.* --------------------------------------------------------------------
.*       END OF WORK AREA DEFINITON
.* --------------------------------------------------------------------
         MACRO
&LABEL   WORKEND
         DS  CL256
WORKLEN  EQU *-WORKAREA
         MEND
