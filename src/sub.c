/*
 * $Id: sub.c,v 1.5 2008/07/15 07:40:54 bnv Exp $
 * $Log: sub.c,v $
 * Revision 1.5  2008/07/15 07:40:54  bnv
 * #include changed from <> to ""
 *
 * Revision 1.4  2002/06/11 12:37:15  bnv
 * Added: CDECL
 *
 * Revision 1.3  2001/06/25 18:49:48  bnv
 * Header changed to Id
 *
 * Revision 1.2  1999/11/26 12:52:25  bnv
 * Changed: To use lLastScannedNumber.
 *
 * Revision 1.1  1998/07/02 17:18:00  bnv
 * Initial Version
 *
 */

#include "lerror.h"
#include "lstring.h"

/* ---------------- Lsub ------------------- */
void __CDECL
Lsub( const PLstr to, const PLstr A, const PLstr B)
{
    int    ta, tb;
    double    r;

    if (LTYPE(*A) == LSTRING_TY) {
        ta = _Lisnum(A);
        if (ta==LSTRING_TY) Lerror(ERR_BAD_ARITHMETIC,0);
        /*//r = strtod(LSTR(*A),NULL); */
        r = lLastScannedNumber;
    } else {
        ta = LTYPE(*A);
        r = TOREAL(*A);
    }

    if (LTYPE(*B) == LSTRING_TY) {
        tb = _Lisnum(B);
        if (tb==LSTRING_TY) Lerror(ERR_BAD_ARITHMETIC,0);
        /*//r -= strtod(LSTR(*B),NULL); */
        r -= lLastScannedNumber;
    } else {
        tb = LTYPE(*B);
        r -= TOREAL(*B);
    }

    if ( (ta == LINTEGER_TY) && (tb == LINTEGER_TY) ) {
        LINT(*to)  = (long)r;
        LTYPE(*to) = LINTEGER_TY;
        LLEN(*to)  = sizeof(long);
    } else {
        LREAL(*to) = r;
        LTYPE(*to) = LREAL_TY;
        LLEN(*to)  = sizeof(double);
    }
} /* Lsub */
