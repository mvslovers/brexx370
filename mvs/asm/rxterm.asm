RXTERM  TITLE 'TERMINATE AND CLEANUP THE BREXX/370 ENVIRONMENT'         00000103
* --------------------------------------------------------------------- 00000200
*   TERMINATE AND CLEANUP THE BREXX/370 ENVIRONMENT                     00000300
*   AUTHOR     : MIKE GROSSMANN (MIG)                                   00000400
*   CREATED    : 10.03.2020  MIG                                        00000500
*   C PROLOGUE : JUERGEN WINKELMANN, ETH ZUERICH.                       00000600
* --------------------------------------------------------------------- 00000700
         PRINT   GEN                                                    00000800
* ===================================================================== 00000900
* RXTERM                                                                00001000
*                                                                       00001100
*     MAIN ENTRY POINT USED BY BREXX/370                                00001200
*                                                                       00001300
*     INPUT:                                                            00001400
*              R1    PARAMS                                             00001500
*                                                                       00001600
*     OUTPUT:                                                           00001700
*              R15   RETURN CODE                                        00001800
*                                                                       00001900
*     REGISTER USAGE:                                                   00002000
*              R4    ENVIRONMENT AREA                                   00002100
*              R5    USER AREA                                          00002200
*              R12   BASE REGISTER                                      00002300
*                                                                       00002400
* ===================================================================== 00002500
RXTERM   MRXSTART A2PLIST=YES  START OF PROGRAM                         00002602
*                                                                       00002700
         USING PARAMS,RB                                                00002800
         L     R4,ENVPTR       GET PTR TO ENVIRONMENT AREA              00002900
         GETMAIN R,LV=USRLEN   GET STORAFE FOR USER AREA                00003000
         LR    R5,R1           SAVE GETMAIN POINTER                     00003100
         USING ENVCTX,R4                                                00003200
         USING USER,R5                                                  00003300
         DROP  RB                                                       00003400
*                                                                       00003500
         CALL  UNALLOC         FREE ALLOCATION MADE BY US               00003601
*                                                                       00003700
         DROP  R5                                                       00003800
         LR    R6,R15                                                   00003908
*                                                                       00004000
         FREEMAIN R,LV=USRLEN,A=(5)                                     00004100
*                                                                       00004200
         LR    R15,R6                                                   00004308
         MRXEXIT                                                        00004400
         LTORG                                                          00004500
*                                                                       00004600
         EJECT                                                          00004700
* ===================================================================== 00004800
* UNALLOC                                                               00004901
*                                                                       00005000
*     PERFORM UNALLOCATION OF ALLOCATIONS MADE BY OURSELVES             00005101
*                                                                       00005200
*     INPUT:                                                            00005300
*              R4    ENVIRONMENT AREA                                   00005400
*              R5    USER AREA                                          00005500
*                                                                       00005600
*     OUTPUT:                                                           00005700
*                                                                       00005800
*     REGISTER USAGE:                                                   00005900
*              R5    USERREA                                            00006000
*              R12   BASE REGISTER                                      00006100
*                                                                       00006200
* ===================================================================== 00006300
         USING ENVCTX,R4                                                00006400
         USING USER,R5                                                  00006500
UNALLOC  CSECT ,                                                        00006602
*                                                                       00006700
* --------------------------------------------------------------------- 00006800
* ENTRY CODING                                                          00006900
* --------------------------------------------------------------------- 00007000
         SAVE  (14,12),,UNALLOC SAVE CALLER'S REGISTERS                 00007101
         BALR  R12,R0          ESTABLISH ADDRESSABILITY                 00007200
         USING *,R12           SET BASE REGISTER                        00007300
*                                                                       00007400
         LA    R11,USRSA1      GET SAVE AREA POINTER                    00007500
         ST    R13,4(R11)      STORE BACKWARD POINTER                   00007600
         ST    R11,8(R13)      STORE FORWARD POINTER                    00007700
*                                                                       00007800
         LR    R13,R11         GET SAVE AREA ADDRESS                    00007900
* --------------------------------------------------------------------- 00008000
* UNALLOCATE STDIN / STDOUT / STDERR                                    00008102
* --------------------------------------------------------------------- 00008200
         IF (TM,EFLAGS2,EF2TSOFG,O) ONLY FOR TSOFG                      00008303
           IF (TM,EFLAGS3,EF3IN,O)                                      00008403
             CALL DYNAFREE,(=CL8'STDIN'),MF=(E,ULCALL2) FREE STDIN      00008502
           ENDIF                                                        00008600
                                                                        00008700
           IF (TM,EFLAGS3,EF3OUT,O)                                     00008803
             CALL DYNAFREE,(=CL8'STDOUT'),MF=(E,ULCALL2) FREE STDOUT    00008902
           ENDIF                                                        00009000
                                                                        00009100
           IF (TM,EFLAGS3,EF3ERR,O)                                     00009203
             CALL DYNAFREE,(=CL8'STDERR'),MF=(E,ULCALL2) FREE STDERR    00009302
           ENDIF                                                        00009400
         ENDIF                                                          00009500
