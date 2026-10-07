#include <string.h>
#include <strings.h>
#include <stdlib.h>

#include "addrlink.h"
#include "lstring.h"
#include "rexx.h"
#include "trace.h"
#include "stack.h"
#include "util.h"
#include "hostenv.h"

extern RX_ENVIRONMENT_BLK_PTR env_block;

int executeCmdInHostEnvironment(PLstr cmd, PLstr env);
int IRXSTAM(RX_ENVIRONMENT_BLK_PTR envblockp, RX_HOSTENV_PARAMS_PTR  pParms);

/* ------------------ RxExecuteCmd ----------------- */
int __CDECL
RxExecuteCmd(PLstr cmd, PLstr env)
{

	rxReturnCode = 0;

	LASCIIZ(*cmd)
    if (IsReturnCode((char *) LSTR(*cmd))) {
        rxReturnCode =  0x123456;
    }

    if (rxReturnCode == 0) {
        rxReturnCode = executeCmdInHostEnvironment(cmd, env);
    }

	if (rxReturnCode == -42) {
	    // TODO: move implementation to irxstam
        if (strcasecmp((const char *)LSTR(*env), "LINK")    == 0 ||
            strcasecmp((const char *)LSTR(*env), "LINKMVS") == 0 ||
            strcasecmp((const char *)LSTR(*env), "LINKEXT") == 0 ||
            strcasecmp((const char *)LSTR(*env), "LINKPGM") == 0) {

            rxReturnCode = handleLinkCommands(cmd, env);
        } else {
            // an environment BREXX does not have: -3, as TSO/E (#371)
            rxReturnCode = -3;
        }
	}

    if (rxReturnCode == 0x123456) {
        fprintf(STDERR, "Error: Invalid command name syntax\n");
        rxReturnCode = -3;
    } else if (rxReturnCode == 0x806000) {
        fprintf(STDERR, "Error: Command %s not found\n", LSTR(*cmd));
        rxReturnCode = -3;
    }

    RxSetSpecialVar(RCVAR,rxReturnCode);
    if (rxReturnCode && !(_proc[_rx_proc].trace & off_trace)) {
        if (_proc[_rx_proc].trace & (error_trace)) {
            TraceCurline(NULL,TRUE);
            fprintf(STDERR,"       +++ RC(%d) +++\n",rxReturnCode);
            if (_proc[_rx_proc].interactive_trace)
                TraceInteractive(FALSE);
        } else if ((_proc[_rx_proc].trace & (normal_trace | failure_trace))
                   && rxReturnCode < 0) {
            TraceCurline(NULL,TRUE);
            fprintf(STDERR,"       +++ RC(%d) +++\n",rxReturnCode);
            if (_proc[_rx_proc].interactive_trace)
                TraceInteractive(FALSE);
        }
    }
    /* raised whatever the TRACE setting: a negative RC is FAILURE, */
    /* or ERROR when FAILURE is not ON (#238)                       */
    if (rxReturnCode) {
        /* a CALL ON trap returns here: raise only one of the two */
        if (rxReturnCode < 0 && (_proc[_rx_proc].condition & SC_FAILURE))
            RxSignalCondition(SC_FAILURE,(char *)LSTR(*cmd));
        else if (_proc[_rx_proc].condition & SC_ERROR)
            RxSignalCondition(SC_ERROR,(char *)LSTR(*cmd));
    }

	return rxReturnCode;
} /* RxExecuteCmd */

int
executeCmdInHostEnvironment(PLstr cmd, PLstr env) {
    int rc = 0;

    char environmentName[8];
    char *commandString;
    int commandLength;

    RX_PARM_BLK_PTR        parm_block;
    RX_SUBCMD_TABLE_PTR    subcmd_table;
    RX_SUBCMD_ENTRY_PTR    subcmd_entry = NULL;
    RX_SUBCMD_ENTRY_PTR    subcmd_entries;

    RX_SVC_PARAMS      svcParams;
    RX_LINK_PARAMS_R15 linkParamsR15;
    RX_HOSTENV_PARAMS  hostenvParams;
    RX_HOSTENV_PARAMS *hostenvParamsPtr;

    bool internalRoutine = FALSE;

    memset(environmentName, ' ', 8);

    parm_block   = env_block->envblock_parmblock;
    subcmd_table = parm_block->parmblock_subcomtb;

    subcmd_entries = subcmd_table->subcomtb_first;

    memcpy(environmentName, (char *) LSTR(*env), LLEN(*env));

    // -42: not in the table (also when it is empty); RxExecuteCmd()
    // tries the LINK environments then and answers -3 otherwise
    rc = -42;
    for (int ii = 0; ii < subcmd_table->subcomtb_used; ii++) {
        subcmd_entry = &subcmd_entries[ii];
        if (memcmp(environmentName, subcmd_entry->subcomtb_name, sizeof(subcmd_entry->subcomtb_name)) == 0 ) {
            rc = 0;
            break;
        }
    }

    if (rc == 0) {
        if(strncasecmp((char *)subcmd_entry->subcomtb_routine, "IRXSTAM ", 8) == 0) {
            internalRoutine = TRUE;
        } else if (!findLoadModule((char *)subcmd_entry->subcomtb_routine)) {
            rc = -3;
        }
    }

    if (rc == 0) {
        commandString = (char *) LSTR(*cmd);
        commandLength = LLEN(*cmd);

        hostenvParams.envName    = environmentName;
        hostenvParams.cmdString  = &commandString;
        hostenvParams.cmdLength  = &commandLength;
        hostenvParams.returnCode = &rc;

        hostenvParamsPtr = &hostenvParams;
        hostenvParamsPtr = (void *) (((uintptr_t) hostenvParamsPtr) | 0x80000000);

        if(internalRoutine) {
            IRXSTAM(env_block, hostenvParamsPtr);
            rc = *hostenvParamsPtr->returnCode;
        } else {
            linkParamsR15.moduleName = subcmd_entry->subcomtb_routine;
            linkParamsR15.dcbAddress = 0;

            svcParams.SVC = 6;
            svcParams.R0  = 0;     /* no ENVBLOCK: BREXX has no IRXEXCOM (#353) */
            svcParams.R1  = (unsigned int) (uintptr_t) hostenvParamsPtr;
            svcParams.R15 = (unsigned int) (uintptr_t) &linkParamsR15;

            call_rxsvc(&svcParams);

            rc = (int) svcParams.R15;
        }
    }

    return rc;
}
