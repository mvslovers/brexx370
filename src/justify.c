/*
 * $Id: justify.c,v 1.5 2008/07/15 07:40:54 bnv Exp $
 * $Log: justify.c,v $
 * Revision 1.5  2008/07/15 07:40:54  bnv
 * #include changed from <> to ""
 *
 * Revision 1.4  2004/08/16 15:25:37  bnv
 * float to double
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

#include "lstring.h"

/* ----------------- Ljustify ------------------ */
void __CDECL
Ljustify( const PLstr to, const PLstr from, long length, char pad )
{
    int    spaces, ins, extra;
    int    p,lp,i;
    double    r,rstep;
    char    padstr[2];
    Lstr    tmp,sub,space;

    L2STR(from);
    LZEROSTR(*to);
    if (length<=0) return;

    LINITSTR(tmp);
    LINITSTR(sub);
    LINITSTR(space);

    Lspace(&tmp,from,1,' ');
    if (LLEN(tmp)==0) {        /* Null string */
        Lstrset(to,length,pad);
        goto fin;
    }

    if (LLEN(tmp) > length) {
        LLEN(tmp) = length;
        Lstrcpy(to,&tmp);
        if (pad != ' ')
            for (p=0; p<length; p++)
                if (LSTR(*to)[p]==' ')
                    LSTR(*to)[p] = pad;
        goto fin;
/****** If we don't to destroy the words
        if (LSTR(tmp)[length] != ' ') {
            for (p=length-1; p>0; p--)
                if (LSTR(tmp)[p] == ' ') break;
            if (!p) goto fin;
            LLEN(tmp) = p;
        }
******/
    }

    for (p=spaces=0; p<LLEN(tmp); p++)    /* count spaces */
        if (LSTR(tmp)[p] == ' ') spaces++;

    if (!spaces) {        /* Ooops seulement un mot */
        Lleft(to,&tmp,length,pad);
        goto fin;
    }
    padstr[0] = pad;
    padstr[1] = 0;

    ins = length - (LLEN(tmp) - spaces);
    extra = ins%spaces;
    rstep = (double)(spaces+1)/(double)(extra+1);
    ins /= spaces;

    Lstrset(&space,ins,pad);

    for (r=rstep,p=0,i=1;;i++) {
        lp = p;
        LSKIPWORD(tmp,p);
        _Lsubstr(&sub,&tmp,lp+1,p-lp);
        Lstrcat(to,&sub);
        if (p>=LLEN(tmp)) break;
        Lstrcat(to,&space);
        if (extra && (int)r<=i) {
            Lcat(to,padstr);
            extra--;
            r += rstep;
        }
        LSKIPBLANKS(tmp,p);
    }
fin:
    LFREESTR(tmp);
    LFREESTR(sub);
    LFREESTR(space);
} /* Ljustify */
