#include "rxmvsext.h"
#include "svc99.h"

int svc99(__S99parms *parms)
{
    int rc;

    unsigned int tmp;
    RX_SVC_PARAMS svcParams;

    // set high order bit
    tmp = (unsigned int) parms;
    tmp |= MASK;

    svcParams.SVC = 99;
    svcParams.R0  = 0;
    svcParams.R1  = (unsigned int) &tmp;
    svcParams.R15 = 0;

    call_rxsvc(&svcParams);

    rc = (int) svcParams.R15;

    return rc;
}
