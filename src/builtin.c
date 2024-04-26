/*
 * $Id: builtin.c,v 1.12 2009/06/02 09:41:27 bnv Exp $
 * $Log: builtin.c,v $
 * Revision 1.12  2009/06/02 09:41:27  bnv
 * MVS/CMS corrections
 *
 * Revision 1.11  2008/07/15 07:40:25  bnv
 * #include changed from <> to ""
 *
 * Revision 1.10  2008/07/14 13:08:42  bnv
 * MVS,CMS support
 *
 * Revision 1.9  2006/01/26 10:24:40  bnv
 * Changed: RxVar...Old() -> RxVar...Name()
 *
 * Revision 1.8  2004/03/27 08:32:37  bnv
 * Corrected: sourceline was reporting wrong lines after an interpret statement
 *
 * Revision 1.7  2003/10/30 13:15:51  bnv
 * Cosmetics
 *
 * Revision 1.6  2003/02/12 16:41:40  bnv
 * *** empty log message ***
 *
 * Revision 1.5  2002/06/11 12:37:38  bnv
 * Added: CDECL
 *
 * Revision 1.4  2002/01/14 10:22:48  bnv
 * Changed: Scan all the dirs in the RXLIB path
 *
 * Revision 1.3  2001/06/25 18:51:48  bnv
 * Header -> Id
 *
 * Revision 1.2  1999/11/26 13:13:47  bnv
 * Added: WIN-32 & Windows CE support
 *
 * Revision 1.1  1998/07/02 17:34:50  bnv
 * Initial revision
 *
 */

#ifndef WCE
#	include <time.h>
#endif
#include <stdlib.h>
#include <string.h>

#ifdef __BORLANDC__
#	include <dos.h>
//#	include <alloc.h>
#else
#	ifndef GCC
	struct timeval_st {
		unsigned long tv_sec;
		long tv_usec;
	};
#	endif
#endif

#include "lerror.h"
#include "lstring.h"

#include "rexx.h"
#include "stack.h"
#include "trace.h"
#include "rxdefs.h"
#include "dqueue.h"
#include "compile.h"
#include "interpre.h"

#ifdef WIN
#	include <winfunc.h>
#endif

/* ------------- External variables ------------ */
extern Lstr     stemvaluenotfound;      /* from variable.c */

/* -------------------------------------------------------------- */
/*  ADDRESS()                                                     */
/* -------------------------------------------------------------- */
/*  DESBUF()                                                      */
/* -------------------------------------------------------------- */
/*  DIGITS()                                                      */
/* -------------------------------------------------------------- */
/*  FORM()                                                        */
/* -------------------------------------------------------------- */
/*  FUZZ()                                                        */
/* -------------------------------------------------------------- */
/*  QUEUED()                                                      */
/* -------------------------------------------------------------- */

/* -- WIN32_WCE ------------------------------------------------- */
/*  LASTERROR()                                                   */
/* -------------------------------------------------------------- */
void __CDECL
R_O( const int func )
{
	long	items;

	if (ARGN)
		Lerror(ERR_INCORRECT_CALL,0);

	switch (func) {
		case f_address:
			if (_proc[_rx_proc].env == NULL)
				Lstrcpy(ARGR,&(systemStr->key));
			else
				Lstrcpy(ARGR,_proc[_rx_proc].env);
			break;

		case f_desbuf:
			items = 0;
			while (1) {
				items += StackQueued();
				if (rxStackList.items>1)
					DeleteStack();
				else {
					DQFlush(DQPEEK(&rxStackList),_Lfree);
					break;
				}
			}
			Licpy(ARGR,items);
			break;

		case f_digits:
			Licpy(ARGR,_proc[_rx_proc].digits);
			break;

		case f_form:
			if (_proc[_rx_proc].form==SCIENTIFIC)
				Lscpy(ARGR,"SCIENTIFIC");
			else
				Lscpy(ARGR,"ENGINEERING");
			break;

		case f_fuzz:
			Licpy(ARGR,_proc[_rx_proc].fuzz);
			break;

		case f_makebuf:
			CreateStack();
			Licpy(ARGR,rxStackList.items);
			break;
#ifdef WIN
		case f_lasterror:
			Licpy(ARGR,GetLastError());
			break;
#endif

		default:
			Lerror(ERR_INTERPRETER_FAILURE,0);
	}
} /* R_O */

