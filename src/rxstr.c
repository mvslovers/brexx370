/*
 * $Id: rxstr.c,v 1.9 2008/07/15 07:40:25 bnv Exp $
 * $Log: rxstr.c,v $
 * Revision 1.9  2008/07/15 07:40:25  bnv
 * #include changed from <> to ""
 *
 * Revision 1.8  2006/01/26 10:27:57  bnv
 * Changed RxVar...Old() -> RxVar...Name()
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
 * Revision 1.4  2001/06/25 18:51:48  bnv
 * Header -> Id
 *
 * Revision 1.3  1999/11/26 13:13:47  bnv
 * Added: Windows CE support.
 * Changed: To use the new macros.
 *
 * Revision 1.2  1998/11/26 09:47:11  bnv
 * Changed: var 'match' in verify must be boolean
 *
 * Revision 1.1  1998/07/02 17:34:50  bnv
 * Initial revision
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mvs/env.h>

#include "lerror.h"
#include "lstring.h"

#include "rexx.h"
#include "rxdefs.h"
#include "interpre.h"
#include "rxmvsext.h"
#include "rxstr.h"

extern Lstr LTMP[16];      /* FCHANGESTR: scratch strings (interpre.c) */

/* --------------------------------------------------------------- */
/*  ABBREV(information,info[,length])                              */
/* --------------------------------------------------------------- */
/*  INDEX(haystack,needle[,start])                                 */
/* --------------------------------------------------------------- */
/*  FIND(string,phrase[,start])                                    */
/* --------------------------------------------------------------- */
/*  LASTPOS(needle,haystack[,start])                               */
/* --------------------------------------------------------------- */
/*  POS(needle,haystack[,start])                                   */
/* --------------------------------------------------------------- */
/*  WORDPOS(phrase,string[,start])                                 */
/* --------------------------------------------------------------- */
void __CDECL
R_SSoI( const int func )
{
	long	l;

	if (!IN_RANGE(2,ARGN,3))
		Lerror(ERR_INCORRECT_CALL,0);
	must_exist(1);
	must_exist(2);
	get_oi0(3,l);

	switch (func) {
		case f_abbrev:
			Licpy(ARGR,Labbrev(ARG1,ARG2,l));
			break;

		case f_index:
			Licpy(ARGR,Lindex(ARG1,ARG2,l));
			break;

		case f_find:
			Licpy(ARGR,Lfind(ARG1,ARG2,l));
			break;

		case f_lastpos:
			Licpy(ARGR,Llastpos(ARG1,ARG2,l));
			break;

		case f_pos:
			Licpy(ARGR,Lpos(ARG1,ARG2,l));
			break;

		case f_wordpos:
			Licpy(ARGR,Lwordpos(ARG1,ARG2,l));
			break;

		default:
			Lerror(ERR_INTERPRETER_FAILURE,0);
	} /* switch */
} /* R_SSoI */

/* --------------------------------------------------------------- */
/*  CENTRE(string,length[,pad])                                    */
/*  CENTER(string,length[,pad])                                    */
/* --------------------------------------------------------------- */
/*  JUSTIFY(string,length[,pad])                                   */
/* --------------------------------------------------------------- */
/*  LEFT(string,length[,pad])                                      */
/* --------------------------------------------------------------- */
/*  RIGHT(string,length[,pad])                                     */
/* --------------------------------------------------------------- */
void __CDECL
R_SIoC( const int func )
{
	long	l;
	char	pad;

	if (!IN_RANGE(2,ARGN,3))
		Lerror(ERR_INCORRECT_CALL,0);

	must_exist(1);
	get_i0(2,l);
	get_pad(3,pad);

	switch (func) {
		case f_center:
			Lcenter(ARGR,ARG1,l,pad);
			break;

		case f_justify:
			Ljustify(ARGR,ARG1,l,pad);
			break;

		case f_left:
			Lleft(ARGR,ARG1,l,pad);
			break;

		case f_right:
			Lright(ARGR,ARG1,l,pad);
			break;

		default:
			Lerror(ERR_INTERPRETER_FAILURE,0);
	} /* of switch */
} /* R_SIoC */

