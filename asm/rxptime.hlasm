RXPTIME  TITLE 'RETURN TIME IN HUNDREDS OF A SECOND'
* ---------------------------------------------------------------------
*   RETURN CURRENT TIME, CALLED FROM C (FOR BREXX)
*     FORMAT HH:MM:SS:HS  HS IS HUNDREDS OF A SECOND
*   AUTHOR  : PETER JACOB (PEJ)
*   CREATED : 03.11.2018  PEJ
*   JCC PROLOGUE : JUERGEN WINKELMANN, ETH ZUERICH.
* ---------------------------------------------------------------------
         PRINT GEN
* --------------------------------------------------------------------
*   RXPTIME CODE: RETURN CURRENT TIME IN HH:MM:SS:HS
* --------------------------------------------------------------------
RXPTIME  MRXSTART A2PLIST=YES
         USING PTIMPARM,RB   ENABLE ADDRESSIBILTY OF C INPUT AREA
RXPTIMGO L     RA,WPTWKADR   LOAD WORK AREA OF INPUT PARM
         USING PTIMECB,RA    ENABLE ADDRESSIBILTY OF C INPUT AREA
         TIME  DEC           CURRENT TIME IN DECIMAL
         ST    R0,FTIME      SAVE TIME
         MVI   RSIGN,X'0F'   SET + SIGN
         UNPK  UNPKFLD,RTIME UNPACK FIELD
         L     RE,WPTMADR    LOAD ADDRESS OF OUTPUT FIELD
         MVC   0(2,RE),UNPKFLD+7  SAVE HOURS
         MVI   2(RE),C':'         ADD SEPARATOR ':'
         MVC   3(2,RE),UNPKFLD+9  SAVE MINUTES
         MVI   5(RE),C':'         ADD SEPARATOR ':'
         MVC   6(2,RE),UNPKFLD+11 SAVE SECONDS
         MVI   8(RE),C'.'         ADD SEPARATOR '.'
         MVC   9(2,RE),UNPKFLD+13 SAVE HUNDREDS OF A SECOND
         L     R1,WPTLADR         LOAD ADDRESS OF LENGTH
         LA    R2,11              LENGTH IS 11
         ST    R2,0(R1)           SAVE IT
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
PTIMPARM DSECT               INPUT PARM DSECT
WPTMADR  DS    A             ADDRESS RESULT RETURNED FROM PGM
WPTLADR  DS    A             ADDRESS OF RETURNED LENGTH
WPTRCADR DS    A             ADDRESS OF  RC
WPTWKADR DS    A             ADDRESS OF  WORKAREA ALLOCATED IN CPROGRAM
*
PTIMECB  DSECT               INPUT PARM DSECT
UNPKFLD  DS    CL16          UNPK FIELD
RTIME    DS    0CL5         +RAW DATE/TIME FROM TIME MACRO
FTIME    DS    F            +- DECIMAL VALUE
RSIGN    DC    X'0F'        +- SIGN OF DECIMAL RESULT OF TIME
* --------------------------------------------------------------------
*    REGISTER DEFINITIONS
* --------------------------------------------------------------------
         COPY  MRXREGS
         END   RXPTIME
