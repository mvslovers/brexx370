RXSVC    TITLE 'GENERIC C WRAPPER FOR SVC CALLS'                        00000100
* --------------------------------------------------------------------- 00000200
*   WRAP ASSEMBLER CALL TO ANY SVC - TO BE CALLABLE FROM C (FOR BREXX)  00000300
*   AUTHOR  : MIKE GROSSMANN (MIG)                                      00000400
*   CREATED : 21.06.2019  MIG                                           00000500
*   JCC PROLOGUE : JUERGEN WINKELMANN, ETH ZUERICH.                     00000600
* --------------------------------------------------------------------- 00000700
         PRINT GEN                                                      00000800
* --------------------------------------------------------------------  00000900
*   RXSVC CODE: WRAP SVC CALL                                           00001000
* --------------------------------------------------------------------  00001100
RXSVC    MRXSTART A2PLIST=YES                                           00001200
         USING SVCPARAM,RB  ENABLE ADDRESSIBILTY OF C INPUT AREA        00001300
RXSVCGO  DS   0H                                                        00001400
*                                                                       00001500
         L     RA,SVCNUM    LOAD SVC NUMBER                             00001600
*                                                                       00001700
         L     R0,SVCR0     LOAD REGISTER 0                             00001800
         L     R1,SVCR1     LOAD REGISTER 1                             00001900
         L     R15,SVCR15   LOAD REGISTER 15                            00002000
         STM   R0,R15,BEFORE                                            00002101
*                                                                       00002200
         EX    R10,DOSVC                                                00002300
*                                                                       00002400
         STM   R0,R15,AFTER                                             00002501
         ST    R15,SVCR15   SAVE REGISTER 15                            00002600
         ST    R1,SVCR1     SAVE REGISTER 1                             00002700
         ST    R0,SVCR0     SAVE REGISTER 0                             00002800
* --------------------------------------------------------------------  00002900
*   EXIT PROGRAM                                                        00003000
* --------------------------------------------------------------------  00003100
EXIT     MRXEXIT                                                        00003200
         LTORG                                                          00003300
DOSVC    SVC   0                                                        00003400
         DC    CL16'BEFORE REGS'                                        00003502
BEFORE   DS    20F                                                      00003601
         DC    CL16'AFTER  REGS'                                        00003702
AFTER    DS    20F                                                      00003801
* --------------------------------------------------------------------  00003900
*    INCOMING STORAGE DEFINITION (FROM C PROGRAM)                       00004000
* --------------------------------------------------------------------  00004100
*                                                                       00004200
* INPUT PARM DSECT, PROVIDED AS INPUT PARAMETER BY THE C PROGRAM        00004300
SVCPARAM DSECT               INPUT PARM DSECT                           00004400
SVCNUM   DS    F             SVC NUMBER                                 00004500
SVCR0    DS    F             REGISTER 0                                 00004600
SVCR1    DS    F             REGISTER 1                                 00004700
SVCR15   DS    F             REGISTER 15                                00004800
* --------------------------------------------------------------------  00004900
*    REGISTER DEFINITIONS                                               00005000
* --------------------------------------------------------------------  00005100
         COPY  MRXREGS                                                  00005200
         END   RXSVC                                                    00005300
