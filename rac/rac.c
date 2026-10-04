#include <string.h>
#ifdef __MVS__
#include <mvs/racf.h>
#endif
#include <strings.h>
#include "rac.h"
#include "rxmvsext.h"
#include "hashmap.h"

const bool NOT_AUTHORIZED = 0;
const bool AUTHORIZED     = 1;

HashMap *profiles = NULL;

/* free the cache of rac_check() results and set it back to NULL, so a
 * reused copy of the module starts with an empty one (#185) */
void rac_done(void)
{
    hashMapFree(profiles, NULL);   /* the values are static constants */
    profiles = NULL;
}

int rac_status()
{
    int isRacSecured = 0;
#ifdef __MVS__ // only in MVS versions
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
#else
    isRacSecured=1;
#endif
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
    CLASS classEntry;
    size_t classNameLength;
    size_t profileNameLength;

    char profile[44];
    char cacheKey[8 + 1 + 8 + 1 + 44 + 1];   // class/attribute/profile

    RX_SVC_PARAMS svcParams;
    if (!rac_status()) {
        return AUTHORIZED;
    }

    // a longer name would be cut and check a different resource
    classNameLength   = strlen(className);
    profileNameLength = strlen(profileName);
    if (classNameLength < 1 || classNameLength > sizeof(classEntry.name) ||
        profileNameLength < 1 || profileNameLength > sizeof(profile) ||
        strlen(attributeName) > 8) {
        return NOT_AUTHORIZED;
    }

    // the answer depends on class and access level, not only on the profile
    snprintf(cacheKey, sizeof(cacheKey), "%s/%s/%s", className, attributeName, profileName);

    if (profiles == NULL) {
        profiles = hashMapNew(10);
    }

    if (profiles != NULL && hashMapGet(profiles, cacheKey) != NULL) {
        return * (int *) hashMapGet(profiles, cacheKey);
    }

    classEntry.length = (unsigned char) classNameLength;
    memset(classEntry.name, ' ', sizeof(classEntry.name));
    memcpy(classEntry.name, className, classNameLength);

    memset(profile, ' ', sizeof(profile));
    memcpy(profile, profileName, profileNameLength);

    memset(&parms, 0, sizeof(RAC_AUTH_PARMS));

    parms.installation_params = 0;
    ((uint24xptr_t *) (&parms.installation_params))->xbyte = sizeof(RAC_AUTH_PARMS);

    parms.entity_profile = profile;
    ((uint24xptr_t *) (&parms.entity_profile))->xbyte = 2;
    parms.class = &classEntry;

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

    if (profiles != NULL) {
        hashMapSet(profiles, cacheKey, (void *) (isAuthorized ? &AUTHORIZED : &NOT_AUTHORIZED));
    }

    return isAuthorized;
}

const char *rac_user(void)
{
    static char userid[8 + 1];
#ifdef __MVS__
    ACEE *acee = racf_get_acee();
    int   len;

    userid[0] = '\0';
    if (acee != NULL) {
        len = (unsigned char) acee->aceeuser[0];
        if (len > 8) len = 8;
        memcpy(userid, &acee->aceeuser[1], len);
        userid[len] = '\0';
    }
#endif
    return userid;
}
