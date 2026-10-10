#include <string.h>
#include <strings.h>
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
    Lstr	 orgcmd;

    char    *tokens[MAX_TOKENS];

    LINITSTR(env)
    LINITSTR(cmd)
    LINITSTR(orgcmd)

    Lscpy2(&env,  pParms->envName, 8);
    Lscpy2(&cmd, *pParms->cmdString, *pParms->cmdLength);
    Lscpy2(&orgcmd, *pParms->cmdString, *pParms->cmdLength); // save copy of command, as it will be cleared by tokenizeCMD

    Lstrip(&env, &env, LTRAILING, ' ');
    Lupper(&env);

    LASCIIZ(env);
    LASCIIZ(cmd)

    tokenizeCmd((char *) LSTR(cmd), tokens);

    if (strcasecmp(tokens[0], EXECIO_CMD) == 0) {
        // EXECIO IS CALLABLE IN TSO AND MVS ENVIRONMENT
        if (strcmp((char *)LSTR(env), TSO_ENVIRONMENT) == 0 ||
            strcmp((char *)LSTR(env), MVS_ENVIRONMENT) == 0) {
            rc = RxEXECIO(tokens,&orgcmd);  // call with original command
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
            bool trap = outtrapBegin();
            rc = __TSO(pEnvBlock, pParms);
            if (trap) outtrapEnd();
        } else if (strcmp((char *)LSTR(env), ISPEXEC_ENVIRONMENT)   == 0) {
            rc = __ISPEXEC(pEnvBlock, pParms);
        } else if (strcmp((char *)LSTR(env), FSS_ENVIRONMENT)       == 0) {
            rc = __FSS(tokens);
        } else if (strcmp((char *)LSTR(env), DYNREXX_ENVIRONMENT)   == 0) {
            rc = __DYNREXX(pParms);
        } else if (strcmp((char *)LSTR(env), COMMAND_ENVIRONMENT)   == 0) {
            bool trap = outtrapBegin();
            rc = __COMMAND(pEnvBlock, pParms);
            if (trap) outtrapEnd();
        } else if (strcmp((char *)LSTR(env), CONSOLE_ENVIRONMENT)   == 0) {
            rc = __CONSOLE(pEnvBlock, pParms);
        } else {
            rc = -3;
        }
    }

    LFREESTR(env);
    LFREESTR(cmd);
    LFREESTR(orgcmd);

    *pParms->returnCode = rc;

    return rc;
}

int __TSO(__unused RX_ENVIRONMENT_BLK_PTR pEnvBlock, RX_HOSTENV_PARAMS_PTR  pParms) {
    return tsoCommand(*pParms->cmdString, *pParms->cmdLength);
}

/*
 * Run a TSO command line the way ADDRESS TSO does: LINK the command
 * processor with the CPPL. SC28-1883-0 p. 23-24 asks for the command's
 * return code, and -3 for a command that is not found (the caller turns
 * the 0x806000 marker into -3). R0 is 0: BREXX has no IRXEXCOM, so an
 * ENVBLOCK would serve no command, and it publishes none in ECTENVBK, which
 * belongs to REXX/370 when both run side by side (#353).
 *
 * Returns the command's return code, -3 without a CPPL (not TSO, or TSO
 * CALL), HOSTENV_CMD_TOO_LONG if it does not fit the CPPL buffer, or
 * 0x806000 if no load module of that name exists.
 */
