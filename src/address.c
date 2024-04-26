#include <string.h>
#include <stdlib.h>

#include "lstring.h"
#include "rexx.h"
#include "trace.h"
#include "stack.h"
#include "compile.h"
#include "interpre.h"
#include "hostcmd.h"
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

    LASCIIZ(*cmd);

	if (IsReturnCode((char *) LSTR(*cmd))) {
        return 0x123456;
	}

    if (!findLoadModule((char *)LSTR(*cmd))) {
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
RxExecuteCmd( PLstr cmd, PLstr env )
{
	int	in,out;
	Lstr	cmdN;

	if (isHostCmd(cmd, env)) {
	    rxReturnCode = handleHostCmd(cmd, env);
	} else {

        LINITSTR(cmdN)
        Lfx(&cmdN,1);
        Lstrcpy(&cmdN,cmd);
        L2STR(&cmdN);

        LASCIIZ(cmdN)

        chkcmd4stack(&cmdN,&in,&out);
        rxReturnCode = RxRedirectCmd(&cmdN,in,out,FALSE, env);

        if (rxReturnCode == 0x123456) {
            fprintf(STDERR, "Error: Invalid command name syntax\n");
            rxReturnCode = -3;
        } else if (rxReturnCode == 0x806000) {
            fprintf(STDERR, "Error: Command %s not found\n", LSTR(cmdN));
            rxReturnCode = -3;
        }

        /* free string */
        LFREESTR(cmdN)

        RxSetSpecialVar(RCVAR,rxReturnCode);
        if (rxReturnCode && !(_proc[_rx_proc].trace & off_trace)) {
            if (_proc[_rx_proc].trace & (error_trace | normal_trace)) {
                TraceCurline(NULL,TRUE);
                fprintf(STDERR,"       +++ RC(%d) +++\n",rxReturnCode);
                if (_proc[_rx_proc].interactive_trace)
                    TraceInteractive(FALSE);
            }
            if (_proc[_rx_proc].condition & SC_ERROR)
                RxSignalCondition(SC_ERROR);
        }
	}


	return rxReturnCode;
} /* RxExecuteCmd */
