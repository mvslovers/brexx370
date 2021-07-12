#include <stdio.h>
#include <string.h>
#include "lstring.h"

#include "rexx.h"
#include "rxtcp.h"
#include "jccdummy.h"
#include "util.h"

extern int RxMvsInitialize();
extern void RxMvsTerminate();
extern void RxMvsRegFunctions();
//extern int  isTSO();

void term();

/* --------------------- main ---------------------- */
int __CDECL
main(int argc, char *argv[]) {

    Lstr args[MAXARGS], tracestr, fileName, pgmStr;
    int ii, jj, rc, staeret;
    jmp_buf b;

    bool input = FALSE;

    // STAE stuff
    char systemCompletionCode[3 + 1];
    char userCompletionCode[3 + 1];

    SDWA sdwa;
    // *


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

        RxRun(&fileName, &pgmStr, &args[0], &tracestr);

    } else if (staeret == 1) { // Something was caught - the STAE has been cleaned up.

        bzero(systemCompletionCode, 4);
        bzero(userCompletionCode, 4);

        sprintf(systemCompletionCode, "%02X%1X", sdwa.SDWACMPC[0], (sdwa.SDWACMPC[1] >> 4));
        sprintf(userCompletionCode, "%1X%02X", sdwa.SDWACMPC[1] & 0xF, sdwa.SDWACMPC[2]);

        /*
        USER HERC01    TRANSMIT  ABEND S013
        PSW   075C1000 00E014BE  ILC 02  INTC 000D
        DATA NEAR PSW  00E014B6  16104100 37860A0D 45E0372A 58204238
        GR 0-3   00E01620  A0013000  000B178C  40E00E9A
        GR 4-7   009A8BF8  019A8F2C  009A8EE4  019A8F2C
        GR 8-11  009A8F04  00014008  58003398  009A8A7C
        GR 12-15 0002AEA0  00000052  80E00F8A  00000018
         */
        fprintf(STDERR, "\nBRX0003E - SYSTEM COMPLETION CODE = %s / USER COMPLETION CODE = %s\n", systemCompletionCode,
                userCompletionCode);

        DumpHex((const unsigned char *) &sdwa, 104);

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

void term() {
#ifdef __DEBUG__
    fprintf(STDOUT, "\nBRX0001I - BREXX/370 TERMINATION ROUTINE STARTED\n");
#endif

    setEnvBlock(0);
}
