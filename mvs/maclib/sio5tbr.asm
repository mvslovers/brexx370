         MACRO
         SIO5TBR &TYPE=TABLE,                                          X
               &P=REL,                                                 X
               &OFFSET=0,                                              X
               &MODE=,                                                 X
               &DSNAME=,                                               X
               &PREFIX=,                                               X
               &DDNAME=,                                               X
               &DPREFIX=,                                              X
               &JOB=,                                                  X
               &JPREFIX=,                                              X
               &VOLSER=,                                               X
               &VPREFIX=,                                              X
               &STEP=,                                                 X
               &SPREFIX=,                                              X
               &DEVADDR=,                                              X
               &PROGRAM=,                                              X
               &PPREFIX=
         GBLB  &FRSTX
         GBLA  &COUNT
         LCLA  &FTYPE
         LCLA  &MODEG
         LCLA  &AOFST
         LCLC  &FIELD
         LCLC  &ATEXT
         AIF   ('&TYPE' EQ 'DSECT').GENTBL
         AIF   ('&MODE' NE '').MODEF
         MNOTE 16,'MODE PARAMETER IS MISSING'
         MEXIT
.MODEF   ANOP
&MODEG   SETA  128                     ASSUME SELECT
         AIF   ('&MODE' EQ 'SELECT').MODEOK
&MODEG   SETA  64                      ASSUME EXEMPT
         AIF   ('&MODE' EQ 'EXEMPT').MODEOK
&MODEG   SETA  32                      ASSUME EXEMPT
         AIF   ('&MODE' EQ 'BYPASS').MODEOK
         MNOTE 16,'MODE=&MODE IS INVALID'
         MEXIT
.MODEOK  ANOP
.GENTBL  ANOP
         AIF   (&FRSTX).DOTBL
***********************************************************************
**                                                                   **
**                         VERSION 5.0                               **
**                                                                   **
**          SEQUENTIAL I/O OPTIMIZER TABLE DEFINITION                **
**                                                                   **
**          (C) COPYRIGHT 1987 SYSTEM CONNECTIONS, INC.              **
**                                                                   **
**                                                                   **
***********************************************************************
         SPACE 2
         AIF   ('&TYPE' NE 'DSECT').DSCTX
&P.5RELD DSECT                         TABLE START
         SPACE 2
         SIO5MID TYPE=NOLB,P=&P
         SPACE 2
&P.SNE   DC    AL2(0)                  NUMBER OF DEFINITIONS
         SPACE 2
**
**       TABLE DEFINITION
**
&P.SEL   DC    AL2(0)                  DEFINITION LENGTH
**
&P.SF1   DC    XL1'0'                  FLAG BYTE 1
&P.SSL   EQU   X'80'                   SELECT ENTRY
&P.SEX   EQU   X'40'                   EXEMPT ENTRY
&P.SIG   EQU   X'20'                   BYPASS ENTRY
**
&P.STL   DC    AL1(0)                  DATA LENGTH
&P.STO   DC    AL1(0)                  DATA OFFSET
&P.SF2   DC    XL1'0'                  FLAG BYTE 2
&P.SNM   EQU   X'01'                   DSNAME FIELD
&P.SNP   EQU   X'02'                   DSNAME PREFIX
&P.SDM   EQU   X'03'                   DDNAME FIELD
&P.SDP   EQU   X'04'                   DDNAME PREFIX
&P.SJM   EQU   X'05'                   JOB NAME FIELD
&P.SJP   EQU   X'06'                   JOB NAME PREFIX
&P.SSM   EQU   X'07'                   STEP NAME FIELD
&P.SSP   EQU   X'08'                   STEP NAME PREFIX
&P.SVM   EQU   X'09'                   VOLUME SERIAL
&P.SVP   EQU   X'0A'                   VOLUME SERIAL PREFIX
&P.SPM   EQU   X'0B'                   PROGRAM NAME
&P.SPP   EQU   X'0C'                   PROGRAM NAME PREFIX
&P.SDV   EQU   X'0D'                   DEVICE DEVADDR
&P.SDT   EQU   *                       START OF DATA
         MEXIT
.DSCTX   ANOP
&FRSTX   SETB  1
SIO5RLTM CSECT                         TABLE START
         SPACE 2
         SIO5MID
         SPACE 2
&P.SND   DC    AL2(0)                  NUMBER OF DEFINITIONS
.DOTBL   ANOP
         SPACE 2
**
**       TABLE DEFINITION
**
         DC    AL2(N&SYSNDX-*)
         DC    AL1(&MODEG)
         AIF   ('&DSNAME' EQ '').NODSN
