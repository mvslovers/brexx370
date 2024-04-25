         MACRO
&LAB1    ENTERWW &WC,&SA=SAVEAREA,&WA=WORKAREA,&LEVEL=,&R=
         MNOTE '             SA=&SA,WA=&WA,LEVEL=&LEVEL'
&LAB1    CSECT
         SAVE  (14,12),,&LAB1-&LEVEL
         LR    R12,R15            HOPE HE KNOWS WHAT HE'S DOING
         USING &LAB1,R12
         LR    R10,R1             SAVE PARM PTR R10->PARM PTR
         LCLA  &I
&I       SETA  1
.WL      AIF   (&I GT N'&WC).GW
         AIF   (T'&WC(&I) NE 'N').ASIS
         L     R1,4*&WC(&I)-4(,R1)
         AGO   .NSC
.ASIS    ANOP
         L     R1,&WC(&I)(,R1)
.NSC     ANOP
&I       SETA  &I+1
         AGO   .WL
.GW      ANOP
         LR    R11,R13            R11->CALLERS SAVEAREA
         LR    R13,R1             R13->WORKAREA
         USING &WA.,R13
         ST    R11,&SA.+4         SAVE HIS SAVEAREA PTR
         LA    R13,&SA            R13->SAVEAREA (MINE)
         ST    R13,8(,R11)        MINE IN HIS
         LR    R11,R1             R11->WORKAREA IN CASE NOT SAME AS R13
*                       WORKAREA ADDR IS STILL R13 FOR
*                       THE ASSEMBLER - IF DIFFERENT FROM R13
*                       THEN USE: DROP R13 AND USING &WA.,R11
         LR    R1,R10             RESTORE PARM PTR PTR
         AIF   ('&R' EQ 'NO').NRE
         REGEQU
.NRE     ANOP
         MEND
