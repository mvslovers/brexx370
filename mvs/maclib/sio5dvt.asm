         MACRO
         SIO5DVT &TYPE=TABLE,                                          X
               &P=DVT,                                                 X
               &DEVICE=,                                               X
               &BUFNUM=(NUMBER,0),                                     X
               &BLKSIZE=
         GBLB  &FIRST
         GBLA  &COUNT
         LCLA  &BLKSZ
         LCLA  &BNUMB
         LCLA  &BXTYP
         LCLC  &BTYPE
         LCLC  &DEVID
         AIF   (&FIRST).NOTFST
***********************************************************************
**                                                                   **
**                         VERSION 5.0                               **
**                                                                   **
**         SEQUENTIAL I/O OPTIMIZER DEVICE TABLE DEFINITION          **
**                                                                   **
**          (C) COPYRIGHT 1987  SYSTEM CONNECTIONS, INC.             **
**                                                                   **
**                                                                   **
***********************************************************************
         SPACE 2
.NOTFST  ANOP
         AIF   ('&TYPE' NE 'DSECT').DSCTX
SIO5DVTD DSECT                         TABLE START
         SPACE 2
         SIO5MID TYPE=NOLB,P=&P
         SPACE 2
&P.SNE   DC    H'0'                    NUMBER OF DEFINITIONS
**
**       TABLE DEFINITION
**
&P.STYP  DC    XL2'00'                 DEVICE TYPE
&P.SBLK  DC    AL2(0)                  MAX BLOCK SIZE
&P.BUTY  DC    AL1(0)                  BUFFER UNIT TYPE
&P.NBUF  EQU   X'01'                   NUMBER OF BUFFERS DEF
&P.SPAC  EQU   X'02'                   BUFFER SPACE DEFINED
&P.TRAK  EQU   X'03'                   TRACK SIZE DEF BUF #
&P.SBUF  DC    AL3(0)                  BUFFER UNIT COUNT
&P.SELL  EQU   *-&P.STYP               ENTRY LENGTH
         MEXIT
.DSCTX   ANOP
         AIF   (&FIRST).DOENTR
&FIRST   SETB  1
SIO5DVTM CSECT                         TABLE START
         SPACE 2
         SIO5MID
         SPACE 2
&P.NOD   DC    H'0'                    NUMBER OF DEFINITIONS
         SPACE 2
.DOENTR  ANOP
**
**       TABLE DEFINITION
**
&BTYPE   SETC  '&BUFNUM(1)'
         AIF   ('&BTYPE' EQ 'NUMBER').BTYPNB
         AIF   ('&BTYPE' EQ 'SPACE').BTYPSP
         AIF   ('&BTYPE' EQ 'TRACKS').BTYPTR
         MNOTE 16,'BUFFER TYPE=&BTYPE IS INVALID'
         MEXIT
.BTYPNB  ANOP
&BXTYP   SETA  1
&BNUMB   SETA  &BUFNUM(2)
         AIF   ('&BNUMB' LT '256').BTYPOK
         MNOTE 16,'BUFFER UNITS=&BNUMB IS INVALID'
         MEXIT
.BTYPSP  ANOP
&BXTYP   SETA  2
&BNUMB   SETA  &BUFNUM(2)
         AIF   ('&BNUMB' GT '7').BTYPOK
         MNOTE 16,'BUFFER UNITS=&BNUMB IS INVALID'
         MEXIT
.BTYPTR  ANOP
&BXTYP   SETA  3
&BNUMB   SETA  &BUFNUM(2)
         AIF   ('&BNUMB' LT '256').BTYPOK
         MNOTE 16,'BUFFER UNITS=&BNUMB IS INVALID'
         MEXIT
.BTYPOK  ANOP
&BLKSZ   SETA  &BLKSIZE
         AIF   ('&BLKSZ' LT '32761').BLKOKX
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
         DC    AL1(&BXTYP)
         DC    AL3(&BNUMB)
         ORG   &P.NOD
&COUNT   SETA  &COUNT+1
         DC    AL2(&COUNT)
         ORG   ,
.NOT3330 ANOP
         DC    X'&DEVID'
         DC    AL2(&BLKSIZE)
         DC    AL1(&BXTYP)
         DC    AL3(&BNUMB)
         ORG   &P.NOD
&COUNT   SETA  &COUNT+1
         DC    AL2(&COUNT)
         ORG   ,
         SPACE 2
         MEND
