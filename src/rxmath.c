/*
 * $Id: rxmath.c,v 1.9 2011/06/29 08:32:25 bnv Exp $
 * $Log: rxmath.c,v $
 * Revision 1.9  2011/06/29 08:32:25  bnv
 * Corrected error on negative sqrt
 *
 * Revision 1.8  2008/07/15 07:40:25  bnv
 * #include changed from <> to ""
 *
 * Revision 1.7  2003/10/30 13:16:28  bnv
 * Variable name change
 *
 * Revision 1.6  2002/06/11 12:37:38  bnv
 * Added: CDECL
 *
 * Revision 1.5  2001/09/28 10:08:03  bnv
 * Added new integer bitwise functions AND,OR,NOT,XOR
 *
 * Revision 1.4  2001/06/25 18:51:48  bnv
 * Header -> Id
 *
 * Revision 1.3  1999/11/26 13:13:47  bnv
 * Changed: The formatting of the code.
 *
 * Revision 1.2  1999/02/26 08:45:49  bnv
 * Correction of pow10 for BORLANDC.
 *
 * Revision 1.1  1998/07/02 17:34:50  bnv
 * Initial revision
 *
 */

#include <math.h>
#include <stdlib.h>

#include "lerror.h"
#include "lstring.h"

#include "rexx.h"
#include "rxdefs.h"

/* --------------------------------------------------------------- */
/*  ABS(number)                                                    */
/* --------------------------------------------------------------- */
/*  SIGN(number)                                                   */
/* --------------------------------------------------------------- */
void __CDECL
R_abs_sign( const int func )
{
	if (ARGN!=1) Lerror(ERR_INCORRECT_CALL,0);

	if (func==f_abs)
		Labs(ARGR,ARG1);
	else
		Licpy(ARGR,Lsign(ARG1));
} /* R_abs_sign */

/* ----------------------* common math functions *---------------- */
void __CDECL
R_math( const int func )
{
	if (ARGN!=1) Lerror(ERR_INCORRECT_CALL,0);
	L2REAL(ARG1);
	Lstrcpy(ARGR,ARG1);
	switch (func) {
		case f_acos:
			LREAL(*ARGR) = acos(LREAL(*ARGR));
			break;

		case f_asin:
			LREAL(*ARGR) = asin(LREAL(*ARGR));
			break;

		case f_atan:
			LREAL(*ARGR) = atan(LREAL(*ARGR));
			break;

		case f_cos :
			LREAL(*ARGR) =  cos(LREAL(*ARGR));
			break;

		case f_cosh:
			LREAL(*ARGR) = cosh(LREAL(*ARGR));
			break;

		case f_exp :
			LREAL(*ARGR) =  exp(LREAL(*ARGR));
			break;

		case f_log :
			LREAL(*ARGR) =  log(LREAL(*ARGR));
			break;

		case f_log10:
			LREAL(*ARGR) = log10(LREAL(*ARGR));
			break;

		case f_pow10:
			LREAL(*ARGR) = pow(10.0,LREAL(*ARGR));
			break;

		case f_sin :
			LREAL(*ARGR) =  sin(LREAL(*ARGR));
			break;

		case f_sinh:
			LREAL(*ARGR) = sinh(LREAL(*ARGR));
			break;

		case f_sqrt:
			if (LREAL(*ARGR)<0.0)
				Lerror(ERR_ARITH_OVERFLOW,0);
			LREAL(*ARGR) = sqrt(LREAL(*ARGR));
			break;

		case f_tan :
			LREAL(*ARGR) =  tan(LREAL(*ARGR));
			break;

		case f_tanh:
			LREAL(*ARGR) = tanh(LREAL(*ARGR));
			break;

		default:
			Lerror(ERR_INTERPRETER_FAILURE,0);
	} /* switch */
} /* R_math */

/* --------------------------------------------------------------- */
/*  ATAN2(x,y)                                                     */
/* --------------------------------------------------------------- */
/*  POW(x,y)                                                       */
/* --------------------------------------------------------------- */
void __CDECL
R_atanpow( const int func )
{
	if (ARGN!=2) Lerror(ERR_INCORRECT_CALL,0);
	L2REAL(ARG1);
	L2REAL(ARG2);
	Lstrcpy(ARGR,ARG1);
	if (func==f_atan2)
		LREAL(*ARGR) = atan2(LREAL(*ARGR),LREAL(*ARG2));
	else
		LREAL(*ARGR) = pow(LREAL(*ARGR),LREAL(*ARG2));
} /* R_atanpow */

/* --------------------------------------------------------------- */
/*  AND(a,b)                                                       */
/* --------------------------------------------------------------- */
/*  OR(a,b)                                                        */
/* --------------------------------------------------------------- */
/*  XOR(a,b)                                                       */
/* --------------------------------------------------------------- */
void __CDECL
R_bitwise( const int func )
{
	int	i;
	int	num;
	if (ARGN<2) Lerror(ERR_INCORRECT_CALL,0);

	Lstrcpy(ARGR,ARG1);
	L2INT(ARGR);

	for (i=1; i<ARGN; i++) {
		num = Lrdint(rxArg.a[i]);
		if (func==f_and)
			LINT(*ARGR) &= num;
		else
		if (func==f_or)
			LINT(*ARGR) |= num;
		else
			LINT(*ARGR) ^= num;
	}
} /* R_bitwise */

/* --------------------------------------------------------------- */
/*  NOT(n)                                                         */
/* --------------------------------------------------------------- */
void __CDECL
R_not( const int func )
{
	if (ARGN!=1) Lerror(ERR_INCORRECT_CALL,0);

	Lstrcpy(ARGR,ARG1);
	L2INT(ARGR);
	LINT(*ARGR) = ~LINT(*ARGR);
} /* R_not */

/* --------------------------------------------------------------- */
/*  CEILING(number)                                                */
/* --------------------------------------------------------------- */
void __CDECL
R_ceil( )
{
    must_exist(1);
    Lceil(ARGR,ARG1);
} /* R_ceil */

/* --------------------------------------------------------------- */
/*  FLOOR(number)                                                  */
/* --------------------------------------------------------------- */
void __CDECL
R_floor( )
{
    must_exist(1);
    Lfloor(ARGR,ARG1);
} /* R_floor */

/* --------------------------------------------------------------- */
/*  ROUND(number,number-fraction-digits)                                                  */
/* --------------------------------------------------------------- */
void __CDECL
R_round( )
{
    long   n;
    if (ARGN!=2) Lerror(ERR_INCORRECT_CALL,0);
    must_exist(1);
    must_exist(2);
    get_oi0(2,n);

    Lround(ARGR,ARG1,n);
} /* R_floor */

