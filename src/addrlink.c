#include "addrlink.h"
#include "rxmvsext.h"

int
handleLinkCommands(PLstr cmd, PLstr env)
{
    int rc = 0;

    char sCmd[1025];

    char *loadModule;
    char *args;

    char moduleName[8];

    RX_SVC_PARAMS  svcParams;
    RX_LINK_PARAMS linkParams;

    bzero(sCmd,1025);
    strncpy(sCmd, (const char *) LSTR(*cmd), 1024);

    memset(moduleName, ' ', 8);

    loadModule = strtok(sCmd," (),");
    args       = strtok(NULL,"");

    if (strcasecmp((const char *)LSTR(*env), "LINK") == 0) {
        if (findLoadModule(loadModule)) {
            strncpy(moduleName, loadModule, strlen(loadModule));
            linkParams.moduleName = moduleName;
            linkParams.dcbAddress = 0;

            svcParams.SVC = 6;
            svcParams.R0  = (unsigned int) getEnvBlock();
            svcParams.R1  = (unsigned int) &args;    // must be arg und len(arg)+high order bit
            svcParams.R15 = (unsigned int) &linkParams;

            call_rxsvc(&svcParams);

            printf("FOO> RXSVC RC(%d)\n", svcParams.R15);
            if (svcParams.R15 == 0) {
                rc = 1;
            }
        } else {
            rc = -3;
        }

    } else if (strcasecmp((const char *)LSTR(*env), "LINKMVS") == 0) {

    } else if (strcasecmp((const char *)LSTR(*env), "LINKPGM") == 0) {

    }

    return rc;

}