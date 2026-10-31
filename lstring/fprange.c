/*
 * Floating-point operations that check the S/370 range first (#267).
 * An exponent overflow is a program check (S0CC) that no mask
 * suppresses, so each helper compares before it computes and raises
 * error 42 instead. Underflow is masked and gives 0. The limit is a
 * little below the largest long float (7.237E75), which leaves room
 * for the rounding of the comparison itself.
 */
#include "lerror.h"
#include "lstring.h"

#define LHFPMAX 7.2E75

/* ---------------- Lfpadd ---------------- */
double __CDECL
Lfpadd( double a, double b )
{
	if ((a > 0 && b > 0 && a >  LHFPMAX - b) ||
	    (a < 0 && b < 0 && a < -LHFPMAX - b))
		Lerror(ERR_ARITH_OVERFLOW,0);
	return a + b;
} /* Lfpadd */

/* ---------------- Lfpmul ---------------- */
double __CDECL
Lfpmul( double a, double b )
{
	double	x = (a < 0) ? -a : a;
	double	y = (b < 0) ? -b : b;

	/* a factor below 1 cannot overflow; LHFPMAX/x < LHFPMAX for x > 1 */
	if (x > 1 && y > 1 && y > LHFPMAX / x)
		Lerror(ERR_ARITH_OVERFLOW,0);
	return a * b;
} /* Lfpmul */

/* ---------------- Lfpdiv ---------------- */
double __CDECL
Lfpdiv( double a, double b )
{
	double	x = (a < 0) ? -a : a;
	double	y = (b < 0) ? -b : b;

	if (y == 0) Lerror(ERR_ARITH_OVERFLOW,3);
	/* a divisor of 1 or more cannot overflow; LHFPMAX*y < LHFPMAX */
	if (y < 1 && x > LHFPMAX * y)
		Lerror(ERR_ARITH_OVERFLOW,0);
	return a / b;
} /* Lfpdiv */
