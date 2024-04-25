BRXSVC  TITLE 'BREXX EXTERNAL SVC INTERFACE'
         PRINT   GEN
BRXSVC   START 0                  START MAIN CODE CSECT AT BASE 0
*
         SAVE  (14,12)            SAVE INPUT REGISTERS
         LR    R12,R15            BASE REGISTER := ENTRY ADDRESS
         USING BRXSVC,R12         DECLARE BASE REGISTER
         ST    R13,SAVE+4         SET BACK POINTER IN CURRENT SAVE AREA
         LR    R2,R13             REMEMBER CALLERS SAVE AREA
         LA    R13,SAVE           SETUP CURRENT SAVE AREA
         ST    R13,8(R2)          SET FORW POINTER IN CALLERS SAVE AREA
*
         LR    R11,R1             SAVE PARAMETER LIST
*
         LM    R4,R7,0(R11)       LOAD ADDRESSES OF SVC NUM,R0,R1,R15
*
         L     R0,0(R5)           LOAD VALUE FOR R0
         L     R1,0(R6)           LOAD VALUE FOR R1
         L     R15,0(R7)          LOAD VALUE FOR R15
*
         EX    R4,DOSVC           EXCUTE SVC
*
         ST    R15,0(R7)          UPDATE R15
         ST    R1,0(R6)           UPDATE R1
         ST    R0,0(R5)           UPDATE R0
*
         L     R13,4(R13)         RESTORE REGISTERS
         L     R14,12(R13)        ...
         LM    R1,12,24(R13)      ...
         BR    R14
*
DOSVC    SVC   0                  Executed Instruction
*
         EJECT
SAVE     DS    18F                LOCAL SAVE AREA
*
* =====================================================================
* OTHER DUMMY SECTIONS
* =====================================================================
         YREGS    ,
         END   BRXSVC