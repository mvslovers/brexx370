/*
 * $Id: rxconv.c,v 1.7 2008/07/15 07:40:25 bnv Exp $
 * $Log: rxconv.c,v $
 * Revision 1.7  2008/07/15 07:40:25  bnv
 * #include changed from <> to ""
 *
 * Revision 1.6  2008/07/14 13:08:42  bnv
 * MVS,CMS support
 *
 * Revision 1.5  2002/06/11 12:37:38  bnv
 * Added: CDECL
 *
 * Revision 1.4  2001/06/25 18:51:48  bnv
 * Header -> Id
 *
 * Revision 1.3  1999/11/26 13:13:47  bnv
 * Changed: Something in the formatting of code.
 *
 * Revision 1.2  1999/03/15 15:22:23  bnv
 * Changed the type cast in Lxrange
 *
 * Revision 1.1  1998/07/02 17:34:50  bnv
 * Initial revision
 *
 */

#include <math.h>

#include "lerror.h"
#include "lstring.h"

#include "rexx.h"
#include "rxdefs.h"

/* --------------------------------------------------------------- */
/*  BITAND(string1Ý,Ýstring2¨Ý,pad¨¨)                              */
/* --------------------------------------------------------------- */
/*  BITOR(string1Ý,Ýstring2¨Ý,pad¨¨)                               */
/* --------------------------------------------------------------- */
/*  BITXOR(string1Ý,Ýstring2¨Ý,pad¨¨)                              */
/* --------------------------------------------------------------- */
void __CDECL
R_SoSoC( const int func )
{
    char    pad=' ';
    bool    usepad;
    PLstr    a2;
    Lstr    nullstr;

    if (!IN_RANGE(1,ARGN,3)) Lerror(ERR_INCORRECT_CALL,0);

    must_exist(1);

    if (exist(2))
        a2 = ARG2;
    else {
        LINITSTR(nullstr);
        a2 = &nullstr;
    }

    if (exist(3)) {
        usepad = TRUE;
        get_pad(3,pad);
    } else
        usepad = FALSE;

    switch (func) {
        case f_bitand:
            Lbitand(ARGR,ARG1,a2,usepad,pad);
            break;

        case f_bitor:
            Lbitor(ARGR,ARG1,a2,usepad,pad);
            break;

        case f_bitxor:
            Lbitxor(ARGR,ARG1,a2,usepad,pad);
            break;

        default:
            Lerror(ERR_INTERPRETER_FAILURE,0);
    } /* switch */
} /* R_SoSoC */

/* --------------------------------------------------------------- */
/*  C2D(stringÝ,n¨)                                                */
/* --------------------------------------------------------------- */
/*  X2D(hex-stringÝ,n¨)                                            */
/* --------------------------------------------------------------- */
void __CDECL
R_SoI ( const int func )
{
    long    n;
    if (!IN_RANGE(1,ARGN,2)) Lerror(ERR_INCORRECT_CALL,0);
    must_exist(1);
    get_oi(2,n);

    switch (func) {
        case f_c2d:
            Lc2d(ARGR,ARG1,n);
            break;

        case f_x2d:
            Lx2d(ARGR,ARG1,n);
            break;

        default:
            Lerror(ERR_INTERPRETER_FAILURE,0);
    } /* switch */
} /* R_SoI */

/* --------------------------------------------------------------- */
/*  D2C(wholenumberÝ,n¨)                                           */
/* --------------------------------------------------------------- */
/*  D2X(wholenumberÝ,n¨)                                           */
/* --------------------------------------------------------------- */
void __CDECL
R_IoI ( const int func )
{
    long    n;

    if (!IN_RANGE(1,ARGN,2)) Lerror(ERR_INCORRECT_CALL,0);
    must_exist(1);
    get_oiv(2,n,-1);

    switch (func) {
        case f_d2c:
            Ld2c(ARGR,ARG1,n);
            break;

        case f_d2x:
            Ld2x(ARGR,ARG1,n);
            break;

        default:
            Lerror(ERR_INTERPRETER_FAILURE,0);
    } /* switch */
} /* R_IoI */

/* --------------------------------------------------------------- */
/*  FORMAT(number(,(before)(,(after)(,(expp)(,expt)))))            */
/* --------------------------------------------------------------- */
void __CDECL
R_format( const int func )
{
    long    before, after, expp, expt;

    if (!IN_RANGE(1,ARGN,5)) Lerror(ERR_INCORRECT_CALL,0);
    must_exist(1);

    get_oi0(2,before);
    get_oi0(3,after);
    get_oi0(4,expp);
    get_oi0(5,expt);

    Lformat(ARGR,ARG1,before,after,expp,expt);
} /* R_format */

/* --------------------------------------------------------------- */
/*  TRUNC(number(,n))                                              */
/* --------------------------------------------------------------- */
void __CDECL
R_trunc( const int func )
{
    long   n;

    if (!IN_RANGE(1,ARGN,2)) Lerror(ERR_INCORRECT_CALL,0);
    must_exist(1);
    get_oi0(2,n);

    Ltrunc(ARGR,ARG1,n);
} /* R_trunc */

/* --------------------------------------------------------------- */
/*  XRANGE(Ýstart¨Ý,end¨)                                          */
/* --------------------------------------------------------------- */
void __CDECL
R_xrange( const int func )
{
    unsigned int    start, stop;

    if (ARGN>2) Lerror(ERR_INCORRECT_CALL,0);
    if (exist(1)) {
        L2STR(ARG1);
        if (LLEN(*ARG1)!=1) Lerror(ERR_INCORRECT_CALL,0);
        start = (unsigned)LSTR(*ARG1)Ý0¨ & 0xFF;
    } else
        start = 0;

    if (exist(2)) {
        L2STR(ARG2);
        if (LLEN(*ARG2)!=1) Lerror(ERR_INCORRECT_CALL,0);
        stop = (unsigned)LSTR(*ARG2)Ý0¨ & 0xFF;
    } else
        stop = 255;

    Lxrange(ARGR,(byte)start,(byte)stop);
} /* R_xrange */