/* --------------------------------------------------------------- */
/*  B2X(string)                                                    */
/* --------------------------------------------------------------- */
/*  C2X(string)                                                    */
/* --------------------------------------------------------------- */
/*  GETENV(string)                                                 */
/* --------------------------------------------------------------- */
/*  LENGTH(string)                                                 */
/* --------------------------------------------------------------- */
/*  WORDS(string)                                                  */
/* --------------------------------------------------------------- */
/*  REVERSE(string)                                                */
/* --------------------------------------------------------------- */
/*  SYMBOL(name)                                                   */
/* --------------------------------------------------------------- */
/*  X2B(string)                                                    */
/* --------------------------------------------------------------- */
/*  X2C(string)                                                    */
/* --------------------------------------------------------------- */
/*  IMPORT( filename )                                             */
/*      loads a shared library or a rexx library                   */
/* --------------------------------------------------------------- */
/*  LOAD( filename )                                               */
/*      load a rexx file so it can be used as a library            */
/*      returns a return code from loadfile                        */
/*        "-1" when file is already loaded                         */
/*         "0" on success                                          */
/*         "1" on error opening the file                           */
/* ------------------------------------------------------ -------- */
/* -- WIN32_WCE -------------------------------------------------- */
/*  A2U(string)                                                    */
/* --------------------------------------------------------------- */
/*  U2A(string)                                                    */
/* --------------------------------------------------------------- */
void __CDECL
R_S( const int func )
{
	Lstr	str;
	int	found;

	if (ARGN!=1) Lerror(ERR_INCORRECT_CALL,0);
	L2STR(ARG1);

	switch (func) {
		case f_b2x:
			Lb2x(ARGR,ARG1);
			break;

		case f_c2x:
			Lc2x(ARGR,ARG1);
			break;

		case f_getenv:
			{
				char	*env;
				LASCIIZ(*ARG1);
				env = getenv(LSTR(*ARG1));
				if (env)
					Lscpy( ARGR, env);
				else
					LZEROSTR(*ARGR);
			}
			break;

		case f_length:
			Licpy(ARGR, LLEN(*ARG1));
			break;

		case f_words:
			Licpy(ARGR, Lwords(ARG1));
			break;

		case f_reverse:
			Lstrcpy(ARGR,ARG1);
			Lreverse(ARGR);
			break;

		case f_soundex:
			Lsoundex(ARGR,ARG1);
			break;

		case f_symbol:
			if (Ldatatype(ARG1,'S')==0) {
				Lscpy(ARGR,"BAD");
				return;
			}
			LINITSTR(str); Lfx(&str,LLEN(*ARG1));
			Lstrcpy(&str,ARG1);
			Lupper(&str); LASCIIZ(str);
			RxVarFindName(_proc[_rx_proc].scope,&str,&found);
			LFREESTR(str);
			if (found)
				Lscpy(ARGR,"VAR");
			else
				Lscpy(ARGR,"LIT");
			break;

		case f_x2b:
			Lx2b(ARGR,ARG1);
			break;

		case f_x2c:
			Lx2c(ARGR,ARG1);
			break;

		case f_hashvalue:
			Licpy(ARGR,Lhashvalue(ARG1));
			break;

		case f_load:
		case f_import:
			Licpy(ARGR,RxLoadLibrary(ARG1,func==f_import));
			break;

		default:
			Lerror(ERR_INTERPRETER_FAILURE,0);
	} /* switch */
} /* R_S */
/* --------------------------------------------------------------- */
/*  DELSTR(string,n[,length])                                      */
/* --------------------------------------------------------------- */
/*  DELWORD(string,n[,length])                                     */
/* --------------------------------------------------------------- */
/*  SUBWORD(string,n[,length])                                     */
/* --------------------------------------------------------------- */
void __CDECL
R_SIoI( const int func )
{
	long	n,l;

	if (!IN_RANGE(2,ARGN,3))
		Lerror(ERR_INCORRECT_CALL,0);
	must_exist(1);
	get_i(2,n);
	get_oiv(3,l,-1);

	switch (func) {
		case f_delstr:
			Ldelstr(ARGR,ARG1,n,l);
			break;

		case f_delword:
			Ldelword(ARGR,ARG1,n,l);
			break;

		case f_subword:
			Lsubword(ARGR,ARG1,n,l);
			break;

		default:
			Lerror(ERR_INTERPRETER_FAILURE,0);
	} /* switch */
} /* R_SIoI */