* --------------------------------------------------------------------- 00009600
* EXIT CODING                                                           00009700
* --------------------------------------------------------------------- 00009800
         L     R13,4(,R13)     PICK UP CALLER'S SAVE AREA               00009900
         L     R14,12(,R13)    GET RETURN ADDRESS                       00010000
         RETURN (0,12)                                                  00010100
*                                                                       00010200
         LTORG                                                          00010300
*                                                                       00010400
         EJECT                                                          00010500
* ===================================================================== 00010600
* DYNAFREE                                                              00010701
*                                                                       00010800
*     PERFORM UNALLOCATION FOR GIVEN DD NAME                            00010901
*                                                                       00011000
*     INPUT:                                                            00011100
*              R1    PARAMS                                             00011200
*              R5    USERAREA                                           00011300
*                                                                       00011400
*     OUTPUT:                                                           00011500
*                                                                       00011600
*     REGISTER USAGE:                                                   00011700
*              R5    USERREA                                            00011800
*              R12   BASE REGISTER                                      00011900
*                                                                       00012000
* ===================================================================== 00012100
         USING USER,R5                                                  00012200
DYNAFREE CSECT ,                                                        00012302
*                                                                       00012400
* --------------------------------------------------------------------- 00012500
* ENTRY CODING                                                          00012600
* --------------------------------------------------------------------- 00012700
         SAVE  (14,12),,DYNAFREE SAVE CALLER'S REGISTERS                00012802
         BALR  R12,R0          ESTABLISH ADDRESSABILITY                 00012900
         USING *,R12           SET BASE REGISTER                        00013000
*                                                                       00013100
         LA    R11,USRSA2      GET SAVE AREA POINTER                    00013200
         ST    R13,4(R11)      STORE BACKWARD POINTER                   00013300
         ST    R11,8(R13)      STORE FORWARD POINTER                    00013400
*                                                                       00013500
         LR    R13,R11         GET SAVE AREA ADDRESS ..                 00013600
* --------------------------------------------------------------------- 00013700
* GET DD NAME FROM PARAMETERS                                           00013800
* --------------------------------------------------------------------- 00013900
         L     R10,0(,R1)                                               00014000
         LA    R10,0(,R10)                                              00014100
* --------------------------------------------------------------------- 00014200
* PREPARE REQUEST BLOCK                                                 00014300
* --------------------------------------------------------------------- 00014400
         XC    UARBP(UALEN),UARBP CLEAR                                 00014500
*                                                                       00014600
         LA    R9,UARBP                                                 00014700
         USING S99RBP,R9                                                00014800
         LA    R4,S99RBPTR+L'S99RBPTR                                   00014900
         USING S99RB,R4                                                 00015000
         ST    R4,S99RBPTR                                              00015100
         OI    S99RBPTR,S99RBPND                                        00015200
         DROP  R9                                                       00015300
* --------------------------------------------------------------------- 00015400
* BUILD REQUEST BLOCK                                                   00015500
* --------------------------------------------------------------------- 00015600
         MVI   S99RBLN,S99RBLEN                                         00015700
         MVI   S99VERB,S99VRBUN                                         00015806
         LA    R2,UATUPL                                                00015900
         ST    R2,S99TXTPP                                              00016000
         DROP  R4                                                       00016100
*                                                                       00016200
         USING S99TUPL,R2                                               00016300
* --------------------------------------------------------------------- 00016400
* ADD DUNDDNAM TEXT UNIT POINTER TO LIST                                00016505
* --------------------------------------------------------------------- 00016600
         LA    R6,UADDNAMU                                              00016700
         ST    R6,S99TUPTR                                              00016800
* --------------------------------------------------------------------- 00016908
* ADD DUNUNALC TEXT UNIT POINTER TO LIST                                00017008
* --------------------------------------------------------------------- 00017108
         LA    R2,S99TUPL+L'S99TUPTR POINT TO NEXT ELEMENT              00017208
         LA    R6,UAUNALCU                                              00017308
         ST    R6,S99TUPTR                                              00017408
* --------------------------------------------------------------------- 00017500
* MARK LAST ENTRY IN TEXT UNIT POINTER LIST                             00017600
* --------------------------------------------------------------------- 00017700
         OI    S99TUPTR,S99TUPLN                                        00017800
* --------------------------------------------------------------------- 00017900
* BUILD TEXT UNITS                                                      00018000
* --------------------------------------------------------------------- 00018100
         MVC   UADDNAMU(UADDNAML),MADDNAMU                              00018200
         MVC   UAUNALCU(UAUNALCL),MAUNALCU                              00018308
