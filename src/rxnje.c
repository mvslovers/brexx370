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

bool    njeInitialized  = FALSE;
bool    stcRunning      = FALSE;

HashMap *subtaks;

int subtask();

void postECB(void *ecb);

bool checkSTC() {
    // TODO: implement STC check here
    stcRunning =  TRUE;
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

    // to gather subtask information
    subtaks = hashMapNew(32);

    njeInitialized = TRUE;
}

void R_njereg  (__unused int func) {

    P_SUBTASK_INFO   pSubtaskInfo;
    DQueue          *queue;

    char            userId[8 + 1];

    if (ARGN != 1) {
        Lerror(ERR_INCORRECT_CALL, 0);
    }

    if (!stcRunning) {
        Lerror(ERR_NJE_NOT_ACTIVE, 0);
    }

    if (!njeInitialized) {
        Lerror(ERR_NJE_NOT_INIT, 0);
    }

    LASCIIZ(*ARG1);
    get_s(1);
    Lupper(ARG1);

    bzero(userId,9);
    memset (userId, ' ', 8);
    strncpy(userId, (const char *) LSTR(*ARG1), LLEN(*ARG1));

    pSubtaskInfo = (P_SUBTASK_INFO) hashMapGet(subtaks, userId);

    if (pSubtaskInfo == NULL) {
        pSubtaskInfo = MALLOC(sizeof(SUBTASK_INFO), "NJE SUBTASK INFO");
        bzero(pSubtaskInfo, sizeof(SUBTASK_INFO));

        // set user
        memset (pSubtaskInfo->userId, ' ', 8);
        strncpy(pSubtaskInfo->userId, (const char *) LSTR(*ARG1), LLEN(*ARG1));

        // set running flags
        pSubtaskInfo->isRunning   = FALSE;
        pSubtaskInfo->stopRunning = FALSE;

        // set message queue
        queue = MALLOC(sizeof(DQueue), "NJE MSG QUEUE");
        DQINIT(*queue);
        pSubtaskInfo->queue = queue;

        // put subtask info structure into our map
        hashMapSet(subtaks, pSubtaskInfo->userId, pSubtaskInfo);

        // userId not yes registered
        Licpy(ARGR, 0);
    } else {
        // userId already registered
        Licpy(ARGR, 24);
    }

}

void R_njerecv (__unused int func) {

    P_SUBTASK_INFO   pSubtaskInfo;

    char            userId[8 + 1];
    int             wakeUpCounter = 0;
    int             timeOut     = 5000;

    int             ii;

    if (ARGN != 1 && ARGN != 2) {
        Lerror(ERR_INCORRECT_CALL, 0);
    }

    if (!stcRunning) {
        Lerror(ERR_NJE_NOT_ACTIVE, 0);
    }

    if (!njeInitialized) {
        Lerror(ERR_NJE_NOT_INIT, 0);
    }

    // prepare userId parameter
    LASCIIZ(*ARG1);
    get_s(1);
    Lupper(ARG1);

    // get timeOut parameter
    if (ARGN == 2) {
        get_i(2, timeOut);
    }

    bzero  (userId, 9);
    memset (userId, ' ', 8);
    strncpy(userId, (const char *) LSTR(*ARG1), LLEN(*ARG1));

    pSubtaskInfo = hashMapGet(subtaks, userId);
    if (pSubtaskInfo == NULL) {
        Lerror(ERR_NJE_USER_NOT_REGISTERED, 0, LSTR(*ARG1));
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
        pSubtaskInfo->nje_thread_id = beginthread(&subtask, 0, (void *) pSubtaskInfo);
    }

    // TODO: testen
    //WaitForSingleEvent()
    while (!pSubtaskInfo->isRunning && wakeUpCounter < 100) {
        Sleep(10);
        wakeUpCounter++;
    }

    if (pSubtaskInfo->queue->items == 0) {
        // now we will reuse the wakeUpCounter
        wakeUpCounter = timeOut / 500;
        for (ii = 0; ii < wakeUpCounter; ii++) {
            Sleep(500);
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
        setVariable("_DATA", DQPop(pSubtaskInfo->queue));
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

    rc = systemTSO((char *) LSTR(*cmd));

    LPFREE(cmd)

    Licpy(ARGR, rc);
}

void R_njedereg(__unused int func) {
    int rc;

    P_SUBTASK_INFO   pSubtaskInfo;
    char            userId[8 + 1];

    if (ARGN != 1) {
        Lerror(ERR_INCORRECT_CALL, 0);
    }

    if (!stcRunning) {
        Lerror(ERR_NJE_NOT_ACTIVE, 0);
    }

    if (!njeInitialized) {
        Lerror(ERR_NJE_NOT_INIT, 0);
    }

    bzero(userId,9);
    memset (userId, ' ', 8);
    strncpy(userId, (const char *) LSTR(*ARG1), LLEN(*ARG1));

    pSubtaskInfo = hashMapGet(subtaks, userId);
    if (pSubtaskInfo != NULL) {
        postECB(pSubtaskInfo->nje_ecb);
        rc = syncthread(pSubtaskInfo->nje_thread_id);
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
    // make sure all users are deregistered
}

/* will be moved in to a generic source file, to be used everywhere */
void postECB(void *ecb) {
    RX_SVC_PARAMS params;

    params.SVC = 2;
    params.R0 = 0;
    params.R1 = (unsigned int) (uintptr_t) ecb;

    call_rxsvc(&params);
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

        endthread(rc);
        return   (rc);
    }

    // get ECB for registered user
    pSubtaskInfo->nje_ecb = (void *) njerly(&nje_token, NJE_GETECB, DUMMY);

    // check for already present message
    rc = njerly(&nje_token, NJE_GETMSG, msg);
    if (rc == 0) {
        DQPUSH(pSubtaskInfo->queue, msg);
    } else if (rc != 4) {
        // TODO: create error flags for every nje action
        pSubtaskInfo->errorRunning = TRUE;
        pSubtaskInfo->lastRC       = rc;

        endthread(rc);
        return   (rc);
    }

    pSubtaskInfo->isRunning = TRUE;
    while(!pSubtaskInfo->stopRunning && !pSubtaskInfo->errorRunning) {
        rc = njerly(&nje_token, NJE_WAIT, DUMMY);
        if (rc == 0) {
            rc = njerly(&nje_token, NJE_GETMSG, msg);
            if (rc == 0) {
                DQPUSH(pSubtaskInfo->queue, msg);
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

    rc = njerly(&nje_token, NJE_DEREGISTER, "");

    endthread(rc);
    return   (rc);
}