/* --------------------------------------------------------------- */
/*  INSERT(new,target[,[n][,[length][,pad]]])                      */
/* --------------------------------------------------------------- */
/*  OVERLAY(new,target[,[n][,[length][,pad]]])                     */
/* --------------------------------------------------------------- */
void __CDECL
R_SSoIoIoC( const int func )
{
	long	n,l;
	char	pad;

	if (!IN_RANGE(2,ARGN,5))
		Lerror(ERR_INCORRECT_CALL,0);
	must_exist(1);
	must_exist(2);
	get_oi0(3,n);
	get_oiv(4,l,-1);
	get_pad(5,pad);

	switch (func) {
		case f_insert:
			Linsert(ARGR,ARG1,ARG2,n,l,pad);
			break;

		case f_overlay:
			Loverlay(ARGR,ARG1,ARG2,n,l,pad);
			break;

		default:
			Lerror(ERR_INTERPRETER_FAILURE,0);
	} /* switch */
} /* R_SSoIoIoC */

/* --------------------------------------------------------------- */
/*  CHANGESTR(searchstr,string,replacestr)                         */
/* --------------------------------------------------------------- */
void __CDECL
R_changestr( )
{
	if (ARGN != 3)
		Lerror(ERR_INCORRECT_CALL,0);
	must_exist(1);
	must_exist(2);
	must_exist(3);
	Lchangestr(ARGR,ARG1,ARG2,ARG3);
} /* R_changestr */

/* --------------------------------------------------------------- */
/*  COMPARE(string1,string2[,pad])                                 */
/* --------------------------------------------------------------- */
void __CDECL
R_compare( )
{
	char	pad;

	if (!IN_RANGE(2,ARGN,3))
		Lerror(ERR_INCORRECT_CALL,0);
	must_exist(1);
	must_exist(2);
	get_pad(3,pad);

	Licpy(ARGR, Lcompare(ARG1,ARG2,pad));
} /* R_compare */

/* --------------------------------------------------------------- */
/*  COPIES(string,n)                                               */
/* --------------------------------------------------------------- */
void __CDECL
R_copies( )
{
	long	n;

	if (ARGN != 2)
		Lerror(ERR_INCORRECT_CALL,0);
	must_exist(1);
	must_exist(2); n = Lrdint(ARG2);
	if (n<0) Lerror(ERR_INCORRECT_CALL,0); 

	Lcopies(ARGR,ARG1,n);
} /* R_copies */

/* --------------------------------------------------------------- */
/*  SUBSTR(string,n[,[length][,pad]])                              */
/* --------------------------------------------------------------- */
void __CDECL
R_substr( )
{
	long	n,l;
	char	pad;

	if (!IN_RANGE(2,ARGN,4))
		Lerror(ERR_INCORRECT_CALL,0);
	must_exist(1);
	get_i(2,n);
	get_oiv(3,l,-1);
	get_pad(4,pad);

	Lsubstr(ARGR,ARG1,n,l,pad);
} /* R_substr */

/* --------------------------------------------------------------- */
/*  STRIP(string[,[<"L"|"T"|"B">][,char]])                         */
/* --------------------------------------------------------------- */
void __CDECL
R_strip( )
{
	char	action='B';
	char	pad;

	if (!IN_RANGE(1,ARGN,3))
		Lerror(ERR_INCORRECT_CALL,0);

	must_exist(1);
	if (exist(2)) { L2STR(ARG2); action = l2u[(byte)LSTR(*ARG2)[0]]; }
	get_pad(3,pad);
	Lstrip(ARGR,ARG1,action,pad);
} /* R_strip */

