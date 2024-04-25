/*
 * $Id: div.c,v 1.5 2011/06/29 08:33:09 bnv Exp $
 * $Log: div.c,v $
 * Revision 1.5  2011/06/29 08:33:09  bnv
 * char to unsigned
 *
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

/* ------------------- Ldiv ----------------- */
void __CDECL
Ldiv( const PLstr to, const PLstr A, const PLstr B )
{
    double    b;

    b = Lrdreal(B);
    if (b == 0) Lerror(ERR_ARITH_OVERFLOW,3);
    LREAL(*to) = Lrdreal(A) / b;
    LTYPE(*to) = LREAL_TY;
    LLEN(*to)  = sizeof(double);
} /* Ldiv */
