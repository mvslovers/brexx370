         MACRO
         SIOSDVT &TYPE=TABLE,                                          X
               &P=DVT,                                                 X
               &DEVICE=,                                               X
               &BUFNUM=5,                                              X
               &BLKSIZE=
         GBLB  &FRST
         GBLA  &COUNT
         LCLA  &FTYPE
         LCLA  &BLKX
         LCLC  &DEVID
         AIF   (&FRST).DSCTX
&FRST    SETB  1
***********************************************************************
**                                                                   **
**                         VERSION 4.0                               **
**                                                                   **
**         SEQUENTIAL I/O OPTIMIZER DEVICE TABLE DEFINITION          **
**                                                                   **
**          (C) COPYRIGHT 1987  SYSTEM CONNECTIONS, INC.             **
**                                                                   **
**                                                                   **
***********************************************************************
         SPACE 2
         AIF   ('&TYPE' EQ 'DSECT').DSCT
SIOSDVTM CSECT                         TABLE START
         AGO   .GENT
.DSCT    ANOP
SIOSDVTM DSECT                         TABLE START
.GENT    ANOP
         SPACE 2
&P.SID   DC    CL8'SIOSDVTM'
&P.SNE   DC    H'0'                    NUMBER OF DEFINITIONS
         SPACE 2
         AIF   ('&TYPE' NE 'DSECT').DSCTX
**
**       TABLE DEFINITION
**
&P.STYP  DC    H'0'                    DEVICE TYPE
&P.SBLK  DC    H'0'                    BLOCK SIZE
&P.SBUF  DC    H'0'                    NUMBER OF BUFFERS
&P.SELL  EQU   *-&P.STYP               ENTRY LENGTH
         MEXIT
.DSCTX   ANOP
**
**       TABLE DEFINITION
**
&BLKX    SETA  &BLKSIZE
         AIF   ('&BLKX' LT '32761').BLKOKX
         MNOTE 16,'BLOCK SIZE=&BLKSIZE IS TOO LARGE'
         MEXIT
.BLKOKX  ANOP
&DEVID   SETC  '2009'
         AIF   ('&DEVICE' EQ '3330').DEVOK
&DEVID   SETC  '200A'
         AIF   ('&DEVICE' EQ '3340').DEVOK
&DEVID   SETC  '200B'
         AIF   ('&DEVICE' EQ '3350').DEVOK
&DEVID   SETC  '200C'
         AIF   ('&DEVICE' EQ '3375').DEVOK
&DEVID   SETC  '200E'
         AIF   ('&DEVICE' EQ '3380').DEVOK
&DEVID   SETC  '8003'
         AIF   ('&DEVICE' EQ '3420').DEVOK
&DEVID   SETC  '8080'
         AIF   ('&DEVICE' EQ '3480').DEVOK
         MNOTE 16,'INCORRECT DEVICE TYPE'
         MEXIT
.DEVOK   ANOP
         AIF   ('&DEVICE' NE '3330').NOT3330
         DC    X'200D'
         DC    AL2(&BLKSIZE)
         DC    AL2(&BUFNUM)
         ORG   &P.SNE
&COUNT   SETA  &COUNT+1
         DC    AL2(&COUNT)
         ORG   ,
.NOT3330 ANOP
         DC    X'&DEVID'
         DC    AL2(&BLKSIZE)
         DC    AL2(&BUFNUM)
         ORG   &P.SNE
&COUNT   SETA  &COUNT+1
         DC    AL2(&COUNT)
         ORG   ,
         SPACE 2
         MEND