/* --------------------------------------------------------------- */
/*  FILTER(string,tablei)                                         */
/* --------------------------------------------------------------- */
void __CDECL
R_filter( )
{
    char  action='D';

    if (!IN_RANGE(1,ARGN,3))
        Lerror(ERR_INCORRECT_CALL,0);
    must_exist(1);
    must_exist(2);
    if (exist(3)) {
        Lupper(ARG_OWN(3)) ;
        if ((l2u[(byte)LSTR(*ARG3)[0]])=='K') action='K';
        else if ((l2u[(byte)LSTR(*ARG3)[0]])=='B') action='B';
        else action='D';
    }
    Lfilter(ARGR, ARG1, ARG2,action);
} /* R_filter */
/* --------------------------------------------------------------- */
/*  D2P(numeric,fraction,)                                         */
/* --------------------------------------------------------------- */
void __CDECL
R_d2p( )
{
    int fraction,plen;

    if (!IN_RANGE(1,ARGN,3))
        Lerror(ERR_INCORRECT_CALL,0);
    must_exist(1);
    get_oi0(2,plen);
    get_oi0(3,fraction);

    Ld2p(ARGR, ARG1, plen,fraction);
} /* R_d2p */
/* --------------------------------------------------------------- */
/*  P2D(packed-numeric)                                            */
/* --------------------------------------------------------------- */
void __CDECL
R_p2d( )
{
    int fraction;

    if (!IN_RANGE(1,ARGN,3))
        Lerror(ERR_INCORRECT_CALL,0);
    must_exist(1);
    get_oi0(3,fraction);

    Lp2d(ARGR, ARG1,0,fraction);
} /* R_p2d */

/* --------------------------------------------------------------- */
/*  TRANSLATE(string(,(tableo)(,(tablei)(,pad))))                  */
/* --------------------------------------------------------------- */
void __CDECL
R_translate( )
{
	char	pad;
	PLstr	tableo,tablei;

	if (!IN_RANGE(1,ARGN,4))
		Lerror(ERR_INCORRECT_CALL,0);

	must_exist(1);

	if (ARGN==1) {
		Lstrcpy(ARGR,ARG1);
		Lupper(ARGR);
		return;
	}

	if (exist(2))
		tableo = ARG2;
	else	
		tableo = NULL;

	if (exist(3))
		tablei = ARG3;
	else	
		tablei = NULL;

	get_pad(4,pad);

	Ltranslate(ARGR,ARG1,tableo,tablei,pad);
} /* R_translate */

/* --------------------------------------------------------------- */
/*  VERIFY(string,reference[,[option][,start]])                    */
/* --------------------------------------------------------------- */
void __CDECL
R_verify( )
{
	bool	match=FALSE;
	long	start;

	if (!IN_RANGE(2,ARGN,4))
		Lerror(ERR_INCORRECT_CALL,0);

	must_exist(1);
	must_exist(2);
	if (exist(3)) {
		L2STR(ARG3);
		match = (l2u[(byte)LSTR(*ARG3)[0]] == 'M');
	}
	get_oi(4,start);
	Licpy(ARGR,Lverify(ARG1,ARG2,match,start));
} /* R_verify */

/* --------------------------------------------------------------- */
/*  COUNTSTR(target,string)                                        */
/* --------------------------------------------------------------- */
void __CDECL
R_SS( __unused int type )
{
	if (ARGN!=2)
		Lerror(ERR_INCORRECT_CALL,0);

	must_exist(1);
	must_exist(2);
	Licpy(ARGR,Lcountstr(ARG1,ARG2));
} /* R_SS */


/* -------------------------------------------------------------------------------------
 * BREXX string functions, registered by RxStrRegFunctions(): UPPER, LOWER,
 * LASTWORD, JOIN, SPLIT, FPOS, FCHANGESTR, QUOTE, CHAR, C2U, E2A, A2E,
 * MASKBLK and LCS. Moved from rxmvs.c (#302).
 * -------------------------------------------------------------------------------------
 */
/* ------------------------------------------------------------------------------------
 * Pick exactly one CHAR out of a string
 * ------------------------------------------------------------------------------------
 */