/* -------------------------------------------------------------- */
/*  DATE((option))                                                */
/* -------------------------------------------------------------- */
/*  TIME((option))                                                */
/* -------------------------------------------------------------- */
/*  TRACE((option))                                               */
/* -------------------------------------------------------------- */
/*  QUEUED((option))                                              */
/*  Options A=All (default), B=buffers, T=Topmost buffer          */
/* -------------------------------------------------------------- */
void __CDECL
R_C( const int func )
{
	int	i;
	long	items;
	char	option='N';
	DQueueElem	*qe;

	if (ARGN>1)
		Lerror(ERR_INCORRECT_CALL,0);
	if (exist(1)) {
		L2STR(ARG1);
		option = l2u[(byte)LSTR(*ARG1)[0]];
	}

	switch (func) {
		case f_date:
			Ldate(ARGR,option);
			break;

		case f_time:
			Ltime(ARGR,option);
			break;

		case f_trace:
			i = 0;
			if (_proc[_rx_proc].interactive_trace)
				LSTR(*ARGR)[i++] = '?';
			switch (_proc[_rx_proc].trace) {
				case all_trace:		LSTR(*ARGR)[i++] = 'A'; break;
				case commands_trace:	LSTR(*ARGR)[i++] = 'C'; break;
				case error_trace:	LSTR(*ARGR)[i++] = 'E'; break;
				case intermediates_trace:LSTR(*ARGR)[i++]= 'I'; break;
				case labels_trace:	LSTR(*ARGR)[i++] = 'L'; break;
				case normal_trace:	LSTR(*ARGR)[i++] = 'N'; break;
				case off_trace:		LSTR(*ARGR)[i++] = 'O'; break;
				case results_trace:	LSTR(*ARGR)[i++] = 'R'; break;
				case scan_trace:	LSTR(*ARGR)[i++] = 'S'; break;
			}
			LTYPE(*ARGR) = LSTRING_TY;
			LLEN(*ARGR)  = i;
			if (exist(1)) TraceSet(ARG1);
			break;

		case f_queued:
#if defined(__CMS__) || defined(__MVS)  /* dw start */
					Licpy(ARGR,StackQueued());
					break;
#else
			if (exist(1)) {
				if (option=='T') {
					Licpy(ARGR,StackQueued());
					break;
				} else
				if (option=='B') {
					Licpy(ARGR,rxStackList.items);
					break;
				} else
				if (option=='A') /* nothing */;
				else
					Lerror(ERR_INCORRECT_CALL,0);
			}

			/* count all buffers */
			items = 0;
			for (qe=rxStackList.head; qe; qe=qe->next)
				items += ((DQueue*)(qe->dat))->items;
			Licpy(ARGR,items);
			break;
#endif

		default:
			Lerror(ERR_INTERPRETER_FAILURE,0 );
	}  /* switch */
}  /* R_C */

/* -------------------------------------------------------------- */
/*  VARDUMP((symbol)(,'Depth'|'Hex'|'X'))                         */
/*      returns the binary tree in the format                     */
/*      var = "value"  <cr>                                       */
/*      if depth is specified (only the fist char is significant) */
/*      returns the result in the format.                         */
/*      depth var = "value"  <cr>                                 */
/* -------------------------------------------------------------- */
void __CDECL
R_oSoS( )
{
	int		option = FALSE;
	int		found;
	PBinLeaf	leaf;
	Variable	*var;
	Lstr		str;

	if (ARGN>2)
		Lerror(ERR_INCORRECT_CALL,0);

	option = RVT_NOTHING;
	if (ARGN==2) {
		L2STR(ARG2);

		switch (LSTR(*ARG2)[0]) {
			case 'D':
			case 'd':
				option = RVT_DEPTH;
				break;
			case 'H': case 'X':
			case 'h': case 'x':
				option = RVT_HEX;
				break;
		}
	}

	LZEROSTR(*ARGR);
	if (ARG1==NULL)
		RxReadVarTree(ARGR,_proc[_rx_proc].scope,NULL,option);
	else {
		if (Ldatatype(ARG1,'S')==0) return;
		LINITSTR(str);
		Lstrcpy(&str,ARG1);
		Lupper(&str); LASCIIZ(str);
#ifdef JCC
		leaf = (PBinLeaf) RxVarFindName(_proc[_rx_proc].scope,&str,&found);
#else
		leaf = RxVarFindName(_proc[_rx_proc].scope,&str,&found);
#endif
		if (found == 0) return;
		var = (Variable*)(leaf->value);
		if (var->stem == NULL)
			RxVar2Str(ARGR,leaf,option);
		else
			RxReadVarTree(ARGR,var->stem,&(leaf->key),option);
		LFREESTR(str);
	}
} /* R_oSoS */

