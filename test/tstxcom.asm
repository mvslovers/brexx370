TSTXCOM  TITLE 'VARIABLES OF THE RUNNING EXEC VIA IRXEXTE (#602)'
* --------------------------------------------------------------------
*   TEST HELPER FOR TEST/XCOM*.REXX.  LINKMVS WITH ONE VARIABLE, THE
*   MODE (HALFWORD LENGTH + VALUE):
*
*   VARS  FIND THE ENVBLOCK THROUGH ECTENVBK (PSAAOLD - ASCBASXB -
*         ASXBLWA - LWAPECT - ECTENVBK), TAKE THE ADDRESS OF THE
*         VARIABLE ROUTINE FROM THE IRXEXTE VECTOR AND CALL IT: SET,
* FETCH AND DROP VARIABLES OF THE EXEC THAT IS RUNNING, SYMBOLIC
*         AND DIRECT, A CHAIN WITH A BAD BLOCK, 'P' AND 'N' (THE
*         NAMES OF ALL VARIABLES GO TO THE VARIABLE XCLIST).  THE
*         EXEC CHECKS WHAT THE ROUTINE DID.
*   BAD   ECTENVBK = X'00BAD000'   (THE EXEC FAILED; THE CHECK AFTER
*                                   IT CANNOT PASS)
*   FRGN  ECTENVBK = X'00F0F000'   (A VALUE THAT IS NOT BREXX'S: BREXX
*                                   MUST LEAVE IT ALONE AT THE END)
*
*   RC 0 WHEN ALL WENT AS EXPECTED.  OTHERWISE STEP*10 + CLASS WITH
*   CLASS 1 R15, 2 SHVRET, 3 SHVVALL, 4 VALUE, 5 RETURN CODE WORD;
*   STEPS 91..99 ARE THE CHAIN, N AND THE FINAL SET; 1..8 CLASS 0 ARE
*   THE LOOKUP OF THE ENVIRONMENT (NO ECT, ECTENVBK 0, NOT AN ENVBLOCK,
*   NO IRXEXTE, NO ROUTINE IN IT).  ANY OTHER CALL RETURNS RC 0.
*   THE LOAD MODULE IS NOT REENTRANT: IT KEEPS ITS DATA IN THE CSECT.
* --------------------------------------------------------------------
TSTXCOM  CSECT
         STM   R14,R12,12(R13)
         LR    R12,R15
         USING TSTXCOM,R12
         LA    R2,SAVE
         ST    R13,4(,R2)
         ST    R2,8(,R13)
         LR    R13,R2
         LTR   R2,R1               PARAMETER LIST
         BZ    BADMODE
         L     R3,0(,R2)           P1: THE MODE
         CLC   2(4,R3),=C'VARS'
         BE    VARS
         CLC   2(4,R3),=C'BAD '
         BE    DOBAD
         CLC   2(4,R3),=C'FRGN'
         BE    DOFRGN
BADMODE  SR    R15,R15             ANY OTHER CALL (SMOKE RUN): RC 0
         B     EXIT
* ---------------------------------------------------------------- BAD
DOBAD    BAL   R10,FINDECT
         LTR   R4,R4
         BZ    NOECT
         L     R1,=X'00BAD000'
         ST    R1,48(,R4)
         SR    R15,R15
         B     EXIT
DOFRGN   BAL   R10,FINDECT
         LTR   R4,R4
         BZ    NOECT
         L     R1,=X'00F0F000'
         ST    R1,48(,R4)
         SR    R15,R15
         B     EXIT
NOECT    LA    R15,1
         B     EXIT
* ---------------------------------------------------------------- VARS
VARS     BAL   R10,FINDECT
         LTR   R4,R4
         BZ    NOECT               NO ECT: NOT A TSO COMMAND
         L     R5,48(,R4)          ECTENVBK
         LTR   R5,R5
         BNZ   HAVEENV
         LA    R15,2               ECTENVBK IS 0
         B     EXIT
