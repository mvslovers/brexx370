**
**       SIO SMF RECORD DESCRIPTION
**
SSRECRD  DC    0F'0'
SSRJOBN  DC    CL8' '                  JOB NAME
SSRSTEP  DC    CL8' '                  STEP NAME
SSRPROG  DC    CL8' '                  PROGRAM NAME
SSRDDNM  DC    CL8' '                  DDNAME
SSRDSNM  DC    CL44' '                 DATA SET NAME
SSRVOLS  DC    CL6' '                  VOLUME SERIAL NUMBER
**
SSRNBLK  DC    XL2'00'                 NEW BLOCK SIZE
**
SSRDATE  DC    0XL4'00'                RECORD DATE
SSRXIOT  DC    XL4'00'                 I/O TIME SAVED
**
SSRTIME  DC    0XL4'00'                RECORD TIME
SSRXEXC  DC    XL4'00'                 EXCP'S SAVED
**
SSRJOBD  DC    0XL4'00'                READER DATE
SSRXTRK  DC    XL4'00'                 TRACKS SAVED
**
SSRJOBT  DC    0XL4'00'                READER TIME
         DC    XL4'00'
**
SSREXCP  DC    XL4'00'                 EXCP COUNT
SSRDTYP  DC    XL4'00'                 DEVICE TYPE
SSRTRKS  DC    XL4'00'                 TRACKS/BLOCS USED
SSRIOTM  DC    XL4'00'                 I/O TIME
**
SSRUSEC  DC    XL2'00'                 USE COUNT
SSRCUAN  DC    XL2'00'                 DEV ADDRESS
SSRLREC  DC    XL2'00'                 RECORD LENGTH
SSRBLKS  DC    XL2'00'                 BLOCK SIZE
SSRECFM  DC    XL2'00'                 RECORD FORMAT
SSRDSRG  DC    XL2'00'                 DATA SET ORGANIZATION
**
SSRTYPE  DC    XL1'00'                 RECORD TYPE
**
SSRLENG  EQU   *-SSRECRD
