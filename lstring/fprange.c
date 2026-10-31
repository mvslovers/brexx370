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

/* ---------------- Lfpaddovf ---------------- */
int __CDECL
Lfpaddovf( double a, double b )
{
	return (a > 0 && b > 0 && a >  LHFPMAX - b) ||
	       (a < 0 && b < 0 && a < -LHFPMAX - b);
} /* Lfpaddovf */

/* ---------------- Lfpmulovf ---------------- */
int __CDECL
Lfpmulovf( double a, double b )
{
	double	x = (a < 0) ? -a : a;
	double	y = (b < 0) ? -b : b;

	/* a factor below 1 cannot overflow; LHFPMAX/x < LHFPMAX for x > 1 */
	return x > 1 && y > 1 && y > LHFPMAX / x;
} /* Lfpmulovf */

/* ---------------- Lfpdivovf ---------------- */
int __CDECL
Lfpdivovf( double a, double b )
{
	double	x = (a < 0) ? -a : a;
	double	y = (b < 0) ? -b : b;

	/* a divisor of 1 or more cannot overflow; LHFPMAX*y < LHFPMAX */
	return y < 1 && x > LHFPMAX * y;
} /* Lfpdivovf */

/* ---------------- Lfpadd ---------------- */
double __CDECL
Lfpadd( double a, double b )
{
	if (Lfpaddovf(a, b)) Lerror(ERR_ARITH_OVERFLOW,0);
	return a + b;
} /* Lfpadd */

/* ---------------- Lfpmul ---------------- */
double __CDECL
Lfpmul( double a, double b )
{
	if (Lfpmulovf(a, b)) Lerror(ERR_ARITH_OVERFLOW,0);
	return a * b;
} /* Lfpmul */

/* ---------------- Lfpdiv ---------------- */
double __CDECL
Lfpdiv( double a, double b )
{
	if (b == 0) Lerror(ERR_ARITH_OVERFLOW,3);
	if (Lfpdivovf(a, b)) Lerror(ERR_ARITH_OVERFLOW,0);
	return a / b;
} /* Lfpdiv */
