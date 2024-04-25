JISSMFD  DSECT
**
**       S.I.O. SMF RECORD LAYOYT
**
JISLLBB  DC    F'0'                    LL-BB
JISSYSI  DC    XL1'00'                 SYSTEM TYPE
JISSMFI  DC    XL1'00'                 RECORD NUMBER
JISTIME  DC    XL4'00'                 SMF RECORD TIME (BIN)
JISDATE  DC    XL4'00'                 SMF RECORD DATE (0YYDDDF)
JISSSID  DC    CL4' '                  SUB SYSTEM ID
JISJOBN  DC    CL8' '                  JOB NAME
JISSTEP  DC    CL8' '                  STEP NAME
JISDDNM  DC    CL8' '                  DDNAME
JISPGMN  DC    CL8' '                  PROGRAM NAME
JISVOLS  DC    CL6' '                  VOLUME SERIAL NUMBER
JISBLKF  DC    CL3'PGM'                WERE BLOCK SIZE FOUND
JISOBLK  DC    CL5' '                  OLD BLOCK SIZE
JISNBLK  DC    CL5' '                  NEW BLOCK SIZE
JISATYP  DC    CL6' '                  ACCESS TYPE
JISDSNM  DC    CL44' '                 DATA SET NAME
JISSMFL  EQU   *-JISSMFD               RECORD LENGTH
