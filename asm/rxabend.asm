RXABEND  TITLE 'CREATE ABEND WITH COMPLETION CODE'                      00000100
* --------------------------------------------------------------------- 00000200
*   CREATE ABEND WITH GIVEN COMPLETION CODE, CALLED FROM C (FOR BREXX)  00000300
*   AUTHOR  : MIKE GROSSMANN (MIG)                                      00000400
*   CREATED : 06.12.2018  MIG                                           00000500
*   JCC PROLOGUE : JUERGEN WINKELMANN, ETH ZUERICH.                     00000600
* --------------------------------------------------------------------- 00000700
         PRINT GEN                                                      00000800
* --------------------------------------------------------------------  00000900
*   RXABEND CODE: CREATE ABEND WITH GIVEN COMPLETION CODE               00001000
* --------------------------------------------------------------------  00001100
RXABEND  MRXSTART A2PLIST=YES                                           00001200
         USING ABNDPARM,RB  ENABLE ADDRESSIBILTY OF C INPUT AREA        00001301
RXABNDGO DS   0H                                                        00001401
* ... PICK UP COMPLETION CODE                                           00001500
         L     RF,ABENDCC   LOAD COMPLETION CODE                        00001600
         ABEND (RF)                                                     00001700
* --------------------------------------------------------------------  00001800
*   EXIT PROGRAM                                                        00001900
* --------------------------------------------------------------------  00002000
EXIT     MRXEXIT                                                        00002100
         LTORG                                                          00002200
* --------------------------------------------------------------------  00002300
*    INCOMING STORAGE DEFINITION (FROM C PROGRAM)                       00002400
* --------------------------------------------------------------------  00002500
*                                                                       00002600
* INPUT PARM DSECT, PROVIDED AS INPUT PARAMETER BY THE C PROGRAM        00002700
ABNDPARM DSECT              INPUT PARM DSECT                            00002801
ABENDCC  DS    A             COMPLETION CODE                            00002900
* --------------------------------------------------------------------  00003000
*    REGISTER DEFINITIONS                                               00003100
* --------------------------------------------------------------------  00003200
         COPY  MRXREGS                                                  00003300
         END   RXABEND                                                  00003400
