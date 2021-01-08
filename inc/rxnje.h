#ifndef __RXNJE_H
#define __RXNJE_H

#ifdef JCC
#include "mvsutils.h"
#include "rxmvsext.h"

#define __unused
#endif

#define NJETOKEN        int


/* events */
#define NJE_MSG_EVENT       1
#define NJE_STOP_EVENT      2
#define NJE_ERROR_EVENT     3


/* external NJERLY stuff */

/* defines */
#define NJERLY          "NJERLY  "
#define DUMMY           "DUMMY"
#define REGISTER        1
#define DEREGISTER      2
#define WAIT            3
#define GETMSG          4
#define GETECB          5

char        njerlyModuleName[8] = "NJERLY  ";

/* external function */
typedef int njerly_func_t (int*, int, char*);
typedef     njerly_func_t * njerly_func_p;
static      njerly_func_p njerly;

/* exported functions */
void RxNjeRegFunctions();
void ResetNje();

#endif //__RXNJE_H