&FIELD   SETC  '&DSNAME'
&FTYPE   SETA  1
         DC    AL1(L'A&SYSNDX-1)
         DC    AL1(0)
         DC    AL1(&FTYPE)
A&SYSNDX DC    CL44'&FIELD'
.NODSN   ANOP
         AIF   ('&PREFIX' EQ '').NOPFX
&FIELD   SETC  '&PREFIX'
&FTYPE   SETA  2
&AOFST   SETA  &OFFSET
         AIF   ('&FIELD'(1,1) NE '(').SFIELD1
&FIELD   SETC  '&PREFIX(1)'
&AOFST   SETA  &PREFIX(2)
.SFIELD1 ANOP
         DC    AL1(L'B&SYSNDX-1)
         DC    AL1(&AOFST)
         DC    AL1(&FTYPE)
B&SYSNDX DC    C'&FIELD'
.NOPFX   ANOP
         AIF   ('&DDNAME' EQ '').NODD
&FIELD   SETC  '&DDNAME'
&FTYPE   SETA  3
         DC    AL1(L'C&SYSNDX-1)
         DC    AL1(0)
         DC    AL1(&FTYPE)
C&SYSNDX DC    CL8'&FIELD'
.NODD    ANOP
         AIF   ('&DPREFIX' EQ '').NODDPX
&FIELD   SETC  '&DPREFIX'
&FTYPE   SETA  4
&AOFST   SETA  &OFFSET
         AIF   ('&FIELD'(1,1) NE '(').SFIELD2
&FIELD   SETC  '&DPREFIX(1)'
&AOFST   SETA  &DPREFIX(2)
.SFIELD2 ANOP
         DC    AL1(L'D&SYSNDX-1)
         DC    AL1(&AOFST)
         DC    AL1(&FTYPE)
D&SYSNDX DC    C'&FIELD'
.NODDPX  ANOP
         AIF   ('&JOB' EQ '').NOJOB
&FIELD   SETC  '&JOB'
&FTYPE   SETA  5
         DC    AL1(L'E&SYSNDX-1)
         DC    AL1(0)
         DC    AL1(&FTYPE)
E&SYSNDX DC    CL8'&FIELD'
.NOJOB   ANOP
         AIF   ('&JPREFIX' EQ '').NOJPX
&FIELD   SETC  '&JPREFIX'
&FTYPE   SETA  6
&AOFST   SETA  &OFFSET
         AIF   ('&FIELD'(1,1) NE '(').SFIELD3
&FIELD   SETC  '&JPREFIX(1)'
&AOFST   SETA  &JPREFIX(2)
.SFIELD3 ANOP
         DC    AL1(L'F&SYSNDX-1)
         DC    AL1(&AOFST)
         DC    AL1(&FTYPE)
F&SYSNDX DC    C'&FIELD'
.NOJPX   ANOP
         AIF   ('&STEP' EQ '').NOSTEP
&FIELD   SETC  '&STEP'
&FTYPE   SETA  7
         DC    AL1(L'G&SYSNDX-1)
         DC    AL1(0)
         DC    AL1(&FTYPE)
G&SYSNDX DC    CL8'&FIELD'
.NOSTEP  ANOP
         AIF   ('&SPREFIX' EQ '').NOSTEPX
&FIELD   SETC  '&SPREFIX'
&FTYPE   SETA  8
&AOFST   SETA  &OFFSET
         AIF   ('&FIELD'(1,1) NE '(').SFIELD4
&FIELD   SETC  '&SPREFIX(1)'
&AOFST   SETA  &SPREFIX(2)
.SFIELD4 ANOP
         DC    AL1(L'H&SYSNDX-1)
         DC    AL1(&AOFST)
         DC    AL1(&FTYPE)
H&SYSNDX DC    C'&FIELD'
.NOSTEPX ANOP
         AIF   ('&VOLSER' EQ '').NOVSN
&FIELD   SETC  '&VOLSER'
&FTYPE   SETA  9
         DC    AL1(L'I&SYSNDX-1)
         DC    AL1(0)
         DC    AL1(&FTYPE)
I&SYSNDX DC    CL6'&FIELD'
.NOVSN   ANOP
         AIF   ('&VPREFIX' EQ '').NOVSNP
&FIELD   SETC  '&VPREFIX'
&FTYPE   SETA  10
&AOFST   SETA  &OFFSET
         AIF   ('&FIELD'(1,1) NE '(').SFIELD5
&FIELD   SETC  '&VPREFIX(1)'
&AOFST   SETA  &VPREFIX(2)
.SFIELD5 ANOP
         DC    AL1(L'J&SYSNDX-1)
         DC    AL1(&AOFST)
         DC    AL1(&FTYPE)
J&SYSNDX DC    C'&FIELD'
.NOVSNP  ANOP
         AIF   ('&PROGRAM' EQ '').NOPGM
&FIELD   SETC  '&PROGRAM'
&FTYPE   SETA  11
         DC    AL1(L'K&SYSNDX-1)
         DC    AL1(0)
         DC    AL1(&FTYPE)
K&SYSNDX DC    CL8'&FIELD'
.NOPGM   ANOP
         AIF   ('&PPREFIX' EQ '').NOPGMX
&FIELD   SETC  '&PPREFIX'
&FTYPE   SETA  12
&AOFST   SETA  &OFFSET
         AIF   ('&FIELD'(1,1) NE '(').SFIELD6
&FIELD   SETC  '&PPREFIX(1)'
&AOFST   SETA  &PPREFIX(2)
.SFIELD6 ANOP
         DC    AL1(L'L&SYSNDX-1)
         DC    AL1(&AOFST)
         DC    AL1(&FTYPE)
L&SYSNDX DC    C'&FIELD'
.NOPGMX  ANOP
         AIF   ('&DEVADDR' EQ '').NOUNIT
&FIELD   SETC  '&DEVADDR'
&FTYPE   SETA  13
         DC    AL1(L'M&SYSNDX-1)
         DC    AL1(0)
         DC    AL1(&FTYPE)
M&SYSNDX DC    CL3'&FIELD'
.NOUNIT  ANOP
N&SYSNDX EQU   *
         ORG   &P.SND
&COUNT   SETA  &COUNT+1
         DC    AL2(&COUNT)
         ORG   ,
         SPACE 2
         MEND
