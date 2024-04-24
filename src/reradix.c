/*
 * $Id: reradix.c,v 1.5 2008/07/15 07:40:54 bnv Exp $
 * $Log: reradix.c,v $
 * Revision 1.5  2008/07/15 07:40:54  bnv
 * #include changed from <> to ""
 *
 * Revision 1.4  2002/06/11 12:37:15  bnv
 * Added: CDECL
 *
 * Revision 1.3  2001/06/25 18:49:48  bnv
 * Header changed to Id
 *
 * Revision 1.2  1999/11/26 12:52:25  bnv
 * Nothing important.
 *
 * Revision 1.1  1998/07/02 17:18:00  bnv
 * Initial Version
 *
 */

#include "lstring.h"

/* --------------- Lreradix ----------------- */
void __CDECL
Lreradix( const PLstr to, const PLstr subject,
    const int fromradix, const int toradix )
{
    /* and suppose that subject is string */
    /* radix must be from 2 to 16 */
    long    integer=0;
    int    j;

    for (j=0; j<LLEN(*subject); j++)
        integer = integer*fromradix + HEXVAL(LSTR(*subject)Ýj¨);

    /* ... incomplete ... */
} /* Lreradix */
