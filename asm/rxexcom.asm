BRXEXCOM TITLE 'VARIABLE ACCESS FOR ASSEMBLER PROGRAMS (IRXEXCOM FORM)'
*
*  BRXEXCOM - the address in the irxexcom entry of the IRXEXTE.
*  OS linkage: R1 = the IRXEXCOM parameter list, R13 = the caller's
*  save area, R14 = return, R15 = this entry.  There is no external
*  name for anyone to LOAD or LINK; the IRX* names are REKX/370's.
*
*  The routine is C (RXXCOM, src/rxvarcom.c), called through @@CCALL
*  of libc370, which copies a parameter list without the X'80'.  The
*  original list is passed on as the one parameter.  Not reentrant:
*  the one-word list is in the CSECT, and BREXX is linked NORENT.
*
*  R15 = the routine's return code on exit.
*
BRXEXCOM CSECT
         USING BRXEXCOM,15
         ST    1,XCPARM           the caller's list ...
         OI    XCPARM,X'80'       ... as the only, last parameter
         LA    1,XCPARM
         L     0,=V(RXXCOM)       R0 = the C function
         L     15,=V(@@CCALL)     R15 = the glue
         BR    15                 R13 and R14 as the caller left them
         LTORG
XCPARM   DC    A(0)
         END
