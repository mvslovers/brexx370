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
#define TRUNC_MAXDIG	LMAXNUMERICSTRING

/* a number as sign, significant digits and exponent: 0.num * 10**exp */
typedef struct {
	char	num[TRUNC_MAXDIG+1];
	int	nd;			/* digits in num */
	int	neg;
	long	exp;
} TruncNum;

/* ---------------- trunc_exponent ----------------- */
/* read the digits of an exponent, s points past the 'E' */
static long
trunc_exponent( const char *s, const char *end )
{
	int	esign = FALSE;
	long	e = 0;

	if (s<end && (*s=='-' || *s=='+')) {
		esign = (*s=='-');
		s++;
	}
	while (s<end && IN_RANGE('0',*s,'9')) {
		if (e<=TRUNC_MAXINT*10L)
			e = e*10 + (*s-'0');
		s++;
	}
	return esign ? -e : e;
} /* trunc_exponent */

/* ---------------- trunc_split ----------------- */
/* split a valid number (already checked by _Lisnum) into a TruncNum */
static void
trunc_split( TruncNum *t, const char *s, const char *end )
{
	int	point = FALSE;

	t->nd  = 0;
	t->neg = FALSE;
	t->exp = 0;

	while (s<end && ISSPACE((unsigned char)*s)) s++;
	if (s<end && (*s=='-' || *s=='+')) {
		t->neg = (*s=='-');
		s++;
	}
	for (; s<end && *s!='e' && *s!='E'; s++) {
		if (*s=='.')
			point = TRUE;
		else
		if (!IN_RANGE('0',*s,'9'))
			continue;			/* blanks */
		else
		if (t->nd==0 && *s=='0') {		/* leading zero */
			if (point) t->exp--;
		} else {
			if (t->nd<TRUNC_MAXDIG) t->num[t->nd++] = *s;
			if (!point) t->exp++;
		}
	}
	if (s<end)
		t->exp += trunc_exponent(s+1, end);
} /* trunc_split */

/* ---------------- trunc_round ----------------- */
/* round to digits significant digits, the guard digit decides */
static void
trunc_round( TruncNum *t, int digits )
{
	int	i;

	if (t->nd<=digits) return;
	t->nd = digits;
	if (t->num[digits]<'5') return;

	for (i=digits-1; i>=0; i--) {
		if (t->num[i]!='9') {
			t->num[i]++;
			return;
		}
		t->num[i] = '0';
	}
	t->num[0] = '1';			/* 99.9 -> 100 */
	t->nd = 1;
	t->exp++;
} /* trunc_round */

/* ---------------- trunc_digit ----------------- */
/* the digit at position idx of 0.num, '0' outside of num */
static char
trunc_digit( const TruncNum *t, long idx )
{
	return (idx>=0 && idx<t->nd) ? t->num[idx] : '0';
} /* trunc_digit */

/* ---------------- trunc_iszero ----------------- */
/* does the result with n decimals show only zeros? */
static int
trunc_iszero( const TruncNum *t, long n )
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
	TruncNum t;
	char	buf[40];
	const char *s = buf;
	const char *end;
	int	digits = lNumericDigits;
	int	neg;
	long	intlen;
	long	idx;
	size_t	len;
	char	*p;

	if (n<0) n = 0;

	if (LTYPE(*from)==LINTEGER_TY)
		snprintf(buf, sizeof(buf), "%ld", LINT(*from));
	else
	if (LTYPE(*from)==LREAL_TY) {
		digits = MIN(digits, TRUNC_DBLDIG);
		snprintf(buf, sizeof(buf), "%.*e", digits-1, LREAL(*from));
	} else {
		if (_Lisnum(from)==LSTRING_TY)
			Lerror(ERR_BAD_ARITHMETIC,0);
		s = (const char *)LSTR(*from);
	}
	end = (s==buf) ? s+STRLEN(buf) : s+LLEN(*from);

	trunc_split(&t, s, end);
	trunc_round(&t, MAX(1, MIN(digits, TRUNC_MAXDIG)));

	if (t.nd==0) t.exp = 0;			/* zero */
	if (t.exp>TRUNC_MAXINT)
		Lerror(ERR_ARITH_OVERFLOW,0);
	neg = t.neg && !trunc_iszero(&t, n);	/* no negative zero */

	intlen = (t.exp>0) ? t.exp : 1;
	len = (size_t)(neg + intlen + (n ? n+1 : 0));
	Lfx(to, len);
	p = (char *)LSTR(*to);

	if (neg) *p++ = '-';
	if (t.exp>0)
		for (idx=0; idx<t.exp; idx++)
			*p++ = trunc_digit(&t, idx);
	else
		*p++ = '0';
	if (n) {
		*p++ = '.';
		for (idx=0; idx<n; idx++)
			*p++ = trunc_digit(&t, t.exp+idx);
	}
	LLEN(*to)  = len;
	LTYPE(*to) = LSTRING_TY;
} /* Ltrunc */