/* -------------------------------------------------------------- */
/*  ADDR(symbol[,[option][,[pool]]])                              */
/*  Returns the normalised address of the variable 'symbol'       */
/*  in the pool 'pool' (if exist)                                 */
/*  Option can be:                                                */
/*	'Data'	(default) the address of variables data           */
/*	'Lstring'	the lstring structure                     */
/*	'Variable'	the address of variable structure         */
/*  (valid only for rexx pools)                                   */
/* -------------------------------------------------------------- */
/*  VALUE(name[,[newvalue][,[pool]]])                             */
/*  Return the value of variable 'name'                           */
/*  if 'newvalue' exists then it sets this value to the var 'name */
/*  if 'pool' exist then the function is performed on this        */
/*  external pool                                                 */
/* -------------------------------------------------------------- */
void __CDECL
R_SoSoS( int func )
{
	char	response;

	if (!IN_RANGE(1,ARGN,3)) Lerror(ERR_INCORRECT_CALL,0);
	get_s(1);
	if (func == f_addr) {		/* ADDR(...) */
		int		found,poolnum;
		char	opt='D';
		PBinLeaf leaf;
		Lstr	str;
		void	*ptr=NULL;
		long	addr;

		/* translate to uppercase */
		LINITSTR(str); Lfx(&str,LLEN(*ARG1));
		Lstrcpy(&str,ARG1);
		Lupper(&str); LASCIIZ(str);

		if (exist(2)) {
			L2STR(ARG2);
			opt =  l2u[(byte)LSTR(*ARG2)[0]];
		}

		if (exist(3)) {
			poolnum = (int)Lrdint(ARG3);
			if (poolnum<0 || poolnum > _rx_proc)
				Lerror(ERR_INCORRECT_CALL,37,ARG3);
		} else
			poolnum = _rx_proc;

#ifdef JCC
		leaf = (PBinLeaf) RxVarFindName(_proc[poolnum].scope,&str,&found);
#else
		leaf = RxVarFindName(_proc[poolnum].scope,&str,&found);
#endif
		LFREESTR(str);
		if (!found) {
			Licpy(ARGR,-1);
			return;
		}
		switch (opt) {
			case 'D':
				ptr = LSTR( *(LEAFVAL(leaf)) );
				break;
			case 'L':
				ptr = LEAFVAL(leaf);
				break;
			case 'V':
				ptr = &(leaf->value);
				break;
			default:
				Lerror(ERR_INCORRECT_CALL,0);
		}
#if defined(__BORLANDC__) && !defined(__WIN32__) && !defined(WCE)
		addr = (((long)FP_SEG(ptr))<<4) + (long)FP_OFF(ptr);
#else
		addr = (dword)ptr;
#endif
		Licpy(ARGR,addr);
	} else
	if (func == f_value) {
		if (exist(3)) {		/* An external pool? */
			/* let external pool to handle the value */
			L2STR(ARG3);
			LZEROSTR(*ARGR);
			response = RxPoolGet(ARG3,ARG1,ARGR);
			if (response == 'F' && !exist(2))
				Lerror(ERR_INCORRECT_CALL,36,ARG1);
			else
			if (response == 'P')
				Lerror(ERR_INCORRECT_CALL,37,ARG3);

			if (!exist(2)) return;
			/* Set the new value */
			response = RxPoolSet(ARG3,ARG1,ARG2);
			if (response == 'P')
				Lerror(ERR_INCORRECT_CALL,37,ARG3);
			else
			if (response == 'F')
				Lerror(ERR_INCORRECT_CALL,36,ARG1);
		} else {
			Lstr	str;

			LINITSTR(str); Lfx(&str,sizeof(dword));
			Licpy(&str,_rx_proc);
			response = RxPoolGet(&str,ARG1,ARGR);
			if (exist(2))
				response = RxPoolSet(&str,ARG1,ARG2);
			LFREESTR(str);
		}
	}
} /* SoSoS */

