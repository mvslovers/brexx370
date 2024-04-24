         MACRO
&OPNM    OPERLIST
         LCLA  &I
&OPNM    DC    F'0'                     LIST OF KNOWN OPERANDS
.CU      ANOP
&I       SETA  &I+1
         AIF   (&I GT N'&SYSLIST).MEX
         DC    A(&SYSLIST(&I))
         AGO   .CU
.MEX     DC    F'0'                     END OF LIST
         MEND