HAVEENV  CLC   0(8,R5),=C'ENVBLOCK'
         BE    ISENV
         LA    R15,3               NOT AN ENVBLOCK
         B     EXIT
ISENV    ST    R5,ENVA
         L     R6,28(,R5)          ENVBLOCK_IRXEXTE
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
         MVI   VBUF,X'FF'
         MVC   VBUF+1(63),VBUF
* ---- THE TABLE
         LA    R9,STEPS
STEPLOOP CLI   0(R9),0
         BE    STEPSEND
         XC    SHV,SHV
         MVC   SHV+8(1),0(R9)      SHVCODE
         LH    R1,16(,R9)
         ST    R1,SHV+12           SHVBUFL
         MVC   SHV+16(4),4(R9)     SHVNAMA
         LH    R1,8(,R9)
         ST    R1,SHV+20           SHVNAML
         LH    R1,10(,R9)
         ST    R1,SHV+28           SHVVALL
         MVC   SHV+24(4),12(R9)    SHVVALA
         CLI   0(R9),C'f'
         BE    ISFETCH
         CLI   0(R9),C'F'
         BE    ISFETCH
         CLI   0(R9),C'P'
         BNE   NOFETCH
ISFETCH  LA    R1,VBUF
         ST    R1,SHV+24
         MVI   VBUF,X'FF'
         MVC   VBUF+1(63),VBUF
NOFETCH  CLI   26(R9),1
         BE    FORM4
         BAL   R10,CALL6
         B     CALLED
FORM4    BAL   R10,CALL4
CALLED   LR    R8,R15              R15 OF THE CALL
         LH    R0,24(,R9)          STEP NUMBER
         MH    R0,=H'10'
         LR    R6,R0               STEP*10
         LH    R1,2(,R9)
         CR    R8,R1               EXPECTED R15?
         BNE   FAIL1
         CLI   26(R9),1
         BE    NORCW
         LTR   R8,R8
         BZ    NORCW
         C     R8,RCW              R15 ALSO IN THE 6TH PARAMETER
         BNE   FAIL5
NORCW    CLC   SHV+9(1),1(R9)      EXPECTED SHVRET?
         BNE   FAIL2
         CLI   0(R9),C'f'
         BE    CHKVAL
         CLI   0(R9),C'F'
         BE    CHKVAL
         CLI   0(R9),C'P'
         BNE   NEXTSTEP
CHKVAL   LH    R2,18(,R9)          EXPECTED SHVVALL
         LTR   R2,R2
         BM    CHKSPEC             -1 NOT CHECKED, -2 NON-EMPTY
         L     R1,SHV+28
         CR    R1,R2
         BNE   FAIL3
         L     R3,SHV+12           SHVBUFL
         CR    R3,R2
         BL    SHORTBUF
         LR    R3,R2               COMPARE THE FULL VALUE
SHORTBUF LTR   R3,R3
         BZ    CHKEND
         BCTR  R3,0
         L     R4,20(,R9)
         EX    R3,CLCVAL
         BNE   FAIL4
         LA    R3,1(,R3)
CHKEND   LA    R4,VBUF(R3)
         CLI   0(R4),X'FF'         NOTHING WRITTEN BEHIND THE VALUE
         BNE   FAIL4
         B     NEXTSTEP
CHKSPEC  CH    R2,=H'-2'
         BNE   NEXTSTEP
         L     R1,SHV+28
         LTR   R1,R1
         BNP   FAIL3
NEXTSTEP LA    R9,32(,R9)
         B     STEPLOOP
FAIL1    LA    R15,1(,R6)
         B     EXIT
FAIL2    LA    R15,2(,R6)
         B     EXIT
FAIL3    LA    R15,3(,R6)
         B     EXIT
FAIL4    LA    R15,4(,R6)
         B     EXIT
FAIL5    LA    R15,5(,R6)
         B     EXIT
