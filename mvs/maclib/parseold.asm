         MACRO
&ML      PARSEKMD &CBUF=CPPLCBUF,&OPLIST=OPLIST,&FLAG=FLAG,            X
               &EXIT=,&PARM=,                                          X
               &KEYLIST=,&KEYWORK=,                                    X
               &WORK=,&OPFLG=
         GBLC  &XPARM
&XPARM   SETC  '&PARM'
*
         MNOTE '*           &&CBUF=&CBUF,&&OPLIST=&OPLIST,&&FLAG=&FLAG'
         MNOTE '*           &&EXIT=&EXIT,&&PARM=&PARM'
         MNOTE '*           &&KEYLIST=&KEYLIST,&&KEYWORK=&KEYWORK'
         MNOTE '*           &&WORK=&WORK,&&OPFLG=&OPFLG'
*
*       FIRST BUILD KOMAND-PROCESSING PARAMETER LIST:
*
&ML      XC    KPPL(40),KPPL            CLEAR BUFFER PROC PARMLIST
         L     R15,&CBUF                R15 -> CBUF
         ST    R15,CBUFPTR              BUFFER PTR
         LA    R15,&OPLIST              OPERAND LIST
         ST    R15,OPLSTPTR             PASS IT
         LA    R15,&FLAG                FLAG AREA
         ST    R15,FLAGPTR              PASS IT
         AIF   ('&EXIT' EQ '').SK
         LA    R15,&EXIT                EXIT FOR OPS NOT IN MY LIST
         AIF   ('&KEYLIST' EQ '').S1A
         ST    R15,REEXPASS             PASS IT
         AGO   .SK
.S1A     ST    R15,UNKNEXIT             PASS IT
.SK      AIF   ('&KEYLIST' EQ '').S1B
         LA    R15,&KEYLIST       LIST OF KEYWORDS
         ST    R15,KEYLPASS       PASS IT
         L     R15,=V(KEYEX)      KEYWORD EXIT
         ST    R15,UNKNEXIT       PASS IT
.S1B     AIF   ('&KEYWORK' EQ '').S1
         LA    R15,&KEYWORK       SAVEAREA AND FLAGAREA FOR KEYWD EXIT
         ST    R15,KEYWPASS       PASS IT
.S1      AIF   ('&PARM' EQ '').S2
         LA    R15,&PARM                WORK AREA FOR EXIT
         ST    R15,EXITPARM             PASS IT TO THE EXIT
.S2      AIF   ('&WORK' EQ '').S3
         LA    R15,&WORK                WORK AREA FOR KMDPARS
         ST    R15,WORKPASS             LENGTH PTR RETURN AREA
.S3      AIF   ('&OPFLG' EQ '').S4
         XC    &OPFLG(1),&OPFLG         CLEAR OPERANDS PRESENT FLAG
.S4      ANOP
*
*       THEN CALL KMDPARS (PARSE SUBROUTINE):
*
         LA    R1,KPPL                  R1 -> BUFFER PROC PARMLIST
         CALL  KMDPARS                  PROCESS AN OPERAND
         AIF   ('&OPFLG' EQ '').S5
         LTR   R15,R15                  ANYTHING FOUND?
         BNZ   B&SYSNDX                 YES
         OI    &OPFLG,X'FF'
B&SYSNDX DS    0H
.S5      ANOP
         MEND
