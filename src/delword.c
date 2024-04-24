/*
 * $Id: delword.c,v 1.5 2008/07/15 07:40:54 bnv Exp $
 * $Log: delword.c,v $
 * Revision 1.5  2008/07/15 07:40:54  bnv
 * #include changed from <> to ""
 *
 * Revision 1.4  2003/10/30 13:16:53  bnv
 * Cosmetics
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

#include "lstring.h"

/* ----------------- Ldelword ---------------- */
void __CDECL
Ldelword( const PLstr to, const PLstr from, long start, long length )
{
    size_t    i;
    Lstr    tmp;

    if (start <= 0) start = 1;
    i = Lwordindex(from,start);
    if (i==0) {
        Lstrcpy(to,from);
        return;
    }

    if (i==1)
        LZEROSTR(*to)
    else
        _Lsubstr(to,from,1,i-1);

    if (length<0) return;

    i--;
    while (length) {
        length--;
        LSKIPWORD(*from,i);
        if (i>=LLEN(*from)) return;
        LSKIPBLANKS(*from,i);
        if (i>=LLEN(*from)) return;
    };
    LINITSTR(tmp);
    _Lsubstr(&tmp, from, i+1, 0);
    Lstrcat(to,&tmp);
    LFREESTR(tmp);
} /* Ldelword */
