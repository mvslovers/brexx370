/*
 * $Id: copies.c,v 1.4 2008/07/15 07:40:54 bnv Exp $
 * $Log: copies.c,v $
 * Revision 1.4  2008/07/15 07:40:54  bnv
 * #include changed from <> to ""
 *
 * Revision 1.3  2002/06/11 12:37:15  bnv
 * Added: CDECL
 *
 * Revision 1.2  2001/06/25 18:49:48  bnv
 * Header changed to Id
 *
 * Revision 1.1  1998/07/02 17:17:00  bnv
 * Initial revision
 *
 */

#include "lstring.h"

/* ------------------ Lcopies -------------------- */
void __CDECL
Lcopies( const PLstr to, const PLstr from, long n )
{
    Lstr    tmp,tmp2;
    long    l;

    LZEROSTR(*to);
    if (n<0 || !LLEN(*from)) return;
    L2STR(to);

    Lfx(to, (size_t)(LLEN(*from)*n) );

    LINITSTR(tmp);
    LINITSTR(tmp2);

    l = 1;
    while (l<n) l<<=1;
    l>>=1;
    Lfx(&tmp,(size_t)l);
    Lfx(&tmp2,(size_t)l);

    Lstrcpy(&tmp,from);
    while (n != 0 ) {
        if (n&1) Lstrcat(to,&tmp);
        Lstrcpy(&tmp2,&tmp);
        Lstrcat(&tmp,&tmp2);
        n >>= 1;
    }

    LFREESTR(tmp);
    LFREESTR(tmp2);
} /* Lcopies */
