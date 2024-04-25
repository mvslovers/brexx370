         MACRO
&LAB     KKPARSE &CPPL=R11,&ANS=ANS,&ECB=ECB,&PCL=PCL,&PPLA=PPLA
         MNOTE 'CPPL=&CPPL,ANS=&ANS,ECB=&ECB,PCL=&PCL,PPLA=&PPLA'
*                  DEFAULT OPERANDS :
*        KKPARSE &CPPL=R11,&ANS=ANS,&ECB=ECB,&PCL=PCL,&PPLA=PPLA
*                            CPPL IS THE REGISTER CONTAINING THE
*                                 POINTER TO THE COMMAND PROCESSOR
*                                 PARAMETER LIST.
*                            ANS  IS A FULLWORD WHERE PARSE RETURNS
*                                 THE POINTER TO HIS ANSWER (IKJPARMD).
*                            ECB  IS A FULLWORD.
*                            PCL  IS THE NAME OF THE PARSE CONTROL
*                                 LIST CSECT (IKJPARM).
*                            PPLA IS A 7 FULLWORD AREA USED FOR
*                                 THE PARSE PARAMETER LIST.
*
*        KKPARSE             USES REGS R14,R15,R1,&CPPL REG
*
         USING CPPL,&CPPL         POINTS TO CPPL (PARM LIST)
*
&LAB     LA    R1,&PPLA           R1->PPL AREA
         USING PPL,R1             TELL ASSEMBLER POINTS TO PPL AREA
*
*                         CONSTRUCT PARSE PARAMETER LIST
*                                           FOR IKJPARS :
*
         MVC   PPLUPT,CPPLUPT     UPT
         MVC   PPLECT,CPPLECT     ECT
         LA    R15,&ECB           ECB
         ST    R15,PPLECB
         L     R15,=V(&PCL.)      PCL
         ST    R15,PPLPCL
         LA    R15,&ANS           ANS
         ST    R15,PPLANS
         MVC   PPLCBUF,CPPLCBUF   CBUF
         XC    PPLUWA,PPLUWA
*
         DROP  R1
         EJECT
*        CALLTSSR EP=IKJPARS      CALL PARSE:
         CALLTSSR EP=IKJPARS      CALL PARSE:
         EJECT
*
*                        DSECTS NEEDED BY PARSE:
*
*CPPL    IKJCPPL
CPPL     IKJCPPL
*PPL     IKJPPL
PPL      IKJPPL
*
CVTMAP   DSECT
         ORG   CVTMAP+524
CVTPARS  DS    F
CVTPTR   EQU   16
*
*
&SYSECT  CSECT
         MEND
