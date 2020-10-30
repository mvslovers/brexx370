#ifndef EXTERNAL_H
#define EXTERNAL_H
#include "lstring.h"

#define MAX_ARGS    15

typedef struct trx_ext_params_r15 {
    void* moduleName;
    void* dcbAddress;
} RX_EXT_PARAMS_R15, *RX_EXT_PARAMS_R15_PTR;

typedef struct trx_ext_params_r1 {
    void* ptr[1];
} RX_EXT_PARAMS_R1, *RX_EXT_PARAMS_R1_PTR;

int callExternalFunction(char *functionName, char* arguments[MAX_ARGS], int numArguments, PLstr result);

#endif //EXTERNAL_H
