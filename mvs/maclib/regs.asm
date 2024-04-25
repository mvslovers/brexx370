         MACRO
         REGS  &A
         LCLA  &N
         SPACE 2
*        GENERATE REGISTER NAMES
.B       ANOP
R&N      EQU   &N
&N       SETA  &N+1
         AIF   (&N NE 16).B
         MEND
