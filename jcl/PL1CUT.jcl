//RXPI JOB 'RXPI','COMPILE',                                            00000100
//      CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),                              00000200
//      REGION=256K,TIME=(1,0),PRTY=8,NOTIFY=&SYSUID                    00000300
//CLG EXEC PL1LFCL,                                                     00000400
//      PARM.PL1L='MACRO,LOAD,NODECK,OPT=2',                            00000500
//      PARM.LKED='MAP,LIST'                                            00000600
//PL1L.SYSLIN  DD UNIT=SYSDA                                            00000700
//* PL1L.SYSLIB  DD DISP=SHR,DSN=BREXX.PL1.SRC                          00000801
//PL1L.SYSLIB  DD DUMMY                                                 00000900
//PL1L.SYSIN   DD *                                                     00001000
 RXCUT:   PROCEDURE(EFPL_PTR) OPTIONS(MAIN);                            00001100
 /* --------------------------------------------------------------------00001200
  * THIS INCLUDE MODULE CAN BE MOVED TO A LIBRARY, RECFM=F REQUIRED AND 00001300
  *                                                                     00001400
  * INCLUDED WITH  %INCLUDE RXCOMM;                                     00001500
  * --------------------------------------------------------------------00001600
  */                                                                    00001700
 /* --------------------------------------------------------------------00001800
  * REXX INTERFACE BLOCK  EFPL                                          00001900
  * --------------------------------------------------------------------00002000
  */                                                                    00002100
   DCL EFPL_PTR PTR;                                                    00002200
   DCL 1 EFPL BASED(EFPL_PTR),                                          00002300
         2 EFPLCOM  FIXED BIN(31),                                      00002400
         2 EFPLBARG FIXED BIN(31),                                      00002500
         2 EFPLEARG FIXED BIN(31),                                      00002600
         2 EFPLFB   FIXED BIN(31),                                      00002700
         2 EFPLARG  PTR,                                                00002800
         2 EFPLEVAL PTR;                                                00002900
 /* --------------------------------------------------------------------00003000
  * ARGTABLE ENTRIES AND RELATED DEFINITIONS                            00003100
  * --------------------------------------------------------------------00003200
  */                                                                    00003300
   DCL EFPLARG_PTR      PTR;                                            00003400
   EFPLARG_PTR        = EFPLARG;                                        00003500
   DCL 1 ARGTABLE BASED(EFPLARG_PTR),                                   00003600
         2 ARGTABLE_ENTRY(15),                                          00003700
           3 ARGSTRING_PTR    PTR,                                      00003800
           3 ARGSTRING_LENGTH FIXED BIN(31);                            00003900
                                                                        00004000
   DCL ARGNUM      BIN FIXED(31);                                       00004100
   DCL ARG_LEN(15) BIN FIXED(31);                                       00004200
   DCL ARG(15)     CHAR(255) VARYING;                                   00004300
                                                                        00004400
   DCL ARG_PTR PTR;                                                     00004500
   DCL ARGSTRING CHAR(255) BASED(ARG_PTR);                              00004600
 /* --------------------------------------------------------------------00004700
  * EVALUATION BLOCK: EVALBLOCK                                         00004800
  * --------------------------------------------------------------------00004900
  */                                                                    00005000
   DCL EFPLEVAL_ADR_PTR PTR;                                            00005100
   DCL EFPLEVAL_PTR     PTR;                                            00005200
   EFPLEVAL_ADR_PTR     = EFPLEVAL;                                     00005300
                                                                        00005400
   DCL 1 EVALBLOCK_ADR BASED(EFPLEVAL_ADR_PTR),                         00005500
         2 EFPLEVAL_ADR PTR;                                            00005600
                                                                        00005700
   EFPLEVAL_PTR = EFPLEVAL_ADR;                                         00005800
                                                                        00005900
   DCL 1 EVALBLOCK BASED(EFPLEVAL_PTR),                                 00006000
         2 EVALBLOCK_EVPAD1 FIXED BIN(31),                              00006100
         2 EVALBLOCK_EVSIZE FIXED BIN(31),                              00006200
         2 EVALBLOCK_EVLEN  FIXED BIN(31),                              00006300
         2 EVALBLOCK_EVPAD2 FIXED BIN(31),                              00006400
         2 EVALBLOCK_EVDATA CHAR(256);                                  00006500
                                                                        00006600
   DCL EVDATA_PTR PTR;                                                  00006700
   DCL EVDATLN_PTR PTR;                                                 00006800
                                                                        00006900
   EVDATA_PTR = ADDR(EVALBLOCK_EVDATA);                                 00007000
   EVDATLN_PTR = ADDR(EVALBLOCK_EVLEN);                                 00007100
                                                                        00007200
   DCL RESULT CHAR(1024) BASED (EVDATA_PTR);                            00007300
   DCL RESULT_LEN    BIN FIXED(31) BASED(EVDATLN_PTR);                  00007400
                                                                        00007500
   RESULT_LEN = 1;                                                      00007600
 /* --------------------------------------------------------------------00007700
  * COPY BREXX PARMS INTO PL1 STRUCTURE                                 00007800
  * --------------------------------------------------------------------00007900
  */                                                                    00008000
   DCL AI BIN FIXED(31);                                                00008100
                                                                        00008200
   DO AI=1 TO 15 ;                                                      00008300
      ARG_PTR = ARGSTRING_PTR(AI);                                      00008400
      ARG_LEN(AI) = ARGSTRING_LENGTH(AI);                               00008500
      IF ARG_LEN(AI)<=0 THEN ARG(AI)='';                                00008600
      ELSE DO                                                           00008700
         ARG(AI) = SUBSTR(ARGSTRING,1,ARG_LEN(AI));                     00008800
         ARGNUM=AI;                                                     00008900
      END;                                                              00009000
   END;                                                                 00009100
 /* --------------------------------------------------------------------00009200
  * THIS IS THE END OF THE %INCLUDE MODULE                              00009300
  * --------------------------------------------------------------------00009400
  */                                                                    00009500
                                                                        00009602
 /* --------------------------------------------------------------------00009701
  * RXCUT(STRING-TO-DETERMINE,N)                                        00009802
  * RETURN EVERY N.TH CHAR OF A INPUT STRING                            00009901
  * CALL FUNCTION IN A REXX SCRIPT WITH STR=RXCUT(STRING,N)             00010002
  * --------------------------------------------------------------------00010101
  */                                                                    00010201
                                                                        00010301
 /* --------------------------------------------------------------------00010400
  * INPUT VARIABLES                                                     00010500
  *   ARGNUM      CONTAINS NUMBER OF PROVIDED ARGUMENTS (MAX 15)        00010600
  *   ARG(I)      CONTAINS CONTENTS OF ARGUMENT I (1 TO 15)             00010700
  *   ARG_LEN(I)  CONTAINS LENGTH   OF ARGUMENT I (1 TO 15)             00010800
  * RETURN VARIABLES                                                    00010900
  *   RESULT      CONTAINS RESULT TO BE RETURNED TO BREXX               00011000
  *               THE RETURN VALUE MUST NOT EXCEED 1024 BYTES           00011100
  *   RESULT_LEN  CONTAINS LENGTH OF RETURNED STRING                    00011200
  * --------------------------------------------------------------------00011300
  */                                                                    00011400
                                                                        00011500
  RESULT='';                                                            00011600
  N=ARG(2);                                                             00011700
  RESULT_LEN=0;                                                         00011800
  DO I=N TO ARG_LEN(1) BY N;                                            00011900
     RESULT_LEN=RESULT_LEN+1;                                           00012000
     SUBSTR(RESULT,RESULT_LEN,1)=SUBSTR(ARG(1),I,1);                    00012100
  END;                                                                  00012200
 END RXCUT;                                                             00012300
                                                                        00012400
/*                                                                      00012500
//LKED.SYSLIB  DD DISP=SHR,DSN=SYS1.PL1LIB                              00012600
//LKED.SYSLMOD DD DISP=SHR,DSN=SYS2.LINKLIB(RXCUT)                      00012701
//                                                                      00012800
