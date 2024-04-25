         MACRO
         SIO5GBL &TYPE=TABLE,                                          X
               &P=GBT,                                                 X
               &MODE=MIXMOD,                                           X
               &SYSUFX=01,                                             X
               &RLSUFX=01,                                             X
               &DVSUFX=01,                                             X
               &BLKMSG=WTO,                                            X
               &BUFMSG=NO,                                             X
               &TSOMSG=NO,                                             X
               &SETBLK=NO,                                             X
               &PGMDCB=NO,                                             X
               &SMFREC=0,                                              X
               &RPG=NO,                                                X
               &SORTIN=(SORTIN),                                       X
               &EXITNM=SIO5EXT,                                        X
               &SETBUF=NO
         LCLA  &INDEX,&COUNT,&VALUE
         LCLC  &TEXT
***********************************************************************
**                                                                   **
**                         VERSION 5.0                               **
**                                                                   **
**         SEQUENTIAL I/O OPTIMIZER GLOBAL DEFAULTS DEFINITION       **
**                                                                   **
**          (C) COPYRIGHT 1987  SYSTEM CONNECTIONS, INC.             **
**                                                                   **
**                                                                   **
***********************************************************************
         SPACE 2
         AIF   ('&TYPE' NE 'DSECT').CSCT
SIO5GBLD DSECT                         TABLE START
         SPACE 2
         SIO5MID TYPE=NOLB,P=&P
         SPACE 2
&P.TBSZ  DC    A(0)                    TABLE SIZE
         SPACE 2
**
**       TABLE DEFINITION
**
&P.SVCP  DC    A(0,0)                  ADR/LEN OF SIO5SVC
&P.RELP  DC    A(0,0)                  ADR/LEN OF SIO5REL
&P.JISP  DC    A(0,0)                  ADR/LEN OF SIO5JIS
&P.DCBE  DC    A(0,0)                  ADR/LEN OF SIO5DEX
&P.TBLM  DC    A(0,0)                  ADR/LEN OF SIO5TBXX
&P.DVTM  DC    A(0,0)                  ADR/LEN OF SIO5DVXX
&P.RELT  DC    A(0,0)                  ADR/LEN OF SIO5RLXX
&P.UEXI  DC    A(0,0)                  ADR/LEN OF USER EXIT
**
&P.SC19  DC    A(0)                    SVC 19 ADDRESS
&P.SC64  DC    A(0)                    SVC 64 ADDRESS
**
&P.VSAM  DC    A(0,0)                  ADR/LEN OF SIO5VSM
**
&P.SMFR  DC    AL1(0)                  SMF RECORD ID
**
&P.RUNT  DC    CL1' '                  RUN TYPE (T/A)
**
         DC    AL2(0)