int tsoCommand(char *cmd, size_t cmdLength) {
    int rc = 0;

    void **cppl;
    byte *ect = NULL;

    // no CPPL: not TSO, or not called as a command processor (TSO CALL)
    cppl = isTSO() ? tsoCppl() : NULL;
    if (cppl != NULL) {
        ect  = cppl[3];
    } else {
        rc = -3;
    }

    // the command has to fit the CPPL buffer (size_t: a negative int
    // length from a caller arrives huge and is rejected here)
    if (rc == 0 && cmdLength > MAX_CPPLBUF_DATA_LENGTH) {
        rc = HOSTENV_CMD_TOO_LONG;
    }

    if (rc == 0) {
        cpplbuf cpplBuffer;
        cpplbuf *cpplBuffer_old;

        char    *ectPCMD;
        char8   modulName;

        size_t ii = 0;

        // save old cpplBuf
        cpplBuffer_old = cppl[0];

        // TODO: do we need to restore the pcmd value?
        ectPCMD = (char *) (ect+12);

        memset(ectPCMD, ' ', 8);

        // excracting the load module name from command string
        memset(modulName, ' ', sizeof(char8));
        while (ii < sizeof(char8) && ii < cmdLength && cmd[ii] != ' ' && cmd[ii] != 0x00) {
            // copy module name char by char
            ((char *)modulName)[ii] = cmd[ii];

            // we also write it to the ectpcmd field
            ectPCMD[ii] = cmd[ii];
            ii++;
        }

        // copy command string into the new cppl buffer
        memset(cpplBuffer.data, ' ', MAX_CPPLBUF_DATA_LENGTH);
        memcpy(cpplBuffer.data, cmd, cmdLength);

        // fill cppl buffer header
        cpplBuffer.length = CPPL_HEADER_LENGTH + cmdLength;
        cpplBuffer.offset = ii == cmdLength ? ii : ii + 1;

        // link new cppl buffer into cppl
        cppl[0] = &cpplBuffer;
        // modulName is 8 blank-padded bytes, not a C string
        if (strncasecmp(modulName, "TIME    ", sizeof(char8)) == 0) {
            memcpy(modulName, "IKJEFT25", sizeof(char8));
        }
        // call link svc
        if (findLoadModule(modulName)) {
            rc = linkLoadModule(modulName, cppl, NULL);
        } else {
            // marker for module not found
            rc = 0x806000;
        }

        cppl[0] = cpplBuffer_old;
    }

    return rc;
}

int __ISPEXEC(__unused RX_ENVIRONMENT_BLK_PTR pEnvBlock, RX_HOSTENV_PARAMS_PTR  pParms) {
    int rc = 0;

    void **cppl;

    // no CPPL: not TSO, or not called as a command processor (TSO CALL)
    cppl = isTSO() ? tsoCppl() : NULL;
    if (cppl == NULL) {
        rc = -3;
    }

    // environment name, a blank and the command have to fit the CPPL buffer
    if (rc == 0 && *pParms->cmdLength > MAX_CPPLBUF_DATA_LENGTH - (MAX_ENV_LENGTH + 1)) {
        rc = HOSTENV_CMD_TOO_LONG;
    }

    if (rc == 0) {
        cpplbuf cpplBuffer;

        // temporary pointer
        char *p_cpplBufferData = cpplBuffer.data;

        // clear cpplbuff with blanks
        memset(p_cpplBufferData, ' ', sizeof(cpplBuffer.data));

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
            rc = linkLoadModule(pParms->envName, cppl, NULL);
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

    if (rc == FSS_NOT_INIT) {
        Lerror(ERR_FSS_NOT_INIT, 0);
    }

    return rc;
}

#define skipOverBlank(lstr,ix) {while (LSTR(lstr)[ix] != 0) \
        {if (LSTR(lstr)[ix] != ' ') break;ix++;} }

