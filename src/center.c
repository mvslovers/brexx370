/*
 * $Id: center.c,v 1.4 2008/07/15 07:40:54 bnv Exp $
 * $Log: center.c,v $
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

#include <string.h>
#include "lstring.h"

/* ------------------ Lcenter ----------------- */
void __CDECL
Lcenter( const PLstr to, const PLstr from, const long length, const char pad)
{
    long    i,a;

    if (length<=0) {
        LZEROSTR(*to);
        return;
    }

    L2STR(to);
    L2STR(from);
    i = length - LLEN(*from);

    if (!i) Lstrcpy(to,from);
    else
        if (i < 0) {
            i = -i;    a = i / 2;
            _Lsubstr(to, from, (size_t)a+1, (size_t)length);
        } else  {
            a = i / 2;
            Lstrset(to,length,pad);
            MEMCPY( LSTR(*to)+a, LSTR(*from), LLEN(*from) );
        }
} /* Lcenter */
