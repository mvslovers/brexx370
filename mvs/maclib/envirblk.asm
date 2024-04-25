         MACRO
         ENVIRBLK
ENVIRBLK DSECT                                                          00090
*     SOURCE FOR ENVIRBLK FOUND IN SECEXIT IN PANSPACE  REL 11.D
*         USED BY THE ACF2/PANVALET INTERFACE
*                                                                       00016
*        ENVIRONMENT BLOCK                                              00088
*                                                                       00089
ENPRODID DS    CL10          PRODUCT NAME -- VALUE IS ALWAYS "PANVALET" 00091
ENPRODOP DS    CL10          PRODUCT OPTION -- (E.G. TSO, ISPF)         00092
ENPRODVR DS    CL4           PRODUCT VERSION -- THE RELEASE OF THE      00093
*                            PRODUCT (I.E. PANVALET 11.0 = "1100")      00094
ENOPSYS  DS    CL10          OPERATING SYSTEM -- THE OPERATING SYSTEM   00095
*                            UNDER WHICH THE PRODUCT IS RUNNING         00096
*                            ("OS/MVS" OR "OS/VS1" OR "OS/MVS/XA")      00097
ENDCMON  DS    CL10          DC MONITOR                                 00098
ENDBMGR  DS    CL10          DB MANAGER                                 00099
*        DS    XL2           RESERVED                                   00100
ENDCPARM DS    A             ADDRESS OF CICS ENVIRONMENT BLOCK OR 0     00101
ENDBPARM DS    A             ADDRESS OF DB MANAGER CONTROL BLOCK OR 0   00102
         MEND
