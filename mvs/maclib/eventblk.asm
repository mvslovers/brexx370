       MACRO
       EVENTBLK
EVENTBLK DSECT                                                          00059
*    SOURCE FOR EVENTBLK FOUND IN PANSPACE SECEXIT  PAN REL 11.D
*          USED BY THE ACF2/PANVALET INTERFACE
*                                                                       00056
*        EVENT BLOCK                                                    00057
*                                                                       00058
EVEVENT  DS    CL8           EVENT-ID -- THE NAME OF THE EVENT          00060
*                            (E.G. INIT,$OPEN001,$MEM001,TERM ETC...)   00061
EVEXTYPE DS    CL8           EXIT TYPE -- ANY USER EXIT IDENTIFIER      00062
*                            (GIVEN ON THE EXIT TYPE= MACRO OR BLANKS)  00063
EVRESPON DS    CL1           RESPONSE CODE -- INITIALLY 'C', SET BY     00064
*                            USER EXIT TO:                              00065
CONTINUE EQU   C'C'          'C' - CONTINUE NORMAL PROCESSING           00066
ABORT    EQU   C'A'          'A' - ABORT PANVALET PROCESSING            00067
TERMINAT EQU   C'T'          'T' - TERMINATE THIS EXIT                  00068
*                                  (PANVALET WILL DISCONNECT THE EXIT   00069
*                                  FROM ALL THE EVENTS FOR THE          00070
*                                  DURATION OF THE RUNNING TASK ONLY    00071
*                                  AND PROCEEDS AS IF 'C' HAD BEEN      00072
*                                  SPECIFIED.  THIS INCLUDES THE TERM   00073
*                                  EVENT.  AN EXIT RESPONDING WITH A    00074
*                                  "T" SHOULD DO ALL CLEANUP REQUIRED   00075
*                                  BEFORE RETURNING.  OTHER EXIT(S),    00076
*                                  IF ANY, WILL CONTINUE TO BE CALLED   00077
*                                  BY PANVALET.)                        00078
VERIFY   EQU   C'V'          'V' - ACTIVATE VERIFICATION                00079
*                                  (VALID ONLY FROM THE INIT EVENT;     00080
*                                  SEE THE INIT EVENT FOR DETAILS)      00081
*        DS    CL3           RESERVED                                   00082
EVUSER   DS    F             USER FULLWORD -- INITIALLY ZEROES; TO BE   00083
*                            USED BY USER AS DESIRED (E.G. ADDRESS OF   00084
*                            A WORK AREA ETC...); THIS FIELD IS UNIQUE  00085
*                            TO EACH EXIT DEFINED BY A EXIT MACRO       00086
        MEND
