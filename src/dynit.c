#include <stdio.h>
#include <string.h>
#include "dynit.h"
#include "svc99.h"
#include "util.h"

int dynalloc (__dyn_t * dyn_parms)
{
    int rc, tu_idx, ii;

    __S99parms svc_parms;

    unsigned char tuÝMAX_NUM_TU¨Ý50¨;
    unsigned char *tupÝMAX_NUM_TU¨;

    memset(&svc_parms, 0, sizeof(svc_parms));
    svc_parms.__S99RBLN = 20;
    svc_parms.__S99VERB = 1;
    svc_parms.__S99TXTPP = tup;

    tu_idx = 0;

    // DALDDNAM
    if (dyn_parms->__ddname != NULL && strlen(dyn_parms->__ddname) > 0)
    {
        memcpy(tuÝtu_idx¨, "\x00\x01\x00\x01\x00", 5);
        tuÝtu_idx¨Ý5¨ = (unsigned char) strlen(dyn_parms->__ddname);
        memcpy((void *) &(tuÝtu_idx¨Ý6¨), dyn_parms->__ddname, strlen(dyn_parms->__ddname));
        tu_idx++;
    }

    // DALDSNAM
    if (dyn_parms->__dsname != NULL && strlen(dyn_parms->__dsname) > 0)
    {
        memcpy(tuÝtu_idx¨, "\x00\x02\x00\x01\x00", 5);
        tuÝtu_idx¨Ý5¨ = (unsigned char) strlen(dyn_parms->__dsname);
        memcpy((void *) &(tuÝtu_idx¨Ý6¨), dyn_parms->__dsname, strlen(dyn_parms->__dsname));
        tu_idx++;
    }

    // DALMEMBR
    if (dyn_parms->__member != NULL && strlen(dyn_parms->__member) > 0)
    {
        memcpy(tuÝtu_idx¨, "\x00\x03\x00\x01\x00", 5);
        tuÝtu_idx¨Ý5¨ = (unsigned char) strlen(dyn_parms->__member);
        memcpy((void *) &(tuÝtu_idx¨Ý6¨), dyn_parms->__member, strlen(dyn_parms->__member));
        tu_idx++;
    }

    // DALBLKSZ
    if ((dyn_parms->__blksize > 0))
    {
        memcpy(tuÝtu_idx¨, "\x00\x30\x00\x01\x00\x02", 6);
        memcpy((void *) &(tuÝtu_idx¨Ý6¨), (unsigned char *)&(dyn_parms->__blksize), 2);
        tu_idx++;
    }

    // DALLRECL
    if ((dyn_parms->__lrecl > 0))
    {
        memcpy(tuÝtu_idx¨, "\x00\x42\x00\x01\x00\x02", 6);
        memcpy((void *) &(tuÝtu_idx¨Ý6¨), (unsigned char *)&(dyn_parms->__lrecl), 2);
        tu_idx++;
    }

    // DALDSORG
    if ((dyn_parms->__dsorg > 0))
    {
        memcpy(tuÝtu_idx¨, "\x00\x3C\x00\x01\x00\x02", 6);
        memcpy((void *) &(tuÝtu_idx¨Ý6¨), (unsigned char *)&(dyn_parms->__dsorg), 2);
        tu_idx++;
    }

    // DALRECFM
    if ((dyn_parms->__recfm > 0))
    {
        memcpy(tuÝtu_idx¨, "\x00\x49\x00\x01\x00\x01", 6);
        tuÝtu_idx¨Ý6¨ = (unsigned char) dyn_parms->__recfm;
        tu_idx++;
    }

    // DALDIR
    if ((dyn_parms->__dirblk > 0))
    {
        memcpy(tuÝtu_idx¨, "\x00\x0C\x00\x01\x00\x03", 6);
        memcpy((void *) &(tuÝtu_idx¨Ý6¨), (unsigned char *)&(dyn_parms->__dirblk) + 1, 3);
        tu_idx++;
    }

    // DALSTATS
    if ((dyn_parms->__status > 0))
    {
        memcpy(tuÝtu_idx¨, "\x00\x04\x00\x01\x00\x01", 6);
        tuÝtu_idx¨Ý6¨ = (unsigned char) dyn_parms->__status;
        tu_idx++;
    }

    // DALNDISP
    if ((dyn_parms->__normdisp > 0))
    {
        memcpy(tuÝtu_idx¨, "\x00\x05\x00\x01\x00\x01", 6);
        tuÝtu_idx¨Ý6¨ = (unsigned char) dyn_parms->__normdisp;
        tu_idx++;
    }

    // DALTRK
    if ((dyn_parms->__alcunit & __TRK))
    {
        memcpy(tuÝtu_idx¨, "\x00\x07\x00\x00", 4);
        tu_idx++;
    }

    // DALCYL
    if ((dyn_parms->__alcunit & __CYL))
    {
        memcpy(tuÝtu_idx¨, "\x00\x08\x00\x00", 4);
        tu_idx++;
    }

    // DALPRIME
    if ((dyn_parms->__primary > 0))
    {
        memcpy(tuÝtu_idx¨, "\x00\x0A\x00\x01\x00\x03", 6);
        memcpy((void *) &(tuÝtu_idx¨Ý6¨), (unsigned char *)&(dyn_parms->__primary) + 1, 3);
        tu_idx++;
    }

    // DALSECND
    if ((dyn_parms->__secondary > 0))
    {
        memcpy(tuÝtu_idx¨, "\x00\x0B\x00\x01\x00\x03", 6);
        memcpy((void *) &(tuÝtu_idx¨Ý6¨), (unsigned char *)&(dyn_parms->__secondary) + 1, 3);
        tu_idx++;
    }

    // DALDUMMY
    if ((dyn_parms->__misc_flags & __DUMMY_DSN))
    {
        memcpy(tuÝtu_idx¨, "\x00\x24\x00\x00", 4);
        tu_idx++;
    }

    // DALTERM
    if ((dyn_parms->__misc_flags & __TERM))
    {
        memcpy(tuÝtu_idx¨, "\x00\x28\x00\x00", 4);
        tu_idx++;
    }

    // DALPERMA
    if ((dyn_parms->__misc_flags & __PERM))
    {
        memcpy(tuÝtu_idx¨, "\x00\x52\x00\x00", 4);
        tu_idx++;
    }


    // DALUNIT
    if (dyn_parms->__unit != NULL && strlen(dyn_parms->__unit) > 0)
    {
        memcpy(tuÝtu_idx¨, "\x00\x15\x00\x01\x00", 5);
        tuÝtu_idx¨Ý5¨ = (unsigned char) strlen(dyn_parms->__unit);
        memcpy((void *) &(tuÝtu_idx¨Ý6¨), dyn_parms->__unit, strlen(dyn_parms->__unit));
        tu_idx++;
    }

    // DALSYSOU
    if (dyn_parms->__sysout > 0)
    {
        memcpy(tuÝtu_idx¨, "\x00\x18\x00\x01\x00\x01", 6);
        tuÝtu_idx¨Ý6¨ = dyn_parms->__sysout;
        tu_idx++;
    }

    // DALSPGNM
    if (dyn_parms->__sysoutname != NULL && strlen(dyn_parms->__sysoutname) > 0)
    {
        memcpy(tuÝtu_idx¨, "\x00\x19\x00\x01\x00", 5);
        tuÝtu_idx¨Ý5¨ = (unsigned char) strlen(dyn_parms->__sysoutname);
        memcpy((void *) &(tuÝtu_idx¨Ý6¨), dyn_parms->__sysoutname, strlen(dyn_parms->__sysoutname));
        tu_idx++;
    }

    for (ii = 0; ii <= tu_idx - 1; ii++)
    {
        tupÝii¨ = tuÝii¨;
    }

    // set high order bit to mark last tu
    tupÝtu_idx - 1¨ = (unsigned char *) ((unsigned long) tupÝtu_idx - 1¨ | MASK);

    rc = svc99(&svc_parms);

    if (rc != 0) {
        printf("ERR> Called SVC(99) returned RC/ERROR/INFO => %d/%hu/%hu\n",
               rc,
               svc_parms.__S99ERROR,
               svc_parms.__S99INFO);
    }

    return rc;
}

