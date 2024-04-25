         MACRO
&LABEL   IFON  &BIT,&BRYES,&BRNO
         LCLB  &BL121,&BL122
         LCLC  &#
&#       SETC  '#'
         AIF   ('&BIT' NE '').A
         MNOTE 1,'OPERAND 1 MISSING - NO GENERATION'
         MEXIT
.A       ANOP
&BL121   SETB  ('&BRYES' NE '')
&BL122   SETB  ('&BRNO' NE '')
         AIF   (&BL121 OR &BL122).AA
         MNOTE 1,'NO TRANSFER ADDRESS'
         MEXIT
.AA      ANOP
&LABEL   TM    &BIT,&BIT&#  .          TEST FOR BIT.
         AIF   (NOT &BL121).TAKNO
         BO    &BRYES  .               BRANCH ON.
         AIF   (&BL122).TAKNO
         SPACE
         MEXIT
.TAKNO   ANOP
         BZ    &BRNO  .                BRANCH NOT ON.
         SPACE
         MEND
