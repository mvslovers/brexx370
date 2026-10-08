TSTEFUN  TITLE 'EXTERNAL FUNCTION: DESCRIBE THE ARGUMENTS (#386)'
*
* Called as a REXX function (EFPL in R1). Returns the number of
* entries in the argument table as three digits, then one letter
* per entry: N for an address of 0, E for a length of 0, V for a
* value. For test/extfun.rexx.
*
TSTEFUN  CSECT
         STM   R14,R12,12(R13)
         LR    R12,R15
         USING TSTEFUN,R12
         LTR   R1,R1               NO PARAMETER LIST
         BZ    RC0
         TM    0(R1),X'80'         A PROGRAM'S PARM LIST (TEST-MVS)
         BO    RC0
         L     R2,16(,R1)          EFPLARG: THE ARGUMENT TABLE
         L     R3,20(,R1)          EFPLEVAL: ADDRESS OF THE EVALBLOCK
         L     R3,0(,R3)           ADDRESS
         LA    R4,16+3(,R3)        RESULT LETTERS AFTER THE COUNT
         SR    R5,R5               ENTRY COUNT
LOOP     CLC   0(4,R2),=X'FFFFFFFF' END OF THE TABLE?
         BE    DONE
         LA    R5,1(,R5)
         MVI   0(R4),C'V'
         L     R6,0(,R2)           ARGUMENT ADDRESS
         LTR   R6,R6
         BNZ   HASADDR
         MVI   0(R4),C'N'
         B     NEXT
HASADDR  L     R7,4(,R2)           ARGUMENT LENGTH
         LTR   R7,R7
         BNZ   NEXT
         MVI   0(R4),C'E'
NEXT     LA    R4,1(,R4)
         LA    R2,8(,R2)
         C     R5,=F'64'           NEVER MORE THAN 64
         BL    LOOP
DONE     CVD   R5,DWORK
         UNPK  16(3,R3),DWORK+6(2)
         OI    16+2(R3),X'F0'      ZONE OF THE LAST DIGIT
         LR    R6,R4
         SR    R6,R3
         S     R6,=F'16'
         ST    R6,8(,R3)           EVLEN
RC0      LM    R14,R12,12(R13)
         SR    R15,R15
         BR    R14
         LTORG
DWORK    DS    D
R1       EQU   1
R2       EQU   2
R3       EQU   3
R4       EQU   4
R5       EQU   5
R6       EQU   6
R7       EQU   7
R12      EQU   12
R13      EQU   13
R14      EQU   14
R15      EQU   15
         END   TSTEFUN
