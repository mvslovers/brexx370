#include <string.h>
#include <stdlib.h>

#include "addrlink.h"
#include "lstring.h"
#include "rexx.h"
#include "trace.h"
#include "stack.h"
#include "rxmvsext.h"

#ifndef WIN
#if defined(MSDOS) || defined(__WIN32__)
#	include <io.h>
#	include <fcntl.h>
#ifndef _MSC_VER
#	include <dir.h>
#endif
#	include <process.h>
#	if defined(__BORLANDC__) && !defined(__WIN32__)
#		include <systemx.h>
#	endif
#elif defined(__MPW__)
#elif defined(_MSC_VER)
#else
#	if !defined(__CMS__) && !defined(__MVS__)
#		include <fcntl.h>
#		include <unistd.h>
#	endif
#endif

#if !defined(__CMS__) && !defined(__MVS__)
#	include <sys/stat.h>
#endif
#include <string.h>
#include "util.h"
#ifndef S_IREAD
#	define S_IREAD 0
#	define S_IWRITE 1
#endif

#define NOSTACK		0
#define FIFO		1
#define LIFO		2
#define STACK		3

#define LOW_STDIN	0
#define LOW_STDOUT	1

extern RX_ENVIRONMENT_BLK_PTR env_block;

int executeCmdInHostEnvironment(PLstr cmd, PLstr env);
int IRXSTAM(RX_ENVIRONMENT_BLK_PTR envblockp, RX_HOSTENV_PARAMS_PTR  pParms);

/* ---------------------- chkcmd4stack ---------------------- */
static void
chkcmd4stack(PLstr cmd, int *in, int *out )
{
	Lstr Ucmd;

	*in = *out = 0;
	if (LLEN(*cmd)<7) return;

	LINITSTR(Ucmd);

	/* Search for string "STACK>" in front of command
	or for strings    "(STACK", "(FIFO", "(LIFO"
	                  ">STACK", ">FIFO", ">LIFO" at the end */

	if (LLEN(*cmd)<=5) return;

	Lstrcpy(&Ucmd,cmd); Lupper(&Ucmd);

	if (!MEMCMP(LSTR(Ucmd),"STACK>",6)) *in=FIFO;
	if (!MEMCMP(LSTR(Ucmd)+LLEN(Ucmd)-5,"STACK",5)) *out = STACK;
	if (!MEMCMP(LSTR(Ucmd)+LLEN(Ucmd)-4,"FIFO",4)) *out = FIFO;
	if (!MEMCMP(LSTR(Ucmd)+LLEN(Ucmd)-4,"LIFO",4)) *out = LIFO;
	if (*out)
		if (LSTR(Ucmd)[LLEN(Ucmd)-((*out==STACK)?6:5)]!='(' &&
		    LSTR(Ucmd)[LLEN(Ucmd)-((*out==STACK)?6:5)]!='>')   *out = 0;
	LFREESTR(Ucmd);

	if (*in) {
		MEMMOVE(LSTR(*cmd),LSTR(*cmd)+6,LLEN(*cmd)-6);
		LLEN(*cmd) -= 6;
	}
	if (*out)
		LLEN(*cmd) -= (*out==STACK)?6:5;

	if (*out==STACK)
		*out = FIFO;
} /* chkcmd4stack */

/* ------------------ RxRedirectCmd ----------------- */
int __CDECL
RxRedirectCmd(PLstr cmd, int in, int out, PLstr outputstr, PLstr env)
{
	char fnin[45], fnout[45];
	int	old_stdin=0, old_stdout=0;
	int	filein, fileout;
	FILE	*f;
	PLstr	str;

	char moduleName[8 + 1];

    LASCIIZ(*cmd);

	if (IsReturnCode((char *) LSTR(*cmd))) {
        return 0x123456;
	}

	bzero(moduleName, 9);
	strncpy(moduleName, (char *) LSTR(*cmd), 8);
	strtok(moduleName, " (),");
	if (!findLoadModule(moduleName)) {
        return 0x806000;
    }

	/* --- redirect input --- */
	if (in) {
		// mkfntemp(fnin,sizeof(fnin));  // make filename
		if ((f=fopen(fnin,"w"))!=NULL) {
			while (StackQueued()>0) {
				str = PullFromStack();
				L2STR(str); LASCIIZ(*str)
				fputs(LSTR(*str),f); fputc('\n',f);
				LPFREE(str)
			}
			fclose(f);

			old_stdin = dup(LOW_STDIN);
			filein = open(fnin,S_IREAD);
			dup2(filein,LOW_STDIN);
			close(filein);
			fdopen(0,"rt");
		} else
			in = FALSE;
	}

	/* --- redirect output --- */
	if (out) {
		old_stdout = dup(LOW_STDOUT);
		strcpy(fnout, "//MEM:OUT");
		fileout = open(fnout, O_CREAT);
		dup2(fileout,LOW_STDOUT);
		close(fileout);
		fdopen(1,"at");
	}

	/* --- Execute the command --- */
	if (env != NULL && strcmp(LSTR(*env) , "TSO") == 0) {
#ifdef __MVS__
		rxReturnCode = systemTSO(LSTR(*cmd));
#endif
	} else {
		rxReturnCode = system(LSTR(*cmd));
	}

	/* --- restore input --- */
	if (in) {
		close(LOW_STDIN);
		dup2(old_stdin,LOW_STDIN);
		close(old_stdin);
		remove(fnin);

		fdopen(0,"rt");
	}

	/* --- restore output --- */
	if (out) {
		close(LOW_STDOUT);
		dup2(old_stdout,LOW_STDOUT);  /* restore stdout */
		close(old_stdout);

		fdopen(1,"at");

		if ((f=fopen(fnout,"r"))!=NULL) {
			if (outputstr) {
				Lread(f,outputstr,LREADFILE);
#ifdef RMLAST
				if (LSTR(*outputstr)[LLEN(*outputstr)-1]=='\n')
					LLEN(*outputstr)--;
#endif
			} else	/* push it to stack */
				while (!feof(f)) {
					LPMALLOC(str);
					Lread(f,str,LREADLINE);
					if (LLEN(*str)==0 && feof(f)) {
						LPFREE(str);
						break;
					}
					if (out==FIFO) {
						Queue2Stack(str);
					}
					else {
						Push2Stack(str);
					}
				}

			fclose(f);
			remove(fnout);
		}
	}

	return rxReturnCode;
} /* RxRedirectCmd */
#endif