int __DYNREXX(RX_HOSTENV_PARAMS_PTR  pParms) {
    int i,eoc,ri=0, rxerr=0;
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
        rxDynrexxCtx->code = NULL;
    }

    if (strncmp((char *)LSTR(cmd), "{", 1) == 0) {
        if (rxDynrexxCtx->code != NULL) LPFREE(rxDynrexxCtx->code)  /* one left unfinished */
        LPMALLOC(rxDynrexxCtx->code)
        Lfx(rxDynrexxCtx->code, 80);
    }

    /* a line before any "{" had no code string to go to */
    if (rxDynrexxCtx->code == NULL) {
        LFREESTR(cmd)
        return 8;
    }

    /* strchr() with a character literal: cc370 folds strstr(s, "}") into
     * strchr(s, 0x7D), the ASCII value, which is the quote in EBCDIC, so
     * any line with a quote ended the module and the rest was lost (#386) */
    if (strchr((char *)LSTR(cmd), '}') != NULL) {
        goto segmentEnd;    // make an internal module, to make it better readable
        returnSegmentEnd:   // return from the module
        if (rxerr == 0) {
            PLstr old;

            Lupper(&rexx);
            /* free the module this one replaces (#93) */
            old = hashMapGet(globalVariables, (char *) LSTR(rexx));
            hashMapSet(globalVariables, (char *) LSTR(rexx), rxDynrexxCtx->code);
            if (old != NULL && old != rxDynrexxCtx->code) LPFREE(old)
        } else {
            LPFREE(rxDynrexxCtx->code)  /* a rejected module was kept (#93) */
        }
        rxDynrexxCtx->code = NULL;
    } else {
        Lcat(rxDynrexxCtx->code, ";");
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
    /* strcat() looked for a NUL behind the unterminated string, so the
     * ";" went wherever one was and a byte of the old storage stood in
     * its place: a module of several lines lost its AS clause (#386) */
    Lcat(rxDynrexxCtx->code, ";");
    Lstrcat(rxDynrexxCtx->code,&cmd);
    Lfx(rxDynrexxCtx->code, LLEN(*rxDynrexxCtx->code) + 1);
    LSTR(*rxDynrexxCtx->code)[LLEN(*rxDynrexxCtx->code)]='\0';   // force end of string
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
        while (LSTR(*rxDynrexxCtx->code)[i] != 0 && LSTR(*rxDynrexxCtx->code)[i] != ' ' &&
               ri < 31) {               /* rexx holds 32 */
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

int __COMMAND(__unused RX_ENVIRONMENT_BLK_PTR pEnvBlock, RX_HOSTENV_PARAMS_PTR  pParms) {
    int rc = 0;

    void **cppl;

    // no CPPL: not TSO, or not called as a command processor (TSO CALL)
    cppl = isTSO() ? tsoCppl() : NULL;
    if (cppl == NULL) {
        rc = -3;
    }

    if (rc == 0) {

        byte *ect;
        byte *upt;
        int taken;

        upt  = cppl[1];
        ect  = cppl[3];

        if(strncasecmp(*pParms->cmdString, CP_NAM, CP_LEN) == 0) {
            *pParms->cmdString = *pParms->cmdString + CP_LEN;
            *pParms->cmdLength = *pParms->cmdLength - CP_LEN;

            // RXCPCMD starts with MODESET: S047 without the privilege (#368)
            if (privTake(&taken) == 0)
                rc = systemCP(upt, ect, *pParms->cmdString, *pParms->cmdLength, NULL,0);
            else
                rc = HOSTENV_NOT_AUTH;
            privDrop(taken);
        } else {
            rc = -3; // ONLY CP COMMANDS ARE SUPPORTED
        }
    }

    return rc;
}

int __CONSOLE(__unused RX_ENVIRONMENT_BLK_PTR pEnvBlock, RX_HOSTENV_PARAMS_PTR  pParms) {
    int rc = 0;

    RX_SVC_PARAMS svc_parameter;
    unsigned char cmd[128];

    if (!isTSO()) {
        rc = -3;
    }

    // the command text starts at cmd[4]
    if (rc == 0 && *pParms->cmdLength > (int) sizeof(cmd) - 4) {
        rc = HOSTENV_CMD_TOO_LONG;
    }

    if (rc == 0) {
        int taken;

        memset(cmd, 0, sizeof(cmd));
        cmd[1] = 104;

        memset(&cmd[4], ' ', 124);
        memcpy(&cmd[4], *pParms->cmdString, *pParms->cmdLength);

        // SVC 34 is restricted: S047 without the privilege (#368)
        if (privTake(&taken) == 0) {
            /* SEND COMMAND */
            svc_parameter.R0 = (uintptr_t) 0;
            svc_parameter.R1 = (uintptr_t) &cmd[0];
            svc_parameter.SVC = 34;
            call_rxsvc(&svc_parameter);
        } else {
            rc = HOSTENV_NOT_AUTH;
        }
        privDrop(taken);
    }

    return rc;
}

void clearTokens(char **tokens) {
    int idx;
    for (idx = 0; idx < MAX_TOKENS; idx++) {
        tokens[idx] = NULL;
    }
}

int findToken(const char *cmd, char **tokens) {
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

    // keep the last entry NULL
    while(tokens[idx] != NULL && idx < MAX_TOKENS - 2) {
        idx++;
        tokens[idx] = strtok(NULL, " (),");
    }
    if (tokens[idx] != NULL) {
        idx++;
    }

    if(idx == 0) {
        tokens[idx] = cmd;
    }

    return idx;
}

