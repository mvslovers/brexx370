//RXPI JOB 'RXPI','COMPILE',                                            00000100
//      CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),                              00000200
//      REGION=256K,TIME=(1,0),PRTY=8,NOTIFY=&SYSUID                    00000300
//CLG EXEC PL1LFCL,                                                     00000400
//      PARM.PL1L='MACRO,LOAD,NODECK,OPT=2',                            00000500
//      PARM.LKED='MAP,LIST'                                            00000600
//PL1L.SYSLIN  DD UNIT=SYSDA                                            00000700
//* PL1L.SYSLIB  DD DISP=SHR,DSN=BREXX.PL1.SRC                          00000800
//PL1L.SYSLIB  DD DUMMY                                                 00000900
//PL1L.SYSIN   DD *                                                     00001000
 RXPI:   PROCEDURE(EFPLCOM, EFPLBARG, EFPLEARG, EFPLFB,                 00001100
                   EFPLARG, EFPLEVAL) OPTIONS(MAIN);                    00001200
 /* --------------------------------------------------------------------00001300
  * RXCOMM FOR ENTRY IHESAPB (OPT=0) OR IHESAPD (OPT=1, 2)              00001400
  * THE PROGRAM IS LINKED WITH  ENTRY IHESAPD  (OR IHESAPB FOR OPT=0),  00001500
  * SO REGISTER 1 REACHES THE MAIN PROCEDURE UNCHANGED: THE EFPL OF     00001600
  * TSO/E REXX AND BREXX/370 IS ITS PARAMETER LIST.  THE PROCEDURE      00001700
  * STATEMENT NAMES THE SIX EFPL WORDS:                                 00001800
  *   NAME: PROCEDURE(EFPLCOM,EFPLBARG,EFPLEARG,EFPLFB,EFPLARG,EFPLEVAL)00001900
  *         OPTIONS(MAIN);                                              00002000
  * EFPLCOM .. EFPLFB ARE RESERVED AND NEVER TOUCHED.                   00002100
  * ADDR(EFPLARG) IS THE ARGUMENT TABLE, EFPLEVAL THE EVALUATION BLOCK. 00002200
  * --------------------------------------------------------------------00002300
  */                                                                    00002400
   DCL (EFPLCOM, EFPLBARG, EFPLEARG, EFPLFB) PTR;                       00002500
   DCL EFPLARG  PTR;                                                    00002600
   DCL EFPLEVAL PTR;                                                    00002700
 /* --------------------------------------------------------------------00002800
  * ARGTABLE ENTRIES AND RELATED DEFINITIONS                            00002900
  * --------------------------------------------------------------------00003000
  */                                                                    00003100
   DCL EFPLARG_PTR      PTR;                                            00003200
   EFPLARG_PTR        = ADDR(EFPLARG);                                  00003300
   DCL 1 ARGTABLE BASED(EFPLARG_PTR),                                   00003400
         2 ARGTABLE_ENTRY(15),                                          00003500
           3 ARGSTRING_PTR    PTR,                                      00003600
           3 ARGSTRING_LENGTH FIXED BIN(31);                            00003700
                                                                        00003800
   DCL ARGNUM      BIN FIXED(31);                                       00003900
   DCL ARG_LEN(15) BIN FIXED(31);                                       00004000
   DCL ARG(15)     CHAR(255) VARYING;                                   00004100
                                                                        00004200
   DCL ARG_PTR PTR;                                                     00004300
   DCL ARGSTRING CHAR(255) BASED(ARG_PTR);                              00004400
 /* --------------------------------------------------------------------00004500
  * EVALUATION BLOCK: EVALBLOCK                                         00004600
  * --------------------------------------------------------------------00004700
  */                                                                    00004800
   DCL EFPLEVAL_PTR     PTR;                                            00004900
   EFPLEVAL_PTR = EFPLEVAL;                                             00005000
                                                                        00005100
   DCL 1 EVALBLOCK BASED(EFPLEVAL_PTR),                                 00005200
         2 EVALBLOCK_EVPAD1 FIXED BIN(31),                              00005300
         2 EVALBLOCK_EVSIZE FIXED BIN(31),                              00005400
         2 EVALBLOCK_EVLEN  FIXED BIN(31),                              00005500
         2 EVALBLOCK_EVPAD2 FIXED BIN(31),                              00005600
         2 EVALBLOCK_EVDATA CHAR(256);                                  00005700
                                                                        00005800
   DCL EVDATA_PTR PTR;                                                  00005900
   DCL EVDATLN_PTR PTR;                                                 00006000
                                                                        00006100
   EVDATA_PTR = ADDR(EVALBLOCK_EVDATA);                                 00006200
   EVDATLN_PTR = ADDR(EVALBLOCK_EVLEN);                                 00006300
                                                                        00006400
   DCL RESULT CHAR(1024) BASED (EVDATA_PTR);                            00006500
   DCL RESULT_LEN    BIN FIXED(31) BASED(EVDATLN_PTR);                  00006600
                                                                        00006700
   RESULT_LEN = 1;                                                      00006800
 /* --------------------------------------------------------------------00006900
  * COPY BREXX PARMS INTO PL1 STRUCTURE                                 00007000
  * --------------------------------------------------------------------00007100
  */                                                                    00007200
   DCL AI BIN FIXED(31);                                                00007300
                                                                        00007400
   DO AI=1 TO 15 ;                                                      00007500
      ARG_PTR = ARGSTRING_PTR(AI);                                      00007600
      ARG_LEN(AI) = ARGSTRING_LENGTH(AI);                               00007700
      IF ARG_LEN(AI)<=0 THEN ARG(AI)='';                                00007800
      ELSE DO;                                                          00007900
         ARG(AI) = SUBSTR(ARGSTRING,1,ARG_LEN(AI));                     00008000
         ARGNUM=AI;                                                     00008100
      END;                                                              00008200
   END;                                                                 00008300
 /* --------------------------------------------------------------------00008400
  * THIS IS THE END OF THE %INCLUDE MODULE                              00008500
  * --------------------------------------------------------------------00008600
  */                                                                    00008700
                                                                        00008800
 /* --------------------------------------------------------------------00008900
  * CALCULATE PI USING THE ALGORITHM OF S. RABINOWICZ AND S. WAGON      00009000
  * CALL FUNCTION IN A REXX SCRIPT WITH PI=RXPI OR SAY RXPI()           00009100
  * --------------------------------------------------------------------00009200
  */                                                                    00009300
 /* --------------------------------------------------------------------00009400
  * INPUT VARIABLES                                                     00009500
  *   ARGNUM      CONTAINS NUMBER OF PROVIDED ARGUMENTS (MAX 15)        00009600
  *   ARG(I)      CONTAINS CONTENTS OF ARGUMENT I (1 TO 15)             00009700
  *   ARG_LEN(I)  CONTAINS LENGTH   OF ARGUMENT I (1 TO 15)             00009800
  * RETURN VARIABLES                                                    00009900
  *   RESULT      CONTAINS RESULT TO BE RETURNED TO BREXX               00010000
  *               THE RETURN VALUE MUST NOT EXCEED 1024 BYTES           00010100
  *   RESULT_LEN  CONTAINS LENGTH OF RETURNED STRING                    00010200
  * --------------------------------------------------------------------00010300
  */                                                                    00010400
  DCL (N, LEN) FIXED BINARY;                                            00010500
  DCL PI CHAR(512) VARYING;                                             00010600
  DCL TEMPI CHAR(9);                                                    00010700
  DCL PREDIGIT BIN FIXED(15);                                           00010800
  N = 500;                                                              00010900
  LEN = 10*N / 3;                                                       00011000
  PI='';                                                                00011100
 BEGIN;                                                                 00011200
  DECLARE ( I, J, K, Q, NINES) BIN FIXED(15);                           00011300
  DECLARE X FIXED BINARY (31);                                          00011400
  DECLARE A(LEN) FIXED BINARY (31);                                     00011500
                                                                        00011600
  A = 2; /* START WITH 2S */                                            00011700
  NINES, PREDIGIT =0; /* FIRST PREDIGIT IS A 0 */                       00011800
  DO J = 1 TO N;                                                        00011900
     Q = 0;                                                             00012000
     DO I = LEN TO 1 BY -1; /* WORK BACKWARDS */                        00012100
        X = 10*A(I) + Q*I;                                              00012200
        A(I) = MOD (X, (2*I-1));                                        00012300
        Q = X / (2*I-1);                                                00012400
     END;                                                               00012500
     A(1) = MOD(Q, 10); Q = Q / 10;                                     00012600
     IF Q = 9 THEN NINES = NINES + 1;                                   00012700
     ELSE IF Q = 10 THEN DO;                                            00012800
        TEMPI=PREDIGIT+1;                                               00012900
        PI=PI||SUBSTR(TEMPI,9,1);                                       00013000
        DO K = 1 TO NINES;                                              00013100
           PI=PI||'0';                                                  00013200
        END;                                                            00013300
        PREDIGIT=0;                                                     00013400
        NINES = 0;                                                      00013500
     END;                                                               00013600
     ELSE DO;                                                           00013700
        TEMPI=PREDIGIT;                                                 00013800
        PI=PI||SUBSTR(TEMPI,9,1);                                       00013900
        PREDIGIT = Q;                                                   00014000
        DO K = 1 TO NINES;                                              00014100
           PI=PI||'9';                                                  00014200
        END;                                                            00014300
        NINES = 0;                                                      00014400
     END;                                                               00014500
   END;                                                                 00014600
 END ; /* END BEGIN */                                                  00014700
   TEMPI=PREDIGIT;                                                      00014800
   PI=PI||SUBSTR(TEMPI,9,1);                                            00014900
 RESULT='3.'||SUBSTR(PI,3);                                             00015000
 RESULT_LEN=LENGTH(PI);                                                 00015100
 END RXPI;                                                              00015200
/*                                                                      00015300
//LKED.SYSLIB  DD DISP=SHR,DSN=SYS1.PL1LIB                              00015400
//LKED.SYSLMOD DD DISP=SHR,DSN=SYS2.LINKLIB(RXPI)                       00015500
//* ENTRY IHESAPD: REGISTER 1 REACHES THE MAIN PROCEDURE UNCHANGED,     00015600
//* SO THE EFPL OF BREXX/370 IS ITS PARAMETER LIST (SEE RXCOMM)         00015700
//LKED.SYSIN  DD *                                                      00015800
 ENTRY IHESAPD                                                          00015900
/*                                                                      00016000
//                                                                      00016100
