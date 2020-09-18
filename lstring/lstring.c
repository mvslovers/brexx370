/*
 * $Id: lstring.c,v 1.14 2011/06/29 08:33:09 bnv Exp $
 * $Log: lstring.c,v $
 * Revision 1.14  2011/06/29 08:33:09  bnv
 * char to unsigned
 *
 * Revision 1.13  2011/06/20 08:31:19  bnv
 * removed the FCVT and GCVT replaced with sprintf
 *
 * Revision 1.12  2011/05/17 06:53:31  bnv
 * Added SQLite
 *
 * Revision 1.11  2009/06/02 09:40:53  bnv
 * MVS/CMS corrections
 *
 * Revision 1.10  2008/07/15 07:40:54  bnv
 * #include changed from <> to ""
 *
 * Revision 1.9  2008/07/14 13:08:16  bnv
 * MVS,CMS support
 *
 * Revision 1.8  2004/03/26 22:51:11  bnv
 * values to limits
 *
 * Revision 1.7  2003/02/26 16:29:24  bnv
 * Changed: READLINE definitions
 *
 * Revision 1.6  2002/06/11 12:37:15  bnv
 * Added: CDECL
 *
 * Revision 1.5  2002/06/06 08:21:29  bnv
 * Added: Readline support
 *
 * Revision 1.4  2001/06/25 18:49:48  bnv
 * Header changed to Id
 *
 * Revision 1.3  1999/11/26 12:52:25  bnv
 * Added: Windows CE support
 * Added: Lwscpy, for unicode string copy
 * Changed: _Lisnum, it creates immediately a double number contained in
 * the string, for faster access. The value is hold in lLastScannedNumber
 *
 * Revision 1.2  1999/05/14 13:11:47  bnv
 * Minor changes
 *
 * Revision 1.1  1998/07/02 17:18:00  bnv
 * Initial Version
 *
 */

#define __LSTRING_C__

#ifdef JCC
#include "rexx.h"
#endif

#include <math.h>
#include "lerror.h"
#include "lstring.h"

#ifndef WIN32
#	if !defined(__CMS__) && !defined(__MVS__)
#	ifndef WIN
#		include <limits.h>
#	endif
#	endif
#endif

#ifdef WIN32
#	include <limits.h>
#	define MAXLONG LONG_MAX
#endif

#if defined(__CMS__) || defined(__MVS__)
#	include <limits.h>
#	define MAXLONG LONG_MAX
#endif

#ifdef HAVE_READLINE
//#	if defined(HAVE_READLINE_HISTORY_H)
#	include <readline/history.h>
//#	elif defined(HAVE_HISTORY_H)
//#		include <history.h>
//#	endif
#endif

/* ================= Lstring routines ================== */

/* -------------------- Linit ---------------- */
void __CDECL
Linit( LerrorFunc Lerr)
{
    size_t	i;

    /* setup error function */
#ifndef WIN
    if (Lerr)
        Lerror = Lerr;
    else
        Lerror = Lstderr;
#else
    Lerror = Lerr;
#endif

    /* setup upper */
    for (i=0; i<256; i++)  u2l[i] = l2u[i] = i;
    for (i=0; clower[i]; i++) {
        l2u[ (byte)clower[i] & 0xFF ] = cUPPER [i];
        u2l[ (byte)cUPPER[i] & 0xFF ] = clower [i];
    }

#ifdef HAVE_READLINE
    using_history();
#endif

    /* setup time */
    _Ltimeinit();
} /* Linit */

/* -------------- _Lfree ------------------- */
void __CDECL
_Lfree(void *str)
{
    LPFREE((PLstr)str);
} /* _Lfree */

