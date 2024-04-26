/*
 * $Id: compile.h,v 1.6 2008/07/15 07:40:07 bnv Exp $
 * $Log: compile.h,v $
 * Revision 1.6  2008/07/15 07:40:07  bnv
 * MVS, CMS support
 *
 * Revision 1.5  2004/08/16 15:30:30  bnv
 * Changed: name of mnemonic operands from xxx_mn to O_XXX
 *
 * Revision 1.4  2002/06/11 12:37:56  bnv
 * Added: CDECL
 *
 * Revision 1.3  2001/06/25 18:52:04  bnv
 * Header -> Id
 *
 * Revision 1.2  1999/11/29 14:58:00  bnv
 * Changed: Some defines
 *
 * Revision 1.1  1998/07/02 17:35:50  bnv
 * Initial revision
 *
 */

#ifndef __COMPILE_H__
#define __COMPILE_H__

#ifndef WIN
#	include "bmem.h"
#endif
#include "lstring.h"
#include "bintree.h"
#include "nextsymb.h"

#ifdef __COMPILE_C__
#	define EXTERN
#else
#	define EXTERN extern
#endif

/* ----------- local defines --------------- */
#define UNKNOWN_LABEL		0xFFFF
#define CMP(a)			Lcmp(&symbolstr,a)
#define identCMP(a)		((symbol==ident_sy) && !CMP(a))
#define MUSTBE_SEMICOLON	_mustbe(semicolon_sy, ERR_EXTRAD_DATA,1)
#define SKIP_SEMICOLONS		while (symbol==semicolon_sy) nextsymbol()

#define SYMBOLADD2LITS		_Add2Lits(&symbolstr,symbolhasdot)
#define	SYMBOLADD2LITS_KEY	&(((PBinLeaf)SYMBOLADD2LITS)->key)

/* ----------- Function structure ----------- */
enum functypes {
	FT_LABEL,
	FT_FUNCTION,
	FT_BUILTIN,
	FT_INTERNAL,
	FT_EXTERNAL,
	FT_SYSTEM
};

typedef struct tfunction {
	int	type;			/* function type	*/
	TBltFunc *builtin;		/* builtin function	*/
	size_t	label;			/* offset in code	*/
} RxFunc;

/* ------------ Global Variables ------------ */
/* --- Compile Variables --- */
EXTERN RxFile	*CompileRxFile;		/* Rexx file pointer	*/
EXTERN byte	*CompileCodePtr;	/* code pointer		*/
EXTERN PLstr	CompileCode;		/* code space		*/
#ifndef ALIGN
EXTERN word	CompileCodeLen;		/* code length		*/
#else
EXTERN dword	CompileCodeLen;		/* code length		*/
#endif

EXTERN Clause	*CompileClause;		/* compile clauses	*/
EXTERN int	CompileCurClause;	/* current clause	*/
EXTERN int	CompileClauseItems;	/* maximum clause len	*/

EXTERN int	CompileNesting;		/* current nesting	*/

/* --------------- rexx options ----------------- */
enum options_type {
	 environment_opt	/* address envirnoment	*/
	,trace_opt		/* trace option		*/
	,digits_opt		/* numeric digits	*/
	,fuzz_opt		/* fuzz digits		*/
	,form_opt		/* numeric form		*/
	,author_opt		/* author string	*/
	,version_opt		/* version string	*/
	,os_opt			/* OS string		*/
	,calltype_opt		/* call type string	*/
	,filename_opt		/* rexx prg file name	*/
	,prgname_opt		/* program file name	*/
	,shell_opt		/* current shell	*/
	,set_signal_opt		/* signal condition	*/
	,set_signal_name_opt	/* signal name cond	*/
	,unset_signal_opt	/* signal condition	*/
};

enum expr_type {
	 exp_assign		/* expr for assingment	*/
	,exp_tmp		/* expr copied to tmp	*/
	,exp_normal		/* do not do anything	*/
};

/* ---------------- mnemonic codes --------------- */
enum mnemonic_type {
	 OP_NEWCLAUSE	/* new command used for trace	*/
	,OP_NOP		/* Nothing dummy instruction	*/
	,OP_PUSH	/* push lstring			*/
	,OP_PUSHTMP	/* push a temporary lstring	*/
	,OP_POP		/* pop lstring			*/
	,OP_DUP		/* DUP [relative] duplicates something from stack	*/
	,OP_COPY	/* COPY to previous (Lstrcpy)*/
	,OP_COPY2TMP	/* COPY a value to temporary	*/
	,OP_PATCH	/* PATCH [relative] [byte] in code	*/
	,OP_RAISE	/* raise a condition error	*/

