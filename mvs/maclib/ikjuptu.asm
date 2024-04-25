         MACRO
&LAB1    IKJUPTU
         ORG   UPTUSER
UPTU     DS    0CL10                    WDPSC AREA                WDPSC
UPTU1    DS    X                        OUR FLAG BYTE 1           WDPSC
UPTUNF   EQU   X'80'  SUBMIT EXIT SHOULD ADD NOTIFY OPERAND       WDPSC
UPTUAF   EQU   X'40'  PAN EXIT SHOULD NOT AUDIT COMMANDS          WDPSC
UPTUAAF  EQU   X'20'  PAN WILL AUDIT ALL CMDS - IF 0,CHANGES ONLY WDPSC
UPTUPF   EQU   X'10'  LOGON EXIT WILL ADD PREFIX= TO EXEC PROD1   WDPSC
UPTUSF   EQU   X'08'  LOGON EXIT WILL ADD STEPLIB DD CARD         WDPSC
UPTUNM   EQU   X'04'  DO NOT LIST MAIL AT LOGON TIME              WDPSC
UPTUNC1  EQU   X'02'  DO NOT ADD USERCAT1 TO STEPCAT              WDPSC
UPTUDPF  EQU   X'01'  DIALOG PREFIX HAS BEEN ENCODED IN UPT       WDPSC
*                                                                 WDPSC
UPTU2    DS    X                        OUR FLAG BYTE 2           WDPSC
UPTUSPF  EQU   X'80'  LOGON WITH ISPPLIB (PANELS=)                WDPSC
UPTUSSF  EQU   X'40'  LOGON WITH ISPSLIB (SKELS=)                 WDPSC
UPTUSMF  EQU   X'20'  LOGON WITH ISPMLIB (MSGS=)                  WDPSC
UPTUSAF  EQU   X'10'  DIALOG PREFIX INCLUDES SUBAGENCY            WDPSC
*                                                                 WDPSC
UPTUDPA  DS    XL3    DIALOG PREFIX AREA FOR ISP LIB DD CARDS     WDPSC
*                                                                 WDPSC
UPTU67   DS    XL2    # OF SECONDS TO EXTEND BEFORE 322 ABENDING  WDPSC
*                     0=DEFAULT, -1=DON'T EXTEND                  WDPSC
*                                                                 WDPSC
UPTU8    DS    X      # OF USERS DEFAULT STEPCAT 0=NONE (CATTABLE)WDPSC
UPTU9    DS    X      USERS DEFAULT TIME LIMIT MINUTES            WDPSC
UPTU10   DS    X      USERS DEFAULT TIME LIMIT SECONDS            WDPSC
         ORG
         MEND
