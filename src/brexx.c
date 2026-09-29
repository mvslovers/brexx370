#include <stdio.h>
#include <string.h>
#include "lstring.h"

#include "rexx.h"
#include "rxtcp.h"
#include "util.h"

#ifdef __CROSS__
# include "jccdummy.h"
#endif

extern int RxMvsInitialize();
extern void RxMvsTerminate();
extern void RxMvsRegFunctions();

/*
 * main() runs under an ESTAE (asm/rxestae.asm). After an abend it returns
 * through RXSETJMP a second time, like longjmp(), so what the cleanup at the
 * end reads is kept static rather than in registers or stack slots. BREXX is
 * serially reusable: main() resets all of it on every entry.
 */
static Lstr args[MAXARGS], tracestr, fileName, pgmStr;

// how far the initialisation got; the cleanup undoes only that much
static enum { STAGE_NONE, STAGE_MVS, STAGE_REXX } stage;

/* --------------------- main ---------------------- */
int __CDECL
main(int argc, char *argv[]) {

    int ii, jj, rc, staeret;
    jmp_buf jmpBuf;

    bool input = FALSE;

    // STAE stuff
    SDWA sdwa;
    bool nostae = FALSE;

    for (ii = 0; ii < MAXARGS; ii++) {
        LINITSTR(args[ii]);
    }

    LINITSTR(tracestr);
    LINITSTR(fileName);
    LINITSTR(pgmStr);

    stage = STAGE_NONE;

    // register abend recovery routine
    if (strcasecmp(argv[argc - 1], "NOSTAE") == 0) {
        staeret = 0;
        nostae = TRUE;
        argc--;
    } else {
        staeret = _setjmp_estae(jmpBuf, (char *) &sdwa);
    }

    if (staeret == 0) {
        rc = RxMvsInitialize();
        if (rc != 0) {
            printf("\nBRX0001E - ERROR IN INITIALIZATION OF THE BREXX/370 ENVIRONMENT: %d\n", rc);
            if (!nostae) {
                _setjmp_ecanc();
            }
            return rc;
        }
        stage = STAGE_MVS;

        if (argc < 2) {
            puts(VERSIONSTR);
            if (!nostae) {
                _setjmp_ecanc();
            }
            RxMvsTerminate();
            return 0;
        }

#ifdef __DEBUG__
        __debug__ = FALSE;
#endif

        RxInitialize(argv[0]);
        stage = STAGE_REXX;

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

        if (!input && ii < argc) {
            /* read exec from dataset, the rest are its arguments */
            for (jj = ii + 1; jj < argc; jj++) {
                Lcat(&args[0], argv[jj]);
                if (jj < argc - 1) {
                    Lcat(&args[0], " ");
                }
            }

            Lcat(&fileName, argv[ii]);
        } else if (ii >= argc) {
            Lread(STDIN, &pgmStr, LREADFILE);
        } else {
            for (; ii < argc; ii++) {
                Lcat(&pgmStr, argv[ii]);
                if (ii < argc-1) Lcat(&pgmStr," ");
            }
        }

        RxRun(&fileName, &pgmStr, &args[0], &tracestr);

        if (!nostae) {
            rc = _setjmp_ecanc();
            if (rc > 0) {
                fprintf(STDERR, "ERROR: BREXX ESTAE routine ended with RC(%d)\n", rc);
            }
        }

    } else if (staeret == 1) { // Something was caught - the STAE has been cleaned up.

        // condition codes
        uint16_t scc;
        uint16_t ucc;

        // program status word
        int psw1;
        int nxt1;

        // instruction length code
        uint8_t  ilc;

        // interruption code
        uint16_t intc;

        // general purpose register
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
        char *user;

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

        // extract the psw
        psw1 = sdwa.sdwapsw1;
        nxt1 = sdwa.sdwanxt1;

        // extract instruction length code
        ilc = sdwa.sdwailc1;

        // extract interruption  code
        intc = sdwa.sdwaicd1;

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

        fprintf(STDERR, "\nBRX0003E - ABEND CAUGHT IN BREXX/370 \n\n");

        user = getlogin();
        if (user == NULL) {
            user = "";
        }

        fprintf(STDERR, "USER %-8s  %-8s  ABEND %-5s\n", user, moduleName, completionCode );
        fprintf(STDERR, "EPA %p  PSW %08X %08X  ILC %02X  INTC %04X\n",
                sdwa.sdwaepa, psw1, nxt1, ilc, intc );
        fprintf(STDERR, "GR 0-3   %08X  %08X  %08X  %08X\n", gpr00, gpr01, gpr02, gpr03);
        fprintf(STDERR, "GR 4-7   %08X  %08X  %08X  %08X\n", gpr04, gpr05, gpr06, gpr07);
        fprintf(STDERR, "GR 8-11  %08X  %08X  %08X  %08X\n", gpr08, gpr09, gpr10, gpr11);
        fprintf(STDERR, "GR 12-15 %08X  %08X  %08X  %08X\n", gpr12, gpr13, gpr14, gpr15);

        printf("\n");

        rxReturnCode = 8;

    } else { // can only be -1 = OS failure
        fprintf(STDERR, "\nBRX0002E - ERROR IN INITIALIZATION OF THE BREXX/370 STAE ROUTINE\n");
        rxReturnCode = 8;
    }

    /* --- Free everything --- */
    if (stage >= STAGE_REXX) {
        RxFinalize();
    }
    RxResetTcpIp();
    if (stage >= STAGE_MVS) {
        RxMvsTerminate();
    }

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
