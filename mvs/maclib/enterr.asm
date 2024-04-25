         MACRO
&LAB1    ENTERR  &SA=SAVEAREA,&WA=WORKAREA,&WL=WORKLEN,&LEVEL=,&R=,   XX
               &CLEAR=YES
         MNOTE ' CLEAR=&CLEAR,SA=&SA,WA=&WA,WL=&WL,LEVEL=&LEVEL'
&LAB1    CSECT
         SAVE  (14,12),,&LAB1-&LEVEL
         LR    R12,R15            HOPE HE KNOWS WHAT HE'S DOING
         USING &LAB1,R12
         LR    R10,R1             SAVE PARM PTR R10->PARM PTR
         L     R0,=A(&WL)         R0=GET LENGTH
         GETMAIN R,LV=(0)         R1->WORKAREA
         LR    R11,R13            R11->CALLERS SAVEAREA
         LR    R13,R1             R13->WORKAREA
         USING &WA.,R13
         AIF   ('&CLEAR' NE 'YES').NCLEAR
         L     R15,=A(&WL)        R0=GET LENGTH
         S     R15,=F'72'         SKIP REGS
         MOVE  72(13),(15),0,0
.NCLEAR  ANOP
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
