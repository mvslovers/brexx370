#include <errno.h>
#include <stdio.h>
#include <string.h>

#include "dsio.h"
#include "util.h"

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
    char name[DSN_NAME_MAX + 2 + 1];    /* in quotes: fully qualified */

    if (dsn == NULL || mode == NULL || dsn[0] == '\0' || strlen(dsn) > DSN_NAME_MAX) {
        errno = EINVAL;
        return NULL;
    }
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
