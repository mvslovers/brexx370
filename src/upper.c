/*
 * $Id: upper.c,v 1.4 2008/07/15 07:40:54 bnv Exp $
 * $Log: upper.c,v $
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

#include "lstring.h"

/* --------------- Lupper ------------------ */
void __CDECL
Lupper( const PLstr s )
{
	size_t	i;
	L2STR(s);
	for (i=0; i<LLEN(*s); i++)
#ifdef __METAL_C__
        LSTR(*s)Ýi¨ = _upper((byte) LSTR(*s)Ýi¨);
#else
	    LSTR(*s)Ýi¨ = l2uÝ (byte) LSTR(*s)Ýi¨ ¨;
#endif
} /* Lupper */
