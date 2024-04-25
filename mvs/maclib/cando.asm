         MACRO
&L1      CANDO
         LCLA  &I,&J,&K,&L
         LCLC  &O(3)
&O(1)    SETC  'PAL'
&O(2)    SETC  'DIALOG'
&O(3)    SETC  'NOPARM'
.L1      ANOP
&I       SETA  &I+1
         AIF   (&I GT 3).MEX
&K       SETA  2*&K
&J       SETA  0
.L2      ANOP
&J       SETA  &J+1
         AIF   (&J GT N'&SYSLIST).L1
         AIF   ('&SYSLIST(&J)' NE '&O(&I)').L2
&K       SETA  &K+1
         AGO   .L1
.MEX     ANOP
&L       SETA  K'&L1
         DC    AL2(&L),AL2(&K),CL8'&L1'
.X       MEND
