/*
 * $Id: b2x.c,v 1.6 2011/06/29 08:33:09 bnv Exp $
 * $Log: b2x.c,v $
 * Revision 1.6  2011/06/29 08:33:09  bnv
 * char to unsigned
 *
 * Revision 1.5  2008/07/15 07:40:54  bnv
 * #include changed from <> to ""
 *
 * Revision 1.4  2002/06/11 12:37:15  bnv
 * Added: CDECL
 *
 * Revision 1.3  2001/06/25 18:49:48  bnv
 * Header changed to Id
 *
 * Revision 1.2  1999/11/26 09:51:19  bnv
 * Changed: To use the new macros.
 *
 * Revision 1.1  1998/07/02 17:16:35  bnv
 * Initial revision
 *
 */

#include "lerror.h"
#include "lstring.h"

/* ------------------- Lb2x ------------------- */
void __CDECL
Lb2x( const PLstr to, const PLstr from )
{
    long    i;
    int    j,k;
    unsigned char    *c;

    Lstrcpy(to,from);
    Lreverse(to);
    c = LSTR(*to);

    for (i=j=k=0; i<LLEN(*to); i++) {
        if (ISSPACE(LSTR(*to)[i])) continue;
        if (LSTR(*to)[i]<'0' || LSTR(*to)[i]>'1')
            Lerror(ERR_INVALID_HEX_CONST,0);

        j |= ((LSTR(*to)[i]=='1')&1) << k;
        if (++k==4) {
            *c++ = chex[j];
            j=k=0;
        }
    }
    if (k) *c++ = chex[j];
    *c = 0;
    LLEN(*to) = STRLEN(LSTR(*to));
    LTYPE(*to) = LSTRING_TY;
    Lreverse(to);
} /* Lb2x */
