/*
 * $Id: verify.c,v 1.5 2008/07/15 07:40:54 bnv Exp $
 * $Log: verify.c,v $
 * Revision 1.5  2008/07/15 07:40:54  bnv
 * #include changed from <> to ""
 *
 * Revision 1.4  2004/08/16 15:26:40  bnv
 * Spaces...
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

#include <string.h>
#include "lstring.h"

/* --------------------- Lverify  ----------------------- *
 *  str      -  string that we check every char           *
 *        if it exists on 'ref'                     *
 *  ref      -  reference characters                      *
 *  match    -  FALSE = find non matching chars           *
 *        TRUE  = find only matching chars          *
 *  start    -    starting position [1,len]                 *
 * returns                                                *
 *    0        if every char is found (or not found)     *
 *        according to match                        *
 *   pos    else non matching (or matching) position  *
 * ------------------------------------------------------ */
long __CDECL
Lverify( const PLstr str, const PLstr ref, const bool match, long start )
{
    bool    found;

    L2STR(str);
    L2STR(ref);

    start--;
    if (start<0) start = 0;
    if (start >= LLEN(*str)) return LNOTFOUND;

    for (; start<LLEN(*str); start++) {
        found = (MEMCHR(LSTR(*ref), LSTR(*str)[start], LLEN(*ref))==NULL);
        if (found ¬ match) return start+1;
    }
    return LNOTFOUND;
} /* Lverify */
