#include "rxnje.h"
#include "rexx.h"
#include "rxdefs.h"
#include "rxmvsext.h"
#include "lstring.h"
#include "lerror.h"

NJETOKEN nje_token;

bool njeInit = FALSE;

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
        setIntegerVariable("#ERROR", NJE_ERROR_EVENT);

        // check availability of hercules tcp facility
        njeInit = testNJE();
        if (!njeInit) Lerror(ERR_NJE_NOT_ACTIVE, 0);
    } else {
        Lerror(ERR_NJERLY_NOT_FOUND, 0);
    }

}

void R_njereg(int func) {
    int rc;

    char userId[9];

    if (ARGN != 1) {
        Lerror(ERR_INCORRECT_CALL,0);
    }

    LASCIIZ(*ARG1);
    get_s(1);
    Lupper(ARG1);

    memset(userId, ' ', 9);
    strncpy(userId, (const char *) LSTR(*ARG1), LLEN(*ARG1));

    rc = njerly(&nje_token, REGISTER, userId);

    Licpy(ARGR, rc);
}

void R_njerecv(int func) {
    int rc = 0;

    char msg[121];

    if (ARGN != 0) {
        Lerror(ERR_INCORRECT_CALL,0);
    }

    if (NJERLY != NULL) {
        /* try to get a message */
        rc = njerly(&nje_token, GETMSG, msg);
        if (rc == 0) {
            setVariable("_DATA", msg);
            Licpy(ARGR, NJE_MSG_EVENT);

            /* send back MSG_EVENT */
            return;
        }

        if (rc == 4) {
            /* wait for incoming messag */
            rc = njerly(&nje_token, WAIT, "DUMMY");
            if (rc == 0) {
                /* get the message */
                rc = njerly(&nje_token, GETMSG, msg);
                if (rc == 0) {
                    setVariable("_DATA", msg);
                    Licpy(ARGR, NJE_MSG_EVENT);

                    /* send back MSG_EVENT */
                    return;
                }
            } else if (rc == 8) {
                setVariable("_DATA", "From LOCAL(SYSOP): STOP COMMAND ISSUED");
                Licpy(ARGR, NJE_STOP_EVENT);

                /* send back STOP_EVENT */
                return;
            }
            setIntegerVariable("_RC", rc);

            /* send back ERROR_EVENT */
            Licpy(ARGR, NJE_ERROR_EVENT);
        }
    }
}

void R_njedereg(int func) {
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
        rc = njerly(&nje_token, DEREGISTER, "DUMMY");
    }

    Licpy(ARGR, rc);
}

/* register rexx functions to brexx/370 */
void RxNjeRegFunctions() {
    RxRegFunction("__NJEINIT",      R_njeinit, 0);
    RxRegFunction("__NJEREGISTER",  R_njereg, 0);
    RxRegFunction("__NJERECEIVE",   R_njerecv, 0);
    RxRegFunction("__NJEDEREGISTER",R_njedereg, 0);
    RxRegFunction("__NJEDEREGISTER2",R_njedereg2, 0);
} /* RxNjeRegFunctions() */

int deregisterNjeToken() {
    int rc = 0;

    void *parms[3];

    if (njerly != NULL) {
        parms[0] = (void *) &nje_token;
        parms[1] = (void *) DEREGISTER;
        parms[2] = (void *) "DUMMY";

      //rc = njerly(&njetoken, DEREGISTER, "DUMMY");
        rc = linkLoadModule(NJERLY, parms, 0);
    }

    return rc;
}