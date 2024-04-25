         MACRO
&NAME    LEAVE  &EQ,&CC=
         GBLC  &LV,&SP,&SAVED(2)
&NAME    LR    2,13               SAVE CURRENT WORK/SAVE AREA
         L     13,4(13)           PICK UP LAST SAVE AREA
         STM   15,1,16(13)        STORE RETURN REGS
         AIF   ('&LV' EQ '').L1
         FREEMAIN R,LV=&LV,SP=&SP,A=(2)  FREE SAVE AREA
.L1      AIF   ('&SAVED(2)' EQ '').L2
         AIF   ('&CC' EQ '').L15       WAS CC SPECIFIED
         RETURN (&SAVED(1),&SAVED(2)),T,RC=&CC RETURN
         AGO   .L3
.L15     RETURN (&SAVED(1),&SAVED(2)),T        RETURN
         AGO   .L3
.L2      RETURN &SAVED(1),T *   RETURN TO CALLER
.L3      AIF   ('&EQ' NE 'EQ').L4
         REGISTER
.L4      MEND
