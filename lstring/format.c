/*
 * FORMAT(number[,[before][,[after][,[expp][,expt]]]])
 *
 * As the TSO/E REXX Reference defines it (SA32-0972, FORMAT). The number
 * is first rounded to NUMERIC DIGITS, as though "number+0" had been
 * carried out. Like TRUNC this works on the decimal digits of the
 * argument (numfmt.c), not on a double: a string keeps its digits, a
 * real is taken to the 15 digits it holds. An omitted option is -1.
 *
 * Exponential notation is used when the integer part needs more than
 * expt places or the decimal part more than twice expt. expt defaults
 * to NUMERIC DIGITS, so without expp and expt the number is laid out as
 * number+0 prints. expt=0 always uses it, expp=0 never. An exponent of
 * 0 is not shown, or shown as expp+2 blanks when expp is given.
 *
 * Until 3.0.0 BREXX formatted with the C library (expp 1/2 chose the
 * G/E format, expt was ignored) and returned wrong numbers (#43).
 */

#include "lerror.h"
#include "lstring.h"

#define FORMAT_MAX	1000	/* places FORMAT writes for one part */

/* ---------------- fmt_digit ----------------- */
/* the digit of weight 10**w, '0' outside of num */
static char
fmt_digit( const LDecNum *d, long w )
{
	long	idx = d->exp - 1 - w;

	return (idx>=0 && idx<d->nd) ? d->num[idx] : '0';
} /* fmt_digit */

/* ---------------- fmt_number ----------------- */
/* the argument as decimal digits, rounded to NUMERIC DIGITS */
static void
fmt_number( LDecNum *d, const PLstr from, int digits )
{
	char	buf[40];

	if (LTYPE(*from)==LREAL_TY) {
		Ldecreal(d, LREAL(*from), digits);
		while (d->nd>0 && d->num[d->nd-1]=='0') d->nd--;
		if (d->nd==0) {
			d->exp = 0;
			d->neg = FALSE;
		}
	} else if (LTYPE(*from)==LINTEGER_TY) {
		snprintf(buf, sizeof(buf), "%ld", LINT(*from));
		Ldecsplit(d, buf, buf+STRLEN(buf));
		Ldecround(d, digits);
	} else {
		if (_Lisnum(from)==LSTRING_TY)
			Lerror(ERR_BAD_ARITHMETIC,0);
		Ldecsplit(d, (const char *)LSTR(*from),
				(const char *)LSTR(*from)+LLEN(*from));
		Ldecround(d, digits);
	}
} /* fmt_number */

/* ---------------- fmt_round ----------------- */
/* round half up, keeping the digits of weight 10**w and above */
static void
fmt_round( LDecNum *d, long w )
{
	long	keep = d->exp - w;

	if (d->nd<=keep) return;
	if (keep>=1) {
		Ldecround(d, (int)keep);
		return;
	}
	if (keep==0 && d->num[0]>='5') {	/* 0.6 -> 1 */
		d->num[0] = '1';
		d->nd  = 1;
		d->exp = w + 1;
		return;
	}
	d->nd  = 0;				/* rounds to zero */
	d->exp = 0;
	d->neg = FALSE;
} /* fmt_round */

/* ---------------- fmt_engineering ----------------- */
/* exponent a multiple of three, one to three integer digits */
static void
fmt_engineering( long *e, long *point )
{
	while (*e % 3) {
		(*point)++;
		(*e)--;
	}
} /* fmt_engineering */

/* ---------------- fmt_expdigits ----------------- */
static long
fmt_expdigits( long e )
{
	long	n = 1;

	for (e = labs(e); e>=10; e /= 10) n++;
	return n;
} /* fmt_expdigits */

/* ---------------- Lformat ------------------ */
void __CDECL
Lformat( const PLstr to, const PLstr from, long before, long after,
	long expp, long expt, int engineering )
{
	LDecNum	d;
	long	digits = MIN(MAX(lNumericDigits,1), LMAXNUMERICDIGITS);
	long	sig, intp, decp, e, point, expd, explen, blanks, len, i;
	int	showexp, neg;
	char	*p;

	if (before>FORMAT_MAX || after>FORMAT_MAX ||
	    expp>FORMAT_MAX || expt>FORMAT_MAX)
		Lerror(ERR_INCORRECT_CALL,0);

	fmt_number(&d, from, (int)digits);

	/* places the number needs; trailing zeros are not needed */
	sig = d.nd;
	while (sig>0 && d.num[sig-1]=='0') sig--;
	intp = (d.exp>0) ? d.exp : 1;
	decp = (sig>d.exp) ? sig-d.exp : 0;

	if (expt<0) expt = digits;
	if (d.nd==0 || expp==0)
		showexp = FALSE;
	else if (expt==0)
		showexp = TRUE;
	else
		showexp = (intp>expt || decp>2*expt);

	if (showexp) {
		e = d.exp - 1;
		point = 1;
		if (engineering) fmt_engineering(&e, &point);
	} else {
		e = 0;
		point = intp;
	}

	if (after<0) {		/* as many decimals as the number has */
		after = d.nd - (d.exp - e);
		if (after<0) after = 0;
	} else {
		fmt_round(&d, e - after);
		if (d.nd>0 && d.exp-e>point) {	/* 9.96 -> 10.0 */
			point = d.exp - e;
			if (!showexp && expp!=0 && point>expt) {
				/* the rounded integer part needs more than */
				/* expt places: 99.999 -> 1.00E+2           */
				showexp = TRUE;
				e = d.exp - 1;
				point = 1;
				if (engineering) fmt_engineering(&e, &point);
				fmt_round(&d, e - after);
			} else if (showexp) {
				e += point - 1;
				point = 1;
				if (engineering) fmt_engineering(&e, &point);
			}
		}
	}
	if (point>FORMAT_MAX || after>FORMAT_MAX)
		Lerror(ERR_ARITH_OVERFLOW,0);
	neg = d.neg && d.nd>0;

	if (before<0)
		before = point + neg;
	else if (point+neg>before)
		Lerror(ERR_INCORRECT_CALL,0);
	blanks = before - point - neg;

	explen = 0;
	expd = 0;
	if (showexp) {
		expd = fmt_expdigits(e);
		if (expp>0) {
			if (expd>expp) Lerror(ERR_INCORRECT_CALL,0);
			expd = expp;
		}
		if (e!=0)
			explen = 2 + expd;
		else if (expp>0)
			explen = expp + 2;	/* blanks for exponent 0 */
	}

	len = before + (after>0 ? after+1 : 0) + explen;
	Lfx(to, (size_t)len);
	p = (char *)LSTR(*to);

	for (i=0; i<blanks; i++) *p++ = ' ';
	if (neg) *p++ = '-';
	for (i=point-1; i>=0; i--)
		*p++ = fmt_digit(&d, e+i);
	if (after>0) {
		*p++ = '.';
		for (i=1; i<=after; i++)
			*p++ = fmt_digit(&d, e-i);
	}
	if (explen && e==0) {
		for (i=0; i<explen; i++) *p++ = ' ';
	} else if (explen) {
		*p++ = 'E';
		*p++ = (e<0) ? '-' : '+';
		for (i=expd-1; i>=0; i--) {
			long	v = labs(e);
			for (long k=0; k<i; k++) v /= 10;
			*p++ = (char)('0' + v%10);
		}
	}
	LLEN(*to)  = (size_t)len;
	LTYPE(*to) = LSTRING_TY;
} /* Lformat */
