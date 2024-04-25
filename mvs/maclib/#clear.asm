         MACRO
         #CLEAR &AREA,&ADDR=,&LEN=,&PAD=
         AIF   ('&ADDR' NE '').ADRSET
         LA    R0,&AREA            TARGET ADDRESS
         AGO   .ADRDONE
.ADRSET  ANOP
         REGOP L,R0,&ADDR          TARGET ADDRESS
.ADRDONE ANOP
         AIF   ('&LEN'(1,1) NE '(').REGNOT
         LR    R1,&LEN(1)          TARGET LENGTH
         AGO   .LENSET
.REGNOT  ANOP
         LA    R1,&LEN             TARGET LENGTH
.LENSET  ANOP
         XR    RE,RE               CLEAR SOURCE ADDRESS
         XR    RF,RF               CLEAR LENGTH REGISTER
         ICM   RF,B'1000',=X&PAD
         MVCL  R0,RE               CLEAR AREA
         MEND
