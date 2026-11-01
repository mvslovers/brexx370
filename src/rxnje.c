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

    if (pSubtaskInfo->nje_thread_id == 0) {
        pSubtaskInfo->nje_thread_id = subtaskStart(&subtask, (void *) pSubtaskInfo);
        if (pSubtaskInfo->nje_thread_id == 0) {
            // no subtask, so nothing will ever be queued; not sticky, the
            // next call tries to attach again
            setIntegerVariable("_RC", NJE_SUBTASK_FAILED);
            Licpy(ARGR, NJE_ERROR_EVENT);
            return;
        }
    }

    while (!pSubtaskInfo->isRunning && wakeUpCounter < 100) {
        sleepMs(10);
        wakeUpCounter++;
    }

    if (pSubtaskInfo->queue->items == 0) {
        // now we will reuse the wakeUpCounter
        wakeUpCounter = timeOut / 100;
        for (ii = 0; ii < wakeUpCounter; ii++) {
            sleepMs(100);
            if (pSubtaskInfo->stopRunning || pSubtaskInfo->errorRunning ||
                pSubtaskInfo->queue->items > 0) {
                break;
            }
        }
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

    rc = tsoCommand((char *) LSTR(*cmd), LLEN(*cmd));
    if (rc == 0x806000) {
        rc = -3;    // no NJE38 load module
    }

    LPFREE(cmd)

    Licpy(ARGR, rc);
}

// An exec that ends without this call leaves its subtask attached and gets
// system abend A03; documented behaviour (#328), as with VSAMIO.
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
        if (!pSubtaskInfo->stopRunning) {
            // a subtask that has not reached its wait loop yet sees the flag
            // and leaves; one that waits is posted
            pSubtaskInfo->stopRunning = TRUE;
            // no __NJERECEIVE yet: there is no subtask to end
            if (pSubtaskInfo->nje_thread_id != 0) {
                // the ECB exists only while the subtask is registered with
                // NJERLY, so it is not posted after an error
                if (pSubtaskInfo->nje_ecb != NULL &&
                    !pSubtaskInfo->errorRunning) {
                    postECB(pSubtaskInfo->nje_ecb);
                }
                rc = subtaskWait(pSubtaskInfo->nje_thread_id);
            }
        }
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

/* reset all nje stuff */
void RxNjeReset() {
    // stop all running subtasks => post ECBs
    // wait for the end of all subtasks

    // subtasks->buckets->head->next
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

/* msg must be NUL-terminated within its 121-byte buffer */
static void queueMsg(P_SUBTASK_INFO pSubtaskInfo, const char *msg) {
    char   *tmp = MALLOC(121,"QUEUED MSG");
    size_t  len = strlen(msg);

    if (tmp == NULL) {
        return;
    }
    if (len > 120) {
        len = 120;
    }
    memcpy(tmp, msg, len);
    tmp[len] = '\0';
    DQQUEUE(pSubtaskInfo->queue, tmp);
}

int subtask(void *input) {
    int rc;

    P_SUBTASK_INFO   pSubtaskInfo;
    char            msg[121];
    int             nje_token;

    pSubtaskInfo = (P_SUBTASK_INFO) input;

    // register user with NJE
    rc = njerly(&nje_token, NJE_REGISTER, pSubtaskInfo->userId);
    if (rc != 0) {
        // TODO: create error flags for every nje action
        pSubtaskInfo->errorRunning = TRUE;
        pSubtaskInfo->lastRC       = rc;

        subtaskEnd(rc);
        return   (rc);
    }

    // get ECB for registered user
    pSubtaskInfo->nje_ecb = (void *) (uintptr_t) njerly(&nje_token, NJE_GETECB, DUMMY);

    // check for already present message
    memset(msg, 0, sizeof(msg));
    rc = njerly(&nje_token, NJE_GETMSG, msg);
    if (rc == 0) {
        msg[sizeof(msg) - 1] = '\0';
        queueMsg(pSubtaskInfo, msg);

    } else if (rc != 4) {
        // TODO: create error flags for every nje action
        pSubtaskInfo->errorRunning = TRUE;
        pSubtaskInfo->lastRC       = rc;

        subtaskEnd(rc);
        return   (rc);
    }

    pSubtaskInfo->isRunning = TRUE;
    while(!pSubtaskInfo->stopRunning && !pSubtaskInfo->errorRunning) {
        rc = njerly(&nje_token, NJE_WAIT, DUMMY);
        if (rc == 0) {
            memset(msg, 0, sizeof(msg));
            rc = njerly(&nje_token, NJE_GETMSG, msg);
            if (rc == 0) {
                msg[sizeof(msg) - 1] = '\0';
                queueMsg(pSubtaskInfo, msg);
            }
        } else if (rc == 8) {
            pSubtaskInfo->stopRunning  = TRUE;
            pSubtaskInfo->lastRC       = rc;
        } else if (rc == 32) {
            pSubtaskInfo->stopRunning  = TRUE;
            pSubtaskInfo->lastRC       = rc;
        } else {
            // TODO: create error flags for every nje action
            pSubtaskInfo->errorRunning = TRUE;
            pSubtaskInfo->lastRC       = rc;
        }
    }
    pSubtaskInfo->isRunning = FALSE;

    rc = njerly(&nje_token, NJE_DEREGISTER, DUMMY);

    subtaskEnd(rc);
    return   (rc);
}
