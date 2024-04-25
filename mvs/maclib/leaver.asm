         MACRO
&LAB     LEAVER &WR=R13,&WL=WORKLEN
&LAB     LR    R1,&WR             WORKAREA ADDR FOR FREEMAIN
         L     R0,=A(&WL)         WORKAREA LEN   "    "
         L     R13,4(R13)         GET CALLERS SAVEAREA ADDR
         LR    R11,R15            SAVE RETURN CODE
         FREEMAIN R,LV=(0),A=(1)
         LR    R15,R11            RESTORE RETURN CODE
         RETURN (14,12),RC=(15)
         MEND
