         MACRO
&LABEL   $EPILOG &RC
         GBLC  &PROGM
&LABEL   LR    R1,R13              GET SAVEAREA ADDRESS
         L     R13,4(R13)          GET BACK CHAIN POINTER
         AIF   ('&PROGM' NE 'GETMAIN').NOFREE
         L     R0,16(R13)          GET SAVEAREA LENGTH
         ST    R15,16(R13)         SAVE REGISTER 15 (RETCODE)
         FREEMAIN R,LV=(0),A=(1)   FREE SAVEAREA
         AGO   .LM
.NOFREE  ANOP
         ST    R15,16(R13)         SAVE REGISTER 15 (RETCODE)
.LM      ANOP
         LM    R14,R12,12(R13)     RESTORE CALLERS REGS
         AIF   (T'&RC EQ 'O').SPEC
         LA    R15,&RC             SET RETURN CODE
.SPEC    ANOP
         BR    R14                 RETURN TO CALLER
         MEND
