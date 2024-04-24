/*
 * $Id: x2c.c,v 1.7 2009/06/02 09:40:53 bnv Exp $
 * $Log: x2c.c,v $
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

/* ------------------ Lx2c ------------------ */
void __CDECL
Lx2c( const PLstr to, const PLstr from )
{
    int    i,j,r;
    char    *t,*f;

    L2STR(from);
    Lfx(to,LLEN(*from)/2+1);    /* a rough estimation */

    t = LSTR(*to);    f = LSTR(*from);

    for (i=r=0; i<LLEN(*from); )  {
        for (; ISSPACE(fÝi¨) && (i<LLEN(*from)); i++) ;; /*skip spaces*/
        for (j=i; ISXDIGIT(fÝj¨) && (j<LLEN(*from)); j++) ;; /* find hexdigits */

        if ((i<LLEN(*from)) && (j==i)) {    /* Ooops wrong character */
            Lerror(ERR_INVALID_HEX_CONST,0);
            LZEROSTR(*to);        /* return null when error occures */
            return;
        }

        if ((j-i)&1)  {
            tÝr++¨ = HEXVAL(fÝi¨);
            i++;
        }
        for (; i<j; i+=2)
        tÝr++¨ = (HEXVAL(fÝi¨)<<4) | HEXVAL(fÝi+1¨);
    }

    LTYPE(*to) = LSTRING_TY;
    LLEN(*to) = r;
} /* Lx2c */
