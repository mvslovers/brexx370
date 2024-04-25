***********************************************************************
**                                                                   **
**     THESE PROGRAMS WILL BE BYPASSED DURING SIO PROCESSING         **
**                                                                   **
***********************************************************************
         SIOSTBL MODE=BYPASS,PROGRAM=IEWL
         SIOSTBL MODE=BYPASS,PROGRAM=HEWL
         SIOSTBL MODE=BYPASS,PROGRAM=HMASMP
         SIOSTBL MODE=BYPASS,PROGRAM=GIMSMP
         SIOSTBL MODE=BYPASS,PROGRAM=IEHINITT
         SIOSTBL MODE=BYPASS,PROGRAM=TMSTPNIT
         SIOSTBL MODE=BYPASS,PROGRAM=ICNRTNDF
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
         SIOSTBL MODE=EXEMPT,DDNAME=SYSPUNCH
         SIOSTBL MODE=EXEMPT,DDNAME=SYSGO
         SIOSTBL MODE=EXEMPT,DDNAME=SYSLIN
         SIOSTBL MODE=EXEMPT,DDNAME=DVDCODE
**
**       THE FOLLOWING EXEMPT ENTRIES MUST BE USED
**       FOR DISOSS
**
         SIOSTBL MODE=EXEMPT,DDNAME=DSVWRKSS
         SIOSTBL MODE=EXEMPT,DDNAME=DSVWRK
         SIOSTBL MODE=EXEMPT,DDNAME=DSVWRKJB
***********************************************************************
**                                                                   **
**                SELECT ENTRIES  (QSAM)                             **
**                                                                   **
***********************************************************************
         SIOSTBL MODE=SELECT,          SELECT THESE FILES:             X
               PREFIX=SYS87,           TEMP DATA SETS                  X
               ACCMETH=QSAM            INDICATE QSAM
***********************************************************************
**                                                                   **
**                SELECT ENTRIES  (BSAM)                             **
**                                                                   **
***********************************************************************
         SIOSTBL MODE=SELECT,          SELECT THESE FILES:             X
               PROGRAM=IEBGENER,       IEBGENER USES BSAM              X
               DDNAME=SYSUT1,          INPUT FILE ONLY                 X
               ACCMETH=BSAM            INDICATE BSAM USED
         SIOSTBL MODE=SELECT,          SELECT THESE FILES:             X
               PROGRAM=IEBGENER,       IEBGENER USES BSAM              X
               DDNAME=SYSUT2,          INPUT FILE ONLY                 X
               ACCMETH=BSAM            INDICATE BSAM USED
         END