/* -------------------------------------------------------------- */
/*  ARG([n[,option]])                                             */
/* -------------------------------------------------------------- */
void __CDECL
R_arg( )
{
	int	a;

	RxProc	*pr = &(_proc[_rx_proc]);

	switch (ARGN) {
		case  0:
			Licpy(ARGR,pr->arg.n);
			break;

		case  1:
			a = (int)Lrdint(ARG1);
			if (!IN_RANGE(1,a,MAXARGS))
				Lerror(ERR_INCORRECT_CALL,0);
			if (pr->arg.a[a-1] != NULL)
				Lstrcpy(ARGR,
					pr->arg.a[a-1]);
			else
				LZEROSTR(*ARGR);
			break;

		case  2:
			a = (int)Lrdint(ARG1);
			if (!IN_RANGE(1,a,MAXARGS))
				Lerror(ERR_INCORRECT_CALL,0);
			L2STR(ARG2);

			if (l2u[(byte)LSTR(*ARG2)[0]] == 'E')
				Licpy(ARGR,
					pr->arg.a[a-1] != NULL);
			else
			if (l2u[(byte)LSTR(*ARG2)[0]] == 'O')
				Licpy(ARGR,
					pr->arg.a[a-1] == NULL);
			else
				Lerror(ERR_INCORRECT_CALL,0);
			break;

		default:
			Lerror(ERR_INCORRECT_CALL,0);
	}
} /* R_arg */

/* -------------------------------------------------------------- */
/* DATATYPE(string(,type))                                        */
/* -------------------------------------------------------------- */
void __CDECL
R_datatype( )
{
	char	type=' ';

	if (!IN_RANGE(1,ARGN,2))
		Lerror(ERR_INCORRECT_CALL,0);
	must_exist(1);
	if (exist(2)) {
		L2STR(ARG2);
		if (!LLEN(*ARG2))
			Lerror(ERR_INCORRECT_CALL,0);
		type = l2u[(byte)LSTR(*ARG2)[0]];
	}  else {
		Lscpy( ARGR,
			((LTYPE(*ARG1)==LSTRING_TY &&
			_Lisnum(ARG1)==LSTRING_TY)? "CHAR": "NUM")
		);
		return;
	}

	if (type=='T') {   /* mine special type */
		switch (LTYPE(*ARG1)) {
			case LINTEGER_TY:Lscpy(ARGR,"INTEGER");	break;
			case LREAL_TY:	 Lscpy(ARGR,"REAL");	break;
			case LSTRING_TY: Lscpy(ARGR,"STRING");	break;
			default:
				Lerror(ERR_INTERPRETER_FAILURE,0);
		}
		return;
	}
	Licpy(ARGR,Ldatatype(ARG1,type));
} /* R_datatype */

/* -------------------------------------------------------------- */
/*  DROPBUF((num))                                                */
/* -------------------------------------------------------------- */
void __CDECL
R_dropbuf( )
{
	long	n=1;
	long	items=0;

	if (ARGN>1)
		Lerror(ERR_INCORRECT_CALL,0);
	get_oiv(1,n,1)

	if (n==0)
		Licpy(ARGR,StackQueued());
	else {
		for (;n>0;n--) {
			items += StackQueued();
			if (rxStackList.items>1)
				DeleteStack();
			else {
				DQFlush(DQPEEK(&rxStackList),_Lfree);
				break;
			}
		}
		Licpy(ARGR,items);
	}
} /* R_dropbuf */

