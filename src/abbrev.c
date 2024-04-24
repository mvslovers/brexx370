/*
 * $Id: abbrev.c,v 1.5 2008/07/15 07:40:54 bnv Exp $
 * $Log: abbrev.c,v $
 * Revision 1.5  2008/07/15 07:40:54  bnv
 * #include changed from <> to ""
 *
 * Revision 1.4  2008/07/14 13:07:53  bnv
 * Bug correction
 *
 * Revision 1.3  2002/06/11 12:37:15  bnv
 * Added: CDECL
 *
 * Revision 1.2  2001/06/25 18:49:48  bnv
 * Header changed to Id
 *
 * Revision 1.1  1998/07/02 17:16:15  bnv
 * Initial revision
 *
 */

#include "lstring.h"

/* ------------------- Labbrev -------------------- */
bool __CDECL
Labbrev(const PLstr information, const PLstr info, long length)
{
        int     cond1, cond2, cond3;

    if (length<=0) length = LLEN(*info);

        cond1 = (LLEN(*information) >= LLEN(*info));
        cond2 = (LLEN(*info) >= length);
        cond3 = !memcmp(LSTR(*information), LSTR(*info), LLEN(*info));
        return cond1 && cond2 && cond3;
} /* Labbrev */
