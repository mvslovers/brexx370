         MACRO
&LABEL   SETON &A,&B,&C,&D,&E,&F,&G,&H,&I,&J,&K,&L,&M,&N,&O,&P
         LCLA  &NU
         LCLC  &VALUE
         LCLC  &#
&#       SETC  '#'
         AIF   ('&A' NE '').OK
         MNOTE 5,'MISSING OPERANDS - NO GEN'
         MEXIT
.OK      AIF   ('&LABEL' EQ '').B1
&LABEL   EQU   *
.B1      ANOP
&NU      SETA  N'&SYSLIST
.CHK     AIF   ('&NU' NE '0').LOOP
         SPACE
         MEXIT
.LOOP    ANOP
&VALUE   SETC  '&SYSLIST(&NU)'
         OI    &SYSLIST(&NU),&VALUE&#
&NU      SETA  &NU-1
         AGO   .CHK
         MEND
