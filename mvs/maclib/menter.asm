         MACRO
&NAME    MENTER  &REG,&EQU,&COM=,&CP=NO
&NAME    CSECT
         GBLC    &USE
         GBLC    &GBCP
         LCLC    &COMMENT
         LCLC    &BASE
         LCLA    &REGNO
&GBCP    SETC    '&CP'
&USE     SETC    'USE'
&COMMENT SETC    '&COM'
         AIF     ('&COMMENT' NE '').NOCOMM
&COMMENT SETC    '&NAME'
.NOCOMM  ANOP
         AIF     ('&EQU' EQ 'NOEQU').NOEQU
***********************************************************************
*                REGISTER EQUATES                                     *
***********************************************************************
*
R0       EQU     0
R1       EQU     1
R2       EQU     2
R3       EQU     3
R4       EQU     4
R5       EQU     5
R6       EQU     6
R7       EQU     7
R8       EQU     8
R9       EQU     9
R10      EQU     10
R11      EQU     11
R12      EQU     12
R13      EQU     13
R14      EQU     14
R15      EQU     15
.*
.NOEQU   ANOP
&REGNO   SETA    &REG
         AIF     (&REGNO GT 12).NOWAY
         AIF     (&REGNO LT 2).NOWAY
.*
.*       INITIALIZE BASE REGISTER TO USER SPECIFICATIONS
.*
&BASE    SETC    '&REG'
         AGO     .START
.NOWAY   ANOP
*
         MNOTE   0,'INCORRECT REGISTER SPECIFIED ...USING 12'
*
&BASE    SETC    '12'
.START   ANOP
***********************************************************************
*                SET UP THE SAVE AREA                                 *
***********************************************************************
*        SAVE    (14,12)
         DS      0H
         STM     14,12,12(13)          SAVE REGISTERS
         LR      &BASE,15              LOAD BASE REGISTER
         USING   &NAME,&BASE           TELL ASSEMBLER
         B       MENT&SYSNDX
         DC      CL8'&SYSDATE'
         DC      CL8'&SYSTIME'
         DC      CL8'&COMMENT'
MENT&SYSNDX DS 0H
         ST      13,SAVE+4             STORE OLD SAVE AREA
         LA      3,SAVE                AND PREPARE TO STORE NEW
         ST      3,8(13)               STORE IT
         LR      13,3                  AND LOAD R13
         AIF     ('&CP' EQ 'NOCP').NOPPL
         LA      R2,IOPLADS
         USING   IOPL,R2
         L       R3,0(1)
         ST      R3,CPPLCBUF
         L       R3,4(1)
         ST      R3,CPPLUPT
         ST      R3,IOPLUPT
         L       R3,8(1)
         ST      R3,CPPLPSCB
         L       R3,12(1)
         ST      R3,CPPLECT
         ST      R3,IOPLECT
         L       R3,ECBADS
         ST      R3,IOPLECB
         DROP    R2
.NOPPL   ANOP
*
*
*
         MEND
