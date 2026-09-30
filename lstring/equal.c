/*
 * $Id: equal.c,v 1.8 2011/06/20 08:31:19 bnv Exp $
 * $Log: equal.c,v $
 * Revision 1.8  2011/06/20 08:31:19  bnv
 * Using a global SMALL number
 *
 * Revision 1.7  2008/07/15 07:40:54  bnv
 * #include changed from <> to ""
 *
 * Revision 1.6  2004/03/26 22:51:11  bnv
 * Increased the accuracy
 *
 * Revision 1.5  2002/06/11 12:37:15  bnv
 * Added: CDECL
 *
 * Revision 1.4  2001/06/25 18:49:48  bnv
 * Header changed to Id
 *
 * Revision 1.3  1999/11/26 09:56:55  bnv
 * Changed: To use the new macros.
 * Changed: From char* to byte* comparison, to avoid signed char problems.
 * Changed: To use the lLastScannedNumber
 *
 * Revision 1.2  1998/11/10 13:36:14  bnv
 * Comparison for reals is done with fabs(a-b)<smallnumber
 *
 * Revision 1.1  1998/07/02 17:18:00  bnv
 * Initial Version
 *
 */

#include <math.h>
#include <ctype.h>
#include <string.h>
#include "lstring.h"

/* -------------------- num_cmp ----------------- */
/* A numeric comparison is (A-B) compared with 0 under NUMERIC DIGITS */
/* (TSO/E, "Numbers and arithmetic"). On doubles that means: round    */
/* both to DIGITS significant digits, at most the 15 a double holds,  */
/* and compare the decimals. Comparing the doubles themselves made    */
/* 100.5-50.6 = 49.9 false, and the old fabs(a-b)<=1E-20 made         */
/* 1E-20 = 0 true (#223). Values far apart skip the decimal step.     */
static int
num_cmp( double ra, double rb )
{
	static const double tens[] = { 1E0, 1E1, 1E2, 1E3, 1E4, 1E5, 1E6,
		1E7, 1E8, 1E9, 1E10, 1E11, 1E12, 1E13, 1E14, 1E15, 1E16 };
	LDecNum	a, b;
	int	digits = MIN(MAX(lNumericDigits,1), LDBLDIG);
	int	sa, sb, mag, i;
	double	big;

	if (ra==rb) return 0;
	big = MAX(fabs(ra),fabs(rb));
	/* more than a hundred units of the last digit apart: no rounding */
	/* to DIGITS can make them equal                                  */
	if (fabs(ra-rb) > big*100/tens[digits])
		return (ra>rb) ? 1 : -1;

	Ldecreal(&a, ra, digits);
	Ldecreal(&b, rb, digits);
	while (a.nd>0 && a.num[a.nd-1]=='0') a.nd--;
	while (b.nd>0 && b.num[b.nd-1]=='0') b.nd--;

	sa = (a.nd==0) ? 0 : (a.neg ? -1 : 1);
	sb = (b.nd==0) ? 0 : (b.neg ? -1 : 1);
	if (sa!=sb) return (sa>sb) ? 1 : -1;
	if (sa==0) return 0;

	if (a.exp!=b.exp)
		mag = (a.exp>b.exp) ? 1 : -1;
	else {
		mag = 0;
		for (i=0; i<a.nd || i<b.nd; i++) {
			char	da = (i<a.nd) ? a.num[i] : '0';
			char	db = (i<b.nd) ? b.num[i] : '0';
			if (da!=db) {
				mag = (da>db) ? 1 : -1;
				break;
			}
		}
	}
	return sa*mag;
} /* num_cmp */

/* -------------------- Lequal ----------------- */
int __CDECL
Lequal(const PLstr A, const PLstr B)
{
	int	ta, tb;
	byte	*a, *b;		/* start position in string */
	byte	*ae, *be;	/* ending position in string */
	double	ra, rb;

	if (LTYPE(*A)==LSTRING_TY) {
		ta = _Lisnum(A);

		/* check to see if the first argument is string? */
		if (ta == LSTRING_TY) {
			L2STR(B);	/* make string and the second	*/
			goto eq_str;	/* go and check strings		*/
		}

		ra = lLastScannedNumber;
	} else {
		ta = LTYPE(*A);
		ra = TOREAL(*A);
	}

	if (LTYPE(*B)==LSTRING_TY) {
		tb = _Lisnum(B);
		rb = lLastScannedNumber;
	} else {
		tb = LTYPE(*B);
		rb = TOREAL(*B);
	}

	/* is B also a number */
	if (tb != LSTRING_TY)
		return num_cmp(ra,rb);

	/* nope it was a string */
	L2STR(A);		/* convert A string */
eq_str:
	a = (byte*)LSTR(*A);
	ae = a + LLEN(*A);
	for(; (a<ae) && ISSPACE(*a); a++) ;

	b = (byte*)LSTR(*B);
	be = b + LLEN(*B);
	for(; (b<be) && ISSPACE(*b); b++) ;

	/* trailing blanks are ignored as well: 'abc  ' = 'abc' */
	for(; (ae>a) && ISSPACE(ae[-1]); ae--) ;
	for(; (be>b) && ISSPACE(be[-1]); be--) ;

	for(;(a<ae) && (b<be) && (*a==*b); a++,b++) ;

	if (a<ae && b<be)
		return (*a<*b) ? -1 : 1 ;

	/* the shorter string is padded with blanks */
	for(; (a<ae) && (*a==' '); a++) ;
	for(; (b<be) && (*b==' '); b++) ;
	if (a<ae)
		return (*a<' ') ? -1 : 1 ;
	if (b<be)
		return (*b<' ') ? 1 : -1 ;
	return 0;
} /* Lequal */
