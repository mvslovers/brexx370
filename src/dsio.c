#include <errno.h>
#include <stdio.h>
#include <string.h>

#include <mvs/dscb.h>

/* no BREXX header beyond dsio.h here: ldefs.h defines ROUND(), which
 * <mvs/dscb.h> uses as a flag name */
#include "dsio.h"

/* this module is the one that calls libc370's fopen() itself, not the
 * JCC layer's jcc_fopen() that compat/jccompat.h maps it to (#298, #299);
 * the mapping exists only where jccompat.h is force-included */
#ifdef fopen
#undef fopen
#endif

#define DD_NAME_MAX (8 + 1 + 8 + 1)     /* ddname(member) */

FILE *
rxOpenDsn(const char *dsn, const char *mode)
{
    char   name[DSN_NAME_MAX + 2 + 1];  /* in quotes: fully qualified */
    size_t len;
    int    asIs;

    if (dsn == NULL || mode == NULL || dsn[0] == '\0') {
        errno = EINVAL;
        return NULL;
    }
    /* 'dsn' and &temp stand as they are; everything else gets quotes */
    asIs = (dsn[0] == '\'' || dsn[0] == '&');
    len  = strlen(dsn);
    if (len > DSN_NAME_MAX + (asIs ? 2 : 0)) {
        errno = EINVAL;
        return NULL;
    }
    if (asIs)
        return fopen(dsn, mode);
    snprintf(name, sizeof(name), "'%s'", dsn);
    return fopen(name, mode);
}

FILE *
rxOpenDd(const char *ddn, const char *mode)
{
    char name[3 + DD_NAME_MAX + 1];     /* DD:ddname(member) */

    if (ddn == NULL || mode == NULL || ddn[0] == '\0' || strlen(ddn) > DD_NAME_MAX) {
        errno = EINVAL;
        return NULL;
    }
    snprintf(name, sizeof(name), "DD:%s", ddn);
    return fopen(name, mode);
}

int
rxWalkDir(const char *name, int byDd, PDS_WALK fn, void *arg)
{
    char full[3 + DSN_NAME_MAX + 2 + 1];    /* 'dsn' or DD:ddname */

    if (name == NULL || name[0] == '\0' ||
        strlen(name) > (byDd ? (size_t) DD_NAME_MAX : (size_t) DSN_NAME_MAX)) {
        errno = EINVAL;
        return -1;
    }
    if (byDd)
        snprintf(full, sizeof(full), "DD:%s", name);
    else
        snprintf(full, sizeof(full), "'%s'", name);
    return __walkpd(full, NULL, fn, arg);
}

int
rxDsAttr(const char *dsn, char volser[6 + 1], char dsorg[2 + 1])
{
    char    dsn44[44];                  /* blank padded, as OBTAIN takes it */
    LOCWORK loc;
    DSCB    dscb;
    size_t  len;

    if (dsn == NULL || volser == NULL || dsorg == NULL) {
        errno = EINVAL;
        return -1;
    }
    len = strlen(dsn);
    if (len == 0 || len > sizeof(dsn44)) {
        errno = EINVAL;
        return -1;
    }
    memset(dsn44, ' ', sizeof(dsn44));
    memcpy(dsn44, dsn, len);
    memset(&loc, 0, sizeof(loc));
    memset(&dscb, 0, sizeof(dscb));

    if (__locate(dsn44, &loc) != 0 || __dscbdv(dsn44, loc.volser, &dscb) != 0)
        return -1;

    memcpy(volser, loc.volser, 6);
    volser[6] = '\0';
    if (dscb.dscb1.dsorg1 & DSGPO)
        strcpy(dsorg, "PO");
    else if (dscb.dscb1.dsorg1 & DSGPS)
        strcpy(dsorg, "PS");
    else if (dscb.dscb1.dsorg1 & DSGDA)
        strcpy(dsorg, "DA");
    else if (dscb.dscb1.dsorg1 & DSGIS)
        strcpy(dsorg, "IS");
    else
        strcpy(dsorg, "??");
    return 0;
}
