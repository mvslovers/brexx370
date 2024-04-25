/*
 * $Id: c2x.c,v 1.5 2011/06/29 08:33:09 bnv Exp $
 * $Log: c2x.c,v $
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
 * Revision 1.1  1998/07/02 17:16:35  bnv
 * Initial revision
 *
 */

#include "lstring.h"

/* ------------------- Lc2x ------------------- */
void __CDECL
Lc2x( const PLstr to, const PLstr from )
{
    unsigned char    *re, *ar;
    int    i,r;

    L2STR(from);

    Lfx(to,2*LLEN(*from));
    re = LSTR(*to); ar = LSTR(*from);

    for (i=0,r=0; i<LLEN(*from); i++) {
        re[r++] = chex[(ar[i] >> 4) & 0x0F];
        re[r++] = chex[ar[i] & 0x0F];
    }
    LTYPE(*to) = LSTRING_TY;
    LLEN(*to) = r;
} /* Lc2x */
