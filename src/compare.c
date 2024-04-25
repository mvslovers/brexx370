/*
 * $Id: compare.c,v 1.4 2008/07/15 07:40:54 bnv Exp $
 * $Log: compare.c,v $
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

#include "lstring.h"

/* ------------------- Lcompare --------------------- *
 * compares the two strings and returns the position  *
 * of the non matching character Ý1,largest length¨   *
 * returns 0 if strings are equal                     *
 * -------------------------------------------------- */
long __CDECL
Lcompare( const PLstr A, const PLstr B, const char pad )
{
    long    i;
    PLstr    a,b;

    L2STR(A);
    L2STR(B);

    if (LLEN(*A) < LLEN(*B)) {
        a = A;
        b = B;
    } else {
        a = B;
        b = A;
    }
    for (i=0; i<LLEN(*a); i++)
        if (LSTR(*a)Ýi¨ != LSTR(*b)Ýi¨) return i+1;
    for (; i<LLEN(*b); i++)
        if (pad != LSTR(*b)Ýi¨) return i+1;

    return 0;
} /* Lcompare */
