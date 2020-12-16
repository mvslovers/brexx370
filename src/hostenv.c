#include <string.h>
#include "hostenv.h"
#include "rxexecio.h"
#include "rxvsamio.h"
#include "rxfss.h"
#include "lstring.h"
#include "irx.h"

#define MVS_ENVIRONMENT             "MVS"
#define TSO_ENVIRONMENT             "TSO"
#define ISPEXEC_ENVIRONMENT         "ISPEXEC"
#define FSS_ENVIRONMENT             "FSS"

#define EXECIO_CMD                  "EXECIO"
#define VSAMIO_CMD                  "VSAMIO"

// - Host Environment Command Router -
int IRXSTAM(RX_ENVIRONMENT_BLK_PTR pEnvBlock, RX_HOSTENV_PARAMS_PTR  pParms) {
    int rc;

    Lstr     env;
    Lstr	 cmd;

    char    *tokens[128];

    LINITSTR(env)
    LINITSTR(cmd)

    Lscpy2(&env,  pParms->envName, 8);
    Lscpy2(&cmd, *pParms->cmdString, *pParms->cmdLength);

    Lstrip(&env, &env, LTRAILING, ' ');
    Lupper(&env);

    LASCIIZ(env);
    LASCIIZ(cmd)

    tokenizeCmd((char *)LSTR(cmd), tokens);

    if (strcasecmp(tokens[0], EXECIO_CMD) == 0) {
        // EXECIO IS CALLABLE IN TSO AND MVS ENVIRONMENT
        if (strcmp((char *)LSTR(env), TSO_ENVIRONMENT) == 0 ||
            strcmp((char *)LSTR(env), MVS_ENVIRONMENT) == 0) {
            rc = RxEXECIO(tokens);
        } else {
            rc = -3;
        }
    } else if (strcasecmp(tokens[0], VSAMIO_CMD) == 0) {
        // VSAMIO IS CALLABLE IN TSO AND MVS ENVIRONMENT
        if (strcmp((char *)LSTR(env), TSO_ENVIRONMENT) == 0 ||
            strcmp((char *)LSTR(env), MVS_ENVIRONMENT) == 0) {
            rc = RxVSAMIO(tokens);
        } else {
            rc = -3;
        }
    } else {
        // HANDLE COMMAND IN GIVEN ENVIRONMENT
        if (strcmp((char *)LSTR(env),        MVS_ENVIRONMENT)       == 0) {
            rc = __MVS(&cmd, tokens);
        } else if (strcmp((char *)LSTR(env), TSO_ENVIRONMENT)       == 0) {
            rc = __TSO(pEnvBlock, pParms);
        } else if (strcmp((char *)LSTR(env), ISPEXEC_ENVIRONMENT)   == 0) {
            rc = __ISPEXEC(pEnvBlock, pParms);
        } else if (strcmp((char *)LSTR(env), FSS_ENVIRONMENT)       == 0) {
            rc = __FSS(tokens);
        } else {
            rc = -3;
        }
    }

    LFREESTR(env);
    LFREESTR(cmd);

    *pParms->returnCode = rc;

    return rc;
}

int __TSO(RX_ENVIRONMENT_BLK_PTR pEnvBlock, RX_HOSTENV_PARAMS_PTR  pParms) {
    int rc = 0;

    void **cppl;
    byte *ect;

    if (isTSO()) {
        cppl = entry_R13[6];
        ect  = cppl[3];
    } else {
        rc = -3;
    }

    if (rc == 0) {
        cpplbuf cpplBuffer;
        cpplbuf *cpplBuffer_old;

        char    *ectPCMD;
        char8   modulName;

        int ii = 0;

        // save old cpplBuf
        cpplBuffer_old = cppl[0];

        // TODO: do we need to restore the pcmd value?
        ectPCMD = (char *) (ect+12);

        memset(ectPCMD, ' ', 8);

        // excracting the load module name from command string
        memset(modulName, ' ', sizeof(char8));
        while (ii < sizeof(char8) && (*pParms->cmdString)[ii] != ' ' &&  (*pParms->cmdString)[ii] != 0x00) {
            // copy module name char by char
            ((char *)modulName)[ii] = (*pParms->cmdString)[ii];

            // we also write it to the ectpcmd field
            ectPCMD[ii] = (*pParms->cmdString)[ii];
            ii++;
        }

        // copy command string into the new cppl buffer
        memset(cpplBuffer.data, ' ', MAX_CPPLBUF_DATA_LENGTH);
        memcpy(cpplBuffer.data, *pParms->cmdString, *pParms->cmdLength);

        // fill cppl buffer header
        cpplBuffer.length = CPPL_HEADER_LENGTH + (*pParms->cmdLength);
        cpplBuffer.offset = ii == *pParms->cmdLength ? ii : ii + 1;

        // link new cppl buffer into cppl
        cppl[0] = &cpplBuffer;

        // call link svc
        if (findLoadModule(modulName)) {
            rc = linkLoadModule(modulName, cppl, pEnvBlock);
        } else {
            // marker for module not found
            rc = 0x806000;
        }

        cppl[0] = cpplBuffer_old;
    }

    return rc;
}

