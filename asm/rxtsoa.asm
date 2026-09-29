RXTSO   TITLE 'INTERACT WITH TIME SHARING OPTION'
* ---------------------------------------------------------------------
*   INTERACT WITH TIME SHARING OPTION
*   AUTHOR     : MIKE GROSSMANN (MIG)
*   CREATED    : 14.05.2019  MIG
*   C PROLOGUE : JUERGEN WINKELMANN, ETH ZUERICH.
* ---------------------------------------------------------------------
         PRINT   GEN
* =====================================================================
* RXTSO
*
*     MAIN ENTRY POINT USED BY BREXX/370
*
*     INPUT:
*              R11   PARAMS
*
*     OUTPUT:
*              R15   RETURN CODE
*
*     REGISTER USAGE:
*              R4    CPPL
*              R5    USER AREA
*              R12   BASE REGISTER
*
* =====================================================================
RXTSO    MRXSTART A2PLIST=YES  START OF PROGRAM
*
         LR    R4,RB           SAVE PARAMS POINTER
         GETMAIN R,LV=USRLEN   GET STORAGE FOR USER AREA
         LR    R5,R1           SAVE GETMAIN POINTER
*
         CALL  PREPTSO         PREPTSO USERAREA / USING R4&R5
         USING USER,R5
*
         L     R6,USRPUPT
         L     R7,USRPECT
*
         IF (TM,USRFLGS,UF1IN,O)  HANDLE DDIN
           STACK PARM=USRSTPB,UPT=(R6),ECT=(R7),ECB=USRECB,            X
               DATASET=(INDD=USRDDIN,CNTL,SEQ),                        X
               MF=(E,USRIOPL)     PUT DDIN ON STACK
           LTR R15,R15
           BNZ ERROR
*
           OI  USRFLGS,UF1TMP     INDICATE NOT TO CALL STACK DELETE
         ENDIF
*
         IF (TM,USRFLGS,UF1OUT,O)  HANDLE DDOUT
           STACK PARM=USRSTPB,UPT=(R6),ECT=(R7),ECB=USRECB,            X
               DATASET=(OUTDD=USRDDOUT,CNTL,SEQ),                      X
               MF=(E,USRIOPL)     PUT DDOUT ON STACK
           LTR R15,R15
           BNZ ERROR
*
           OI  USRFLGS,UF1TMP     INDICATE NOT TO CALL STACK DELETE
         ENDIF
*
         IF (TM,USRFLGS,UF1TMP,NO)
           STACK PARM=USRSTPB,UPT=(R6),ECT=(R7),ECB=USRECB,            X
               DELETE=TOP,MF=(E,USRIOPL)
           LTR R15,R15
           BNZ ERROR
         ENDIF
*
         LR   R3,R15               SAVE LAST RC
         B    EXIT                 BRANCH OVER ERROR HANDLING
*
ERROR    DS   0H
         LR   R3,R15               SAVE LAST RC
         WTO 'ERROR IN RXTSO'
*
EXIT     FREEMAIN R,LV=USRLEN,A=(5)
*
         LR   R15,R3               RESTORE LAST RC
*
         MRXEXIT
         LTORG
*
         EJECT
* =====================================================================
* PREPTSO
*
*     PERFORM ALL NECESSARY PREPARATIONS
*
*     INPUT:
*              R5    USERAREA
*
*     OUTPUT:
*
*     REGISTER USAGE:
*              R4    PARAMS AREA
*              R5    USER AREA
*              R12   BASE REGISTER
*              R13   SAVE AREA
*
* =====================================================================
         USING PARAMS,R4
         USING USER,R5
PREPTSO  CSECT ,
*
* ---------------------------------------------------------------------
* ENTRY CODING - PART 1 - SAVE CALLER'S REGISTERS
* ---------------------------------------------------------------------
         SAVE  (14,12),,PREPTSO  SAVE CALLER'S REGISTERS
         BALR  R12,R0          ESTABLISH ADDRESSABILITY
         USING *,R12           SET BASE REGISTER
* ---------------------------------------------------------------------
* ENTRY CODING - PART 2 - PREPTSO USER AREA
* ---------------------------------------------------------------------
         #CLEAR USER,LEN=USRLEN,PAD='00'
         MVC   USREYE,=CL4'USER' ADD EYE CATCHER
* ---------------------------------------------------------------------
* ENTRY CODING - PART 3 - CAHINING SAVE AREAS
* ---------------------------------------------------------------------
         LA    R11,USRSA1      GET SAVE AREA POINTER
         ST    R13,4(R11)      STORE BACKWARD POINTER
         ST    R11,8(R13)      STORE FORWARD POINTER
*
         LR    R13,R11         GET SAVE AREA ADDRESS ..
* ---------------------------------------------------------------------
* PREPARE NECESSARY POINTERS AND FIELDS
* ---------------------------------------------------------------------
         L     R1,CPPLPTR      POINT TO THE CPPL
         ST    R1,USRPCPPL     STORE ADDRESS IN THE USER AREA
