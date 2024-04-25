         MACRO
&NAME    TERME &PASS,&RC=O
         GBLC  &LAB
         GBLB  &PRIM
&NAME    DS    0H
         AIF   (&PRIM).TSTRC
         MNOTE 8,'PRIME MUST OCCUR BEFORE TERME'
         MEXIT
.TSTRC   AIF   ('&RC' EQ '(15)').RET
         AIF   ('&RC' EQ 'O').RET
         AIF   ('&RC'(1,1) EQ '(').ISAREG
         LA    15,&RC
         AGO   .RET
.ISAREG  ANOP
         LR    15,&RC
.RET     AIF   ('&PASS' NE 'PASS').NOPASS
         L     14,4(13)
         STM   0,1,20(14)
.NOPASS  ANOP
         B     &LAB.X
         MEND
