#include "addrlink.h"
#include "rxmvsext.h"

int
parse(char scmd[256], char *tokens[])
{
    int ii;

    for (ii = 0; ii < MAX_ARGS; ii++) {
        tokens[ii] = NULL;
    }

    ii = 0;

    tokens[ii] = strtok(scmd, " (),");

    while(tokens[ii] != NULL) {
        ii++;
        tokens[ii]=strtok(NULL, " (),");
    }

    if (ii == 0) {
        tokens[ii] = (char *) &scmd;
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

    RX_SVC_PARAMS      svcParams;
    RX_LINK_PARAMS_R1  linkParamsR1;
    RX_LINK_PARAMS_R15 linkParamsR15;

    bzero(sCmd, 1025);
    strncpy(sCmd, (const char *) LSTR(*cmd), 1024);

    memset(moduleName, ' ', 8);

    loadModule = strtok(sCmd," (),");
    args       = strtok(NULL,"");

    if (!findLoadModule(loadModule)) {
        rc = -3;
    }

    if (rc == 0) {
        int varCount = 0;
        int varValLen;
        int ii,jj;

        strncpy(moduleName, loadModule, strlen(loadModule));
        linkParamsR15.moduleName = moduleName;
        linkParamsR15.dcbAddress = 0;

        svcParams.SVC = 6;
        svcParams.R0  = (unsigned int)  getEnvBlock();
        svcParams.R15 = (unsigned int) &linkParamsR15;

        if (strcasecmp((const char *)LSTR(*env), "LINK") == 0) {

            varValLen = strlen(args);
            linkParamsR1.ptr[0] = &args;
            linkParamsR1.ptr[1] = (void *) (((int)&varValLen) | 0x80000000);

            svcParams.R1  = (unsigned int) &linkParamsR1;
        } else if (strcasecmp((const char *)LSTR(*env), "LINKMVS") == 0) {
            char *varNames[MAX_ARGS];
            PLstr plsVarValue;

            varCount = parse(args, varNames);

            for (ii = 0; ii < varCount; ii++) {
                short *tmp;

                LPMALLOC(plsVarValue)

                getVariable(varNames[ii], plsVarValue);
                L2STR(plsVarValue);

                Lfx(plsVarValue, LLEN(*plsVarValue) + 2);

                // Shifting value two bytes to the right
                for (jj = LLEN(*plsVarValue) - 1; jj >= 0 ; jj--) {
                    LSTR(*plsVarValue)[jj + 2] = LSTR(*plsVarValue)[jj];
                }

                // Copy length in the first two bytes
                tmp = (short *)LSTR(*plsVarValue);
                *tmp = (short) LLEN(*plsVarValue);

                linkParamsR1.ptr[ii] = LSTR(*plsVarValue);

                FREE(plsVarValue);
            }

            linkParamsR1.ptr[ii - 1] = (void *) (((int)linkParamsR1.ptr[ii - 1]) | 0x80000000);
            svcParams.R1  = (unsigned int) &linkParamsR1;
        } else if (strcasecmp((const char *)LSTR(*env), "LINKPGM") == 0) {
            char *varNames[MAX_ARGS];
            PLstr plsVarValue;

            varCount = parse(args, varNames);

            for (ii = 0; ii < varCount; ii++) {
                LPMALLOC(plsVarValue)

                getVariable(varNames[ii], plsVarValue);
                L2STR(plsVarValue);

                linkParamsR1.ptr[ii] = LSTR(*plsVarValue);

                FREE(plsVarValue);
            }

            linkParamsR1.ptr[ii - 1] = (void *) (((int)linkParamsR1.ptr[ii - 1]) | 0x80000000);
            svcParams.R1  = (unsigned int) &linkParamsR1;
        }

        call_rxsvc(&svcParams);
        rc = svcParams.R15;

        for (ii = 0; ii < varCount; ii++) {
            FREE(linkParamsR1.ptr[ii]);
        }
    }

    setIntegerVariable("RC", rc);

    return rc;
}
