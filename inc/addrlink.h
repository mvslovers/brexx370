#ifndef ADDRLINK_H
#define ADDRLINK_H

#include "lstring.h"

typedef struct trx_link_params {
    void* moduleName;
    void* dcbAddress;
} RX_LINK_PARAMS, *RX_LINK_PARAMS_PTR;

int handleLinkCommands(PLstr cmd, PLstr env);

#endif //ADDRLINK_H
