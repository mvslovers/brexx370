/*
 * $Id: mod.c,v 1.4 2008/07/15 07:40:54 bnv Exp $
 * $Log: mod.c,v $
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

/* ------------------ Lmod ----------------- */
void __CDECL
Lmod( const PLstr to, const PLstr A, const PLstr B )
{
    L2REAL(A);
    L2REAL(B);

    if (LREAL(*B) == 0) Lerror(ERR_ARITH_OVERFLOW,0);

    LREAL(*to) = (double) (LREAL(*A) - (long)(LREAL(*A) / LREAL(*B)) * LREAL(*B));
    LTYPE(*to) = LREAL_TY;
    LLEN(*to)  = sizeof(double);
} /* Lmod */
