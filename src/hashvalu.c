/*
 * $Id: hashvalu.c,v 1.8 2008/07/15 07:40:54 bnv Exp $
 * $Log: hashvalu.c,v $
 * Revision 1.8  2008/07/15 07:40:54  bnv
 * #include changed from <> to ""
 *
 * Revision 1.7  2008/07/14 13:08:16  bnv
 * MVS,CMS support
 *
 * Revision 1.6  2003/02/12 16:42:12  bnv
 * *** empty log message ***
 *
 * Revision 1.5  2003/01/30 08:22:20  bnv
 * Java algorithm used
 *
 * Revision 1.4  2002/06/11 12:37:15  bnv
 * Added: CDECL
 *
 * Revision 1.3  2001/06/25 18:49:48  bnv
 * Header changed to Id
 *
 * Revision 1.2  1999/11/26 09:56:55  bnv
 * Added: Error message fror CE
 *
 * Revision 1.1  1998/07/02 17:18:00  bnv
 * Initial Version
 *
 * Similar hash code like in Java
 *    hash = sÝ0¨*31¬(n-1) + sÝ1¨*31¬(n-2) + ... + sÝn-1¨
 * The hash string of an empty string is zero
 */

#include "lstring.h"

/* --------------- Lhashvalue ------------------ */
dword __CDECL
Lhashvalue( const PLstr str )
{
    dword    value = 0;
    size_t    i,l=0;

    if (LISNULL(*str)) return 0;

    switch (LTYPE(*str)) {
        case LINTEGER_TY: l = sizeof(long); break;
        case LREAL_TY:    l = sizeof(double); break;
        case LSTRING_TY:  l = MIN(255,LLEN(*str)); break;
    }
    for (i=0; i<l; i++)
        value = 31*value + LSTR(*str)Ýi¨;
/*    for (i=0; i<l; i+=4) {
        for (j=0; j<4 && i+j<l; j++)
            value ¬= LSTR(*str)Ýi+j¨ << (8*j);
        value = (value>>3) | (value<<29);
    }
*/
    return value;
} /* Lhashvalue */