**
&P.SYSP  DC    A(0)                    SYSPRINT DCB LOC
**
&P.OPTC  DC    F'0'                    OPTIMIZED COUNT
**
&P.USEX  DC    CL8' '                  NAME OF USER EXIT
**
&P.GBFX  DC    CL2'00'                 GLOBAL TABLE SUFFIX
&P.SYFX  DC    CL2'00'                 SYSTEM TABLE SUFFIX
&P.RLFX  DC    CL2'00'                 RELEASE TABLE SUFFIX
&P.DVFX  DC    CL2'00'                 DEVICE TABLE SUFFIX
**
&P.PRFL  DC    XL1'0'                  PROCESSING FLAGS
&P.PROU  EQU   X'00'                   SIO IS SHUTDOWN
&P.PRUP  EQU   X'80'                   SIO IS AVAILABLE
**
&P.MDFL  DC    XL1'00'                 MODE OF OPER FLAG
&P.MDSL  EQU   X'01'                   SELECT MODE
&P.MDEX  EQU   X'02'                   EXEMPT MODE
&P.MDMX  EQU   X'03'                   MIXMOD MODE
**
&P.OPMG  DC    XL1'00'                 OPTIMIZATION MESSAGE
&P.OPOM  EQU   X'01'                   ISSUE WTO MESSAGE
&P.OPLM  EQU   X'02'                   ISSUE WTL MESSAGE
&P.OPNO  EQU   X'03'                   NO MESSAGE GENERATED
**
&P.BFMG  DC    XL1'00'                 BUFFER CHANGE MESSAGE
&P.BFOM  EQU   X'01'                   ISSUE WTO MESSAGE
&P.BFLM  EQU   X'02'                   ISSUE WTL MESSAGE
&P.BFNO  EQU   X'03'                   NO MESSAGE GENERATED
**
&P.TSMG  DC    XL1'00'                 TSO MESSAGE
&P.TSYE  EQU   X'01'                   ISSUE WTO MESSAGE
&P.TSNO  EQU   X'02'                   DO NOT ISSUE MESSAGE
**
&P.ACTF  DC    XL1'00'                 SETBLK (REBLOCK) FLAG
&P.ACTY  EQU   X'01'                   DO THE REBLOCKING
&P.ACTN  EQU   X'02'                   DO NOT REBLOCK FILES
**
&P.DCBF  DC    XL1'00'                 HARD CODED DCB FLAG
&P.DCBY  EQU   X'01'                   DO THE REBLOCKING
&P.DCBN  EQU   X'02'                   DO NOT REBLOCK FILES
**
&P.BUFF  DC    XL1'00'                 BUFFER (REBUFFER) FLAG
&P.BUFY  EQU   X'01'                   CHANGE THE # OF BUFFERS
&P.BUFN  EQU   X'02'                   DO NOT CHANGE # BUFFERS
**
&P.RPGF  DC    XL1'00'                 R.P.G. PROGRAMS FLAG
&P.RPGY  EQU   X'01'                   SHOP HAS RPG PROGRAMS
&P.RPGN  EQU   X'02'                   SHOP DOES NOT RUN RPG
**
&P.SIDD  DS    0CL256                  BEGINNING OF DDNAMES
         MEXIT
.CSCT    ANOP
SIO5GBLT CSECT                         TABLE START
         SPACE 2
         SIO5MID
         SPACE 2
         DC    A(0)                    TABLE SIZE
         SPACE 2
         DC    A(0,0)                  ADR/LEN OF SIO5SVC
         DC    A(0,0)                  ADR/LEN OF SIO5REL
         DC    A(0,0)                  ADR/LEN OF SIO5JIS
         DC    A(0,0)                  ADR/LEN OF SIO5DEX
         DC    A(0,0)                  ADR/LEN OF SIO5TBXX
         DC    A(0,0)                  ADR/LEN OF SIO5DVXX
         DC    A(0,0)                  ADR/LEN OF SIO5RLXX
         DC    A(0,0)                  ADR/LEN OF USER EXIT
         DC    A(0)                    SVC 19 ADDRESS
         DC    A(0)                    SVC 64 ADDRESS
**
         DC    A(0,0)                  ADR/LEN OF SIO5VSM
**
         DC    AL1(&SMFREC)            SMF RECORD ID
         DC    AL3(0)
**
         DC    A(0)                    SYSPRINT DCB LOC
**
         DC    F'0'                    OPTIMIZED COUNT
**
         DC    CL8'&EXITNM'            USER EXIT NAME
**
         DC    CL2'  '                 GLOBAL TABLE SUFFIX
         DC    CL2'&SYSUFX'            SYSTEM TABLE SUFFIX
         DC    CL2'&RLSUFX'            RELEASE TABLE SUFFIX
         DC    CL2'&DVSUFX'            DEVICE TABLE SUFFIX
**
         DC    XL1'0'                  PROCESSING FLAGS
**
&VALUE   SETA  1
         AIF   ('&MODE' EQ 'SELECT').MODEOK
&VALUE   SETA  2
         AIF   ('&MODE' EQ 'EXEMPT').MODEOK
&VALUE   SETA  3
         AIF   ('&MODE' EQ 'MIXMOD').MODEOK
         MNOTE 16,'MODE=&MODE IS INVALID'
         MEXIT
.MODEOK  ANOP
         DC    AL1(&VALUE)             MODE OF OPERATION
