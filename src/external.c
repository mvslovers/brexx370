#include <string.h>

#include "external.h"
#include "lstring.h"
#include "rxmvsext.h"
#include "irx.h"

int
callExternalFunction(char *functionName, char* arguments[MAX_ARGS], int numArguments, PLstr result)
{
    int rc, ii;

    RX_SVC_PARAMS     svcParams;
    RX_EXT_PARAMS_R15 linkParamsR15;

    char moduleName[8];

    struct efpl _efpl;
    struct efpl *efpl = &_efpl;
    struct argtable_entry argtableEntries[MAX_ARGS];
    struct evalblock *_evalblock_ptr = MALLOC(EVALBLOCK_DATA_LENGTH + EVALBLOCK_HEADER_LENGTH, "EVALBLOCK");

    memset(efpl, 0, sizeof(struct efpl));
    memset(_evalblock_ptr, 0, EVALBLOCK_DATA_LENGTH + EVALBLOCK_HEADER_LENGTH);
    memset(argtableEntries, 0xFF, sizeof(argtableEntries));

    _evalblock_ptr->evalblock_evsize = (EVALBLOCK_DATA_LENGTH + EVALBLOCK_HEADER_LENGTH) / 8;
    _evalblock_ptr->evalblock_evlen  = (int) 0x80000000;

    _efpl.efplarg  = &argtableEntries;
    _efpl.efpleval = &_evalblock_ptr;

    memset(moduleName, ' ', 8);
    strncpy(moduleName, functionName, strlen(functionName));

    for (ii = 0; ii < numArguments; ii++) {
        argtableEntries[ii].argtable_argstring_ptr = (void *) arguments[ii];
        argtableEntries[ii].argtable_argstring_length = (int) strlen(arguments[ii]);
    }

    linkParamsR15.moduleName = moduleName;
    linkParamsR15.dcbAddress = 0;

    svcParams.SVC = 6;
    svcParams.R0  = (uintptr_t)getEnvBlock();
    svcParams.R1  = (((uintptr_t) &_efpl) | 0x80000000);
    svcParams.R15 = (uintptr_t) &linkParamsR15;

    call_rxsvc(&svcParams);
    rc = (int) svcParams.R15;

    if (_evalblock_ptr->evalblock_evlen > 0) {
        Lscpy2(result,  (char *)&_evalblock_ptr->evalblock_evdata, _evalblock_ptr->evalblock_evlen);

        setIntegerVariable("RC", rc);
        setVariable("RESULT", (char *)LSTR(*result));
    } else {
        setIntegerVariable("RC", -3);
    }

    FREE(_evalblock_ptr);

    return rc;
}
