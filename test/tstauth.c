/* The authorization of the job step after an abend (#505).
 *
 * __NJESEND holds the SVC 244 authorization in a flag on its stack. If the
 * NJE38 command abends, BREXX's ESTAE returns through _setjmp_estae in
 * main() and the frame is gone: nothing calls authDrop(), and main() ends
 * the exec with RxNoPriv(). This test does the same with the functions
 * of src/privilege.c: it takes the authorization, leaves the "service" by
 * longjmp without dropping it, and runs RxNoPriv(). The step must not be
 * authorized then, and the flag of the lost frame must not count for a
 * later holder.
 *
 * The result is the RC, and the authorization of the step the caller sees
 * (test/njeauth2.rexx checks SYSVAR('SYSAUTH') after LINKMVS).
 * RC 0 also when the step is authorized anyway, or RAKF denies READ on
 * FACILITY SVC244: nothing can be measured then.
 */
#include <stdio.h>
#include <setjmp.h>
#include <mvs/apf.h>
#include <mbtcheck.h>
#include "rexx.h"
#include "rxmvsext.h"

/* rac.c asks it for the ACEE; the one of the task is right in both steps */
int isTSO(void)
{
    return 0;
}

static jmp_buf      escape;
/* static, so that the flag outlives the "frame" the way stack memory does */
static volatile int lost;

static void service(void)
{
    if (authTake(&lost) != 0) {
        longjmp(escape, 2);
    }
    longjmp(escape, 1);
}

int main(void)
{
    volatile int later = 0;
    int rc;

    if (__isauth()) {
        printf("TSTAUTH - the job step is authorized anyway .. SKIPPED\n");
        return 0;
    }

    rc = setjmp(escape);
    if (rc == 0) {
        service();
    }
    if (rc == 2) {
        printf("TSTAUTH - no READ on FACILITY SVC244 .. SKIPPED\n");
        return 0;
    }

    CHECK(__isauth(), "the lost holder authorized the step");

    RxNoPriv();
    CHECK(!__isauth(), "not authorized after RxNoPriv");

    rc = authTake(&later);
    CHECK_EQ(rc, 0, "a later holder takes it");
    CHECK(__isauth(), "authorized by the later holder");
    authDrop(&lost);
    CHECK(__isauth(), "the lost holder does not drop the later one");
    authDrop(&later);
    CHECK(!__isauth(), "not authorized after the later holder");

    authDrop(&lost);
    return mbt_test_summary("TSTAUTH");
}
