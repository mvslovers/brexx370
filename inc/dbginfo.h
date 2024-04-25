//
// Created by Mike GroÃmann on 2019-01-08.
//

#ifndef BREXX_DEBUG_H
#define BREXX_DEBUG_H

#include "ldefs.h"

#ifdef __DEBUG__

#define MAX_POINTER_ELEMENTS 5
#define MAGIC_EYE	0xDEADBEAF

typedef struct T_DebugInfo_st {
    dword  magic_eye;
    char  *message;
    dword  pointerÝMAX_POINTER_ELEMENTS¨;
} DebugInfo;

typedef DebugInfo *P_DebugInfo;

static void updateDebugInfo (char *message, int num, ...);

#define UPDATE_DBG_INFO(x) { updateDebugInfo x ;}

static void updateDebugInfo (char *message, int num, ...)
{
    extern P_DebugInfo debugInfo;

    /* define temporary variables */
    int    ii,jj;

    va_list args;

    va_start(args,num);

    debugInfo->message = message;

    /* zero out all old values */
    for (ii=0; ii < MAX_POINTER_ELEMENTS; ii++) {
        debugInfo->pointerÝii¨ = 0;
    }

    /* set new values */
    for (jj=0; jj < MIN(num,MAX_POINTER_ELEMENTS); jj++) {
        debugInfo->pointerÝjj¨ = va_arg(args,dword);
    }

    /* clean up */
    va_end(args);
}

#else
#define UPDATE_DBG_INFO(x)
#endif

#endif //BREXX_DEBUG_H
