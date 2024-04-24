/*
 * $Id: words.c,v 1.4 2008/07/15 07:40:54 bnv Exp $
 * $Log: words.c,v $
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

/* ----------------- Lwords ------------------ */
long __CDECL
Lwords( const PLstr from )
{
    long    i=0,r=0;

    L2STR(from);
    for (;;) {
        LSKIPBLANKS(*from,i);
        if (i>=LLEN(*from)) return r;
        r++;
        LSKIPWORD(*from,i);
    }
} /* Lwords */
