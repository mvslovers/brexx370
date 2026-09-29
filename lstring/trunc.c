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
#define TRUNC_DBLDIG	15	/* significant digits a double holds  */
#define TRUNC_MAXINT	1000	/* integer digits TRUNC will write    */

void __CDECL
Ltrunc( const PLstr to, const PLstr from, long n)
{
	char	num[LMAXNUMERICSTRING+1];	/* significant digits    */
	char	buf[40];
	const char *s, *end;
	char	*p;
	int	neg = FALSE, point = FALSE, esign = FALSE;
	int	digits, nd = 0, i;
	long	exp = 0, e = 0;		/* value = 0.num * 10**exp */
	long	intlen, idx, k;
	size_t	len;

	if (n<0) n = 0;

	switch (LTYPE(*from)) {
		case LINTEGER_TY:
			snprintf(buf, sizeof(buf), "%ld", LINT(*from));
			s = buf;
			digits = lNumericDigits;
			break;
		case LREAL_TY:
			digits = MIN(lNumericDigits, TRUNC_DBLDIG);
			snprintf(buf, sizeof(buf), "%.*e", digits-1, LREAL(*from));
			s = buf;
			break;
		default:
			if (_Lisnum(from)==LSTRING_TY)
				Lerror(ERR_BAD_ARITHMETIC,0);
			s = LSTR(*from);
			digits = lNumericDigits;
	}
	end = (s==buf) ? s+STRLEN(buf) : s+LLEN(*from);

	/* split into sign, significant digits and exponent */
	while (s<end && ISSPACE((unsigned char)*s)) s++;
	if (s<end && (*s=='-' || *s=='+')) {
		neg = (*s=='-');
		s++;
	}
	for (; s<end; s++) {
		if (IN_RANGE('0',*s,'9')) {
			if (nd==0 && *s=='0') {		/* leading zero */
				if (point) exp--;
				continue;
			}
			if (nd<(int)sizeof(num)) num[nd++] = *s;
			if (!point) exp++;
		} else
		if (*s=='.')
			point = TRUE;
		else
		if (*s=='e' || *s=='E') {
			s++;
			if (s<end && (*s=='-' || *s=='+')) {
				esign = (*s=='-');
				s++;
			}
			for (; s<end && IN_RANGE('0',*s,'9'); s++)
				if (e<=TRUNC_MAXINT*10L)
					e = e*10 + (*s-'0');
			break;
		}
	}
	exp += esign ? -e : e;

	/* round to NUMERIC DIGITS significant digits */
	if (nd>digits) {
		int up = (num[digits]>='5');
		nd = digits;
		for (i=nd-1; up && i>=0; i--) {
			if (num[i]=='9')
				num[i] = '0';
			else {
				num[i]++;
				up = FALSE;
			}
		}
		if (up) {			/* 99.9 -> 100 */
			num[0] = '1';
			nd = 1;
			exp++;
		}
	}
	if (nd==0) {				/* zero */
		exp = 0;
		neg = FALSE;
	}
	if (exp>TRUNC_MAXINT)
		Lerror(ERR_ARITH_OVERFLOW,0);

	/* a zero result carries no sign */
	if (neg) {
		neg = FALSE;
		for (idx=0; idx<nd && idx<exp+n; idx++)
			if (num[idx]!='0') {
				neg = TRUE;
				break;
			}
	}

	intlen = (exp>0) ? exp : 1;
	len = (size_t)(neg + intlen + (n ? n+1 : 0));
	Lfx(to, len);
	p = (char *)LSTR(*to);

	if (neg) *p++ = '-';
	if (exp>0)
		for (idx=0; idx<exp; idx++)
			*p++ = (idx<nd) ? num[idx] : '0';
	else
		*p++ = '0';
	if (n) {
		*p++ = '.';
		for (k=0; k<n; k++) {
			idx = exp + k;		/* digit position in num */
			*p++ = (idx>=0 && idx<nd) ? num[idx] : '0';
		}
	}
	LLEN(*to)  = len;
	LTYPE(*to) = LSTRING_TY;
} /* Ltrunc */
