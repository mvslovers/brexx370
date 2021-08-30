#include <string.h>
#include "hostenv.h"
#include "rxexecio.h"
#include "rxvsamio.h"
#include "rxfss.h"
#include "lstring.h"
#include "lerror.h"
#include "irx.h"
#include "rac.h"
#include "rxrac.h"
#include "hashmap.h"

#define MVS_ENVIRONMENT             "MVS"
#define TSO_ENVIRONMENT             "TSO"
#define ISPEXEC_ENVIRONMENT         "ISPEXEC"
#define FSS_ENVIRONMENT             "FSS"
#define DYNREXX_ENVIRONMENT         "DYNREXX"
#define COMMAND_ENVIRONMENT         "COMMAND"
#define CONSOLE_ENVIRONMENT         "CONSOLE"

#define EXECIO_CMD                  "EXECIO"
#define VSAMIO_CMD                  "VSAMIO"

extern HashMap *globalVariables;

RX_DYNREXX_CTX_PTR                  rxDynrexxCtx = NULL;

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

    tokenizeCmd((char *) LSTR(cmd), tokens);

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
        } else if (strcmp((char *)LSTR(env), DYNREXX_ENVIRONMENT)   == 0) {
            rc = __DYNREXX(pParms);
        } else if (strcmp((char *)LSTR(env), COMMAND_ENVIRONMENT)   == 0) {
            rc = __COMMAND(pEnvBlock, pParms);
        } else if (strcmp((char *)LSTR(env), CONSOLE_ENVIRONMENT)   == 0) {
            rc = __CONSOLE(pEnvBlock, pParms);
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
    } else if (strcasecmp(tokens[0], "STATIC")   == 0) {
        rc = RxFSS_STATIC(tokens);
    } else if (strcasecmp(tokens[0], "RESET")   == 0) {
        rc = RxFSS_RESET(tokens);
    } else if (strcasecmp(tokens[0], "TEXT")    == 0) {
        rc = RxFSS_TEXT(tokens);
    } else if (strcasecmp(tokens[0], "TEST")    == 0) {
        rc = RxFSS_TEST(tokens);
    } else if (strcasecmp(tokens[0], "FIELD")   == 0) {
        rc = RxFSS_FIELD(tokens);
    } else if (strcasecmp(tokens[0], "SET")     == 0) {
        rc = RxFSS_SET(tokens);
    } else if (strcasecmp(tokens[0], "GET")     == 0) {
        rc = RxFSS_GET(tokens);
    } else if (strcasecmp(tokens[0], "REFRESH") == 0) {
        rc = RxFSS_REFRESH(tokens);
    } else if (strcasecmp(tokens[0], "SHOW") == 0) {
        rc = RxFSS_SHOW(tokens);
    } else if (strcasecmp(tokens[0], "CHECK") == 0) {
        rc = RxFSS_CHECK(tokens);
    } else {
        rc = -3;
    }

    if (rc == 8) {
        Lerror(ERR_FSS_NOT_INIT, 0);
    }

    return rc;
}

#define skipOverBlank(lstr,ix) {while (LSTR(lstr)[ix] != 0) \
        {if (LSTR(lstr)[ix] != ' ') break;ix++;} }

