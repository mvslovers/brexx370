/*
 * $Id: rexxfunc.c,v 1.12 2013/09/03 20:03:26 bnv Exp $
 * $Log: rexxfunc.c,v $
 * Revision 1.12  2013/09/03 20:03:26  bnv
 * Add setenv for windows ce
 *
 * Revision 1.11  2010/01/27 13:20:27  bnv
 * CMS and MVS corrections
 *
 * Revision 1.10  2008/07/15 07:40:25  bnv
 * #include changed from <> to ""
 *
 * Revision 1.9  2008/07/14 13:08:42  bnv
 * MVS,CMS support
 *
 * Revision 1.8  2004/08/16 15:28:54  bnv
 * Added new WCE functions
 *
 * Revision 1.7  2003/10/30 13:16:28  bnv
 * Variable name change
 *
 * Revision 1.6  2003/01/30 08:22:37  bnv
 * HASHVALUE added
 *
 * Revision 1.5  2002/06/11 12:37:38  bnv
 * Added: CDECL
 *
 * Revision 1.4  2001/09/28 10:08:03  bnv
 * Added new integer bitwise functions AND,OR,NOT,XOR
 *
 * Revision 1.3  2001/06/25 18:51:48  bnv
 * Header -> Id
 *
 * Revision 1.2  1999/11/26 13:13:47  bnv
 * Added: Windows CE routines.
 *
 * Revision 1.1  1998/07/02 17:34:50  bnv
 * Initial revision
 *
 */

#include <math.h>

#include "lerror.h"
#include "lstring.h"

#include "rexx.h"
#include "rxdefs.h"
#include "compile.h"

#define DECL( A )  void __CDECL R_##A ( const int );

#ifdef __CMS__
#define VMDCL( A )  void __CDECL VM_##A ( const int );

VMDCL( O )

#endif

DECL( SSoI     )   DECL( SIoC  )  DECL( S   )   DECL( SIoI )
DECL( SSoIoIoC )   DECL( SoSoC )  DECL( SoI )   DECL( IoI  )
DECL( O        )   DECL( SI    )  DECL( C   )   DECL( oSoS )
DECL( SS       )   DECL( SoSoS )

DECL( arg       )  DECL( compare   )  DECL( copies    )  DECL( close     )
DECL( datatype  )  DECL( eof       )  DECL( errortext )
DECL( filesize  )  DECL( filter )     DECL( format    )  DECL( intr      )
DECL( max       )  DECL( min       )  DECL( open      )  DECL( random    )
DECL( read      )  DECL( seek      )  DECL( substr    )  DECL( sourceline)
DECL( strip     )  DECL( storage   )  DECL( space     )  DECL( translate )
DECL( trunc     )  DECL( verify    )  DECL( write     )  DECL( xrange    )
DECL( d2p       )
DECL( p2d       )
DECL( dropbuf   )
DECL( changestr )
DECL( flush     )
DECL( port      )

DECL( charslines )
DECL( charlinein )
DECL( charlineout )
DECL( stream )

/* Math routines */
DECL( ceil  )
DECL( floor )
DECL( round )
DECL( abs_sign  )
DECL( math )
DECL( atanpow )
DECL( bitwise )
DECL( not )
#undef DECL

