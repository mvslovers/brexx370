#include <string.h>
#include "printf.h"
#include "metal.h"
#include "irx.h"

#define SPACE_LENGTH                1
#define CPPL_HEADER_LENGTH          4
#define MAX_ENV_LENGTH              8
#define MAX_CMD_LENGTH              256
#define MAX_CPPLBUF_DATA_LENGTH     MAX_ENV_LENGTH + SPACE_LENGTH + MAX_CMD_LENGTH

const int __libc_arch       = 0;

const unsigned char _TSOFG  = 0x1; // hex for 0000 0001
const unsigned char _TSOBG  = 0x2; // hex for 0000 0010
const unsigned char _ISPF   = 0x8; // hex for 0000 1000

typedef struct env_ctx_t {
    char    SYSPREFÝ8¨;
    char    SYSUIDÝ8¨;
    char    SYSENVÝ5¨;
    char    SYSISPFÝ11¨;
    unsigned char flags1;  /* allocations */
    unsigned char flags2;  /* environment */
    unsigned char flags3;  /* unused */
    unsigned char flags4;  /* unused */
    void         *literals;
    void         *variables;
    int           proc_id;
    void         *cppl;
    unsigned      dummyÝ28¨;
    unsigned     *VSAMSUBT;
    unsigned      reservedÝ64¨;
} envContext;
typedef struct cpplbuf_t {
    hword length;
    hword offset;
    char  dataÝMAX_CPPLBUF_DATA_LENGTH¨;
} cpplbuf;
typedef struct cppl_t    {
    cpplbuf *buffer;
    void    *upt;
    void    *pscb;
    void    *ect;
} cppl;

typedef int     irxexcom_func_t (const char *, void *, void *, struct shvblock *, ...);
typedef         irxexcom_func_t *   irxexcom_func_p;
static          irxexcom_func_p     irxexcom;

typedef int     isplink_func_t ();
typedef         isplink_func_t *    isplink_func_p;
static          isplink_func_p      isplink;

int handleMVSCommands(struct envblock *pEnvblock, struct parm *parms);
int handleTSOCommands(struct envblock *p_env_block, struct parm *parms);
int handleISPEXECCommands(struct envblock *pEnvBlock, struct parm *parms);

int IRXSTAM() {
    int rc = 0;

    struct envblock  *      envblockp;
    struct parm      *      parms;

    envblockp  = (struct envblock *) _xregs(0); // GPR0
    parms      = (struct parm     *) _xregs(1); // GPR1

    if (memcmp("MVS     ", parms->envname, 8) == 0) {
        rc = handleMVSCommands(envblockp, parms);
    } else if (memcmp("TSOX    ", parms->envname, 8) == 0) {
        rc = handleTSOCommands(envblockp, parms);
    } else if (memcmp("ISPEXEC ", parms->envname, 8) == 0) {
        rc = handleISPEXECCommands(envblockp, parms);
    } else {
        rc = -3;
    }

    _clrbuf();

    *parms->retcode = rc;

    return rc;
}

int handleTSOCommands(struct envblock *p_env_block, struct parm *parms) {
    int rc = 0;

    cppl *p_cppl;

    envContext *pEnvContext = p_env_block->envblock_userfield;

    if (pEnvContext != NULL) {
        // make sure we are running inside TSO
        if ((pEnvContext->flags2 & _TSOFG) == _TSOFG ||
            (pEnvContext->flags2 & _TSOBG) == _TSOBG) {
            p_cppl = pEnvContext->cppl;
        } else {
            rc = -3;
        }
    } else {
        rc = -3;
    }

    if (rc == 0) {

        cpplbuf *cpplBuffer;
        char8   modulName;

        char *p_cpplBufferData;
        char *p_parmsCmdString;

        int len;
        int ii = 0;

        // allocate memory for new buffer
        cpplBuffer = _getm(sizeof(cpplbuf));

        // temporary pointer
        p_cpplBufferData = cpplBuffer->data;
        p_parmsCmdString = *parms->cmdstring;

        // excracting the load module name from command string
        len = *parms->cmdlen;
        memset(modulName, ' ', sizeof(char8));
        while (ii < sizeof(char8) && (*parms->cmdstring)Ýii¨ != ' ' &&  (*parms->cmdstring)Ýii¨ != 0x00) {
            ((char *)modulName)Ýii¨ = (*parms->cmdstring)Ýii¨;
            p_parmsCmdString++;
            len--;
            ii++;
        }

        if (len > 0) {
            // skip the blank
            p_parmsCmdString++;
            len--;

            // clear cpplbuff with blanks
            memset(p_cpplBufferData, ' ', sizeof(cpplbuf));

            // copy command string to buffer
            memcpy(p_cpplBufferData, p_parmsCmdString, len);
        }

        // fill cppl buffer header
        cpplBuffer->length = CPPL_HEADER_LENGTH + len;
        cpplBuffer->offset = 0;

        // link new cppl buffer into cppl
        p_cppl->buffer = cpplBuffer;

        // call link svc
        if (_bldl(modulName)) {
            rc = _link(modulName, p_cppl, p_env_block);
        } else {
            rc = -3;
        }

        _free(cpplBuffer);
    }

    if (rc != 0) {
        printf("FOO> RC is not 0 but %d \n", rc);
    }

    return rc;
}

int handleISPEXECCommands(struct envblock *pEnvBlock, struct parm *parms) {
    int rc = 0;

    envContext *pEnvContext;

    void **cppl;

    /*
    rc = _load("ISPLINK ", (void **) &isplink);
    if (rc == 0) {
        rc = isplink("DISPLAY ", "P1      ", "        ");
    }

    return rc;
    */

    pEnvContext = pEnvBlock->envblock_userfield;
    if (pEnvContext != NULL) {
        // make sure we are running inside ISPF
        if ((pEnvContext->flags2 & _ISPF) != _ISPF) {
            rc = -3;
        } else {
            cppl = pEnvContext->cppl;
        }
    } else {
       rc = -3;
    }

    if (rc == 0) {
        cpplbuf cpplBuffer;

        // temporary pointer
        char *p_cpplBufferData = cpplBuffer.data;

        // clear cpplbuff with blanks
        memset(p_cpplBufferData, ' ', sizeof(cpplbuf));

        // copy environment name to buffer
        memcpy(p_cpplBufferData, parms->envname, MAX_ENV_LENGTH);
        p_cpplBufferData = p_cpplBufferData + MAX_ENV_LENGTH + 1;

        // copy command string to buffer
        memcpy(p_cpplBufferData, *parms->cmdstring, *parms->cmdlen);

        // fill cppl buffer header
        cpplBuffer.length = CPPL_HEADER_LENGTH + (MAX_ENV_LENGTH + 1) + *parms->cmdlen;
        cpplBuffer.offset = MAX_ENV_LENGTH + 1;

        // link new cppl buffer into cppl
        cpplÝ0¨ = &cpplBuffer;

        // call link svc
        if (_bldl(parms->envname)) {
            rc = _link(parms->envname, cppl, pEnvBlock);
        }
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


