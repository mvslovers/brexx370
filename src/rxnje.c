#include "rxnje.h"

#ifdef __CROSS__
#include "jccdummy.h"
#endif

#include "rexx.h"
#include "rxdefs.h"
#include "rxmvsext.h"
#include "lstring.h"
#include "lerror.h"
#include "ldefs.h"
#include "hashmap.h"
#include "util.h"
#include "subtask.h"
#include "rac.h"
#include "hostenv.h"

static njerly_func_p njerly;     // NJERLY entry point, LOADed on first use

extern RX_ENVIRONMENT_BLK_PTR env_block;

bool    njeInitialized  = FALSE;
bool    stcRunning      = FALSE;

HashMap *subtasks;

// TEMP will be removed with V2R5 and MultiUserSupport
char tempUserId[8+1];

int subtask(void *);

void postECB(void *ecb);

// the one message for a missing authorization, once per exec
static void notAuthMessage(void) {
    static bool shown = FALSE;

    if (!shown) {
        shown = TRUE;
        fprintf(STDERR, "\nBRX0010E - NJE38 NEEDS READ ACCESS TO FACILITY SVC244 "
                        "OR AN APF AUTHORIZED BREXX/370\n");
    }
}

bool checkSTC() {

    void ** psa;           // PSA     =>    0 / 0x00
    void ** cvt;           // FLCCVT  =>   16 / 0x10
    void ** fqcb;          // CVTFQCB =>  640 / 0x280
    // MAJOR
    void ** majfmin;       // MAJFMIN =>    8 / 0x8
    void ** majlmin;       // MAJLMIN =>   12 / 0xC
    void ** majname;       // MAJNAME =>   16 / 0x10
    // MINOR
    void ** minqcb;
    void ** minname;       // MINNAME =>   20 / 0x14

    psa     = 0;
    cvt     = psa[4];                       //  16
    fqcb    = cvt[160];                     // 640

    stcRunning = FALSE;

    while (fqcb != 0)
    {
        majname = fqcb + 4;                 // 16

        if (strncmp((char *)majname, "NJE38", 5) == 0)
        {
            majfmin = fqcb[2];              //  8
            majlmin = fqcb[3];              // 12

            // first minor qcb
            minqcb = majfmin;

            do
            {
                minname = minqcb + 5;       // 20
                // check minor queue name
                if (strncmp((char *)minname, "NJEINIT", 7) == 0)
                {
                    stcRunning = TRUE;
                }

                // if this is not the last minor qcb, point to the next
                if (minqcb != majlmin)
                {
                    minqcb = minqcb[0];
                }

            } while (minqcb != majlmin);
        }

        fqcb    = fqcb[0];
    }

    return stcRunning;
}

void R_njeinit (__unused int func) {

    // check availability of NJE38 started task
    checkSTC();

    if (!stcRunning) {
        Lerror(ERR_NJE_NOT_ACTIVE, 0);
    }

    if (findLoadModule(NJERLY_MOD)) {
        loadLoadModule(NJERLY_MOD, (void **) &njerly);
    } else {
        Lerror(ERR_NJERLY_NOT_FOUND, 0);
    }

    // event constants
    setIntegerVariable("#MSG", NJE_MSG_EVENT);
    setIntegerVariable("#STOP", NJE_STOP_EVENT);
    setIntegerVariable("#TIMEOUT", NJE_TIMEOUT_EVENT);
    setIntegerVariable("#ERROR", NJE_ERROR_EVENT);
    setIntegerVariable("#COMPLETE", NJE_COMPLETE_EVENT);

    // to gather subtask information
    subtasks = hashMapNew(1);
    njeInitialized = TRUE;
}

// ARG1 as the blank padded, upper case user id of 8 characters. Checked
// before the NJE38 state: userId and SUBTASK_INFO hold 8 characters.
static void getUserId(char userId[8 + 1]) {
    get_s(1);
    Lupper(ARG_OWN(1));

    if (LLEN(*ARG1) > 8) {
        Lerror(ERR_INCORRECT_CALL, 0);
    }

    memset(userId, ' ', 8);
    userId[8] = '\0';
    memcpy(userId, LSTR(*ARG1), LLEN(*ARG1));
}

