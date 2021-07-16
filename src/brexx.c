#include <stdio.h>
#include <string.h>
#include "lstring.h"

#include "rexx.h"
#include "rxtcp.h"
#include "smf.h"
#include "util.h"

#if defined(__CROSS__)
# include "jccdummy.h"
#endif

extern int RxMvsInitialize();
extern void RxMvsTerminate();
extern void RxMvsRegFunctions();
//extern int  isTSO();

int genRunId();
void term();

/* --------------------- main ---------------------- */
int __CDECL
main(int argc, char *argv[]) {

    Lstr args[MAXARGS], tracestr, fileName, pgmStr;
    int ii, jj, rc, staeret;
    jmp_buf b;

    bool input = FALSE;
    int runId;

    // STAE stuff
    SDWA sdwa;
    // *

    // generate run id, used as kind of session identification for SMF
    runId = genRunId();

    // register termination routine
    atexit(term);

    // register abend recovery routine
    if (strcasecmp(argv[argc - 1], "NOSTAE") == 0) {
        staeret = 0;
        argc--;
    } else {
        staeret = _setjmp_stae(b, (char *) &sdwa); // We don't want 104 bytes of abend data
    }

    if (staeret == 0) {
        rc = RxMvsInitialize();
        if (rc != 0) {
            printf("\nBRX0001E - ERROR IN INITIALIZATION OF THE BREXX/370 ENVIRONMENT: %d\n", rc);
            return rc;
        }

        for (ii = 0; ii < MAXARGS; ii++) {
            LINITSTR(args[ii]);
        }

        LINITSTR(tracestr);

        if (argc < 2) {
            puts(VERSIONSTR);

            return 0;
        }

#ifdef __DEBUG__
        __debug__ = FALSE;
#endif

        RxInitialize(argv[0]);

        /* register mvs specific functions */
        RxMvsRegFunctions();

        /* scan arguments --- */
        ii = 1;
        if (argv[ii][0] == '-') {
            if (argv[ii][1] == 0) {
                input = TRUE;
            } else {
                Lscpy(&tracestr, argv[ii] + 1);
            }

            ii++;
        } else if (argv[ii][0] == '?' || argv[ii][0] == '!') {
            Lscpy(&tracestr, argv[ii]);
            ii++;
        }

        /* read exec from dataset */
        if (!input && ii < argc) {
            //LFREESTR(pgmStr)
            pgmStr.pstr = NULL;
            LINITSTR(fileName)

            /* prepare arguments for program */
            for (jj = ii + 1; jj < argc; jj++) {
                Lcat(&args[0], argv[jj]);
                if (jj < argc - 1) {
                    Lcat(&args[0], " ");
                }
            }

        Lcat(&fileName, argv[ii]);

        } else {
            //LFREESTR(fileName)
            fileName.pstr = NULL;
            LINITSTR(pgmStr)

            if (ii >= argc) {
                Lread(STDIN, &pgmStr, LREADFILE);
            } else {
                for (; ii < argc; ii++) {
                    Lcat(&pgmStr, argv[ii]);
                    if (ii < argc-1) Lcat(&pgmStr," ");
                }
            }
        }

        RxRun(&fileName, &pgmStr, &args[0], &tracestr, runId);

    } else if (staeret == 1) { // Something was caught - the STAE has been cleaned up.

        unsigned short scc;
        unsigned short ucc;

        char completionCode[5 + 1];
        memset(completionCode, ' ', 5 + 1);

        scc = (* (short *) &sdwa.SDWACMPC[0]) >> 4;
        ucc = (* (short *) &sdwa.SDWACMPC[1]) & 0xFFF;

        if(scc > 0) {
            sprintf(completionCode, "S%03X", scc);
        } else if (ucc > 0){
            sprintf(completionCode, "U%04d", ucc);
        } else {
            sprintf(completionCode, "?????");
        }

        //TODO: SMF field for abend code must be increased to 5
        fprintf(STDERR, "\nBRX0003E - ABEND CAUGHT IN BREXX/370 \n\n");
        fprintf(STDERR, "USER %-8s  %-8s  ABEND %-5s\n", getlogin(), "BRX", completionCode );
        fprintf(STDERR, "PSW   %08X %08X  ILC %02d  INTC %04X\n", 0, 0, 2, 12);
        fprintf(STDERR, "DATA NEAR PSW  %08X  %08X %08X %08X %08X\n", 0, 0, 0, 0, 0);
        fprintf(STDERR, "GR 0-3   00E01620  A0013000  000B178C  40E00E9A\n", 0, 0, 0, 0, 0);
        fprintf(STDERR, "GR 4-7   009A8BF8  019A8F2C  009A8EE4  019A8F2C\n", 0, 0, 0, 0, 0);
        fprintf(STDERR, "GR 8-11  009A8F04  00014008  58003398  009A8A7C\n", 0, 0, 0, 0, 0);
        fprintf(STDERR, "GR 12-15 0002AEA0  00000052  80E00F8A  00000018\n\n", 0, 0, 0, 0, 0);

        /*
        USER HERC01    TRANSMIT  ABEND S013
        PSW   075C1000 00E014BE  ILC 02  INTC 000D
        DATA NEAR PSW  00E014B6  16104100 37860A0D 45E0372A 58204238
        GR 0-3   00E01620  A0013000  000B178C  40E00E9A
        GR 4-7   009A8BF8  019A8F2C  009A8EE4  019A8F2C
        GR 8-11  009A8F04  00014008  58003398  009A8A7C
        GR 12-15 0002AEA0  00000052  80E00F8A  00000018
         */

        fprintf(STDERR, "DUMPING THE SDWA\n");
        DumpHex((const unsigned char *) &sdwa, 104);

        write242Record(runId, &fileName, SMF_ABEND, 0, completionCode);

        rxReturnCode = 8;

        goto TERMINATE;

    } else { // can only be -1 = OS failure
        fprintf(STDERR, "\nBRX0002E - ERROR IN INITIALIZATION OF THE BREXX/370 STAE ROUTINE\n");
    }

    TERMINATE:

    /* --- Free everything --- */
    RxFinalize();
    RxResetTcpIp();
    RxMvsTerminate();
    // TODO: call brxterm

    for (ii = 0; ii < MAXARGS; ii++) {
        LFREESTR(args[ii]);
    }

    LFREESTR(tracestr);
    LFREESTR(fileName);
    LFREESTR(pgmStr);

#ifdef __DEBUG__
    if (mem_allocated() != 0) {
        fprintf(STDERR, "\nMemory left allocated: %ld\n", mem_allocated());
        mem_list();
    }
#endif

    return rxReturnCode;
} /* main */

int genRunId()
{
    srand((unsigned) time((time_t *)0)%(3600*24));
    return rand() % 9999;
}

void term() {
#ifdef __DEBUG__
    fprintf(STDOUT, "\nBRX0001I - BREXX/370 TERMINATION ROUTINE STARTED\n");
#endif

    setEnvBlock(0);
}
