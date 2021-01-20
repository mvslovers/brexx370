#include "rxnje.h"

#ifdef __CROSS__
#include "jccdummy.h"
#else
#include "process.h"
#endif

#include "rexx.h"
#include "rxdefs.h"
#include "rxmvsext.h"
#include "lstring.h"
#include "lerror.h"
#include "util.h"

NJETOKEN nje_token;
EVENT    data_event;
void     *stop_event;

bool njeInit     = FALSE;
bool hasData     = FALSE;
bool stopWaiting = FALSE;
bool isRunning   = FALSE;

int subtask();

int deregisterNjeToken();

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

        data_event = CreateEvent(0);

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
           stop_event=(void *) njerly(&nje_token,NJE_GETECB,DUMMY);
           printf("ECB %p\n",stop_event);
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
                printf("FOO> WILL START SUBTASK \n");
                beginthread(&subtask, 0, NULL);
            }

            if (!hasData) {
                int irc,i;
                printf("FOO> SLEEPING %d MS \n", timeOut);
                for (i = 0; i < tcount; i ++) {
                    Sleep(500);
                    if (hasData) goto data_arrived;
                    if (stopWaiting) goto stop;
                }
                printf("FOO> TIMEOUT Occurred\n");
                Licpy(ARGR, NJE_TIMEOUT_EVENT);
                /* send back TIME_OUT_EVENT */
                return;

                printf("FOO> SLEEPING %d MS \n", timeOut);
                irc = WaitForSingleEvent(data_event, timeOut);
                printf("FOO> WAKEUP WITH RC(%d)\n", irc);
                if (EventStatus(data_event) == 1) {
                    ResetEvent(data_event);
                    printf("FOO> DATA_EVENT RESET\n", irc);
                }
            }
            stop:
            if (stopWaiting) {
                printf("FOO> GOT STOP EVENT\n");
                Licpy(ARGR, NJE_STOP_EVENT);

                /* send back STOP_EVENT */
                return;
            }
            data_arrived:
            if (hasData) {
                /* get the message */
                hasData = FALSE;
                rc = njerly(&nje_token, NJE_GETMSG, msg);
                if (rc == 0) {
                    setVariable("_DATA", msg);
                    Licpy(ARGR, NJE_MSG_EVENT);

                    /* send back MSG_EVENT */
                    return;
                } else {
                    printf("FOO> GOT RC(%d)\n", rc);
                    setIntegerVariable("_RC", rc);

                    Licpy(ARGR, NJE_ERROR_EVENT);

                    /* send back ERROR_EVENT */
                    return;
                }
            } else {
                Licpy(ARGR, NJE_TIMEOUT_EVENT);

                /* send back TIME_OUT_EVENT */
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

    printf("FOO> calling '%s' \n", LSTR(*cmd));

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
    unsigned char firstb;

    DumpHex((char *) stop_event,4);
    ((unsigned char *) stop_event)[0]=0x40;
    DumpHex((char *) stop_event,4);
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

int subtask() {

    int rc = 0;

    printf("FOO> SUBTASK STARTED\n");

    isRunning = TRUE;

    while (!stopWaiting ) {

        while(hasData) {
            Sleep(100);
        }

        rc = njerly(&nje_token, NJE_WAIT, "DUMMY");
        printf("FOO> BINGO WAIT RETURNED WITH RC(%d)\n", rc);
        if (rc == 0) {
            hasData = TRUE;
            SetEvent(data_event);
            printf("FOO> DATA_EVENT SEND\n");
        } else if (rc == 8 ) {
            stopWaiting = TRUE;
            // not yet used, could be used for differentiation in the main task
       //   SetEvent(stop_event);
            printf("FOO> STOP_EVENT SEND\n");
        }
    }

    printf("FOO> SUBTASK ENDED\n");

    return (0);
}