/* ---------------- Lfx -------------------- */
void __CDECL
Lfx( const PLstr s, const size_t len )
{
    size_t	max;

    if (LISNULL(*s)) {
        LSTR(*s) = (unsigned char *) MALLOC( (max = LNORMALISE(len))+LEXTRA, "Lstr" );
        memset(LSTR(*s),0,max);
        LLEN(*s) = 0;
        LMAXLEN(*s) = max;
        LTYPE(*s) = LSTRING_TY;
#ifdef USEOPTION
        LOPT(*s) = 0;
#endif
    } else
#ifdef USEOPTION
    if (!LOPTION(*s,LOPTFIX) && LMAXLEN(*s)<len) {
        LSTR(*s) = (unsigned char *) REALLOC( LSTR(*s), (max=LNORMALISE(len))+LEXTRA);
        LMAXLEN(*s) = max;
    }
#else
    if (LMAXLEN(*s)<len) {
        LSTR(*s) = (unsigned char *) REALLOC( LSTR(*s), (max=LNORMALISE(len))+LEXTRA);
        LMAXLEN(*s) = max;
    }
#endif
} /* Lfx */

/* ---------------- Licpy ------------------ */
void __CDECL
Licpy( const PLstr to, const long from )
{
    LLEN(*to)  = sizeof(long);
    LTYPE(*to) = LINTEGER_TY;
    LINT(*to)  = from;
} /* Licpy */

/* ---------------- Lrcpy ------------------ */
void __CDECL
Lrcpy( const PLstr to, const double from )
{
    LLEN(*to)  = sizeof(double);
    LTYPE(*to) = LREAL_TY;
    LREAL(*to) = from;
} /* Lrcpy */

/* ---------------- Lscpy ------------------ */
void __CDECL
Lscpy( const PLstr to, const char *from )
{
    size_t	len;

    if (!from)
        Lfx(to,len=0);
    else {
        Lfx(to,len = STRLEN(from));
        MEMCPY( LSTR(*to), from, len );
    }
    LLEN(*to) = len;
    LTYPE(*to) = LSTRING_TY;
} /* Lscpy */

void __CDECL
Lscpy2( const PLstr to, const char *from, int lFrom )
{
    size_t	len;

    if (!from)
        Lfx(to,len=0);
    else {
        Lfx(to,len = lFrom);
        MEMCPY( LSTR(*to), from, len );
    }
    LLEN(*to) = len;
    LTYPE(*to) = LSTRING_TY;
} /* Lscpy */

#if !defined(__CMS__) && !defined(__MVS__)
/* ---------------- Lwscpy ------------------ */
void __CDECL
Lwscpy(const PLstr to, const wchar_t *from )
{
    size_t	len;

    if (!from)
        Lfx(to,len=0);
    else {
        Lfx(to,len = wcslen(from));
        wcstombs(LSTR(*to), from ,len );
    }
    LLEN(*to) = len;
    LTYPE(*to) = LSTRING_TY;
} /* Lwscpy */
#endif

/* ---------------- Lcat ------------------- */
void __CDECL
Lcat( const PLstr to, const char *from )
{
    size_t	l;

    if (from==NULL) return;

    if (LLEN(*to)==0)
        Lscpy( to, from );
    else {
        L2STR(to);
        l=LLEN(*to) + STRLEN(from);
        if (LMAXLEN(*to)<l) Lfx(to,l);
        STRCPY( LSTR(*to) + LLEN(*to), from );
        LLEN(*to) = l;
    }
} /* Lcat */

/* ------------------ Lcmp ------------------- */
int __CDECL
Lcmp( const PLstr a, const char *b )
{
    int	r,blen;

    L2STR(a);

    blen = STRLEN(b);
    if ( (r=MEMCMP( LSTR(*a), b, MIN(LLEN(*a),blen)))!=0 )
        return r;
    else {
        if (LLEN(*a) > blen)
            return 1;
        else
        if (LLEN(*a) == blen)
            return 0;
        else
            return -1;
    }
} /* Lcmp */

/* ---------------- Lstrbeg ----------------- */
int __CDECL
Lstrbeg(const PLstr str, const PLstr pre)
{
    size_t lenpre = pre->len,
           lenstr = str->len;

    return lenstr < lenpre ? FALSE : memcmp(pre->pstr, str->pstr, lenpre) == 0;
} /* Lstrbeg

/* ---------------- Lbeg -------------------- */
int __CDECL
Lbeg(const PLstr str, const char *pre)
{
    size_t lenpre = strlen(pre),
            lenstr = str->len;
    return lenstr < lenpre ? FALSE : memcmp(pre, str->pstr, lenpre) == 0;
} /* Lbeg */