CLCVAL   CLC   VBUF(1),0(R4)
* ---- A CHAIN OF THREE BLOCKS, THE MIDDLE ONE WITH A BAD NAME
STEPSEND LA    R1,CHA
         ST    R1,CHAIN
         BAL   R10,CALLCH
         LA    R6,910
         C     R15,=F'8'           THE OR OF THE ERROR FLAGS
         BNE   FAIL1L
         LA    R6,920
         CLI   CHA+9,X'01'         NEW
         BNE   FAIL2L
         CLI   CHB+9,X'08'         BAD NAME
         BNE   FAIL2L
         LA    R6,930
         CLI   CHC+9,X'01'         ...BUT THE LAST ONE WAS DONE
         BNE   FAIL2L
         B     NWALK
FAIL1L   LA    R15,1(,R6)
         B     EXIT
FAIL2L   LA    R15,2(,R6)
         B     EXIT
* ---- N: THE NAMES OF ALL VARIABLES
NWALK    MVI   LIST,C' '
         MVC   LIST+1(255),LIST
         MVC   LIST+256(244),LIST
         LA    R8,LIST
         LA    R9,200              LOOP GUARD
NLOOP    XC    SHV,SHV
         MVI   SHV+8,C'N'
         LA    R1,40
         ST    R1,SHV+4            SHVUSER: LENGTH OF THE NAME BUFFER
         LA    R1,64
         ST    R1,SHV+12           SHVBUFL
         LA    R1,NBUF
         ST    R1,SHV+16
         LA    R1,VBUF
         ST    R1,SHV+24
         BAL   R10,CALL6
         LTR   R15,R15
         BNZ   NFAIL1
         TM    SHV+9,X'02'         SHVLVAR
         BO    NDONE
         L     R5,SHV+20           SHVNAML
         LTR   R5,R5
         BNP   NFAIL2
         C     R5,=F'40'
         BH    NFAIL2
         LA    R1,LISTEND
         LA    R2,2(R5,R8)
         CR    R2,R1
         BH    NFAIL2
         BCTR  R5,0
         EX    R5,MVCNAME
         LA    R8,2(R5,R8)
         BCT   R9,NLOOP
NFAIL2   LA    R15,952
         B     EXIT
NFAIL1   LA    R15,951
         B     EXIT
MVCNAME  MVC   0(1,R8),NBUF
NDONE    LA    R1,LIST
         SR    R8,R1               LENGTH OF THE LIST
         BNP   NFAIL2
         XC    SHV,SHV
         MVI   SHV+8,C's'
         LA    R1,NXCLIST
         ST    R1,SHV+16
         LA    R1,6
         ST    R1,SHV+20
         LA    R1,LIST
         ST    R1,SHV+24
         ST    R8,SHV+28
         BAL   R10,CALL6
         LTR   R15,R15
         BNZ   SFAIL
         SR    R15,R15
         B     EXIT
SFAIL    LA    R15,971
EXIT     L     R13,4(,R13)
         ST    R15,16(,R13)
         LM    R14,R12,12(R13)
         BR    R14
*
* --------------------------------------------------------------------
* FINDECT: R4 = THE ECT OF THE TASK, OR 0.  RETURN IN R10.
*
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
*
* --------------------------------------------------------------------
* CALL6 / CALL4 / CALLCH: IRXEXCOM CALL WITH SHV (OR THE CHAIN), RETURN
* IN R10.  CALL6 PASSES THE ENVBLOCK AND A RETURN CODE WORD, CALL4 NOT.
*
* --------------------------------------------------------------------
CALL6    ST    R10,SAVE10
         LA    R1,SHV
         ST    R1,PL+12
         MVC   PL+16(4),ENVA
         LA    R1,RCW
         O     R1,=X'80000000'
         ST    R1,PL+20
         MVC   RCW,=F'-77'
         B     DOCALL
CALL4    ST    R10,SAVE10
         LA    R1,SHV
         O     R1,=X'80000000'
         ST    R1,PL+12
DOCALL   LA    R1,PL
         L     R15,EXCOMA
         BALR  R14,R15
         L     R10,SAVE10
         BR    R10