void R_njereg  (__unused int func) {

    P_SUBTASK_INFO   pSubtaskInfo;
    DQueue          *queue;
    const char      *owner;

    char            userId[8 + 1];
    char            ownerId[8];

    if (ARGN != 1) {
        Lerror(ERR_INCORRECT_CALL, 0);
    }

    getUserId(userId);

    // only the logged-on user may receive his own messages (#492); an
    // address space without an ACEE has no logged-on user
    owner = rac_user();
    memset(ownerId, ' ', 8);
    memcpy(ownerId, owner, strlen(owner) > 8 ? 8 : strlen(owner));
    if (owner[0] == '\0' || memcmp(userId, ownerId, 8) != 0) {
        Lerror(ERR_NJE_USER_NOT_OWN, 0, ARG1);
    }

    if (!stcRunning) {
        Lerror(ERR_NJE_NOT_ACTIVE, 0);
    }

    if (!njeInitialized) {
        Lerror(ERR_NJE_NOT_INIT, 0);
    }

    // the subtask of the first __NJERECEIVE needs the authorization for
    // every call of NJERLY: better to know now than at the first receive
    if (!authAvailable()) {
        notAuthMessage();
        Licpy(ARGR, NJE_NOT_AUTH);
        return;
    }

    pSubtaskInfo = (P_SUBTASK_INFO) hashMapGet(subtasks, userId);

    if (pSubtaskInfo == NULL) {
        pSubtaskInfo = MALLOC(sizeof(SUBTASK_INFO), "NJE SUBTASK INFO");
        memset(pSubtaskInfo, 0, sizeof(SUBTASK_INFO));

        // set user
        memcpy(pSubtaskInfo->userId, userId, 8);

        // set running flags
        pSubtaskInfo->isRunning   = FALSE;
        pSubtaskInfo->stopRunning = FALSE;

        // set message queue
        queue = MALLOC(sizeof(DQueue), "NJE MSG QUEUE");
        DQINIT(*queue);
        pSubtaskInfo->queue = queue;

        // put subtask info structure into our map
        hashMapSet(subtasks, pSubtaskInfo->userId, pSubtaskInfo);

        // TEMP
        memset(tempUserId, 0, 9);
        strcpy(tempUserId, userId);

        // userId not yes registered
        Licpy(ARGR, 0);
    } else {
        // userId already registered
        Licpy(ARGR, 24);
    }

}

// The subtask has ended without saying so: an abend, which the thread
// recovery keeps from the main task. Whatever it held is given back here,
// for nobody else will.
static void watchSubtask(P_SUBTASK_INFO info) {
    if (info->nje_thread_id != 0 && !info->finished && !info->errorRunning &&
        subtaskEnded(info->nje_thread_id)) {
        info->lastRC       = NJE_SUBTASK_ABEND;
        info->errorRunning = TRUE;
        authDrop(&info->authHeld);
    }
}

// End of __NJERECEIVE: the subtask waits for messages with the job step
// authorized (NJE_WAIT cannot be called without), so the wait is ended here
// by posting the ECB of the user, and the authorization is given back before
// the exec runs on. A subtask that does not answer within 3 seconds sits in a
// NJERLY call that NJE38 does not complete; its authorization is taken back.
static void recvLeave(P_SUBTASK_INFO info) {
    int ii;
    void *ecb;

    info->receiving = FALSE;

    for (ii = 0; ii < 300 && info->authHeld; ii++) {
        ecb = info->nje_ecb;
        if (ecb != NULL && !info->stopRunning && !info->errorRunning) {
            postECB(ecb);
        }
        sleepMs(10);
        watchSubtask(info);
    }
    authDrop(&info->authHeld);
}