/* ---------------- Lstrcpy ----------------- */
void __CDECL
Lstrcpy( const PLstr to, const PLstr from )
{
    //TODO MIG may be this is not the best place
    if ( LISNULL(*to) ) {
        Lfx(to,31);
    }

    if (LLEN(*from)==0) {
        LLEN(*to) = 0;
        LTYPE(*to) = LSTRING_TY;
    } else {
        if (LMAXLEN(*to)<=LLEN(*from)) Lfx(to,LLEN(*from));
        switch ( LTYPE(*from) ) {
            case LSTRING_TY:
                MEMCPY( LSTR(*to), LSTR(*from), LLEN(*from) );
                break;

            case LINTEGER_TY:
                LINT(*to) = LINT(*from);
                break;

            case LREAL_TY:
                LREAL(*to) = LREAL(*from);
                break;
        }
        LTYPE(*to) = LTYPE(*from);
        LLEN(*to) = LLEN(*from);
    }
} /* Lstrcpy */

/* ----------------- Lstrcat ------------------ */
void __CDECL
Lstrcat( const PLstr to, const PLstr from )
{
    size_t	l;

    if (LLEN(*from)==0) return;

    if (LLEN(*to)==0) {
        Lstrcpy( to, from );
        return;
    }

    L2STR(to);
    L2STR(from);

    l = LLEN(*to)+LLEN(*from);
    if (LMAXLEN(*to) < l)
#ifdef JCC
        Lfx(to, MAX(l,LMAXLEN(*to) + CAT_INC));
#else
        Lfx(to, l);
#endif
    MEMCPY( LSTR(*to) + LLEN(*to), LSTR(*from), LLEN(*from) );
    LLEN(*to) = l;
} /* Lstrcat */

/* ----------------- _Lstrcmp ----------------- */
/* -- Low level strcmp, suppose that both of -- */
/* -- are of the same type                      */
int __CDECL
_Lstrcmp( const PLstr a, const PLstr b )
{
    int	r;

    if ( (r=MEMCMP( LSTR(*a), LSTR(*b), MIN(LLEN(*a),LLEN(*b))))!=0 )
        return r;
    else {
        if (LLEN(*a) > LLEN(*b))
            return 1;
        else
        if (LLEN(*a) == LLEN(*b)) {
            if (LTYPE(*a) > LTYPE(*b))
                return 1;
            else
            if (LTYPE(*a) < LTYPE(*b))
                return -1;
            return 0;
        } else
            return -1;
    }
} /* _Lstrcmp */

/* ----------------- Lstrcmp ------------------ */
int __CDECL
Lstrcmp( const PLstr a, const PLstr b )
{
    int	r;

    L2STR(a);
    L2STR(b);

    if ( (r=MEMCMP( LSTR(*a), LSTR(*b), MIN(LLEN(*a),LLEN(*b))))!=0 )
        return r;
    else {
        if (LLEN(*a) > LLEN(*b))
            return 1;
        else
        if (LLEN(*a) == LLEN(*b))
            return 0;
        else
            return -1;
    }
}  /* Lstrcmp */

/* ----------------- Lstrset ------------------ */
void __CDECL
Lstrset( const PLstr to, const size_t length, const char value)
{
    Lfx(to,length);
    LTYPE(*to) = LSTRING_TY;
    LLEN(*to) = length;
    MEMSET(LSTR(*to),value,length);
}  /* Lstrset */

/* ----------------- _Lsubstr ----------------- */
/* WARNING!!! length is size_t type DO NOT PASS A NEGATIVE value */
void __CDECL
_Lsubstr( const PLstr to, const PLstr from, size_t start, size_t length )
{
    L2STR(from);

    start--;
    if ((length==0) || (length+start>LLEN(*from)))
        length = LLEN(*from) - start;

    if (start<LLEN(*from)) {
        if (LMAXLEN(*to)<length) Lfx(to,length);
        MEMCPY( LSTR(*to), LSTR(*from)+start, length );
        LLEN(*to) = length;
    } else
        LZEROSTR(*to);
    LTYPE(*to) = LSTRING_TY;
}  /* Lstrsub */

