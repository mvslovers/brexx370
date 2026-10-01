TSTLINK  TITLE 'CHANGE THE PARMS OF LINKMVS/LINKPGM (#102)'
* --------------------------------------------------------------------
*   TEST HELPER FOR TEST/ADDRLINK.REXX: A PROGRAM THAT WRITES INTO
*   ITS PARAMETERS, SO THE EXEC CAN CHECK WHAT BREXX WRITES BACK.
*
*   THE FIRST PARAMETER SELECTS THE ENVIRONMENT THE CALL CAME FROM:
*
*   LINKMVS, FIRST VALUE 'LMVS' (HALFWORD LENGTH + VALUE):
*     P2  SET TO 'CHANGED'                (LENGTH 7)
*     P3  SET TO 500 X'S                  (USES THE 500-BYTE SPACE)
*     P4  LENGTH SET TO 0                 (VARIABLE BECOMES NULL)
*     P5  LENGTH SET TO -1, VALUE CHANGED (VARIABLE NOT UPDATED)
*   LINKPGM, FIRST VALUE 'LPGM' (THE VALUE ALONE):
*     P2  FIRST THREE BYTES SET TO 'XYZ'
*
*   ANY OTHER CALL - A SINGLE PARAMETER, AS FROM EXEC PGM= OR THE TSO
*   CALL COMMAND - CHANGES NOTHING. RC IS ALWAYS 0.
* --------------------------------------------------------------------
TSTLINK  CSECT
         STM   R14,R12,12(R13)
         LR    R12,R15
         USING TSTLINK,R12
         LTR   R2,R1               PARAMETER LIST
         BZ    RETURN
         TM    0(R2),X'80'         ONLY ONE PARAMETER?
         BO    RETURN
         L     R3,0(,R2)           P1: THE ENVIRONMENT
         CLC   0(4,R3),=C'LPGM'
         BE    LINKPGM
         CLC   2(4,R3),=C'LMVS'
         BNE   RETURN
* ------------------------------------------------------------ LINKMVS
         L     R3,4(,R2)           P2
         MVC   0(2,R3),=H'7'
         MVC   2(7,R3),=C'CHANGED'
         TM    4(R2),X'80'
         BO    RETURN
         L     R3,8(,R2)           P3
         MVC   0(2,R3),=H'500'
         MVI   2(R3),C'X'
         MVC   3(255,R3),2(R3)     PROPAGATE: BYTES 3..257
         MVC   258(244,R3),257(R3) BYTES 258..501
         TM    8(R2),X'80'
         BO    RETURN
         L     R3,12(,R2)          P4
         MVC   0(2,R3),=H'0'
         TM    12(R2),X'80'
         BO    RETURN
         L     R3,16(,R2)          P5
         MVC   0(2,R3),=H'-1'
         MVC   2(3,R3),=C'ZZZ'
         B     RETURN
* ------------------------------------------------------------ LINKPGM
LINKPGM  L     R3,4(,R2)           P2
         MVC   0(3,R3),=C'XYZ'
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
         END   TSTLINK
