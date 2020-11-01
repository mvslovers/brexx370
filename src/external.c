#include <string.h>

#include "external.h"
#include "lstring.h"
#include "rxmvsext.h"
#include "irx.h"

int
callExternalFunction(char *functionName, char* arguments[MAX_ARGS], int numArguments, PLstr result)
{

    int rc, ii;

    RX_SVC_PARAMS      svcParams;
    RX_EXT_PARAMS_R1  linkParamsR1;
    RX_EXT_PARAMS_R15 linkParamsR15;

    char moduleName[8];

    struct efpl _efpl;
    byte *tmp = (byte *) &_efpl;

    struct argtable_entry argtableEntries[MAX_ARGS];
    struct evalblock *_evalblock_ptr = MALLOC(EVALBLOCK_DATA_LENGTH + sizeof(struct evalblock), "EVALBLOCK");

    bzero(_evalblock_ptr,   256 + sizeof(struct evalblock));
    memset(argtableEntries, 0xFF, sizeof(argtableEntries));

    _evalblock_ptr->evalblock_evpad1 = 0x00;
    _evalblock_ptr->evalblock_evpad2 = 0x00;
    _evalblock_ptr->evalblock_evlen  = 0x80000000;
    _evalblock_ptr->evalblock_evsize = (EVALBLOCK_DATA_LENGTH + sizeof(struct evalblock)) / 8;

    _efpl.efplcom  = 0;
    _efpl.efplbarg = 0;
    _efpl.efplearg = 0;
    _efpl.efplfb   = 0;

    // FIX FOR PL/1 => PL/1 is skipping 2 bytes for length field
    tmp = tmp - 2;

    _efpl.efplarg  = &argtableEntries;
    _efpl.efpleval = &_evalblock_ptr;

    memset(moduleName, ' ', 8);
    strncpy(moduleName, functionName, strlen(functionName));

    for (ii = 0; ii < numArguments; ii++) {
        argtableEntries[ii].argtable_argstring_ptr = (void *) arguments[ii];
        argtableEntries[ii].argtable_argstring_length = strlen(arguments[ii]);
    }

    linkParamsR1.ptr[0] = tmp;
    linkParamsR1.ptr[0] = (void *) (((int)linkParamsR1.ptr[0]) | 0x80000000);

    linkParamsR15.moduleName = moduleName;
    linkParamsR15.dcbAddress = 0;

    svcParams.SVC = 6;
    svcParams.R0  = (unsigned int)  getEnvBlock();
    svcParams.R1  = (unsigned int) &linkParamsR1;
    svcParams.R15 = (unsigned int) &linkParamsR15;

    call_rxsvc(&svcParams);
    rc = svcParams.R15;

    if (_evalblock_ptr->evalblock_evlen > 0) {
        Lscpy2(result,  (char *)&_evalblock_ptr->evalblock_evdata, _evalblock_ptr->evalblock_evlen);

        setIntegerVariable("RC", rc);
        setVariable("RESULT", (char *)LSTR(*result));
    }

    FREE(_evalblock_ptr);

    return rc;
}