/* ------------------------ _Lisnum ----------------------- */
/* _Lisnum      - returns if it is possible to convert      */
/*               a LSTRING to NUMBER                        */
/*               a LREAL_TY or LINTEGER_TY                  */
/* There is one possibility that is missing...              */
/* that is to hold an integer number as a real in a string. */
/* ie.   '  2.0 '  this should be LINTEGER not LREAL        */
/* -------------------------------------------------------- */
int __CDECL
_Lisnum( const PLstr s )
{
    bool	F, R;
    register char	*ch;

    int	sign;
    int	exponent;
    int	expsign;
    int	fractionDigits;

    lLastScannedNumber = 0.0;

/* ---
#ifdef USEOPTION
    if (LOPT(*s) & (LOPTINT | LOPTREAL)) {
        if (LOPT(*s) & LOPTINT)
            return LINTEGER_TY;
        else
            return LREAL_TY;
    }
#endif
--- */

    ch = LSTR(*s);
    if (ch==NULL) return LSTRING_TY;
#if defined(__CMS__) || defined(__MVS__)                
    if (s->len>LMAXNUMERICSTRING) return LSTRING_TY;    
#endif                                                  
    LASCIIZ(*s);	/*	///// Remember to erase LASCIIZ
                ///// before all the calls to Lisnum */

    /* skip leading spaces */
    while (ISSPACE(*ch)) ch++;

    /* accept one sign */
    if (*ch=='-') {
        sign = TRUE;
        ch++;
    } else {
        sign=FALSE;
        if (*ch=='+')
            ch++;
    }

    /* skip following spaces after sign */
    while (ISSPACE(*ch)) ch++;

    /* accept many digits */
    R = FALSE;

    lLastScannedNumber = 0.0;
    fractionDigits=0;
    exponent=0;
    expsign=FALSE;

    if (IN_RANGE('0',*ch,'9')) {
        lLastScannedNumber = lLastScannedNumber*10.0 + (*ch-'0');
        ch++;
        F = TRUE;
        while (ISSPACE(*ch)) ch++;
        while (IN_RANGE('0',*ch,'9')) {
            lLastScannedNumber = lLastScannedNumber*10.0 + (*ch-'0');
            ch++;
        }
        if (!*ch) goto isnumber;
    } else
        F = FALSE;

    /* accept one dot */
    if (*ch=='.') {
        R = TRUE;
        ch++;

        /* accept many digits */
        if (IN_RANGE('0',*ch,'9')) {
            lLastScannedNumber = lLastScannedNumber*10.0 + (*ch-'0');
            fractionDigits++;
            ch++;
            while (IN_RANGE('0',*ch,'9')) {
                lLastScannedNumber = lLastScannedNumber*10.0 + (*ch-'0');
                fractionDigits++;
                ch++;
            }
        } else
            if (!F) return LSTRING_TY;

        if (!*ch) goto isnumber;
    } else
        if (!F) return LSTRING_TY;


    /* accept on 'e' or 'E' */
    if (*ch=='e' || *ch=='E') {
        ch++;
        R = TRUE;
        /* accept one sign */
        if (*ch=='-') {
            expsign = TRUE;
            ch++;
        } else
        if (*ch=='+')
            ch++;

        /* accept many digits */
        if (IN_RANGE('0',*ch,'9')) {
            exponent = exponent*10+(*ch-'0');
            ch++;
            while (IN_RANGE('0',*ch,'9')) {
                exponent = exponent*10+(*ch-'0');
                ch++;
            }
        } else
            return LSTRING_TY;
    }

    /* accept many blanks */
    while (ISSPACE(*ch)) ch++;

    /* is it end of string */
    if (*ch) return LSTRING_TY;

isnumber:
    if (expsign) exponent = -exponent;

    exponent -= fractionDigits;

    if (exponent)
#ifdef __BORLAND_C__
        lLastScannedNumber *= pow10(exponent);
#else
        lLastScannedNumber *= pow(10.0,(double)exponent);
#endif

    if (lLastScannedNumber>LONG_MAX)
        R = TRUE;	/* Treat it as real number */

    if (sign)
        lLastScannedNumber = -lLastScannedNumber;

    if (R) return LREAL_TY;

    return LINTEGER_TY;
} /* _Lisnum */

