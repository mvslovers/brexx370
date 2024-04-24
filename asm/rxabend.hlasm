RXABEND  TITLE 'CREATE ABEND WITH COMPLETION CODE'
* ---------------------------------------------------------------------
*   CREATE ABEND WITH GIVEN COMPLETION CODE, CALLED FROM C (FOR BREXX)
*   AUTHOR  : MIKE GROSSMANN (MIG)
*   CREATED : 06.12.2018  MIG
*   JCC PROLOGUE : JUERGEN WINKELMANN, ETH ZUERICH.
* ---------------------------------------------------------------------
         PRINT GEN
* --------------------------------------------------------------------
*   RXABEND CODE: CREATE ABEND WITH GIVEN COMPLETION CODE
* --------------------------------------------------------------------
RXABEND  MRXSTART A2PLIST=YES
         USING ABNDPARM,RB  ENABLE ADDRESSIBILTY OF C INPUT AREA
RXABNDGO DS   0H
* ... PICK UP COMPLETION CODE
         L     RF,ABENDCC   LOAD COMPLETION CODE
         ABEND (RF)
* --------------------------------------------------------------------
*   EXIT PROGRAM
* --------------------------------------------------------------------
EXIT     MRXEXIT
         LTORG
* --------------------------------------------------------------------
*    INCOMING STORAGE DEFINITION (FROM C PROGRAM)
* --------------------------------------------------------------------
*
* INPUT PARM DSECT, PROVIDED AS INPUT PARAMETER BY THE C PROGRAM
ABNDPARM DSECT              INPUT PARM DSECT
ABENDCC  DS    A             COMPLETION CODE
* --------------------------------------------------------------------
*    REGISTER DEFINITIONS
* --------------------------------------------------------------------
         COPY  MRXREGS
         END   RXABEND
