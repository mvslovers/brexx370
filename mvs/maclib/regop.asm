.* --------------------------------------------------------------------
.*  DECIDES WHICH OP CODE TO BE USED, ENABLES REGISTER NOTATION =(RX)
.*       USE APPROPRIATE OP CODE L/LH/LR ST/STH A/AH/AR S/SH/SR
.* --------------------------------------------------------------------
         MACRO
&LABEL   REGOP &OP,&TO,&FROM
         LCLC  &TYPE
&TYPE    SETC  T'&FROM
         AIF   ('&FROM'(1,1) NE '(').REGNOT
         AIF   ('&TO' EQ '&FROM(1)').REGSAME
&LABEL   &OP.R &TO,&FROM(1)
         MEXIT
.REGSAME ANOP
         AIF   ('&LABEL' EQ '').NOLABL
&LABEL   DS    0H                 SOURCE = TARGET REGISTER
.NOLABL  ANOP
         MEXIT
.REGNOT  AIF   ('&TYPE' EQ 'U').FULLW
         AIF   (L'&FROM EQ 2).HALFW
.FULLW   ANOP
&LABEL   &OP   &TO,&FROM
         MEXIT
.HALFW   ANOP
&LABEL   &OP.H &TO,&FROM
         MEND