/* ------------------ L2str ------------------- */
void __CDECL
L2str( const PLstr s )
{
    if (LTYPE(*s)==LINTEGER_TY) {
#if defined(WCE) || defined(__BORLANDC__)
        LTOA(LINT(*s),LSTR(*s),10);
#else
        sprintf(LSTR(*s), "%ld", LINT(*s));
#endif
        LLEN(*s) = STRLEN(LSTR(*s));
    } else {	/* LREAL_TY */
        /* There is a problem with the Windows CE */
        char	str[50];
        size_t	len;

        snprintf(str, sizeof(str), "%.*g", lNumericDigits, LREAL(*s));
        /* --- remove the last dot from the number --- */
        len = STRLEN(str);
#ifdef WCE
        if (str[len-1] == '.') len--;
#endif
        if (len>=LMAXLEN(*s)) Lfx(s,len);
        MEMCPY(LSTR(*s),str,len);
        LLEN(*s) = len;
    }
    LTYPE(*s) = LSTRING_TY;
} /* L2str */

/* ------------------ L2int ------------------- */
void __CDECL
L2int( const PLstr s )
{
    if (LTYPE(*s)==LREAL_TY) {
        if ((double)((long)LREAL(*s)) == LREAL(*s))
            LINT(*s) = (long)LREAL(*s);
        else
            Lerror(ERR_INVALID_INTEGER,0);
    } else { /* LSTRING_TY */
        LASCIIZ(*s);
        switch (_Lisnum(s)) {
            case LINTEGER_TY:
                LINT(*s) = (long)lLastScannedNumber;
                break;

            case LREAL_TY:
                LREAL(*s) = lLastScannedNumber;
                if ((double)((long)LREAL(*s)) == LREAL(*s))
                    LINT(*s) = (long)LREAL(*s);
                else
                    Lerror(ERR_INVALID_INTEGER,0);
                break;

            default:
                Lerror(ERR_INVALID_INTEGER,0);
        }
    }
    LTYPE(*s) = LINTEGER_TY;
    LLEN(*s) = sizeof(long);
} /* L2int */

/* ------------------ L2real ------------------- */
void __CDECL
L2real( const PLstr s )
{
    if (LTYPE(*s)==LINTEGER_TY)
        LREAL(*s) = (double)LINT(*s);
    else { /* LSTRING_TY */
        LASCIIZ(*s);
        if (_Lisnum(s)!=LSTRING_TY)
            /*/////LREAL(*s) = strtod( LSTR(*s), NULL ); */
            LREAL(*s) = lLastScannedNumber;
        else
            Lerror(ERR_BAD_ARITHMETIC,0);
    }
    LTYPE(*s) = LREAL_TY;
    LLEN(*s) = sizeof(double);
} /* L2real */

/* ------------------- _L2num -------------------- */
/* this function is used when we know to what type */
/* we should change the string                     */
void __CDECL
_L2num( const PLstr s, const int type )
{
    LASCIIZ(*s);
    switch (type) {
        case LINTEGER_TY:
            /*////LINT(*s) = atol( LSTR(*s) ); */
            LINT(*s) = (long)lLastScannedNumber;
            LTYPE(*s) = LINTEGER_TY;
            LLEN(*s) = sizeof(long);
            break;

        case LREAL_TY:
            /*////LREAL(*s) = strtod( LSTR(*s), NULL ); */
            LREAL(*s) = lLastScannedNumber;
            if ((double)((long)LREAL(*s)) == LREAL(*s)) {
                LINT(*s) = (long)LREAL(*s);
                LTYPE(*s) = LINTEGER_TY;
                LLEN(*s) = sizeof(long);
            } else {
                LTYPE(*s) = LREAL_TY;
                LLEN(*s) = sizeof(double);
            }
            break;
        default:
            Lerror(ERR_BAD_ARITHMETIC,0);
    }
} /* _L2num */

