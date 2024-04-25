#define __INTERPRET_C__

#include <stdio.h>
#include <signal.h>

#include "lerror.h"
#include "lstring.h"
#include "rexx.h"
#include "stack.h"
#include "trace.h"
#include "bintree.h"
#include "compile.h"
#include "interpre.h"

#if defined(__MVS__) && defined(JCC) || defined(__CROSS__)
#include "rxmvsext.h"
#endif

#include "external.h"

/* ---------------- global variables ------------------ */
int	_trace;			/* if trace is enabled	*/
PLstr   RxStck[STCK_SIZE];	/* Array of PLstr       */
int     RxStckTop;		/* top item of stack    */
Lstr	_tmpstr[STCK_SIZE];	/* temporary strings	*/
Lstr    LTMP[16];
unsigned long long  ullInstrCount = 0;
char brxoptions[16]="";
char SignalCondition[64]="";
char SignalLine[64]="";

/*extern	int	_interrupt;*/	/* if any interrupt is pending	*/
/*void	ProcessInterrupt();*/

/* ---------------- Local variables ------------------- */
static	Scope	VarScope;	/* Variables Scope      */
static	PLstr	ToParse;	/* Parsing variables	*/
static	int	DataStart,
		DataEnd,
		BreakStart,
		BreakEnd,
		SourceEnd;	/* Length of string+1	*/


static	jmp_buf  old_error;	/* keep old value of errortrap */

static RX_ENVIRONMENT_BLK_PTR envBlock;

extern Lstr	stemvaluenotfound;	/* from variable.c */

static void updateEnvironment(Scope scope, int proc_id);

#define STACKTOP	RxStck[RxStckTop]
#define STACKP(i)	RxStck[RxStckTop-(i)]

#ifdef __DEBUG__
#	define DEBUGDISPLAY0(a)		if (__debug__) printf("\t%zu\t%s\n",inst_ip,(a))
#	define DEBUGDISPLAY0nl(a)	if (__debug__) printf("\t%zu\t%s\t",inst_ip,(a))
#	define DEBUGDISPLAY(a)		if (__debug__) {printf("\t%zu\t%s\t\"",inst_ip,(a)); \
					Lprint(STDOUT,RxStck[RxStckTop]); printf("\"\n"); }
#	define DEBUGDISPLAYi(a,b)	if (__debug__) {printf("\t%zu\t%s\t\"",inst_ip,(a)); \
					Lprint(STDOUT,(b)); printf("\"\n"); }
#	define DEBUGDISPLAY2(a)		if (__debug__) {printf("\t%zu\t%s\t\"",inst_ip,(a)); \
					Lprint(STDOUT,STACKP(1)); printf("\",\""); \
					Lprint(STDOUT,STACKTOP);printf("\"\n"); }
#else
#	define DEBUGDISPLAY0(a)
#	define DEBUGDISPLAY0nl(a)
#	define DEBUGDISPLAY(a)
#	define DEBUGDISPLAYi(a,b)
#	define DEBUGDISPLAY2(a)
#endif

#ifdef __PROFILE__
int	instr_cnt[256];		/* instruction counter */
#endif

#define CHKERROR	if (RxStckTop==STCK_SIZE-1) Lerror(ERR_STORAGE_EXHAUSTED,0)
#define	INCSTACK	{ RxStckTop++; CHKERROR; }
#define	POP_C_POP_B_PEEK_A	{ POP(C); POP(B); PEEK(A); }
#define PEEK(x)		x = &(STACKTOP)
#define PEEKR(x,r)	x = &(RxStck[RxStckTop-(r)])
#define POP(x)		x = &(RxStck[RxStckTop--])
#define PUSH(x)		{x = &(RxStck[++RxStckTop]); CHKERROR; }

#ifndef ALIGN
#	define PLEAF(x)		{ x = (PBinLeaf)(*(dword*)Rxcip); \
				Rxcip += sizeof(dword); }
#	define INCWORD(x)	(x) += sizeof(word)
#	define INCDWORD(x)	(x) += sizeof(dword)
#	define CWORD		word
#else
#	define PLEAF(x)		x = (PBinLeaf)(*Rxcip++)
#	define INCWORD(x)	(x)++
#	define INCDWORD(x)	(x)++
#	define CWORD		dword
#endif

#ifdef __DEBUG__
/* -------------- DebugStackList ------------- */
static void
DebugStackList(void)
{
	int	i;
	if (RxStckTop<0)
		printf("Stack is empty\n");
	else
		for (i=RxStckTop; i>=0; i--) {
			printf("#%d: \"",i);
			Lprint(STDOUT,RxStck[i]);
			printf("\"\n");
		}
} /* DebugStackList */
#endif

/* ---------------- RxProcResize ---------------- */
void __CDECL
RxProcResize( void )
{
	size_t oldsize=_proc_size;

	_proc_size += PROC_INC;
	_proc = (RxProc*) REALLOC( _proc, _proc_size * sizeof(RxProc) );
	MEMSET(_proc+oldsize,0,PROC_INC*sizeof(RxProc));
} /* RxProcResize */

/* ------------- I_trigger_space -------------- */
static void
I_trigger_space( void )
{
	/* normalise to 0 .. len-1 */
	DataStart = BreakEnd-1;

	/* skip leading spaces */
	LSKIPBLANKS(*ToParse,DataStart);

	/* find word */
	BreakStart = DataStart;
	LSKIPWORD(*ToParse,BreakStart);

	/* skip trailing spaces */
	BreakEnd = BreakStart;
	LSKIPBLANKS(*ToParse,BreakEnd);

	/* again in rexx strings 1..len */
	DataStart++;
	BreakStart++;
	BreakEnd++;
} /* I_trigger_space */

/* ------------- I_trigger_litteral -------------- */
static void
I_trigger_litteral(const PLstr lit)
{
	int	PatternPos;

	PatternPos = (int)Lpos(lit,ToParse,DataStart);
	if (PatternPos>0) {
		BreakStart = PatternPos;
		BreakEnd = PatternPos + LLEN(*lit);
	} else {	/* the rest of the source is selected */
		DataStart = BreakEnd;
		BreakStart = SourceEnd;
		BreakEnd = SourceEnd;
	}
} /* I_trigger_litteral */

/* ----------------- I_LoadOption ---------------- */
static void
I_LoadOption( const PLstr value, const int opt )
{
#ifndef WCE
	char	*ch;
#endif

	switch (opt) {
		case environment_opt:
			Lstrcpy(value,_proc[_rx_proc].env);
			break;

		case digits_opt:
			Licpy(value,_proc[_rx_proc].digits);
			break;

		case fuzz_opt:
			Licpy(value,_proc[_rx_proc].fuzz);
			break;

		case form_opt:
			Lscpy(value,(_proc[_rx_proc].form)?"ENGINEERING":"SCIENTIFIC");
			break;

		case author_opt:
			Lscpy(value,AUTHOR);
			break;

		case version_opt:
			Lscpy(value,VERSIONSTR);
			break;

		case os_opt:
			Lscpy(value,OS);
			break;

		case calltype_opt:
			switch (_proc[_rx_proc].calltype) {
				case CT_PROCEDURE:
					Lscpy(value,"PROCEDURE");
					break;
				case CT_FUNCTION:
					Lscpy(value,"FUNCTION");
					break;
				default:
					Lscpy(value,"COMMAND");
			}
			break;

		case filename_opt:
			Lstrcpy(value,&(CompileClause[0].fptr)->name);
			break;

		case prgname_opt:
			Lscpy(value,_prgname);
			break;

		case shell_opt:
#ifndef WCE
			ch = getenv(SHELL);
			if (ch)
				Lscpy(value,ch);
			else
#endif
				LZEROSTR(*value);
			break;

		default:
			Lerror(ERR_INTERPRETER_FAILURE,0);
	}
} /* I_LoadOption */

