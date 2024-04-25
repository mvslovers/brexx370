         MACRO                                                          TSO06270
&L1      MOVE  &TO,&TL,&FROM,&FL,&PAD=                                  TSO06280
         LCLA  &NL,&UL,&VL                                              TSO06290
         LCLC  &TO$,&TL$,&FROM$,&FL$                                    TSO06290
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
         LA    R2,&TO$                                                  TSO06310
         LA    R3,&TL$                                                  TSO06320
         LA    R4,&FROM$                                                TSO06330
         AIF   (T'&FL EQ 'O').UTL                                       TSO06340
         LA    R5,&FL$                                                  TSO06350
         AGO   .PC                                                      TSO06360
.UTL     LA    R5,&TL$                                                  TSO06370
.PC      AIF   ('&PAD' EQ '').NPC                                       TSO06380
         ICM   R5,8,=&PAD                                               TSO06390
.NPC     MVCL  R2,R4                                                    TSO06400
         LM    14,12,12(13)                                             TSO06410
         MEND                                                           TSO06420
