/*
 * $Id: add.c,v 1.6 2008/07/15 07:40:54 bnv Exp $
 * $Log: add.c,v $
 * Revision 1.6  2008/07/15 07:40:54  bnv
 * #include changed from <> to ""
 *
 * Revision 1.5  2002/06/11 12:37:15  bnv
 * Added: CDECL
 *
 * Revision 1.4  2001/06/25 18:49:48  bnv
 * Header changed to Id
 *
 * Revision 1.3  1999/11/26 09:50:50  bnv
 * Cleaned up a little
 *
 * Revision 1.2  1999/03/10 16:55:55  bnv
 * Corrected, the use of 'ta' and 'tb'
 *
 * Revision 1.1  1998/07/02 17:16:35  bnv
 * Initial revision
 *
 */

#include "lerror.h"
#include "lstring.h"

/* ---------------- Ladd ------------------- */
void __CDECL
Ladd( const PLstr to, const PLstr A, const PLstr B)
{
    int    ta, tb;
    double    r;

    if (LTYPE(*A) == LSTRING_TY) {
        ta = _Lisnum(A);
        if (ta==LSTRING_TY) Lerror(ERR_BAD_ARITHMETIC,0);
        r = lLastScannedNumber;
    } else {
        ta = LTYPE(*A);
        r = TOREAL(*A);
    }

    if (LTYPE(*B) == LSTRING_TY) {
        tb = _Lisnum(B);
        if (tb==LSTRING_TY) Lerror(ERR_BAD_ARITHMETIC,0);
        r += lLastScannedNumber;
    } else {
        tb = LTYPE(*B);
        r += TOREAL(*B);
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
} /* Ladd */
