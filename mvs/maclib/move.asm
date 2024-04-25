         MACRO                                                          TSO06270
&L1      MOVE  &TO,&TL,&FROM,&FL,&PAD=                                  TSO06280
         LCLA  &NL,&UL,&VL,&RP,&RP2,&RC                                 TSO06290
         LCLC  &TO$,&TL$,&FROM$,&FL$                                    TSO06290
         LCLC  &R1(2),&R2(2),&RN1,&RN2                                  TSO06290
&RC      SETA  1
&RP      SETA  2
&RP2     SETA  &RP+1
.RPLOOP  ANOP
&RN1     SETC  '(R'.'&RP'.')'
&RN2     SETC  '(R'.'&RP2'.')'
         AIF   ('&TO' EQ '&RN1').CKP2
         AIF   ('&TL' EQ '&RN1').CKP2
         AIF   ('&FROM' EQ '&RN1').CKP2
         AIF   ('&FL' EQ '&RN1').CKP2
         AIF   ('&TO' EQ '&RN2').CKP2
         AIF   ('&TL' EQ '&RN2').CKP2
         AIF   ('&FROM' EQ '&RN2').CKP2
         AIF   ('&FL' EQ '&RN2').CKP2
&R1(&RC) SETC  'R'.'&RP'
&R2(&RC) SETC  'R'.'&RP2'
&RC      SETA  &RC+1
         AIF   (&RC EQ 3).GP
.CKP2    ANOP
&RP      SETA  &RP+2
&RP2     SETA  &RP+1
         AIF   (&RP LT 10).RPLOOP
         MNOTE 8,'NO REGISTER PAIRS FREE FOR MVCL INSTRUCTION'
         MEXIT
.GP      ANOP
&TO$     SETC  '&TO'
&TL$     SETC  '&TL'
&FROM$   SETC  '&FROM'
&FL$     SETC  '&FL'
         AIF   ('&TO'(1,1) NE '(').TLC
&TO$     SETC  '0&TO'
.TLC     AIF   ('&TL'(1,1) NE '(').FC
&TL$     SETC  '0&TL'
.FC      AIF   ('&FROM'(1,1) NE '(').FLC
&FROM$   SETC  '0&FROM'
.FLC     AIF   (T'&FL EQ 'O').OO                                        TSO06340
         AIF   ('&FL'(1,1) NE '(').OO
&FL$     SETC  '0&FL'
.OO      ANOP
&L1      STM   14,12,12(13)                                             TSO06300
         LA    &R1(1),&TO$                                              TSO06310
         LA    &R2(1),&TL$                                              TSO06320
         LA    &R1(2),&FROM$                                            TSO06330
         AIF   (T'&FL EQ 'O').UTL                                       TSO06340
         LA    &R2(2),&FL$                                              TSO06350
         AGO   .PC                                                      TSO06360
.UTL     LA    &R2(2),&TL$                                              TSO06370
.PC      AIF   ('&PAD' EQ '').NPC                                       TSO06380
         ICM   &R2(2),8,=&PAD                                           TSO06390
.NPC     MVCL  &R1(1),&R1(2)                                            TSO06400
         LM    14,12,12(13)                                             TSO06410
         MEND                                                           TSO06420
