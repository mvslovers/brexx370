TSTXSENT TITLE 'SET AND CHECK ECTENVBK AROUND AN EXEC (#602)'
* --------------------------------------------------------------------
*   TEST HELPER FOR TEST/XCOM*.REXX: A TSO COMMAND THAT PUTS A KNOWN
*   VALUE INTO ECTENVBK BEFORE BREXX RUNS AND CHECKS, AFTER THE EXEC
*   HAS ENDED, THAT BREXX HAS PUT IT BACK.  THE KNOWN VALUE IS THE
*   ADDRESS OF THE ECT ITSELF: READABLE, NEVER AN ENVBLOCK.
*
*   OPERAND:
*     SET    ECTENVBK = ADDRESS OF THE ECT                    RC 0
*     CHK    ECTENVBK MUST BE THE ADDRESS OF THE ECT          RC 0/12
*     CHKF   ECTENVBK MUST BE X'00F0F000', WHAT TSTXCOM FRGN
*            LEFT THERE (BREXX MAY NOT OVERWRITE A FOREIGN
*            VALUE)                                           RC 0/12
*
*   EVERY CALL WRITES THE VALUE IT FOUND TO THE JOB LOG (WTO).
*   RC 16: NO ECT, RC 20: UNKNOWN OPERAND.  A CALL FROM A PARM= OR
*   THE TSO CALL COMMAND (SMOKE RUN OF MBT TEST --MVS) RETURNS RC 0.
* --------------------------------------------------------------------
TSTXSENT CSECT
         STM   R14,R12,12(R13)
         LR    R12,R15
         USING TSTXSENT,R12
         LR    R2,R1
         TM    0(R2),X'80'         AN OS PARAMETER LIST (PARM=, CALL),
         BO    EXIT0               NOT THE CPPL OF A TSO COMMAND: RC 0
         L     R3,12(,R2)          ECT
         LTR   R3,R3
         BZ    NOECT
         L     R4,0(,R2)           CBUF
         LH    R5,2(,R4)           OFFSET OF THE OPERAND
         LA    R5,4(R5,R4)         THE OPERAND
         CLC   0(3,R5),=C'SET'
         BE    DOSET
         CLC   0(4,R5),=C'CHKF'
         BE    DOCHKF
         CLC   0(3,R5),=C'CHK'
         BE    DOCHK
         LA    R15,20
         B     EXIT
NOECT    LA    R15,16
         B     EXIT
DOSET    ST    R3,48(,R3)          ECTENVBK = ADDRESS OF THE ECT
         L     R7,48(,R3)
         LR    R6,R7
         MVC   TEXT(8),=C'SET     '
         B     COMPARE
DOCHK    LR    R6,R3
         MVC   TEXT(8),=C'CHK     '
         B     COMPARE
DOCHKF   L     R6,=X'00F0F000'
         MVC   TEXT(8),=C'CHKF    '
COMPARE  L     R7,48(,R3)          ECTENVBK
         ST    R7,WRK
         UNPK  HEXO(9),WRK(5)
         TR    HEXO(8),HEXTAB-240
         MVI   HEXO+8,C' '
         SR    R8,R8               THE ECT OF THE LWA, TO COMPARE
         L     R8,548(,R8)
         L     R8,108(,R8)
         L     R8,20(,R8)
         LTR   R8,R8
         BZ    NOLWA
         L     R8,32(,R8)
NOLWA    ST    R8,WRK
         UNPK  HEXL(9),WRK(5)
         TR    HEXL(8),HEXTAB-240
         MVI   HEXL+8,C' '
         LA    R1,WTOL
         SVC   35
         SR    R15,R15
         CR    R7,R6
         BE    EXIT
         LA    R15,12
EXIT     ST    R15,16(,R13)
         LM    R14,R12,12(R13)
         BR    R14
EXIT0    SR    R15,R15
         B     EXIT
WTOL     DC    AL2(WTOEND-WTOL),H'0'
         DC    C'TSTXSENT '
TEXT     DC    CL8' '
         DC    C' ECTENVBK='
HEXO     DC    CL9' '
         DC    C' LWAECT='
HEXL     DC    CL9' '
WTOEND   EQU   *
WRK      DC    D'0'
         DC    XL240'00'           HEXTAB-240 MUST BE IN RANGE
HEXTAB   DC    C'0123456789ABCDEF'
         LTORG
R1       EQU   1
R2       EQU   2
R3       EQU   3
R4       EQU   4
R5       EQU   5
R6       EQU   6
R7       EQU   7
R8       EQU   8
R12      EQU   12
R13      EQU   13
R14      EQU   14
R15      EQU   15
         END   TSTXSENT
