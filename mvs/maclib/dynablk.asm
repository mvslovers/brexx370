         MACRO
&L1      DYNABLK &TN,&MF=L
         LCLA  &I,&J
         LCLC  &LP,&RLN
&I       SETA  &TN
&J       SETA  1
         AIF   ('&MF' EQ 'L').LT
         AIF   (N'&MF LE 1).X
         AIF   ('&MF(1)' NE 'E').X
&RLN     SETC  '&MF(2)'
&LP      SETC  '&RLN'(1,4)
&L1      LA    R1,&LP.RB
         ST    R1,&RLN
         MVI   &RLN,X'80'
         MVC   &LP.RB(8),=X'1401200000000000'
         XC    &LP.TPLA(12),&LP.TPLA
         LA    R1,&LP.TPL
         ST    R1,&LP.TPLA
.STP     AIF   (&J GT &I).SEF
         LA    R1,&LP.TU&J
         ST    R1,&LP.TP&J
&J       SETA  &J+1
         AGO   .STP
.SEF     ANOP
         MVI   &LP.TP&I,X'80'
         AGO   .X
.LT      ANOP
&LP      SETC  '&L1'(1,4)
         DS    0F
&L1      DC    X'80',AL3(&LP.RB)
&LP.RB   DC    X'14',X'01',X'2000'
         DC    X'0000',X'0000'
&LP.TPLA DC    A(&LP.TPL),2F'0'
&LP.TPL  DS    0H
.TPL     AIF   (&J GT &I).X
&LP.TP&J DC    A(&LP.TU&J)
&J       SETA  &J+1
         AGO   .TPL
.X       MEND
