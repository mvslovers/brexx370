#ifndef __HOSTENV_H
#define __HOSTENV_H

#include "rxmvsext.h"

#define SPACE_LENGTH                1
#define CPPL_HEADER_LENGTH          4
#define MAX_ENV_LENGTH              8
#define MAX_CMD_LENGTH              256
#define MAX_CPPLBUF_DATA_LENGTH     ( MAX_ENV_LENGTH + SPACE_LENGTH + MAX_CMD_LENGTH )

extern void ** entry_R13;

typedef struct cpplbuf_t {
    word length;
    word offset;
    char data[MAX_CPPLBUF_DATA_LENGTH];
} cpplbuf;

int handleMVSCommands(RX_ENVIRONMENT_BLK_PTR pEnvBlock, RX_HOSTENV_PARAMS_PTR  parms);

int handleTSOCommands(RX_ENVIRONMENT_BLK_PTR pEnvBlock, RX_HOSTENV_PARAMS_PTR  parms);

int handleISPEXECCommands(RX_ENVIRONMENT_BLK_PTR pEnvBlock, RX_HOSTENV_PARAMS_PTR  parms);

#endif