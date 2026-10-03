#include <errno.h>
#include <stdio.h>
#include <string.h>

#include <ctype.h>
#include <stdlib.h>
#include <mvs/dscb.h>

/* no BREXX header beyond dsio.h here: ldefs.h defines ROUND(), which
 * <mvs/dscb.h> uses as a flag name */
#include "dsio.h"
#include "dynit.h"


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
rxDsAttr(const char *dsn, RX_DSATTR *attr)
{
    char    dsn44[44];                  /* blank padded, as OBTAIN takes it */
    LOCWORK loc;
    DSCB    dscb;
    size_t  len;

    if (dsn == NULL || attr == NULL) {
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

    memcpy(attr->volser, loc.volser, 6);
    attr->volser[6] = '\0';
    if (dscb.dscb1.dsorg1 & DSGPO)
        strcpy(attr->dsorg, "PO");
    else if (dscb.dscb1.dsorg1 & DSGPS)
        strcpy(attr->dsorg, "PS");
    else if (dscb.dscb1.dsorg1 & DSGDA)
        strcpy(attr->dsorg, "DA");
    else if (dscb.dscb1.dsorg1 & DSGIS)
        strcpy(attr->dsorg, "IS");
    else
        strcpy(attr->dsorg, "??");
    attr->recfm   = (unsigned char) dscb.dscb1.recfm;
    attr->lrecl   = dscb.dscb1.lrecl;
    attr->blksize = dscb.dscb1.blksz;
    return 0;
}

/* RECFM letters to the DCB byte dynit takes: F/V/U, then B S A M */
static int
recfmByte(const char *v, int *recfm)
{
    int r = 0;

    switch (toupper((unsigned char) *v)) {
        case 'F': r = _F_; break;
        case 'V': r = _V_; break;
        case 'U': r = _U_; break;
        default:  return -1;
    }
    for (v++; *v; v++) {
        switch (toupper((unsigned char) *v)) {
            case 'B': r |= _B_; break;
            case 'S': r |= _S_; break;
            case 'A': r |= _A_; break;
            case 'M': r |= _M_; break;
            default:  return -1;
        }
    }
    *recfm = r;
    return 0;
}

/* a whole decimal number, 0 or more */
static int
number(const char *v, int *n)
{
    char *end;
    long  l;

    if (*v == '\0') return -1;
    l = strtol(v, &end, 10);
    if (*end != '\0' || l < 0 || l > 0xFFFFFF) return -1;
    *n = (int) l;
    return 0;
}

/* one KEY=value of the allocation string into dyn */
static int
createAttr(__dyn_t *dyn, char *key, char *val, char unit[8 + 1])
{
    int n;
    int rc = 0;

    for (char *p = key; *p; p++) *p = (char) toupper((unsigned char) *p);
    for (char *p = val; *p; p++) *p = (char) toupper((unsigned char) *p);

    if (strcmp(key, "DSORG") == 0) {
        if (strcmp(val, "PO") == 0)      dyn->__dsorg = __DSORG_PO;
        else if (strcmp(val, "PS") == 0) dyn->__dsorg = __DSORG_PS;
        else rc = -1;
    } else if (strcmp(key, "RECFM") == 0) {
        rc = recfmByte(val, &n);
        if (rc == 0) dyn->__recfm = (short) n;
    } else if (strcmp(key, "LRECL") == 0) {
        rc = number(val, &n);
        dyn->__lrecl = (unsigned short) n;
    } else if (strcmp(key, "BLKSIZE") == 0) {
        rc = number(val, &n);
        dyn->__blksize = (short) n;
    } else if (strcmp(key, "PRI") == 0) {
        rc = number(val, &dyn->__primary);
    } else if (strcmp(key, "SEC") == 0) {
        rc = number(val, &dyn->__secondary);
    } else if (strcmp(key, "DIRBLKS") == 0) {
        rc = number(val, &dyn->__dirblk);
    } else if (strcmp(key, "UNIT") == 0 && strlen(val) <= 8) {
        strcpy(unit, val);
    } else {
        rc = -1;                        /* unknown key, or UNIT too long */
    }
    return rc;
}

int
rxCreateDsn(const char *dsn, const char *attrs)
{
    __dyn_t dyn;
    char    copy[256];
    char    unit[8 + 1] = "SYSDA";
    RX_DSATTR attr;
    char    *tok;
    char    *next;
    int     rc;

    if (dsn == NULL || dsn[0] == '\0' || strlen(dsn) > 44 ||
        attrs == NULL || strlen(attrs) >= sizeof(copy)) {
        errno = EINVAL;
        return -1;
    }
    if (rxDsAttr(dsn, &attr) == 0)
        return -2;                      /* cataloged already */

    dyninit(&dyn);
    dyn.__dsname    = (char *) dsn;
    dyn.__status    = __DISP_NEW;
    dyn.__normdisp  = __DISP_CATLG;
    dyn.__conddisp  = __DISP_DELETE;
    dyn.__alcunit   = __TRK;
    dyn.__primary   = 1;
    dyn.__secondary = 1;

    strcpy(copy, attrs);
    for (tok = copy; tok != NULL; tok = next) {
        char *eq;

        next = strchr(tok, ',');
        if (next != NULL) *next++ = '\0';
        while (*tok == ' ') tok++;                  /* blanks around a key */
        for (char *e = tok + strlen(tok); e > tok && e[-1] == ' '; e--) e[-1] = '\0';
        if (*tok == '\0') continue;                 /* empty item, e.g. a,,b */

        eq = strchr(tok, '=');
        if (eq == NULL) {
            errno = EINVAL;
            return -1;
        }
        *eq = '\0';
        if (createAttr(&dyn, tok, eq + 1, unit) != 0) {
            errno = EINVAL;
            return -1;
        }
    }
    if (dyn.__dsorg == 0)
        dyn.__dsorg = dyn.__dirblk > 0 ? __DSORG_PO : __DSORG_PS;
    if (dyn.__dsorg == __DSORG_PO && dyn.__dirblk == 0)
        dyn.__dirblk = 5;
    dyn.__unit = unit;

    rc = dynalloc(&dyn);
    if (rc != 0)
        return -1;

    /* catalogued now: let the allocation go again */
    {
        __dyn_t fr;

        dyninit(&fr);
        fr.__ddname = dyn.__retddn;
        dynfree(&fr);
    }
    return 0;
}