	,OP_LOADARG	/* load argument	*/
	,OP_LOADOPT	/* load internal data	*/
	,OP_STOREOPT	/* save internal data	*/
	,OP_LOAD	/* load a variable	*/
	,OP_CREATE	/* create/load a var	*/
	,OP_DROP	/* drop a variable	*/
	,OP_DROPIND	/* drop a var indirect	*/
	,OP_ASSIGNSTEM	/* assign array		*/

	,OP_BYINIT	/* DO .. BY .. init	*/
	,OP_FORINIT	/* DO FOR initialise	*/
	,OP_DECFOR	/* DEC of a DO FOR loop	*/

	,OP_TOINT	/* transform mnemonics	*/
	,OP_LOWER	/* to lowercase	a lit	*/
	,OP_UPPER	/* to uppercase	a lit	*/

	,OP_SIGNAL	/* Clear up stack and jmp rel	*/
	,OP_SIGNALVAL	/* evaluate and jump	*/

	,OP_JMP		/* Unconditional jump	*/
	,OP_JF		/* Jump if false (0)	*/
	,OP_JT		/* Jump if true (1)	*/
	,OP_CALL	/* Call a procedure	*/
	,OP_RETURN	/* return from a proc	*/
	,OP_RETURNF	/* return from a func	*/

	,OP_INTERPRET	/* interpret a string	*/
	,OP_INTER_END	/* end of interpret	*/

	,OP_PROC	/* start procedure	*/

	,OP_SAY		/* print on stdout	*/
	,OP_SYSTEM	/* execute a system command	*/
	,OP_EXIT	/* normal terminate prg	*/

	,OP_PARSE	/* load a template to parse	*/
	,OP_PVAR	/* parse into a variable	*/
	,OP_PDOT	/* parse to a dot	*/
	,OP_TR_SPACE	/* trigger a space	*/
	,OP_TR_LIT	/* trigger a litteral	*/
	,OP_TR_ABS	/* trigger absolute pos	*/
	,OP_TR_REL	/* trigger relative pos	*/
	,OP_TR_END	/* trigger to end	*/

	,OP_RX_QUEUE
	,OP_RX_PUSH
	,OP_RX_PULL
	,OP_RX_EXTERNAL

	,OP_EQ		/* checking mnemonics	*/
	,OP_NE
	,OP_GT
	,OP_GE
	,OP_LT
	,OP_LE
	,OP_DEQ
	,OP_DNE
	,OP_DGT
	,OP_DGE
	,OP_DLT
	,OP_DLE

	,OP_TEQ		/* return to tmp */
	,OP_TNE
	,OP_TDEQ
	,OP_TDNE
	,OP_TGT
	,OP_TGE
	,OP_TLT
	,OP_TLE

	,OP_NOT
	,OP_AND
	,OP_OR
	,OP_XOR

	,OP_CONCAT	/* concat two string	*/
	,OP_BCONCAT	/* concat two strings with space	*/

	,OP_NEG
	,OP_INC
	,OP_DEC

	,OP_ADD
	,OP_SUB
	,OP_MUL
	,OP_DIV
	,OP_IDIV
	,OP_MOD
	,OP_POW

};

/* ------- function prototypes ----- */
void	__CDECL RxInitCompile( RxFile *rxf, PLstr src );
void	__CDECL RxDoneCompile( void );
int	__CDECL RxCompile( void );

#ifndef ALIGN
	word	_CodeInsByte( word pos, byte b );
	word	_CodeAddByte( byte b );
	word	_CodeAddWord( word w );
	word	_CodeAddPtr( void *ptr );
#else
#	define	_CodeAddByte(b)	_CodeAddDWord((dword)(b))
#	define	_CodeAddWord(w)	_CodeAddDWord((dword)(w))
	dword	_CodeInsByte( dword pos, dword d );
	dword	_CodeAddDWord( dword d);
	dword	_CodeAddPtr( void *ptr );
#endif
void		*_Add2Lits( PLstr lit, int hasdot );
void	__CDECL _mustbe( enum symboltype sym, int err, int subno);
PBinLeaf	_AddLabel( int type, size_t position );

#undef EXTERN
#endif
