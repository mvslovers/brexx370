         TITLE 'RXDRV - STANDALONE DRIVER FOR IKJCT437'
*
*  RXDRV - call IKJCT437 exactly the way IKJCT430 does, but from a
*          tiny load module.  Isolates the classifier so probes can
*          be added freely: inside the 24 KB EXEC load module every
*          extra WTO pushed the member over a size where program
*          fetch failed with S106, which masked the real fault.
*
*  MUST be invoked as a TSO COMMAND, not via CALL:
*
*      //SYSTSIN DD *
*       RXDRV RXA
*
*  TSO CALL passes a standard parameter list (R1 -> fullword ->
*  halfword-length-prefixed text), NOT a CPPL.  Called that way the
*  classifier reads a garbage ECT, misses the ENVBLOCK eye-catcher
*  and answers "not REXX" without ever faulting -- a run that looks
*  like a measurement and is not one.  Measured 2026-09-24.
*
*  The member name comes from the command operand; DEFMEM if absent.
*
         PRINT NOGEN
R0       EQU   0
R1       EQU   1
R2       EQU   2
R3       EQU   3
R4       EQU   4
R12      EQU   12
R13      EQU   13
R14      EQU   14
R15      EQU   15
CPPLCBUF EQU   0                  CPPL -> command buffer
         PRINT GEN
*
RXDRV    CSECT
         STM   R14,R12,12(R13)
         BALR  R12,0
         USING *,R12
         LR    R2,R1              CPPL
         LA    R3,SAVE
         ST    R13,4(,R3)
         ST    R3,8(,R13)
         LR    R13,R3
*
         WTO   'RXDRV: ENTERED'
*
* --- member name from the command operand, bounded by the buffer ---
         MVC   MEMB,BLANKS
         LTR   R2,R2
         BZ    USEDEF
         L     R4,CPPLCBUF(,R2)   command buffer
         LTR   R4,R4
         BZ    USEDEF
         LH    R0,0(,R4)          total length, header included
         SH    R0,=H'4'           length of the text
         LH    R1,2(,R4)          offset of the operand in the text
         SR    R0,R1              bytes left from the operand on
         BNP   USEDEF
         LA    R1,4(R1,R4)        -> operand text
         CH    R0,=H'8'
         BNH   HAVELEN
         LA    R0,8               a member name is never longer
HAVELEN  DS    0H
         LA    R3,MEMB
COPYLP   CLI   0(R1),C' '
         BE    COPYEND
         MVC   0(1,R3),0(R1)
         LA    R1,1(,R1)
         LA    R3,1(,R3)
         BCT   R0,COPYLP
COPYEND  DS    0H
         CLI   MEMB,C' '          did anything arrive?
         BNE   CALLIT
USEDEF   DS    0H
         MVC   MEMB,DEFMEM
*
CALLIT   DS    0H
         OC    MEMB,BLANKS        fold lower case to upper (EBCDIC)
         MVC   WMSG+12(8),MEMB
         WTO   MF=(E,WMSGL)
         LR    R0,R2              CPPL, as IKJCT430 passes it
         LA    R1,MEMB
         L     R15,=V(IKJCT437)
         BALR  R14,R15
         LTR   R15,R15
         BZ    SAIDNO
         WTO   'RXDRV: IKJCT437 SAID REXX (R15=4)'
         B     DONE
SAIDNO   DS    0H
         WTO   'RXDRV: IKJCT437 SAID NOT REXX (R15=0)'
*
DONE     DS    0H
         L     R13,4(,R13)
         LM    R14,R12,12(R13)
         SR    R15,R15
         BR    R14
*
DEFMEM   DC    CL8'RXA'
BLANKS   DC    CL8' '
         LTORG
*
*  WTO list form; the member name is patched into it before the call.
*  RXDRV is a driver and is deliberately not reentrant.
         DS    0F
WMSGL    WTO   'RXDRV: CALL xxxxxxxx',MF=L
WMSG     EQU   WMSGL+4
*
         DS    0F
SAVE     DS    18F
*  IKJCT437's parameter list (#331): member, DD, A and length of the
*  argument.  RXDRV passes no argument.
MEMB     DS    CL8
         DC    CL8' '             DD: blank, the load routine searches
         DC    A(0)               argument address
         DC    F'0'               argument length: none
*
         END
