/*
 * $Id: bitand.c,v 1.4 2008/07/15 07:40:54 bnv Exp $
 * $Log: bitand.c,v $
 * Revision 1.4  2008/07/15 07:40:54  bnv
 * #include changed from <> to ""
 *
 * Revision 1.3  2002/06/11 12:37:15  bnv
 * Added: CDECL
 *
 * Revision 1.2  2001/06/25 18:49:48  bnv
 * Header changed to Id
 *
 * Revision 1.1  1998/07/02 17:16:35  bnv
 * Initial revision
 *
 */

#include "lstring.h"

/* ---------------- Lbitand ------------------ */
void __CDECL
Lbitand( const PLstr to, const PLstr s1, const PLstr s2,
    const bool usepad, const char pad )
{
    long    i;

    L2STR(s1);
    L2STR(s2);

    if (LLEN(*s1) < LLEN(*s2)) {
        Lstrcpy(to,s2);
        for (i=0; i<LLEN(*s1); i++)
            LSTR(*to)[i] = LSTR(*s1)[i] & LSTR(*s2)[i];

        if (usepad)
            for (; i<LLEN(*s2); i++)
                LSTR(*to)[i] = LSTR(*s2)[i] & pad;
    } else {
        Lstrcpy(to,s1);

        for (i=0; i<LLEN(*s2); i++)
            LSTR(*to)[i] = LSTR(*s1)[i] & LSTR(*s2)[i];

        if (usepad)
            for (; i<LLEN(*s1); i++)
                LSTR(*to)[i] = LSTR(*s1)[i] & pad;
    }
} /* Lbitand */