**
&VALUE   SETA  1
         AIF   ('&BLKMSG' EQ 'WTO').OPTMSOK
&VALUE   SETA  2
         AIF   ('&BLKMSG' EQ 'WTL').OPTMSOK
&VALUE   SETA  3
         AIF   ('&BLKMSG' EQ 'NO').OPTMSOK
         MNOTE 16,'BLKMSG=&BLKMSG IS INVALID'
         MEXIT
.OPTMSOK ANOP
         DC    AL1(&VALUE)             OPTIMIZATION MESSAGE
**
&VALUE   SETA  1
         AIF   ('&BUFMSG' EQ 'WTO').BUFMSOK
&VALUE   SETA  2
         AIF   ('&BUFMSG' EQ 'WTL').BUFMSOK
&VALUE   SETA  3
         AIF   ('&BUFMSG' EQ 'NO').BUFMSOK
         MNOTE 16,'BUFMSG=&BUFMSG IS INVALID'
         MEXIT
.BUFMSOK ANOP
         DC    AL1(&VALUE)             BUFFER SET MESSAGE
**
&VALUE   SETA  1
         AIF   ('&TSOMSG' EQ 'YES').TSOMSOK
&VALUE   SETA  2
         AIF   ('&TSOMSG' EQ 'NO').TSOMSOK
         MNOTE 16,'TSOMSG=&TSOMSG IS INVALID'
         MEXIT
.TSOMSOK ANOP
         DC    AL1(&VALUE)             TSO MESSAGE FLAG
**
&VALUE   SETA  1
         AIF   ('&SETBLK' EQ 'YES').ACTNOK
&VALUE   SETA  2
         AIF   ('&SETBLK' EQ 'NO').ACTNOK
         MNOTE 16,'SETBLK=&SETBLK IS INVALID'
         MEXIT
.ACTNOK  ANOP
         DC    AL1(&VALUE)             SETBLK (REBLOCK) FLAG
**
&VALUE   SETA  1
         AIF   ('&PGMDCB' EQ 'YES').HDCBSOK
&VALUE   SETA  2
         AIF   ('&PGMDCB' EQ 'NO').HDCBSOK
         MNOTE 16,'PGMDCB=&PGMDCB IS INVALID'
         MEXIT
.HDCBSOK ANOP
         DC    AL1(&VALUE)             OPTIMIZE HARD CODE DCB'S
**
&VALUE   SETA  1
         AIF   ('&SETBUF' EQ 'YES').BUFFOK
&VALUE   SETA  2
         AIF   ('&SETBUF' EQ 'NO').BUFFOK
         MNOTE 16,'SETBUF=&SETBUF IS INVALID'
         MEXIT
.BUFFOK  ANOP
         DC    AL1(&VALUE)             CHANGE # OF BUFFERS FLAG
**
&VALUE   SETA  1
         AIF   ('&RPG' EQ 'YES').RPGOK
&VALUE   SETA  2
         AIF   ('&RPG' EQ 'NO').RPGOK
         MNOTE 16,'RPG=&RPG IS INVALID'
         MEXIT
.RPGOK   ANOP
         DC    AL1(&VALUE)             RPG PROGRAMS FLAG
**
         AIF   ('&SORTIN' EQ '').NOSRTIN
&COUNT   SETA  N'&SORTIN
         AIF   ('&COUNT' EQ '0').NOSRTIN
         AIF   ('&COUNT' LT '33').OKSRTIN
         MNOTE 16,'TOO MANY SORTIN DD NAMES'
         MEXIT
.OKSRTIN ANOP
&INDEX   SETA  1
.LOOP    ANOP
&TEXT    SETC  '&SORTIN(&INDEX)'
         DC    CL8'&TEXT'
         AIF   ('&INDEX' EQ '&COUNT').NOSRTIN
&INDEX   SETA  &INDEX+1
         AGO   .LOOP
.NOSRTIN ANOP
&COUNT   SETA  32-N'&SORTIN
         DC    &COUNT.CL8' '
         MEND
