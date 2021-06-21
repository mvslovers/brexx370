#include <rxmvsext.h>
#include "smf.h"

int writeUserSmfRecord(P_SMF_RECORD smfRecord)
{
    int rc;

    RX_SVC_PARAMS svcParams;

    // switch off authorisation
    privilege(1);     // requires authorisation

    svcParams.SVC = 83;
    svcParams.R0  = 0;
    svcParams.R1  = (uintptr_t) smfRecord;

    call_rxsvc(&svcParams);

    rc = (int) svcParams.R15;

    // switch off authorisation
    privilege(0);    // switch authorisation off

    return rc;
}


