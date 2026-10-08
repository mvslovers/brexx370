#ifndef EXTERNAL_H
#define EXTERNAL_H
#include "lstring.h"

#define EVALBLOCK_HEADER_LENGTH   16
#define EVALBLOCK_DATA_LENGTH   4096

typedef struct trx_ext_params_r15 {
    void* moduleName;
    void* dcbAddress;
} RX_EXT_PARAMS_R15, *RX_EXT_PARAMS_R15_PTR;

typedef struct trx_ext_params_r1 {
    void* ptr[1];
} RX_EXT_PARAMS_R1, *RX_EXT_PARAMS_R1_PTR;

/* arguments[] has numArguments entries, at most MAXARGS (rexx.h); an
 * omitted one is NULL. It had 15 entries while a call has up to 32 (#386) */
int callExternalFunction(const char *functionName, char* arguments[], int numArguments, PLstr result);

#endif //EXTERNAL_H