/* ----------------- I_StoreOption --------------- */
static void
I_StoreOption( const PLstr value, const int opt )
{
	long	l;

	switch (opt) {
		case environment_opt:
			if (LLEN(*value) > 250)
				Lerror(ERR_ENVIRON_TOO_LONG,1,value);
			if (_rx_proc > 0 && _proc[_rx_proc].env == _proc[_rx_proc-1].env)
				LPMALLOC(_proc[_rx_proc].env);
			Lstrcpy(_proc[_rx_proc].env,value);
			break;

		case trace_opt:
			TraceSet(value);
			if (_proc[_rx_proc].trace &
				(normal_trace | off_trace | error_trace))
					_trace = FALSE;
			else
					_trace = TRUE;

			break;

		case digits_opt:
			if (LLEN(*value)==0)
				_proc[_rx_proc].digits = LMAXNUMERICDIGITS;
			else {
				l = Lrdint(value);
				if (l <= 0)
					Lerror(ERR_INVALID_INTEGER,5,value);
				_proc[_rx_proc].digits = (int)l;
			}
			lNumericDigits = MIN(_proc[_rx_proc].digits,LMAXNUMERICDIGITS);
			if (_proc[_rx_proc].digits <= _proc[_rx_proc].fuzz)
				Lerror(ERR_INVALID_RESULT,1);
			break;

		case fuzz_opt:
			if (LLEN(*value)==0)
				_proc[_rx_proc].fuzz = 0;
			else {
				l = Lrdint(value);
				if (l <= 0)
					Lerror(ERR_INVALID_INTEGER,6,value);
				_proc[_rx_proc].fuzz = (int)l;
			}
			if (_proc[_rx_proc].digits <= _proc[_rx_proc].fuzz)
				Lerror(ERR_INVALID_RESULT,1);
			break;

		case form_opt:
			_proc[_rx_proc].form = (int)Lrdint(value);
			break;

		case set_signal_opt:
		case set_signal_name_opt:
			switch (LSTR(*value)[0]) {
				case 'E':
					_proc[_rx_proc].condition |= SC_ERROR;
					if (opt==set_signal_name_opt)
						_proc[_rx_proc].lbl_error = STACKP(1);
					else
						_proc[_rx_proc].lbl_error = &(errorStr->key);
					break;
				case 'H':
					_proc[_rx_proc].condition |= SC_HALT;
					if (opt==set_signal_name_opt)
						_proc[_rx_proc].lbl_halt = STACKP(1);
					else
						_proc[_rx_proc].lbl_halt = &(haltStr->key);
					break;
				case 'N':
					if (LSTR(*value)[2]=='V') {
						_proc[_rx_proc].condition |= SC_NOVALUE;
						if (opt==set_signal_name_opt)
							_proc[_rx_proc].lbl_novalue = STACKP(1);
						else
							_proc[_rx_proc].lbl_novalue = &(noValueStr->key);
					} else {
						_proc[_rx_proc].condition |= SC_NOTREADY;
						if (opt==set_signal_name_opt)
							_proc[_rx_proc].lbl_notready = STACKP(1);
						else
							_proc[_rx_proc].lbl_notready = &(notReadyStr->key);
					}
					break;
				case 'S':
					_proc[_rx_proc].condition |= SC_SYNTAX;
					if (opt==set_signal_name_opt)
						_proc[_rx_proc].lbl_syntax = STACKP(1);
					else
						_proc[_rx_proc].lbl_syntax = &(syntaxStr->key);
					break;
				default:
					Lerror(ERR_INTERPRETER_FAILURE,0);
			}
			break;

		case unset_signal_opt:
			switch (LSTR(*value)[0]) {
				case 'E':
					_proc[_rx_proc].condition &= ~SC_ERROR;
					break;
				case 'H':
					_proc[_rx_proc].condition &= ~SC_HALT;
					break;
				case 'N':
					if (LSTR(*value)[2]=='V')
						_proc[_rx_proc].condition &= ~SC_NOVALUE;
					else
						_proc[_rx_proc].condition &= ~SC_NOTREADY;
					break;
				case 'S':
					_proc[_rx_proc].condition &= ~SC_SYNTAX;
					break;
				default:
					Lerror(ERR_INTERPRETER_FAILURE,0);
			}
			break;

		default:
			Lerror(ERR_INTERPRETER_FAILURE,0);
	}
} /* I_StoreOption */

/* ---------------- I_MakeIntArgs ---------------- */
/* prepare arguments for an internal function call */
/* returns stack position after call               */
#ifdef INLINE
inline
#endif
static int
I_MakeIntArgs( const int na, const int realarg, const CTYPE existarg )
{
	int	i,st;
	word	bp;	/* bit position */

	rxArg.n = na;
	bp = (1 << (na-1));

	/* must doit reverse */
	MEMSET(rxArg.a,0,sizeof(rxArg.a));

	rxArg.r = RxStck[RxStckTop-realarg];

	st = RxStckTop;	/* stack position of arguments */
	for (i=na-1; i>=0; i--) {
		if (existarg & bp) {
			if (rxArg.r == RxStck[st]) {
				Lstrcpy(&(_tmpstr[st]),RxStck[st]);
				rxArg.a[i] = &_tmpstr[st];
			} else
				rxArg.a[i] = RxStck[st];
			st--;
		}
		bp >>= 1;
	}
	return st;
} /* I_MakeIntArgs */

/* ---------------- I_MakeArgs ---------------- */
/* prepare arguments for a call to a func       */
#ifdef INLINE
inline
#endif
static void
I_MakeArgs( const int calltype, const int na, const CTYPE existarg )
{
	int	i,st;
	CTYPE	bp;	/* bit position */
	RxProc	*pr;
	Args	*arg;

	_rx_proc++;		/* increase program items       */

	if (_rx_proc==_proc_size) RxProcResize();
	pr = _proc+_rx_proc;

	/* initialise pr structure */
	/* use the old values      */
	MEMCPY(pr,_proc+_rx_proc-1,sizeof(*pr));
	pr->calltype	= calltype;
	pr->ip		= (size_t)((byte huge *)Rxcip - (byte huge *)Rxcodestart);
	pr->stacktop	= RxStckTop;

	/* setup arguments */
	arg = &(pr->arg);
	arg->n	= na;

	bp = (1 << (na-1));

	/* must doit reverse */
	MEMSET(arg->a,0,sizeof(arg->a));

	st = RxStckTop;	/* stack position of arguments */
	for (i=na-1; i>=0; i--) {
		if (existarg & bp) {
			arg->a[i] = RxStck[st];
			st--;
		} else
			arg->a[i] = NULL;
		bp >>= 1;
	}
	arg->r = RxStck[st];

	if (calltype==CT_FUNCTION)
		pr->stack	= st;
	else
		pr->stack	= st-1;
} /* I_MakeArgs */

