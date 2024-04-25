/*
 * $Id: subword.c,v 1.6 2008/07/15 07:40:54 bnv Exp $
 * $Log: subword.c,v $
 * Revision 1.6  2008/07/15 07:40:54  bnv
 * #include changed from <> to ""
 *
 * Revision 1.5  2008/07/14 13:08:16  bnv
 * MVS,CMS support
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

/* ----------------- Lsubword ------------------ */
void __CDECL
Lsubword( const PLstr to, const PLstr from, long n, long length )
{
    long    i;
    Lstr    tmp;

    if (n<=0) n = 1;
    i = Lwordindex(from,n);

    if (i==0) {
        LZEROSTR(*to);
        return;
    }

    LINITSTR(tmp);

    if (length<=0) {
        if (length<0) _Lsubstr(&tmp,from,(size_t)i,0);
        goto fin;
    }
    n = i--;
    for (;;) {
        length--;
        LSKIPWORD(*from,i);
        if ((i>=LLEN(*from)) || !length) break;
        LSKIPBLANKS(*from,i);
        if (i>=LLEN(*from)) break;
    }
    _Lsubstr(&tmp,from,(size_t)n,(size_t)(i-n+1));
fin:
    Lstrip(to,&tmp,LTRAILING,' ');
    LFREESTR(tmp);
} /* Lsubword */
