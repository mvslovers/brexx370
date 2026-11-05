BRXEXCOM TITLE 'VARIABLE ACCESS FOR ASSEMBLER PROGRAMS (IRXEXCOM FORM)'
*
*  BRXEXCOM - the address in the irxexcom entry of the IRXEXTE.
*  OS linkage: R0 = the ENVBLOCK the caller found in ECTENVBK, R1 = the
*  IRXEXCOM parameter list, R13 = the caller's save area, R14 = return,
*  R15 = this entry.  There is no external name for anyone to LOAD or
*  LINK; the IRX* names are REKX/370's.
*
*  Several copies of BREXX can run on one ECT (two ISPF screens, an
*  exec started from an exec).  Each one has an ENVBLOCK, and while its
*  exec runs the ENVBLOCKs form a chain: ECTENVBK is the newest,
*  ENVBLOCK+X'13C' the next older one, 0 at the end.  ENVBLOCK+X'130'
*  is the input stack element that was on top when that exec started
*  (src/rxvarcom.c).  A request is meant for the exec whose element is
*  on top now.  The routine of the newest copy is the one called, so
*  this stub finds the right copy BEFORE C is entered: @@CCALL takes
*  the C environment of the task, and C code of another copy must never
*  run on it.
*
*   1  R0 is the ENVBLOCK of this copy (the external symbol of
*      env_block) and its X'130' is the element on top of the input
*      stack (ECT -> ECTIOWA -> IOSTELM): our exec.  @@CCALL as ever.
*      Without an ECT (batch) there is no chain: the same.
*   2  Otherwise walk from ECTENVBK through X'13C', 256 blocks at most
*      (a cycle ends the walk), eyecatcher and length checked on each.
*      The first block whose X'130' is the element on top, and whose
*      IRXEXTE has an irxexcom entry, gets the request: branch to that
*      entry with R0 = that block; R1, R13, R14 as the caller's.
*      The stub of that copy meets step 1.
*   3  No block: R15 = -1 (and the same in the sixth parameter, if
*      there is one).  Caller: no exec of ours is on top, the CLIST
*      path.
*
*  The C routine RXXCOM (src/rxvarcom.c) gets the caller's list and R0
*  as two parameters.  @@CCALL copies the list without the X'80'.  Not
*  reentrant: the two-word list is in the CSECT, and BREXX is linked
*  NORENT.  R15 = the routine's return code on exit.
*
BRXEXCOM CSECT
         STM   14,12,12(13)
         LR    12,15
         USING BRXEXCOM,12
         LR    2,0                R2 = the ENVBLOCK we are asked for
         SR    3,3                R3 = the input stack element on top
         SR    4,4
         L     4,548(,4)          PSAAOLD
         LTR   4,4
         BZ    OWN
         L     4,108(,4)          ASCBASXB
         LTR   4,4
         BZ    OWN
         L     4,20(,4)           ASXBLWA
         LTR   4,4
         BZ    OWN
         L     4,32(,4)           LWAPECT
         LTR   4,4
         BZ    OWN                no ECT: no chain
         L     5,4(,4)            ECTIOWA
         LTR   5,5
         BZ    HAVETOP
         L     3,0(,5)            IOSTELM
HAVETOP  DS    0H
*  step 1
         L     6,=V(ENV@BLOC)
         L     6,0(,6)            the ENVBLOCK of this copy
         LTR   6,6
         BZ    WALK
         CR    6,2
         BNE   WALK
         C     3,304(,6)          ENVBLOCK+X'130'
         BE    OWN
*  step 2
WALK     L     7,48(,4)           ECTENVBK
         LA    8,256
WLOOP    LTR   7,7
         BZ    NOMATCH
         CLC   0(8,7),=C'ENVBLOCK'
         BNE   NOMATCH
         CLC   12(4,7),=F'320'
         BNE   NOMATCH
         L     9,304(,7)          X'130'
         LTR   9,9
         BZ    NEXT
         CR    9,3
         BNE   NEXT
         L     10,28(,7)          IRXEXTE
         LTR   10,10
         BZ    NEXT
         L     15,16(,10)         its irxexcom entry
         LTR   15,15
         BNZ   JUMP
NEXT     L     7,316(,7)          X'13C'
         BCT   8,WLOOP
*  step 3
NOMATCH  L     2,24(,13)          the caller's list (its R1)
         LTR   2,2
         BZ    NOSIXTH
         LA    3,5
SIXTHL   TM    0(2),X'80'         the last parameter?
         BO    NOSIXTH
         LA    2,4(,2)
         BCT   3,SIXTHL
         L     4,0(,2)            the sixth, if there is one
         N     4,=X'00FFFFFF'
         BZ    NOSIXTH
         MVC   0(4,4),=F'-1'
NOSIXTH  LM    14,12,12(13)
         LA    15,1
         LCR   15,15              R15 = -1
         BR    14
*  into the copy that owns the exec: R0 and R15 are taken from the save
*  area, together with everything else
JUMP     ST    7,20(,13)          R0 = that block
         ST    15,16(,13)         R15 = its entry
         LM    14,12,12(13)
         BR    15
*  our exec: the caller's registers back, then C as before
OWN      LM    14,12,12(13)
         DROP  12
         USING BRXEXCOM,15
         ST    1,XCPARM           the caller's list ...
         ST    0,XCPARM+4         ... and R0 ...
         OI    XCPARM+4,X'80'     ... as the last parameter
         LA    1,XCPARM
         L     0,=V(RXXCOM)       R0 = the C function
         L     15,=V(@@CCALL)     R15 = the glue
         BR    15                 R13 and R14 as the caller left them
         LTORG
XCPARM   DC    2A(0)
         END