// Waits for the end of the subtask, if there is one, and returns its return
// code, NJE_SUBTASK_ABEND for one that ended by an abend. The handle is
// gone afterwards.
static int joinSubtask(P_SUBTASK_INFO info) {
    int rc = 0;

    if (info->nje_thread_id != 0) {
        rc = subtaskWait(info->nje_thread_id);
        info->nje_thread_id = 0;
        if (!info->finished) {
            rc = NJE_SUBTASK_ABEND;
            info->errorRunning = TRUE;
            info->lastRC       = rc;
        }
        authDrop(&info->authHeld);
    }
    return rc;
}

void R_njerecv (__unused int func) {

    P_SUBTASK_INFO   pSubtaskInfo;

    int             wakeUpCounter = 0;
    int             timeOut     = 5000;

    int             ii;

    if (ARGN > 1) {
        Lerror(ERR_INCORRECT_CALL, 0);
    }

    if (!stcRunning) {
        Lerror(ERR_NJE_NOT_ACTIVE, 0);
    }

    if (!njeInitialized) {
        Lerror(ERR_NJE_NOT_INIT, 0);
    }

    // get timeOut parameter
    if (ARGN == 1) {
        get_i(1, timeOut);
    }

    // TODO: iterate over all subtask infos
    pSubtaskInfo = hashMapGet(subtasks, tempUserId);
    if (pSubtaskInfo == NULL) {
        // Lerror() wants an Lstr for <user>, and cuts the text at an empty one
        static char noUser[] = "(none)";
        Lstr lsUser;

        LINITSTR(lsUser);
        LSTR(lsUser)    = (unsigned char *) (tempUserId[0] ? tempUserId : noUser);
        LLEN(lsUser)    = strlen((char *) LSTR(lsUser));
        LMAXLEN(lsUser) = LLEN(lsUser);

        Lerror(ERR_NJE_USER_NOT_REGISTERED, 0, &lsUser);
    }

    // subtask ended by operator or user
    if (pSubtaskInfo->stopRunning) {
        setIntegerVariable("_RC", pSubtaskInfo->lastRC);
        Licpy(ARGR, NJE_STOP_EVENT);
        return;
    }

    // subtask ended due to error
    if (pSubtaskInfo->errorRunning) {
        setIntegerVariable("_RC", pSubtaskInfo->lastRC);
        Licpy(ARGR, NJE_ERROR_EVENT);
        return;
    }

    // from here until recvLeave() the subtask may wait for messages with the
    // job step authorized; it never does so outside of this call
    pSubtaskInfo->receiving = TRUE;

    if (pSubtaskInfo->nje_thread_id == 0) {
        pSubtaskInfo->nje_thread_id = subtaskStart(&subtask, (void *) pSubtaskInfo);
        if (pSubtaskInfo->nje_thread_id == 0) {
            // no subtask, so nothing will ever be queued; not sticky, the
            // next call tries to attach again
            pSubtaskInfo->receiving = FALSE;
            setIntegerVariable("_RC", NJE_SUBTASK_FAILED);
            Licpy(ARGR, NJE_ERROR_EVENT);
            return;
        }
    }

    while (!pSubtaskInfo->isRunning && !pSubtaskInfo->errorRunning &&
           wakeUpCounter < 100) {
        sleepMs(10);
        wakeUpCounter++;
        watchSubtask(pSubtaskInfo);
    }

    if (pSubtaskInfo->queue->items == 0) {
        // now we will reuse the wakeUpCounter
        wakeUpCounter = timeOut / 100;
        for (ii = 0; ii < wakeUpCounter; ii++) {
            sleepMs(100);
            watchSubtask(pSubtaskInfo);
            if (pSubtaskInfo->stopRunning || pSubtaskInfo->errorRunning ||
                pSubtaskInfo->queue->items > 0) {
                break;
            }
        }
    }

    recvLeave(pSubtaskInfo);

    // subtask ended by operator or user
    if (pSubtaskInfo->stopRunning) {
        setIntegerVariable("_RC", pSubtaskInfo->lastRC);
        Licpy(ARGR, NJE_STOP_EVENT);
        return;
    }

    // subtask ended due to error
    if (pSubtaskInfo->errorRunning) {
        if (pSubtaskInfo->lastRC == NJE_NOT_AUTH) {
            notAuthMessage();
        }
        setIntegerVariable("_RC", pSubtaskInfo->lastRC);
        Licpy(ARGR, NJE_ERROR_EVENT);
        return;
    }

    if (pSubtaskInfo->queue->items > 0) {
        char * msg = DQPop(pSubtaskInfo->queue);
        setVariable("_DATA", msg);
        FREE(msg);

        Licpy(ARGR, NJE_MSG_EVENT);
        return;
    } else {
        Licpy(ARGR, NJE_TIMEOUT_EVENT);
        return;
    }

}

