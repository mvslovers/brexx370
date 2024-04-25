         MACRO
         SIOSCVT
**
**       S. I. O. COMMUNICATIONS VECTOR TABLE
**
         IEZBITS
**
SIOSCVT  DSECT
**
SIOSSVCP DC    A(0)                    ADDRESS OF SIOSSVC
SIOSRELP DC    A(0)                    ADDRESS OF SIOSREL
SIOSJISP DC    A(0)                    ADDRESS OF SIOSJIS
**
SIOSFLAG DC    XL4'0'                  PROCESSING FLAGS
SIOSSHFG EQU   BIT0                    SIO IS UP (AVAILABLE)
SIOS19FG EQU   BIT1                    SIO IS SHUTDOWN (WILL ONLY
*                                      BE SET IF CAN NOT BACKOUT SVC19)
SIOS64FG EQU   BIT2                    SIO IS SHUTDOWN (WILL ONLY
*                                      BE SET IF CAN NOT BACKOUT SVC64)
SIOSCVTL EQU   *-SIOSCVT               LENGTH OF SIO CVT
         MEND
