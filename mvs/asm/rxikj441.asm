RXIKJ441 TITLE 'WRAP CALL TO IKJCT441 FROM C'
         PRINT GEN
* ---------------------------------------------------------------------
*   WRAP CALL TO IKJCT441 FROM C (FOR BREXX)
*   AUTHOR  : PETER JACOB (PEJ)
*   CREATED : 21.10.2018  PEJ
*   UPDATE  : 27.10.2018  PEJ ADD WORKAREA SUPPLIED BY "C" PROGRAMM
*   UPDATE  : 03.12.2018  PEJ CHANGED TO ADDRESS LIST OF PARMS
*   UPDATE  : 18.01.2019  PEJ USE LOAD INSTEAD OF LINK TO IKJCT441
*   JCC PROLOGUE : JUERGEN WINKELMANN, ETH ZUERICH.
* ---------------------------------------------------------------------
*   PROGRAM PASSES THE INCOMING PARAMETERS VIA R1 TO IKJCT441
* ---------------------------------------------------------------------
RXIKJ441 MRXSTART A2PLIST=YES   START OF PROGRAM
* --------------------------------------------------------------------
*   WRAPPER CODE
* --------------------------------------------------------------------
         USING WRCPARM,RB       ADDRESSABILITY OF C WORKAREA
RUNPGM   BAL   RE,INIT          INIT PROGRAM
         BAL   RE,LINK441       CALL IKJCT441
         B     EXIT             EXIT PROGRAM
* --------------------------------------------------------------------
*   INIT PROGRAM TEST INCOMING ENVIRONMENT, SETUP IKJCT441 CBS
* --------------------------------------------------------------------
INIT     DS    0H
         CLI   MISSIKJ,C'1'
         BE    EX806
         LOAD  EP=IKJCT441,ERRET=EX806   PRE LOAD IKJCT441
         LR    R5,R0            LOAD ENTRY POINT OF IKJCT441
         LA    R5,0(R5)         LOAD AND CLEAR HIGH ORDER BYTE
         LTR   R5,R5            LOAD AND TEST ENTRY POINT
         BZ    EX806            ENTRY POINT ADDRESS IS ZERO, EXIT PGM
CHKPARM  LTR   RB,RB            LOAD INCOMING PARAMETER ADDRESS
         BNZ   SETUPENV         GT 0, YES
         LA    RF,512           ELSE, SET RC=512
         B     EXFATAL          GOTO EXIT, ADDRESSABILITY  NOT GIVEN
SETUPENV DS    0H
         L     RA,WORKPTR       POINTER TO THE WORK AREA
         USING WRPPERWA,RA      ESTABLISH ADDRESSABILIT OF WORK AREA
         ST    RE,SAVE01        SAVE INIT RETURN REGISTER
         MVA   CCOD,16          DEFAULT RETURN CODE
         MVA   AECODE,ECODE
         MVA   ANAMEPTR,NAMEPTR
         MVA   ANAMELEN,NAMELEN
         MVA   AVALPTR,VALUEPTR
         MVA   AVALLEN,VALUELEN
         MVA   ATOKEN,TOKEN
         MVI   ATOKEN,X'80'
         L     RE,SAVE01
         BR    RE               RETURN TO CALLER
* --------------------------------------------------------------------
*   CALL  IKJCT441, REQUESTS ARE DEFINED BY CALLING C PROGRAM
* --------------------------------------------------------------------
LINK441  ST    RE,SAVE01       SAVE RETURN REGISTER
         LA    R1,IKJPARMS
*        LINK  EP=IKJCT441
         LR    RF,R5           LOAD ENTRY POINT TO RF (CALL MUST BE RF)
         BALR  RE,RF           CALL IKJCT441 WITH SAVE R5 FROM LOAD
         ST    RF,CCOD         SAVE RETURN CODE
         L     RE,SAVE01       LOAD RETURN REGISTER
         BR    RE              RETURN TO CALLER
* --------------------------------------------------------------------
*   EXIT PROGRAM
* --------------------------------------------------------------------
EX806    MVI   MISSIKJ,C'1'
         LA    RF,806
         B     EXFATAL
EXIT     L     RF,CCOD
EXFATAL  MRXEXIT
MISSIKJ  DC    CL1'0'
         LTORG
* --------------------------------------------------------------------
*    INCOMING STORAGE DEFINITION (FROM C PROGRAM)
* --------------------------------------------------------------------
*
WRCPARM  DSECT
ECODE    DS    A
NAMELEN  DS    A               LENGTH OF THE VARIABLE NAME
NAMEPTR  DS    A               POINTER TO THE VARIABLE NAME
VALUELEN DS    A               LENGTH OF THE VARIABLE VALUE
VALUEPTR DS    A               POINTER TO THE VARIABLE VALUE
WORKPTR  DS    A               POINTER TO THE WORK AREA
WRPPERWA DSECT                 WRAPPER WORK AREA
TOKEN    DS    A               POINTER TO THE VARIABLE VALUE
SAVE01   DS    A               RETURN REGISTER SAVE ADDRESS
CCOD     DS    A               IKJCT441 RETURN CODE
IKJPARMS DS    0A
AECODE   DS    A(ECODE)
ANAMEPTR DS    A(NAMEPTR)
ANAMELEN DS    A(NAMELEN)
AVALPTR  DS    A(VALUEPTR)
AVALLEN  DS    A(VALUELEN)
ATOKEN   DS    A(TOKEN)
RESERVED ORG   WRPPERWA+256
*
         COPY  MRXREGS
         END   RXIKJ441
