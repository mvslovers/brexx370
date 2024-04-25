/*
 * $Id: index.c,v 1.4 2008/07/15 07:40:54 bnv Exp $
 * $Log: index.c,v $
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

#include "lstring.h"

/* ----------------- Lindex ---------------------- */
/* haystack   - Lstr where to search               *
 *  needle    - Lstr to search                     *
 *    p       - starting position Ý1,haystack len¨ *
 *              if p < 1 then p = 1                *
 * returns  0 (NOTFOUND) is needle is not found    *
 * else returns position Ý1,haystack len¨          *
 * ----------------------------------------------- */
long __CDECL
Lindex( const PLstr haystack, const PLstr needle, long p)
{
    long    n,lp;

    p--;        /* for C string offset = 0, Rexx=1 */
    if (p<0) p = 0;

    L2STR(haystack);
    L2STR(needle);

    if (!LLEN(*needle)) {
        if (!LLEN(*haystack)) return LNOTFOUND;
        return p+1;
    }
    if (LLEN(*needle) > LLEN(*haystack)) return LNOTFOUND;
    lp = p-1;
    do {
        n = 0; p = lp+1;
        if (p >= LLEN(*haystack)) return LNOTFOUND;
        while (LSTR(*haystack)Ýp¨ != LSTR(*needle)Ý0¨) {
            p++;
            if (p >= LLEN(*haystack)) return LNOTFOUND;
        }
        lp = p;
        while ( (LSTR(*haystack)Ýp¨==LSTR(*needle)Ýn¨) && (n<LLEN(*needle))) {
            if ((++n) >= LLEN(*needle)) return lp+1;
            p++;
            if (p >= LLEN(*haystack)) return LNOTFOUND;
        }
    } while (n<LLEN(*needle));
    return lp+1;
} /* Lindex */