/* ------------------ RxExecuteCmd ----------------- */
int __CDECL
RxExecuteCmd(PLstr cmd, PLstr env)
{
	int	in,out;
	Lstr	cmdN;

	rxReturnCode = 0;

	LASCIIZ(*cmd)
    if (IsReturnCode((char *) LSTR(*cmd))) {
        rxReturnCode =  0x123456;
    }

    if (rxReturnCode == 0) {
        rxReturnCode = executeCmdInHostEnvironment(cmd, env);
    }

	if (rxReturnCode == -1) {
	    // TODO: move implementation to irxstam
        if (strcasecmp((const char *)LSTR(*env), "LINK")    == 0 ||
            strcasecmp((const char *)LSTR(*env), "LINKMVS") == 0 ||
            strcasecmp((const char *)LSTR(*env), "LINKEXT") == 0 ||
            strcasecmp((const char *)LSTR(*env), "LINKPGM") == 0) {

            rxReturnCode = handleLinkCommands(cmd, env);
        } else {
            printf("ERROR> please repost this to MIG\n");
        }
	}

    if (rxReturnCode == 0x123456) {
        fprintf(STDERR, "Error: Invalid command name syntax\n");
        rxReturnCode = -3;
    } else if (rxReturnCode == 0x806000) {
        fprintf(STDERR, "Error: Command %s not found\n", LSTR(cmdN));
        rxReturnCode = -3;
    }

    RxSetSpecialVar(RCVAR,rxReturnCode);
    if (rxReturnCode && !(_proc[_rx_proc].trace & off_trace)) {
        if (_proc[_rx_proc].trace & (error_trace)) {
            TraceCurline(NULL,TRUE);
            fprintf(STDERR,"       +++ RC(%d) +++\n",rxReturnCode);
            if (_proc[_rx_proc].interactive_trace)
                TraceInteractive(FALSE);
        } else if ((_proc[_rx_proc].trace & normal_trace) && rxReturnCode < 0) {
            TraceCurline(NULL,TRUE);
            fprintf(STDERR,"       +++ RC(%d) +++\n",rxReturnCode);
            if (_proc[_rx_proc].interactive_trace)
                TraceInteractive(FALSE);
        }
        if (_proc[_rx_proc].condition & SC_ERROR)
            RxSignalCondition(SC_ERROR);
    }

	return rxReturnCode;
} /* RxExecuteCmd */

int
executeCmdInHostEnvironment(PLstr cmd, PLstr env) {
    int rc = 0;

    int ii;

    char environmentName[8];
    char *commandString;
    int commandLength;

    RX_PARM_BLK_PTR        parm_block;
    RX_SUBCMD_TABLE_PTR    subcmd_table;
    RX_SUBCMD_ENTRY_PTR    subcmd_entry;
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

    for (ii = 0; ii < subcmd_table->subcomtb_used; ii++) {
        subcmd_entry = &subcmd_entries[ii];
        if (memcmp(environmentName, subcmd_entry->subcomtb_name, sizeof(subcmd_entry->subcomtb_name)) == 0 ) {
            rc = 0;
            break;
        } else {

            // TODO: must be -3, later
            rc = -1;
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
            svcParams.R0  = (unsigned int) (uintptr_t) getEnvBlock();
            svcParams.R1  = (unsigned int) (uintptr_t) hostenvParamsPtr;
            svcParams.R15 = (unsigned int) (uintptr_t) &linkParamsR15;

            call_rxsvc(&svcParams);

            rc = (int) svcParams.R15;
        }
    }

    return rc;
}
