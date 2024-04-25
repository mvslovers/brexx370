#include <stdio.h>
#include <string.h>
#include "lstring.h"

#include "rexx.h"
#include "rxtcp.h"
#include "smf.h"
#include "util.h"

#ifdef __CROSS__
# include "jccdummy.h"
#else
extern char* _style;
extern void ** entry_R13;
extern int  __libc_tso_status;
extern long __libc_arch;
extern long __libc_heap_used;
extern long __libc_heap_max;
extern long __libc_stack_used;
extern long __libc_stack_max;
#endif

extern int RxMvsInitialize();
extern void RxMvsTerminate();
extern void RxMvsRegFunctions();

/* --------------------- main ---------------------- */
int __CDECL
main(int argc, char *argv[]) {

    Lstr args[MAXARGS], tracestr, fileName, pgmStr;
    int ii, jj, rc, staeret;
    jmp_buf jmpBuf;

    bool input = FALSE;
    bool smfTermWritten = FALSE;

    void **cppl;
    byte *cmdbuf;

    // STAE stuff
    SDWA sdwa;
    bool nostae = FALSE;
    // *

    // TODO: make this configurable
    //__libc_arch = 1;
    
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
            return rc;
        }

        for (ii = 0; ii < MAXARGS; ii++) {
            LINITSTR(args[ii]);
        }

        LINITSTR(tracestr);

        /*
        printf("DEBUG: BREXX got %d arguments\n", argc - 1);

        if (isTSOFG()) {
            printf("DEBUG: BREXX got called from TSO (online) \n");
        } else if (isTSOBG()) {
            printf("DEBUG: BREXX got called from TSO (batch)  \n");
        }

        if (isISPF()) {
            printf("DEBUG: BREXX got called from ISPF\n");
        }

        if (isEXEC()) {
            printf("DEBUG: BREXX got called from CLIST\n");
        }


        cppl = entry_R13[6];
        cmdbuf = cppl[0];

        puts("DEBUG: R1");
        {
            DumpHex((void *)cppl, 4);
        }
        puts("DEBUG: CPPLCBUF");
        {
            //unsigned length = (cmdbuf[0] | cmdbuf[1]); // subtract header length
            //DumpHex(cmdbuf + 4, length);
            DumpHex(cmdbuf, 24);
        }
        */

        if (argc < 2) {
            puts(VERSIONSTR);
            RxMvsTerminate();
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
            if(Lbeg(&fileName, "0X") == 1) {

                char *pgm = (char *) (atoi((const char *)fileName.pstr + 2));
                int pgm_len  = strlen(pgm);

                LINITSTR(pgmStr)

                pgmStr.pstr = pgm;
                pgmStr.len  = pgm_len;

                fileName.pstr = NULL;

                /*
                printf("2) TvB0j3pIB4fNF3epVo1fRS2wGFatkVFcfe5BbPZCwuad0zbopALAmZcvpAy7dvMu44DK1QxkipbdIiXJJCP4iRB64zfrPOtk60modq3oFTrE6ys0KWrH7x3rfXqA7chM\n");
                printf("3) TvB0j3pIB4fNF3epVo1fRS2wGFatkVFcfe5BbPZCwuad0zbopALAmZcvpAy7dvMu44DK1QxkipbdIiXJJCP4iRB64zfrPOtk60modq3oFTrE6ys0KWrH7x3rfXqA7chM1\n");
                printf("5) TvB0j3pIB4fNF3epVo1fRS2wGFatkVFcfe5BbPZCwuad0zbopALAmZcvpAy7dvMu44DK1QxkipbdIiXJJCP4iRB64zfrPOtk60modq3oFTrE6ys0KWrH7x3rfXqA7chM12\n");
                printf("7) TvB0j3pIB4fNF3epVo1fRS2wGFatkVFcfe5BbPZCwuad0zbopALAmZcvpAy7dvMu44DK1QxkipbdIiXJJCP4iRB64zfrPOtk60modq3oFTrE6ys0KWrH7x3rfXqA7chM123\n");
                printf("7) TvB0j3pIB4fNF3epVo1fRS2wGFatkVFcfe5BbPZCwuad0zbopALAmZcvpAy7dvMu44DK1QxkipbdIiXJJCP4iRB64zfrPOtk60modq3oFTrE6ys0KWrH7x3rfXqA7chM1234\n");
                printf("7) TvB0j3pIB4fNF3epVo1fRS2wGFatkVFcfe5BbPZCwuad0zbopALAmZcvpAy7dvMu44DK1QxkipbdIiXJJCP4iRB64zfrPOtk60modq3oFTrE6ys0KWrH7x3rfXqA7chM12345\n");
                printf("7) TvB0j3pIB4fNF3epVo1fRS2wGFatkVFcfe5BbPZCwuad0zbopALAmZcvpAy7dvMu44DK1QxkipbdIiXJJCP4iRB64zfrPOtk60modq3oFTrE6ys0KWrH7x3rfXqA7chM123456\n");
                */
            }


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

        writeStartRecord((char *) LSTR(fileName), (char *) LSTR(args[0]));

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

        fprintf(STDERR, "USER %-8s  %-8s  ABEND %-5s\n", getlogin(), moduleName, completionCode );
        fprintf(STDERR, "EPA %p  PSW %08X %08X  ILC %02X  INTC %04X\n",
                sdwa.sdwaepa, psw1, nxt1, ilc, intc );
        fprintf(STDERR, "GR 0-3   %08X  %08X  %08X  %08X\n", gpr00, gpr01, gpr02, gpr03);
        fprintf(STDERR, "GR 4-7   %08X  %08X  %08X  %08X\n", gpr04, gpr05, gpr06, gpr07);
        fprintf(STDERR, "GR 8-11  %08X  %08X  %08X  %08X\n", gpr08, gpr09, gpr10, gpr11);
        fprintf(STDERR, "GR 12-15 %08X  %08X  %08X  %08X\n", gpr12, gpr13, gpr14, gpr15);

        printf("\n");

        rxReturnCode = 8;

        writeTermRecord(rxReturnCode, completionCode);
        smfTermWritten = TRUE;

        goto TERMINATE;

    } else { // can only be -1 = OS failure
        fprintf(STDERR, "\nBRX0002E - ERROR IN INITIALIZATION OF THE BREXX/370 STAE ROUTINE\n");
    }

    TERMINATE:

    if (smfTermWritten == FALSE) {
        writeTermRecord(rxReturnCode, NULL);
    }

    /* --- Free everything --- */
    RxFinalize();
    RxResetTcpIp();
    RxMvsTerminate();

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