/* ------------- Register Functions Tree ----------- */
static BinTree	*ExtraFuncs = NULL;
/* !!!!!!!!!!!! WARNING THE LIST MUST BE SORTED !!!!!!!!!!! */
/* !!!!!! EBCDIC SORT ORDER IS NOT THE SAME AS ASCII */
static
TBltFunc
rexx_routine[] = {
#ifdef WCE
	{ "A2U",	R_S		,f_a2u		},
#endif
	{ "ABBREV",	R_SSoI		,f_abbrev	},
	{ "ABS",	R_abs_sign	,f_abs		},
	{ "ACOS",	R_math		,f_acos		},
	{ "ADDR",	R_SoSoS		,f_addr		},
	{ "ADDRESS",	R_O		,f_address	},
	{ "ARG",	R_arg		,f_arg		},
	{ "ASIN",	R_math		,f_asin		},
	{ "ATAN",	R_math		,f_atan		},
	{ "ATAN2",	R_atanpow	,f_atan2	},
#if !defined(__CMS__) && !defined(__MVS__)
	{ "B2X",	R_S		,f_b2x		},
#endif
	{ "BITAND",	R_SoSoC		,f_bitand	},
	{ "BITOR",	R_SoSoC		,f_bitor	},
	{ "BITXOR",	R_SoSoC		,f_bitxor	},
#if defined(__CMS__) || defined(__MVS__)
	{ "B2X",	R_S		,f_b2x		},
#else
	{ "C2D",	R_SoI		,f_c2d		},
	{ "C2X",	R_S		,f_c2x		},
#endif
    { "CEIL",	R_ceil  	,f_ceil	},
	{ "CENTER",	R_SIoC		,f_center	},
	{ "CENTRE",	R_SIoC		,f_center	},
	{ "CHANGESTR",	R_changestr	,f_changestr	},
	{ "CHARIN",	R_charlinein	,f_charin	},
	{ "CHAROUT",	R_charlineout	,f_charout	},
	{ "CHARS",	R_charslines	,f_chars	},
	{ "CLOSE",	R_close		,f_close	},
#if defined(__CMS__)
	{ "CMSFLAG",	VM_O		,f_cmsflag	},
#endif
	{ "COMPARE",	R_compare	,f_compare	},
	{ "COPIES",	R_copies	,f_copies	},
	{ "COS",	R_math		,f_cos		},
	{ "COSH",	R_math		,f_cosh		},
	{ "COUNTSTR",	R_SS		,f_countstr	},
#if defined(__CMS__) || defined(__MVS__)
	{ "C2D",	R_SoI		,f_c2d		},
	{ "C2X",	R_S		,f_c2x		},
#else
	{ "D2C",	R_IoI		,f_d2c		},
	{ "D2X",	R_IoI		,f_d2x		},
#endif
	{ "DATATYPE",	R_datatype	,f_datatype	},
	{ "DATE",	R_C		,f_date		},
	{ "DELSTR",	R_SIoI		,f_delstr	},
	{ "DELWORD",	R_SIoI		,f_delword	},
	{ "DESBUF",	R_O		,f_desbuf	},
	{ "DIGITS",	R_O		,f_digits	},
	{ "DROPBUF",	R_dropbuf	,f_dropbuf	},
#if defined(__CMS__) || defined(__MVS__)
	{ "D2C",	R_IoI		,f_d2c		},
    { "D2P",	R_d2p		,f_d2p	},
	{ "D2X",	R_IoI		,f_d2x		},
#endif
	{ "EOF",	R_eof		,f_eof		},
	{ "ERRORTEXT",	R_errortext	,f_errortext	},
	{ "EXP",	R_math		,f_exp		},
    { "FILTER",	R_filter	,f_filter	},
	{ "FIND",	R_SSoI		,f_find		},
    { "FLOOR",	R_floor  	,f_floor	},

    { "FLUSH",	R_flush		,f_flush	},
	{ "FORM",	R_O		,f_form		},
	{ "FORMAT",	R_format	,f_format	},
	{ "FUZZ",	R_O		,f_fuzz		},
#if !defined(__MVS__) && !defined(WCE)
	{ "GETENV",	R_S		,f_getenv	},
#endif
	{ "HASHVALUE",	R_S		,f_hashvalue	},
	{ "IAND",	R_bitwise	,f_and		},
	{ "IMPORT",	R_S		,f_import	},
	{ "INDEX",	R_SSoI		,f_index	},
	{ "INOT",	R_not		,0		},
	{ "INSERT",	R_SSoIoIoC	,f_insert	},
#if defined(__BORLANDC__) && !defined(__WIN32__) && !defined(WCE)
	{ "INTR",	R_intr		,f_intr		},
#endif
	{ "IOR",	R_bitwise	,f_or		},
	{ "IXOR",	R_bitwise	,f_xor		},
	{ "JUSTIFY",	R_SIoC		,f_justify	},
#ifdef WCE
	{ "LASTERROR",	R_O		,f_lasterror	},
#endif
	{ "LASTPOS",	R_SSoI		,f_lastpos	},
	{ "LEFT",	R_SIoC		,f_left		},
	{ "LENGTH",	R_S		,f_length	},
	{ "LINEIN",	R_charlinein	,f_linein	},
	{ "LINEOUT",	R_charlineout	,f_lineout	},
	{ "LINES",	R_charslines	,f_lines	},
#ifdef __CMS__
	{ "LINESIZE",	VM_O		,f_cmsline	},
#endif
	{ "LOAD",	R_S		,f_load		},
	{ "LOG",	R_math		,f_log		},
	{ "LOG10",	R_math		,f_log10	},
	{ "MAKEBUF",	R_O		,f_makebuf	},
	{ "MAX",	R_max		,f_max		},
	{ "MIN",	R_min		,f_min		},
	{ "OPEN",	R_open		,f_open		},
	{ "OVERLAY",	R_SSoIoIoC	,f_overlay	},
#if defined(__BORLANDC__) && !defined(__WIN32__) && !defined(WCE)
	{ "PORT",	R_port		,f_port		},
#endif
	{ "POS",	R_SSoI		,f_pos		},
	{ "POW",	R_atanpow	,f_pow		},
	{ "POW10",	R_math		,f_pow10	},
#ifndef WCE
	{ "PUTENV",	R_SS		,f_putenv	},
#endif
    { "P2D",	R_p2d		,f_p2d	},
	{ "QUEUED",	R_C		,f_queued	},
	{ "RANDOM",	R_random	,f_random	},
	{ "READ",	R_read		,f_read		},
	{ "REVERSE",	R_S		,f_reverse	},
	{ "RIGHT",	R_SIoC		,f_right	},
    { "ROUND",	R_round		,f_round	},
	{ "SEEK",	R_seek		,f_seek		},
#ifndef WCE
	{ "SETENV",	R_SS		,f_putenv	},
#endif
	{ "SIGN",	R_abs_sign	,f_sign		},
	{ "SIN",	R_math		,f_sin		},
	{ "SINH",	R_math		,f_sinh		},
	{ "SOUNDEX",	R_S		,f_soundex	},
	{ "SOURCELINE",	R_sourceline	,f_sourceline	},
	{ "SPACE",	R_space		,f_space	},
	{ "SQRT",	R_math		,f_sqrt		},
	{ "STORAGE",	R_storage	,f_storage	},
	{ "STREAM",	R_stream	,f_stream	},
	{ "STRIP",	R_strip		,f_strip	},
	{ "SUBSTR",	R_substr	,f_substr	},
	{ "SUBWORD",	R_SIoI		,f_subword	},
	{ "SYMBOL",	R_S		,f_symbol	},
	{ "TAN",	R_math		,f_tan		},
	{ "TANH",	R_math		,f_tanh		},
	{ "TIME",	R_C		,f_time		},
	{ "TRACE",	R_C		,f_trace	},
	{ "TRANSLATE",	R_translate	,f_translate	},
	{ "TRUNC",	R_trunc		,f_trunc	},
#ifdef __CMS__
	{ "USERID",	VM_O		,f_cmsuser	},
#endif
#ifdef WCE
	{ "U2A",	R_S		,f_u2a		},
#endif
	{ "VALUE",	R_SoSoS		,f_value	},
	{ "VARDUMP",	R_oSoS		,f_vartree	},
	{ "VERIFY",	R_verify	,f_verify	},
	{ "WORD",	R_SI		,f_word		},
	{ "WORDINDEX",	R_SI		,f_wordindex	},
	{ "WORDLENGTH",	R_SI		,f_wordlength	},
	{ "WORDPOS",	R_SSoI		,f_wordpos	},
	{ "WORDS",	R_S		,f_words	},
	{ "WRITE",	R_write		,f_write	},
#if defined(__CMS__) || defined(__MVS__)
	{ "XRANGE",	R_xrange	,f_xrange	},
	{ "X2B",	R_S		,f_x2b		},
	{ "X2C",	R_S		,f_x2c		},
	{ "X2D",	R_SoI		,f_x2d		}
#else
	{ "X2B",	R_S		,f_x2b		},
	{ "X2C",	R_S		,f_x2c		},
	{ "X2D",	R_SoI		,f_x2d		},
	{ "XRANGE",	R_xrange	,f_xrange	}
#endif
};

