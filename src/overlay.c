/*
 * $Id: overlay.c,v 1.4 2008/07/15 07:40:54 bnv Exp $
 * $Log: overlay.c,v $
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

#include <string.h>
#include "lstring.h"

/* ------------------ Loverlay ---------------- */
void __CDECL
Loverlay( const PLstr to, const PLstr newstr, const PLstr target,
    long n, long length, const char pad)
{
    Lstr    tmp;

    L2STR(newstr);
    L2STR(target);

    n--;
    if (n<0) n = 0;
    if (length==0) {
        Lstrcpy(to,target);
        return;
    }
    if (length<0) length = LLEN(*newstr);

    if (n+length > LLEN(*target))
        Lsubstr(to,target,1,n+length,pad);
    else
        Lstrcpy(to,target);

    LINITSTR(tmp);
    Lsubstr(&tmp,newstr,1,length,pad);

    MEMCPY( LSTR(*to)+n, LSTR(tmp), (size_t)length);
    LFREESTR(tmp);
} /* Loverlay */
