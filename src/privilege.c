/* -------------------------------------------------------------------------------------
 * PRIVILEGE's machinery: authorisation through SVC 244 and key 0 in problem
 * state, and its reset at the end of an exec. Moved from rxmvs.c (#302);
 * the prototypes are in rxmvsext.h, the REXX function R_privilege stays
 * there.
 * -------------------------------------------------------------------------------------
 */
#include <mvs/apf.h>
#include "rexx.h"
#include "rxmvsext.h"
#include "rxrac.h"
#include "rac.h"

/* whether the task was APF authorised before PRIVILEGE (-1: not asked
 * yet), and whether PRIVILEGE('ON') is in effect */
int _authorisedNative=-1;
int _authorisedGranted=0;

/* Leave the state PRIVILEGE('ON') set, if it is set: an exec may end,
 * or abend, without PRIVILEGE('OFF'), and every FREEMAIN in supervisor
 * state and key 0 then goes to the wrong subpool (S30A, S378, #191).
 * Tests _authorisedGranted first, so it costs no RAC call otherwise. */
void RxNoPriv(void)
{
    if (_authorisedGranted) {
        privilege(0);
    }
}

/* Key 0 in problem state, and back (privilege()): JCC's _modeset(0) and
 * _modeset(1). Supervisor state with key 0 makes MVS map GETMAIN and
 * FREEMAIN of subpool 0 to subpool 252, and libc370's free() then
 * abended S30A/S378 (#191). __prob() sets a key only from supervisor
 * state, hence two steps each way. Nothing that calls privilege() needs
 * supervisor state itself: RXCPCMD switches on its own, SVC 34 needs the
 * authorisation only. */
static unsigned char savedKey = PSWKEY8;

static int keyZero(int on)
{
    int rc;

    if (on)
        rc = __super(PSWKEY0, &savedKey);
    else
        rc = __super(savedKey, NULL);
    if (rc == 0)
        rc = __prob(PSWKEYNONE, NULL);
    return rc;
}

int privilege(int state)
{
    int rc = 8;

    RX_SVC_PARAMS svc_parameter;

    if (!rac_check(FACILITY, SVC244, READ)) {
        return rc;
    }

    // get current authorization state
    if (_authorisedNative == -1)
        _authorisedNative = __isauth() ? 1 : 0;

    if (state == 1) {
        /* SET AUTHORIZED 1 */
        if (_authorisedNative == 0) {
            svc_parameter.R0 = (uintptr_t) 0;
            svc_parameter.R1 = (uintptr_t) 1;
            svc_parameter.SVC = 244;
            call_rxsvc(&svc_parameter);

            rc = 0;
        }

        /* MODSET KEY=ZERO
        svc_parameter.R0 = (uintptr_t) 0;
        svc_parameter.R1 = (uintptr_t) 0x30; // DC    B'00000000 00000000 00000000 00110000'
        svc_parameter.SVC = 107;
        call_rxsvc(&svc_parameter);
        */
        rc = keyZero(1);
        _authorisedGranted=1;
    } else if (state == 0) {
        rc = 0;                 /* it stayed 8: OFF always failed (#386) */
    }
    if (state == 0 && _authorisedGranted == 1) {
        /* MODSET KEY=NZERO
        svc_parameter.R0 = (uintptr_t) 0;
        svc_parameter.R1 = (uintptr_t) 0x20; // DC    B'00000000 00000000 00000000 00100000'
        svc_parameter.SVC = 107;
        call_rxsvc(&svc_parameter);
        */
        keyZero(0);

        /* Reset AUTHORIZED 0 */
        if (_authorisedNative == 0) {
            svc_parameter.R0 = (uintptr_t) 0;
            svc_parameter.R1 = (uintptr_t) 0;
            svc_parameter.SVC = 244;
            call_rxsvc(&svc_parameter);
        }
        _authorisedGranted = 0;
    }

    return rc;
}

/* The authorisation one service call needs (ADDRESS COMMAND, ADDRESS
 * CONSOLE, CONSOLE(), SYSVAR('SYSCP')): nothing to do in an APF
 * authorised task or under PRIVILEGE('ON'), privilege(1) otherwise.
 * Returns 0 when the call may go ahead, 8 when RAKF denies FACILITY
 * SVC244 and the restricted SVC must not be issued (S047, #368).
 * *taken tells privDrop() whether it set anything: a PRIVILEGE('ON') of
 * the exec stays in effect after the call. */
int privTake(int *taken)
{
    int rc;

    *taken = 0;
    if (_authorisedGranted || __isauth())
        return 0;
    rc = privilege(1);
    *taken = _authorisedGranted;
    return rc == 0 ? 0 : 8;
}

void privDrop(int taken)
{
    if (taken)
        privilege(0);
}
