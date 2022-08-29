#include "rexx.h"
#include "rxdefs.h"
#include "rxregex.h"
#include "lstring.h"
#include "re.h"

void R_match(__unused int func)
{
    int match_length;
    int match_idx;

    if (ARGN != 2)
        Lerror(ERR_INCORRECT_CALL, 0);

    LASCIIZ(*ARG1)
    LASCIIZ(*ARG2)

    get_s(1);
    get_s(2);

    match_idx = re_match(LSTR(*ARG1), LSTR(*ARG2), &match_length);

    Licpy(ARGR, match_idx);
}

/* register rexx functions to brexx/370 */
void RxRegexRegFunctions()
{
    RxRegFunction("MATCH",   R_match,     0);
} /* RxRacRegFunctions() */
