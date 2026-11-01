/* -------------------------------------------------------------------------------------
 * PRIVILEGE's machinery: authorisation through SVC 244 and key 0 in problem
 * state, and its reset at the end of an exec. Moved from rxmvs.c (#302);
 * the prototypes are in rxmvsext.h, the REXX function R_privilege stays
 * there.
 * -------------------------------------------------------------------------------------
 */
#include <mvs/apf.h>
#include <mvs/mutex.h>
#include "rexx.h"
#include "rxmvsext.h"
#include "rxrac.h"
#include "rac.h"

/* whether PRIVILEGE('ON') is in effect */
int _authorisedGranted=0;

/* The authorisation of the job step, switched on by SVC 244. JSCBAUTH
 * belongs to the job step: every task of it, the NJE subtask included,
 * is authorised while one of them holds it (measured). So switching it
 * off is only allowed for the last holder, and that is what the count
 * keeps. A holder is a flag in the caller's own storage, set and cleared
 * under the mutex, so that a holder that is cleaned up for a subtask that
 * died cannot give it back twice. The flag holds the generation of the
 * take: authReset() ends a generation, and a flag of an earlier one (of a
 * stack frame that an abend threw away, or of a subtask that is still
 * running) counts for nothing any more. */
static CLIBMUTX authMtx = CLIBMUTX_INITIALIZER;
static int authCount = 0;
static int authSwitched = 0;
static int authGen = 1;

static void authSvc(int on)
{
    RX_SVC_PARAMS svc_parameter;

    svc_parameter.R0 = (uintptr_t) 0;
    svc_parameter.R1 = (uintptr_t) on;
    svc_parameter.SVC = 244;
    call_rxsvc(&svc_parameter);
}

/* rac_check() fills a cache without a lock, and the NJE subtask reaches it
 * from authTake(): every use goes through the mutex */
static int authCheck(void)
{
    int ok;

    mtxlock(&authMtx);
    ok = rac_check(FACILITY, SVC244, READ);
    mtxunlk(&authMtx);
    return ok;
}

/* 1 when SVC 244 may be issued, or the task is authorised anyway */
int authAvailable(void)
{
    return __isauth() || authCheck();
}

/* Authorise the job step for one service call: nothing to do in an APF
 * authorised task. Returns 0 when the call may go ahead, 8 when RAKF
 * denies FACILITY SVC244 or the SVC did not take effect (it returns
 * silently when RAKF denies, so TESTAUTH decides). *held tells authDrop()
 * whether this call counts; it is the only link between the two. */
int authTake(volatile int *held)
{
    int rc = 0;

    mtxlock(&authMtx);
    *held = 0;
    if (authCount == 0 && !__isauth()) {
        if (!rac_check(FACILITY, SVC244, READ)) {
            rc = 8;
        } else {
            authSvc(1);
            if (__isauth())
                authSwitched = 1;
            else
                rc = 8;
        }
    }
    if (rc == 0 && (authCount > 0 || authSwitched)) {
        authCount++;
        *held = authGen;
    }
    mtxunlk(&authMtx);
    return rc;
}

void authDrop(volatile int *held)
{
    mtxlock(&authMtx);
    if (*held == authGen && authCount > 0 && --authCount == 0 && authSwitched) {
        authSvc(0);
        authSwitched = 0;
    }
    *held = 0;
    mtxunlk(&authMtx);
}

/* Gives back whatever is still held, whoever holds it: a holder that lives
 * on the stack of a service call is gone when an abend ends the call, and
 * nobody can drop it. Only for the end of the exec, when every task of the
 * exec is done with it; the flags of holders that survive are of an earlier
 * generation, and authDrop() ignores them. */
void authReset(void)
{
    mtxlock(&authMtx);
    if (authSwitched) {
        authSvc(0);
        authSwitched = 0;
    }
    authCount = 0;
    authGen++;
    mtxunlk(&authMtx);
}

/* 1 when the task is authorised without any holder: APF, or an earlier
 * authorisation that is not ours */
static int authNative(void)
{
    int native;

    mtxlock(&authMtx);
    native = authCount == 0 && __isauth();
    mtxunlk(&authMtx);
    return native;
}

/* Leave the state PRIVILEGE('ON') set, if it is set: an exec may end,
 * or abend, without PRIVILEGE('OFF'), and every FREEMAIN in supervisor
 * state and key 0 then goes to the wrong subpool (S30A, S378, #191).
 * Tests _authorisedGranted first, so it costs no RAC call otherwise. The
 * authorisation of the step is given back last, whoever still holds it. */
void RxNoPriv(void)
{
    if (_authorisedGranted) {
        privilege(0);
    }
    authReset();
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

static int privHeld = 0;

int privilege(int state)
{
    int rc = 8;

    if (state == 1) {
        if (_authorisedGranted)
            return 0;
        if (!authCheck()) {
            return rc;
        }
        /* SET AUTHORIZED 1: the SVC did not take effect, so key 0 and
         * the flag must not follow */
        if (authTake(&privHeld) != 0) {
            return rc;
        }
        rc = keyZero(1);
        _authorisedGranted=1;
    } else if (state == 0) {
        rc = 0;                 /* it stayed 8: OFF always failed (#386) */
        if (_authorisedGranted == 1) {
            keyZero(0);

            /* Reset AUTHORIZED 0 */
            authDrop(&privHeld);
            _authorisedGranted = 0;
        }
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
    if (_authorisedGranted || authNative())
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
