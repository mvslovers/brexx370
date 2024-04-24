/*
 * $Id: dec.c,v 1.4 2008/07/15 07:40:54 bnv Exp $
 * $Log: dec.c,v $
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

/* ------------------- Ldec ------------------ */
void __CDECL
Ldec( const PLstr num )
{
    L2NUM(num);

    if (LTYPE(*num)==LINTEGER_TY)
        LINT(*num) -= 1;
    else
        LREAL(*num) -= 1.0;
} /* Ldec */
