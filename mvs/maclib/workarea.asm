         MACRO
&LABEL   WORKAREA &SYSOUT=
         LTORG
* ---------------------------------------------------------------------
*  SYSPRINT DCB FOR STANDARD OUTPUT
* ---------------------------------------------------------------------
         AIF   ('&SYSOUT' EQ '').NSYSOUT
&SYSOUT  DCB   DDNAME=&SYSOUT,MACRF=PM,                                X
               DSORG=PS,LRECL=133,RECFM=FBA
.NSYSOUT ANOP
         EJECT
* --------------------------------------------------------------------
*       WORK AREA DEFINITON FOR ALLOCATED STORAGE IN SPROC
* --------------------------------------------------------------------
WORKAREA DSECT
&LABEL   DS    0H
         AIF   ('&SYSOUT' EQ '').NMPOUT
MPOUTLN  DS    0CL133
MPOUTCTL DS    CL1
MPOUTLIN DS    CL132
         DC    CL255'RESERVED'
         DC    CL255'RESERVED'
.NMPOUT  ANOP
         MEND