/* ------------------ L2num ------------------- */
void __CDECL
L2num( const PLstr s )
{
    switch (_Lisnum(s)) {
        case LINTEGER_TY:
            /*//LINT(*s) = atol( LSTR(*s) ); */
            LINT(*s) = (long)lLastScannedNumber;
            LTYPE(*s) = LINTEGER_TY;
            LLEN(*s) = sizeof(long);
            break;

        case LREAL_TY:
            /*///LREAL(*s) = strtod( LSTR(*s), NULL ); */
            LREAL(*s) = lLastScannedNumber;
/*
//// Numbers like 2.0 should be treated as real and not as integer
//// because in cases like factorial while give an error result
////			if ((double)((long)LREAL(*s)) == LREAL(*s)) {
////				LINT(*s) = (long)LREAL(*s);
////				LTYPE(*s) = LINTEGER_TY;
////				LLEN(*s) = sizeof(long);
////			} else {
*/
                LTYPE(*s) = LREAL_TY;
                LLEN(*s) = sizeof(double);
/*
////			}
*/
            break;

        default:
            Lerror(ERR_BAD_ARITHMETIC,0);
    }
} /* L2num */

/* ----------------- Lrdint ------------------ */
long __CDECL
Lrdint( const PLstr s )
{
    if (LTYPE(*s)==LINTEGER_TY) return LINT(*s);

    if (LTYPE(*s)==LREAL_TY) {
        if ((double)((long)LREAL(*s)) == LREAL(*s))
            return (long)LREAL(*s);
        else
            Lerror(ERR_INVALID_INTEGER,0);
    } else { /* LSTRING_TY */
        LASCIIZ(*s);
        switch (_Lisnum(s)) {
            case LINTEGER_TY:
                /*///return atol( LSTR(*s) ); */
                return (long)lLastScannedNumber;

            case LREAL_TY:
                /*///d = strtod( LSTR(*s), NULL );
                //////if ((double)((long)d) == d)
                //////	return (long)d; */
                if ((double)((long)lLastScannedNumber) == lLastScannedNumber)
                    return (long)lLastScannedNumber;
                else
                    Lerror(ERR_INVALID_INTEGER,0);
                break;

            default:
                Lerror(ERR_INVALID_INTEGER,0);
        }
    }
    return 0;	/* never gets here but keeps compiler happy */
} /* Lrdint */

/* ----------------- Lrdreal ------------------ */
double __CDECL
Lrdreal( const PLstr s )
{
    if (LTYPE(*s)==LREAL_TY) return LREAL(*s);

    if (LTYPE(*s)==LINTEGER_TY)
        return (double)LINT(*s);
    else { /* LSTRING_TY */
        LASCIIZ(*s);
        if (_Lisnum(s)!=LSTRING_TY)
            /*///// return strtod( LSTR(*s), NULL ); */
            return lLastScannedNumber;
        else
            Lerror(ERR_BAD_ARITHMETIC,0);
    }
    return 0.0;
} /* Lrdreal */

/* ------------------- Ceil ------------------ */
void __CDECL
Lceil( const PLstr to, const PLstr num )
{
    LINT(*to)  = ceil(Lrdreal(num));
    LTYPE(*to) = LINTEGER_TY;
    LLEN(*to)  = sizeof(long);
} /* Ceil */

/* ------------------- Floor ------------------ */
void __CDECL
Lfloor( const PLstr to, const PLstr num )
{
    LINT(*to)  = floor(Lrdreal(num));
    LTYPE(*to) = LINTEGER_TY;
    LLEN(*to)  = sizeof(long);
} /* Floor */

/* ----------------- Lpow --------------------- */
void __CDECL
Lpow( const PLstr to, const PLstr num, const PLstr p )
{
    L2REAL(num);
    L2REAL(p);
    Lrcpy(to, pow(LREAL(*num),LREAL(*p)));
} /* Lpow */

/* ----------------- Lpow --------------------- */
void __CDECL
Latan2( const PLstr to, const PLstr x, const PLstr y )
{
    Lrcpy(to, atan2(Lrdreal(x),Lrdreal(y)));
} /* Latan2 */