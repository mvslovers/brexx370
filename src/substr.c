/*
 * $Id: substr.c,v 1.4 2008/07/15 07:40:54 bnv Exp $
 * $Log: substr.c,v $
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

/* --------------------------- Lsubstr -------------------------------- */
/*    to       - Output Lstr                                            *
 *   from      - Input Lstr                                             *
 *   start     - an integer, can take values from Ý1,from length¨       *
 *               if start<1 then start = 1                              *
 *   length    - negative value means rest of string (default)          *
 *               Ý1 - nnn¨ cuts string and pad's it if necessary.       *
 *    pad      - pad character                                          *
 * -------------------------------------------------------------------- */
void __CDECL
Lsubstr(const PLstr to, const PLstr from,
    long start, long length, const char pad )
{
    size_t    l;

    L2STR(from);

    start--;
    if (start<0) start = 0;

    if (length<=0) {
        if (length==0 || start>=LLEN(*from)) {
            LZEROSTR(*to);
            return;
        }
        length = LLEN(*from) - start;
    }

    Lfx(to,(size_t)length);

    if (start<LLEN(*from)) {
        if (length+start>LLEN(*from)) {
            l = LLEN(*from) - (size_t)start;
            MEMMOVE( LSTR(*to), LSTR(*from)+start, l);
            MEMSET( LSTR(*to)+l, pad, (size_t)length-l);
        } else
            MEMMOVE( LSTR(*to), LSTR(*from)+start, (size_t)length);
    } else
        MEMSET(LSTR(*to),pad,(size_t)length);

    LTYPE(*to) = LSTRING_TY;
    LLEN(*to) = (size_t)length;
} /* Lstrsub */
