#include <string.h>
#include "rac.h"
#include "rxmvsext.h"

int rac_status()
{
    int isRacSecured = 0;

    void ** psa;            // PSA     =>    0 / 0x00
    void ** cvt;            // FLCCVT  =>   16 / 0x10
    void ** safv;           // CVTSAF  =>  248 / 0xF8

    void ** safvid;         // SAFVIDEN =>   0 / 0x00

    psa  = 0;
    cvt  = psa[4];          // 16
    safv = cvt[62];         // 248

    if (safv != NULL) {
        safvid = safv;
        if (strncmp((char *)safvid, "SAFV", 4) == 0) {
            isRacSecured = 1;
        }
    }

    return isRacSecured;
}

int rac_facility_check(char *className, char *facilityName, char *attributeName)
{
    int isAuthorized = 0;

    RAC_AUTH_PARMS parms;
    P_CLASS classPtr;
    int classNameLength;

    char facility[39];

    RX_SVC_PARAMS svcParams;

    classNameLength = (short) strlen(className);
    classPtr = malloc(classNameLength + 1);
    classPtr->length = classNameLength;
    memset(classPtr->name, ' ', 8);
    memcpy(classPtr->name, className, classNameLength);

    /*
    printf("\nDBG> Class = '%.*s' at %p \n", (int) classNameLength+1, classPtr->name, classPtr);
    DumpHex((void *)classPtr, classNameLength+1);
    */

    memset(facility, ' ', sizeof(facility));
    memcpy(facility, facilityName, strlen(facilityName));

    bzero(&parms, sizeof(RAC_AUTH_PARMS));

    parms.installation_params = 0;
    ((uint24xptr_t *) (&parms.installation_params))->xbyte = sizeof(RAC_AUTH_PARMS);

    /*
    printf("\nDBG> Entity = '%.*s' at %p \n", 39, facility, facility);
    DumpHex((void *)facility, 39);
    */

    parms.entity_profile = facility;
    ((uint24xptr_t *) (&parms.entity_profile))->xbyte = 0;

    parms.class = classPtr;
    ((uint24xptr_t *)(&parms.class))->xbyte = 2; //READ

    svcParams.SVC = 130;
    svcParams.R1  = (uintptr_t) &parms;

    /*
    printf("\nDBG> RACHECK parameter list\n");
    DumpHex((void *)svcParams.R1, sizeof(RAC_AUTH_PARMS));
    */

    call_rxsvc(&svcParams);

    if (svcParams.R15 == 0) {
        isAuthorized = 1;
    }

    return isAuthorized;
}
