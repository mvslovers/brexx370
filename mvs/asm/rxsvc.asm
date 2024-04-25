RXSVC    TITLE 'GENERIC C WRAPPER FOR SVC CALLS'
* ---------------------------------------------------------------------
*   WRAP ASSEMBLER CALL TO ANY SVC - TO BE CALLABLE FROM C (FOR BREXX)
*   AUTHOR  : MIKE GROSSMANN (MIG)
*   CREATED : 21.06.2019  MIG
*   JCC PROLOGUE : JUERGEN WINKELMANN, ETH ZUERICH.
* ---------------------------------------------------------------------
         PRINT GEN
* --------------------------------------------------------------------
*   RXSVC CODE: WRAP SVC CALL
* --------------------------------------------------------------------
RXSVC    MRXSTART A2PLIST=YES
         USING SVCPARAM,RB  ENABLE ADDRESSIBILTY OF C INPUT AREA
RXSVCGO  DS   0H
*
         L     RA,SVCNUM    LOAD SVC NUMBER
*
         L     R0,SVCR0     LOAD REGISTER 0
         L     R1,SVCR1     LOAD REGISTER 1
         L     R15,SVCR15   LOAD REGISTER 15
*
         EX    R10,DOSVC
*
         ST    R15,SVCR15   SAVE REGISTER 15
         ST    R1,SVCR1     SAVE REGISTER 1
         ST    R0,SVCR0     SAVE REGISTER 0
* --------------------------------------------------------------------
*   EXIT PROGRAM
* --------------------------------------------------------------------
EXIT     MRXEXIT
         LTORG
DOSVC    SVC   0
* --------------------------------------------------------------------
*    INCOMING STORAGE DEFINITION (FROM C PROGRAM)
* --------------------------------------------------------------------
*
* INPUT PARM DSECT, PROVIDED AS INPUT PARAMETER BY THE C PROGRAM
SVCPARAM DSECT               INPUT PARM DSECT
SVCNUM   DS    F             SVC NUMBER
SVCR0    DS    F             REGISTER 0
SVCR1    DS    F             REGISTER 1
SVCR15   DS    F             REGISTER 15
* --------------------------------------------------------------------
*    REGISTER DEFINITIONS
* --------------------------------------------------------------------
         COPY  MRXREGS
         END   RXSVC
