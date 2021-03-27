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

typedef struct dynrexx_ctx_t {
    bool initialized;
    Lstr code;
} RX_DYNREXX_CTX, *RX_DYNREXX_CTX_PTR;

// HOST ENVIRONMENTS
int __MVS(PLstr cmd, char **tokens);
int __TSO(RX_ENVIRONMENT_BLK_PTR pEnvBlock, RX_HOSTENV_PARAMS_PTR  pParms);
int __ISPEXEC(RX_ENVIRONMENT_BLK_PTR pEnvBlock, RX_HOSTENV_PARAMS_PTR  pParms);
int __FSS(char **tokens);
int __LINK(RX_ENVIRONMENT_BLK_PTR pEnvBlock, RX_HOSTENV_PARAMS_PTR  pParms);
int __LINKPGM(RX_ENVIRONMENT_BLK_PTR pEnvBlock, RX_HOSTENV_PARAMS_PTR  pParms);
int __LINKMVS(RX_ENVIRONMENT_BLK_PTR pEnvBlock, RX_HOSTENV_PARAMS_PTR  pParms);
int __DYNREXX(RX_HOSTENV_PARAMS_PTR  pParms);

// HELPER FUNCTIONS
int tokenizeCmd(char *cmd, char **tokens);
int findToken(char *cmd,   char **tokens);

#endif
