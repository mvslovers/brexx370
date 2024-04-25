         MACRO
&PGM     MRXSTART &MODE=C,&PGMREG=RC,&A2PLIST='YES',&BREXX='YES'
         GBLC  &MAIN
         GBLC  &PGMTYPE
&MAIN    SETC  '&PGM'
&PGMTYPE SETC  '&MODE'
* ---------------------------------------------------------------------
         MNOTE '*     PROGRAM &PGM'
* ---------------------------------------------------------------------
&PGM     CSECT ,                START OF PROGRAM
         USING &PGM,RF          INIT PROGRAM ADDRESSABILITY
         STM   RE,RC,12(RD)     SAVE REGISTERS
         AIF   ('&BREXX' EQ 'NO').NOBREXX
         L     R2,8(,RD)        \
         LA    RE,96(,R2)        \
         L     RC,0(,RD)          \
         CL    RE,4(,RC)           \
         BL    G&SYSNDX             \
         L     RA,0(,RC)             \ SAVE AREA CHAINING
         BALR  RB,RA                 / AND JCC PROLOGUE
         CNOP  0,4                  /
         DC    F'96'               /
G&SYSNDX STM   RC,RE,0(R2)        /
         LR    RD,R2             /
         B     ISBREXX     IS IN BREXX ENVIRONMENT
.NOBREXX ANOP              FOR NON BREXX USAGE WITH A STUB
         LR    R5,R1       SAVE PARM REGISTER
         LR    R6,RF       ENTRY REGISTER
         GETMAIN RC,LV=256,SP=47
         ST    R1,0(R1)               IDENTIFY SAVE AREA BY ITS ADDRESS
         MVC   4(4,R1),=A(256)        ... AND ITS LENGTH
         MVC   0(20,R1),=CL20'*** SAVE-AREA ***'  SET EYECATCHER
         MVC   20(8,R1),=CL8'&PGM'
         LA    RE,28(R1)              NEW SAVE AREA, START CHAINING
         ST    RD,4(RE)               BACKWARD CHAIN TO CALLER IN NEW
         ST    RE,8(RD)               FORWARD  CHAIN FROM CALLER (OLD)
         LR    RD,RE                  POINT TO NEW SAVE AREA
         LR    R1,R5       RE-ESTABLISH PARM REGISTER
         LR    RF,R6       RE-ESTABLISH PROGRAM REGISTER
* ....
ISBREXX  LR    &PGMREG,RF       ESTABLISH MODULE ADDRESSABILITY
         DROP  RF               RELEASE INITIAL BASE REGISTER
         USING &PGM,&PGMREG     SET NEW PROGRAM BASE REGISTER ++++
         LR    RB,R1            PARAMETER LIST FROM CALLING PGM
         AIF   ('&BREXX' EQ 'NO').NLOAD
         AIF   ('&A2PLIST' NE 'YES').NLOAD
         L     RB,0(RB)         REFER TO PARMLIST
.NLOAD   ANOP
         B     S&SYSNDX
         DC    C'*** &PGM ***'
         DC    CL8'&SYSDATE',CL8'&SYSTIME'  DATE/TIME OF ASSEMBLY
S&SYSNDX DS    0H
         MEND
