#include "rxnje.h"

#ifdef __CROSS__
#include "jccdummy.h"
#endif


#include "rexx.h"
#include "rxdefs.h"
#include "rxmvsext.h"
#include "lstring.h"
#include "lerror.h"

NJETOKEN nje_token;
NJEECB   nje_ecb;

bool njeInit     = FALSE;
bool hasData     = FALSE;
bool stopWaiting = FALSE;
bool isRunning   = FALSE;

long tid;
int subtask();

int deregisterNjeToken();
int postECB(void *ecb);

void ResetNje() {
    if (njeInit) {
        deregisterNjeToken();
    }
}

bool testNJE() {
    // TODO: implement STC check here
    return TRUE;
}

void R_njeinit(__unused int func) {

    if (findLoadModule(NJERLY)) {
        loadLoadModule(NJERLY, (void **) &njerly);

        // event constants
        setIntegerVariable("#MSG",   NJE_MSG_EVENT);
        setIntegerVariable("#STOP",  NJE_STOP_EVENT);
        setIntegerVariable("#TIMEOUT", NJE_TIMEOUT_EVENT);
        setIntegerVariable("#ERROR", NJE_ERROR_EVENT);

        // check availability of hercules tcp facility
        njeInit = testNJE();
        if (!njeInit) Lerror(ERR_NJE_NOT_ACTIVE, 0);

    } else {
        Lerror(ERR_NJERLY_NOT_FOUND, 0);
    }

}

void R_njereg(int func)    {
    int rc = 0;

    char userId[9];

    if (ARGN != 1) {
        Lerror(ERR_INCORRECT_CALL,0);
    }

    LASCIIZ(*ARG1);
    get_s(1);
    Lupper(ARG1);

    memset(userId, ' ', 9);
    strncpy(userId, (const char *) LSTR(*ARG1), LLEN(*ARG1));

    if (njeInit) {
        rc = njerly(&nje_token, NJE_REGISTER, userId);
        if (rc==0) {
           nje_ecb = (void *) njerly(&nje_token,NJE_GETECB,DUMMY);
        }
    } else {
        Lerror(ERR_NJE_NOT_INIT, 0);
    }

    Licpy(ARGR, rc);
}

void R_njerecv(int func)   {
    int rc, tcount, stop=5;

    int timeOut = 5000;

    char msg[121];

    if (ARGN > 1) {
        Lerror(ERR_INCORRECT_CALL,0);
    }

    if (ARGN == 1) {
        get_i(1, timeOut);
    }

    tcount=timeOut/500;
    if (njeInit) {
        /* try to get a message */
        if (hasData) goto data_arrived;
        else {
            hasData = FALSE;

            /* wait for incoming messag */
            // rc = njerly(&nje_token, WAIT, "DUMMY");

            if (!isRunning) {
                tid = beginthread(&subtask, 0, NULL);
            }

            //1.
            if (!hasData) {
                int irc,i;
                for (i = 0; i < tcount; i ++) {
                    Sleep(500);
                    if (hasData) goto data_arrived;
                    if (stopWaiting) goto stop;
                }

                /* send back TIME_OUT_EVENT */
                Licpy(ARGR, NJE_TIMEOUT_EVENT);
                return;
            }
            stop:
            if (stopWaiting) {

                /* send back STOP_EVENT */
                Licpy(ARGR, NJE_STOP_EVENT);
                return;
            }
            data_arrived:
            if (hasData) {
                /* get the message */
                hasData = FALSE;
                rc = njerly(&nje_token, NJE_GETMSG, msg);
                if (rc == 0) {
                    setVariable("_DATA", msg);

                    /* send back MSG_EVENT */
                    Licpy(ARGR, NJE_MSG_EVENT);
                    return;
                } else {
                    setIntegerVariable("_RC", rc);

                    /* send back ERROR_EVENT */
                    Licpy(ARGR, NJE_ERROR_EVENT);
                    return;
                }
            } else {
                /* send back TIME_OUT_EVENT */
                Licpy(ARGR, NJE_TIMEOUT_EVENT);
                return;
            }
        }
    } else {
        Lerror(ERR_NJE_NOT_INIT, 0);
    }
}

void R_njesend(int func)   {
    int rc = 0;

    PLstr cmd;

    void *parms[3];

    // check arg count
    if (ARGN != 3) {
        Lerror(ERR_INCORRECT_CALL,0);
    }

    // check initialization state
    if (!njeInit) {
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
    Lcat(cmd, (char *)LSTR(*ARG1));
    Lcat(cmd, " ");
    Lcat(cmd, (char *)LSTR(*ARG2));
    Lcat(cmd, " ");
    Lcat(cmd, (char *)LSTR(*ARG3));

    rc = systemTSO(LSTR(*cmd));

    LPFREE(cmd)

    Licpy(ARGR, rc);
}

void R_njedereg(int func)  {
    int rc;

    if (ARGN != 1) {
        Lerror(ERR_INCORRECT_CALL,0);
    }

    rc = deregisterNjeToken();

    Licpy(ARGR, rc);
}

void R_njedereg2(int func) {
    int rc = 4;

    if (ARGN != 1) {
        Lerror(ERR_INCORRECT_CALL,0);
    }

    if (NJERLY != NULL) {
        rc = njerly(&nje_token, NJE_DEREGISTER, "DUMMY");
    }

    Licpy(ARGR, rc);
}

void R_njestop(int func) {
    int rc;

    if (ARGN != 0) {
        Lerror(ERR_INCORRECT_CALL,0);
    }

    postECB(nje_ecb);

    rc = syncthread(tid);

    printf("FOO> in R_njestop(): subtask ended with RC(%d)\n", rc);
}

/* register rexx functions to brexx/370 */
void RxNjeRegFunctions() {
    RxRegFunction("__NJEINIT", R_njeinit, 0);
    RxRegFunction("__NJEREGISTER", R_njereg, 0);
    RxRegFunction("__NJERECEIVE", R_njerecv, 0);
    RxRegFunction("__NJESEND", R_njesend, 0);
    RxRegFunction("__NJEDEREGISTER", R_njedereg, 0);
    RxRegFunction("__NJEDEREGISTER2", R_njedereg2, 0);
    RxRegFunction("__NJESTOP", R_njestop, 0);
}

int deregisterNjeToken() {
    int rc = 0;

    void *parms[3];

    if (njeInit) {
        parms[0] = (void *) &nje_token;
        parms[1] = (void *) NJE_DEREGISTER;
        parms[2] = (void *) "DUMMY";

      //rc = njerly(&njetoken, DEREGISTER, "DUMMY");
        rc = linkLoadModule(NJERLY, parms, 0);
    }

    return rc;
}

/* will be moved in to a generic source file, to be used everywhere */
int postECB(void *ecb) {
    RX_SVC_PARAMS params;

    params.SVC = 2;
    params.R0  = 0;
    params.R1  = (unsigned int) ecb;

    call_rxsvc(&params);

}

int subtask() {
    int rc;

    isRunning = TRUE;

    while (!stopWaiting ) {

        while(hasData) {
            Sleep(100);
        }

        rc = njerly(&nje_token, NJE_WAIT, "DUMMY");
        if (rc == 0) {
            hasData = TRUE;
        } else if (rc == 8 ) {
            stopWaiting = TRUE;
        } else if (rc == 32 ) {
            stopWaiting = TRUE;
        } else {
            stopWaiting = TRUE;
            printf("ERROR IN NJERLY WAIT - RC(%d) \n", rc);
        }
    }

    endthread(rc);

    return (rc);
}