CALLCH   ST    R10,SAVE10
         MVC   PL+12(4),CHAIN
         MVC   PL+16(4),ENVA
         LA    R1,RCW
         O     R1,=X'80000000'
         ST    R1,PL+20
         B     DOCALL
         LTORG
SAVE     DS    18F
SAVE10   DS    F
ENVA     DS    F
EXCOMA   DS    F
RCW      DS    F
CHAIN    DS    F
PL       DC    A(IDN),A(0),A(0),A(0),A(0),A(0)
IDN      DC    C'IRXEXCOM'
SHV      DS    8F
VBUF     DS    CL64
NBUF     DS    CL40
LIST     DS    CL500
LISTEND  EQU   *
NXCLIST  DC    C'XCLIST'
* the chain
CHA      DC    A(CHB),F'0'
         DC    C's',X'00',H'0'
         DC    F'0',A(NCH1)
         DC    F'5',A(VCH1),F'1'
CHB      DC    A(CHC),F'0'
         DC    C's',X'00',H'0'
         DC    F'0',A(NCHB)
         DC    F'4',A(VCH1),F'1'
CHC      DC    A(0),F'0',C's',X'00',H'0',F'0',A(NCH2),F'5',A(VCH3),F'1'
NCH1     DC    C'XCCH1'
NCHB     DC    C'1BAD'
NCH2     DC    C'XCCH2'
VCH1     DC    C'a'
VCH3     DC    C'c'
* names and values of the table
NXCNEW   DC    C'XCNEW'
VXCNEW   DC    C'FROM ASM'
NXC1     DC    C'XC1'
NXC1L    DC    C'xc1'
NXCNONE  DC    C'XCNONE'
NXCSA    DC    C'XCSTEM.A'
NXCSZZ   DC    C'XCSTEM.ZZ'
NXCSH    DC    C'XCSTEM.'
NXCSTI   DC    C'XCST.XCI'
NXCSTL   DC    C'XCSTEM.QQ'
NXC2     DC    C'XC2'
NBAD     DC    C'1BAD'
NXCBADV  DC    C'XCBADV'
NPARM    DC    C'PARM'
NVERS    DC    C'VERSION'
NNOPE    DC    C'NOPE'
VONE     DC    C'one'
VS       DC    C's'
VDFLT    DC    C'dflt'
VNEWD    DC    C'newdflt'
VV1      DC    C'v1'
VV2      DC    C'v2'
VX       DC    C'x'
         DS    0F
