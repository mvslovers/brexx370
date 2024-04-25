         TITLE '"SIOSEXT" SEQUENTIAL I/O OPTIMIZER USER EXIT MODULE'
**
**       REGISTER DEFINITIONS
**
R0       EQU   0
R1       EQU   1
R2       EQU   2
R3       EQU   3
R4       EQU   4
R5       EQU   5
R6       EQU   6
R7       EQU   7
R8       EQU   8
R9       EQU   9
R10      EQU   10
R11      EQU   11
R12      EQU   12
R13      EQU   13
R14      EQU   14
R15      EQU   15
         EJECT
         DCBD  DSORG=PS
         EJECT
DEXJOBD  DSECT
**
**       JOB DEFINITIONS PASSED TO THE EXIT
**
DEXJOBN  DC    CL8' '                  JOB NAME
         DC    CL1' '
DEXSTEP  DC    CL8' '                  STEP NAME
         DC    CL1' '
DEXDDNM  DC    CL8' '                  DDNAME
         DC    CL1' '
DEXPGMN  DC    CL8' '                  PROGRAM NAME
         DC    CL1' '
DEXVOLS  DC    CL6' '                  VOLUME SERIAL NUMBER
         DC    CL1' '
DEXBLKF  DC    CL3'   '                BLOCK SIZE DEFINED (EXT/PGM)
         DC    CL1' '
         DC    CL7' '
DEXOBLK  DC    CL5' '                  OLD BLOCK SIZE
         DC    CL1' '
         DC    CL7' '
DEXNBLK  DC    CL5' '                  NEW BLOCK SIZE
         DC    CL1' '
DEXATYP  DC    CL6' '                  OPEN TYPE (INPUT/OUTPUT)
         DC    CL1' '
DEXDSNM  DC    CL44' '                 DATA SET NAME
         EJECT
SIO5EXT  CSECT
**
**       THE SIO5MID MACRO MUST BE USED FOR THE RELEASE 5 USER
**       EXIT EVEN IF THE NAME IS CHANGED FROM SIO5DEX TO OTHER
**       NAME.  THE CSECT NAME MUST BE THE SAME AS THE ONE CODED
**       IN THE GLOBAL TABLE. DIFFERENCE IN THESE NAMES WILL
**       PREVENT SIO INITIALIZATION.
**
         SIO5MID
**
**       EPA FROM SIO IS HERE
**
         USING *,R15
**
**       REGISTER ONE POINTS TO THE EXIT PARAMETER LIST.
**
         SPACE 2
**
**       THIS IS A DUMMY SIO USER EXIT
**
         SLR   R15,R15                  CLEAR THE RETURN CODE
         BR    R14                      AND RETURN TO SIO
         END
