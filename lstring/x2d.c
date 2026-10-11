/*
 * $Id: x2d.c,v 1.4 2008/07/15 07:40:54 bnv Exp $
 * $Log: x2d.c,v $
 * Revision 1.4  2008/07/15 07:40:54  bnv
 * #include changed from <> to ""
 *
 * Revision 1.3  2002/06/11 12:37:15  bnv
 * Added: CDECL
 *
 * Revision 1.2  2001/06/25 18:49:48  bnv
 * Header changed to Id
 *
 * Revision 1.1  1998/07/02 17:20:58  bnv
 * Initial Version
 *
 */

#include "lstring.h"

/* ------------------ Lx2d ------------------- */
/* n < 0: no length given; n == 0 gives 0, as the standard says (#192) */
void __CDECL
Lx2d( const PLstr to, const PLstr from, long n )
{
	Lstr	tmp, dig;

	if (n==0) {
		Licpy(to,0);
		return;
	}
	LINITSTR(tmp);
	if (n<0) {
		Lx2c(&tmp,from);
		Lc2d(to,&tmp,-1);  // -1 means there was no 2. parameter set, will be reset to null
		LFREESTR(tmp);
		return;
	}
	LINITSTR(dig);
	Lspace(&tmp,from,0,' ');
	L2STR(&tmp);	/* Lspace copies a number as it is, LLEN would be its size */
	/* the digits left of the string are '0', one of them shows the sign */
	if ((size_t) n > LLEN(tmp)) n = LLEN(tmp)+1;
	Lright(&dig,&tmp,n,'0');
	/* extend the sign to whole bytes and let Lc2d take them as signed:
	 * it refuses a value that does not fit a long, where the digits
	 * left of the rightmost eight used to be dropped (#192) */
	if (n&1)
		Lright(&tmp,&dig,n+1,(HEXVAL(LSTR(dig)[0]) & 0x8) ? 'F' : '0');
	else
		Lstrcpy(&tmp,&dig);
	Lx2c(&dig,&tmp);
	Lc2d(to,&dig,(n+1)/2);
	LFREESTR(dig);
	LFREESTR(tmp);
} /* Lx2d */
