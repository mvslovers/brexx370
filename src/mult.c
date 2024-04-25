/*
 * $Id: mult.c,v 1.4 2008/07/15 07:40:54 bnv Exp $
 * $Log: mult.c,v $
 * Revision 1.4  2008/07/15 07:40:54  bnv
 * #include changed from <> to ""
 *
 * Revision 1.3  2002/06/11 12:37:15  bnv
 * Added: CDECL
 *
 * Revision 1.2  2001/06/25 18:49:48  bnv
 * Header changed to Id
 *
 * Revision 1.1  1998/07/02 17:18:00  bnv
 * Initial Version
 *
 */

#include "lerror.h"
#include "lstring.h"

/* ------------------- Lmult ----------------- */
void __CDECL
Lmult( const PLstr to, const PLstr A, const PLstr B)
{
    long long a,b,c,d;
    int numDigits = 0;

#if defined(__CMS__) || defined(__MVS__) || defined(__CROSS__)
   if (A->len+B->len>LMAXNUMERICSTRING) Lerror(ERR_ARITH_OVERFLOW,0);
#endif

    L2NUM(A);
    L2NUM(B);

    if ((LTYPE(*A)==LINTEGER_TY) && (LTYPE(*B)==LINTEGER_TY)) {

        a = LINT(*A);
        b = LINT(*B);

        c = a * b;
        d = c;

        if (c >= INT32_MIN && c <= INT32_MAX) {
            LINT(*to) = c;
            LTYPE(*to) = LINTEGER_TY;
            LLEN(*to) = sizeof(long);
        } else {
            while (d != 0) {
                d /= 10;
                ++numDigits;
            }

            Lfx(to,numDigits);
            sprintf(LSTR(*to), "%lld", c);
            LTYPE(*to) = LSTRING_TY;

            LLEN(*to) = numDigits;
        }

    } else {
        LREAL(*to) = TOREAL(*A) * TOREAL(*B);
        LTYPE(*to) = LREAL_TY;
        LLEN(*to)  = sizeof(double);
    }
} /* Lmult */
