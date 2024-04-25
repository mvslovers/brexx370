         MACRO
&NAME    PRIME &REG,&SAVE,&CONS,&NTER,&EQU
.* THIS IS THE PRIME MACRO
.* ITS FUNCTION IS
.* 1.  ESTABLISH ADDRESSABILITY SAVE REGISTERS ACT AS ENTRY
.* 2.  GENERATE REG SAVE AREA OR DO GETMAIN
.* 3.  PROVIDE EXIT USED BY TERME MACRO
.* 4.  PROVIDE ADDIT SAVE AREAS FOR SUBROUTINES SO ONLY 1 BAL REG
         GBLA  &PERFD,&PERFL
         GBLC  &PERFR,&LAB,&SNTRY
         GBLB  &EQFLG,&PRIM
         LCLB  &REENT
         LCLA  &CNT,&LOOP,&INC
         LCLC  &BASE(3),&SCSECT,&PNAME
         AIF   (&PRIM).DUMB
&PRIM    SETB  1
&LAB     SETC  'ICC'.'&SYSNDX'
&SNTRY   SETC  '&LAB'.'A'
&SCSECT  SETC  '&SYSECT'
         AIF   (T'&NAME EQ 'O').CSCT0
         AIF   ('&SCSECT' NE '').CSCT1
&NAME    CSECT
&SCSECT  SETC  '&NAME'
         AGO   .CSCT0
.DUMB    MNOTE 8,'ONLY ONE PRIME MAY BE DEFINED'
         MEXIT
.CSCT1   MNOTE 'A CSECT IS ALREADY DEFINED.'
&PNAME   SETC  '&NAME'
.CSCT0   ANOP
         USING &SCSECT,R15
.*        AIF   ('&EQU' EQ '').A1
***********************************************************************
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
***********************************************************************
.A1      AIF   ('&CONS' EQ '').A2
&PNAME   SAVE  (14,12),,&CONS.-&SYSDATE.-&SYSTIME
         AGO   .A3
.A2      ANOP
&PNAME   SAVE  (14,12),,&SCSECT.-&SYSDATE.-&SYSTIME
.A3       ANOP
         LA    14,&LAB
         ST    14,&SNTRY
         B     &SNTRY+4
         AIF   ('&SAVE' NE '').A4
&REENT   SETB  1
.A4      AIF   ('&REG' EQ '').A6
         AIF   (N'&REG GT 3).BAD3
         AIF   (N'&REG LT 2).B1
&CNT     SETA  N'&REG
&LOOP    SETA  1
&INC     SETA  &LOOP+1
.A5      AIF   (T'&REG(&LOOP) NE 'N').BAD1
&BASE(&LOOP) SETC '&REG'(&INC,K'&REG(&LOOP))
&INC     SETA  &INC+K'&REG(&LOOP)+1
&LOOP    SETA  &LOOP+1
         AIF   (&LOOP LE &CNT).A5
         AGO   .A7
.B1      ANOP
&BASE(1) SETC  '&REG'
         AGO   .B2
.A6      ANOP
&BASE(1) SETC  '12'
.B2      ANOP
&CNT     SETA  1
.A7      ANOP
&SNTRY   DS    F
          DROP 15
         AIF   (&CNT NE 3).A8
         LA    &BASE(3),2048                     ESTABLISH ADDRESSAB
         LA    &BASE(2),2048(&BASE(3),15)        WITH THREE
         LA    &BASE(3),2048(&BASE(3),&BASE(2))  BASE REGS
         LR    &BASE(1),15
         USING &SCSECT,&BASE(1),&BASE(2),&BASE(3)
         AGO   .A10
.A8      AIF   (&CNT NE 2).A9
         LA    &BASE(2),2048                     ESTABLISH ADRESSAB
         LA    &BASE(2),2048(&BASE(2),15)        WITH TWO
         LR    &BASE(1),15                       BASE REGS
         USING &SCSECT,&BASE(1),&BASE(2)
         AGO   .A10
.A9      AIF   (&CNT NE 1).BAD4
         LR    &BASE(1),15                       ESTABLISH ADRESSAB
         USING &SCSECT,&BASE(1)
.A10     AIF   (&REENT).A11
         LA    15,&SAVE
         AGO   .A14
.A11     AIF   ('&NTER' NE '').A12
&PERFL   SETA  0
&CNT     SETA  72
         AGO   .A13
.A12     AIF   (T'&NTER NE 'N').BAD5
&PERFL   SETA  &NTER
&PERFR   SETC  '14'
&PERFD   SETA  0
&CNT     SETA  72+&NTER*4
* GENERATED SAVE AREA EXTENDED FOR USE BY NTER AND XIT MACROS
.A13     ANOP
         GETMAIN R,LV=&CNT
         LR    15,1
.A14     ANOP
         LM    0,1,20(13)
         ST    13,4(15)                          CHAIN THE
         ST    15,8(13)                          SAVE AREAS
         LR    13,15
         L     15,&SNTRY
          BR   15
         AIF   (&REENT).A20
&LAB.X   L     13,4(13)
         AGO   .A21
.A20     ANOP
&LAB.X   LR    1,13
         L     13,4(13)
         LR    11,15
         FREEMAIN R,LV=&CNT,A=(1)
         LR    15,11
.A21     ANOP
         RETURN (14,12),T,RC=(15)
         AIF   (&REENT).A24
         AIF   ('&NTER' NE '').A22
&CNT     SETA  18
         AGO   .A23
.A22     AIF   (T'&NTER NE 'N').BAD5
&PERFL   SETA  &NTER
&PERFR   SETC  '14'
&PERFD   SETA  0
&CNT     SETA  &NTER+18
* GENERATED SAVE AREA EXTENDED FOR USE BY NTER AND XIT MACROS
.A23     ANOP
&SAVE    DC    &CNT.F'0'
.A24     ANOP
         LTORG
&LAB     DS    0H
         MEXIT
.BAD1    MNOTE 8,'FIRST PARAMETER/S MUST BE SELF DEFINING'
         MEXIT
.BAD3    ANOP
.BAD4    MNOTE 8,'THIS MACRO WILL HANDLE 1-3 BASE REGS'
         MEXIT
.BAD5    MNOTE 8,'THIRD PARAMETER MUST BE SELF DEFINING'
         MEND
