         MACRO
&LAB     LOGONXWA &OFF=*
WDPSCPRM EQU   &OFF                                               WDPSC
*                                                                 WDPSC
*        WDPSC ADDITIONS TO IKJEFLDA PARM LIST:                   WDPSC
*                                                                 WDPSC
DESTLNG  EQU   &OFF                                               WDPSC
         DS    XL2                                                WDPSC
DESTUSID EQU   &OFF                                               WDPSC
         DS    CL8                                                WDPSC
MSGCLASS EQU   &OFF                                               WDPSC
         DS    XL2                                                WDPSC
TIMELM   EQU   &OFF                                               WDPSC
         DS    H                                                  WDPSC
TIMEM    EQU   &OFF                                               WDPSC
         DS    CL4                                                WDPSC
TIMELS   EQU   &OFF                                               WDPSC
         DS    H                                                  WDPSC
TIMES    EQU   &OFF                                               WDPSC
         DS    CL2                                                WDPSC
PROGL    EQU   &OFF                                               WDPSC
         DS    H                                                  WDPSC
PROG     EQU   &OFF                                               WDPSC
         DS    CL20                                               WDPSC
SLIBFLGS EQU   &OFF                                               WDPSC
         DS    H                                                  WDPSC
STEP     EQU   X'80'                                              WDPSC
NOSTEP   EQU   X'40'                                              WDPSC
PAL      EQU   X'20'                                              WDPSC
NOPAL    EQU   X'10'                                              WDPSC
DIALOG   EQU   X'08'                                              WDPSC
NODIALOG EQU   X'04'                                              WDPSC
VANILLA  EQU   X'02'                                              WDPSC
CHOCLATE EQU   X'01'                                              WDPSC
*                                                                 WDPSC
*              ADDED WORK AREAS FOR IKJEFLD                       WDPSC
*                                                                 WDPSC
ACF2FLG  DS    H                                                  WDPSC
WUPTPTR  DS    2H                                                 WDPSC
WLWAPTR  DS    2H                                                 WDPSC
WLWPPTR  DS    2H                                                 WDPSC
WLIPPTR  DS    2H                                                 WDPSC
WPFGPTR  DS    2H                                                 WDPSC
TIMWK1   DS    4H                                                 WDPSC
TIMWK2   DS    4H                                                 WDPSC
DESTRECK DS    H                                                  WDPSC
REGIONS  DS    CL5                                                WDPSC
DESTFORM DS    CL9                                                WDPSC
ACCTDATA DS    CL10                                               WDPSC
W1       DS    F                                                  WDPSC
W2       DS    F                                                  WDPSC
DSL      DS    H                                                  WDPSC
DSF      DS    XL20                                               WDPSC
         DS    0F                                                 WDPSC
         MEND
