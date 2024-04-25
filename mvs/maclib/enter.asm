         MACRO
&SUBR    ENTER &REGS,&BASES,&SAVE
         GBLC  &LV,&SP,&SAVED(2)
         LCLA  &K,&N
         LCLC  &AREA,&B(16),&SUBNAME,&S
&SAVED(1) SETC '&REGS(1)'
&SAVED(2) SETC '&REGS(2)'
&SUBNAME SETC  '&SUBR'
         AIF   ('&SUBNAME' NE '').P1
&SUBNAME SETC  'MAIN'
.P1      ANOP
&SUBNAME CSECT
         AIF   ('&REGS' EQ '').PA
         SAVE  &REGS,T,*
.PA      AIF   ('&BASES(1)' EQ '15' OR '&BASES' EQ '').PC
         AIF   ('&BASES(1)' EQ '13' AND '&SAVE' NE '').PC
         LR    &BASES(1),15
.PC      CNOP  0,4
&S       SETC  '&SUBNAME'
         AIF   (N'&SAVE EQ 2).P4
         AIF   ('&SAVE' EQ '').P3
&AREA    SETC  '&SAVE'
         AIF   ('&SAVE' NE '*').P2
&AREA    SETC  'SAVEAREA'
.P2      AIF   ('&SAVE' NE '+').PB
&AREA    SETC  'SAVE'.'&SYSNDX'
.PB      AIF   ('&BASES(1)' NE '13').P4
&S       SETC  '*'
         USING &SUBNAME,15
         AIF   ('&REGS' EQ '').PD
         ST    14,&AREA+4
         LA    14,&AREA
         ST    14,8(13)
         L     14,&AREA+4
         ST    13,&AREA+4
.PD      BAL   13,*+76
         DROP  15
         AGO   .P4
.P3      AIF   ('&BASES(1)' NE '13').P4
         MNOTE 8,'*** THE CONTENTS OF REG. 13 ARE LOST. NO SAVE AREA WAX
               S ESTABLISHED.'
.P4      AIF   ('&BASES(1)' NE '14' OR '&SAVE' EQ '').P5
         MNOTE 8,'*** MACRO RESTRICTION - REG. 14 MUST NOT BE USED AS TX
               HE FIRST BASE REGISTER IF A SAVE AREA IS USED.'
.P5      AIF   ('&BASES' EQ '').P9
&N       SETA  N'&BASES
.P6      ANOP
&K       SETA  &K+1
&B(&K)   SETC  ','.'&BASES(&K)'
         AIF   (N'&SAVE EQ 1).PE
         AIF   ('&BASES(&K)' NE '13').P7
         MNOTE 8,'*** REG. 13 MAY NOT BE USED AS A BASE REGISTER FOR REX
               ENTRANT CODE.'
         AGO   .P7
.PE      AIF   ('&BASES(&K+1)' NE '13' OR '&SAVE' EQ '').P7
         MNOTE 8,'*** WHEN USING A SAVE AREA, REG. 13 MAY NOT BE USED AX
               S A SECONDARY BASE REGISTER.'
.P7      AIF   ('&BASES(&K+1)' NE '').P6
         USING &S&B(1)&B(2)&B(3)&B(4)&B(5)&B(6)&B(7)&B(8)&B(9)&B(10)&B(X
               11)&B(12)&B(13)&B(14)&B(15)&B(16)
&K       SETA  1
         AIF   ('&BASES(1)' NE '13' OR '&SAVE' EQ '').P8
&AREA    DC    18F'0'
.P8      AIF   (&K GE &N).P10
         LA    &BASES(&K+1),X'FFF'(&BASES(&K))
         LA    &BASES(&K+1),1(&BASES(&K+1))
&K       SETA  &K+1
         AGO   .P8
.P9      USING &SUBNAME,15
.P10     AIF   (N'&SAVE EQ 2).P13
         AIF   ('&SAVE' EQ '' OR '&BASES(1)' EQ '13').P12
         AIF   ('&REGS' EQ '').P11
         ST    14,&AREA+4
         LA    14,&AREA
         ST    14,8(13)
         L     14,&AREA+4
         ST    13,&AREA+4
.P11     BAL   13,*+76
&AREA    DC    18F'0'
.P12     MEXIT
.P13     ANOP
&LV      SETC  '&SAVE(2)'
&SP      SETC  '0'
         AIF   ('&SAVE(1)' EQ '').P14
&SP      SETC  '&SAVE(1)'
.P14     GETMAIN R,LV=&LV,SP=&SP
         ST    13,4(1)
         ST    1,8(13)
         LR    2,13
         LR    13,1
         LM    0,2,20(2)
         MEND
