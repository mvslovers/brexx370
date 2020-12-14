#include <string.h>
#include "hostenv.h"
#include "mvssup.h"
#include "lstring.h"
#include "irx.h"

// - Host Environment Command Router -

int IRXSTAM(RX_ENVIRONMENT_BLK_PTR pEnvBlock, RX_HOSTENV_PARAMS_PTR  parms) {
    int rc;

    if (memcmp("MVS     ", parms->envName, 8) == 0) {
        rc = handleMVSCommands(pEnvBlock, parms);
    } else if (memcmp("TSOX    ", parms->envName, 8) == 0) {
        rc = handleTSOCommands(pEnvBlock, parms);
    } else if (memcmp("ISPEXEC ", parms->envName, 8) == 0) {
        rc = handleISPEXECCommands(pEnvBlock, parms);
    } else {
        rc = -3;
    }

    *parms->returnCode = rc;

    return rc;
}

int handleTSOCommands(RX_ENVIRONMENT_BLK_PTR pEnvBlock, RX_HOSTENV_PARAMS_PTR  pParms) {
    int rc = 0;

    void **cppl;
    byte *ect;

    if (isTSO()) {
        cppl = entry_R13[6];
        ect  = cppl[3];
    } else {
        rc = -3;
    }

    if (rc == 0) {
        cpplbuf cpplBuffer;
        cpplbuf *cpplBuffer_old;

        char    *ectPCMD;
        char8   modulName;

        int ii = 0;

        // save old cpplBuf
        cpplBuffer_old = cppl[0];

        // TODO: do we need to restore the pcmd value?
        ectPCMD = (char *) (ect+12);

        memset(ectPCMD, ' ', 8);

        // excracting the load module name from command string
        memset(modulName, ' ', sizeof(char8));
        while (ii < sizeof(char8) && (*pParms->cmdString)[ii] != ' ' &&  (*pParms->cmdString)[ii] != 0x00) {
            // copy module name char by char
            ((char *)modulName)[ii] = (*pParms->cmdString)[ii];

            // we also write it to the ectpcmd field
            ectPCMD[ii] = (*pParms->cmdString)[ii];
            ii++;
        }

        // copy command string into the new cppl buffer
        memset(cpplBuffer.data, ' ', MAX_CPPLBUF_DATA_LENGTH);
        memcpy(cpplBuffer.data, *pParms->cmdString, *pParms->cmdLength);

        // fill cppl buffer header
        cpplBuffer.length = CPPL_HEADER_LENGTH + (*pParms->cmdLength);
        cpplBuffer.offset = ii == *pParms->cmdLength ? ii : ii + 1;

        // link new cppl buffer into cppl
        cppl[0] = &cpplBuffer;

        // call link svc
        if (findLoadModule(modulName)) {
            rc = linkLoadModule(modulName, cppl, pEnvBlock);
        } else {
            // marker for module not found
            rc = 0x806000;
        }

        cppl[0] = cpplBuffer_old;
    }

    return rc;
}

int handleISPEXECCommands(RX_ENVIRONMENT_BLK_PTR pEnvBlock, RX_HOSTENV_PARAMS_PTR  parms) {
    int rc = 0;

    void **cppl;

    if (isTSO()) {
        cppl = entry_R13[6];
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
        memcpy(p_cpplBufferData, parms->envName, MAX_ENV_LENGTH);
        p_cpplBufferData = p_cpplBufferData + MAX_ENV_LENGTH + 1;

        // copy command string to buffer
        memcpy(p_cpplBufferData, *parms->cmdString, *parms->cmdLength);

        // fill cppl buffer header
        cpplBuffer.length = CPPL_HEADER_LENGTH + (MAX_ENV_LENGTH + 1) + *parms->cmdLength;
        cpplBuffer.offset = MAX_ENV_LENGTH + 1;

        // link new cppl buffer into cppl
        cppl[0] = &cpplBuffer;

        // call link svc
        if (findLoadModule(parms->envName)) {
            rc = linkLoadModule(parms->envName, cppl, pEnvBlock);
        } else {
            // marker for module not found
            rc = 0x806000;
        }
    }

    return rc;
}

int handleMVSCommands(RX_ENVIRONMENT_BLK_PTR pEnvBlock, RX_HOSTENV_PARAMS_PTR  parms) {
    int rc = 42;

    printf("FOO> IRXSTAM will handle MVS command \n");

    return rc;
}