/* -------------- I_CallFunction ---------------- */
static int
I_CallFunction( void )
{
	PBinLeaf	leaf,litleaf;
	RxFunc	*func;
	int	ct,nargs,realarg;
	CTYPE	existarg, line;
	Lstr	cmd;
	PLstr	res = NULL;
#ifndef WCE
	int	st;
#endif
#ifdef __DEBUG__
	size_t	inst_ip;
#endif

	/* --- read the arguments here --- */
	PLEAF(leaf);			/* function number	*/
	nargs = *(Rxcip++);		/* number of args	*/
	realarg = *(Rxcip++);		/* real arguments	*/
	existarg = *(CWORD *)Rxcip;	/* existing arguments	*/
		INCWORD(Rxcip);
	line  = *(CWORD *)Rxcip;	/* SIGL line		*/
		INCWORD(Rxcip);
	ct = *(Rxcip++);		/* call type		*/
	func = (RxFunc *)(leaf->value);

#ifdef __DEBUG__
	if (__debug__) {
		int	i;
		for (i=0; i<LLEN(leaf->key); i++)
			putchar(LSTR(leaf->key)[i]);
		printf(" NoArgs=%d, Exist=%lX Type=%s\n",
			nargs, existarg,(func->type==FT_BUILTIN)?"builtin":"other");
	}
#endif

	if (func->type == FT_BUILTIN) {
		nargs = I_MakeIntArgs(nargs,realarg,existarg);
		(func->builtin->func)(func->builtin->opt);
		if (ct==CT_PROCEDURE) {
			RxVarSet(VarScope,resultStr,rxArg.r);
			RxStckTop = nargs-1;	/* clear stack */
		} else
			RxStckTop = nargs;
		return TRUE;
	} else {
		if (func->type!=FT_SYSTEM && func->label == UNKNOWN_LABEL) {
			/* Try to find if there is a program to be loaded */
			LINITSTR(cmd);
			Lstrcpy(&cmd,&leaf->key);
			func->type = FT_SYSTEM;

            if (RxLoadLibrary(&cmd,FALSE) != 0) {
                char moduleName[8 +1];

                bzero(moduleName, 9);
                strncpy(moduleName, (char *) LSTR(cmd), 8);
                strtok(moduleName, " (),");

                if (findLoadModule(moduleName)) {
                    func->type = FT_EXTERNAL;
                }
            }

            LFREESTR(cmd)
		}

		if (func->type == FT_SYSTEM) {
            RxStckTop=-1;
            Lerror(ERR_INVALID_FUNCTION,0);
			return TRUE;
		} else if (func->type == FT_EXTERNAL) {

		    int i;
            CTYPE	bp;

            PLstr retVal;

            char* args[MAX_ARGS];
            bzero(args, sizeof(args));

            bp = (1 << (nargs-1));
            RxSetSpecialVar(SIGLVAR,line);

            for (i=nargs-1; i>=0; i--) {
                if (existarg & bp) {
                    L2STR(RxStck[RxStckTop]);
                    LASCIIZ(*RxStck[RxStckTop])
                    args[i] = (char *) LSTR(*RxStck[RxStckTop]);
                    RxStckTop--;
                } else {
                    args[i]= NULL;
                }

                bp >>= 1;
            }

            retVal = RxStck[RxStckTop];

            callExternalFunction((char *)LSTR(leaf->key), args, nargs, retVal);

            Rxcip++;

        } else {
			Rxcip++;
			RxSetSpecialVar(SIGLVAR,line);
			I_MakeArgs(ct,nargs,existarg);
			Rxcip = (CIPTYPE*)((byte huge *)Rxcodestart+func->label);
			Rxcip++;	/* skip the OP_NEWCLAUSE */
			if (_trace) TraceClause();

			/* handle OP_PROC code */
			if (*Rxcip == OP_PROC) {
				int	exposed;

				/* give a unique program id */
				/* we might have a problem after 2*32 routine calls!! */
				_procidcnt++;
				_proc[_rx_proc].id = _procidcnt;
				Rx_id  = _procidcnt;
#ifdef __DEBUG__
				if (__debug__)
					inst_ip = (size_t)((byte huge *)Rxcip - (byte huge *)Rxcodestart);
#endif
				DEBUGDISPLAY0nl("PROC ");
				Rxcip++;
				_proc[_rx_proc].scope = RxScopeMalloc();
                VarScope = _proc[_rx_proc].scope;
                updateEnvironment(VarScope, Rx_id);

                /* handle exposed variables */
				exposed = *(Rxcip++);
#ifdef __DEBUG__
				if (__debug__ && exposed>0)
					printf("EXPOSE");
#endif
				for (;exposed>0;exposed--) {
					/* Get pointer to variable */
					PLEAF(litleaf);
					/* test if indirect exposure (var) */
					if (litleaf==NULL) {
						int	found;
						PBinLeaf leaf;

						PLEAF(litleaf);
						RxVarExpose(VarScope,litleaf);
#ifdef __DEBUG__
						if (__debug__) {
							putchar(' ');
							putchar('(');
							Lprint(STDOUT,&(litleaf->key));
							putchar(')');
							putchar('=');
						}
#endif
						leaf = RxVarFind(_proc[_rx_proc-1].scope,
								litleaf,
								&found);
#ifdef __DEBUG__
						if (__debug__)
							Lprint(STDOUT,LEAFVAL(leaf));
#endif
						if (found)
							RxVarExposeInd(VarScope,LEAFVAL(leaf));
					} else {
#ifdef __DEBUG__
						if (__debug__) {
							putchar(' ');
							Lprint(STDOUT,&(litleaf->key));
						}
#endif
						RxVarExpose(VarScope,litleaf);
					}
				}
#ifdef __DEBUG__
				if (__debug__)
					putchar('\n');
#endif
			}
		}
		return FALSE;
	}
}

static void updateEnvironment(Scope scope, int proc_id) {
    if (envBlock != NULL) {
        ((RX_ENVIRONMENT_CTX_PTR) envBlock->envblock_userfield)->variables = scope;
        ((RX_ENVIRONMENT_CTX_PTR) envBlock->envblock_userfield)->proc_id   = proc_id;
    }
}
/* I_CallFunction */

/* ---------------- I_ReturnProc -------------- */
/* restore arguments after a procedure return	*/
static void
I_ReturnProc( void )
{
		/* fix ip and stack */
	Rxcip = (CIPTYPE*)((byte huge *)Rxcodestart + _proc[_rx_proc].ip);
	RxStckTop = _proc[_rx_proc].stack;

	if (_rx_proc>0) {
			/* free everything that it is new */
		if (VarScope!=_proc[_rx_proc-1].scope) {
			RxScopeFree(VarScope);
			FREE(VarScope);
		}

		if (_proc[_rx_proc].env != _proc[_rx_proc-1].env)
			LPFREE(_proc[_rx_proc].env);
	}

		/* load previous data and exit */
    _rx_proc--;
    Rx_id = _proc[_rx_proc].id;
    VarScope = _proc[_rx_proc].scope;
    updateEnvironment(VarScope, Rx_id);

    lNumericDigits = _proc[_rx_proc].digits;

	if (_proc[_rx_proc].trace & (normal_trace | off_trace | error_trace))
		_trace = FALSE;
	else
		_trace = TRUE;
} /* I_ReturnProc */

/* ------------ RxInitInterStr -------------- */
void __CDECL
RxInitInterStr()
{
	RxProc *pr;

	_rx_proc++; 				/* increase program items       */
	if (_rx_proc==_proc_size) RxProcResize();
	pr = _proc+_rx_proc;

	/* program id is the same */
	MEMCPY(pr,_proc+_rx_proc-1,sizeof(*pr));
	pr->calltype  = CT_INTERPRET;
	pr->ip        = (size_t)((byte huge *)Rxcip - (byte huge *)Rxcodestart);
	pr->codelen   = LLEN(*_code);		/* remember code len before compile */
	pr->clauselen = CompileCurClause;	/* remember clause len -//- */
	pr->stack     = RxStckTop-1;		/* before temporary str */
	pr->stacktop  = RxStckTop;

	/* setup arguments */
	(pr->arg).n = 0;
	MEMSET(pr->arg.a,0,sizeof(pr->arg.a));
	(pr->arg).r = NULL;

	/* --- save state --- */
	MEMCPY(old_error,_error_trap,sizeof(_error_trap));
	SIGNAL(SIGINT,SIG_IGN);

	/* compile the program */
	RxInitCompile(rxFileList,STACKTOP);
	RxCompile();
	pr->codelenafter = LLEN(*_code);	/* remember code len after compile */

	/* --- restore state --- */
	MEMCPY(_error_trap,old_error,sizeof(_error_trap));
	SIGNAL(SIGINT,RxHaltTrap);

	/* might have changed position */
	Rxcodestart = (CIPTYPE*)LSTR(*_code);
	Rxcip       = (CIPTYPE*)((byte huge *)Rxcodestart + pr->codelen);

	/* check for an error in compilation */
	if (rxReturnCode) {
		/* --- load previous data and exit ---- */
		Rxcip = (CIPTYPE*)((byte huge *)Rxcodestart + pr->ip);
		_rx_proc--;
		Rx_id = _proc[_rx_proc].id;
		VarScope = _proc[_rx_proc].scope;

		RxSetSpecialVar(RCVAR,rxReturnCode);
		RxSignalCondition(SC_SYNTAX,"");
	}
} /* RxInitInterStr */

