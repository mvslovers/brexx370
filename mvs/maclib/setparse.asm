         MACRO
         SETPARSE &PCL=,&ECB=MYECB,&ANS=MYANS
         GBLC  &SETBEF
         GBLC  &USE
         AIF   ('&USE' EQ '').ERROR
         MVC   PPLUPT(4),CPPLUPT       MOVE IN UPT
         MVC   PPLCBUF(4),CPPLCBUF     MOVE IN CBUF/
         MVC   PPLECT(4),CPPLECT       MOVE IN ECT
         L     R1,=V(&PCL)             GET ADDRESS OF PARM CONTROL
         ST    R1,PPLPCL               MOVE IT IN
         LA    R1,&ECB                 GET ADDRESS OF AN ECB
         ST    R1,PPLECB               MOVE IT IN
         XC    PPLUWA(4),PPLUWA        ZERO OUT THE WORK AREA
         LA    R1,&ANS                 GET ADDRESS OF AN ANSWER
*                                      PLACE
         ST    R1,PPLANS
         LA    R1,PPL                  FINALLY, LOAD R1 WITH A(PPL)
         AIF   ('&SETBEF' EQ 'SET').NOSYM
&SETBEF   SETC  'SET'
         B     SETP&SYSNDX
MYECB    DC    F'0'
MYANS    DC    F'0'
PPL      DS    0D                       START OF PARM CONTROL LIST
PPLUPT   DS    A
PPLECT   DS    A
PPLECB   DS    A
PPLPCL   DS    A
PPLANS   DS    A
PPLCBUF  DS    A
PPLUWA   DS    A
SETP&SYSNDX DS  0H
.NOSYM   ANOP
         MEND
.ERROR   ANOP
         MNOTE  12,'ERROR, MENTER MACRO MUST BE USED PREVIOSLY'
         MEND
