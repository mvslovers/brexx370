         TITLE '"IFG0EX0B" - OPEN EXIT (RELEASE SEC SPACE)'
**
**       REGISTER DEFINITIONS
**
R0       EQU   0
R1       EQU   1
R2       EQU   2
R3       EQU   3
R4       EQU   4
R5       EQU   5
R6       EQU   6
R7       EQU   7
R8       EQU   8
R9       EQU   9
R10      EQU   10
R11      EQU   11
R12      EQU   12
R13      EQU   13
R14      EQU   14
R15      EQU   15
RA       EQU   10
RB       EQU   11
RC       EQU   12
RD       EQU   13
RE       EQU   14
RF       EQU   15
         EJECT
         PRINT NOGEN
JFCB     DSECT
         IEFJFCBN LIST=NO
**
         IECOIEXL
**
         IHAPSA
**
         CVT   DSECT=YES,LIST=NO
**
         IEFJESCT
**
         IEFJSCVT
**
         SIO5GBL TYPE=DSECT
**
         SIO5MID TYPE=DSECT
         EJECT
**
         SIOSCVT
         PRINT GEN
         EJECT
**
WRKDSCT  DSECT
**
**       EXIT WORK AREA
**
WRKSAVE  DC    18F'0'                  REG SAVE AREA
WRKLEN   EQU   *-WRKDSCT               LENGTH OF AREA
         EJECT
IFG0EX0B CSECT
**                                       CONTROL OF PERMISSION)
**
**       SAVE ALL THE REGISTERS NOW
**
         USING IFG0EX0B,RF             EPA REG
         SAVE  (14,12)                 SAVE THE REGS
         SPACE 2
**
**       IDENTIFY THIS MODULE
**
         B     ARNIDN                  GO AROUND THE ID
         DC    CL8'IFG0EX0B'
         DC    CL8'&SYSDATE'
         DC    CL8'&SYSTIME'
ARNIDN   DS    0H
         SPACE 2
**
**       SET THE BASE REG
**
         LR    RC,RF                   SET THE NEW BASE
         DROP  RF
         USING IFG0EX0B,RC             AND TELL THE ASSEMBLER
         SPACE 2
**
**       SET PARMS BASE
**
         LR    RB,R1                   POINT TO THE PARMS
         USING OIEXL,RB                AND MAP THEM
         SPACE 2
**
**       GET THE WORK AREA
**
         GETMAIN R,LV=WRKLEN           POINT TO THE LENGTH
         ST    RD,4(,R1)               SAVE CALLER REG
         ST    R1,8(,RD)               AND OUR SAVE
         LR    RD,R1                   POINT TO THE WORK AREA
         USING WRKDSCT,RD              AND MAP THE AREA
         SPACE 2
**
**       LOCATE THE S.C.I. SSCT
**
         L     RF,FLCCVT-PSA           POINT AT CVT
         L     RF,CVTJESCT-CVT(RF)     POINT AT JESCT
         LTR   RF,RF                   IS THERE A JESCT?
         BZ    IFGEXIT                 NO, EXIT NOW
         L     RF,JESSSCT-JESCT(RF)    POINT AT SSCT
         LTR   RF,RF                   IS THERE AN SSCT?
         BZ    IFGEXIT                 NO, EXIT NOW
SSCTSCAN DS    0H
         CLC   =C'SCI1',SSCTSNAM-SSCT(RF) IS THIS OUR SSCT?
         BE    SSCTFND                 YES
         L     RF,SSCTSCTA-SSCT(RF)    POINT AT NEXT SSCT
         LTR   RF,RF                   IS THERE A NEXT SSCT?
         BNZ   SSCTSCAN                YES, CONTINUE SCAN
         B     IFGEXIT                 NO, EXIT
         SPACE 2
SSCTFND  DS    0H
**
**       SEE IF S.I.O. INITIALIZED
**
         L     RF,SSCTSUSE-SSCT(RF)    LOAD SIO CVT ADDRESS
         LTR   RF,RF                   DOES SIO CVT EXIST?
         BZ    IFGEXIT                 NO, EXIT
         SPACE 2
**
**       SEE IF RUNNING S.I.O. RELEASE 5.0
**
         CLC   =CL8'SIO5GBLT',0(RF)    IS IT RELEASE 5?
         BNE   NOTREL5                 NOPE, DO IT THE OLD WAY
**
**       SEE IF S.I.O. IS ACTIVE NOW
**
         CLI   GBTPRFL-SIO5GBLD(RF),GBTPRUP TEST IS SIO UP?
         BNE   IFGEXIT                 NO, EXIT
         SPACE 2
