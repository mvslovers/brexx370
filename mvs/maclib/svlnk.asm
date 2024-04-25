         MACRO
&NAME    SVLNK &REG1,&REG2,&REG3,&IND,&LV=
         GBLC  &EQU
         GBLC  &GM
         GBLC  &CSECT
         LCLC  &REGA
         AIF   (T'&NAME EQ 'O').NOCSECT
         AIF   ('&NAME' EQ '*').NOCSECT
&CSECT   SETC  '&NAME'
&CSECT   CSECT                         NAME OF PROGRAM
         AGO   .RST
.NOCSECT ANOP
&CSECT   SETC  '*'
         CSECT                         BEGINNING OF PROGRAM
.RST     ANOP
         AIF   ('&EQU' EQ 'ON').NRQ
&EQU     SETC  'ON'
*
***REGISTER EQUATES***
*
R0       EQU   0
R1       EQU   1
R2       EQU   2
R3       EQU   3
R4       EQU   4
R5       EQU   5
R6       EQU   6
R7       EQU   7
R8       EQU   8
R9       EQU   9
R10      EQU   10
R11      EQU   11
R12      EQU   12
R13      EQU   13
R14      EQU   14
R15      EQU   15
.NRQ     ANOP
*
*******************  PROGRAM INITIALIZATION  *************************
*
         AIF   (T'&REG1 EQ 'O').NOREG
&REGA    SETC  '&REG1'
         AIF   (T'&REG2 EQ 'O').ONEREG
         USING &CSECT,&REGA,&REG2          ESTABLISH ADDRESSABILITY
         AGO   .BYUSE
.NOREG   ANOP
&REGA    SETC  'R3'
.ONEREG  USING &CSECT,&REGA              ESTABLISH ADDRESSABILITY
.BYUSE   ANOP
         STM   R14,R12,12(R13) :       STORE REGS IN HIGH SAVE AREA
         LR    &REGA,R15                  INITIALIZE BASE REG
         AIF   (T'&REG2 EQ 'O').NOLA
         LA    &REG2,4095(&REGA)       INITIALIZE THE SECOND
         LA    &REG2,1(&REG2)                BASE REGISTER
.NOLA    ANOP
         AIF   (T'&REG3 EQ 'O').NOLNK
         L     &REG3,0(R1)                GET PARAMETER LIST ADDR
.NOLNK   ANOP
         AIF (T'&IND EQ 'O').GETIT
         CNOP  0,4
         BAL   R15,SAVEAREA+72         BRANCH AROUND SAVE AREA
SAVEAREA DS    18F                     REGISTER SAVE AREA
         ST    R15,8(R13)
         ST    R13,SAVEAREA+4
         LR    R13,R15
         AGO   .NOSAVE
.GETIT   ANOP
         AIF   (T'&LV EQ 'O').GMD
&GM      SETC  '&LV'
         AGO   .DGM
.GMD     ANOP
&GM      SETC  '72'
.DGM     ANOP
*
***GET MAIN STORAGE FOR SAVE AREA***
*
         AIF   ('&GM' LT '4096').LA
         GETMAIN R,LV=&GM              GET CORE FOR SAVE AREA
         AGO   .EGM
.LA      ANOP
         LA    R0,&GM                  GET &GM BYTES
         GETMAIN R,LV=(0)
.EGM     ANOP
*
***SET UP SAVE AREA POINTERS***
*
         ST    R1,8(R13)               STORE LOW SAVE POINTER
         ST    R13,4(R1)               STORE HIGH SAVE POINTER
         LR    R13,R1                  INITIALIZE SAVE POINTER
         AIF   (T'&REG3  NE 'O').NOSAVE
         L     R1,4(R13)               GET POINTER TO RESTORE PARA REG
         L     R1,24(R1)               RESTORE PARAMETER REGISTER
.NOSAVE  ANOP
         AIF   ('&CSECT' EQ '*').EXIT
         B     *+12
         DC    CL8'&CSECT'             END INITIAL., BEGIN THIS PROG.
.EXIT    ANOP
*
*********************  END INITIALIZATION  ***************************
*
         MEND
