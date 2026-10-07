         TITLE 'IKJCT437 - BREXX/370 EXEC CLASSIFIER AND RUNNER'
*
*  IKJCT437 - Decide whether an exec is REXX and, if it is, run it
*             through BREXX/370.  Called from IKJCT430 (EXEC) before
*             anything is stacked.  Part of usermod ZMG0001.
*
*  The entries, their interface and the language rules are those of
*  REXX/370's IKJCT437 (usermod ZMG0002, mvslovers/rexx370 tso/,
*  main f574e90), so tso/IKJCT430.ASM is that patch unchanged.
*  What differs: no REXX environment.  This module finds and reads
*  the member itself (BPAM) and LINKs the BREXX command processor.
*
*  Entry IKJCT437  implicit (%name / name): SYSUEXEC, SYSUPROC,
*                  SYSEXEC, SYSPROC
*  Entry IKJCT43C  explicit EXEC 'ds(mem)': REXX only if line 1 is a
*                  comment containing REXX, whatever the library
*  Entry IKJCT43F  explicit EXEC 'ds(mem)' EXEC: REXX, forced
*          R1  -> RXPLIST  +0  CL8 member, blank padded
*                          +8  CL8 DD: the DD DAIR allocated
*                              (explicit), blank (implicit)
*                          +16 A   the exec's argument
*                          +20 F   its length; 0 = no argument
*          R0  -> CPPL
*          R13 -> caller savearea,  R14 -> return
*  Exit    R15 = 0   not REXX -- IKJCT430 carries on with CLIST
*          R15 = 4   was REXX, already executed
*          all registers except R15 restored
*
*  Entry IKJCT43N  is the command that was not found a line of a
*                  running CLIST?  (IKJ56479I)
*          R1  -> CPPL,  R13 -> caller savearea,  R14 -> return
*  Exit    R15 = 4   yes: the top of the input stack is an EXEC
*                    element (X'08') and not a terminal one (X'80')
*          R15 = 0   no
*  Unlike ZMG0002 there is no environment to check: with ZMG0001
*  installed BREXX is there, so the hint always applies
*  (maintainer, 2026-10-05).
*
*  CSECT IKJCT43M  holds IKJ56479I for IKJEFF02, in IKJCT435 format.
*
*  ---- The language decision (z/OS, measured for ZMG0002) ----
*
*      implicit, member in SYSUEXEC or SYSEXEC -> REXX, no check
*      implicit, member in SYSUPROC or SYSPROC -> REXX if line 1 is
*                     a comment containing REXX; in SYSUPROC else
*                     passed over, in SYSPROC else a CLIST
*      The user libraries come first, as BREXX searches them for
*      RX; TSO/E searches them only after ALTLIB, which MVS 3.8 lacks.
*      SYSEXEC before SYSPROC also when the SYSPROC member is a
*      CLIST: the TSO/E default (SEARCHDD(YES)), measured on z/OS
*      2026-10-07 (internals/tso-integration.md).  MVS 3.8's EXEC
*      searched SYSPROC only, so a name in both changes (#368).
*      explicit, no keyword         -> line 1 decides, any library
*      explicit, EXEC keyword       -> REXX
*
*  ---- Running it ----
*
*  BREXX is LINKed as the command processor it is under TSO: R1 ->
*  a CPPL with the caller's UPT, PSCB and ECT and a command buffer
*      BREXX <dd>(<member>) <argument>
*  BREXX opens DD:<dd>(<member>) first (src/rexx.c RxFileLoad), and
*  takes its argument string from the command buffer unchanged after
*  the name (#358).  The argument comes from IKJCT430 as z/OS gives
*  it; BREXX drops leading and trailing blanks of it.
*  BREXX is looked up with BLDL first: a LINK to a missing module
*  abends S806 in EXEC.  Not found: the exec runs as CLIST.
*
*  ---- BPAM, as REXX/370's asm/irxbpam.asm learned it ----
*
*  The DD is looked up in the TIOT first: OPEN of a missing DD says
*  IEC130I.  FIND ...,D expands through IHBINNRA, which loads R1
*  from the DCB operand before R0 from the name, so R0/R1 cannot
*  carry either (KB MVS-BLDL-0001): R4/R5.  A concatenation takes
*  BLKSIZE from its first data set; a later library with larger
*  blocks fails the READ into SYNAD, and the member counts as not
*  REXX.  A short block's length is DCBBLKSI minus the CSW residual
*  at IOB+14.  RECFM F: line 1 is the first LRECL bytes; V: the
*  first record after BDW and RDW; U: the whole block.
*
*  ---- Constraints ----
*
*  The EXEC load module is AC=0 and RENT: nothing authorized, no
*  stores into this CSECT.  The work area, the DCB, the DECB and the
*  READ buffer are GETMAINed.
*
*  NOTE for as370/IFOX00: RS-format LM/STM must be written D(B).
*
         PRINT NOGEN
R0       EQU   0
R1       EQU   1
R2       EQU   2
R3       EQU   3
R4       EQU   4
R5       EQU   5
R6       EQU   6
R7       EQU   7
R11      EQU   11
R12      EQU   12
R13      EQU   13
R14      EQU   14
R15      EQU   15
CPPLECT  EQU   12                 CPPL -> ECT
ECTIOWA  EQU   4                  ECT  -> IOSRL (I/O service work)
IOSTELM  EQU   0                  IOSRL -> top input stack element
INSEXEC  EQU   X'08'              element flag: EXEC (CLIST) owns it
INSTERM  EQU   X'80'              element flag: terminal / TERMIN
PSATOLD  EQU   X'21C'             PSA -> current TCB
TCBTIO   EQU   12                 TCB -> TIOT
TIOFIRST EQU   24                 TIOT -> first DD entry
TIOEDDNM EQU   4                  DD entry -> DD name
IOBRESID EQU   14                 IOB -> CSW residual count (H)
DECBIOB  EQU   16                 DECB -> IOB address
FOPEN    EQU   X'80'              WFLAGS: DCB is open
FEOD     EQU   X'40'              WFLAGS: EODAD reached
FERR     EQU   X'20'              WFLAGS: SYNAD reported an error
ARGMAX   EQU   480                argument bytes passed at most
         PRINT GEN
*
IKJCT437 CSECT
*  Three entries share one body; R7 carries the mode.  Each entry
*  branches through its own address in R15, so none needs a base.
         STM   R14,R12,12(R13)
         SR    R7,R7              mode 0: implicit
         B     COMMON-IKJCT437(,R15)
         ENTRY IKJCT43C
IKJCT43C STM   R14,R12,12(R13)
         LA    R7,MODEC           mode 1: explicit, line 1 decides
         B     COMMON-IKJCT43C(,R15)
         ENTRY IKJCT43F
IKJCT43F STM   R14,R12,12(R13)
         LA    R7,MODEF           mode 2: explicit, forced
COMMON   BALR  R12,0
         USING *,R12
         LR    R5,R0              CPPL
         LR    R6,R1              RXPLIST
         LTR   R5,R5
         BZ    NOTREXX
         LTR   R6,R6
         BZ    NOTREXX
* --- workarea, zeroed: GETMAIN storage is not ---
         L     R0,=A(WALEN)
         GETMAIN RC,LV=(0)
         LTR   R15,R15
         BNZ   NOTREXX
         LR    R3,R1
         LR    R0,R1
         L     R1,=A(WALEN)
         SR    R14,R14            source length 0, pad byte 0
         SR    R15,R15
         MVCL  R0,R14
         LR    R1,R3
         ST    R13,4(,R1)
         ST    R1,8(,R13)
         LR    R13,R1
         USING WAREA,R13
         LA    R4,WDCB
         USING IHADCB,R4
*
         C     R7,=A(MODEF)
         BE    FORCED
         LTR   R7,R7
         BNZ   EXPLICIT
* --- implicit, in BREXX's own order (src/rexx.c RxFileLoad): the
*     user's SYSUEXEC and SYSUPROC first, then SYSEXEC and SYSPROC.
*     The EXEC DDs hold REXX only; in the PROC DDs line 1 decides,
*     and a CLIST in SYSUPROC is passed over, as BREXX does ---
         MVC   WDD,DDUEXEC
         BAL   R11,LOOKUP
         LTR   R15,R15
         BNZ   RUNIT              in SYSUEXEC: REXX
         MVC   WDD,DDUPROC
         BAL   R11,LOOKUP
         LTR   R15,R15
         BZ    IMPEXEC            not in SYSUPROC
         BAL   R11,LINE1
         LTR   R15,R15
         BNZ   RUNIT              SYSUPROC, REXX comment: REXX
         BAL   R11,CLOSEIT        a CLIST there: go on
IMPEXEC  MVC   WDD,DDEXEC
         BAL   R11,LOOKUP
         LTR   R15,R15
         BNZ   RUNIT              in SYSEXEC: REXX
         MVC   WDD,DDPROC
         BAL   R11,LOOKUP
         LTR   R15,R15
         BZ    DONE               nowhere: let IKJCT430 say so
         B     CHKIT
* --- explicit: the DD DAIR allocated; line 1 decides ---
EXPLICIT MVC   WDD,8(R6)
         BAL   R11,LOOKUP
         LTR   R15,R15
         BZ    DONE
CHKIT    BAL   R11,LINE1
         LTR   R15,R15
         BZ    DONE               no REXX identifier: a CLIST
         B     RUNIT
FORCED   MVC   WDD,8(R6)
* --- run it: LINK BREXX with a CPPL of its own ---
RUNIT    DS    0H
         BAL   R11,CLOSEIT
         MVC   WBLDL(4),BLDLHDR   one entry of 58 bytes
         MVC   WBLDL+4(8),BREXXNM
         LA    R0,WBLDL
         SR    R1,R1              JOBLIB/STEPLIB, then the link list
         SVC   18                 BLDL
         LTR   R15,R15
         BNZ   DONE               no BREXX: CLIST it is
*  command buffer: BREXX <dd>(<member>) <argument>
         LA    R3,WCBTXT
         MVC   0(6,R3),BREXXCMD   'BREXX '
         LA    R3,6(,R3)
         LA    R1,WDD
         BAL   R11,PUTNAME
         MVI   0(R3),C'('
         LA    R3,1(,R3)
         LR    R1,R6              member, +0 of RXPLIST
         BAL   R11,PUTNAME
         MVI   0(R3),C')'
         LA    R3,1(,R3)
         L     R15,20(,R6)        argument length
         LTR   R15,R15
         BNP   CBDONE
         C     R15,=A(ARGMAX)
         BNH   ARGLENOK
         L     R15,=A(ARGMAX)
ARGLENOK MVI   0(R3),C' '
         LA    R3,1(,R3)
         L     R14,16(,R6)        argument address
         LR    R0,R3              target
         LR    R1,R15
         LR    R2,R14             source
         LR    R3,R15
         MVCL  R0,R2              R0 ends past the target
         LR    R3,R0
CBDONE   LA    R1,WCBUF
         SR    R3,R1              length, 4-byte header included
         STH   R3,WCBUF
         MVC   WCBUF+2(2),=H'6'   first operand after 'BREXX '
         LA    R1,WCBUF
         ST    R1,WCPPL
         MVC   WCPPL+4(12),4(R5)  UPT, PSCB, ECT of the caller
         LA    R1,WCPPL
         LINK  EP=BREXX
         MVI   WHANDLED,X'01'
* --- clean up and answer ---
DONE     DS    0H
         BAL   R11,CLOSEIT
*  FREEMAIN clobbers R0/R1/R15 only, so the verdict rides in R2.
         SR    R2,R2
         IC    R2,WHANDLED
         LR    R1,R13
         L     R13,4(,R13)
         L     R0,=A(WALEN)
         FREEMAIN RU,LV=(0),A=(R1)
         LTR   R2,R2
         BNZ   WASREXX
NOTREXX  DS    0H
         LM    R14,R12,12(R13)
         SR    R15,R15
         BR    R14
WASREXX  DS    0H
         LM    R14,R12,12(R13)
         LA    R15,4
         BR    R14
* ------------------------------------------------------------------
*  LOOKUP - is member 0(R6) in DD WDD?  Link in R11.
*           R15 = 4 found, DCB WDCB left open; 0 not found, closed.
*           Uses R0-R3, R5 is restored.
* ------------------------------------------------------------------
LOOKUP   DS    0H
         ST    R5,WSAVR5
         SR    R15,R15
         L     R1,PSATOLD         current TCB
         L     R1,TCBTIO(,R1)     TIOT
         LA    R1,TIOFIRST(,R1)
LKTIOT   CLI   0(R1),0            end of the TIOT
         BE    LKRET
         CLC   TIOEDDNM(8,R1),WDD
         BE    LKOPEN
         SR    R2,R2
         IC    R2,0(,R1)          entry length
         AR    R1,R2
         B     LKTIOT
LKOPEN   MVC   WDCB(MDCBLEN),MDCB
         MVC   DCBDDNAM,WDD
         MVC   WOPEN,MOPEN
         XC    WDECB,WDECB
         OPEN  ((R4),(INPUT)),MF=(E,WOPEN)
         SR    R15,R15
         TM    DCBOFLGS,DCBOFOPN
         BNO   LKRET
         OI    WFLAGS,FOPEN
         LR    R5,R6              member name
         FIND  (R4),(R5),D
         LTR   R15,R15
         BNZ   LKNOT
         LA    R15,4
         B     LKRET
LKNOT    ST    R11,WSAVR11
         BAL   R11,CLOSEIT
         L     R11,WSAVR11
         SR    R15,R15
LKRET    L     R5,WSAVR5
         BR    R11
* ------------------------------------------------------------------
*  LINE1 - does the member's line 1 start a comment containing REXX?
*          DCB open and positioned by LOOKUP.  Link in R11.
*          R15 = 4 yes, 0 no.  Uses R0-R3, R5.
* ------------------------------------------------------------------
LINE1    DS    0H
         ST    R11,WSAVR11
         ST    R5,WSAVR5
         LH    R0,DCBBLKSI
         LTR   R0,R0
         BNP   L1NO
         ST    R0,WBUFL
         GETMAIN RC,LV=(0)
         LTR   R15,R15
         BNZ   L1NO
         ST    R1,WBUF
         LA    R3,WDECB
         L     R5,WBUF
         READ  (R3),SF,(R4),(R5),'S',MF=E
         CHECK (R3)
AFTERCHK DS    0H
         TM    WFLAGS,FEOD+FERR
         BNZ   L1FREE             empty member or I/O error
         L     R14,WDECB+DECBIOB  IOB
         SLR   R1,R1
         ICM   R1,B'0011',IOBRESID(R14)  residual count
         LH    R2,DCBBLKSI
         SR    R2,R1              bytes in the block
         BNP   L1FREE
         L     R1,WBUF
         TM    DCBRECFM,X'C0'
         BO    L1TEST             U: the whole block
         TM    DCBRECFM,X'80'
         BO    L1FIX              F
         TM    DCBRECFM,X'40'
         BNO   L1TEST             unknown: the whole block
*  V: BDW, then the first record's RDW (its length includes itself)
         C     R2,=F'8'
         BL    L1FREE
         LH    R2,4(,R1)
         S     R2,=F'4'
         LA    R1,8(,R1)
         B     L1TEST
L1FIX    LH    R0,DCBLRECL
         CR    R0,R2
         BNL   L1TEST
         LR    R2,R0              one record, not the block
L1TEST   BAL   R11,CHKLINE1
         ST    R15,WRESULT
         B     L1FREE2
L1FREE   XC    WRESULT,WRESULT
L1FREE2  L     R1,WBUF
         L     R0,WBUFL
         FREEMAIN RU,LV=(0),A=(R1)
         L     R15,WRESULT
         B     L1RET
L1NO     SR    R15,R15
L1RET    L     R5,WSAVR5
         L     R11,WSAVR11
         BR    R11
*  EODAD: entered from CHECK with R2-R13 as they were at CHECK.
EOD      DS    0H
         OI    WFLAGS,FEOD
         B     AFTERCHK
*  SYNAD: same registers; R14 returns into the access method, which
*  then returns from CHECK normally.
SYN      DS    0H
         OI    WFLAGS,FERR
         BR    R14
* ------------------------------------------------------------------
*  CHKLINE1 - R1 -> line 1, R2 = its length, link in R11.
*             R15 = 4 if it starts with '/*' and contains REXX.
*             As REXX/370's: R1 carries the address (R0 as a base
*             means no base, JOB01212), len-3 start positions for a
*             4-byte compare.
* ------------------------------------------------------------------
CHKLINE1 DS    0H
         SR    R15,R15
         LTR   R1,R1
         BZ    CL1DONE
         C     R2,=F'2'
         BL    CL1DONE
         CLC   0(2,R1),SLASHST    must start with '/*'
         BNE   CL1DONE
         S     R2,=F'3'           number of start positions
         BNP   CL1DONE
CL1SCAN  CLC   0(4,R1),REXXLIT
         BE    CL1YES
         LA    R1,1(,R1)
         BCT   R2,CL1SCAN
         B     CL1DONE
CL1YES   LA    R15,4
CL1DONE  BR    R11
* ------------------------------------------------------------------
*  CLOSEIT - CLOSE the DCB if LOOKUP left it open.  Link in R11.
* ------------------------------------------------------------------
CLOSEIT  DS    0H
         TM    WFLAGS,FOPEN
         BZR   R11
         CLOSE ((R4)),MF=(E,WOPEN)
         NI    WFLAGS,255-FOPEN
         BR    R11
* ------------------------------------------------------------------
*  PUTNAME - copy the CL8 at R1 up to its first blank to R3, and
*            advance R3.  Link in R11.  Uses R0, R1.
* ------------------------------------------------------------------
PUTNAME  DS    0H
         LA    R0,8
PNLOOP   CLI   0(R1),C' '
         BER   R11
         MVC   0(1,R3),0(R1)
         LA    R1,1(,R1)
         LA    R3,1(,R3)
         BCT   R0,PNLOOP
         BR    R11
         DROP  R4,R13
* ------------------------------------------------------------------
*  IKJCT43N - was the command not found a line of a running CLIST?
*             TSO/E then says IKJ56479I (REXX identifier missing)
*             instead of IKJ56500I.  The test is PUTLINE's
*             (IKJEFT40): the top element of the input stack has
*             INSEXEC on and INSTERM off.  INSTERM excludes TERMIN,
*             where the CLIST element reads X'88' (IKJCT436).
*             It runs on its own base and uses no literals.
* ------------------------------------------------------------------
         ENTRY IKJCT43N
         DROP  R12
IKJCT43N STM   R14,R12,12(R13)
         LR    R12,R15
         USING IKJCT43N,R12
         SR    R15,R15            answer: no
         LTR   R1,R1              CPPL
         BZ    N43RET
         L     R3,CPPLECT(,R1)    ECT
         LTR   R3,R3
         BZ    N43RET
         L     R2,ECTIOWA(,R3)    IOSRL
         LTR   R2,R2
         BZ    N43RET
         L     R2,IOSTELM(,R2)    top element
         LTR   R2,R2
         BZ    N43RET
         TM    0(R2),INSEXEC
         BNO   N43RET
         TM    0(R2),INSTERM
         BNZ   N43RET
         LA    R15,4              yes: IKJ56479I
N43RET   L     R14,12(,R13)
         LM    R0,R12,20(R13)
         BR    R14
         DROP  R12
* --- read-only static data (RENT-safe) ---
DDUEXEC  DC    CL8'SYSUEXEC'
DDUPROC  DC    CL8'SYSUPROC'
DDEXEC   DC    CL8'SYSEXEC'
DDPROC   DC    CL8'SYSPROC'
BREXXNM  DC    CL8'BREXX'
BREXXCMD DC    C'BREXX '
BLDLHDR  DC    H'1',H'58'         BLDL list: one entry, 58 bytes
SLASHST  DC    C'/*'
REXXLIT  DC    C'REXX'
MODEC    EQU   1
MODEF    EQU   2
*  models, copied into the work area before OPEN; EODAD/SYNAD point
*  back into this CSECT
MDCB     DCB   DSORG=PO,MACRF=R,DDNAME=SYSPROC,EODAD=EOD,SYNAD=SYN
MDCBLEN  EQU   *-MDCB
MOPEN    OPEN  (MDCB,(INPUT)),MF=L
         LTORG
WAREA    DSECT
WSAVE    DS    18F
         DS    0D
WDCB     DS    XL(MDCBLEN)        the DCB, copied from MDCB
         DS    0F
WDECB    DS    XL20               DECB for READ/CHECK
WOPEN    DS    F                  OPEN/CLOSE list
WBUF     DS    A                  READ buffer
WBUFL    DS    F                  its length
WRESULT  DS    F                  LINE1's answer across FREEMAIN
WSAVR5   DS    F
WSAVR11  DS    F
WDD      DS    CL8                the DD being looked at
WFLAGS   DS    X
WHANDLED DS    X                  X'01' = the exec was run
         DS    0H
WBLDL    DS    XL62               BLDL list for BREXX
         DS    0F
WCPPL    DS    4A                 CPPL for BREXX
WCBUF    DS    H,H                command buffer: length, offset
WCBTXT   DS    CL(6+8+1+8+1+1+ARGMAX)
WALEN    EQU   *-WAREA
* ------------------------------------------------------------------
*  IKJCT43M - IKJ56479I for IKJEFF02, laid out like IKJCT435.
*             M479 is the ID IKJCT430 issues; like M502/H502 there,
*             H479 is the first-level line (inserts, trailing +) and
*             M479 the second level.  Text as TSO/E prints it.
*             Taken over from REXX/370's IKJCT437 unchanged.
* ------------------------------------------------------------------
IKJCT43M CSECT
         IKJTSMSG ('IKJ56479I ',,'COMMAND ',,' NOT FOUND OR REXX IDENTI*
               FIER IS MISSING+'),H479
         IKJTSMSG ('IKJ56479I SUPPLY ''/* REXX */'' AS THE FIRST RECORD*
                TO EXECUTE AS A REXX EXEC OR, FOR AN EXPLICIT EXEC, SUP*
               PLY THE EXEC KEYWORD ON THE EXEC COMMAND'),M479,H479
         IKJTSMSG
         DCBD  DSORG=PO,DEVD=DA
         END