void R_njesend (__unused int func) {
    int rc;
    volatile int held = 0;

    PLstr cmd;

    if (ARGN != 3) {
        Lerror(ERR_INCORRECT_CALL, 0);
    }

    if (!stcRunning) {
        Lerror(ERR_NJE_NOT_ACTIVE, 0);
    }

    if (!njeInitialized) {
        Lerror(ERR_NJE_NOT_INIT, 0);
    }

    get_s(1)
    get_s(2)
    get_s(3)

    LASCIIZ(*ARG1)
    LASCIIZ(*ARG2)
    LASCIIZ(*ARG3)

    LPMALLOC(cmd)

    Lcat(cmd, "NJE38 MSG ");
    Lcat(cmd, (char *) LSTR(*ARG1));
    Lcat(cmd, " ");
    Lcat(cmd, (char *) LSTR(*ARG2));
    Lcat(cmd, " ");
    Lcat(cmd, (char *) LSTR(*ARG3));

    // the NJE38 command module needs the authorization for its MODESET; it
    // finds the job step authorized, so it does not ask for it itself
    if (authTake(&held) != 0) {
        notAuthMessage();
        rc = NJE_NOT_AUTH;
    } else {
        rc = tsoCommand((char *) LSTR(*cmd), LLEN(*cmd));
        authDrop(&held);
        if (rc == 0x806000) {
            rc = -3;    // no NJE38 load module
        }
    }

    LPFREE(cmd)

    Licpy(ARGR, rc);
}

// Ends the subtask: it sees the flag when it is parked, which it always is
// outside of __NJERECEIVE, deregisters the user and ends.
void R_njedereg(__unused int func) {
    int rc = 0;

    P_SUBTASK_INFO   pSubtaskInfo;
    char            userId[8 + 1];

    if (ARGN != 1) {
        Lerror(ERR_INCORRECT_CALL, 0);
    }

    getUserId(userId);

    if (!stcRunning) {
        Lerror(ERR_NJE_NOT_ACTIVE, 0);
    }

    if (!njeInitialized) {
        Lerror(ERR_NJE_NOT_INIT, 0);
    }

    pSubtaskInfo = hashMapGet(subtasks, userId);
    if (pSubtaskInfo != NULL) {
        pSubtaskInfo->stopRunning = TRUE;
        rc = joinSubtask(pSubtaskInfo);
    } else {
        Licpy(ARGR, 28);
        return;
    }

    Licpy(ARGR, rc);
}

/* register rexx functions to brexx/370 */
void RxNjeRegFunctions() {
    RxRegFunction("__NJEINIT", R_njeinit, 0);
    RxRegFunction("__NJEREGISTER", R_njereg, 0);
    RxRegFunction("__NJERECEIVE", R_njerecv, 0);
    RxRegFunction("__NJESEND", R_njesend, 0);
    RxRegFunction("__NJEDEREGISTER", R_njedereg, 0);
}

/* The end of the exec, also after an abend: the subtask does not outlive
 * the exec and does not leave the job step authorized (#505). An exec that
 * ended without __NJEDEREGISTER got system abend A03 for the subtask. */
