TSTABND  TITLE 'ABEND S0C1 IN A LINKED PROGRAM (#191)'
* --------------------------------------------------------------------
*   TEST HELPER FOR TEST/LNKABND.REXX AND TEST/PRIVABND.REXX.
*
*   LINKMVS WITH TWO VARIABLES, THE FIRST 'ABND' (HALFWORD LENGTH +
*   VALUE): ABEND S0C1 (OPERATION EXCEPTION). BREXX LINKS IT IN ITS
*   OWN TASK, SO BREXX'S ESTAE CATCHES THE ABEND AND BREXX ENDS WITH
*   RC 8. NOTHING IS WRITTEN ANYWHERE, SO IT IS SAFE IN KEY 0 TOO.
*
*   ANY OTHER CALL - A SINGLE PARAMETER, AS FROM EXEC PGM= OR THE TSO
*   CALL COMMAND OF MAKE TEST-MVS - RETURNS RC 0.
* --------------------------------------------------------------------
TSTABND  CSECT
         STM   R14,R12,12(R13)
         LR    R12,R15
         USING TSTABND,R12
         LTR   R2,R1               PARAMETER LIST
         BZ    RETURN
         TM    0(R2),X'80'         ONLY ONE PARAMETER?
         BO    RETURN
         L     R3,0(,R2)           P1
         CLC   2(4,R3),=C'ABND'
         BNE   RETURN
         DC    H'0'                OPERATION EXCEPTION -> S0C1
RETURN   LM    R14,R12,12(R13)
         SR    R15,R15
         BR    R14
         LTORG
R1       EQU   1
R2       EQU   2
R3       EQU   3
R12      EQU   12
R13      EQU   13
R14      EQU   14
R15      EQU   15
         END   TSTABND
