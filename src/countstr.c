/*
 * $Id: countstr.c,v 1.4 2008/07/15 07:40:54 bnv Exp $
 * $Log: countstr.c,v $
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

/* ----------------- Lcountstr ------------------- *
 * Counts the appearances of the first string 'target'
 * in the second argument 'source'
 */
long __CDECL
Lcountstr( const PLstr target, const PLstr source )
{
    long    output=0, position;

    position = Lpos(target,source,0);
    while (position>0) {
        output++;
        position = Lpos(target,source,position+LLEN(*target));
    }
    return output;
} /* Lcountstr */