/* ------------ RxDoneInterStr -------------- */
static void
RxDoneInterStr( void )
{
	/* fix ip and stack */
	if (_proc[_rx_proc].calltype == CT_INTERACTIVE) {
		if (_proc[_rx_proc].trace &
			(normal_trace | off_trace | error_trace))
				_trace = FALSE;
			else
				_trace = TRUE;
	}

	Rxcip = (CIPTYPE*)((byte huge *)Rxcodestart + _proc[_rx_proc].ip);
	RxStckTop = _proc[_rx_proc].stack;

	/* Fixup code length, cut the interpretation code
	 * Warning in the case that the interpret calls an import
	 * then the import code will be after the temporary
	 * interpret one. In this case leave untouched the
	 * tempoerary interpret code (leaving garbage)
	 * but otherwise we will end up with wrong pointers.
	 */
	if (_proc[_rx_proc].codelenafter == LLEN(*_code)) {
		LLEN(*_code)     = _proc[_rx_proc].codelen;
		CompileCurClause = _proc[_rx_proc].clauselen;
	}
	if (_proc[_rx_proc].env != _proc[_rx_proc-1].env) {
		Lstrcpy(_proc[_rx_proc-1].env, _proc[_rx_proc].env);
		LPFREE(_proc[_rx_proc].env);
	}

	/* --- load previous data and exit ---- */
	_rx_proc--;
	Rx_id = _proc[_rx_proc].id;

	_proc[_rx_proc].trace = _proc[_rx_proc+1].trace;
	_proc[_rx_proc].interactive_trace = _proc[_rx_proc+1].interactive_trace;
	VarScope = _proc[_rx_proc].scope;
} /* RxDoneInterStr */

/* ---------------- RxInitInterpret --------------- */
void __CDECL
RxInitInterpret( void )
{
	int	i;

#ifdef __PROFILE__
	MEMSET(instr_cnt,sizeof(instr_cnt),0);
#endif
	MEMSET(RxStck,0,(STCK_SIZE)*sizeof(PLstr));
	RxStckTop = -1;
	MEMSET(_tmpstr,0,(STCK_SIZE)*sizeof(Lstr));
	for (i=0; i<STCK_SIZE;i++) {
		Lfx(&(_tmpstr[i]),0);
		if (!LSTR(_tmpstr[i])) Lerror(ERR_STORAGE_EXHAUSTED,0);
	}

    envBlock = getEnvBlock();
	if (envBlock != NULL) {
        ((RX_ENVIRONMENT_CTX_PTR) envBlock->envblock_userfield)->literals = &rxLitterals;
    }

} /* RxInitInterpret */

/* ---------------- RxDoneInterpret --------------- */
void __CDECL
RxDoneInterpret( void )
{
	int	i;
#ifdef __PROFILE__
	FILE	*fout;
	fout = fopen("instr.cnt","w");
	fprintf(fout,"Instr\tCount\n");
	for (i=0; i<OP_POW; i++)	/* pow is the last command */
		fprintf(fout,"%d\t%d\n",i,instr_cnt[i]);
	fclose(fout);
#endif
#ifdef __DEBUG__
	mem_chk();

	if (RxStckTop>=0) {
		fprintf(STDERR,"interpret: %d items left in stack.\n", RxStckTop+1);
		DebugStackList();
	}
#endif

	/* clear stack */
	for (i=0; i<STCK_SIZE; i++) {
#ifdef __DEBUG__
		if (__debug__ && LLEN(_tmpstr[i])) {
			fprintf(STDERR,"Freeing... %d: \"",i);
			Lprint(STDERR,&(_tmpstr[i]));
			fprintf(STDERR,"\"\n");
		}
#endif
		LFREESTR(_tmpstr[i]);
	}
} /* RxDoneInterpret */

