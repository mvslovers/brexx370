/*
 * $Id: x2b.c,v 1.7 2009/06/02 09:40:53 bnv Exp $
 * $Log: x2b.c,v $
 * Revision 1.7  2009/06/02 09:40:53  bnv
 * MVS/CMS corrections
 *
 * Revision 1.6  2008/07/15 07:40:54  bnv
 * #include changed from <> to ""
 *
 * Revision 1.5  2008/07/14 13:08:16  bnv
 * MVS,CMS support
 *
 * Revision 1.4  2002/06/11 12:37:15  bnv
 * Added: CDECL
 *
 * Revision 1.3  2001/06/25 18:49:48  bnv
 * Header changed to Id
 *
 * Revision 1.2  1999/11/26 12:52:25  bnv
 * Changed: To use the new macros
 *
 * Revision 1.1  1998/07/02 17:20:58  bnv
 * Initial Version
 *
 */

#include <ctype.h>
#include "lerror.h"
#include "lstring.h"

/* ------------------- Lx2b ------------------- */
void __CDECL
Lx2b( const PLstr to, const PLstr from )
{
    long    i;
    int    k;
    char    *c,d;

    L2STR(from);
    Lfx(to,4*LLEN(*from));
    c = LSTR(*to);

    for (i=0; i<LLEN(*from); i++) {
        if (ISSPACE(LSTR(*from)[i])) continue;
        if (!ISXDIGIT(LSTR(*from)[i]))
            Lerror(ERR_INVALID_HEX_CONST,0);

        d = HEXVAL(LSTR(*from)[i]);
        for (k=8; k; k>>=1)
#ifndef __CMS__
            *c++ = (d&k)? '1' : '0';
#else
            if (d&k)
                *c++ = '1';
            else
                *c++ = '0';
#endif
    }
    *c = 0;
    LLEN(*to) = STRLEN(LSTR(*to));
    LTYPE(*to) = LSTRING_TY;
} /* Lx2b */
