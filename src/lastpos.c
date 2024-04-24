/*
 * $Id: lastpos.c,v 1.4 2008/07/15 07:40:54 bnv Exp $
 * $Log: lastpos.c,v $
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

/* ---------------- Llastpos --------------- */
long __CDECL
Llastpos( const PLstr needle, const PLstr haystack, long p)
{
    Lstr    N;
    Lstr    H;

    L2STR(needle);
    L2STR(haystack);

    if (p<0 || p>=LLEN(*haystack)) p = LLEN(*haystack);

    if (!LLEN(*needle)) {
        if (LLEN(*haystack))
            return (p>0)?p:1;
        else
            return LNOTFOUND;
    }

    LINITSTR(N);    Lstrcpy(&N,needle);
    LINITSTR(H);    Lstrcpy(&H,haystack);

    Lreverse(&N);
    Lreverse(&H);

    if (p>0) p = LLEN(H) - p + 1;

    p = Lindex(&H, &N, p);
    if (p!=LNOTFOUND)  p = LLEN(H)-(p+LLEN(N))+2;

    LFREESTR(N);
    LFREESTR(H);

    return p;
} /* Llastpos */
