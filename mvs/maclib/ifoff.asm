         MACRO
&LABEL   IFOFF &BIT,&BROF,&BRON
         LCLB  &BL121,&BL122
         LCLC  &#
&#       SETC  '#'
         AIF   ('&BIT' NE '').A
         MNOTE 1,'OPERAND 1 MISSING - NO GENERATION'
         MEXIT
.A       ANOP
&BL121   SETB  ('&BRON' NE '')
&BL122   SETB  ('&BROF' NE '')
         AIF   (&BL121 OR &BL122).AA
         MNOTE 1,'NO TRANSFER ADDRESS'
         MEXIT
.AA      ANOP
&LABEL   TM    &BIT,&BIT&#  .          TEST FOR BIT.
         AIF   (NOT &BL122).OTHER
         BZ    &BROF  .                BRANCH NOT ON.
         AIF   (&BL121).OTHER
         SPACE
         MEXIT
.OTHER   BO    &BRON  .                BRANCH ON.
         SPACE
         MEND
