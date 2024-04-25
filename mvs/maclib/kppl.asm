         MACRO
&LAB1    KPPL   &DSECT
         LCLC  &LAB2
*
*               PARAMETER LIST PASSED TO KMDPARS (12 FULLWORDS):
*
         AIF   (T'&LAB1 NE 'O').LOK
&LAB2    SETC  'KPPL'
         AGO   .DSCK
.LOK     ANOP
&LAB2    SETC  '&LAB1'
.DSCK    AIF   ('&DSECT' EQ 'DSECT').DSL
         DS    0A
&LAB2    DS    0XL48
         AGO   .ADSL
.DSL     ANOP
&LAB2    DSECT
.ADSL    ANOP
CBUFPTR  DS    F                        CMDBUF TO BE PARSED
OPLSTPTR DS    F                        LIST OF OPERANDS TO FLAG
FLAGPTR  DS    F                        WHERE TO FLAG THEM
UNKNEXIT DS    F                        EXIT TO CALL IF UNKNOWN OPER
EXITPARM DS    F                        PARAMETER TO PASS EXITS (ADDR)
*                                       (R1 POINTS HERE AT EXIT ENTRY)
BPPLPASS DS    F                        BPPL PTR WHEN EXIT GETS CONTROL
WORKPASS DS    F                        OPTIONAL WORKAREA (512 BYTES)
KEYLPASS DS    F                        LIST OF KEYWORD OPERANDS
KEYWPASS DS    F                        WORKAREA FOR KEYWORD PROCESSOR
REEXPASS DS    F                        ADDRESS OF REAL UNKNOWN EXIT
BUFFLEN  DS    F                        LEN OF STR BUFF
         DS    F                        RSVD- FLAGS
         MEND
