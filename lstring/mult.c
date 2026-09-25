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
    long long a,b,c;
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

        if (c >= INT32_MIN && c <= INT32_MAX) {
            LINT(*to) = c;
            LTYPE(*to) = LINTEGER_TY;
            LLEN(*to) = sizeof(long);
        } else {
            /* format first: sprintf() yields the length including a sign.
             * (A "d /= 10" digit count dropped the sign, and cc370 inlines
             * a long long division by a constant incorrectly, cc370#467.) */
            char buf[24];

            numDigits = sprintf(buf, "%lld", c);

            Lfx(to,numDigits);
            MEMCPY(LSTR(*to), buf, numDigits);
            LTYPE(*to) = LSTRING_TY;

            LLEN(*to) = numDigits;
        }

    } else {
        LREAL(*to) = TOREAL(*A) * TOREAL(*B);
        LTYPE(*to) = LREAL_TY;
        LLEN(*to)  = sizeof(double);
    }
} /* Lmult */