int __ISPEXEC(RX_ENVIRONMENT_BLK_PTR pEnvBlock, RX_HOSTENV_PARAMS_PTR  pParms) {
    int rc = 0;

    void **cppl;

    if (isTSO()) {
        cppl = entry_R13[6];
    } else {
        rc = -3;
    }

    if (rc == 0) {
        cpplbuf cpplBuffer;

        // temporary pointer
        char *p_cpplBufferData = cpplBuffer.data;

        // clear cpplbuff with blanks
        memset(p_cpplBufferData, ' ', sizeof(cpplbuf));

        // copy environment name to buffer
        memcpy(p_cpplBufferData, pParms->envName, MAX_ENV_LENGTH);
        p_cpplBufferData = p_cpplBufferData + MAX_ENV_LENGTH + 1;

        // copy command string to buffer
        memcpy(p_cpplBufferData, *pParms->cmdString, *pParms->cmdLength);

        // fill cppl buffer header
        cpplBuffer.length = CPPL_HEADER_LENGTH + (MAX_ENV_LENGTH + 1) + *pParms->cmdLength;
        cpplBuffer.offset = MAX_ENV_LENGTH + 1;

        // link new cppl buffer into cppl
        cppl[0] = &cpplBuffer;

        // call link svc
        if (findLoadModule(pParms->envName)) {
            rc = linkLoadModule(pParms->envName, cppl, pEnvBlock);
        } else {
            // marker for module not found
            rc = 0x806000;
        }
    }

    return rc;
}

int __MVS(PLstr cmd, char **tokens) {
    int rc = 0;

    if (!findLoadModule(tokens[0])) {
        rc = 0x806000;
    }

    if (rc == 0) {
        rc = system((char *) LSTR(*cmd));
    }

    return rc;
}

int __FSS(char **tokens) {
    int rc;

    if (strcasecmp(tokens[0],        "INIT")    == 0) {
        rc = RxFSS_INIT(tokens);
    } else if (strcasecmp(tokens[0], "TERM")    == 0) {
        rc = RxFSS_TERM(tokens);
    } else if (strcasecmp(tokens[0], "RESET")   == 0) {
        rc = RxFSS_RESET(tokens);
    } else if (strcasecmp(tokens[0], "TEXT")    == 0) {
        rc = RxFSS_TEXT(tokens);
    } else if (strcasecmp(tokens[0], "FIELD")   == 0) {
        rc = RxFSS_FIELD(tokens);
    } else if (strcasecmp(tokens[0], "SET")     == 0) {
        rc = RxFSS_SET(tokens);
    } else if (strcasecmp(tokens[0], "GET")     == 0) {
        rc = RxFSS_GET(tokens);
    } else if (strcasecmp(tokens[0], "REFRESH") == 0) {
        rc = RxFSS_REFRESH(tokens);
    } else if (strcasecmp(tokens[0], "CHECK") == 0) {
        rc = RxFSS_CHECK(tokens);
    } else {
        rc = -3;
    }

    return rc;
}

void clearTokens(char **tokens) {
    int idx;
    for (idx = 0; idx <= sizeof(tokens); idx++) {
        tokens[idx] = NULL;
    }
}

int findToken(char *cmd, char **tokens) {
    int idx = 0;
    while (tokens[idx] != NULL) {
        if (strcasecmp(cmd, tokens[idx]) == 0) {
            return (idx);
        }
        idx++;
    }
    return (-1);
}

int tokenizeCmd(char *cmd, char **tokens) {
    int idx = 0;

    clearTokens(tokens);

    tokens[idx] = strtok(cmd, " (),");

    while(tokens[idx] != NULL) {
        idx++;
        tokens[idx] = strtok(NULL, " (),");
    }

    if(idx == 0) {
        tokens[idx] = (char *) &cmd;
    }

    return idx;
}

