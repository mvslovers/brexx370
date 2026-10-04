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

/* rxmvs.c; rxmvsext.h brings ldefs.h along, and with it ROUND() */
int isTSOFG();

#define DD_NAME_MAX (8 + 1 + 8 + 1)     /* ddname(member) */

/* An OPEN of a password protected data set asks for the password:
 * the operator in batch (IEC301A), the user in TSO (IEC113A). Without
 * it, or without a terminal to give it on, the OPEN does not fail, it
 * abends S913-0C (#294). So outside the TSO foreground the format-1
 * DSCB is read first, by the bare data set name -- quotes and member
 * stripped: a password for reading stops every open, one for writing
 * an open that writes. A temporary &name is the job's own, and a data
 * set that cannot be looked up is left to the OPEN to report. Returns
 * 0, or -1 with errno EACCES. */
static int
denied(const char *dsn, const char *mode)
{
    char      bare[44 + 1];
    size_t    len;
    RX_DSATTR attr;

    if (dsn[0] == '&' || isTSOFG())
        return 0;
    if (dsn[0] == '\'')
        dsn++;
    len = strcspn(dsn, "('");
    if (len == 0 || len >= sizeof(bare))
        return 0;
    memcpy(bare, dsn, len);
    bare[len] = '\0';
    for (char *p = bare; *p; p++)
        *p = (char) toupper((unsigned char) *p);
    if (rxDsAttr(bare, &attr) != 0)
        return 0;
    if (attr.password == RX_PWD_READ ||
        (attr.password == RX_PWD_WRITE && strpbrk(mode, "wa+") != NULL)) {
        errno = EACCES;
        return -1;
    }
    return 0;
}

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
    if (denied(dsn, mode) != 0)
        return NULL;
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
    else if (denied(name, "r") != 0)
        return -1;
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
    if (!(dscb.dscb1.dsind & IND10))
        attr->password = RX_PWD_NONE;
    else if (dscb.dscb1.dsind & IND04)
        attr->password = RX_PWD_WRITE;
    else
        attr->password = RX_PWD_READ;
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
    int n = 0;
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
        if (rc == 0) dyn->__lrecl = (unsigned short) n;
    } else if (strcmp(key, "BLKSIZE") == 0) {
        rc = number(val, &n);
        if (rc == 0) dyn->__blksize = (short) n;
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
    char    dsname[44 + 1];             /* dynit takes a char * */
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
    strcpy(dsname, dsn);
    dyn.__dsname    = dsname;
    dyn.__status    = __DISP_NEW;
    dyn.__normdisp  = __DISP_CATLG;
    dyn.__conddisp  = __DISP_DELETE;
    dyn.__alcunit   = __TRK;
    dyn.__primary   = 1;
    dyn.__secondary = 1;

    strcpy(copy, attrs);
    tok = copy;
    while (tok != NULL) {
        char *eq;

        next = strchr(tok, ',');
        if (next != NULL) *next++ = '\0';
        while (*tok == ' ') tok++;                  /* blanks around a key */
        for (char *e = tok + strlen(tok); e > tok && e[-1] == ' '; e--) e[-1] = '\0';
        if (*tok == '\0') {                       /* empty item, e.g. a,,b */
            tok = next;
            continue;
        }

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
        tok = next;
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
