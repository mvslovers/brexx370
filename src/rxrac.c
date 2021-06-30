#include "rexx.h"
#include "rxdefs.h"
#include "rxrac.h"
#include "rac.h"
#include "lstring.h"

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

    rc = rac_check(LSTR(*ARG1), LSTR(*ARG2), LSTR(*ARG3));

    Licpy(ARGR, rc);
}

/* register rexx functions to brexx/370 */
void RxRacRegFunctions()
{
    RxRegFunction("RACCHECK",   R_raccheck,     0);
} /* RxRacRegFunctions() */
