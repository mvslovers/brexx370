***********************************************************************
**                                                                   **
**     THESE PROGRAMS WILL BE BYPASSED DURING SIO PROCESSING         **
**                                                                   **
***********************************************************************
         SIO5TBL MODE=BYPASS,PROGRAM=IEWL
         SIO5TBL MODE=BYPASS,PROGRAM=HEWL
         SIO5TBL MODE=BYPASS,PROGRAM=HMASMP
         SIO5TBL MODE=BYPASS,PPREFIX=GIM
         SIO5TBL MODE=BYPASS,PPREFIX=DFH
         SIO5TBL MODE=BYPASS,PROGRAM=IEHINITT
         SIO5TBL MODE=BYPASS,PROGRAM=TMSTPNIT
         SIO5TBL MODE=BYPASS,PROGRAM=ICNRTNDF
***********************************************************************
**                                                                   **
**                     EXEMPT ENTRIES                                **
**                                                                   **
***********************************************************************
**
**       THE FOLLOWING EXEMPT ENTRIES MUST BE USED
**       BECAUSE REBLOCKING WILL CREATE PROBLEMS
**       FOR THE ASSEMBLER, LINKAGE-EDITOR AND SMP.
**
         SIO5TBL MODE=EXEMPT,DDNAME=SYSPUNCH
         SIO5TBL MODE=EXEMPT,DDNAME=SYSGO
         SIO5TBL MODE=EXEMPT,DDNAME=SYSLIN
         SIO5TBL MODE=EXEMPT,DDNAME=DVDCODE
**
**       THE FOLLOWING EXEMPT ENTRIES MUST BE USED
**       FOR DISOSS
**
         SIO5TBL MODE=EXEMPT,DDNAME=DSVWRKSS
         SIO5TBL MODE=EXEMPT,DDNAME=DSVWRK
         SIO5TBL MODE=EXEMPT,DDNAME=DSVWRKJB
***********************************************************************
**                                                                   **
**                SELECT ENTRIES  (QSAM)                             **
**                                                                   **
***********************************************************************
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=SYS88,           TEMP DATA SETS                  X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               BUFNUM=(NUMBER,5),      ALLOCATE BUFFERS                X
               ACCMETH=QSAM            INDICATE QSAM
***********************************************************************
**                                                                   **
**                SELECT ENTRIES  (BSAM)                             **
**                                                                   **
***********************************************************************
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PROGRAM=IEBGENER,       IEBGENER USES BSAM              X
               DDNAME=SYSUT1,          INPUT FILE ONLY                 X
               ACCMETH=BSAM            INDICATE BSAM USED
***********************************************************************
**                                                                   **
**                SELECT ENTRIES  (VSAM)                             **
**                                                                   **
**       PLEASE NOTE THAT THE VSAM ENTRIES ARE USED FOR BUFFERING    **
**       PURPOSES ONLY.                                              **
**                                                                   **
***********************************************************************
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=XXXXX,           DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               MACRF=(DIR),            VSAM MACRF SELECTED             X
               BUFNUM=(6,3),           BUFNI=6, BUFND=3                X
               ACCMETH=VSAM            INDICATE VSAM USED
**
         SIO5TBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=XXXXX,           DATA SET NAME PREFIX            X
               SETBUF=YES,             CHANGE THE BUFFERS              X
               MACRF=(SEQ),            VSAM MACRF SELECTED             X
               AMP=OVERRIDE,           FORCE THE BUFFERING             X
               BUFNUM=(SPACE,128000),  BUFSP=128000                    X
               ACCMETH=VSAM            INDICATE VSAM USED
         END
