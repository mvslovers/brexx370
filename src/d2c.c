/*
 * $Id: d2c.c,v 1.5 2008/07/15 07:40:54 bnv Exp $
 * $Log: d2c.c,v $
 * Revision 1.5  2008/07/15 07:40:54  bnv
 * #include changed from <> to ""
 *
 * Revision 1.4  2008/07/14 13:08:16  bnv
 * MVS,CMS support
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

#include "lstring.h"

/* -------------------- Ld2c -------------------- */
void __CDECL
Ld2c( const PLstr to, const PLstr from, long n )
{
    int   i;
    long  num,n2;
    bool  negative;

    num = Lrdint(from);

    if (n==0) {
        LZEROSTR(*to);
        return;
    }
    if (n<0) n=0;

    negative = (num<0);
    if (negative)
        num = -num-1;

    if (n>sizeof(long)) n=sizeof(long);
    Lfx(to,(size_t)n);

    n2 = n? n: sizeof(long);
    for (i=0; num && i<n2; i++) {
        LSTR(*to)Ýi¨ = (char)(num & 0xFF);
        if (negative)
            LSTR(*to)Ýi¨ ¬= 0xFF;
        num >>= 8;
    }
    if (i==0) {
        LSTR(*to)Ýi¨ = 0x00;
        if (negative)
            LSTR(*to)Ýi¨ ¬= 0xFF;
        i++;
    }

    while (i<n) {
        LSTR(*to)Ýi¨ = negative? 0xFF : 0x00;
        i++;
    }

    LTYPE(*to) = LSTRING_TY;
    LLEN(*to) = i;
    Lreverse(to);
} /* Ld2c */
