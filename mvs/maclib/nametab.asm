         MACRO
&PTL     NAMETAB &LL,&NL,&ENTRIES=0,&DSECT=DEF
         LCLA  &LC,&LN
         LCLC  &SS
*              TABLE OF PREFIX OR QUALIFIER NAMES -
*                UP TO 8 BYTES EACH, PRECEDED BY HALFWORD LENGTHS
         AIF   ('&DSECT' EQ 'YES').CD
         AIF   (T'&LL EQ 'O').ND
         AIF   ('&LL'(1,1) EQ '(').ND
.CD      AIF   ('&DSECT' EQ 'NO').ND
&PTL     DSECT
         AGO   .L1
.ND      ANOP
&PTL     DS    0H
.L1      ANOP
         AIF   (T'&LL EQ 'O').MBST
         AIF   ('&LL'(1,1) EQ '(').MBTP
&LL      DS    H                  LENGTH OF NAME - IF ZERO TABLE END
&NL      DS    CL8                NAME - UP TO 8 BYTES
         MEXIT
.MBTP    AIF   (N'&LL EQ 1).STRNG
&LC      SETA  &LC+1
&LN      SETA  K'&LL(&LC)
         DC    H'&LN',CL8'&LL(&LC)'
         AIF   (&LC LT N'&LL).MBTP
         DC    H'0',CL8' '        END OF TABLE
         MEXIT
.MBST    DS    &ENTRIES.H,&ENTRIES.CL8
         MEXIT
.STRNG   ANOP
&LC      SETA  2
&LN      SETA  0
.NC      AIF   ('&LL'(&LC,1) EQ ',').BE
         AIF   ('&LL'(&LC,1) EQ ')').BE
&LN      SETA  &LN+1
&LC      SETA  &LC+1
         AGO   .NC
.BE      ANOP
&SS      SETC  '&LL'(&LC-&LN,&LN)
         DC    H'&LN',CL8'&SS'
         AIF   ('&LL'(&LC,1) EQ ')').TE
&LN      SETA  0
&LC      SETA  &LC+1
         AGO   .NC
.TE      ANOP
         DC    H'0',CL8' '        END OF TABLE
         MEND
