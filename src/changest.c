/*
 * $Id: changest.c,v 1.6 2008/07/15 07:40:54 bnv Exp $
 * $Log: changest.c,v $
 * Revision 1.6  2008/07/15 07:40:54  bnv
 * #include changed from <> to ""
 *
 * Revision 1.5  2002/06/11 12:37:15  bnv
 * Added: CDECL
 *
 * Revision 1.4  2001/06/25 18:49:48  bnv
 * Header changed to Id
 *
 * Revision 1.3  2000/09/28 15:52:19  bnv
 * Corrected a bug if the input string had repeated targets.
 *
 * Revision 1.2  2000/02/07 11:21:35  bnv
 * Corrected: The case where the old string has length equal to ZERO.
 *
 * Revision 1.1  1998/07/02 17:17:00  bnv
 * Initial revision
 *
 */

#include "lstring.h"

/* ----------------- Lchagestr ------------------- */
void __CDECL
Lchangestr( const PLstr to, const PLstr oldstr,
    const PLstr str, const PLstr newstr)
{
    size_t    pos, foundpos;
    Lstr    tmp;

    if (LLEN(*oldstr)==0) {
        Lstrcpy(to,str);
        return;
    }

    Lfx(to,LLEN(*str));
    LZEROSTR(*to);

    LINITSTR(tmp);

    pos = 1;
    for (;;) {
        foundpos = Lindex(str,oldstr,pos);
        if (foundpos==0) break;
        if (foundpos!=pos) {
            _Lsubstr(&tmp,str,pos,foundpos-pos);
            Lstrcat(to,&tmp);
        }
        Lstrcat(to,newstr);
        pos = foundpos + LLEN(*oldstr);
    }
    _Lsubstr(&tmp,str,pos,0);
    Lstrcat(to,&tmp);
    LFREESTR(tmp);
} /* Lchagestr */
