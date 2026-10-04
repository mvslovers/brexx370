#include "addrlink.h"
#include <strings.h>
#include "rxmvsext.h"

// TSO/E gives a LINKMVS value under 500 bytes room for 500
#define LINKMVS_SPACE 500

int
parse(char *scmd, char *tokens[])
{
    int ii;

    for (ii = 0; ii < MAX_ARGS; ii++) {
        tokens[ii] = NULL;
    }

    ii = 0;

    if (scmd == NULL) {
        return 0;
    }

    tokens[ii] = strtok(scmd, " (),");

    // keep the last entry NULL
    while(tokens[ii] != NULL && ii < MAX_ARGS - 2) {
        ii++;
        tokens[ii]=strtok(NULL, " (),");
    }
    if (tokens[ii] != NULL) {
        ii++;
    }

    if (ii == 0) {
        tokens[ii] = scmd;
    }

    return ii;
}


int
handleLinkCommands(PLstr cmd, PLstr env)
{
    int rc = 0;

    char sCmd[1025];

    char *loadModule;
    char *args;

    char moduleName[8];

    short noParms = 0;               // halfword length 0 for a call without parameters

    RX_SVC_PARAMS      svcParams;
    RX_LINK_PARAMS_R1  linkParamsR1;
    RX_LINK_PARAMS_R15 linkParamsR15;

    memset(sCmd, 0, 1025);
    strncpy(sCmd, (const char *) LSTR(*cmd), 1024);

    memset(moduleName, ' ', 8);

    loadModule = strtok(sCmd," (),");
    args       = strtok(NULL,"");

    // a name over 8 characters cannot be a load module; findLoadModule()
    // would look up its first 8 and moduleName[] would overflow
    if (loadModule == NULL || strlen(loadModule) > sizeof(moduleName) ||
        !findLoadModule(loadModule)) {
        rc = -3;
    }

    if (rc == 0) {
        int varCount = 0;
        int varValLen;
        int ii;
        char *varNames[MAX_ARGS];
        char *parmBuf[MAX_ARGS];
        int   parmSpace[MAX_ARGS];
        int   mvs = strcasecmp((const char *)LSTR(*env), "LINKMVS") == 0;

        strncpy(moduleName, loadModule, strlen(loadModule));
        linkParamsR15.moduleName = moduleName;
        linkParamsR15.dcbAddress = 0;

        svcParams.SVC = 6;
        svcParams.R0  = (unsigned int)  getEnvBlock();
        svcParams.R15 = (unsigned int) &linkParamsR15;

        if (strcasecmp((const char *)LSTR(*env), "LINK") == 0) {

            if (args == NULL) {
                args = "";
            }

            varValLen = strlen(args);
            linkParamsR1.ptr[0] = &args;
            linkParamsR1.ptr[1] = (void *) (((int)&varValLen) | 0x80000000);

            svcParams.R1  = (unsigned int) &linkParamsR1;
        } else if (mvs || strcasecmp((const char *)LSTR(*env), "LINKPGM") == 0) {
            varCount = parse(args, varNames);

            // LINKMVS: halfword length + value, with room for 500 bytes as
            // TSO/E gives it, so the program may lengthen a short value.
            // LINKPGM: the value alone, at its own length.
            for (ii = 0; ii < varCount; ii++) {
                Lstr lsValue;
                int  len;

                LINITSTR(lsValue)
                getVariable(varNames[ii], &lsValue);
                L2STR(&lsValue);

                len = (int) LLEN(lsValue);
                if (mvs) {
                    parmSpace[ii] = len < LINKMVS_SPACE ? LINKMVS_SPACE : len;
                    parmBuf[ii]   = MALLOC(parmSpace[ii] + 2, "LINKMVS");
                    *(short *) parmBuf[ii] = (short) len;
                    memcpy(parmBuf[ii] + 2, LSTR(lsValue), len);
                } else {
                    parmSpace[ii] = len;
                    parmBuf[ii]   = MALLOC(len + 1, "LINKPGM");
                    memcpy(parmBuf[ii], LSTR(lsValue), len);
                }
                linkParamsR1.ptr[ii] = parmBuf[ii];

                LFREESTR(lsValue)
            }

            if (varCount > 0) {
                linkParamsR1.ptr[ii - 1] = (void *) (((uintptr_t)linkParamsR1.ptr[ii - 1]) | 0x80000000);
            } else {
                linkParamsR1.ptr[0] = (void *) (((uintptr_t)&noParms) | 0x80000000);
            }
            svcParams.R1  = (unsigned int) &linkParamsR1;
        }

        call_rxsvc(&svcParams);
        rc = svcParams.R15;

        // write back what the program left in the parameters (TSO/E):
        // LINKMVS by the halfword, < 0 keeps the variable, 0 makes it
        // null; LINKPGM at the length the value had
        for (ii = 0; ii < varCount; ii++) {
            if (mvs) {
                int len = *(short *) parmBuf[ii];

                if (len > parmSpace[ii]) {
                    len = parmSpace[ii];
                }
                if (len >= 0) {
                    setVariable2(varNames[ii], parmBuf[ii] + 2, len);
                }
            } else {
                setVariable2(varNames[ii], parmBuf[ii], parmSpace[ii]);
            }
            FREE(parmBuf[ii]);
        }
    }

    setIntegerVariable("RC", rc);

    return rc;
}
