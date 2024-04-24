/*
 * $Id: word.c,v 1.4 2008/07/15 07:40:54 bnv Exp $
 * $Log: word.c,v $
 * Revision 1.4  2008/07/15 07:40:54  bnv
 * #include changed from <> to ""
 *
 * Revision 1.3  2002/06/11 12:37:15  bnv
 * Added: CDECL
 *
 * Revision 1.2  2001/06/25 18:49:48  bnv
 * Header changed to Id
 *
 * Revision 1.1  1998/07/02 17:20:58  bnv
 * Initial Version
 *
 */

#include "lstring.h"

/* ------------------ Lword ------------------- */
void __CDECL
Lword( const PLstr to, const PLstr from, long n )
{
    long    i;

    i = Lwordindex(from,n);
    if (n<=0) n = 1;
    if (i==0) {
        LZEROSTR(*to);
        return;
    }
    n = i-1;
    LSKIPWORD(*from,n);
    _Lsubstr(to,from,i,n-i+1);
} /* Lword */
