#include <string.h>
#include "rac.h"
#include "rxmvsext.h"
#include "hashmap.h"

const bool NOT_AUTHORIZED = 0;
const bool AUTHORIZED     = 1;

HashMap *profiles = NULL;

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

void * getACEE()
{
    void ** psa;           // PAS      =>   0 / 0x00
    void ** ascb;          // PSAAOLD  => 548 / 0x224
    void ** asxb;          // ASCBASXB => 108 / 0x6C
    void ** acee;          // ASXBSENV => 200 / 0xC8

    if (isTSO()) {
        psa  = 0;
        ascb = psa[137];
        asxb = ascb[27];
        acee = asxb[50];

    } else {
        acee = NULL;
    }

    return acee;
}

int rac_check(const char *className, const char *profileName, const char *attributeName)
{
    int isAuthorized = 0;

    RAC_AUTH_PARMS parms;
    P_CLASS classPtr;
    int classNameLength;

    char profile[39];

    RX_SVC_PARAMS svcParams;

    if (profiles == NULL) {
        profiles = hashMapNew(10);
    }

    if (hashMapGet(profiles, (char *) profileName) != NULL) {
        return * (int *) hashMapGet(profiles, (char *) profileName);
    }

    classNameLength = (short) strlen((const char *) className);
    classPtr = malloc(classNameLength + 1);
    classPtr->length = classNameLength;
    memset(classPtr->name, ' ', 8);
    memcpy(classPtr->name, className, classNameLength);

    memset(profile, ' ', sizeof(profile));
    memcpy(profile, profileName, strlen((const char *) profileName));

    bzero(&parms, sizeof(RAC_AUTH_PARMS));

    parms.installation_params = 0;
    ((uint24xptr_t *) (&parms.installation_params))->xbyte = sizeof(RAC_AUTH_PARMS);

    parms.entity_profile = profile;
    ((uint24xptr_t *) (&parms.entity_profile))->xbyte = 0;

    parms.class = classPtr;

    /*
       8    (8)	    BITSTRING   1   ACHKFLG2	SECOND FLAGS BYTE
 	        	    1... ....	    ACHKTALT	ATTR=ALTER
 	 	            .111 ....	    *	        Reserved
 	 	            .... 1...	    ACHKTCTL	ATTR=CONTROL
 	 	            .... .1..	    ACHKTUPD	ATTR=UPDATE
 	 	            .... ..1.	    ACHKTRD	    ATTR=READ
 	 	            .... ...1	    *	        Reserved
     */
    if (strcasecmp((const char *) attributeName, "READ") == 0) {
        ((uint24xptr_t *)(&parms.class))->xbyte = 2;   // READ
    } else if (strcasecmp((const char *) attributeName, "UPDATE") == 0) {
        ((uint24xptr_t *)(&parms.class))->xbyte = 4;   // UPDATE
    } else if (strcasecmp((const char *) attributeName, "CONTROL") == 0) {
        ((uint24xptr_t *)(&parms.class))->xbyte = 8;   // CONTROL
    } else if (strcasecmp((const char *) attributeName, "ALTER") == 0) {
        ((uint24xptr_t *)(&parms.class))->xbyte = 128; // ALTER
    }

    parms.acee = getACEE();

    svcParams.SVC = 130;
    svcParams.R1  = (uintptr_t) &parms;

    call_rxsvc(&svcParams);

    if (svcParams.R15 == 0) {
        isAuthorized = 1;
    }

    free(classPtr);

    if (isAuthorized) {
        hashMapSet(profiles, (char *) profileName, (void *) &AUTHORIZED);
    } else {
        hashMapSet(profiles, (char *) profileName, (void *) &NOT_AUTHORIZED);
    }

    return isAuthorized;
}
