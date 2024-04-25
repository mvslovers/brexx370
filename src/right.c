/*
 * $Id: right.c,v 1.4 2008/07/15 07:40:54 bnv Exp $
 * $Log: right.c,v $
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

/* ------------------ Lright ------------------- */
void __CDECL
Lright( const PLstr to, const PLstr from, const long length, const char pad)
{
    L2STR(from);

    if (length<=0) {
        LZEROSTR(*to);
        return;
    }

    if (length > LLEN(*from)) {
        Lstrset(to, length-LLEN(*from), pad );
        Lstrcat(to, from);
    } else
        Lsubstr(to, from, LLEN(*from)-length+1,LREST,pad);
} /* Lright */
