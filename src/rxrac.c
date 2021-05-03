#include "rexx.h"
#include "rxdefs.h"
#include "rxrac.h"
#include "rac.h"
#include "lstring.h"
#ifdef __CROSS__
# include "jccdummy.h"
#endif

void R_racstatus(__unused int func)
{
    int rc;

    if (ARGN != 0)
        Lerror(ERR_INCORRECT_CALL, 0);

    rc = rac_status();

    Licpy(ARGR, rc);
}

void R_racauth(__unused int func)
{
    int rc;

    if (ARGN != 2)
        Lerror(ERR_INCORRECT_CALL, 0);

    LASCIIZ(*ARG1)
    LASCIIZ(*ARG2)

    get_s(1);
    get_s(2);

    rc = rac_user_auth(LSTR(*ARG1), LSTR(*ARG2));

    Licpy(ARGR, rc);
}

void R_raccheck(__unused int func)
{
    int rc;

    if (ARGN != 3)
        Lerror(ERR_INCORRECT_CALL, 0);

    LASCIIZ(*ARG1)
    LASCIIZ(*ARG2)
    LASCIIZ(*ARG3)

    get_s(1);
    get_s(2);
    get_s(3);

    rc = rac_facility_check(LSTR(*ARG1), LSTR(*ARG2), LSTR(*ARG3));

    Licpy(ARGR, rc);
}

/* register rexx functions to brexx/370 */
void RxRacRegFunctions()
{
    RxRegFunction("RACSTATUS",  R_racstatus,    0);
    RxRegFunction("RACAUTH",    R_racauth,      0);
    RxRegFunction("RACCHECK", R_raccheck,       0);
} /* RxRacRegFunctions() */
