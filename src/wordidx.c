/*
 * $Id: wordidx.c,v 1.4 2008/07/15 07:40:54 bnv Exp $
 * $Log: wordidx.c,v $
 * Revision 1.4  2008/07/15 07:40:54  bnv
 * #include changed from <> to ""
 *
 * Revision 1.3  2002/06/11 12:37:15  bnv
 * Added: CDECL
 *
 * Revision 1.2  2001/06/25 18:49:48  bnv
 * Header changed to Id
 *
 * Revision 1.1  1998/07/02 17:20:58  bnv
 * Initial Version
 *
 */

#include "lstring.h"

/* ----------------- Lwordindex ---------------- */
long __CDECL
Lwordindex( const PLstr str, long n )
{
    long    p;

    L2STR(str);

    if ((LLEN(*str)==0) || (n<=0))  return 0;
    for (p=0;;) {
        LSKIPBLANKS(*str,p);
        if (p>=LLEN(*str)) return 0;
        n--;
        if (!n) return p+1;
        LSKIPWORD(*str,p);
    }
} /* Lwordindex */
