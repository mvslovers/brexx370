         MACRO
&LAB1    ITCOMA1 &DSECT
         LCLC  &LAB2
*
*        LOCAL INTER-TASK COMMUNICATION AREA ONE:
*
         AIF   (T'&LAB1 NE 'O').LOK
&LAB2    SETC  'ITCOMA1'
         AGO   .DSCK
.LOK     ANOP
&LAB2    SETC  '&LAB1'
.DSCK    AIF   ('&DSECT' EQ 'DSECT').DSL
         DS    0A
&LAB2    DS    0XL100
         AGO   .ADSL
.DSL     ANOP
&LAB2    DSECT
.ADSL    ANOP
         DC    CL8'ITCOMA1'
         DC    CL4'V1M3'
         DC    A(ITCOML)
*              TABLE OF UP TO 4 TCB ADDRESS PAIRS FOR NEWMWILE    *KK*
SCR1     DC    2A(0)                   SCREEN 1 TCB ADDRESSES
SCR2     DC    2A(0)                   SCREEN 2 TCB ADDRESSES
SCR3     DC    2A(0)                   SCREEN 3 TCB ADDRESSES
SCR4     DC    2A(0)                   SCREEN 4 TCB ADDRESSES
         SPACE
SUBDPTR  DS    A                       PTR TO CURRENT SUBMIT DATA(TSOE)
         SPACE
CMAINROK DS    A                       PTR TO TRUE C370 MAIN PROGRAM
         SPACE
         DS    23F                     FUTURE OPTIONS
ITCOML   EQU   *-ITCOMA1
         MEND
