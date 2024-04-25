         MACRO
&NAME    MLEAVE
         GBLC    &GBCP
         LH      R15,EXITRC
         L       13,SAVE+4
*        RETURN  (14,12),T,RC=0
         L       14,12(13)          RESTORE THE REGISTERS
         LM      0,12,20(13)          RESTORE THE REGISTERS
         MVI     12(13),X'FF'          SET RETURN INDICATION
         BR      14                    RETURN
EXITRC   DC      H'0'             RETURN CODE FROM COMMAND PROCESSOR
         AIF     ('&GBCP' EQ 'NOCP').NOPPL
CPPLCBUF DS      A
CPPLUPT  DS      A
CPPLPSCB DS      A
CPPLECT  DS      A
IOPLADS  DS      4F               SPACE FOR IO PARM LIST
ECBADS   DC      F'0'             ECB FOR PUTLINE, GETLINE
PUTBLOK  PUTLINE MF=L             DEFAULT PUTLINE MACRO, LIST FORM
.NOPPL   ANOP
SAVE     DS      18F
         MEND
