         MACRO
&ML      PARSEKMD &CBUF=CPPLCBUF,&OPLIST=OPLIST,&FLAG=FLAG,            X
               &EXIT=,&PARM=,&KPPL=KPPL,                               X
               &KEYLIST=,&KEYWORK=,&BUFF=,&BUFFLEN=,                   X
               &WORK=,&OPFLG=,&UNKFLG=
         GBLC  &XPARM
         LCLC  &EXNM,&FS,&BUFF$,&BUFFL$
&XPARM   SETC  '&PARM'
         AIF   ('&UNKFLG' EQ '').SU
&EXNM    SETC  'UNKX&SYSNDX'
         AGO   .SUOK
.SU      ANOP
&EXNM    SETC  '&EXIT'
.SUOK    ANOP
*
         MNOTE '*           &&CBUF=&CBUF,&&OPLIST=&OPLIST,&&FLAG=&FLAG'
         MNOTE '*           &&EXIT=&EXNM,&&PARM=&PARM,&&KPPL=&KPPL'
         MNOTE '*           &&KEYLIST=&KEYLIST,&&KEYWORK=&KEYWORK'
         MNOTE '*           &&WORK=&WORK,&&OPFLG=&OPFLG'
*
*       FIRST BUILD KOMAND-PROCESSING PARAMETER LIST:
*
&ML      XC    &KPPL.(40),&KPPL         CLEAR BUFFER PROC PARMLIST
         AIF   ('&BUFF' EQ '').CB
&BUFF$   SETC  '&BUFF'
         AIF   ('&BUFF'(1,1) NE '(').BOK
&BUFF$   SETC  '0&BUFF'
.BOK     LA    R15,&BUFF$
         ST    R15,CBUFPTR
&BUFFL$  SETC  '&BUFFLEN'
         AIF   ('&BUFFLEN'(1,1) NE '(').BLOK
&BUFFL$  SETC  '0&BUFFLEN'
.BLOK    LA    R15,&BUFFL$
         ST    R15,BUFFLEN
         MVC   KEYWPASS,=X'FFFFFFFF'    FLAG V2 PARMLIST (12 WD KPPL)
         AGO   .SB
.CB      L     R15,&CBUF                R15 -> CBUF
         ST    R15,CBUFPTR              BUFFER PTR
.SB      LA    R15,&OPLIST              OPERAND LIST
         ST    R15,OPLSTPTR             PASS IT
         LA    R15,&FLAG                FLAG AREA
         ST    R15,FLAGPTR              PASS IT
         AIF   ('&EXNM' EQ '').SK
         LA    R15,&EXNM                EXIT FOR OPS NOT IN MY LIST
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
         AIF   ('&BUFF' EQ '').S1
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
.S5      AIF   ('&UNKFLG' EQ '').SU2
         B     B&SYSNDX
         SPACE
UNKX&SYSNDX L  R1,0(,R1)                R1->PARMAREA PASSED
&FS      SETC  '&UNKFLG-&PARM'.'(R1)'
         OI    &FS,X'FF'                SET FLAG FOR UNKN OPS
         SLR   R15,R15                  SAY OK TO CONTINUE
         BR    R14
         SPACE
.SU2     ANOP
B&SYSNDX DS    0H
         ANOP
         MEND