void R_char(__unused int func) {
    char pad;
    int cnum;
    Lfx(ARGR,8);
    get_s(1);
    get_i(2,cnum);
    get_pad(3,pad);
    if ((size_t) cnum <= LLEN(*ARG1)) pad=LSTR(*ARG1)[cnum-1];
    Lscpy(ARGR,&pad);
    LLEN(*ARGR)=1;
}

void R_upper(__unused int func) {
    if (ARGN != 1) Lerror(ERR_INCORRECT_CALL,0);

    if (LTYPE(*ARG1) != LSTRING_TY) {
        L2str(ARG1);
    }
    LASCIIZ(*ARG1) ;
    Lstrcpy(ARGR,ARG1);
    Lupper(ARGR);
}

void R_lower(__unused int func) {
    if (ARGN != 1) Lerror(ERR_INCORRECT_CALL,0);

    if (LTYPE(*ARG1) != LSTRING_TY) {
        L2str(ARG1);
    }
    LASCIIZ(*ARG1) ;
    Lstrcpy(ARGR,ARG1);
    Llower(ARGR);
}

void R_lastword(__unused int func) {
    long offset=0;
    long lwi=0;
    long lwe=0;
    long wrds;

    LZEROSTR(*ARGR);   // default no word

    if (LLEN(*ARG1)==0) return;

    get_sv(1);
    get_oiv(2,wrds,1)

    offset= LLEN(*ARG1) - 1;


    while (wrds>0) {
        while (offset >= 0 && ISSPACE(LSTR(*ARG1)[offset])) offset--;
        if (offset < 0) break;
        lwe = offset + 2; // offset points to last char of word +1 to place it to next blank, +1 to make offset to position

        while (offset >= 0 && !ISSPACE(LSTR(*ARG1)[offset])) offset--;
        lwi= offset + 2;   // offset points to first blank prior to word +1 to place it to first char of word, +1 to make offset to position
        wrds--;
    }
     if (wrds==0) _Lsubstr(ARGR,ARG1,lwi,lwe-lwi);
}

void R_join(__unused int func) {
    int mlen = 0;
    int i = 0;
    Lstr joins;
    Lstr tabin;
    if (ARGN >3 || ARGN<2 || ARG1==NULL || ARG2==NULL) Lerror(ERR_INCORRECT_CALL, 0);
    if (LLEN(*ARG1) <1) {
        Lstrcpy(ARGR, ARG2);
        return;
    }
    if (LLEN(*ARG2) <1) {
        Lstrcpy(ARGR, ARG1);
        return;
    }
    if (LLEN(*ARG1) > LLEN(*ARG2)) mlen = LLEN(*ARG1);
    else mlen = LLEN(*ARG2);
    if (mlen <= 0) {
        LZEROSTR(*ARGR);
        return;
    }
    LINITSTR(tabin);
    Lfx(&tabin,32);
    if (ARG3==NULL||LLEN(*ARG3)==0) {
        LLEN(tabin)=1;
        LSTR(tabin)[0]=' ';
    } else {
        L2STR(ARG3);
        Lstrcpy(&tabin,ARG3);
    }

    LINITSTR(joins);
    Lfx(&joins, mlen);
    LLEN(joins)=mlen;

    L2STR(ARG1);
    LASCIIZ(*ARG1);
    L2STR(ARG2);
    LASCIIZ(*ARG2);

    /* both strings were read up to the longer length (#386): past the
     * target's end the string is appended, past the string's end a join
     * character of the target stays */
    for (i = 0; i < mlen; i++) {
        if ((size_t) i >= LLEN(*ARG2)) {
            LSTR(joins)[i] = LSTR(*ARG1)[i];
            continue;
        }
        LSTR(joins)[i] = LSTR(*ARG2)[i];
        if ((size_t) i >= LLEN(*ARG1)) continue;
        for (int j = 0; (size_t) j < LLEN(tabin); j++) {
            if (LSTR(*ARG2)[i] == LSTR(tabin)[j]) {   // a join character
                LSTR(joins)[i] = LSTR(*ARG1)[i];
                break;
            }
        }
    }
    Lstrcpy(ARGR, &joins);
    LFREESTR(joins);
    LFREESTR(tabin);
}

