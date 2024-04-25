         MACRO
&LAB1    IKJPSCBX
* PCF2 (THE GREEDY BUM) USES PSCBATR2 AND THE FIRST WORD OF PSCBU.WDPSC
*                                                                 WDPSC
* WE ARE THUS USING BITS 12-15 OF PSCBATR1 (AND LIKEWISE IN UADS) WDPSC
* FOR STATUS/CANCEL/OUTPUT EXIT FLAGS AS DESCRIBED BELOW.         WDPSC
*                                                                 WDPSC
*   IN ANTICIPATION OF IBM FURTHER ENCROACHING THESE AREAS, WE    WDPSC
* HAVE CHAINED A 'PSCBX' FROM THE SECOND WORD OF PSCBU, ALSO      WDPSC
* DESCRIBED BELOW.                                                WDPSC
*                                                                 WDPSC
* PSCBATR1 DS 0XL2                                                WDPSC
*          DS  X                                                  WDPSC
*          DS  X                                                  WDPSC
*              X'08' INIT FIELD DOES NOT NEED TO MATCH (CANCEL)   WDPSC
*              X'04' INIT FIELD DOES NOT NEED TO MATCH (OUTPUT)   WDPSC
*              X'02' SYS  FIELD DOES NOT NEED TO MATCH (OUTPUT)   WDPSC
*              X'01' SYS  FIELD DOES NOT NEED TO MATCH (CANCEL)   WDPSC
*                                                                 WDPSC
*        THE   PSCBX IS CREATED BY IKJEFLD AND CHAINED TO         WDPSC
*              THE PSCB VIA PSCBU+4                               WDPSC
*              IT IS FROM SUBPOOL 234  AND REMAINS THRU SESSION   WDPSC
PSCBX    DS   0XL80                                               WDPSC
PSCBXID  DS  CL8'PSCBX   '  BLOCK ID FIELD                        WDPSC
PSCBXPG  DS  XL32     PERFORM GROUP DATA FROM UADS                WDPSC
PSCBXLA  DS  XL2      LINE ADDR FROM TSB+82                       WDPSC
PSCBXTID DS  CL8      TERMID FROM TSB+104                         WDPSC
PSCBXAN  DS  CL8      ACCOUNT NAME FOR MULTI-ACCT USER            WDPSC
PSCBXRES DS  XL2      RESERVED FOR FUTURE USE (DUE TO ALIGNMENT)  WDPSC
PSCBXSUB DS  F        PTR TO SUBMIT DATA AREA (PASSED TO IKJEFF10)WDPSC
*                     (CALLED PASSWORD PRIOR TO ACF2)             WDPSC
         MEND
