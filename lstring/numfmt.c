/*
 * Decimal digits of a number, and a real formatted the REXX way.
 *
 * A double holds about 15 significant decimal digits (14 hex digits of
 * mantissa on S/370). Printing it with %.*g at NUMERIC DIGITS 30 showed
 * the binary expansion past those digits, and C's %g switches to
 * exponential form by its own rules. Lreal2str() rounds to at most 15
 * significant digits and places them by the REXX rules instead
 * (TSO/E REXX Reference, "Numbers and Arithmetic").
 */

#include "lerror.h"
#include "lstring.h"

#define DEC_MAXEXP	100000000L	/* exponents read are capped here */

/* ---------------- dec_exponent ----------------- */
/* read the digits of an exponent, s points past the 'E' */
static long
dec_exponent( const char *s, const char *end )
{
	int	esign = FALSE;
	long	e = 0;

	if (s<end && (*s=='-' || *s=='+')) {
		esign = (*s=='-');
		s++;
	}
	while (s<end && IN_RANGE('0',*s,'9')) {
		if (e<DEC_MAXEXP)
			e = e*10 + (*s-'0');
		s++;
	}
	return esign ? -e : e;
} /* dec_exponent */

/* ---------------- Ldecsplit ----------------- */
/* split a valid number (already checked, e.g. by _Lisnum) into d */
void __CDECL
Ldecsplit( LDecNum *d, const char *s, const char *end )
{
	int	point = FALSE;

	d->nd  = 0;
	d->neg = FALSE;
	d->exp = 0;

	while (s<end && ISSPACE((unsigned char)*s)) s++;
	if (s<end && (*s=='-' || *s=='+')) {
		d->neg = (*s=='-');
		s++;
	}
	for (; s<end && *s!='e' && *s!='E'; s++) {
		if (*s=='.') {
			point = TRUE;
		} else if (!IN_RANGE('0',*s,'9')) {
			continue;			/* blanks */
		} else if (d->nd==0 && *s=='0') {	/* leading zero */
			if (point) d->exp--;
		} else {
			if (d->nd<LMAXNUMERICSTRING) d->num[d->nd++] = *s;
			if (!point) d->exp++;
		}
	}
	if (s<end)
		d->exp += dec_exponent(s+1, end);
	if (d->nd==0) {				/* zero */
		d->exp = 0;
		d->neg = FALSE;
	}
} /* Ldecsplit */

/* ---------------- Ldecround ----------------- */
/* round to digits significant digits, the guard digit decides */
void __CDECL
Ldecround( LDecNum *d, int digits )
{
	int	i;

	digits = MAX(1, MIN(digits, LMAXNUMERICSTRING));
	if (d->nd<=digits) return;
	d->nd = digits;
	if (d->num[digits]<'5') return;

	for (i=digits-1; i>=0; i--) {
		if (d->num[i]!='9') {
			d->num[i]++;
			return;
		}
		d->num[i] = '0';
	}
	d->num[0] = '1';			/* 99.9 -> 100 */
	d->nd = 1;
	d->exp++;
} /* Ldecround */

/* ---------------- Ldecreal ----------------- */
/* the digits of a double, rounded half up to digits (at most LDBLDIG). */
/* printf delivers two digits more, so the rounding is REXX's and not   */
/* printf's round-half-even. The value is first taken to LDBLDIG digits, */
/* the digits it holds, and then to digits: 0.25 computed on S/370 as   */
/* 0.24999999999999999 is 0.25 and at one digit 0.3, not 0.2.           */
void __CDECL
Ldecreal( LDecNum *d, double r, int digits )
{
	char	tmp[40];

	snprintf(tmp, sizeof(tmp), "%.*e", LDBLDIG+1, r);
	Ldecsplit(d, tmp, tmp+STRLEN(tmp));
	Ldecround(d, LDBLDIG);
	Ldecround(d, MIN(digits, LDBLDIG));
} /* Ldecreal */

/* ---------------- Lreal2str ----------------- */
/* Format r with at most LDBLDIG significant digits. Exponential form */
/* only when the integer part needs more than NUMERIC DIGITS places or */
/* the fraction more than twice NUMERIC DIGITS; then one digit before  */
/* the point and a signed exponent ("1.5E+31"). The result is at most  */
/* 1+1+2*LMAXNUMERICDIGITS+LDBLDIG characters; returns its length.     */
size_t __CDECL
Lreal2str( char *buf, size_t size, double r )
{
	LDecNum	d;
	char	*p = buf;
	char	*last = buf + size - 1;	/* room for the terminator */
	long	idx;
	int	n;
	/* as interpre.c caps it; a restored NUMERIC DIGITS is not capped */
	long	digits = MIN(MAX(lNumericDigits,1), LMAXNUMERICDIGITS);

	Ldecreal(&d, r, (int)digits);
	while (d.nd>0 && d.num[d.nd-1]=='0') d.nd--;	/* trailing zeros */

	if (d.nd==0) {
		if (p<last) *p++ = '0';
		*p = '\0';
		return (size_t)(p-buf);
	}
	if (d.neg && p<last) *p++ = '-';

	if (d.exp>digits || d.nd-d.exp>2*digits) {
		/* scientific: d.ddd E+x */
		if (p<last) *p++ = d.num[0];
		if (d.nd>1 && p<last) *p++ = '.';
		for (idx=1; idx<d.nd && p<last; idx++)
			*p++ = d.num[idx];
		n = snprintf(p, (size_t)(last-p)+1, "E%c%ld",
				(d.exp-1<0) ? '-' : '+', labs(d.exp-1));
		p = (n>0 && n<=last-p) ? p+n : last;
		*p = '\0';
		return (size_t)(p-buf);
	}

	if (d.exp>0) {
		for (idx=0; idx<d.exp && p<last; idx++)
			*p++ = (idx<d.nd) ? d.num[idx] : '0';
	} else if (p<last) {
		*p++ = '0';
	}
	if (d.nd>d.exp && p<last) {
		*p++ = '.';
		for (idx=d.exp; idx<d.nd && p<last; idx++)
			*p++ = (idx<0) ? '0' : d.num[idx];
	}
	*p = '\0';
	return (size_t)(p-buf);
} /* Lreal2str */
