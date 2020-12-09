#include <stdio.h>
#include <string.h>
#include "metal.h"
#include "irx.h"

#define SPACE_LENGTH                1
#define MAX_ENV_LENGTH              8
#define MAX_CMD_LENGTH              256
#define MAX_CPPLBUF_DATA_LENGTH     MAX_ENV_LENGTH + SPACE_LENGTH + MAX_CMD_LENGTH

typedef struct env_ctx_t {
    char    SYSPREF[8];
    char    SYSUID[8];
    char    SYSENV[5];
    char    SYSISPF[11];
    unsigned char flags1;  /* allocations */
    unsigned char flags2;  /* environment */
    unsigned char flags3;  /* unused */
    unsigned char flags4;  /* unused */
    void         *literals;
    void         *variables;
    int           proc_id;
    void         *cppl;
    unsigned      dummy[28];
    unsigned     *VSAMSUBT;
    unsigned      reserved[64];
} *pEnvCtx;

typedef struct cpplbuf_t {
    hword length;
    hword offset;
    char  data[MAX_CPPLBUF_DATA_LENGTH];
} cpplbuf;

typedef int     irxexcom_func_t (const char *, void *, void *, struct shvblock *, ...);
typedef         irxexcom_func_t *   irxexcom_func_p;
static          irxexcom_func_p     irxexcom;

int handleMVSCommands(struct envblock *pEnvblock, struct parm *parms);

int handleISPEXECCommands(struct envblock *pEnvblock, struct parm *parms);

int IRXSTAM() {
    int rc = 0;

    struct envblock  *      envblockp;
    struct parm      *      parms;

    envblockp  = (struct envblock *) _xregs(0); // GPR0
    parms      = (struct parm     *) _xregs(1); // GPR1



    if (memcmp("MVS     ", parms->envname, 8) == 0) {
        rc = handleMVSCommands(envblockp, parms);
    } else if (memcmp("ISPEXEC ", parms->envname, 8) == 0) {
        rc = handleISPEXECCommands(envblockp, parms);
    } else {
        rc = -3;
    }

    _clrbuf();

    *parms->retcode = rc;

    return rc;
}

int handleISPEXECCommands(struct envblock *pEnvblock, struct parm *parms) {
    int rc = 0;

    pEnvCtx userfield;

    void **cppl;
    void **buf;
    void *newBuf;

    char moduleName[8];

    userfield = pEnvblock->envblock_userfield;
    if (userfield != NULL) {
        cppl = userfield->cppl;
    } else {
       rc = -3;
    }

    if (rc == 0) {
        void *R15params[2];

        int R0,R1,R15;

        cpplbuf cpplBuffer;
        char *ptr;

        bzero(&cpplBuffer, sizeof(cpplbuf));

        ptr = cpplBuffer.data;
        memcpy(ptr, parms->envname, 8);
        ptr = ptr + 8;

        memcpy(ptr, " ", 1);
        ptr = ptr + 1;

        memcpy(ptr, *parms->cmdstring, *parms->cmdlen);
        ptr = ptr + *parms->cmdlen;

        memcpy(ptr, 0x00, 1);

        cpplBuffer.length = strlen(cpplBuffer.data) + 4;
        cpplBuffer.offset = 9;

        cppl[0] = &cpplBuffer;

        // prepare GPR15
        R15params[0] = parms->envname;
        R15params[1] = 0;

        R0  = (int) (uintptr_t) pEnvblock;
        R1  = (int) (uintptr_t) cppl;
        R15 = (int) (uintptr_t) R15params;

        SVC(6, &R0, &R1, &R15);

        rc = R15;
    }

    return rc;
}

int  handleMVSCommands(struct envblock *pEnvblock, struct parm *parms) {
    int rc = 42;

    printf("FOO> IRXSTAM will handle MVS command \n");

    return rc;
}

/*
    struct shvblock         shvblock;

    extep      = (struct irxexte *) envblockp->envblock_irxexte;
    irxexcom   = (irxexcom_func_p) extep->irxexcom;

    memset(&shvblock, 0, sizeof(shvblock));
    shvblock.shvcode = shvstore;
    shvblock.shvnama = (void *) varname;
    shvblock.shvnaml = strlen(varname);
    shvblock.shvvala = (void *) varvalue;
    shvblock.shvvall = varlen;

    rc = (* irxexcom) ("IRXEXCOM", NULL, NULL, &shvblock, envblockp);
*/