/* ---------------- RxInterpret --------------- */
int __CDECL
RxInterpret( void )
{
	PLstr	a;
	IdentInfo	*inf;
	CTYPE	w;
	int	na, nf, jc, errno, subno, found;
	PBinLeaf	litleaf,leaf;
	RxFunc	*func;
#ifdef __DEBUG__
	size_t	inst_ip;
	char	cmd='\n';
#endif
#ifdef WCE
	int	event_count = 0;
#endif
	rxReturnCode = 0;
	Rx_id  = _proc[_rx_proc].id;

	Rxcodestart = (CIPTYPE*)LSTR(*_code);
	VarScope = _proc[_rx_proc].scope;
    updateEnvironment(VarScope, Rx_id);

	Rxcip   = (CIPTYPE*)((byte huge *)Rxcodestart + _proc[_rx_proc].ip);
	_proc[_rx_proc].stack = RxStckTop;

	if (_proc[_rx_proc].trace & (normal_trace | off_trace | error_trace))
			_trace = FALSE;
	else
			_trace = TRUE;

	SIGNAL(SIGINT,RxHaltTrap);

	if ((jc=setjmp(_error_trap))!=0) {
		 CIPTYPE *tmp_Rxcip;

		if (jc==JMP_EXIT) {
			RxStckTop = -1;
			goto interpreter_fin;
		}
		/* else if (jc==JMP_CONTINUE) .... CONTINUE code */

		/* exit from interpret, if we are in any */
		tmp_Rxcip = Rxcip;
		while (_proc[_rx_proc].calltype==CT_INTERPRET)
			RxDoneInterStr();
		Rxcip = tmp_Rxcip;

		/* clear stack */
		RxStckTop = _proc[_rx_proc].stacktop;
	}

	while (1) {
main_loop:

#ifdef __DEBUG__
	if (__debug__) {
		while (1) {
			cmd = getchar();
			switch (l2u[(byte)cmd]) {
				case 'M':
					printf("Memory allocated=%ld\n",
						mem_allocated());
					break;
				case 'S':
					DebugStackList();
					break;
				case 'Q':
					goto interpreter_fin;
				case '\n':
					goto outofcmd;
			}
		}
outofcmd:
		printf("Stck:%d\t",RxStckTop+1);
		inst_ip = (size_t)((byte huge *)Rxcip - (byte huge *)Rxcodestart);
	}
#endif
#ifdef __PROFILE__
	instr_cnt[(int)*Rxcip]++;
#endif
	switch (*(Rxcip++)) {
		/*
		 * [mnemonic] <type>[value]...
		 * type:	b = byte
		 *		w = word
		 *		p = pointer
		 */
			/* START A NEW COMMAND */
		case OP_NEWCLAUSE:
			ullInstrCount++;
			DEBUGDISPLAY0("NEWCLAUSE");
			if (_trace) TraceClause();
#ifdef WCE
			/* Check for messages in the event queue */
			if (++event_count == MAX_EVENT_COUNT) {
				event_count = 0;
				/* Peek the stacked events */
				WKeyPressed();
/*//				if (_interrupt) ProcessInterrupt(); */
			}
#endif
			goto main_loop;

				/* POP = NO OPERATION	*/
		case OP_NOP:
			DEBUGDISPLAY0("NOP");
			goto main_loop;

				/* PUSH p[lit]			*/
				/* push a litteral to stack	*/
		case OP_PUSH:
			RxStckTop++;
			STACKTOP = (PLstr)(*(dword*)Rxcip);
			INCDWORD(Rxcip);
			CHKERROR;
			DEBUGDISPLAY("PUSH");
			goto chk4trace;

				/* PUSHTMP */
		case OP_PUSHTMP:
			RxStckTop++;
			STACKTOP = &_tmpstr[RxStckTop];
			CHKERROR;
			DEBUGDISPLAY0("PUSHTMP");
			goto main_loop;

				/* POP b[num]		*/
				/* pop NUM stack items	*/
		case OP_POP:
			DEBUGDISPLAY0("POP");
			RxStckTop -= *(Rxcip++);
			goto main_loop;

				/* DUP b[rel]			*/
				/* duplicate RELative stck item	*/
		case OP_DUP:
			RxStckTop++;
			STACKTOP = RxStck[RxStckTop-*(Rxcip++)-1];
			CHKERROR;
			DEBUGDISPLAY("DUP");
			goto main_loop;

				/* COPY				*/
				/* copy (Lstrcpy) top item	*/
				/* to previous one		*/
		case OP_COPY:
			DEBUGDISPLAY("COPY");
			Lstrcpy(STACKP(1),STACKTOP);
			RxStckTop -= 2;
			goto main_loop;

				/* COPY2TMP			*/
				/* if top item is not a pointer	*/
				/* to a tmp var then copy the	*/
				/* value to a tmp var		*/
		case OP_COPY2TMP:
			/* copy to temporary only if different */
			if (STACKTOP != &(_tmpstr[RxStckTop])) {
				Lstrcpy(&(_tmpstr[RxStckTop]),STACKTOP);
				STACKTOP = &(_tmpstr[RxStckTop]);
			}
			DEBUGDISPLAY("COPY2TMP");
			goto main_loop;

				/* PATCH w[rel] b[code]	*/
				/* patch CODE string to RELative pos with CODE */
		case OP_PATCH:
			w = *(CWORD *)Rxcip;	INCWORD(Rxcip);
			*(CIPTYPE*)((byte huge *)Rxcodestart + w) = *(Rxcip++);
			DEBUGDISPLAY0("PATCH");
			goto main_loop;

				/* RAISE b[cond] b[errno] b[subno]	*/
				/* raise an error condition		*/
		case OP_RAISE:
			errno = *(Rxcip++);
			subno = *(Rxcip++);
			DEBUGDISPLAY("RAISE");
			Lerror(errno,subno,STACKTOP);
			goto main_loop;

				/* LOADARG b[arg]		*/
				/* push an ARGument to stck	*/
		case OP_LOADARG:
			INCSTACK;
			na = (unsigned)*(Rxcip++);	/* argument to push */
			if (_proc[_rx_proc].arg.a[na])
				STACKTOP = _proc[_rx_proc].arg.a[na];
			else {
				LZEROSTR(_tmpstr[RxStckTop]);
				STACKTOP = &(_tmpstr[RxStckTop]);
			}
			DEBUGDISPLAY("LOADARG");
			goto main_loop;


				/* LOADOPT [data]	*/
				/* load an option	*/
		case OP_LOADOPT:
			INCSTACK;
			nf = (unsigned)*(Rxcip++);	/* option to load */
/**
/// Maybe only pointer to Option!!!
**/
			STACKTOP = &(_tmpstr[RxStckTop]);
			I_LoadOption(STACKTOP,nf);
			DEBUGDISPLAY("LOADOPT");
			goto main_loop;

				/* STOREOPT [data]	*/
				/* store an option	*/
		case OP_STOREOPT:
			DEBUGDISPLAY("STOREOPT");
			nf = (unsigned)*(Rxcip++);	/* option to store */
			I_StoreOption(STACKTOP,nf);
			RxStckTop--;
			goto main_loop;

				/* LOAD p[leaf]			*/
				/* push a VARiable to stack	*/
		case OP_LOAD:
			INCSTACK;		/* make space	*/
			PLEAF(litleaf);		/* get variable ptr	*/
			DEBUGDISPLAYi("LOAD",&(litleaf->key));

			inf = (IdentInfo*)(litleaf->value);

			/* check to see if we have allready its position */
			if (inf->id == Rx_id) {
				leaf = inf->leaf[0];
				STACKTOP = LEAFVAL(leaf);
			} else {
				leaf = RxVarFind(VarScope, litleaf, &found);
				if (found)
					STACKTOP = LEAFVAL(leaf);
				else {
					if (inf->stem) {
						/* Lstrcpy to a temp variable */
						Lstrcpy(&(_tmpstr[RxStckTop]),&stemvaluenotfound);
						STACKTOP = &(_tmpstr[RxStckTop]);
						if (leaf==NULL &&
							_proc[_rx_proc].condition & SC_NOVALUE)
							RxSignalCondition(SC_NOVALUE,LSTR(litleaf->key));
					} else {
						/* signal no value found */
						if (_proc[_rx_proc].condition & SC_NOVALUE)
							RxSignalCondition(SC_NOVALUE,LSTR(litleaf->key));
						STACKTOP = &(litleaf->key);if (_proc[_rx_proc].condition & SC_NOVALUE)
							RxSignalCondition(SC_NOVALUE,LSTR(litleaf->key));
						STACKTOP = &(litleaf->key);
					}
				}
			}

			goto chk4trace;

				/* STORE p[leaf]			*/
				/* store top stack item to VARiable	*/
		case OP_CREATE:		/* assigmnent	*/
			INCSTACK;
			PLEAF(litleaf);	/* Get pointer to variable */
			DEBUGDISPLAYi("CREATE",&(litleaf->key));

			inf = (IdentInfo*)(litleaf->value);
			if (inf->id == Rx_id) {
				leaf = inf->leaf[0];
				STACKTOP = LEAFVAL(leaf);
			} else {
				leaf = RxVarFind(VarScope,litleaf,&found);

				if (found)
					STACKTOP = LEAFVAL(leaf);
				else {
					leaf = RxVarAdd(VarScope,
						&(litleaf->key),
						inf->stem,
						leaf);
					STACKTOP = LEAFVAL(leaf);
					if (inf->stem==0) {
						inf->id = Rx_id;
						inf->leaf[0] = leaf;
					}
				}

			}
			goto main_loop;

				/* DROP p[leaf]		*/
				/* drop VARiable	*/
		case OP_DROP:
			PLEAF(litleaf);	/* Get pointer to variable */
			DEBUGDISPLAYi("DROP",&(litleaf->key));

			inf = (IdentInfo*)(litleaf->value);
			if (inf->id == Rx_id) {
				leaf = inf->leaf[0];
				RxVarDel(VarScope,litleaf,leaf);
			} else {
				leaf = RxVarFind(VarScope,litleaf,&found);
				if (found)
					RxVarDel(VarScope,litleaf,leaf);
			}
			inf->id = NO_CACHE;
			Rxcip++;
			goto main_loop;

				/* indirect drop, from stack	*/
				/* asssume that is UPPER case tmp */
		case OP_DROPIND:
			DEBUGDISPLAY("DROP_IND");
			RxVarDelInd(VarScope,STACKTOP);
			RxStckTop--;
			goto chk4trace;

		case OP_ASSIGNSTEM:
			PLEAF(litleaf);	/* Get pointer to stem */
			DEBUGDISPLAYi("ASSIGNSTEM",&(litleaf->key));
			inf = (IdentInfo*)(litleaf->value);
			if (inf->id == Rx_id) {
				leaf = inf->leaf[0];
				RxScopeAssign(leaf);
			} else {
				leaf = RxVarFind(VarScope,litleaf,&found);
				if (found)
					RxScopeAssign(leaf);
			}
			goto main_loop;

				/* BYINIT [patchpos]	*/
		case OP_BYINIT:
			w = *(CWORD *)Rxcip;	INCWORD(Rxcip);
			DEBUGDISPLAY("BYINIT");
			/* copy to temporary only if different */
			if (STACKTOP != &(_tmpstr[RxStckTop])) {
				Lstrcpy(&(_tmpstr[RxStckTop]),STACKTOP);
				STACKTOP = &(_tmpstr[RxStckTop]);
			}
			/* patch comparision code */
			if (Llt(STACKTOP,&(zeroStr->key)))
				*(CIPTYPE*)((byte huge *)Rxcodestart + w) = OP_TLE;
			else
				*(CIPTYPE*)((byte huge *)Rxcodestart + w) = OP_TGE;
			goto main_loop;

				/* FORINIT		*/
				/* Initialise a FOR loop*/
		case OP_FORINIT:
			DEBUGDISPLAY("FORINIT");
			/* copy to temporary only if different */
			if (STACKTOP != &(_tmpstr[RxStckTop])) {
				Lstrcpy(&(_tmpstr[RxStckTop]),STACKTOP);
				STACKTOP = &(_tmpstr[RxStckTop]);
			}
			L2INT(STACKTOP);	/* it is in temporary */
			if (Llt(STACKTOP,&(zeroStr->key)))
				Lerror(ERR_INVALID_INTEGER,3,STACKTOP);
			goto main_loop;

				/* DECFOR		*/
		case OP_DECFOR:
			DEBUGDISPLAY("DECFOR");
			a = RxStck[RxStckTop-*(Rxcip++)];
			if (Leq(a,&(zeroStr->key)))
				Rxcip = (CIPTYPE*)((byte huge *)Rxcodestart+ *(CWORD*)Rxcip);
			else
				INCWORD(Rxcip);
			Ldec(a);
			goto main_loop;

/**
//// Beware might lose something when number is like '   10   '
**/
				/* TOINT		*/
				/* change to integer	*/
		case OP_TOINT:
			DEBUGDISPLAY("TOINT");
			L2INT(STACKTOP);
			goto main_loop;

				/* LOWER		*/
				/* upper top stack	*/
		case OP_LOWER:
			DEBUGDISPLAY("LOWER");
			Llower(STACKTOP);
			goto main_loop;

				/* UPPER		*/
				/* upper top stack	*/
		case OP_UPPER:
			DEBUGDISPLAY("UPPER");
			Lupper(STACKTOP);
			goto main_loop;

				/* SIGNAL p[label]	*/
				/* clear stack and jmp to LABEL pos	*/
		case OP_SIGNAL:
			/* clear stack */
			RxStckTop = _proc[_rx_proc].stacktop;

			/* check label */
			PLEAF(leaf);
			func = (RxFunc*)(leaf->value);
			DEBUGDISPLAYi("SIGNAL",&(leaf->key));

			if (func->label==UNKNOWN_LABEL)
				Lerror(ERR_UNEXISTENT_LABEL,1,&(leaf->key));
			/* jump */
			Rxcip=(CIPTYPE*)((byte huge *)Rxcodestart+func->label);
			goto main_loop;

				/* SIGNALVAL [address]	*/
				/* get address from stack */
		case OP_SIGNALVAL:
			DEBUGDISPLAY("SIGNALVAL");

			/* search for label */
			L2STR(STACKTOP);
			leaf = BinFind(&_labels,RxStck[RxStckTop--]);
			if (leaf==NULL || ((RxFunc*)(leaf->value))->label == UNKNOWN_LABEL)
				Lerror(ERR_UNEXISTENT_LABEL,1,RxStck[RxStckTop+1]);
			func = (RxFunc*)(leaf->value);

			/* clear stack */
			RxStckTop = _proc[_rx_proc].stacktop;

			/* jump */
			Rxcip = (CIPTYPE*)((byte huge *)Rxcodestart + (size_t)(func->label));
			goto main_loop;

				/* JMP w[pos]				*/
				/* unconditional jump to POSition	*/
		case OP_JMP:
			DEBUGDISPLAY0nl("JMP");
			Rxcip = (CIPTYPE*)((byte huge *)Rxcodestart + *(CWORD *)Rxcip);
#ifdef __DEBUG__
			if (__debug__)
				printf("%zd\n",(byte huge *)Rxcip-(byte huge *)Rxcodestart);
#endif
			goto main_loop;

				/* JF w[pos]			*/
				/* jump if top is 0 to POSition	*/
		case OP_JF:
			DEBUGDISPLAY0nl("JF");
#ifdef __DEBUG__
			if (__debug__) {
				w = *(CWORD *)Rxcip;
				if (!Lbool(STACKTOP))
					printf("%ld *\n",w);
				else
					printf("%ld\n",w);
			}
#endif
			if (!Lbool(RxStck[RxStckTop--]))
				Rxcip = (CIPTYPE*)((byte huge *)Rxcodestart+ *(CWORD*)Rxcip);
			else
				INCWORD(Rxcip);
			goto main_loop;

				/* JT w[pos]			*/
				/* jump if top is 1 to POSition	*/
		case OP_JT:
			DEBUGDISPLAY0nl("JT");
#ifdef __DEBUG__
			if (__debug__) {
				w = *(CWORD *)Rxcip;
				if (Lbool(STACKTOP))
					printf("%ld *\n",w);
				else
					printf("%ld\n",w);
			}
#endif
			if (Lbool(RxStck[RxStckTop--]))
				Rxcip = (CIPTYPE*)((byte huge *)Rxcodestart+ *(CWORD*)Rxcip);
			else
				INCWORD(Rxcip);
			goto main_loop;

				/* CALL p[label] b[noargs] w[existarg]	*/
				/* create new stack and jmp to LABEL pos*/
		case OP_CALL:
			DEBUGDISPLAY0nl("CALL");
			if (I_CallFunction()) {
				goto chk4trace;
			}
			goto main_loop;

				/* RETURN			*/
				/* clear stack and return	*/
				/* if first prg then exit	*/
		case OP_RETURN:
			DEBUGDISPLAY0("RETURN");
			if (_proc[_rx_proc].calltype == CT_FUNCTION)
				Lerror(ERR_NO_DATA_RETURNED,0);
			if (_rx_proc==0) {	/* root program */
				rxReturnCode = 0;
				goto interpreter_fin;
			}
			I_ReturnProc();
			goto main_loop;

				/* RETURNF			*/
				/* move top of stack to correct */
				/* position of return arg and	*/
				/* clear stack			*/
		case OP_RETURNF:
			DEBUGDISPLAY0("RETURNF");
			if (_rx_proc==0) {	/* Root program */
				rxReturnCode = (int)Lrdint(RxStck[RxStckTop--]);
				goto interpreter_fin;
			} else
			if (_proc[_rx_proc].calltype != CT_PROCEDURE)
/**
// It is possible to do a DUP in the compile code of returnf
**/
				Lstrcpy(_proc[_rx_proc].arg.r, STACKTOP);
			else {
				/* is the Variable space private? */
				/* proc: PROCEDURE */
				if (VarScope!=_proc[_rx_proc-1].scope)
					/* not a tmp var */
					if (STACKTOP != &(_tmpstr[RxStckTop]))
					{
						Lstrcpy(&(_tmpstr[RxStckTop]),
							STACKTOP);
						STACKTOP =
							&(_tmpstr[RxStckTop]);
					}
				/* point the return data */
				a = STACKTOP;
			}

			I_ReturnProc();

			if (_proc[_rx_proc+1].calltype == CT_PROCEDURE)
				/* Assign the the RESULT variable */
				RxVarSet(VarScope,resultStr,a);
			goto main_loop;

				/* INTERPRET [string] */
		case OP_INTERPRET:
			DEBUGDISPLAY("INTERPRET");
			/* copy to a temporary var */
			if (STACKTOP != &(_tmpstr[RxStckTop])) {
				Lstrcpy(&(_tmpstr[RxStckTop]),STACKTOP);
				STACKTOP = &(_tmpstr[RxStckTop]);
			}
			RxInitInterStr();
			goto main_loop;

		case OP_INTER_END:
			DEBUGDISPLAY0("INTER_END");
			RxDoneInterStr();
			goto main_loop;

				/* PROC */
		case OP_PROC:
			DEBUGDISPLAY0("ERROR-PROC");
			Lerror(ERR_UNEXPECTED_PROC,1);
			goto chk4trace;

				/* SAY			*/
				/* display TOP item	*/
		case OP_SAY:
			DEBUGDISPLAY("SAY");
			Lprint(STDOUT,RxStck[RxStckTop--]);
			PUTCHAR('\n');
			goto main_loop;

				/* SYSTEM		*/
				/* execute a system call*/
		case OP_SYSTEM:
			DEBUGDISPLAY2("SYSTEM");
			L2STR(STACKTOP);
			LASCIIZ(*(STACKTOP));
			L2STR(STACKP(1));
			LASCIIZ(*(STACKP(1)));
			RxExecuteCmd(STACKTOP,STACKP(1));
			RxStckTop -= 2;
			goto main_loop;

				/* EXIT			*/
				/* exit prg with RC	*/
		case OP_EXIT:
			DEBUGDISPLAY("EXIT");
			rxReturnCode = (int)Lrdint(RxStck[RxStckTop--]);
			/* free everything from stack */
#ifndef __DEBUG__
			RxStckTop = -1;
#endif
			goto interpreter_fin;

				/* PARSE		*/
				/* Initialise PARSING	*/
		case OP_PARSE:
			DEBUGDISPLAY("PARSE");
			/* Do not remove from stack */
			ToParse = STACKTOP;
			L2STR(ToParse);
			DataStart = BreakStart = BreakEnd = 1;
			SourceEnd = LLEN(*ToParse)+1;
			goto main_loop;

				/* PVAR			*/
				/* Parse to stack	*/
		case OP_PVAR:
			DEBUGDISPLAY0("PVAR");
			if (BreakEnd<=DataStart)
				DataEnd = SourceEnd;
			else
				DataEnd = BreakStart;

			if (DataEnd!=DataStart) {
				_Lsubstr(RxStck[RxStckTop--], ToParse, DataStart, DataEnd - DataStart);
            }
			else {
				LZEROSTR(*(STACKTOP));
				RxStckTop--;
			}
			if (_trace) {
				RxStckTop++;
				TraceInstruction(*Rxcip);
				RxStckTop--;
			}
			Rxcip++;
			goto main_loop;
			/*** goto chk4trace; ***/

				/* PDOT			*/
				/* Parse to hyperspace	*/
		case OP_PDOT:
			/* Only for debugging */
			DEBUGDISPLAY0("PDOT");
			if (_trace) {
				/* Make space	*/
				RxStckTop++;
				STACKTOP = &(_tmpstr[RxStckTop]);
				if (BreakEnd<=DataStart)
					DataEnd = SourceEnd;
				else
					DataEnd = BreakStart;
				if (DataEnd!=DataStart)
					_Lsubstr(STACKTOP,ToParse,DataStart,DataEnd-DataStart);
				else
					LZEROSTR(*(STACKTOP));
				TraceInstruction(*Rxcip);
				RxStckTop--;	/* free space */
			}
			Rxcip++;
			goto main_loop;

				/* TR_SPACE		*/
				/* trigger a space	*/
		case OP_TR_SPACE:
			DEBUGDISPLAY0("TR_SPACE");
			I_trigger_space();
			goto main_loop;

				/* TR_LIT			*/
				/* trigger a litteral from stck	*/
		case OP_TR_LIT:
			DEBUGDISPLAY("TR_LIT");
			DataStart = BreakEnd;
			I_trigger_litteral(RxStck[RxStckTop--]);
			goto main_loop;

				/* TR_ABS			*/
				/* trigger ABSolute position	*/
		case OP_TR_ABS:
			DEBUGDISPLAY("TR_ABS");
/**
//			L2INT(**A);
**/
			DataStart = BreakEnd;
			BreakStart = (size_t)LINT(*(RxStck[RxStckTop--]));

			/* check for boundaries */
			BreakStart = RANGE(1,BreakStart,SourceEnd);
			BreakEnd = BreakStart;
			goto main_loop;

				/* TR_REL			*/
				/* trigger RELative position	*/
		case OP_TR_REL:
			DEBUGDISPLAY("TR_REL");

/**
//			L2INT(**A);
**/
			DataStart = BreakStart;
			BreakStart = DataStart + (size_t)LINT(*(RxStck[RxStckTop--]));

			/* check for boundaries */
			BreakStart = RANGE(1,BreakStart,SourceEnd);
			BreakEnd = BreakStart;
			goto main_loop;

				/* TR_END			*/
				/* trigger to END of data	*/
		case OP_TR_END:
			DEBUGDISPLAY0("TR_END");
			DataStart = BreakEnd;
			BreakStart = SourceEnd;
			BreakEnd = SourceEnd;
			goto main_loop;

				/* RX_QUEUE			*/
				/* queue stck to Rexx queue	*/
		case OP_RX_QUEUE:
			DEBUGDISPLAY("RX_PUSH");
			LPMALLOC(a);	/* duplicate variable */
			Lfx(a,1);
			Lstrcpy(a,RxStck[RxStckTop--]);
			Queue2Stack(a);
			goto main_loop;

				/* RX_PUSH			*/
				/* push stck to Rexx queue	*/
		case OP_RX_PUSH:
			DEBUGDISPLAY("RX_PUSH");
			LPMALLOC(a);	/* duplicate variable */
			Lfx(a,1);
			Lstrcpy(a,RxStck[RxStckTop--]);
			Push2Stack(a);
			goto main_loop;

				/* RX_PULL			*/
				/* pull stck from Rexx queue	*/
		case OP_RX_PULL:
			RxStckTop++;
			STACKTOP = &(_tmpstr[RxStckTop]);
			a = NULL;
			/* delete empty stacks */
/* dw - let VM handle the stack */
#if !defined(__CMS__)
			while (StackQueued()==0 && rxStackList.items>1)
				DeleteStack();
			if (StackQueued()>0) {
				a = PullFromStack();
				Lstrcpy(STACKTOP,a);
				LPFREE(a);
				while (StackQueued()==0 && rxStackList.items>1)
					DeleteStack();
			} else {
#else
			{
#endif
/*** dw end of let vm do stack */
				Lread(STDIN,STACKTOP,LREADLINE);
			}
			DEBUGDISPLAY("RX_PULL");
			goto main_loop;

				/* RX_EXTERNAL			*/
				/* read data from extrnal queue	*/
		case OP_RX_EXTERNAL:
			RxStckTop++;
			STACKTOP = &(_tmpstr[RxStckTop]);
			Lread(STDIN,STACKTOP,LREADLINE);
			DEBUGDISPLAY("RX_EXTERNAL");
			goto main_loop;

		case OP_EQ:
			DEBUGDISPLAY2("EQ");
			a = STACKP(2);
			LICPY(*a, Leq(STACKP(1),STACKTOP));
			RxStckTop -= 2;
			goto chk4trace;

		case OP_NE:
			DEBUGDISPLAY2("NE");
			a = STACKP(2);
			LICPY(*a, Lne(STACKP(1),STACKTOP));
			RxStckTop -= 2;
			goto chk4trace;

		case OP_GT:
			DEBUGDISPLAY2("GT");
			a = STACKP(2);
			LICPY(*a, Lgt(STACKP(1),STACKTOP));
			RxStckTop -= 2;
			goto chk4trace;

		case OP_GE:
			DEBUGDISPLAY2("GE");
			a = STACKP(2);
			LICPY(*a, Lge(STACKP(1),STACKTOP));
			RxStckTop -= 2;
			goto chk4trace;

		case OP_LT:
			DEBUGDISPLAY2("LT");
			a = STACKP(2);
			LICPY(*a, Llt(STACKP(1),STACKTOP));
			RxStckTop -= 2;
			goto chk4trace;

		case OP_LE:
			DEBUGDISPLAY2("LE");
			a = STACKP(2);
			LICPY(*a, Lle(STACKP(1),STACKTOP));
			RxStckTop -= 2;
			goto chk4trace;

		case OP_DEQ:
			DEBUGDISPLAY2("DEQ");
			a = STACKP(2);
			LICPY(*a, Ldeq(STACKP(1),STACKTOP));
			RxStckTop -= 2;
			goto chk4trace;

		case OP_DNE:
			DEBUGDISPLAY2("DNE");
			a = STACKP(2);
			LICPY(*a, Ldne(STACKP(1),STACKTOP));
			RxStckTop -= 2;
			goto chk4trace;

		case OP_DGT:
			DEBUGDISPLAY2("DGT");
			a = STACKP(2);
			LICPY(*a, Ldgt(STACKP(1),STACKTOP));
			RxStckTop -= 2;
			goto chk4trace;

		case OP_DGE:
			DEBUGDISPLAY2("DGE");
			a = STACKP(2);
			LICPY(*a, Ldge(STACKP(1),STACKTOP));
			RxStckTop -= 2;
			goto chk4trace;

		case OP_DLT:
			DEBUGDISPLAY2("DLT");
			a = STACKP(2);
			LICPY(*a, Ldlt(STACKP(1),STACKTOP));
			RxStckTop -= 2;
			goto chk4trace;

		case OP_DLE:
			DEBUGDISPLAY2("DLE");
			a = STACKP(2);
			LICPY(*a, Ldle(STACKP(1),STACKTOP));
			RxStckTop -= 2;
			goto chk4trace;

		case OP_TEQ:
			DEBUGDISPLAY2("TEQ");
			a = &(_tmpstr[RxStckTop-1]);
			LICPY(*a, Leq(STACKP(1),STACKTOP));
			RxStckTop--;
			STACKTOP = &_tmpstr[RxStckTop];
			goto chk4trace;

		case OP_TNE:
			DEBUGDISPLAY2("TNE");
			a = &(_tmpstr[RxStckTop-1]);
			LICPY(*a, Lne(STACKP(1),STACKTOP));
			RxStckTop--;
			STACKTOP = &_tmpstr[RxStckTop];
			goto chk4trace;

		case OP_TDEQ:
			DEBUGDISPLAY2("TDEQ");
			a = &(_tmpstr[RxStckTop-1]);
			LICPY(*a, Ldeq(STACKP(1),STACKTOP));
			RxStckTop--;
			STACKTOP = &_tmpstr[RxStckTop];
			goto chk4trace;

		case OP_TDNE:
			DEBUGDISPLAY2("TNDE");
			a = &(_tmpstr[RxStckTop-1]);
			LICPY(*a, Ldne(STACKP(1),STACKTOP));
			RxStckTop--;
			STACKTOP = &_tmpstr[RxStckTop];
			goto chk4trace;

		case OP_TGT:
			DEBUGDISPLAY2("TGT");
			a = &(_tmpstr[RxStckTop-1]);
			LICPY(*a, Lgt(STACKP(1),STACKTOP));
			RxStckTop--;
			STACKTOP = &_tmpstr[RxStckTop];
			goto chk4trace;

		case OP_TGE:
			DEBUGDISPLAY2("TGE");
			a = &(_tmpstr[RxStckTop-1]);
			LICPY(*a, Lge(STACKP(1),STACKTOP));
			RxStckTop--;
			STACKTOP = &_tmpstr[RxStckTop];
			goto chk4trace;

		case OP_TLT:
			DEBUGDISPLAY2("TLT");
			a = &(_tmpstr[RxStckTop-1]);
			LICPY(*a, Llt(STACKP(1),STACKTOP));
			RxStckTop--;
			STACKTOP = &_tmpstr[RxStckTop];
			goto chk4trace;

		case OP_TLE:
			DEBUGDISPLAY2("TLE");
			a = &(_tmpstr[RxStckTop-1]);
			LICPY(*a, Lle(STACKP(1),STACKTOP));
			RxStckTop--;
			STACKTOP = &_tmpstr[RxStckTop];
			goto chk4trace;

		case OP_NOT:
			DEBUGDISPLAY("NOT");
			a = STACKP(1);
			LICPY(*a,!Lbool(STACKTOP));
			RxStckTop--;
			goto chk4trace;

		case OP_AND:
			DEBUGDISPLAY2("AND");
			a = STACKP(2);
			LICPY(*a, Lbool(STACKP(1)) & Lbool(STACKTOP));
			RxStckTop -= 2;
			goto chk4trace;

		case OP_OR:
			DEBUGDISPLAY2("OR");
			a = STACKP(2);
			LICPY(*a, Lbool(STACKP(1)) | Lbool(STACKTOP));
			RxStckTop -= 2;
			goto chk4trace;

		case OP_XOR:
			DEBUGDISPLAY2("XOR");
			a = STACKP(2);
			LICPY(*a, Lbool(STACKP(1)) ^ Lbool(STACKTOP));
			RxStckTop -= 2;
			goto chk4trace;

		case OP_CONCAT:
			DEBUGDISPLAY2("CONCAT");
			a = STACKP(2);
			if (a!=STACKTOP) {
				Lstrcpy(a,STACKP(1));
				Lstrcat(a,STACKTOP);
			} else {
				Lstrcpy(&(_tmpstr[RxStckTop]),STACKTOP);
				Lstrcpy(a,STACKP(1));
				Lstrcat(a,&(_tmpstr[RxStckTop]));
			}
			RxStckTop -= 2;
			goto chk4trace;

		case OP_BCONCAT:
			DEBUGDISPLAY2("BCONCAT");
			a = STACKP(2);
			if (a==STACKTOP) {
				Lstrcpy(&(_tmpstr[RxStckTop]),STACKTOP);
				STACKTOP = &(_tmpstr[RxStckTop]);
			}
			Lstrcpy(a,STACKP(1));
			L2STR(a);
			LSTR(*a)[LLEN(*a)] = ' ';
			LLEN(*a)++;
			Lstrcat(a,STACKTOP);
			RxStckTop -= 2;
			goto chk4trace;

		case OP_NEG:
			DEBUGDISPLAY("NEG");
			Lneg(STACKP(1),STACKTOP);
			RxStckTop--;
			goto chk4trace;

		case OP_INC:
			DEBUGDISPLAY("INC");
			Linc(RxStck[RxStckTop--]);
			goto chk4trace;

		case OP_DEC:
			DEBUGDISPLAY("DEC");
			Ldec(RxStck[RxStckTop--]);
			goto chk4trace;

		case OP_ADD:
			DEBUGDISPLAY2("ADD");
			Ladd(STACKP(2), STACKP(1),STACKTOP);
			RxStckTop -= 2;
			goto chk4trace;

		case OP_SUB:
			DEBUGDISPLAY2("SUB");
			Lsub(STACKP(2), STACKP(1),STACKTOP);
			RxStckTop -= 2;
			goto chk4trace;

		case OP_MUL:
			DEBUGDISPLAY2("MUL");
			Lmult(STACKP(2), STACKP(1),STACKTOP);
			RxStckTop -= 2;
			goto chk4trace;

		case OP_DIV:
			DEBUGDISPLAY2("DIV");
			Ldiv(STACKP(2), STACKP(1),STACKTOP);
			RxStckTop -= 2;
			goto chk4trace;

		case OP_IDIV:
			DEBUGDISPLAY2("IDIV");
			Lintdiv(STACKP(2), STACKP(1),STACKTOP);
			RxStckTop -= 2;
			goto chk4trace;

		case OP_MOD:
			DEBUGDISPLAY2("MOD");
			Lmod(STACKP(2), STACKP(1),STACKTOP);
			RxStckTop -= 2;
			goto chk4trace;

		case OP_POW:
			DEBUGDISPLAY2("POW");
			Lexpose(STACKP(2), STACKP(1),STACKTOP);
			RxStckTop -= 2;
			goto chk4trace;

		default:
			DEBUGDISPLAY0("error, unknown mnemonic");
			Rxcip--;
#ifndef WIN
			fprintf(STDERR,"Opcode found=%ld (0x%02lX)\n",*Rxcip,*Rxcip);
#else
			PUTS("Opcode found=0x"); PUTINT(*Rxcip,0,16);
#endif
			Lerror(ERR_INTERPRETER_FAILURE,0);
	}
chk4trace:
	if (_trace)	TraceInstruction(*Rxcip);
	Rxcip++;	/* skip trace byte */
	}
interpreter_fin:
	SIGNAL(SIGINT,SIG_IGN);
	return rxReturnCode;
} /* RxInterpret */
