/*
 * $Id: expose.c,v 1.5 2008/07/15 07:40:54 bnv Exp $
 * $Log: expose.c,v $
 * Revision 1.5  2008/07/15 07:40:54  bnv
 * #include changed from <> to ""
 *
 * Revision 1.4  2002/06/11 12:37:15  bnv
 * Added: CDECL
 *
 * Revision 1.3  2001/06/25 18:49:48  bnv
 * Header changed to Id
 *
 * Revision 1.2  1999/11/26 09:56:55  bnv
 * Changed: Formatting
 *
 * Revision 1.1  1998/07/02 17:18:00  bnv
 * Initial Version
 *
 */

#include "lerror.h"
#include "lstring.h"

/* -----------------  expose ---------------- */
void __CDECL
Lexpose( const PLstr to, const PLstr A, const PLstr B )
{
	double ar,r;
	long   bi;
	bool   minusA;
	bool   minusB;

	ar = Lrdreal(A);
	bi = Lrdint(B);

	if (ar < 0 ) {
		if (ODD(bi))
			minusA = TRUE;
		else
			minusA = FALSE;
		ar = - ar;
	} else
		minusA = FALSE;

	if (bi < 0 ) {
		minusB = TRUE;
		bi = - bi;
	} else
		minusB = FALSE;
	r = 1;

	/* ar is squared only while a higher bit is left: the last square
	 * was never used and could overflow alone (#267) */
	while (bi != 0) {
		if (ODD(bi)) r = Lfpmul(r, ar);
		bi /= 2;
		if (bi != 0) ar = Lfpmul(ar, ar);
	}
	if (minusA) r = -r;

	if (minusB) {
		/* 0**-n divides by zero: S0CF instead of an error */
		if (r == 0) Lerror(ERR_ARITH_OVERFLOW,3);
		LREAL(*to) = Lfpdiv(1.0, r);
	} else
		LREAL(*to) = r;

	LTYPE(*to) = LREAL_TY;
	LLEN(*to)  = sizeof(double);
} /* Lexpose */