* one entry (32 bytes): CODE, EXPECTED SHVRET, EXPECTED R15, NAME, NAME
* LENGTH, VALUE LENGTH IN, VALUE IN, BUFFER LENGTH, EXPECTED SHVVALL
* (-1
* NOT CHECKED, -2 NOT EMPTY), EXPECTED VALUE, STEP, 1 = THE FOUR
* PARAMETER FORM
STEPS    DC    C's',X'01',H'0'
         DC    A(NXCNEW),H'5',H'8',A(VXCNEW)
         DC    H'0',H'0',A(0),H'1'
         DC    X'01',XL5'00'
         DC    C'f',X'00',H'0'
         DC    A(NXC1),H'3',H'0',A(0)
         DC    H'64',H'3',A(VONE),H'2'
         DC    X'00',XL5'00'
         DC    C'f',X'00',H'0'
         DC    A(NXC1L),H'3',H'0',A(0)
         DC    H'64',H'3',A(VONE),H'3'
         DC    X'00',XL5'00'
         DC    C'F',X'00',H'0'
         DC    A(NXC1),H'3',H'0',A(0)
         DC    H'64',H'3',A(VONE),H'4'
         DC    X'00',XL5'00'
         DC    C'f',X'01',H'0'
         DC    A(NXCNONE),H'6',H'0',A(0)
         DC    H'64',H'6',A(NXCNONE),H'5'
         DC    X'00',XL5'00'
         DC    C'f',X'04',H'4'
         DC    A(NXCSA),H'8',H'0',A(0)
         DC    H'1',H'2',A(VS),H'6'
         DC    X'00',XL5'00'
         DC    C'f',X'01',H'0'
         DC    A(NXCSZZ),H'9',H'0',A(0)
         DC    H'64',H'4',A(VDFLT),H'7'
         DC    X'00',XL5'00'
         DC    C'f',X'00',H'0'
         DC    A(NXCSH),H'7',H'0',A(0)
         DC    H'64',H'4',A(VDFLT),H'8'
         DC    X'00',XL5'00'
         DC    C's',X'01',H'0'
         DC    A(NXCSTI),H'8',H'2',A(VV1)
         DC    H'0',H'0',A(0),H'9'
         DC    X'00',XL5'00'
         DC    C'S',X'01',H'0'
         DC    A(NXCSTI),H'8',H'2',A(VV2)
         DC    H'0',H'0',A(0),H'10'
         DC    X'00',XL5'00'
         DC    C'f',X'00',H'0'
         DC    A(NXCSTI),H'8',H'0',A(0)
         DC    H'64',H'2',A(VV1),H'11'
         DC    X'00',XL5'00'
         DC    C'F',X'00',H'0'
         DC    A(NXCSTI),H'8',H'0',A(0)
         DC    H'64',H'2',A(VV2),H'12'
         DC    X'00',XL5'00'
         DC    C's',X'00',H'0'
         DC    A(NXCSH),H'7',H'7',A(VNEWD)
         DC    H'0',H'0',A(0),H'13'
         DC    X'00',XL5'00'
         DC    C'f',X'01',H'0'
         DC    A(NXCSTL),H'9',H'0',A(0)
         DC    H'64',H'7',A(VNEWD),H'14'
         DC    X'00',XL5'00'
         DC    C'd',X'00',H'0'
         DC    A(NXC2),H'3',H'0',A(0)
         DC    H'0',H'0',A(0),H'15'
         DC    X'00',XL5'00'
         DC    C'f',X'01',H'0'
         DC    A(NXC2),H'3',H'0',A(0)
         DC    H'64',H'3',A(NXC2),H'16'
         DC    X'00',XL5'00'
         DC    C's',X'08',H'8'
         DC    A(NBAD),H'4',H'1',A(VX)
         DC    H'0',H'0',A(0),H'17'
         DC    X'00',XL5'00'
         DC    C's',X'10',H'16'
         DC    A(NXCBADV),H'6',H'-1',A(VX)
         DC    H'0',H'0',A(0),H'18'
         DC    X'00',XL5'00'
         DC    C'Z',X'80',H'128'
         DC    A(NXC1),H'3',H'0',A(0)
         DC    H'0',H'0',A(0),H'19'
         DC    X'00',XL5'00'
         DC    C'f',X'00',H'0'
         DC    A(NXCNEW),H'5',H'0',A(0)
         DC    H'64',H'8',A(VXCNEW),H'20'
         DC    X'00',XL5'00'
         DC    C'd',X'00',H'0'
         DC    A(NXCNEW),H'5',H'0',A(0)
         DC    H'0',H'0',A(0),H'21'
         DC    X'00',XL5'00'
         DC    C'f',X'01',H'0'
         DC    A(NXCNEW),H'5',H'0',A(0)
         DC    H'64',H'5',A(NXCNEW),H'22'
         DC    X'00',XL5'00'
         DC    C'P',X'00',H'0'
         DC    A(NPARM),H'4',H'0',A(0)
         DC    H'64',H'-2',A(0),H'23'
         DC    X'00',XL5'00'
         DC    C'P',X'00',H'0'
         DC    A(NVERS),H'7',H'0',A(0)
         DC    H'64',H'-2',A(0),H'24'
         DC    X'00',XL5'00'
         DC    C'P',X'08',H'8'
         DC    A(NNOPE),H'4',H'0',A(0)
         DC    H'64',H'-1',A(0),H'25'
         DC    X'00',XL5'00'
         DC    X'00'
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
R12      EQU   12
R13      EQU   13
R14      EQU   14
R15      EQU   15
         END   TSTXCOM
