#ifndef ADDRLINK_H
#define ADDRLINK_H

#include "lstring.h"

#define MAX_ARGS 16

typedef struct trx_link_params_r15 {
    void* moduleName;
    void* dcbAddress;
} RX_LINK_PARAMS_R15, *RX_LINK_PARAMS_R15_PTR;

typedef struct trx_link_params_r1 {
    void* ptr[MAX_ARGS];
} RX_LINK_PARAMS_R1, *RX_LINK_PARAMS_R1_PTR;

int handleLinkCommands(PLstr cmd, PLstr env);

#endif //ADDRLINK_H