**
**       POINT TO THE RELEASE INTERFACE MODULE
**
         L     RF,GBTRELP-SIO5GBLD(,RF) LOAD SIO EXIT ADDRESS
         LTR   RF,RF                   IS IT AVAILABLE?
         BZ    IFGEXIT                 NO-RETURN TO OPEN W/O RLSE
         LA    RF,MIDLENG(,RF)          PASS THE ID
         B     RELCHECK                GO CHECK FOR RELEASE
         SPACE 2
NOTREL5  DS    0H
**
**       SEE IF S.I.O. IS ACTIVE NOW
**
         TM    SIOSFLAG-SIOSCVT(RF),SIOSSHFG TEST IS SIO UP?
         BNO   IFGEXIT                 NO, EXIT
         SPACE 2
**
**       POINT TO THE RELEASE INTERFACE MODULE
**
         L     RF,SIOSRELP-SIOSCVT(RF) LOAD SIO EXIT ADDRESS
         LTR   RF,RF                   IS IT AVAILABLE?
         BZ    IFGEXIT                 NO-RETURN TO OPEN W/O RLSE
         SPACE 2
RELCHECK DS    0H
**
**       GO TEST FOR RELEASE ELIGIBILITY
**
         LR    R1,RB                   SET THE PARM POINTER
         BALR  RE,RF                   CHECK TABLE FOR RELEASING
         SPACE 2
**
**       THESE RETURN CODES ARE SET IN BYTE 3 OF REG 15.
**
**       00 - DATA SET IS RELEASE CANDIDATE
**       04 - S.I.O. IS INACTIVE
**       08 - S.I.O. RUNNING IN WARNING MODE ONLY
**       0C - DATA SET NOT OPEN FOR OUTPUT
**       10 - PROTECT KEY LOWER THAN 8
**       14 - NOT A DISK FILE BEING OPENED
**       18 - NOT A PS FILE BEING OPENED
**       1C - NOT A QSAM OR BSAM FILE
**       20 - TABLE "SIOSRLXX" CAN NOT BE LOADED
**       24 - TABLE "SIOSRLXX" IS INVALID
**       28 - BYPASS ENTRY FOUND FOR THIS FILE
**       2C - NO SELECT ENTRY FOR THIS FILE
**       30 - FORMAT 1 DSCB NOT BEING PROCESSED
**       34 - DATA SET IS OPENED WITH DISP=MOD
**
**       THE FOLLOWING RETURN CODES ARE ONLY SET FOR DASD DATA SETS
**       THAT USE AN AVERAGE BLOCK LENGTH FOR SPACE ALLOCATION.
**
**       THIS RETURN CODE IS SET IN BYTE 2 OF REG 15
**
**       04 - SPACE ALLOCATION HAS BEEN RE-CALCULATED TO ACCOUNT
**            FOR THE BLOCK SIZE CHANGED BY S.I.O.
**
         SPACE 2
**
**       THIS EXIT ONLY TESTS FOR A RETURN CODE OF 00000000 AND
**       000004XX.   IS UP TO THE USER TO TEST FOR OTHER RETURN
**       CODES AS REQUIRED.
**
         LTR   RF,RF                   RELEASE SPACE ONLY?
         BZ    IFGRLSE                 YES, SET THE RELEASE
**
         CLM   RF,3,=X'0400'           RELEASE/SEC SPACE?
         BE    IFGRLSE                 YES, SET THE RELEASE
**
         CLM   RF,2,=X'04'             SEC SPACE ONLY?
         BE    IFGMODF                 YES, SET JFCB MODIFIED
**
         XR    RF,RF                   CLEAR THE RC (JFCB NOT CHANGED)
         B     IFGEXIT                 RETURN TO OPEN NOW
         SPACE 2
IFGRLSE  DS    0H
**
**       SET THE RELEASE FLAG IN THE JFCB
**
         L     R1,OIEXJFCB             POINT TO THE JFCB
         OI    JFCBIND1-JFCB(R1),JFCRLSE SET THE RELEASE INDICATOR
**
IFGMODF  DS    0H
**
         LA    RF,4                    INDICATE JFCB MODIFIED
         SPACE 2
IFGEXIT  DS    0H
**
**       RELEASE THE WORK AREA
**
         LR    R2,RD                   COPY THE POINTER
         LR    R3,RF                   SAVE THE RC FOR NOW
         L     RD,4(,RD)               POINT TO CALLER SAVE
         XC    0(WRKLEN,R2),0(R2)      CLEAR THE AREA
         FREEMAIN R,LV=WRKLEN,A=(R2)
         SPACE 2
**
**       RETURN TO CALLER NOW
**
         LR    RF,R3                   GET THE RETURN CODE
         L     RE,12(,RD)              RETURN REG
         LM    R0,RC,20(RD)            REST OF REGS
         BR    RE                      AND GO BACK
         SPACE 2
**
**       LITERALS
**
         LTORG
         END