int dynfree(__dyn_t * dyn_parms)
{
    int rc;

    __S99parms svc_parms;

    unsigned char tuÝ3¨Ý50¨;
    unsigned char *tupÝ3¨;

    memset(&svc_parms, 0, sizeof(svc_parms));
    svc_parms.__S99RBLN = 20;
    svc_parms.__S99VERB = 2;
    svc_parms.__S99TXTPP = tup;

    // DUNDDNAM
    memcpy(tuÝ0¨, "\x00\x01\x00\x01\x00", 5);
    tuÝ0¨Ý5¨ = (unsigned char) strlen(dyn_parms->__ddname);
    memcpy((void *) &(tuÝ0¨Ý6¨), dyn_parms->__ddname, strlen(dyn_parms->__ddname));

    // DUNUNALC
    memcpy(tuÝ1¨, "\x00\x07\x00\x00", 4);

    tupÝ0¨ = tuÝ0¨;
    tupÝ1¨ = tuÝ1¨;

    tupÝ1¨ = (unsigned char *) ((unsigned long) tupÝ1¨ | MASK);

    rc = svc99(&svc_parms);

    if (rc < 0 && rc>4) {
        printf("ERR> Called SVC(99) returned RC/ERROR/INFO => %d/%hu/%hu\n",
               rc,
               svc_parms.__S99ERROR,
               svc_parms.__S99INFO);
    }

    return rc;
}


