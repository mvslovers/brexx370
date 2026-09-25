         MACRO
         #ENVCTX
ENVCTX   DSECT
* ---------------------------------------------------------------------
* SYSVAR
* ---------------------------------------------------------------------
SYSPREF  DS    CL8
SYSUID   DS    CL8
SYSENV   DS    CL5
SYSISPF  DS    CL11
* ---------------------------------------------------------------------
* FLAG FIELDS
* ---------------------------------------------------------------------
ENVFLAGS DS    0F
* ALLOCATIONS FOUND
EFLAGS1  DC    X'00'
EF1B8    EQU   X'80' 1... ....  UNSED
EF1B7    EQU   X'40' .1.. ....  UNSED
EF1B6    EQU   X'20' ..1. ....  UNSED
EF1B5    EQU   X'10' ...1 ....  UNSED
EF1RXL   EQU   X'08' .... 1...  RXLIB  ALLOCATION FOUND
EF1ERR   EQU   X'04' .... .1..  STDERR ALLOCATION FOUND
EF1OUT   EQU   X'02' .... ..1.  STDOUT ALLOCATION FOUND
EF1IN    EQU   X'01' .... ...1  STDIN  ALLOCATION FOUND
* ENVIRONMENTS FOUND
EFLAGS2  DC    X'00'
EF2B8    EQU   X'80' 1... ....  UNSED
EF2B7    EQU   X'40' .1.. ....  UNSED
EF2B6    EQU   X'20' ..1. ....  UNSED
EF2B5    EQU   X'10' ...1 ....  UNSED
EF2ISPF  EQU   X'08' .... 1...  ISPF ENVIRONMENT FOUND
EF2EXEC  EQU   X'04' .... .1..  EXEC ENVIRONMENT FOUND
EF2TSOBG EQU   X'02' .... ..1.  TSO BACKGROUND ENVIRONMENT FOUND
EF2TSOFG EQU   X'01' .... ...1  TSO FOREGROUND ENVIRONMENT FOUND
* ALLOCATIONS MADE BY RXINIT
EFLAGS3  DC    X'00'
EF3B8    EQU   X'80' 1... ....  UNSED
EF3B7    EQU   X'40' .1.. ....  UNSED
EF3B6    EQU   X'20' ..1. ....  UNSED
EF3VOUT  EQU   X'10' ...1 ....  TMPOUT ALLOCATED
EF3VIN   EQU   X'08' .... 1...  TMPIN  ALLOCATED
EF3ERR   EQU   X'04' .... .1..  STDERR ALLOCATED
EF3OUT   EQU   X'02' .... ..1.  STDOUT ALLOCATED
EF3IN    EQU   X'01' .... ...1  STDIN  ALLOCATED
* SPARE FLAGS
EFLAGS4  DC    X'00'
EF4B8    EQU   X'80' 1... ....  UNSED
EF4B7    EQU   X'40' .1.. ....  UNSED
EF4B6    EQU   X'20' ..1. ....  UNSED
EF4B5    EQU   X'10' ...1 ....  UNSED
EF4B4    EQU   X'08' .... 1...  UNSED
EF4B3    EQU   X'04' .... .1..  UNSED
EF4B2    EQU   X'02' .... ..1.  UNSED
EF4B1    EQU   X'01' .... ...1  UNSED
* RUNTIME ENVIRONMENT
LITPOOL  DS    A     ADDRESS OF BREXX LITERALS POOL
VARPOOL  DS    A     ADDRESS OF BREXX VARIABLE POOL
PROCID   DS    A     CURRENT PROCEDURE ID
CPPL     DS    A
* ---------------------------------------------------------------------
* SPARE BYTES
* ---------------------------------------------------------------------
DUMMY    DS    28F
* ---------------------------------------------------------------------
* VSAM  POINTERS
* ---------------------------------------------------------------------
VSAMSUBT DS    A     VSAM SUBTASK COMMUNICATION AREA
* ---------------------------------------------------------------------
* RESERVED ADDRESSES
* ---------------------------------------------------------------------
RESERVED DS    64A
         MEND
