        MACRO
        DATALIST
DATALIST DSECT                                                          00106
*    SOURCE FOR DATALIST FOUND IN PANSPACE SECEXIT REL 11.D
*       USED BY THE ACF2/PANVALET INTERFACE                             00001
*                                                                       00103
*        DATA LIST BLOCK                                                00104
*                                                                       00105
DLCOUNT  DS    F             DATA LIST COUNT -- THE NUMBER OF DATA      00107
*                            LIST ENTRIES (0 TO N) FOLLOWING:           00108
DLFIRST  DS    0X            FIRST DATA LIST ENTRY                      00109
*                                                                       00110
*        DATA LIST ENTRY                                                00111
*                                                                       00112
DLENTRY  DSECT               DATA LIST ENTRY:                           00113
DLEID    DS    CL8           DATA ID -- THE NAME OF THE DATA ITEM       00114
*                            (E.G. ELEMFILE, JOBNAME ETC...)            00115
DLESTAT  DS    CL1           DATA ITEM STATUS -- VALUES ARE:            00116
ACTIVE   EQU   C'A'          'A' - ACTIVE                               00117
INACTIVE EQU   C'I'          'I' - INACTIVE                             00118
*        DS    CL3           RESERVED                                   00119
DLEITEM  DS    A             DATA ITEM ADDRESS -- THE ADDRESS OF THE    00120
*                            ITEM                                       00121
DLENEXT  DS    0X            BEGINNING OF NEXT ENTRY                    00122
        MEND