* --------------------------------------------------------------------- 00018400
* FILL TEXT UNITS WITH VALUES                                           00018500
* --------------------------------------------------------------------- 00018600
         MVC   UADDNAM(L'UADDNAM),0(R10) DDNAME                         00018700
*                                                                       00018800
         LA    R1,UARBP                                                 00018900
         DYNALLOC                                                       00019000
*                                                                       00019110
* --------------------------------------------------------------------- 00019200
* EXIT CODING                                                           00019300
* --------------------------------------------------------------------- 00019400
         L     R13,4(,R13)     PICK UP CALLER'S SAVE AREA               00019500
         L     R14,12(,R13)    GET RETURN ADDRESS                       00019600
         RETURN (0,12)                                                  00019700
*                                                                       00019800
         LTORG                                                          00019900
*                                                                       00020000
MADDNAMU DC    AL2(DUNDDNAM),X'0001',X'0008'    DDNAME                  00020105
MAUNALCU DC    AL2(DUNUNALC),X'0000'            OVERRIDE PERM           00020207
         EJECT                                                          00020300
* ===================================================================== 00020400
* PARAMETER AREA                                                        00020500
* ===================================================================== 00020600
PARAMS   DSECT                                                          00020700
ENVPTR   DS    A                                                        00020800
WORKPTR  DS    A                                                        00020900
* ===================================================================== 00021000
* USER AREA DUMMY SECTION                                               00021100
* ===================================================================== 00021200
USER     DSECT                                                          00021300
USREYE   DS    0CL4            THE EYE CATCHER                          00021400
         DC    CL4'USER'                                                00021500
USRSA1   DS    18F             SAVE AREA DEPTH 1                        00021600
USRSA2   DS    18F             SAVE AREA DEPTH 2                        00021700
* --- CALL MACROS                                                       00021800
ULCALL1  CALL ,(0,0,0),MF=L    CALL PARAMETER LIST W 3 PARMS DEPTH 1    00021900
ULCALL2  CALL ,(0,0,0),MF=L    CALL PARAMETER LIST W 3 PARMS DEPTH 2    00022000
* --- DYNALLOC REQUEST BLOCK                                            00022100
UARBP    DS    F,CL20          REQUEST BLOCK POINTER AND REQUEST BLOCK  00022200
UATUPL   DS    2A              TEXT UNIT POINTER LIST                   00022308
* --- TEXT UNITS                                                        00022400
UADDNAMU DC    H'1,1,8'        KEY,VALCOUNT,LEN                         00022500
UADDNAML EQU   *-UADDNAMU                                               00022600
UADDNAM  DS    CL8                                                      00022700
UAUNALCU DC    H'7,0'          KEY,VALCOUNT,LEN                         00022807
UAUNALCL EQU   *-UAUNALCU                                               00022907
UALEN    EQU *-UARBP                                                    00023000
USRLEN   EQU *-USER                                                     00023100
         EJECT                                                          00023200
* ===================================================================== 00023300
* EVIRONMENT CONTEXT                                                    00023400
* ===================================================================== 00023500
         #ENVCTX                  BREXX ENVIRONMENT CONTEXT             00023600
* ===================================================================== 00023700
* OTHER DUMMY SECTIONS                                                  00023800
* ===================================================================== 00023900
*        CVT      DSECT=YES       COMMON VECTOR TABLE                   00024002
*        IHAPSA   DSECT=YES       PREFIXED SAVE AREA                    00024102
*        IHAASCB  DSECT=YES       ADDRESS SPACE CONTOL BLOCK            00024202
*        IHAASXB  DSECT=YES       ADDRESS SPACE EXTENSION BLOCK         00024302
*        IHAACEE  ,               ACCESSOR ENVIRONMENT ELEMENT          00024402
*        IKJEFLWA ,               LOGON WORK AREA                       00024502
*        IKJECT   ,               ENVIRONMENT CONTROL TABLE             00024602
*        IKJPSCB  ,               PROTECTED STEP CONTROL BLOCK          00024702
*        IKJTCB   LIST=YES        TASK CONTROL BLOCK                    00024802
*        IKJUPT   ,               USER PROFILE TABLE                    00024902
*        IEFTIOT1 ,               TASK INPUT OUTPUT TABLE               00025002
         IEFZB4D0 ,               DYNALLOC PARAMETER LIST               00025100
         IEFZB4D2 ,               DYNALLOC TEXT UNIT KEYS               00025200
* --- MISSING LENGTH EQUATE                                             00025300
S99RBLEN EQU   (S99RBEND-S99RB)                                         00025400
* --- I/O SERVICE ROUTINE WORK AREA                                     00025500
         EJECT                                                          00025600
         COPY  MRXREGS                                                  00025700
         END   RXTERM                                                   00025802
