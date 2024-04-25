RXSTIME  TITLE 'RETURN TIME IN HUNDREDS OF A SECOND'
* ---------------------------------------------------------------------
*   RETURN TOD CLOCK IN MICRO SECONDS SINCE MIDNIGHT
*   AUTHOR  : PETER JACOB (PEJ)
*   CREATED : 03.11.2018  PEJ
*   JCC PROLOGUE : JUERGEN WINKELMANN, ETH ZUERICH.
* ---------------------------------------------------------------------
         PRINT GEN
* --------------------------------------------------------------------
*   RXSTIME CODE: RETURN TIME SINCE MIDNIGHT IN HUNDREDS OF A SECOND
* --------------------------------------------------------------------
RXSTIME  MRXSTART A2PLIST=YES
         USING STIMPARM,RB   ENABLE ADDRESSIBILTY OF C INPUT AREA
RXSTIMGO L     RA,WPTWKADR   LOAD WORK AREA OF INPUT PARM
         STCK  0(RA)         CURRENT TIME (BINARY
         LA    RF,0          SET RC=0
* --------------------------------------------------------------------
*   EXIT PROGRAM
* --------------------------------------------------------------------
EXIT     MRXEXIT
         LTORG
* --------------------------------------------------------------------
*    INCOMING STORAGE DEFINITION (FROM C PROGRAM)
* --------------------------------------------------------------------
*    INPUT PARM DSECT, PROVIDED AS INPUT PARAMETER BY THE C PROGRAM
STIMPARM DSECT               INPUT PARM DSECT
WPTWKADR DS    A             ADDRESS RESULT RETURNED FROM PGM
* --------------------------------------------------------------------
*    REGISTER DEFINITIONS
* --------------------------------------------------------------------
         COPY  MRXREGS
         END   RXSTIME
