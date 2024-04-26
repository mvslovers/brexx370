/*
 * $Id: translat.c,v 1.5 2008/07/15 07:40:54 bnv Exp $
 * $Log: translat.c,v $
 * Revision 1.5  2008/07/15 07:40:54  bnv
 * #include changed from <> to ""
 *
 * Revision 1.4  2002/06/11 12:37:15  bnv
 * Added: CDECL
 *
 * Revision 1.3  2001/06/25 18:49:48  bnv
 * Header changed to Id
 *
 * Revision 1.2  1999/03/01 11:07:22  bnv
 * Added '{..}' to avoid nesting if () {} else {} errors.
 *
 * Revision 1.1  1998/07/02 17:18:00  bnv
 * Initial Version
 *
 */

#include "lstring.h"

/* ---------------- Ltranslate ------------------- */
void __CDECL
Ltranslate( const PLstr to, const PLstr from,
    const PLstr tableout, const PLstr tablein, const char pad )
{
    char     table[256];
    int      i;

    Lstrcpy(to,from);    L2STR(to);

    for (i=0; i<256; i++)
        table[i] = i;

    if (tableout)    L2STR(tableout);
    if (tablein)    L2STR(tablein);

    if (tablein) {
        for (i=LLEN(*tablein)-1; i>=0; i--)
            if (tableout) {
                if (i>=LLEN(*tableout))
                    table[(byte)LSTR(*tablein)[i]]=pad;
                else
                    table[(byte)LSTR(*tablein)[i]]=LSTR(*tableout)[i];
            } else
                table[(byte)LSTR(*tablein)[i]] = pad;
    } else {
        for (i=0; i<256; i++)
            if (tableout) {
                if (i >= LLEN(*tableout))
                    table[i] = pad;
                else
                    table[i] = LSTR(*tableout)[i];
            }
    }

    for (i=0; i<LLEN(*to); i++)
        LSTR(*to)[i] = table[ (byte) LSTR(*to)[i] ];
} /* Ltranslate */
