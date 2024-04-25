         MACRO
&LAB1    BPPL   &DSECT
         LCLC  &LAB2
*
*               PARAMETER LIST PASSED TO OPERSCAN SUBROUTINE :
*
         AIF   (T'&LAB1 NE 'O').LOK
&LAB2    SETC  'BPPL'
         AGO   .DSCK
.LOK     ANOP
&LAB2    SETC  '&LAB1'
.DSCK    AIF   ('&DSECT' EQ 'DSECT').DSL
         DS    0A
&LAB2    DS    0XL44
         AGO   .ADSL
.DSL     ANOP
&LAB2    DSECT
.ADSL    ANOP
BUFFPTR  DS    F                        BUFFER PTR (CBUF)
LENPTR   DS    F                        LENGTH PTR (CBUF LEN)
STARTPTR DS    F                        START SEARCH PTR
OPERPTR  DS    F                        NEXT OPER LOC
OPLENPTR DS    F                        NEXT OPER LEN PTR
SUBPTR   DS    F                        SUBFIELD PTR (PARENS INCLUDED)
SUBLENPT DS    F                        SUBFIELD LEN PTR
WORKPTR  DS    F                        WORK PTR (OPTIONAL 350 BYTES)
OPDESCP  DS    F                        PTR TO OPERAND DESCRIPTOR
         DS    F                        RESERVED (ZERO)
*
OPLEN    DS    H                        POINTED TO BY OPLENPTR
SUBLEN   DS    H                        POINTED TO BY SUBLENPT
         MEND
