         MACRO
&NAME    MRXEXIT
&NAME    LR    R0,RF            SAVE RC FOR THE MOMENT
         L     RD,4(,RD)        CALLER'S SAVE AREA POINTER
         L     RE,12(,RD)       RESTORE RE
         LM    R1,RC,24(RD)     RESTORE REGISTERS
         CL    R0,512           WAS IT EXIT BEFORE ADDRESSABILTY?
         BER   RE               YES, THEN RETURN IMMEDIATELY
         LR    RF,R0            RE-LOAD RETURN CODE
         BR    RE               RETURN TO CALLER
         MEND
