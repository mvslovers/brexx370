         MACRO
&LAB1    SUBDATA &DSECT
         LCLC  &LAB2
*
*               OPERAND DATA PASSED TO IKJEFF10 VIA ITCOMA1:
*
         AIF   (T'&LAB1 NE 'O').LOK
&LAB2    SETC  'SUBDATA'
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
NOTIFY   DS    AL2                NOTIFY/NONOTIFY FLAG
JES      DS    AL2                JES CMD FLAG
*
LONE     DS    2A                 PTR/FLG CLASS
LTWO     DS    2A                 PTR/FLG MSGCLASS
DESCR    DS    2A                 PTR/FLG PROG NAME FLD
AN       DS    2A                 PTR/FLG ACCOUNT NO.
BSA      DS    2A                 PTR/FLG BIN-SUB-AGY
SN       DS    2A                 PTR/FLG SYSTEM NO.
NUID     DS    2A                 PTR/FLG NOTIFY UID.
P        DS    2A                 PTR/FLG PRTY
*
CLFLD    DS    H
CLASS    DS    X
MCFLD    DS    H
MSGCLASS DS    X
PNFLD    DS    H
PROGNAME DS    XL20
ANFLD    DS    H
ACCOUNT  DS    XL20
BFLD     DS    H
BIN      DS    XL4
SFLD     DS    H
SYS      DS    XL4
NFLD     DS    H
NOTIUID  DS    XL8
PFLD     DS    H
PRTY     DS    XL8
         MEND