void RxNjeReset(void) {
    P_SUBTASK_INFO pSubtaskInfo;
    int ii;

    if (subtasks == NULL) {
        return;
    }
    pSubtaskInfo = hashMapGet(subtasks, tempUserId);
    if (pSubtaskInfo == NULL || pSubtaskInfo->nje_thread_id == 0) {
        return;
    }

    // a wait in __NJERECEIVE that the abend interrupted
    recvLeave(pSubtaskInfo);

    pSubtaskInfo->stopRunning = TRUE;
    for (ii = 0; ii < 500 && !subtaskEnded(pSubtaskInfo->nje_thread_id); ii++) {
        sleepMs(10);
    }
    if (subtaskEnded(pSubtaskInfo->nje_thread_id)) {
        joinSubtask(pSubtaskInfo);
    } else {
        // does not end: the exec cannot wait for it, but must not leave
        // the authorization behind
        authDrop(&pSubtaskInfo->authHeld);
    }
}

void RxNjeGetNetId(char **netId)
{
    int rc;
    int nje_token = 0;

    char userId[8];
    const char *sUserId;

    // check availability of NJE38 started task
    checkSTC();

    // the caller's buffer holds 10 + 1 bytes: "-INACTIVE-"
    memset(*netId, 0, 11);

    // NJERLY must not be called while the started task is down, also
    // when an earlier use left it loaded
    if (!stcRunning) {
        strcpy(*netId, "-INACTIVE-");
        return;
    }

    if (findLoadModule(NJERLY_MOD)) {
        loadLoadModule(NJERLY_MOD, (void **) &njerly);
    }

    // without NJERLY there is nothing to call
    if (njerly == NULL) {
        strcpy(*netId, "-INACTIVE-");
        return;
    }

    // the user is registered by a __NJERECEIVE: NJE38 refuses a second
    // registration (rc 24), the node is known from the first
    if (subtasks != NULL && tempUserId[0]) {
        P_SUBTASK_INFO info = hashMapGet(subtasks, tempUserId);

        if (info != NULL && info->netId[0]) {
            memcpy(*netId, info->netId, 8);
            return;
        }
    }

    sUserId = rac_user();

    memset(&userId, ' ', 8);
    memcpy(&userId, sUserId, strlen(sUserId));

    rc = njerly(&nje_token, NJE_REGISTER, userId);

    // a failed register leaves no token to deregister
    if (rc != 0) {
        strcpy(*netId, "-INACTIVE-");
        return;
    }

    memcpy(*netId, (void *)(nje_token + 32), 8);

    njerly(&nje_token, NJE_DEREGISTER, userId);
}

void RxNjeGetVersion(char **version)
{
    int tmpPtr;

    if (!findLoadModule(NJERLY_MOD))
    {
        loadLoadModule(NJERLY_MOD, (void **) &njerly);
    }

    memset(*version, 0, 22);

    if (njerly != NULL)
    {
        tmpPtr = (int) njerly;

        //   At EPA+14  (0x0E)  for length=6,  version number. Format:  DC  CL6’v2.2.2’
        //   At EPA+20  (0x14)  for length=8,  assembly date.  Format:  DC  CL8’MM/DD/YY’
        //   At EPA+29  (0x1D)  for length=5,  assembly time.  Format:  DC  CL5’HH.MM’

        memcpy(*version,      (void*)(tmpPtr + 14), 6);
        memcpy(*version +  6, " ", 1);
        memcpy(*version +  7, (void*)(tmpPtr + 20), 8);
        memcpy(*version + 15, " ", 1);
        memcpy(*version + 16, (void*)(tmpPtr + 29), 5);
    } else {
        memcpy(*version, "NO NJE38 FOUND", 14);
    }
}

/* will be moved in to a generic source file, to be used everywhere */
void postECB(void *ecb) {
    RX_SVC_PARAMS params;

    params.SVC = 2;
    params.R0 = 0;
    params.R1 = (unsigned int) (uintptr_t) ecb;

    call_rxsvc(&params);
}

// One call of NJERLY with the job step authorized, only for its duration.
static int callNjerly(P_SUBTASK_INFO info, int func, char *arg) {
    int rc;

    if (authTake(&info->authHeld) != 0) {
        return NJE_NOT_AUTH;
    }
    if (func == NJE_DEREGISTER) {
        info->netId[0] = '\0';
    }
    rc = njerly(&info->nje_token, func, arg);
    if (func == NJE_REGISTER && rc == 0) {
        memcpy(info->netId, (void *)(info->nje_token + 32), 8);
        info->netId[8] = '\0';
    }
    authDrop(&info->authHeld);
    return rc;
}