/* -------------------------------------------------------------- */
/*  ERRORTEXT(n)                                                  */
/* -------------------------------------------------------------- */
void __CDECL
R_errortext( )
{
	if (ARGN!=1) Lerror(ERR_INCORRECT_CALL,0);
	must_exist(1);
	Lerrortext(ARGR,(int)Lrdint(ARG1),0,NULL);
} /* R_errortext */

/* -------------------------------------------------------------- */
/*  INTR( num, reg-string )                                       */
/*      executes a 80x86 soft-interrupt.                          */
/*      num = interrupt number, and reg-string is a string        */
/*      in the format "ax=hex-num bx=hex-num ...."                */
/*      returns in the same format the registers and flags        */
/* -------------------------------------------------------------- */
#if defined(__BORLANDC__) && !defined(__WIN32__) && !defined(WCE)
void __CDECL
R_intr( )
{
	static char  *s_reg[] = {
			"AX=","BX=","CX=","DX=",
			"BP=","SI=","DI=",
			"DS=","ES=","FLAGS=" };
	static char  flags_str[]="C-P-A-ZSTIDO";
	Lstr	str;
	int	i,intno;
	union  {
		struct	REGPACK regpack;
		unsigned regarray[10];
	} reg;
	char	*s;

	if (ARGN != 2)
		Lerror(ERR_INCORRECT_CALL,0);

	must_exist(1);
	intno = (int)Lrdint(ARG1);
	if (!IN_RANGE(0,intno,0xFF))
		Lerror(ERR_INCORRECT_CALL,0);

	must_exist(2);
	L2STR(ARG2);

	LINITSTR(str);
	Lspace(&str,ARG2,1,' ');
	Lupper(&str);
	LASCIIZ(str);
	MEMSET(&(reg.regpack),0,sizeof(reg.regpack));
	for (i=0; i<10; i++) {
		s=strstr(LSTR(str),s_reg[i]);
		if (s!=NULL) {
			s+=3;
			sscanf(s,"%X",&reg.regarray[i]);
		}
	}

	intr(intno,&reg.regpack);
	Lfx(ARGR,100);
		LTYPE(*ARGR) = LSTRING_TY;
		s=LSTR(*ARGR); *s='\0';
	for (i=0; i<9; i++) {
		sprintf(s,"%s%04X ",s_reg[i],reg.regarray[i]);
		s += STRLEN(s);
	}
	STRCAT(s,s_reg[9]); s += STRLEN(s);
	for (i=0; i<12; i++, reg.regpack.r_flags >>= 1)
		if (reg.regpack.r_flags & 0x1)
			*s++ = flags_str[i];
	*s = '\0';

	LLEN(*ARGR) = STRLEN(LSTR(*ARGR))-1;
	LFREESTR(str);
} /* R_int */

/* -------------------------------------------------------------- */
/*  PORT(port(,value))                                            */
/*      if value is not specified then reads one byte from port   */
/*      and returns it in integer format (IN)                     */
/*      if value exists then OUTs that value to the port.         */
/* -------------------------------------------------------------- */
void __CDECL
R_port( )
{
	long port;
	int  value;

	if (!IN_RANGE(1,ARGN,2))
		Lerror(ERR_INCORRECT_CALL,0);
	get_i(1,port);
	if (exist(2)) {
		value = (int)Lrdint(ARG2);
		outp((int)port,value);
	} else {
		value = inp((int)port);
		Licpy(ARGR, value);
	}
} /* R_port */
#endif

