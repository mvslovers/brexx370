/*
 * $Id: delstr.c,v 1.4 2008/07/15 07:40:54 bnv Exp $
 * $Log: delstr.c,v $
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

/* ---------------- Ldelstr ------------------- */
void __CDECL
Ldelstr( const PLstr to, const PLstr from, long start, long length )
{
    Lstr    tmp;

    L2STR(from);

    start--;
    if (start<0) start = 0;
    if (start>=LLEN(*from)) {
        Lstrcpy(to,from);
        return;
    }

    if (start)
        _Lsubstr(to,from,1,(size_t)start);
    else
        LZEROSTR(*to);

    if (length>0)
    if (start+length < LLEN(*from)) {
        LINITSTR(tmp);
        _Lsubstr(&tmp, from, (size_t)(start+length+1), 0);
        Lstrcat(to,&tmp);
        LFREESTR(tmp);
    }
} /* Ldelstr */