static int leave(P_SUBTASK_INFO info, int rc) {
    info->finished = TRUE;
    subtaskEnd(rc);
    return rc;
}

static void queueMsg(P_SUBTASK_INFO info, char *msg) {
    char   *tmp = MALLOC(121,"QUEUED MSG");
    strcpy(tmp, msg);
    DQQUEUE(info->queue, tmp);
}

int subtask(void *input) {
    int rc;

    P_SUBTASK_INFO   pSubtaskInfo;
    char            msg[121];

    pSubtaskInfo = (P_SUBTASK_INFO) input;

    // register user with NJE
    rc = callNjerly(pSubtaskInfo, NJE_REGISTER, pSubtaskInfo->userId);
    if (rc != 0) {
        // TODO: create error flags for every nje action
        pSubtaskInfo->errorRunning = TRUE;
        pSubtaskInfo->lastRC       = rc;

        return leave(pSubtaskInfo, rc);
    }

    // get ECB for registered user
    rc = callNjerly(pSubtaskInfo, NJE_GETECB, DUMMY);
    if (rc < 4096) {
        // an address is expected, not a return code
        pSubtaskInfo->errorRunning = TRUE;
        pSubtaskInfo->lastRC       = rc ? rc : NJE_SUBTASK_FAILED;

        callNjerly(pSubtaskInfo, NJE_DEREGISTER, DUMMY);
        return leave(pSubtaskInfo, pSubtaskInfo->lastRC);
    }
    pSubtaskInfo->nje_ecb = (void *) (uintptr_t) rc;

    // check for already present message
    rc = callNjerly(pSubtaskInfo, NJE_GETMSG, msg);
    if (rc == 0) {
        queueMsg(pSubtaskInfo, msg);

    } else if (rc != 4) {
        // TODO: create error flags for every nje action
        pSubtaskInfo->errorRunning = TRUE;
        pSubtaskInfo->lastRC       = rc;

        pSubtaskInfo->nje_ecb = NULL;
        callNjerly(pSubtaskInfo, NJE_DEREGISTER, DUMMY);
        return leave(pSubtaskInfo, rc);
    }

    pSubtaskInfo->isRunning = TRUE;
    while(!pSubtaskInfo->stopRunning && !pSubtaskInfo->errorRunning) {
        // NJE_WAIT blocks with the authorization on, so it is called only
        // while __NJERECEIVE is waiting for messages
        if (!pSubtaskInfo->receiving) {
            sleepMs(25);
            continue;
        }

        // an ECB posted by the end of the last __NJERECEIVE is stale; the
        // flags are tested again, for a post between them and the clear
        // would be lost
        *(volatile int *) pSubtaskInfo->nje_ecb = 0;
        if (!pSubtaskInfo->receiving || pSubtaskInfo->stopRunning) {
            continue;
        }

        rc = callNjerly(pSubtaskInfo, NJE_WAIT, DUMMY);
        if (rc == 0) {
            rc = callNjerly(pSubtaskInfo, NJE_GETMSG, msg);
            if (rc == 0) {
                queueMsg(pSubtaskInfo, msg);
            }
        } else if (rc == 8) {
            pSubtaskInfo->stopRunning  = TRUE;
            pSubtaskInfo->lastRC       = rc;
        } else if (rc == 32) {
            // the end of __NJERECEIVE or __NJEDEREGISTER posted the ECB
            if (pSubtaskInfo->stopRunning) {
                pSubtaskInfo->lastRC   = rc;
            }
        } else {
            // TODO: create error flags for every nje action
            pSubtaskInfo->errorRunning = TRUE;
            pSubtaskInfo->lastRC       = rc;
        }
    }
    pSubtaskInfo->isRunning = FALSE;

    // nobody posts the ECB of a user who is going to be deregistered
    pSubtaskInfo->nje_ecb = NULL;
    rc = callNjerly(pSubtaskInfo, NJE_DEREGISTER, DUMMY);

    return leave(pSubtaskInfo, rc);
}
