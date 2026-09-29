/*
 * $Id: trunc.c,v 1.9 2011/06/29 08:33:09 bnv Exp $
 * $Log: trunc.c,v $
 * Revision 1.9  2011/06/29 08:33:09  bnv
 * char to unsigned
 *
 * Revision 1.8  2011/06/20 08:31:19  bnv
 * removed the FCVT and GCVT replaced with sprintf
 *
 * Revision 1.7  2010/01/27 13:21:03  bnv
 * Use of fcvt
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
 * Changed: To use the fcvt()
 *
 * Revision 1.1  1998/07/02 17:18:00  bnv
 * Initial Version
 *
 */

#include "lerror.h"
#include "lstring.h"

/* ---------------- Ltrunc ----------------- */
/* The number is first rounded to NUMERIC DIGITS, as though "number+0" */
/* had been carried out, then truncated to n decimal places. This works */
/* on the decimal digits, not on a double: a double cannot hold the     */
/* digits of a string argument exactly, and printing one decimal more   */
/* and dropping it rounded up whenever that decimal carried             */
/* (TRUNC(127.96) gave 128). The argument is left as it is.             */
#define TRUNC_MAXINT	1000	/* integer digits TRUNC will write    */

/* ---------------- trunc_digit ----------------- */
/* the digit at position idx of 0.num, '0' outside of num */
static char
trunc_digit( const LDecNum *t, long idx )
{
	return (idx>=0 && idx<t->nd) ? t->num[idx] : '0';
} /* trunc_digit */

/* ---------------- trunc_iszero ----------------- */
/* does the result with n decimals show only zeros? */
static int
trunc_iszero( const LDecNum *t, long n )
{
	long	idx;

	for (idx=0; idx<t->nd && idx<t->exp+n; idx++)
		if (t->num[idx]!='0') return FALSE;
	return TRUE;
} /* trunc_iszero */

/* ---------------- Ltrunc ----------------- */
void __CDECL
Ltrunc( const PLstr to, const PLstr from, long n)
{
	LDecNum	t;
	char	buf[40];
	int	neg;
	long	intlen;
	long	idx;
	size_t	len;
	char	*p;

	if (n<0) n = 0;

	if (LTYPE(*from)==LREAL_TY) {
		Ldecreal(&t, LREAL(*from), lNumericDigits);
	} else if (LTYPE(*from)==LINTEGER_TY) {
		snprintf(buf, sizeof(buf), "%ld", LINT(*from));
		Ldecsplit(&t, buf, buf+STRLEN(buf));
		Ldecround(&t, lNumericDigits);
	} else {
		if (_Lisnum(from)==LSTRING_TY)
			Lerror(ERR_BAD_ARITHMETIC,0);
		Ldecsplit(&t, (const char *)LSTR(*from),
				(const char *)LSTR(*from)+LLEN(*from));
		Ldecround(&t, lNumericDigits);
	}

	if (t.exp>TRUNC_MAXINT)
		Lerror(ERR_ARITH_OVERFLOW,0);
	neg = t.neg && !trunc_iszero(&t, n);	/* no negative zero */

	intlen = (t.exp>0) ? t.exp : 1;
	len = (size_t)(neg + intlen + (n ? n+1 : 0));
	Lfx(to, len);
	p = (char *)LSTR(*to);

	if (neg) *p++ = '-';
	if (t.exp>0) {
		for (idx=0; idx<t.exp; idx++)
			*p++ = trunc_digit(&t, idx);
	} else {
		*p++ = '0';
	}
	if (n) {
		*p++ = '.';
		for (idx=0; idx<n; idx++)
			*p++ = trunc_digit(&t, t.exp+idx);
	}
	LLEN(*to)  = len;
	LTYPE(*to) = LSTRING_TY;
} /* Ltrunc */
