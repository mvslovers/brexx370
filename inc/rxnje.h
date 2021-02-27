#ifndef __RXNJE_H
#define __RXNJE_H

#ifdef JCC
#include "mvsutils.h"
#include "rxmvsext.h"

#define __unused
#endif

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
static      njerly_func_p njerly;

typedef struct {
    char        userId[8+1];
    NJETOKEN    nje_token;
    NJEECB      nje_ecb;
    long        nje_thread_id;
    DQueue      *queue;
    bool        isRunning;
    bool        stopRunning;
    bool        errorRunning;
    int         lastRC;
} SUBTASK_INFO, *P_SUBTASK_INFO;

/* exported functions */
void RxNjeRegFunctions();
void RxNjeReset();

#endif //__RXNJE_H
