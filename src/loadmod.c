/* -------------------------------------------------------------------------------------
 * Load modules: is one in the search order (BLDL), LOAD it, LINK to it.
 * Moved from rxmvs.c (#302); the prototypes are in rxmvsext.h.
 * -------------------------------------------------------------------------------------
 */
#include <string.h>
#include "rexx.h"
#include "rxmvsext.h"
#include "lstring.h"

int findLoadModule(char moduleName[8])
{
    int found = 0;

    RX_BLDL_PARAMS bldlParams;
    RX_SVC_PARAMS svcParams;

    memset(&bldlParams, 0, sizeof(RX_BLDL_PARAMS));
    memset(&bldlParams.BLDLN, ' ', 8);

    strncpy(bldlParams.BLDLN,
            moduleName,
            MIN(sizeof(bldlParams.BLDLN), strlen(moduleName)));

    bldlParams.BLDLF = 1;
    bldlParams.BLDLL = 50;

    svcParams.SVC = 18;
    svcParams.R0  = (uintptr_t) &bldlParams;
    svcParams.R1  = 0;

    call_rxsvc(&svcParams);

    if (svcParams.R15 == 0) {
        found = 1;
    }

    return found;
}

int loadLoadModule(char moduleName[8], void **pAddress)
{

    RX_SVC_PARAMS  svcParams;
    svcParams.SVC = 8;
    svcParams.R0  = (uintptr_t) moduleName;
    svcParams.R1  = 0;

    call_rxsvc(&svcParams);

    if (svcParams.R15 == 0) {
        *pAddress = (void *) (uintptr_t)svcParams.R0;
    }

    return svcParams.R15;
}

int linkLoadModule(const char8 moduleName, void *pParmList, void *GPR0)
{
    RX_SVC_PARAMS      svcParams;

    void *modInfo[2];
    modInfo[0] = (void *) moduleName;
    modInfo[1] = 0;

    svcParams.SVC = 6;
    svcParams.R0  = (unsigned int) (uintptr_t) GPR0;
    svcParams.R1  = (unsigned int) (uintptr_t) pParmList;
    svcParams.R15 = (unsigned int) (uintptr_t) &modInfo;

    call_rxsvc(&svcParams);

    return svcParams.R15;
}