/* -------------------------------------------------------------- */
/*   MAX(number[,number]..])                                      */
/* -------------------------------------------------------------- */
void __CDECL
R_max( )
{
	int	i, curindx;
	double	r, nr;

	if (!ARGN)
		Lerror(ERR_INCORRECT_CALL,0);
    i = 0;
    while ((i<ARGN) && (rxArg.a[i]==NULL)) i++;
    if (i==MAXARGS) Lerror(ERR_INCORRECT_CALL,0);

    Lstrcpy(ARGR,rxArg.a[i]);
    L2REAL(ARGR);
    r = LREAL(*ARGR);

    curindx=0;
    for (i++; i<ARGN; i++)
        if (rxArg.a[i] != NULL)  {
            Lstrcpy(ARGR,rxArg.a[i]);
            L2REAL(ARGR);
            nr = LREAL(*ARGR);
            if (nr>r) {
                r=nr;
                curindx=i;
            }
        }
    if (Ldatatype(rxArg.a[curindx],'W')==1) {
        L2INT(rxArg.a[curindx]);
        Licpy(ARGR,LINT(*rxArg.a[curindx]));
    }else {
        Lrcpy(ARGR, r);
    }
} /* R_max */

/* -------------------------------------------------------------- */
/*   MIN(number[,number]..])                                      */
/* -------------------------------------------------------------- */
void __CDECL
R_min( )
{
	int	i, curindx;
	double	r, nr;

	if (!ARGN)
		Lerror(ERR_INCORRECT_CALL,0);

	i = 0;
	while ((i<ARGN) && (rxArg.a[i]==NULL)) i++;
	if (i==MAXARGS) Lerror(ERR_INCORRECT_CALL,0);

    Lstrcpy(ARGR,rxArg.a[i]);
    L2REAL(ARGR);
    r = LREAL(*ARGR);
	curindx=0;
	for (i++; i<ARGN; i++)
		if (rxArg.a[i] != NULL)  {
            Lstrcpy(ARGR,rxArg.a[i]);
            L2REAL(ARGR);
            nr = LREAL(*ARGR);
            if (nr<r) {
               r=nr;
               curindx=i;
            }
		}
    if (Ldatatype(rxArg.a[curindx],'W')==1) {
        L2INT(rxArg.a[curindx]);
        Licpy(ARGR,LINT(*rxArg.a[curindx]));
    }else {
        Lrcpy(ARGR, r);
    }
} /* R_min */

/* -------------------------------------------------------------- */
/* RANDOM((min)(,(max)(,seed)))                                   */
/* -------------------------------------------------------------- */
void __CDECL
R_random( )
{
	long	min, max;
	static	long seed;
	static	int  sewed=0 ;

	if (!IN_RANGE(0,ARGN,3)) Lerror(ERR_INCORRECT_CALL,0);

	if (exist(1)) {
		min = Lrdint(ARG1);
		if (min<0) Lerror(ERR_INCORRECT_CALL,0);
	} else
		min = 0;

	if (exist(2)) {
		max = Lrdint(ARG2);
		if (max<0) Lerror(ERR_INCORRECT_CALL,0);
	} else
		max = 999;

	if (min>max) Lerror(ERR_INCORRECT_CALL,0);

	if (exist(3)) {
		seed = Lrdint(ARG3);
		if (seed<0) Lerror(ERR_INCORRECT_CALL,0);
		srand((unsigned)seed);
		sewed = 1;
	} else
	if (sewed==0) {
		sewed = 1 ;
#ifndef WCE
		seed=(time((time_t *)0)%(3600*24));
#else
		seed = GetTickCount();
#endif
		srand((unsigned)seed);
	}

	Licpy(ARGR, (long)rand() % (max-min+1) + min);
} /* R_random */

