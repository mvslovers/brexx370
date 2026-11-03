TSTNMEAS TITLE 'COST OF A FULL N WALK OVER THE VARIABLES OF THE EXEC'
* --------------------------------------------------------------------
*   MEASUREMENT HELPER (MVS-1559, #602).  LINKMVS WITH TWO WORDS,
*   EACH ONE A PARAMETER:
*   'PASS n'  RESET THE N SEQUENCE, THEN CALL THE IRXEXCOM ROUTINE
*             FROM THE IRXEXTE WITH CODE N UNTIL SHVLVAR (n = 0) OR n
*             CALLS HAVE BEEN MADE.  EACH CALL IS TIMED WITH STCK.
*   'BASE n'  n CALLS WITH AN INVALID FUNCTION CODE: THE COST OF THE
*             CALL ITSELF (LINKAGE, PARAMETER LIST, STCK PAIR).
*
*   THE RESULT GOES INTO VARIABLES OF THE EXEC, AFTER THE WALK:
*     NMCNT   CALLS COUNTED (WITHOUT THE ONE THAT SAID SHVLVAR)
*     NMTOT   SUM OF THE CALL TIMES, 1/16 MICROSECOND
*     NMWALL  WALL TIME OF THE LOOP, 1/16 MICROSECOND
*     NMMAXD  THE SLOWEST CALL, 1/16 MICROSECOND
*     NMLAST  THE CALL THAT SAID SHVLVAR, 1/16 MICROSECOND
*     NMNB    NUMBER OF BUCKETS OF 100 CALLS
*     NMB.i   SUM OF THE CALL TIMES OF BUCKET i, 1/16 MICROSECOND
*   RC 0 WHEN ALL WENT AS EXPECTED, 1-5 THE LOOKUP OF THE ENVIRONMENT,
*   20 A CALL ENDED WITH A NON-ZERO R15, 21 MORE CALLS THAN BUCKETS,
*   22 A RESULT COULD NOT BE STORED, 9 A BAD MODE.
*   NAME BUFFER 256, VALUE BUFFER 65536: NOTHING IS TRUNCATED.
* --------------------------------------------------------------------
TSTNMEAS CSECT
         STM   R14,R12,12(R13)
         LR    R12,R15
         USING TSTNMEAS,R12
         LA    R2,SAVE
         ST    R13,4(,R2)
         ST    R2,8(,R13)
         LR    R13,R2
         LTR   R2,R1               PARAMETER LIST
         BZ    BADMODE
         L     R3,0(,R2)           P1: LENGTH + TEXT
         LH    R4,0(,R3)
         ST    R4,PLEN
         LA    R3,2(,R3)
         CH    R4,=H'4'
         BL    BADMODE
         MVI   CODE,C'N'
         CLC   0(4,R3),=C'PASS'
         BE    MODEOK
         MVI   CODE,C'Z'
         CLC   0(4,R3),=C'BASE'
         BNE   BADMODE
MODEOK   SR    R5,R5               THE MAXIMUM NUMBER OF CALLS
         TM    0(R2),X'80'         P1 THE LAST PARAMETER?
         BO    PARSED
         L     R3,4(,R2)           P2: LENGTH + DIGITS
         LH    R4,0(,R3)
         ST    R4,PLEN
         LA    R3,2(,R3)
         SR    R6,R6
PARSE    C     R6,PLEN
         BNL   PARSED
         SR    R7,R7
         IC    R7,0(R6,R3)
         S     R7,=F'240'
         BM    PARSED
         C     R7,=F'9'
         BH    PARSED
         MH    R5,=H'10'
         AR    R5,R7
         LA    R6,1(,R6)
         B     PARSE
PARSED   ST    R5,MAXCALLS
* ---- THE ENVIRONMENT: ECTENVBK -> ENVBLOCK -> IRXEXTE -> IRXEXCOM
         BAL   R10,FINDECT
         LTR   R4,R4
         BNZ   HAVEECT
         LA    R15,1
         B     EXIT
HAVEECT  L     R5,48(,R4)          ECTENVBK
         LTR   R5,R5
         BNZ   HAVEENV
         LA    R15,2
         B     EXIT
HAVEENV  CLC   0(8,R5),=C'ENVBLOCK'
         BE    ISENV
         LA    R15,3
         B     EXIT
ISENV    L     R6,28(,R5)          ENVBLOCK_IRXEXTE
         LTR   R6,R6
         BNZ   HAVEXTE
         LA    R15,4
         B     EXIT
HAVEXTE  L     R7,16(,R6)          IRXEXTE: 4TH ENTRY, IRXEXCOM
         LTR   R7,R7
         BNZ   HAVEXCOM
         LA    R15,5
         B     EXIT
HAVEXCOM ST    R7,EXCOMA
         LA    R1,SHV
         O     R1,=X'80000000'
         ST    R1,PL+12
* ---- A REQUEST THAT IS NOT N: THE SEQUENCE STARTS ANEW
         XC    SHV,SHV
         MVI   SHV+8,C'f'
         LA    R1,NRESET
         ST    R1,SHV+16
         LA    R1,7
         ST    R1,SHV+20
         L     R1,=A(VBUF)
         ST    R1,SHV+24
         LA    R1,64
         ST    R1,SHV+12
         LA    R1,PL
         L     R15,EXCOMA
         BALR  R14,R15
* ---- CLEAR THE BUCKETS
         L     R2,=A(BUCK)
         LA    R3,16
CLRB     XC    0(256,R2),0(R2)
         LA    R2,256(,R2)
         BCT   R3,CLRB
         SR    R0,R0
         ST    R0,TOT
         ST    R0,MAXD
         ST    R0,LASTD
         ST    R0,RCODE
         SR    R8,R8               R8 = CALLS SO FAR
         STCK  W0
* ---- THE LOOP
LOOP     L     R1,MAXCALLS
         LTR   R1,R1
         BZ    NOLIM
         CR    R8,R1
         BNL   DONE
NOLIM    C     R8,=F'102400'
         BL    ROOM
         MVC   RCODE,=F'21'
         B     DONE
ROOM     XC    SHV,SHV
         MVC   SHV+8(1),CODE
         MVC   SHV+4(4),=F'256'    SHVUSER: LENGTH OF THE NAME BUFFER
         MVC   SHV+12(4),=F'65536' SHVBUFL
         LA    R1,NBUF
         ST    R1,SHV+16
         L     R1,=A(VBUF)
         ST    R1,SHV+24
         STCK  T0
         LA    R1,PL
         L     R15,EXCOMA
         BALR  R14,R15
         STCK  T1
         LR    R7,R15
         L     R2,T1+4
         SL    R2,T0+4             LOW WORD: 2**-12 MICROSECOND
         SRL   R2,8                1/16 MICROSECOND
         ST    R2,DELTAW
         CLI   CODE,C'Z'
         BE    COUNT
         TM    SHV+9,X'02'         SHVLVAR
         BNO   NOTLAST
         ST    R2,LASTD
         B     DONE
NOTLAST  LTR   R7,R7
         BZ    COUNT
         MVC   RCODE,=F'20'
         B     DONE
COUNT    L     R3,TOT
         AL    R3,DELTAW
         ST    R3,TOT
         CL    R2,MAXD
         BNH   NOMAX
         ST    R2,MAXD
NOMAX    LR    R5,R8
         SR    R4,R4
         D     R4,=F'100'          R5 = BUCKET NUMBER
         SLL   R5,2
         L     R6,=A(BUCK)
         AR    R6,R5
         L     R3,0(,R6)
         AL    R3,DELTAW
         ST    R3,0(,R6)
         LA    R8,1(,R8)
         B     LOOP
* ---- THE WALL TIME OF THE LOOP
DONE     STCK  W1
         L     R2,W1
         L     R3,W1+4
         L     R4,W1+4
         SL    R3,W0+4
         CL    R4,W0+4
         BNL   NOBORR
         BCTR  R2,0
NOBORR   SL    R2,W0
         SRDL  R2,8                R3 = 1/16 MICROSECOND
         ST    R3,WALL
* ---- THE RESULT INTO THE VARIABLES
         LA    R1,NNMCNT
         LA    R2,5
         LR    R3,R8
         BAL   R9,SETNUM
         LA    R1,NNMTOT
         LA    R2,5
         L     R3,TOT
         BAL   R9,SETNUM
         LA    R1,NNMWALL
         LA    R2,6
         L     R3,WALL
         BAL   R9,SETNUM
         LA    R1,NNMMAXD
         LA    R2,6
         L     R3,MAXD
         BAL   R9,SETNUM
         LA    R1,NNMLAST
         LA    R2,6
         L     R3,LASTD
         BAL   R9,SETNUM
         LA    R3,99(,R8)          NUMBER OF BUCKETS
         SR    R2,R2
         LR    R5,R3
         SR    R4,R4
         D     R4,=F'100'
         LR    R11,R5              R11 = NB
         ST    R11,NB
         LA    R1,NNMNB
         LA    R2,4
         LR    R3,R11
         BAL   R9,SETNUM
         LA    R10,1               R10 = BUCKET NUMBER
BLOOP    C     R10,NB
         BH    BDONE
         LR    R3,R10
         BAL   R6,DECOUT
         MVC   NAMEW(4),=C'NMB.'
         BCTR  R5,0
         EX    R5,MVCDIG
         LA    R2,5(,R5)           4 + LENGTH
         LA    R1,NAMEW
         LR    R3,R10
         BCTR  R3,0
         SLL   R3,2
         L     R4,=A(BUCK)
         AR    R4,R3
         L     R3,0(,R4)
         BAL   R9,SETNUM
         LA    R10,1(,R10)
         B     BLOOP
MVCDIG   MVC   NAMEW+4(1),0(R4)
BDONE    L     R15,RCODE
         B     EXIT
BADMODE  LA    R15,9
EXIT     L     R13,4(,R13)
         ST    R15,16(,R13)
         LM    R14,R12,12(R13)
         BR    R14
*
* --------------------------------------------------------------------
* DECOUT: R3 = VALUE.  R4 = START OF ITS DECIMAL DIGITS, R5 = LENGTH.
* RETURN IN R6.
* --------------------------------------------------------------------
DECOUT   CVD   R3,DW
         UNPK  DEC(15),DW(8)
         OI    DEC+14,X'F0'
         LA    R4,DEC
         LA    R5,15
DZLOOP   CLI   0(R4),C'0'
         BNE   DZDONE
         CH    R5,=H'1'
         BE    DZDONE
         LA    R4,1(,R4)
         BCTR  R5,0
         B     DZLOOP
DZDONE   BR    R6
*
* --------------------------------------------------------------------
* SETNUM: SET THE VARIABLE R1 (NAME), R2 (LENGTH) TO THE NUMBER R3.
* RETURN IN R9.  USES R4-R6.
* --------------------------------------------------------------------
SETNUM   ST    R1,SNAME
         ST    R2,SNAML
         BAL   R6,DECOUT
         XC    SHV,SHV
         MVI   SHV+8,C's'
         MVC   SHV+16(4),SNAME
         MVC   SHV+20(4),SNAML
         ST    R4,SHV+24
         ST    R5,SHV+28
         LA    R1,PL
         L     R15,EXCOMA
         BALR  R14,R15
         LTR   R15,R15
         BZR   R9
         MVC   RCODE,=F'22'
         BR    R9
*
* --------------------------------------------------------------------
* FINDECT: R4 = THE ECT OF THE TASK, OR 0.  RETURN IN R10.
* --------------------------------------------------------------------
FINDECT  SR    R4,R4
         L     R4,548(,R4)         PSAAOLD
         LTR   R4,R4
         BZR   R10
         L     R4,108(,R4)         ASCBASXB
         LTR   R4,R4
         BZR   R10
         L     R4,20(,R4)          ASXBLWA
         LTR   R4,R4
         BZR   R10
         L     R4,32(,R4)          LWAPECT
         BR    R10
         LTORG
SAVE     DS    18F
PLEN     DS    F
MAXCALLS DS    F
EXCOMA   DS    F
RCODE    DS    F
TOT      DS    F
MAXD     DS    F
LASTD    DS    F
WALL     DS    F
DELTAW   DS    F
NB       DS    F
SNAME    DS    F
SNAML    DS    F
CODE     DS    C
         DS    0D
T0       DS    D
T1       DS    D
W0       DS    D
W1       DS    D
DW       DS    D
DEC      DS    CL16
SHV      DS    8F
PL       DC    A(IDN),A(0),A(0),A(0)
IDN      DC    C'IRXEXCOM'
NRESET   DC    C'NMRESET'
NNMCNT   DC    C'NMCNT'
NNMTOT   DC    C'NMTOT'
NNMWALL  DC    C'NMWALL'
NNMMAXD  DC    C'NMMAXD'
NNMLAST  DC    C'NMLAST'
NNMNB    DC    C'NMNB'
NAMEW    DS    CL16
NBUF     DS    CL256
         DS    0D
BUCK     DS    1024F
VBUF     DS    CL65536
R0       EQU   0
R1       EQU   1
R2       EQU   2
R3       EQU   3
R4       EQU   4
R5       EQU   5
R6       EQU   6
R7       EQU   7
R8       EQU   8
R9       EQU   9
R10      EQU   10
R11      EQU   11
R12      EQU   12
R13      EQU   13
R14      EQU   14
R15      EQU   15
         END   TSTNMEAS
