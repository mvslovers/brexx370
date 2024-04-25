         MACRO                                                          TSO06270
&NAME    TRANTAB                                                        TSO06280
.*
.*       TRANTAB (FV,TV),(FV2,TV2)....
.*     FV = FROM VALUE
.*     TV = TO VALUE
.* ALL UNDEFINED CHARACTERS ARE NOT TRANSLATED
.*
         LCLA  &I &N
&I       SETA  0
&NAME    DS    0XL256
.DFNT    PRINT NOGEN
.DLP     DC    AL1(&I)
&I       SETA  &I+1
         AIF   (&I LE 255).DLP
         PRINT GEN
&N       SETA  N'&SYSLIST
         AIF   (&N EQ 0).X
.NE      AIF   (T'&SYSLIST(&N,1) EQ 'O').NO
         ORG   &NAME+&SYSLIST(&N,1)
         DC    &SYSLIST(&N,2)
.NO      ANOP
&N       SETA  &N-1
         AIF   (&N GE 1).NE
.X       ORG
         MEND
