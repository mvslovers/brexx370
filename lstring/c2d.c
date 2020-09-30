/*
 * $Id: c2d.c,v 1.4 2008/07/15 07:40:54 bnv Exp $
 * $Log: c2d.c,v $
 * Revision 1.4  2008/07/15 07:40:54  bnv
 * #include changed from <> to ""
 *
 * Revision 1.3  2002/06/11 12:37:15  bnv
 * Added: CDECL
 *
 * Revision 1.2  2001/06/25 18:49:48  bnv
 * Header changed to Id
 *
 * Revision 1.1  1998/07/02 17:16:35  bnv
 * Initial revision
 *
 */

#include "lstring.h"

/* ------------------- Lc2d ------------------------- */
void __CDECL
Lc2d( const PLstr to, const PLstr from, long n )
{
	int	i;
	bool	negative;
	long	num;

	L2STR(from);


	if (!LLEN(*from) || n==0) {
		Licpy(to,0);
		return;
	}

	if (n<1 || n>sizeof(long)) n = sizeof(long);

	Lstrcpy(to,from);
	Lreverse(to);

	if (n <= LLEN(*to) )
		negative = LSTR(*to)[n-1] & 0x80;  /* msb = 1 */
	else
		negative = FALSE;

	n = MIN(n,LLEN(*from));
	num = 0;
	for (i=n-1; i>=0; i--)
		num = (num << 8) | ((byte)(LSTR(*to)[i]) & 0xFF);
	if (negative) {
		if (n==sizeof(long))
			num = -(~num + 1);
		else
			num = num - (1L << (n*8));
	}
	Licpy(to,num);
} /* Lc2d */
