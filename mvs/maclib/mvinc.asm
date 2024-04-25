         MACRO                                                          TSO06270
&NAME    MVINC &TO,&TL,&FROM,&TABLE=OLD                                 TSO06280
         LCLC  &TO$,&TL$,&FROM$                                         TSO06290
         GBLC  &TBL$
         GBLA  &PREVIDX
&TO$     SETC  '&TO'
&TL$     SETC  '&TL'
&FROM$   SETC  '&FROM'
.TCHK    AIF   ('&TO'(1,1) NE '(').TLCHK
&TO$     SETC  '0&TO'
.TLCHK   AIF   ('&TL'(1,1) NE '(').FCHK
&TL$     SETC  '0&TL'
.FCHK    AIF   ('&FROM'(1,1) NE '(').START$
&FROM$   SETC  '0&FROM'
.START$  ANOP
&SI      SETA  &SYSNDX
&NAME    LA    R1,&TL$                                                  TSO06370
         LA    R14,&TO$                                                 TSO06370
         B     NEXT&SI
         LCLA  &I &IDX
         AIF   (&PREVIDX NE 0).PIDX
&PREVIDX SETA  0001
.PIDX    ANOP
&IDX     SETA  &PREVIDX
.NEWCHK  AIF   ('&TABLE' NE 'NEW').DFNCHK
&IDX     SETA  &SI
         AGO   .INIT$
.DFNCHK  AIF   ('&TBL$' EQ 'DFND').TRNSLT
.INIT$   ANOP
&I       SETA  255
TBL&IDX  DS    0XL256
.DFNT    PRINT NOGEN
.DLP     DC    AL1(&I)
&I       SETA  &I-1
         AIF   (&I GE 0).DLP
         PRINT GEN
.TRNSLT  ANOP
&TBL$    SETC  'DFND'
&PREVIDX SETA  &IDX
NEXT&SI  LA    R15,TBL&IDX+256
         SR    R15,R1
         BCTR  R1,0
         EX    R1,COPY&SI
         EX    R1,TRAN&SI
         B     QUIT&SI
COPY&SI  MVC   0(0,R14),0(R15)
TRAN&SI  TR    0(0,R14),&FROM$
QUIT&SI  EQU   *
         MEND
