         MACRO
         RXPGCALL &FEX
* ..... CALL IRXEXCOM .................................................
         MVC   IRXID1,=CL8'IRXEXCOM'
         MVC   IRXID2,=CL8'IRXDATA'
         MVA   CALLPARM,IRXID1    SET PARAMETER LIST
         MVA   CALLPARM+4,0
         MVA   CALLPARM+8,0
         MVA   CALLPARM+12,IRXBLK
         MVI   CALLPARM+12,X'80'
         L     RF,IRXEXCOM        LOAD PRE LOADED IRXEXCOM ADDRESS
         LTR   RF,RF
         BNZ   N&SYSNDX
         LOAD  EP=IRXEXCOM
         LR    RF,R0
         ST    RF,IRXEXCOM
N&SYSNDX DS    0H
         LA    R1,CALLPARM        LOAD PARM LIST
         BALR  RE,RF              CALL IRXEXCOM
         ST    RF,IRXRF           ST RETURN CODE FROM CALL
         AIF   ('&FEX' EQ '').NOFEX
         LTR   RF,RF
         BNZ   &FEX
.NOFEX   ANOP
         MEND