/* SPLIT: is c one of the delimiter characters */
static int isDelim(unsigned char c, const Lstr *delims)
{
    return memchr(LSTR(*delims), c, LLEN(*delims)) != NULL;
}

void R_split(__unused int func) {
    long i=0;
    long j=0;
    long n = 0;
    long ctr=0;
    Lstr Word;
    Lstr tabin;
    char varName[255];
    int sdot=0;

    if (ARGN >3 || ARG1==NULL|| ARG2==NULL) Lerror(ERR_INCORRECT_CALL, 0);
    LINITSTR(tabin);
    Lfx(&tabin,32);
    if (ARG3==NULL||LLEN(*ARG3)==0) {
        LLEN(tabin)=1;
        LSTR(tabin)[0]=' ';
    } else {
        L2STR(ARG3);
        Lstrcpy(&tabin,ARG3);
    }
    L2STR(ARG1);
    LASCIIZ(*ARG1);
    L2STR(ARG2);
    LASCIIZ(*ARG2);
    j=LLEN(*ARG2)-1;     // offset of last char
    if (LSTR(*ARG2)[j]=='.') sdot=1;
    Lupper(ARG_OWN(2));
    LINITSTR(Word);
    Lfx(&Word,LLEN(*ARG1)+1);

    memset(varName, 0, 255);
// Loop over provided string
    for (;;) {
        //    SKIP to next Word, Drop all word delimiter
        while ((size_t) i < LLEN(*ARG1) && isDelim(LSTR(*ARG1)[i], &tabin)) i++;
        if ((size_t) i >= LLEN(*ARG1)) break;
//    SKIP to next Delimiter, scan word
        n = i;
        while ((size_t) n < LLEN(*ARG1) && !isDelim(LSTR(*ARG1)[n], &tabin)) n++;
        //    Move Word into STEM
        ctr++;                    // Next word found, increase counter
        _Lsubstr(&Word,ARG1,i+1,n-i);
        LSTR(Word)[n-i]='\0';     // set 0 for end of string
        LLEN(Word)=n-i;
        if (sdot==0) snprintf(varName, sizeof(varName), "%s.%li",LSTR(*ARG2) ,ctr);
        else snprintf(varName, sizeof(varName), "%s%li",LSTR(*ARG2) ,ctr);
        setVariable(varName, LSTR(Word));  // set stem variable
        i=n;                      // newly set string offset for next loop
    }
//  set stem.0 content for found words
    {
        char count[16];     /* LSTR(Word) held the last word, not a number */

        if (sdot==0) snprintf(varName, sizeof(varName), "%s.0",LSTR(*ARG2));
        else snprintf(varName, sizeof(varName), "%s0",LSTR(*ARG2));
        snprintf(count, sizeof(count), "%ld", ctr);
        setVariable(varName, count);
    }
    LFREESTR(Word);
    LFREESTR(tabin);
    Licpy(ARGR, ctr);   // return number if found words
}

/* ----------------- Lindex ---------------------- */
/* haystack   - Lstr where to search               *
 *  needle    - Lstr to search                     *
 *    start       - starting position [1,haystack len] *
 *              if start < 1 then start = 1                *
 * returns  0 (NOTFOUND) is needle is not found    *
 * else returns position [1,haystack len]          *
 * ----------------------------------------------- */
long fndpos(const Lstr *needle, PLstr haystack, int start) {
    long fpos;
    start--;		/* for C string offset = 0, Rexx=1 */
    if (start < 0) start = 0;

    if (LLEN(*needle) <= 0)           return LNOTFOUND;
    if (LLEN(*haystack) <= 0)           return LNOTFOUND;
    if (LLEN(*needle) > LLEN(*haystack))  return LNOTFOUND;
    /* a start past the end searched the storage behind the string (#386) */
    if ((size_t) start >= LLEN(*haystack)) return LNOTFOUND;

    fpos= (long) strstr(LSTR(*haystack)+start, LSTR(*needle));
    if (fpos == 0)   return LNOTFOUND;
    return fpos-(long) (*haystack).pstr + 1;
}



