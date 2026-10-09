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

#include "lerror.h"
#include "lstring.h"

/* ------------------- Lc2d ------------------------- */
void __CDECL
Lc2d( const PLstr to, const PLstr from, long n )
{
	int	i;
	bool	negative;
	long	num;
	long	want = n;		/* n as given, -1 if omitted */
	size_t	lim;
	byte	fill;

	L2STR(from);


	if (!LLEN(*from) || n==0) {
		Licpy(to,0);
		return;
	}

	if (n<1 || (size_t) n > sizeof(long)) n = sizeof(long);

	Lstrcpy(to,from);
	Lreverse(to);

	if ((size_t) n <= LLEN(*to) )
		negative = LSTR(*to)[n-1] & 0x80;  /* msb = 1 */
	else
		negative = FALSE;

	/* the bytes left of the four that fit a long were dropped, so
	 * c2d('0100000000'x) gave 0 (#386); they may only extend the sign */
	lim = (want < 1 || (size_t) want > LLEN(*to)) ? LLEN(*to) : (size_t) want;
	fill = (want >= 1 && negative) ? 0xFF : 0x00;
	for (i = sizeof(long); (size_t) i < lim; i++)
		if ((byte) LSTR(*to)[i] != fill) Lerror(ERR_INCORRECT_CALL, 0);

	n = MIN(n,(long) LLEN(*from));
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
