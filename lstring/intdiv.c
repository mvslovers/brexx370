/*
 * $Id: intdiv.c,v 1.4 2008/07/15 07:40:54 bnv Exp $
 * $Log: intdiv.c,v $
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

/* ---------------- Lintdiv ---------------- */
void __CDECL
Lintdiv( const PLstr to, const PLstr A, const PLstr B )
{
    double    d1,d2,r;
    long      s;
    int       ta;
    d2 = Lrdreal(B);

    if (d2 == 0) Lerror(ERR_ARITH_OVERFLOW,0);

    d1 = Lrdreal(A);
    r = d1/d2;
    snprintf(LSTR(*to), LMAXLEN(*to), "%.*f", (int)1, r);
    LLEN(*to)  = STRLEN(LSTR(*to))-2;
    ta=_Lisnum(to);
    s=lLastScannedNumber;
    LINT(*to)  = (long)s;
	LTYPE(*to) = LINTEGER_TY;
	LLEN(*to)  = sizeof(long);
} /* Lintdiv */