/* ------------- C_isBuiltin --------------- */
TBltFunc* __CDECL
C_isBuiltin( PLstr func )
{
	int	first, middle, last, cmp;
	PBinLeaf	leaf;

	first = 0;	/* Use binary search to find intruction */
	last  = DIMENSION(rexx_routine)-1;

	while (first<=last)   {
		middle = (first+last)/2;
		if ((cmp=Lcmp(func,rexx_routine[middle].name))==0)
			return (rexx_routine+middle);
		else
		if (cmp<0)
			last  = middle-1;
		else
			first = middle+1;
	}

	/* try to see if it exists in the extra functions */
	if (ExtraFuncs) {
		leaf = BinFind(ExtraFuncs,func);
		if (leaf)
			return (TBltFunc*)(leaf->value);
	}
	return NULL;
} /* C_isBuiltin */

/* ----------- RxRegFunction ------------- */
/* returns TRUE if an error occurs */
int __CDECL
RxRegFunction( char *name, void (__CDECL *func)(int), int opt )
{
	Lstr		fn;
	TBltFunc	*fp;
	PBinLeaf	leaf;
	RxFunc		*fc;

	if (ExtraFuncs==NULL) {
		ExtraFuncs = (BinTree*)MALLOC(sizeof(BinTree),"ExtraFuncs");
		BINTREEINIT(*ExtraFuncs);
	}

	LINITSTR(fn);
	Lscpy(&fn,name);
	Lupper(&fn);	/* translate to upper case */

	/* Function Already exists */
	if (C_isBuiltin(&fn)) {
		LFREESTR(fn);
		return TRUE;
	}

	/* create the structure */
	fp = (TBltFunc*)MALLOC(sizeof(TBltFunc),"RegFunc");
	if (!fp) return TRUE;

	fp->name = NULL;
	fp->func = func;
	fp->opt  = opt;

	/* Check the labels */
	leaf = BinFind(&_labels, &fn);
	if (leaf != NULL) {
		fc = (RxFunc*)(leaf->value);
		fc->type = FT_BUILTIN;
		fc->builtin = fp;
	} /* if it does not exists, it will be added when needed */

	/* Add it to the ExtraFuncs.
	 * fn after BinAdd will be empty,
	 * so the BinAdd should be the last
	 */
	BinAdd(ExtraFuncs,&fn,fp);

	return FALSE;
} /* RxRegFunction */

/* ----------- RxRegFunctionDone --------- */
void __CDECL
RxRegFunctionDone( void )
{
	if (!ExtraFuncs) return;
	BinDisposeLeaf(ExtraFuncs,ExtraFuncs->parent,FREE);
	FREE(ExtraFuncs);
	ExtraFuncs = NULL;
} /* RxRegFunctionDone */