int __DYNREXX(RX_HOSTENV_PARAMS_PTR  pParms) {
    int i,eoc,ri, rxerr=0;
    Lstr	 cmd;
    Lstr     rexx;
    LINITSTR(cmd)
    LINITSTR(rexx)

    Lscpy2(&cmd, *pParms->cmdString, *pParms->cmdLength);

    LASCIIZ(cmd)

    // allocate and zero out our control block
    // TODO: rxDynrexxCtx could be removed and ->code should be global instead
    if (rxDynrexxCtx == NULL) {
        rxDynrexxCtx = MALLOC(sizeof(RX_DYNREXX_CTX), "__DYNREXX_ctx");
    }

    if (strncmp((char *)LSTR(cmd), "{", 1) == 0) {
        LPMALLOC(rxDynrexxCtx->code)
        Lfx(rxDynrexxCtx->code, 80);
    }

    if (strstr((char *)LSTR(cmd), "}") != NULL) {
        goto segmentEnd;    // make an internal module, to make it better readable
        returnSegmentEnd:   // return from the module
        if (rxerr == 0) {
            Lupper(&rexx);
            hashMapSet(globalVariables, (char *) LSTR(rexx), rxDynrexxCtx->code);
        }
    } else {
        strcat((char *) LSTR(*rxDynrexxCtx->code),";");
        LLEN(*rxDynrexxCtx->code)=LLEN(*rxDynrexxCtx->code)+1;
        Lstrcat(rxDynrexxCtx->code,&cmd);
    }

    /* END IMPL */
    LFREESTR(cmd)
    LFREESTR(rexx)
    if (rxerr==0) return 0;
    return 8;
/* ------------------------------------------------------------------------------------------------
 * Internal sub module for end of DYNREXX , ...} as rexname has been discovered
 * ------------------------------------------------------------------------------------------------
 */
 segmentEnd:
    Lfx(&rexx,32);
    strcat((char *) LSTR(*rxDynrexxCtx->code),";");
    LLEN(*rxDynrexxCtx->code)=LLEN(*rxDynrexxCtx->code)+1;
    Lstrcat(rxDynrexxCtx->code,&cmd);
    LSTR(*rxDynrexxCtx->code)[LLEN(*rxDynrexxCtx->code)]=NULL;   // force end of string
    i=0;
 // translate { and } to blank, if } then pick up rexx name
    while (LSTR(*rxDynrexxCtx->code)[i] != 0) {
        if (LSTR(*rxDynrexxCtx->code)[i] =='{') LSTR(*rxDynrexxCtx->code)[i]=' ';
        if (LSTR(*rxDynrexxCtx->code)[i] =='}') {
            LSTR(*rxDynrexxCtx->code)[i] = ';';
            break;
        }
        i++;
    }
    i++;     // skip over }
    eoc=i;   // save end position of code
 // identify AS clause
    skipOverBlank(*rxDynrexxCtx->code,i);  // skip ober blanks for AS clause
    if (LSTR(*rxDynrexxCtx->code)[i] == 0) {
        printf("DYNREXX   AS clause missing %s\n", LSTR(rexx));
        rxerr=1;
    }
    if (rxerr==0) {
        if ((LSTR(*rxDynrexxCtx->code)[i] == 'A' || LSTR(*rxDynrexxCtx->code)[i] == 'a') &&
            (LSTR(*rxDynrexxCtx->code)[i + 1] == 'S' || LSTR(*rxDynrexxCtx->code)[i + 1] == 's')) i=i+2;
        else {
            printf("DYNREXX   AS clause missing %s\n", LSTR(rexx));
            rxerr = 1;
        }
    }
  //  printf("CODE %s,\n",LSTR(*rxDynrexxCtx->code));
    if (rxerr==0) {
        ri = 0;    // rexx name counter
        skipOverBlank(*rxDynrexxCtx->code,i)
        if (LSTR(*rxDynrexxCtx->code)[i] == 0) {
            printf("DYNREXX   REXX name missings\n");
            rxerr=1;
        }
        // now pick upd rexx name byte per byte
        while (LSTR(*rxDynrexxCtx->code)[i] != 0 && LSTR(*rxDynrexxCtx->code)[i] != ' ') {
            LSTR(rexx)[ri] = LSTR(*rxDynrexxCtx->code)[i];
            if (ri < 2 && LSTR(*rxDynrexxCtx->code)[i] != '_') rxerr = 1;
            ri++;
            i++;
        }
        if (rxerr==1) printf("DYNREXX   REXX name must be prefixed by '__', name is: %s\n",LSTR(rexx));
        skipOverBlank(*rxDynrexxCtx->code,i)
        if (LSTR(*rxDynrexxCtx->code)[i] != 0) {
            printf("DYNREXX   superfluous information after REXX name\n");
            rxerr=1;
        }
        if (ri==0) {
            printf("DYNREXX   REXX name missings\n");
            rxerr=1;
        }
    }
    if (rxerr==1) printf("DYNREXX   REXXDYN clause invalid or missing, REXX not stored\n");
    LSTR(*rxDynrexxCtx->code)[eoc] = 0;
    LLEN(*rxDynrexxCtx->code) = eoc;
    LSTR(rexx)[ri] = 0;
    LLEN(rexx)=ri;
  goto returnSegmentEnd;
}

#define CP_NAM "CP "
#define CP_LEN 3

int __COMMAND(RX_ENVIRONMENT_BLK_PTR pEnvBlock, RX_HOSTENV_PARAMS_PTR  pParms) {
    int rc = 0;

    void **cppl;

    if (!rac_check(FACILITY, CP, READ))
        return -3;

    if (isTSO()) {
        cppl = entry_R13[6];
    } else {
        rc = -3;
    }

    if (rc == 0) {

        byte *ect;
        byte *upt;

        upt  = cppl[1];
        ect  = cppl[3];

        if(strncasecmp(*pParms->cmdString, CP_NAM, CP_LEN) == 0) {
            *pParms->cmdString = *pParms->cmdString + CP_LEN;
            *pParms->cmdLength = *pParms->cmdLength - CP_LEN;

            rc = systemCP(upt, ect, *pParms->cmdString, *pParms->cmdLength, NULL,0);
        } else {
            rc = -3; // ONLY CP COMMANDS ARE SUPPORTED
        }
    }

    return rc;
}

int __CONSOLE(RX_ENVIRONMENT_BLK_PTR pEnvBlock, RX_HOSTENV_PARAMS_PTR  pParms) {
    int rc = 0;

    RX_SVC_PARAMS svc_parameter;
    unsigned char cmd[128];

    if (!rac_check(FACILITY, CONSOLE, READ))
        return -3;

    if (!isTSO()) {
        rc = -3;
    }

    if (rc == 0) {
        bzero(cmd, sizeof(cmd));
        cmd[1] = 104;

        memset(&cmd[4], ' ', 124);
        memcpy(&cmd[4], *pParms->cmdString, *pParms->cmdLength);

        privilege(1);

        /* SEND COMMAND */
        svc_parameter.R0 = (uintptr_t) 0;
        svc_parameter.R1 = (uintptr_t) &cmd[0];
        svc_parameter.SVC = 34;
        call_rxsvc(&svc_parameter);

        privilege(0);
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

