         MACRO
         OACREGS &DUMMY,&PRINT=
         COPY  OACGBLS
         OACPRTPM PRINT=&PRINT
         AIF   ('&OACPRT' NE 'SHORT').L1
         PRINT OFF,GEN
.L1      ANOP
         SPACE &OACPRTS
******************************************
R0       EQU   0                   <-----|
R1       EQU   1                   <-----|
R2       EQU   2                   <-----|
R3       EQU   3                   <-----|
R4       EQU   4                   <-----|
R5       EQU   5                   <-----|      =============
R6       EQU   6                   <-----|      =  GENERAL  =
R7       EQU   7                   <-----|      =  PURPOSE  =
R8       EQU   8                   <-----|      = REGISTERS =
R9       EQU   9                   <-----|      =============
R10      EQU   10                  <-----|
R11      EQU   11                  <-----|
R12      EQU   12                  <-----|
R13      EQU   13                  <-----|
R14      EQU   14                  <-----|
R15      EQU   15                  <-----|
         SPACE
F0       EQU   0                   <-----|    ==================
F2       EQU   2                   <-----|    = FLOATING POINT =
F4       EQU   4                   <-----|    =   REGISTERS    =
F6       EQU   6                   <-----|    ==================
         POP   PRINT
         MEND
