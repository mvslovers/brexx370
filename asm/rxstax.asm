RXSTAX   TITLE 'BREXX/370 STAX ATTENTION EXIT (#610)'
*
*  An attention (PA1) while an exec runs must not end the BREXX command
*  through the TMP: BREXX would not run its own end, and ECTENVBK would
*  keep the ENVBLOCK of an unloaded copy.  The exit only sets a flag;
*  the interpreter reads it at the next clause and raises HALT.
*
*  C calls (no parameters, the result is in R15):
*     int RXSTAXON(void)   establish the exit, clear the flag;
*                          R15 = the return code of STAX, 0 = done
*     int RXSTAXOF(void)   cancel the most recent exit; R15 as above
*  Data:
*     char RXSTAXFL        X'FF' after an attention, the interpreter
*                          clears it
*
*  REPLACE=NO stacks the exit above those of the TMP and of a BREXX
*  that called this one; a cancel takes the topmost off again.  The
*  exit runs as an IRB on this TCB and changes only R15 (its base, as
*  entered).  Not reentrant: flag and list are in the CSECT, and BREXX
*  is linked NORENT.
*
RXSTAX   CSECT
         ENTRY RXSTAXON
         ENTRY RXSTAXOF
         ENTRY RXSTAXFL
RXSTAXON DS    0H
         USING RXSTAXON,15
         MVI   RXSTAXFL,X'00'
         STAX  MF=(E,STAXL)
         BR    14
         DROP  15
RXSTAXOF DS    0H
         STAX
         BR    14
*  the exit: R14 = return, nothing else is needed
ATTNEXIT DS    0H
         BALR  15,0
         USING *,15
         MVI   RXSTAXFL,X'FF'
         BR    14
         DROP  15
         DS    0F
STAXL    STAX  ATTNEXIT,REPLACE=NO,MF=L
RXSTAXFL DC    X'00'
         END