/* -------------------------------------------------------------- */
/*  STORAGE((address(,(length)(,data))))                          */
/*      returns the current virtual machine size expressed as a   */
/*      DECIMAL string if no arguments are specified.             */
/*      Otherwise, returns length bytes from the user's memory    */
/*      starting at address.  The length is in decimal;           */
/*      the default is 1 byte.  The address is a DECIMAL number.  */
/*      If data is specified, after the "old" value has been      */
/*      retrieved, storage starting at address is overwritten     */
/*      with data (the length argument has no effect on this).    */
/* -------------------------------------------------------------- */
void __CDECL
R_storage( )
{
	void	*ptr=NULL;
	long	adr;

	size_t	length = 1;

	if (ARGN>3)
		Lerror(ERR_INCORRECT_CALL,0);
	if (ARGN==0) {

#if __CMS__
		CMSSTORE(ARGR);
#else
		Licpy(ARGR,0);
#endif
		return;
	}
	if (exist(1)) {      /* Argument is decimal and not hex */
		Lx2d(ARGR,ARG1,0);    /* using ARGR as temp field for conversion */
		adr = Lrdint(ARGR);
		if (adr < 0)
			Lerror(ERR_INCORRECT_CALL,0);

		ptr = (void *)adr;
	} else
		Lerror(ERR_INCORRECT_CALL,0);

	if (exist(2)) {
		adr = Lrdint(ARG2);
		if (adr <= 0)
			Lerror(ERR_INCORRECT_CALL,0);
		length = (size_t)adr;
	}

	Lfx(ARGR,length);
		LTYPE(*ARGR) = LSTRING_TY;
		LLEN(*ARGR) = length;
		MEMCPY(LSTR(*ARGR),ptr,length);

	if (exist(3)) {
		L2STR(ARG3);	/*// !!!! Always is converted to string !!!! */
		MEMCPY(ptr, LSTR(*ARG3), LLEN(*ARG3));
	}
} /* R_storage */

/* -------------------------------------------------------------- */
/*  SOURCELINE([n])                                               */
/*      return the number of lines in the program, or the nth     */
/*      line.                                                     */
/* -------------------------------------------------------------- */
void __CDECL
R_sourceline( )
{
	long	l,sl;
	int	i;
	char	*c,*co;
	RxFile	*rxf;

	if (ARGN>1)
		Lerror(ERR_INCORRECT_CALL,0);

	get_oi(1,l);
	if (l==0) {	/* count the lines of the program */
		i = 0;
		rxf = CompileClause[0].fptr;
		while (rxf==CompileClause[i].fptr
				&& CompileClause[i+1].line>=CompileClause[i].line) {
			i++;
			l = CompileClause[i].line;
		}
		i--;
		l = CompileClause[i].line;
		c = CompileClause[i].ptr;
		while (*c)
			if (*c++=='\n') l++;
		l-=2;		/* remove the last two new lines */
		Licpy(ARGR,l);
	} else {
		if (l>1) {
			rxf = CompileClause[0].fptr;
			for (i=0; rxf==CompileClause[i].fptr
					&& CompileClause[i+1].line>=CompileClause[i].line; i++) {
				if (CompileClause[i].line==l) {
					c = CompileClause[i].ptr;
					while (*c!='\n')
						c--;
					c++;
					goto linefound;
				} else
				if (CompileClause[i].line>l) {
					if (i>0) {
						i--;
						c = CompileClause[i].ptr;
						sl = CompileClause[i].line;
					} else {
						c = LSTR(rxf->file);
						sl = 1;
					}
					while (sl<l) {
						/* skip until eol */
						while (*c!='\n') c++;
						sl++; c++;
					}
					goto linefound;
				}
			}
			/* try to search inside a commend, if exists any
				at the end of the program */
			i--;
			sl=CompileClause[i].line; c = CompileClause[i].ptr;
			while (*c && l>sl) {
				if (*c=='\n') sl++;
				c++;
			}
			if (*c) goto linefound;
			LZEROSTR(*ARGR);
			return;
		} else
			c = LSTR((CompileClause[0].fptr)->file);
linefound:
		for (co=c; *co!='\n'; co++) /* do nothing */;;
		l = (char huge *)co - (char huge *)c;
		Lfx(ARGR,(size_t)l);
		LTYPE(*ARGR) = LSTRING_TY;
		LLEN(*ARGR) = (size_t)l;
		MEMCPY(LSTR(*ARGR),c,(size_t)l);
	}
} /* R_sourceline */

#ifdef __CMS__
void __CDECL
VM_O(int func)
{
	switch (func){
		case f_cmsflag:
			if (ARGN!=1) Lerror(ERR_INCORRECT_CALL,0);
			L2STR(ARG1);
			CMSFLAG(ARGR,ARG1);
			break;
		case f_cmsline:
			CMSLINE(ARGR);
			break;
		case f_cmsuser:
			CMSUSER(ARGR);
			break;
		default:
			fprintf(stderr, "unknown function %d in VM_O" , func);
	}
} /* VM_O */
#endif

