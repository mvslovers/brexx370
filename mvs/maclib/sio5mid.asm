         MACRO
         SIO5MID &TYPE=TEXT,&P=MID
         AIF   ('&TYPE' EQ 'TEXT').NODSCT
         AIF   ('&TYPE' EQ 'NOLB').NOLBL
SIO5MIDD DSECT
.NOLBL   ANOP
**
**       MODULE IDENTIFICATION AREA
**
&P.NAME  DC    CL8' '
         DC    CL2' '
&P.RELN  DC    CL8' '
         DC    CL2' '
&P.DATE  DC    CL8' '
         DC    CL2' '
&P.TIME  DC    CL8' '
         DC    CL2' '
         AIF   ('&TYPE' EQ 'NOLB').DONE
&P.LENG  EQU   *-&P.NAME
.DONE    ANOP
         MEXIT
.NODSCT  ANOP
**
**       MODULE IDENTIFICATION AREA
**
         DC    CL8'&SYSECT'
         DC    CL2' '
         DC    CL8'VER 5.0'
         DC    CL2' '
         DC    CL8'&SYSDATE'
         DC    CL2' '
         DC    CL8'&SYSTIME'
         DC    CL2' '
         MEND