void R_fpos( __unused int func)  {
    long	start;

    get_sv(1);
    get_sv(2);
    get_oiv(3,start,1);
     Licpy(ARGR,fndpos(ARG1,ARG2,start));
}

/* ----------------- Lchagestr ------------------- */
void R_fchangestr(__unused int func) {
    size_t pos;
    size_t foundpos;

    get_sv(1);
    get_sv(2);
    get_sv(3);

    if (LLEN(*ARG1)==0) {
        Lstrcpy(ARGR,ARG2);
        return;
    }

    LZEROSTR(*ARGR);
    pos = 1;

    for (;;) {
        foundpos = fndpos(ARG1,ARG2,pos);
        if (foundpos==0) break;
        if (foundpos!=pos) {
            _Lsubstr(&LTMP[14],ARG2,pos,foundpos-pos);
            Lstrcat(ARGR,&LTMP[14]);
        }
        Lstrcat(ARGR,ARG3);
        pos = foundpos + LLEN(*ARG1);
    }
    _Lsubstr(&LTMP[14],ARG2,pos,0);
    Lstrcat(ARGR,&LTMP[14]);
} /* Lchagestr */


void R_quote(__unused int func) {
  char quote= '\'';
  get_sv(1);

  if (LSTR(*ARG1)[0] == quote && LSTR(*ARG1)[LLEN(*ARG1) - 1] == '\'') goto isquoted;
  if (LSTR(*ARG1)[0] == '\"' && LSTR(*ARG1)[LLEN(*ARG1)-1] == '\"') goto isquoted;
  if (strchr((const char *) LSTR(*ARG1), quote) !=0) quote= '\"';   // string contains single quote, use double quote to enclose string
  // else quote='\'';                           // else use single quotes to enclose string is default
  Lfx(ARGR,LLEN(*ARG1)+2);
  LZEROSTR(*ARGR);
  LLEN(*ARGR)=1;
  LSTR(*ARGR)[0] = quote;
  Lstrcat(ARGR, ARG1);
  LSTR(*ARGR)[LLEN(*ARG1)+1] = quote;
  LLEN(*ARGR)=LLEN(*ARG1)+2;
  LSTR(*ARGR)[LLEN(*ARGR)] ='\0';

  return;
  isquoted:
    Lstrcpy(ARGR,ARG1);
  return;
}

void lcs (const char *a, int n, const char *b, int m, char **s) {
    int i;
    int j;
    int k;
    int t;
    int *z;
    int **c;

    if (n < 1 || m < 1) {               /* R_lcs refuses empty strings */
        Lscpy(ARGR, "");
        return;
    }
    /* (n+1)*(m+1) overflowed int for long strings: a small table */
    if ((size_t) (m + 1) > ((size_t) -1) / sizeof (int) / (size_t) (n + 1)) {
        Lfailure("LCS: strings too long", "", "", "", "");
        return;
    }
    z = calloc((size_t) (n + 1) * (size_t) (m + 1), sizeof (int));
    c = calloc((size_t) (n + 1), sizeof (int *));
    if (z == NULL || c == NULL) {       /* not checked before */
        free(c);
        free(z);
        Lfailure("LCS: not enough storage", "", "", "", "");
        return;
    }
    for (i = 0; i <= n; i++) {
        c[i] = &z[i * (m + 1)];
    }
    for (i = 1; i <= n; i++) {
        for (j = 1; j <= m; j++) {
            if (a[i - 1] == b[j - 1])   c[i][j] = c[i - 1][j - 1] + 1;
            else   c[i][j] = MAX(c[i - 1][j], c[i][j - 1]);
        }
    }
    t = c[n][m];
    *s = malloc(t + 1);                 /* Lscpy() reads it up to a NUL */
    if (*s == NULL) {
        free(c);
        free(z);
        Lfailure("LCS: not enough storage", "", "", "", "");
        return;
    }
    (*s)[t] = '\0';
    for (i = n, j = m, k = t - 1; k >= 0 && i > 0 && j > 0;) {
        if (a[i - 1] == b[j - 1])
            (*s)[k] = a[i - 1], i--, j--, k--;
        else if (c[i][j - 1] > c[i - 1][j])
            j--;
        else
            i--;
    }
    Lscpy(ARGR, *s);
    free(c);
    free(z);
    free(*s);
}