*
         IF (LTR,R1,R1,NZ)
           L   R2,CPPLUPT-CPPL(,R1)  POINT TO THE UPT
           ST  R2,USRPUPT      STORE ADDRESS IN THE USER AREA
*
           L   R2,CPPLECT-CPPL(,R1)  POINT TO THE ECT
           ST  R2,USRPECT      STORE ADDRESS IN THE USER AREA
         ENDIF
*
         MVC   USRDDIN(8),DDIN   COPY INPUT DDN
         MVC   USRDDOUT(8),DDOUT COPY OUTPUT DDN
*
         DROP  R4              PARAMS NOT NEEDED ANYMORE
* ---------------------------------------------------------------------
* CHECK DD PARAMETERS
* ---------------------------------------------------------------------
         L     R1,USRDDIN
         L     R2,USRDDOUT
*
         XC    USRFLGS,USRFLGS CLEAR FLAGS
*
         IF (LTR,R1,R1,NZ)
           OI USRFLGS,UF1IN
         ENDIF
*
         IF (LTR,R2,R2,NZ)
           OI USRFLGS,UF1OUT
         ENDIF
* ---------------------------------------------------------------------
* EXIT CODING
* ---------------------------------------------------------------------
         L     R13,4(,R13)     PICK UP CALLER'S SAVE AREA
         L     R14,12(,R13)    GET RETURN ADDRESS
         RETURN (0,12)
*
         LTORG
*
         EJECT
* =====================================================================
* PARAMETER AREA
* =====================================================================
PARAMS   DSECT
CPPLPTR  DS    A
DDIN     DS    CL8
DDOUT    DS    CL8
* =====================================================================
* USER AREA DUMMY SECTION
* =====================================================================
USER     DSECT
USRDWORD DS    D               JUST FOR TESTING
USREYE   DS    0CL4            THE EYE CATCHER
         DC    CL4'USER'
USRSA1   DS    18F             SAVE AREA DEPTH 1
USRSA2   DS    18F             SAVE AREA DEPTH 2
* --- ADDRESS FIELDS
USRPCPPL DS    F               PTR TO CPPL
USRPECT  DS    F               PTR TO ECT
USRPUPT  DS    F               PTR TO UPT
* --- DDN
USRDDIN  DS    CL8             DD FOR INPUT
USRDDOUT DS    CL8             DD FOR OUTPUT
* --- FLAGS
USRFLGS  DC    X'00'
UF1B8    EQU   X'80' 1... ....  UNSED
UF1B7    EQU   X'40' .1.. ....  UNSED
UF1B6    EQU   X'20' ..1. ....  UNSED
UF1B5    EQU   X'10' ...1 ....  UNSED
UF1B4    EQU   X'08' .... 1...  RXLIB  ALLOCATION FOUND
UF1TMP   EQU   X'04' .... .1..  TMP INDICATOR FLGAG
UF1OUT   EQU   X'02' .... ..1.  BRXOUT SHOULD BE USED
UF1IN    EQU   X'01' .... ...1  BRXIN  SHOULD BE USED
* --- STACK STUFF
USRSTPB  DS    CL20            STPB WORK AREA
USRIOPL  DS    CL16            IOPL WORK AREA
USRECB   DS    F               PTR TO ECB
* --- CALL MACROS
ULCALL1  CALL ,(0,0,0),MF=L    CALL PARAMETER LIST W 3 PARMS DEPTH 1
ULCALL2  CALL ,(0,0,0),MF=L    CALL PARAMETER LIST W 3 PARMS DEPTH 2
USRLEN   EQU *-USER
         EJECT
* ---------------------------------------------------------------------
* OTHER DUMMY SECTIONS
* ---------------------------------------------------------------------
         PRINT    GEN
         CVT      DSECT=YES       COMMON VECTOR TABLE
         IHAPSA   DSECT=YES       PREFIXED SAVE AREA
         IKJCPPL  ,               COMMAND PROCESSOR PARAMETER LIST
CPPLLEN  EQU   *-CPPL             LENGTH OF CPPL
*
         IKJUPT   ,               USER PROFILE TABLE
UPTLEN   EQU   *-UPT              LENGTH OF UPT
*
         IKJECT   ,               ENVIRONMENT CONTROL TABLE
ECTLEN   EQU   *-ECT              LENGTH OF ECT
*
         IKJIOPL  ,               INPUT/OUTPUT PARAMETER LIST
IOPLLEN  EQU   *-IOPL             LENGTH OF IOPL
*
         IKJSTPL  ,               STACK PARAMETER LIST
STPLLEN  EQU   *-STPL             LENGTH OF STPL
*
         IKJSTPB  ,               STACK PARAMETER BLOCK
STPBLEN  EQU   *-STPB             LENGTH OF STPB
*
         EJECT
         COPY  MRXREGS
         END   RXTSO
