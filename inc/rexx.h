/*
 *	Defined symbols in makefile
 *	__DEBUG__	enable debuging
 *	ALIGN		to enable DWORD align instead of byte
 *	INLINE		to inline some functions
 */
#ifndef __REXX_H_
#define __REXX_H_

#include <setjmp.h>

#include "lerror.h"
#include "lstring.h"

#include "dqueue.h"
#include "bintree.h"
#include "variable.h"

#ifdef  __REXX_C__
#define EXTERN
#else
#define EXTERN extern
#endif

#define ALIGN  1
//#define GREEK  1
//#define RMLAST 1
//#define STATIC 0

/* ------------ some defines ------------------ */
#define PACKAGE         "BREXX/370"
#define VERSION         "V2R5M0.DEV"
#define	VERSIONSTR	PACKAGE" "VERSION" ("__DATE__")"
#define	AUTHOR		"Vasilis.Vlachoudis@cern.ch"
#define MAINTAINER  "PeterJ, MikeG"
#define	SCIENTIFIC	0
#define ENGINEERING	1

#define MAXARGS		99  // was 15
#define PROC_INC	10
#define CLAUSE_INC	100
#ifdef JCC
#define CODE_INC	4096
#define CAT_INC		4095
#else
#define CODE_INC	256
#endif
#define STCK_SIZE	255

/* call types */
#define CT_PROGRAM	0
#define CT_PROCEDURE	1
#define CT_FUNCTION	2
#define	CT_INTERPRET	3
#define CT_INTERACTIVE	4

/* signal on condition */
#define SC_ERROR	0x01
#define	SC_HALT		0x02
#define SC_NOVALUE	0x04
#define SC_NOTREADY	0x08
#define SC_SYNTAX	0x10

/* long jmp values */
#define	JMP_CONTINUE	2
#define JMP_ERROR	98
#define JMP_EXIT	99

/* rexx variables */
#define	RCVAR		0
#define	SIGLVAR		1

#ifdef ALIGN
#	define CTYPE	dword
#else
#	define CTYPE	word
#endif

/* ----------------- file structure --------------- */
typedef
struct trxfile {
    Lstr	name;		/* complete file path	    */
    char	*filename;	/* filename in name	        */
    char	*filetype;	/* filetype in name	        */
    char    ddn[9];     /* ddname                   */
    char    dsn[45];    /* dsname                   */
    char    member[9];  /* member name              */
    void	*libHandle;	/* Shared library handle    */
    Lstr	file;		/* actual file		        */
    FILE    *fp;        /* file pointer             */
    struct trxfile *next;/* next in list		    */
} RxFile;

/* ------------- clause structure ----------------- */
typedef
struct tclause {
    size_t	code;		/* code start position	    */
    size_t	line;		/* line number in file	    */
    int	nesting;	    /* nesting level	        */
    char	*ptr;		/* pointer in file	        */
    RxFile	*fptr;		/* RxFile pointer	        */
} Clause;

/* ----------------- ident info ------------------- */
typedef
struct tidentinfo {
    int	id;		        /* the last prg that set leaf value	*/
    int	stem;		    /* if it is a stem			        */
    PBinLeaf leaf[1];	/* Variable array of leafs		    */
                        /* Variable value if stem=0 OR		*/
                        /* pointers to litterals		    */
} IdentInfo;

/* ------------ argument structure ---------------- */
typedef
struct targs {
    int	n;		/* number of args	                */
    PLstr	r;		/* return data		            */
    PLstr	a[MAXARGS];	/* argument pointers	    */
} Args;

/* ------------ internal rexxfunctions ------------ */
typedef
struct tbltfunc {
    char	*name;
    void	(__CDECL *func)(int);
    int	opt;
} TBltFunc;

/* ----------- proc data structure ---------------- */
typedef
struct trxproc {
    int	id;		        /* procedure id		        */
    int	calltype;	    /* call type...		        */
    size_t	ip;		    /* instruction pointer	    */
    size_t	stack;		/* stack position	        */
    size_t	stacktop;	/* stack after args	        */
    Scope	scope;		/* Variables		        */
    Args	arg;		/* stck pos of args	        */
    PLstr	env;		/* environment		        */
    int	digits;		    /* numeric digits	        */
    int	fuzz;		    /* numeric fuzz		        */
    int	form;		    /* numeric form		        */
    int	condition;	    /* signal on condition	    */
    PLstr	lbl_error;	/*	labels		            */
    PLstr	lbl_halt;	/*			                */
    PLstr	lbl_novalue;/*			                */
    PLstr	lbl_notready;/*			                */
    PLstr	lbl_syntax;	/*			                */
    int	codelen;	    /* used in OP_INTERPRET	    */
    int	codelenafter;	/* used in OP_INTERPRET	    */
    int	clauselen;	    /* used in OP_INTERPRET	    */
    int	trace;		    /* trace type		        */
    bool	interactive_trace;
} RxProc;

/* ------------- global variables ----------------- */
#ifdef __DEBUG__
EXTERN int	__debug__;
#endif

EXTERN char	*_prgname;	/* point to argv[0]		*/
EXTERN jmp_buf	_error_trap;	/* error trap for compile	*/
EXTERN jmp_buf	_exit_trap;	/* exit from prg		*/

EXTERN DQueue	rxStackList;	/* dble queue of dble queues	*/

EXTERN RxFile	*rxFileList;	/* rexx file list		*/
EXTERN int	rxReturnCode;	/* Global return code		*/

EXTERN int	_procidcnt;	/* procedure id counter		*/
EXTERN RxProc	*_proc;		/* procedure & function array	*/
EXTERN int	_nesting;	/* cur nesting set by TraceCurline */
EXTERN int	_rx_proc;	/* current procedure id		*/
EXTERN int	_proc_size;	/* number of items in proc list	*/

EXTERN PLstr	_code;		/* code of program		*/
EXTERN BinTree	_labels;	/* Labels			*/

EXTERN Args	rxArg;		/* global arguments for internal routines */

EXTERN BinTree	rxLitterals;	/* Litterals			*/
EXTERN BinLeaf	*nullStr,	/* basic leaf Lstrings		*/
        *zeroStr,
        *oneStr,
        *resultStr,
        *siglStr,
        *RCStr,
        *errorStr,
        *haltStr,
        *syntaxStr,
        *systemStr,
        *mvsStr,
        *tsoStr,
        *linkStr,
        *linkpgmStr,
        *linkmvsStr,
        *ispexecStr,
        *noValueStr,
        *notReadyStr;

/* ============= function prototypes ============== */
#ifdef __cplusplus
extern "C" {
#endif

void	__CDECL RxInitialize( char *program_name );
void	__CDECL RxFinalize( void );
RxFile*	__CDECL RxFileAlloc( char *fname );
void	__CDECL RxFileFree( RxFile *rxf );
void	__CDECL RxFileType( RxFile *rxf );
int        __CDECL RxFileLoad(RxFile *rxf, bool loadLibrary);
int	    __CDECL RxLoadLibrary( PLstr libname, bool shared );
int	    __CDECL RxRun( PLstr filename, PLstr programstr,
        PLstr arguments, PLstr tracestr, int runId);

int	    __CDECL RxRegFunction( char *name, void (__CDECL *func)(int), int opt );

void	__CDECL RxHaltTrap( int );
void	__CDECL RxSignalCondition( int );

int	    __CDECL RxRedirectCmd(PLstr cmd, int in, int out, PLstr resultstr, PLstr env);
int	    __CDECL RxExecuteCmd( PLstr cmd, PLstr env );

#ifdef __cplusplus
}
#endif

#undef EXTERN
#endif
