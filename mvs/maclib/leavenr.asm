         MACRO
&LAB     LEAVENR
&LAB     L     R13,4(R13)         GET CALLERS SAVEAREA ADDR
         RETURN (14,12),RC=(15)
         MEND
