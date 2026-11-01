#ifndef __RXNJE_H
#define __RXNJE_H

#include "dqueue.h"

#define NJETOKEN            int
#define NJEECB              void *

#define MAX_SUBTASKS        1

/* events */
#define NJE_MSG_EVENT       1
#define NJE_STOP_EVENT      2
#define NJE_TIMEOUT_EVENT   3
#define NJE_ERROR_EVENT     4
#define NJE_COMPLETE_EVENT  5

/* _RC after #ERROR when the subtask could not be attached */
#define NJE_SUBTASK_FAILED  (-1)
/* _RC after #ERROR when the subtask ended by an abend */
#define NJE_SUBTASK_ABEND   (-2)
/* returned by __NJEREGISTER and __NJESEND, _RC after #ERROR: RAKF denies
 * READ on FACILITY SVC244 and BREXX is not APF authorised (as the -5 of
 * ADDRESS COMMAND and ADDRESS CONSOLE) */
#define NJE_NOT_AUTH        (-5)

/* external NJERLY stuff */

/* defines */
#define NJERLY_MOD          "NJERLY  "
#define DUMMY           ""

#define NJE_REGISTER        1
#define NJE_DEREGISTER      2
#define NJE_WAIT            3
#define NJE_GETMSG          4
#define NJE_GETECB          5

/* external function */
typedef int njerly_func_t (int*, int, char*);
typedef     njerly_func_t * njerly_func_p;

typedef struct {
    char        userId[8+1];
    NJETOKEN    nje_token;
    char        netId[8+1]; /* node of the NJE38 registration, "" while none */
    NJEECB      nje_ecb;
    long        nje_thread_id;
    DQueue      *queue;
    volatile bool isRunning;
    volatile bool stopRunning;
    volatile bool errorRunning;
    volatile bool receiving;    /* a __NJERECEIVE is in progress: the subtask may run authorised */
    volatile bool joining;      /* the main task waits for the subtask to end: it may deregister */
    volatile bool finished;     /* the subtask left by its own end, not by an abend */
    volatile int  authHeld;     /* the subtask holds the authorisation, see authTake() */
    volatile int  lastRC;
} SUBTASK_INFO, *P_SUBTASK_INFO;

/* exported functions */
void RxNjeRegFunctions();
void RxNjeReset(void);
void RxNjeGetNetId(char **netId);
void RxNjeGetVersion(char **version);

#endif //__RXNJE_H