void R_lcs(__unused int func) {
   char *s;
   s = NULL;
   get_s(1);
   get_s(2);
   if (LLEN(*ARG1)==0 || LLEN(*ARG2)==0) Lerror(ERR_INCORRECT_CALL,0);

   lcs(LSTR(*ARG1),LLEN(*ARG1),LSTR(*ARG2),LLEN(*ARG2),&s);
}

void R_e2a(__unused int func){
    get_s(1);
    LE2A(ARGR, ARG1);
    LTYPE(*ARGR) = LSTRING_TY;
}

void R_a2e(__unused int func){
    get_s(1);
    LA2E(ARGR, ARG1);
    LTYPE(*ARGR) = LSTRING_TY;

}

/* -----------------------------------------------------------------------------------
 * Mask Blank within strings to improve WORD functions
 * -----------------------------------------------------------------------------------
 */
void R_maskblk( __unused int func ) {
    int strdel=0;
    char chr;
    if (ARGN != 3) Lerror(ERR_INCORRECT_CALL,0);
    get_s(1);    // string to change
    get_s(2);    // string delimeter typically " or '
    get_s(3);    // Blank replacement character
    LASCIIZ(*ARG1);

    Lstrcpy(ARGR,ARG1);
    for (int i=0; (size_t) i < LLEN(*ARGR);i++) {
        chr=LSTR(*ARGR)[i];
        if (strdel==1) {
            if (chr == LSTR(*ARG2)[0]) strdel = 0;
            else if(chr==' ') LSTR(*ARGR)[i]=LSTR(*ARG3)[0];
        }
        else if(chr==LSTR(*ARG2)[0]) strdel=1;
    }
}

/* -----------------------------------------------------------------------------------
 * Convert Number as unsigned integer to String
 * -----------------------------------------------------------------------------------
 */
void R_c2u( __unused int func )
{
    int n=0;
    unsigned int unum;
    n=sizeof(long);

    if (ARGN > 1) Lerror(ERR_INCORRECT_CALL,0);

    get_s(1);

    L2STR(ARG1);

    if (!LLEN(*ARG1)) {
        Licpy(ARGR,0);
        return;
    }

    Lstrcpy(ARGR,ARG1);
    Lreverse(ARGR);

    n = MIN(n,(int) LLEN(*ARG1));
    unum = 0;
    for (int i=n-1; i>=0; i--)
        unum = (unum << 8) | ((byte) (LSTR(*ARGR)[i]) & 0xFF);

    snprintf((char *) LSTR(*ARGR), LMAXLEN(*ARGR), "%u", unum);
    LTYPE(*ARGR)=LSTRING_TY;
    LLEN(*ARGR) = STRLEN(LSTR(*ARGR));
}

void RxStrRegFunctions()
{
    RxRegFunction("UPPER",      R_upper,        0);
    RxRegFunction("JOIN",       R_join,         0);
    RxRegFunction("SPLIT",      R_split,        0);
    RxRegFunction("LOWER",      R_lower,        0);
    RxRegFunction("LASTWORD",   R_lastword,     0);
    RxRegFunction("FPOS",       R_fpos,         0);
    RxRegFunction("FCHANGESTR", R_fchangestr,   0);
    RxRegFunction("QUOTE",    R_quote,      1);
    RxRegFunction("LCS",        R_lcs,          0);
    RxRegFunction("CHAR",       R_char,         0);
    RxRegFunction("E2A",        R_e2a,          0);
    RxRegFunction("A2E",        R_a2e,          0);
    RxRegFunction("C2U",        R_c2u ,         0);
    RxRegFunction("MASKBLK",    R_maskblk,      0);
} /* RxStrRegFunctions() */
