         MACRO
         SIOSTBL &TYPE=TABLE,                                          X
               &P=SIO,                                                 X
               &OFFSET=0,                                              X
               &MODE=,                                                 X
               &DSNAME=,                                               X
               &BLKSIZE=0,                                             X
               &BUFNUM=5,                                              X
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
               &PPREFIX=,                                              X
               &ACCMETH=QSAM,                                          X
               &ACTION=YES
         GBLB  &FRSTX
         GBLA  &COUNT
         LCLA  &FTYPE
         LCLA  &BLKV
         LCLA  &MODEG
         LCLC  &FIELD
         AIF   ('&TYPE' EQ 'DSECT').MODEOK
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
         AIF   ('&ACCMETH' EQ 'QSAM').ISQSAM
         AIF   ('&ACCMETH' EQ 'BSAM').ISBSAM
         MNOTE 16,'ACCMETH=&ACCMETH IS INVALID'
         MEXIT
.ISBSAM  ANOP
&MODEG   SETA  &MODEG+2                SET CORRECT MODE
.ISQSAM  ANOP
         AIF   ('&ACTION' EQ 'YES').ISACTN
&MODEG   SETA  &MODEG+1                SET CORRECT MODE
.ISACTN  ANOP
&BLKV    SETA  &BLKSIZE
         AIF   ('&BLKV' LT '32761').BLKOK
         MNOTE 16,'BLOCK SIZE=&BLKSIZE IS TOO LARGE'
         MEXIT
.BLKOK   ANOP
         AIF   (&FRSTX).DSCTX
&FRSTX   SETB  1
***********************************************************************
**                                                                   **
**                         VERSION 4.0                               **
**                                                                   **
**          SEQUENTIAL I/O OPTIMIZER TABLE DEFINITION                **
**                                                                   **
**          (C) COPYRIGHT 1987 SYSTEM CONNECTIONS, INC.              **
**                                                                   **
**                                                                   **
***********************************************************************
         SPACE 2
         AIF   ('&TYPE' EQ 'DSECT').DSCT
&P.STBLM CSECT                         TABLE START
         AGO   .GENT
.DSCT    ANOP
&P.STBLM DSECT                         TABLE START
.GENT    ANOP
         SPACE 2
&P.SID   DC    CL8'SIOSTBLM'
&P.SNE   DC    AL2(0)                  NUMBER OF DEFINITIONS
         SPACE 2
         AIF   ('&TYPE' NE 'DSECT').DSCTX
**
**       TABLE DEFINITION
**
&P.SEL   DC    AL2(0)                  DEFINITION LENGTH
&P.BLK   DC    AL2(0)                  BLOCK SIZE
&P.BUF   DC    AL1(0)                  NUMBER OF BUFFERS
&P.SF1   DC    XL1'0'                  FLAG BYTE 1
&P.SSL   EQU   X'80'                   SELECT ENTRY
&P.SEX   EQU   X'40'                   EXEMPT ENTRY
&P.SIG   EQU   X'20'                   IGNORE ENTRY
&P.SBA   EQU   X'02'                   BSAM ENTRY
&P.SAC   EQU   X'01'                   ACTION FLAG
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
**
**       TABLE DEFINITION
**
         DC    AL2(N&SYSNDX-*)
         DC    AL2(&BLKSIZE)
         DC    AL1(&BUFNUM)
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
         DC    AL1(L'B&SYSNDX-1)
         DC    AL1(&OFFSET)
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
         DC    AL1(L'D&SYSNDX-1)
         DC    AL1(&OFFSET)
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
         DC    AL1(L'F&SYSNDX-1)
         DC    AL1(&OFFSET)
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
         DC    AL1(L'H&SYSNDX-1)
         DC    AL1(&OFFSET)
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
         DC    AL1(L'J&SYSNDX-1)
         DC    AL1(&OFFSET)
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
         DC    AL1(L'L&SYSNDX-1)
         DC    AL1(&OFFSET)
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
         ORG   &P.SNE
&COUNT   SETA  &COUNT+1
         DC    AL2(&COUNT)
         ORG   ,
         SPACE 2
         MEND
