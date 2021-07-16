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

        uint16_t scc;
        uint16_t ucc;

        uint8_t  ilc;
        uint16_t intc;

        int gpr00;
        int gpr01;
        int gpr02;
        int gpr03;
        int gpr04;
        int gpr05;
        int gpr06;
        int gpr07;
        int gpr08;
        int gpr09;
        int gpr10;
        int gpr11;
        int gpr12;
        int gpr13;
        int gpr14;
        int gpr15;

        char *moduleName;

        char completionCode[5 + 1];
        memset(completionCode, ' ', 5 + 1);

        // extract completion code
        scc = (* (uint16_t *) &sdwa.sdwacmpc[0]) >> 4;
        ucc = (* (uint16_t *) &sdwa.sdwacmpc[1]) & 0xFFF;

        if(scc > 0) {
            sprintf(completionCode, "S%03X", scc);
        } else if (ucc > 0){
            sprintf(completionCode, "U%04d", ucc);
        } else {
            sprintf(completionCode, "?????");
        }

        // extract instruction length code
        ilc = (sdwa.sdwapmka >> 1) & 0x3;

        // extract interruption  code
        intc = * (uint16_t *) &sdwa.sdwainta[0];

        // extract general purpose registers
        gpr00 = sdwa.sdwagr00;
        gpr01 = sdwa.sdwagr01;
        gpr02 = sdwa.sdwagr02;
        gpr03 = sdwa.sdwagr03;
        gpr04 = sdwa.sdwagr04;
        gpr05 = sdwa.sdwagr05;
        gpr06 = sdwa.sdwagr06;
        gpr07 = sdwa.sdwagr07;
        gpr08 = sdwa.sdwagr08;
        gpr09 = sdwa.sdwagr09;
        gpr10 = sdwa.sdwagr10;
        gpr11 = sdwa.sdwagr11;
        gpr12 = sdwa.sdwagr12;
        gpr13 = sdwa.sdwagr13;
        gpr14 = sdwa.sdwagr14;
        gpr15 = sdwa.sdwagr15;

        // extract module name
        moduleName = (char *) &sdwa.sdwaname;

        fprintf(STDERR, "\nBRX0003E - ABEND CAUGHT IN BREXX/370 - SDWA(%lu)\n\n", sizeof(SDWA));

        fprintf(STDERR, "USER %-8s  %-8s  ABEND %-5s\n", getlogin(), moduleName, completionCode );
        fprintf(STDERR, "EPA %p PSW   %08X %08X  ILC %02X  INTC %04d\n", sdwa.sdwaepa, 0, 0, ilc, intc );
        fprintf(STDERR, "DATA NEAR PSW  %08X  %08X %08X %08X %08X\n", 0, 0, 0, 0, 0);
        fprintf(STDERR, "GR 0-3   %08X  %08X  %08X  %08X\n", gpr00, gpr01, gpr02, gpr03);
        fprintf(STDERR, "GR 4-7   %08X  %08X  %08X  %08X\n", gpr04, gpr05, gpr06, gpr07);
        fprintf(STDERR, "GR 8-11  %08X  %08X  %08X  %08X\n", gpr08, gpr09, gpr10, gpr11);
        fprintf(STDERR, "GR 12-15 %08X  %08X  %08X  %08X\n", gpr12, gpr13, gpr14, gpr15);
        /*
        USER HERC01    TRANSMIT  ABEND S013
        PSW   075C1000 00E014BE  ILC 02  INTC 000D
        DATA NEAR PSW  00E014B6  16104100 37860A0D 45E0372A 58204238
        GR 0-3   00E01620  A0013000  000B178C  40E00E9A
        GR 4-7   009A8BF8  019A8F2C  009A8EE4  019A8F2C
        GR 8-11  009A8F04  00014008  58003398  009A8A7C
        GR 12-15 0002AEA0  00000052  80E00F8A  00000018
         */

        printf("\n");

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
