/*
 * $Id: strip.c,v 1.5 2008/07/15 07:40:54 bnv Exp $
 * $Log: strip.c,v $
 * Revision 1.5  2008/07/15 07:40:54  bnv
 * #include changed from <> to ""
 *
 * Revision 1.4  2002/06/11 12:37:15  bnv
 * Added: CDECL
 *
 * Revision 1.3  2001/06/25 18:49:48  bnv
 * Header changed to Id
 *
 * Revision 1.2  1998/11/06 08:54:58  bnv
 * Corrected: When length=0
 *
 * Revision 1.1  1998/07/02 17:18:00  bnv
 * Initial Version
 *
 */

#include <string.h>
#include "lstring.h"

/* --------------- Lstrip ------------------ */
void __CDECL
Lstrip( const PLstr to, const PLstr str, const char action, const char pad)
{
    char    *cf, *cl;
    size_t    l;

    if (LTYPE(*str)!=LSTRING_TY) {
        Lstrcpy(to,str);
        return;
    }

    l = LLEN(*str);
    if (!l) {
        LZEROSTR(*to);
        return;
    }

    cf = LSTR(*str);
    if (action==LBOTH || action==LLEADING) {
        while (l && (*cf==pad)) { cf++; l--; }
        if (!l) {
            LZEROSTR(*to);
            return;
    }    }

    l = LLEN(*str);
    cl = LSTR(*str)+ l - 1;
    if (action==LBOTH || action==LTRAILING) {
        while (l && (*cl==pad)) {cl--; l--; }
        if (!l) {
            LZEROSTR(*to);
            return;
    }    }

    l = (int)( (long)(char huge *)cl - (long)(char huge *)cf + 1);

    if (l<LLEN(*str)) {
        Lfx(to,l);
        MEMMOVE(LSTR(*to),cf,l);
        LLEN(*to) = l;
        LTYPE(*to) = LSTRING_TY;
    } else
        Lstrcpy(to,str);
} /* Lstrip */
