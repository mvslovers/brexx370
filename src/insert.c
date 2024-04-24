/*
 * $Id: insert.c,v 1.5 2008/07/15 07:40:54 bnv Exp $
 * $Log: insert.c,v $
 * Revision 1.5  2008/07/15 07:40:54  bnv
 * #include changed from <> to ""
 *
 * Revision 1.4  2002/06/11 12:37:15  bnv
 * Added: CDECL
 *
 * Revision 1.3  2001/06/25 18:49:48  bnv
 * Header changed to Id
 *
 * Revision 1.2  1999/11/26 12:52:25  bnv
 * Space
 *
 * Revision 1.1  1998/07/02 17:18:00  bnv
 * Initial Version
 *
 */

#include "lstring.h"

/* ------------------ Linsert ------------------- */
void __CDECL
Linsert( const PLstr to, const PLstr newstr, const PLstr target,
            long n, long length, const char pad)
{
    Lstr    tmp;

    LINITSTR(tmp);

    L2STR(newstr);
    L2STR(target);

    if (n<0) n = 0;

    if (length==0) {
        Lstrcpy(to,target);
        return;
    }

    if (length<0) length = LLEN(*newstr);

    if (n>=1)
        Lsubstr(to,target,1,n,pad);
    else
        LZEROSTR(*to);

    Lsubstr(&tmp,newstr,1,length,pad);
    Lstrcat(to,&tmp);
    if (n <= LLEN(*target)) {
        _Lsubstr(&tmp, target, (size_t)n+1, 0);
        Lstrcat(to,&tmp);
    }

    LFREESTR(tmp);
} /* Linsert */
