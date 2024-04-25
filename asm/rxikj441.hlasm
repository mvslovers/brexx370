RXIKJ441 TITLE 'WRAP CALL TO IKJCT441 FROM C'                           00000100
         PRINT GEN                                                      00000200
* --------------------------------------------------------------------- 00000300
*   WRAP CALL TO IKJCT441 FROM C (FOR BREXX)                            00000400
*   AUTHOR  : PETER JACOB (PEJ)                                         00000500
*   CREATED : 21.10.2018  PEJ                                           00000600
*   UPDATE  : 27.10.2018  PEJ ADD WORKAREA SUPPLIED BY "C" PROGRAMM     00000700
*   UPDATE  : 03.12.2018  PEJ CHANGED TO ADDRESS LIST OF PARMS          00000800
*   UPDATE  : 18.01.2019  PEJ USE LOAD INSTEAD OF LINK TO IKJCT441      00000900
*   JCC PROLOGUE : JUERGEN WINKELMANN, ETH ZUERICH.                     00001000
* --------------------------------------------------------------------- 00001100
*   PROGRAM PASSES THE INCOMING PARAMETERS VIA R1 TO IKJCT441           00001200
* --------------------------------------------------------------------- 00001300
RXIKJ441 MRXSTART A2PLIST=YES   START OF PROGRAM                        00001400
* --------------------------------------------------------------------  00001500
*   WRAPPER CODE                                                        00001600
* --------------------------------------------------------------------  00001700
         USING WRCPARM,RB       ADDRESSABILITY OF C WORKAREA            00001800
RUNPGM   BAL   RE,INIT          INIT PROGRAM                            00001900
         BAL   RE,LINK441       CALL IKJCT441                           00002000
         B     EXIT             EXIT PROGRAM                            00002100
* --------------------------------------------------------------------  00002200
*   INIT PROGRAM TEST INCOMING ENVIRONMENT, SETUP IKJCT441 CBS          00002300
* --------------------------------------------------------------------  00002400
INIT     DS    0H                                                       00002500
         CLI   MISSIKJ,C'1'                                             00002600
         BE    EX806                                                    00002700
         LOAD  EP=IKJCT441,ERRET=EX806   PRE LOAD IKJCT441              00002800
         LR    R5,R0            LOAD ENTRY POINT OF IKJCT441            00002900
         LA    R5,0(R5)         LOAD AND CLEAR HIGH ORDER BYTE          00003000
         LTR   R5,R5            LOAD AND TEST ENTRY POINT               00003100
         BZ    EX806            ENTRY POINT ADDRESS IS ZERO, EXIT PGM   00003200
CHKPARM  LTR   RB,RB            LOAD INCOMING PARAMETER ADDRESS         00003300
         BNZ   SETUPENV         GT 0, YES                               00003400
         LA    RF,512           ELSE, SET RC=512                        00003500
         B     EXFATAL          GOTO EXIT, ADDRESSABILITY  NOT GIVEN    00003600
SETUPENV DS    0H                                                       00003700
         L     RA,WORKPTR       POINTER TO THE WORK AREA                00003800
         USING WRPPERWA,RA      ESTABLISH ADDRESSABILIT OF WORK AREA    00003900
         ST    RE,SAVE01        SAVE INIT RETURN REGISTER               00004000
         MVA   CCOD,16          DEFAULT RETURN CODE                     00004100
         MVA   AECODE,ECODE                                             00004200
         MVA   ANAMEPTR,NAMEPTR                                         00004300
         MVA   ANAMELEN,NAMELEN                                         00004400
         MVA   AVALPTR,VALUEPTR                                         00004500
         MVA   AVALLEN,VALUELEN                                         00004600
         MVA   ATOKEN,TOKEN                                             00004700
         MVI   ATOKEN,X'80'                                             00004800
         L     RE,SAVE01                                                00004900
         BR    RE               RETURN TO CALLER                        00005000
* --------------------------------------------------------------------  00005100
*   CALL  IKJCT441, REQUESTS ARE DEFINED BY CALLING C PROGRAM           00005200
* --------------------------------------------------------------------  00005300
LINK441  ST    RE,SAVE01       SAVE RETURN REGISTER                     00005400
         LA    R1,IKJPARMS                                              00005500
*        LINK  EP=IKJCT441                                              00005600
         LR    RF,R5           LOAD ENTRY POINT TO RF (CALL MUST BE RF) 00005700
         BALR  RE,RF           CALL IKJCT441 WITH SAVE R5 FROM LOAD     00005800
         ST    RF,CCOD         SAVE RETURN CODE                         00005900
         L     RE,SAVE01       LOAD RETURN REGISTER                     00006000
         BR    RE              RETURN TO CALLER                         00006100
* --------------------------------------------------------------------  00006200
*   EXIT PROGRAM                                                        00006300
* --------------------------------------------------------------------  00006400
EX806    MVI   MISSIKJ,C'1'                                             00006500
         LA    RF,806                                                   00006600
         B     EXFATAL                                                  00006700
EXIT     L     RF,CCOD                                                  00006800
EXFATAL  MRXEXIT                                                        00006900
MISSIKJ  DC    CL1'0'                                                   00007000
         LTORG                                                          00007100
* --------------------------------------------------------------------  00007200
*    INCOMING STORAGE DEFINITION (FROM C PROGRAM)                       00007300
* --------------------------------------------------------------------  00007400
*                                                                       00007500
WRCPARM  DSECT                                                          00007600
ECODE    DS    A                                                        00007700
NAMELEN  DS    A               LENGTH OF THE VARIABLE NAME              00007800
NAMEPTR  DS    A               POINTER TO THE VARIABLE NAME             00007900
VALUELEN DS    A               LENGTH OF THE VARIABLE VALUE             00008000
VALUEPTR DS    A               POINTER TO THE VARIABLE VALUE            00008100
WORKPTR  DS    A               POINTER TO THE WORK AREA                 00008200
WRPPERWA DSECT                 WRAPPER WORK AREA                        00008300
TOKEN    DS    A               POINTER TO THE VARIABLE VALUE            00008400
SAVE01   DS    A               RETURN REGISTER SAVE ADDRESS             00008500
CCOD     DS    A               IKJCT441 RETURN CODE                     00008600
IKJPARMS DS    0A                                                       00008700
AECODE   DS    A(ECODE)                                                 00008800
ANAMEPTR DS    A(NAMEPTR)                                               00008900
ANAMELEN DS    A(NAMELEN)                                               00009000
AVALPTR  DS    A(VALUEPTR)                                              00009100
AVALLEN  DS    A(VALUELEN)                                              00009200
ATOKEN   DS    A(TOKEN)                                                 00009300
RESERVED ORG   WRPPERWA+256                                             00009400
*                                                                       00009500
         COPY  MRXREGS                                                  00009600
         END   RXIKJ441                                                 00009700
