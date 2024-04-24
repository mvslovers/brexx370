RXINIT  TITLE 'INITIALIZE  AND CHECK THE BREXX/370 ENVIRONMENT'
* ---------------------------------------------------------------------
*   INITIALIZE  AND CHECK THE BREXX/370 ENVIRONMENT
*   AUTHOR     : MIKE GROSSMANN (MIG)
*   CREATED    : 22.02.2019  MIG
*   C PROLOGUE : JUERGEN WINKELMANN, ETH ZUERICH.
* ---------------------------------------------------------------------
         PRINT   GEN
* =====================================================================
* RXINIT
*
*     MAIN ENTRY POINT USED BY BREXX/370
*
*     INPUT:
*              R1    PARAMS
*
*     OUTPUT:
*              R15   RETURN CODE
*
*     REGISTER USAGE:
*              R4    ENVIRONMENT AREA
*              R5    USER AREA
*              R12   BASE REGISTER
*
* =====================================================================
RXINIT   MRXSTART A2PLIST=YES  START OF PROGRAM
*
         USING PARAMS,RB
         L     R4,ENVPTR       GET PTR TO ENVIRONMENT AREA
         GETMAIN R,LV=USRLEN   GET STORAFE FOR USER AREA
         LR    R5,R1           SAVE GETMAIN POINTER
         USING ENVCTX,R4
         USING USER,R5
         DROP  RB
*
         CALL  PREPARE         PREPARE USERAREA
*
         CALL  CHKISPF         CHECK ISPF ENVIRONMENT
         CALL  CHKTSO          CHECK TSO  ENVIRONMENT
         CALL  CHKEXEC         CHECK EXEC ENVIRONMENT
         CALL  CHKALLOC        CHECK NEEDED ALLOCATIONS
*
         CALL  UPDENV          UDATE ENVIRONMENT AREA
*
         DROP  R5
         FREEMAIN R,LV=USRLEN,A=(5)
*
         MRXEXIT
         LTORG
*
         EJECT
* =====================================================================
* PREPARE
*
*     PERFORM ALL NECESSARY PREPARATIONS
*
*     INPUT:
*              R5    USERAREA
*
*     OUTPUT:
*
*     REGISTER USAGE:
*              R5    USER AREA
*              R12   BASE REGISTER
*              R13   SAVE AREA
*
* =====================================================================
         USING USER,R5
PREPARE  CSECT ,
*
* ---------------------------------------------------------------------
* ENTRY CODING - PART 1 - SAVE CALLER'S REGISTERS
* ---------------------------------------------------------------------
         SAVE  (14,12),,PREPARE  SAVE CALLER'S REGISTERS
         BALR  R12,R0          ESTABLISH ADDRESSABILITY
         USING *,R12           SET BASE REGISTER
* ---------------------------------------------------------------------
* ENTRY CODING - PART 2 - PREPARE USER AREA
* ---------------------------------------------------------------------
         LA    14,USER
         LA    15,USRLEN
         L     1,=AL1(X'00',0,0,0)
         MVCL  14,0
         MVC   USREYE,=CL4'USER' ADD EYE CATCHER
*
* ---------------------------------------------------------------------
* ENTRY CODING - PART 3 - CAHINING SAVE AREAS
* ---------------------------------------------------------------------
         LA    R11,USRSA1      GET SAVE AREA POINTER
         ST    R13,4(R11)      STORE BACKWARD POINTER
         ST    R11,8(R13)      STORE FORWARD POINTER
*
         LR    R13,R11         GET SAVE AREA ADDRESS ..
* ---------------------------------------------------------------------
* FETCH NECESSARY POINTERS
* ---------------------------------------------------------------------
         LA    R2,0            POINT TO THE CURRENT PSA
         USING PSA,R2          ENSURE ADDRESSABILITY
*
         L     R3,PSATOLD      POINT TO THE CURRENT TCB
         ST    R3,USRPTCB      STORE ADDRESS IN THE USER AREA
*
         L     R3,PSAAOLD      POINT TO THE CURRENT ASCB
         ST    R3,USRPASCB     STORE ADDRESS IN THE USER AREA
*
         L     R4,ASCBASXB-ASCB(,R3) AND THEN TO THE ASXB
         ST    R4,USRPASXB     STORE ADDRESS IN THE USER AREA
*
         L     R3,ASXBLWA-ASXB(,R4) GET ADRESS OF THE LWA
         L     R4,LWAPECT-LWA(,R3) POINT TO THE CURRENT ECT
         ST    R4,USRPECT      STORE ADDRESS IN THE USER AREA
 
         L     R3,FLCCVT       POINT TO THE CURRENT CVT
         ST    R3,USRPCVT      STORE ADDRESS IN THE USER AREA
*
         DROP  R2              PSA NOT NEEDED ANYMORE
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
* CHKISPF
*
*     PERFORM ISPF ENVIRONMENT CHECK
*
*     INPUT:
*              R5    USERAREA
*
*     OUTPUT:
*
*     REGISTER USAGE:
*              R5    USERREA
*              R12   BASE REGISTER
*
* =====================================================================
         USING USER,R5
CHKISPF  CSECT ,
*
* ---------------------------------------------------------------------
* ENTRY CODING
* ---------------------------------------------------------------------
         SAVE  (14,12),,CHKISPF  SAVE CALLER'S REGISTERS
         BALR  R12,R0          ESTABLISH ADDRESSABILITY
         USING *,R12           SET BASE REGISTER
*
         LA    R11,USRSA1      GET SAVE AREA POINTER
         ST    R13,4(R11)      STORE BACKWARD POINTER
         ST    R11,8(R13)      STORE FORWARD POINTER
*
         LR    R13,R11         GET SAVE AREA ADDRESS ..
* ---
         LA    R4,0            RETURN CODE / MODULE FOUND
* ---------------------------------------------------------------------
* SEE IF THE PROGRAM IS LOCATED IN JOBLIB/STEPLIB OR IN THE LINKLIST.
* ---------------------------------------------------------------------
         MVC   USRBLDLN,ISPTPNAM MOVE IN PROGRAM NAME FOR BLDL
         MVC   USRBLDLF,=H'1'  SET # ENTRIES TO SEARCH
         MVC   USRBLDLL,=H'50' SET P-LIST LENGTH
         BLDL  0,USRBLDL       ATTEMPT TO LOCATE THE PROGRAM
         IF (LTR,R15,R15,NZ)
* ---------------------------------------------------------------------
* IF NOT INVOKE IEAVVMSR TO SEARCH LPA. THIS ROUTINE DESTROYS
* R3, R6, R8, R9, AND RETURNS TO EITHER R14+0 OR R14+4.
* ---------------------------------------------------------------------
           LM  R0,R1,ISPTPNAM  R0-R1 HAVE PROGRAM NAME
           L   R3,USRPCVT      R3 @ CVT
           L   R15,CVTLPDSR-CVT(R0,R3) R15 @ IEAVVMSR EPA
           BALR R14,R15        SEARCH LPA FOR PROGRAM
           B   *+4             FOUND
           LA  R4,4            NOT FOUND
         ENDIF
         IF (LTR,R4,R4,Z)
* ---------------------------------------------------------------------
* THE PROGRAM WAS FOUND.
* ---------------------------------------------------------------------
           LOAD  EP=ISPQRY       LOAD ENTRY POINT OF ISPQRY
           LR    R15,R0          MOVE EP TO R15
           CALL  (15)            CALL ISPQRY
           IF (LTR,R15,R15,Z)    IF RC = 15 ISPF ENVIRONMENT IS PRESENT
             OI  UFLAGS2,UF2ISPF
           ENDIF
         ENDIF
* ---------------------------------------------------------------------
* EXIT CODING
* ---------------------------------------------------------------------
         L     R13,4(,R13)     PICK UP CALLER'S SAVE AREA
         L     R14,12(,R13)    GET RETURN ADDRESS
         RETURN (0,12)
*
         LTORG
ISPTPNAM DC    CL8'ISPQRY'
*
         EJECT
* =====================================================================
* CHKTSO
*      PERFORM TSO ENVIRONMENT CHECK
*
*      INPUT:  R5  - USERAREA
*
*      OUTPUT:
*
*      REGISTER USAGE:
*              R5    USERREA
*              R12   BASE REGISTER
*
* =====================================================================
         USING USER,R5
CHKTSO   CSECT ,
*
* ---------------------------------------------------------------------
* ENTRY CODING
* ---------------------------------------------------------------------
         SAVE  (14,12),,CHKTSO SAVE CALLER'S REGISTERS
         BALR  R12,R0          ESTABLISH ADDRESSABILITY
         USING *,R12           SET BASE REGISTER
*
         LA    R11,USRSA1      GET SAVE AREA POINTER
         ST    R13,4(R11)      STORE BACKWARD POINTER
         ST    R11,8(R13)      STORE FORWARD POINTER
*
         LR    R13,R11         GET SAVE AREA ADDRESS ..
* ---------------------------------------------------------------------
* USING THE EXTRACT MACRO TO GET CONTROL BLOCKS FROM TCB
* ---------------------------------------------------------------------
         EXTRACT UEXTADDR,FIELDS=(TIOT,TSO,PSB),MF=(E,ULEXTR)
         LM    R1,R3,UEXTADDR     R1   R2  R3
         ST    R1,USRPTIOT     SAVE POINTER TO TIOT     3X INIT
* --- TEST FOR FOREGROUND TSO
         IF (TM,0(R2),X'80',O) TEST HIGH-ORDER BIT
           OI  UFLAGS2,UF2TSOFG  MARK FOREGROUND TSO AS FOUND
         ENDIF
* --- TEST FOR BACKGROUND
         IF (LTR,R3,R3,NZ)     TEST IF ADDRESS OF PSCB IS PRESENT
           ST  R3,USRPSCB
           OI  UFLAGS2,UF2TSOBG  MARK BACKGROUND TSO AS FOUND
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
* CHKEXEC
*
*     PERFORM EXEC ENVIRONMENT CHECK
*
*     INPUT:
*              R5    USERAREA
*
*     OUTPUT:
*
*     REGISTER USAGE:
*              R5    USERREA
*              R12   BASE REGISTER
*
* =====================================================================
         USING USER,R5
CHKEXEC  CSECT ,
*
* ---------------------------------------------------------------------
* ENTRY CODING
* ---------------------------------------------------------------------
         SAVE  (14,12),,CHKEXEC  SAVE CALLER'S REGISTERS
         BALR  R12,R0          ESTABLISH ADDRESSABILITY
         USING *,R12           SET BASE REGISTER
*
         LA    R11,USRSA1      GET SAVE AREA POINTER
         ST    R13,4(R11)      STORE BACKWARD POINTER
         ST    R11,8(R13)      STORE FORWARD POINTER
*
         LR    R13,R11         GET SAVE AREA ADDRESS ..
* ---------------------------------------------------------------------
* CHECK FOR EXEC / CLIST ENVIRONMENT
* ---------------------------------------------------------------------
         IF (TM,UFLAGS2,UF2TSOFG,O),OR,                                *
               (TM,UFLAGS2,UF2TSOBG,O)
*
           L   R2,USRPASXB     GET ADDRESS OF THE ASXB
           L   R1,ASXBLWA-ASXB(,R2) GET ADRESS OF THE LWA
           L   R2,LWAPECT-LWA(,R1) POINT TO THE CURRENT ECT
           L   R1,ECTIOWA-ECT(,R2)  AND THEN TO THE IOSRL
           L   R2,IOSTELM-IOSRL(,R1) AND THEN TO THE IOSTELM
           LA  R1,INSCODE-INSTACK(,R2) FINALLY TO THE STACK OPTIONS
 
           IF (TM,0(R1),INSEXEC,O) TEST STACK OPTIONS
             OI  UFLAGS2,UF2EXEC     MARKS AS EXEC
           ENDIF
*
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
* CHKALLOC
*
*     PERFORM ALLOCATION CHECK
*
*     INPUT:
*              R4    ENVIRONMENT AREA
*              R5    USER AREA
*
*     OUTPUT:
*
*     REGISTER USAGE:
*              R5    USERREA
*              R12   BASE REGISTER
*
* =====================================================================
         USING ENVCTX,R4
         USING USER,R5
CHKALLOC CSECT ,
*
* ---------------------------------------------------------------------
* ENTRY CODING
* ---------------------------------------------------------------------
         SAVE  (14,12),,CHKALLOC SAVE CALLER'S REGISTERS
         BALR  R12,R0          ESTABLISH ADDRESSABILITY
         USING *,R12           SET BASE REGISTER
*
         LA    R11,USRSA1      GET SAVE AREA POINTER
         ST    R13,4(R11)      STORE BACKWARD POINTER
         ST    R11,8(R13)      STORE FORWARD POINTER
*
         LR    R13,R11         GET SAVE AREA ADDRESS
* ---------------------------------------------------------------------
* CHECK NEEDED ALLOCATIONS
* ---------------------------------------------------------------------
         L     R6,USRPTIOT     GET POINTER TO TIOT
         USING TIOT1,R6
*
         DO WHILE=(CLI,TIOELNGH,NE,X'00')
           IF (CLC,TIOEDDNM,EQ,=CL8'STDIN') STDIN FOUND
             OI  UFLAGS1,UF1IN   SET FOUND FLAG
           ELSEIF (CLC,TIOEDDNM,EQ,=CL8'STDOUT') STDOUT FOUND
             OI  UFLAGS1,UF1OUT  SET FOUND FLAG
           ELSEIF (CLC,TIOEDDNM,EQ,=CL8'STDERR') STDERR FOUND
             OI  UFLAGS1,UF1ERR  SET FOUND FLAG
           ELSEIF (CLC,TIOEDDNM,EQ,=CL8'RXLIB')  RXLIB FOUND
             OI  UFLAGS1,UF1RXL  SET FOUND FLAG
           ENDIF
*
           SR  R1,R1           CLEAR R1
           IC  R1,TIOELNGH     SAVE LENGTH VALUE IN R1
           LA  R6,0(R1,R6)     PREPARE NEXT ITERATION
*
         ENDDO
*
         DROP  R6              TIOT IS NOT LONGER NEEDED
* ---------------------------------------------------------------------
* HANDLE THE MISSING ALLOCATIONS - STDIN / STDOUT / STDERR
* ---------------------------------------------------------------------
         IF (TM,UFLAGS2,UF2TSOFG,O) ONLY FOR TSOFG
           IF (TM,UFLAGS1,UF1IN,NO)
             CALL DYNATERM,(=CL8'STDIN'),MF=(E,ULCALL2) ALLOC STDIN
             OI  UFLAGS3,UF3IN MARK STDIN AS ALLOCATED
           ENDIF
 
           IF (TM,UFLAGS1,UF1OUT,NO)
             CALL DYNATERM,(=CL8'STDOUT'),MF=(E,ULCALL2) ALLOC STDOUT
             OI  UFLAGS3,UF3OUT MARK STDOUT AS ALLOCATED
           ENDIF
 
           IF (TM,UFLAGS1,UF1ERR,NO)
             CALL DYNATERM,(=CL8'STDERR'),MF=(E,ULCALL2) ALLOC STDERR
             OI  UFLAGS3,UF3ERR MARK STDERR AS ALLOCATED
           ENDIF
         ENDIF
* ---------------------------------------------------------------------
* ALLOCATE VIO DATASETS - TMPIN / TMPOUT
* ---------------------------------------------------------------------
*        CALL DYNAVIO,(=CL8'TMPIN'),MF=(E,ULCALL2)
*        OI  UFLAGS3,UF3VIN  MARK TMPIN  AS ALLOCATED
*        CALL DYNAVIO,(=CL8'TMPOUT'),MF=(E,ULCALL2)
*        OI  UFLAGS3,UF3VOUT MARK TMPOUT AS ALLOCATED
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
* UPDENV
*
*     UPDATE PROVIDED ENVIRONMENT AREA
*
*     INPUT:
*              R4    ENVIRONMENT AREA
*              R5    USER AREA
*
*     OUTPUT:
*
*     REGISTER USAGE:
*              R5    USERREA
*              R12   BASE REGISTER
*
* =====================================================================
         USING ENVCTX,R4
         USING USER,R5
UPDENV   CSECT ,
*
* ---------------------------------------------------------------------
* ENTRY CODING
* ---------------------------------------------------------------------
         SAVE  (14,12),,UPDENV SAVE CALLER'S REGISTERS
         BALR  R12,R0          ESTABLISH ADDRESSABILITY
         USING *,R12           SET BASE REGISTER
*
         LA    R11,USRSA1      GET SAVE AREA POINTER
         ST    R13,4(R11)      STORE BACKWARD POINTER
         ST    R11,8(R13)      STORE FORWARD POINTER
*
         LR    R13,R11         GET SAVE AREA ADDRESS
* ---------------------------------------------------------------------
* COPY FLAGS FROM USER AREA TO ENVIRONMENT AREA
* ---------------------------------------------------------------------
         L     R1,USRFLAGS
         ST    R1,ENVFLAGS
* ---------------------------------------------------------------------
* CREATE ECT POINTER FOR REXX ENVIRONMENT CONTEXT
* ---------------------------------------------------------------------
         IF (TM,UFLAGS2,UF2TSOFG,O),OR,                                *
               (TM,UFLAGS2,UF2TSOBG,O)
*
           L     R6,USRPECT    SET REXX ENVIRONMENT CONTEXT
           ST    R4,48(,R6)      IN THE ECTENVBK FIELD
*
         ENDIF
* ---------------------------------------------------------------------
* FILL TSO SYSVAR VALUES IN ENVIRONMENT AREA
* ---------------------------------------------------------------------
         IF (TM,UFLAGS2,UF2TSOFG,O),OR,                                *
               (TM,UFLAGS2,UF2TSOBG,O)
* ------ SYSPREF ------------------------------------------------------
           MVI   SYSPREF,X'00'
           MVC   SYSPREF+1(L'SYSPREF-1),SYSPREF
*
           L     R1,USRPSCB    GET ADDRESS OF THE PSCB
           L     R2,PSCBUPT-PSCB(,R1) GET ADDRESS OF THE UPT
*
           LA    R6,UPTPREFX-UPT(,R2) GET ADDRESS OF PREFIX VALUE
           SLR   R7,R7
           IC    R7,UPTPREFL-UPT(,R2) GET PREFIX LENGTH
*
           EXMVC SYSPREF,0(R6),LEN=0(R7),MAXLEN=7
* ------ SYSUID -------------------------------------------------------
           MVI   SYSUID,X'00'
           MVC   SYSUID+1(L'SYSUID-1),SYSUID
*
           IF (TM,UFLAGS2,UF2TSOFG,O)
             L     R1,USRPSCB  GET ADDRESS OF THE PSCB
*
             LA    R6,PSCBUSER-PSCB(,R1) GET ADDRESS OF USERID VALUE
             SLR   R7,R7
             IC    R7,PSCBUSRL-PSCB(,R1) GET USERID LENGTH
*
             EXMVC SYSUID,0(R6),LEN=0(R7)
           ELSE
             L     R1,USRPTCB  GET ADDRESS OF THE TCB
*
             IF (TM,278(R1),X'80',O),AND, CHK TCBFBYT3 FOR TCBEXP      *
               (CLI,331(R1),H,X'03')      AND TCBLEVEL > TCBVS03
*
               LA  R2,340(,R1) GET ADDRESS OF ACEE
*
               LA  R6,ACEEUSRI-ACEE(,R2) GET ADDRESS OF USERID VALUE
               SLR R7,R7
               IC  R7,ACEEUSRL-ACEE(,R2) GET USERID LENGTH
*
               EXMVC SYSUID,0(R6),LEN=0(R7),MAXLEN=7
             ENDIF
           ENDIF
* ------ SYSENV -------------------------------------------------------
           MVI   SYSENV,X'00'
           MVC   SYSENV+1(L'SYSENV-1),SYSENV
*
           IF (TM,UFLAGS2,UF2TSOFG,O)
             EXMVC SYSENV,TSOFG,LEN=5
           ELSEIF (TM,UFLAGS2,UF2TSOBG,O)
             EXMVC SYSENV,TSOBG,LEN=5
           ENDIF
* ------ SYSISPF ------------------------------------------------------
           MVI   SYSISPF,X'00'
           MVC   SYSISPF+1(L'SYSISPF-1),SYSISPF
*
           IF (TM,UFLAGS2,UF2ISPF,O)
             EXMVC SYSISPF,ISPFA,LEN=7
           ELSEIF (TM,UFLAGS2,UF2TSOBG,O)
             EXMVC SYSISPF,ISPFNA,LEN=11
           ENDIF
*
         ENDIF
* ---------------------------------------------------------------------
* EXIT CODING
* ---------------------------------------------------------------------
         L     R13,4(,R13)     PICK UP CALLER'S SAVE AREA
         L     R14,12(,R13)    GET RETURN ADDRESS
         RETURN (0,12)
*
         LTORG
TSOFG    DC    CL4'FORE',X'00'
TSOBG    DC    CL4'BACK',X'00'
ISPFA    DC    CL6'ACTIVE',X'00'
ISPFNA   DC    CL10'NOT ACTIVE',X'00'
*
         EJECT
* =====================================================================
* DYNATERM
*
*     PERFORM TERMINAL ALLOCATION FOR GIVE DD NAME
*
*     INPUT:
*              R1    PARAMS
*              R5    USERAREA
*
*     OUTPUT:
*
*     REGISTER USAGE:
*              R5    USERREA
*              R12   BASE REGISTER
*
* =====================================================================
         USING USER,R5
DYNATERM CSECT ,
*
* ---------------------------------------------------------------------
* ENTRY CODING
* ---------------------------------------------------------------------
         SAVE  (14,12),,DYNATERM SAVE CALLER'S REGISTERS
         BALR  R12,R0          ESTABLISH ADDRESSABILITY
         USING *,R12           SET BASE REGISTER
*
         LA    R11,USRSA2      GET SAVE AREA POINTER
         ST    R13,4(R11)      STORE BACKWARD POINTER
         ST    R11,8(R13)      STORE FORWARD POINTER
*
         LR    R13,R11         GET SAVE AREA ADDRESS ..
* ---------------------------------------------------------------------
* GET DD NAME FROM PARAMETERS
* ---------------------------------------------------------------------
         L     R10,0(,R1)
         LA    R10,0(,R10)
* ---------------------------------------------------------------------
* PREPARE REQUEST BLOCK
* ---------------------------------------------------------------------
         XC    UARBP(UALEN),UARBP CLEAR
*
         LA    R9,UARBP
         USING S99RBP,R9
         LA    R4,S99RBPTR+L'S99RBPTR
         USING S99RB,R4
         ST    R4,S99RBPTR
         OI    S99RBPTR,S99RBPND
         DROP  R9
* ---------------------------------------------------------------------
* BUILD REQUEST BLOCK
* ---------------------------------------------------------------------
         MVI   S99RBLN,S99RBLEN
         MVI   S99VERB,S99VRBAL
         LA    R2,UATUPL
         ST    R2,S99TXTPP
         DROP  R4
*
         USING S99TUPL,R2
* ---------------------------------------------------------------------
* ADD DALDDNAM TEXT UNIT POINTER TO LIST
* ---------------------------------------------------------------------
         LA    R6,UADDNAMU
         ST    R6,S99TUPTR
* ---------------------------------------------------------------------
* ADD DALTERM TEXT UNIT POINTER TO LIST
* ---------------------------------------------------------------------
         LA    R2,S99TUPL+L'S99TUPTR POINT TO NEXT ELEMENT
         LA    R6,UATERMU
         ST    R6,S99TUPTR
* ---------------------------------------------------------------------
* ADD DALPERMA TEXT UNIT POINTER TO LIST
* ---------------------------------------------------------------------
         LA    R2,S99TUPL+L'S99TUPTR POINT TO NEXT ELEMENT
         LA    R6,UAPERMU
         ST    R6,S99TUPTR
* ---------------------------------------------------------------------
* ADD DALSTATS TEXT UNIT POINTER TO LIST
* ---------------------------------------------------------------------
         LA    R2,S99TUPL+L'S99TUPTR POINT TO NEXT ELEMENT
         LA    R6,UASTATSU
         ST    R6,S99TUPTR
* ---------------------------------------------------------------------
* MARK LAST ENTRY IN TEXT UNIT POINTER LIST
* ---------------------------------------------------------------------
         OI    S99TUPTR,S99TUPLN
* ---------------------------------------------------------------------
* BUILD TEXT UNITS
* ---------------------------------------------------------------------
         MVC   UADDNAMU(UADDNAML),MADDNAMU
         MVC   UATERMU(UATERML),MATERMU
         MVC   UAPERMU(UAPERML),MAPERMU
         MVC   UASTATSU(UASTATSL),MASTATSU
* ---------------------------------------------------------------------
* FILL TEXT UNITS WITH VALUES
* ---------------------------------------------------------------------
         MVC   UADDNAM(L'UADDNAM),0(R10) DDNAME
         MVI   UASTATS,X'08'             STATUS SHARE
*
         LA    R1,UARBP
         DYNALLOC
* ---------------------------------------------------------------------
* EXIT CODING
* ---------------------------------------------------------------------
         L     R13,4(,R13)     PICK UP CALLER'S SAVE AREA
         L     R14,12(,R13)    GET RETURN ADDRESS
         RETURN (0,12)
*
         LTORG
*
MADDNAMU DC    AL2(DALDDNAM),X'0001',X'0008'    DDNAME
MATERMU  DC    AL2(DALTERM),X'0000'             TERMINAL
MAPERMU  DC    AL2(DALPERMA),X'0000'            PERMANENT
MASTATSU DC    AL2(DALSTATS),X'0001',X'0001'    STATUS
         EJECT
* =====================================================================
* DYNAVIO
*
*     PERFORM VIO ALLOCATION FOR GIVE DD NAME
*
*     INPUT:
*              R1    PARAMS
*              R5    USERAREA
*
*     OUTPUT:
*
*     REGISTER USAGE:
*              R5    USERREA
*              R12   BASE REGISTER
*
* =====================================================================
         USING USER,R5
DYNAVIO  CSECT ,
*
* ---------------------------------------------------------------------
* ENTRY CODING
* ---------------------------------------------------------------------
         SAVE  (14,12),,DYNAVIO  SAVE CALLER'S REGISTERS
         BALR  R12,R0          ESTABLISH ADDRESSABILITY
         USING *,R12           SET BASE REGISTER
*
         LA    R11,USRSA2      GET SAVE AREA POINTER
         ST    R13,4(R11)      STORE BACKWARD POINTER
         ST    R11,8(R13)      STORE FORWARD POINTER
*
         LR    R13,R11         GET SAVE AREA ADDRESS ..
* ---------------------------------------------------------------------
* GET DD NAME FROM PARAMETERS
* ---------------------------------------------------------------------
         L     R10,0(,R1)
         LA    R10,0(,R10)
* ---------------------------------------------------------------------
* PREPARE REQUEST BLOCK
* ---------------------------------------------------------------------
         XC    UARBP(UALEN),UARBP CLEAR
*
         LA    R9,UARBP
         USING S99RBP,R9
         LA    R4,S99RBPTR+L'S99RBPTR
         USING S99RB,R4
         ST    R4,S99RBPTR
         OI    S99RBPTR,S99RBPND
         DROP  R9
* ---------------------------------------------------------------------
* BUILD REQUEST BLOCK
* ---------------------------------------------------------------------
         MVI   S99RBLN,S99RBLEN
         MVI   S99VERB,S99VRBAL
         LA    R2,UATUPL
         ST    R2,S99TXTPP
         DROP  R4
*
         USING S99TUPL,R2
* ---------------------------------------------------------------------
* ADD DALDDNAM TEXT UNIT POINTER TO LIST
* ---------------------------------------------------------------------
         LA    R6,UADDNAMU
         ST    R6,S99TUPTR
* ---------------------------------------------------------------------
* ADD DALTERM TEXT UNIT POINTER TO LIST
* ---------------------------------------------------------------------
         LA    R2,S99TUPL+L'S99TUPTR POINT TO NEXT ELEMENT
         LA    R6,UATERMU
         ST    R6,S99TUPTR
* ---------------------------------------------------------------------
* ADD DALPERMA TEXT UNIT POINTER TO LIST
* ---------------------------------------------------------------------
         LA    R2,S99TUPL+L'S99TUPTR POINT TO NEXT ELEMENT
         LA    R6,UAPERMU
         ST    R6,S99TUPTR
* ---------------------------------------------------------------------
* ADD DALSTATS TEXT UNIT POINTER TO LIST
* ---------------------------------------------------------------------
         LA    R2,S99TUPL+L'S99TUPTR POINT TO NEXT ELEMENT
         LA    R6,UASTATSU
         ST    R6,S99TUPTR
* ---------------------------------------------------------------------
* MARK LAST ENTRY IN TEXT UNIT POINTER LIST
* ---------------------------------------------------------------------
         OI    S99TUPTR,S99TUPLN
* ---------------------------------------------------------------------
* BUILD TEXT UNITS
* ---------------------------------------------------------------------
         MVC   UADDNAMU(UADDNAML),MBDDNAMU
         MVC   UATERMU(UATERML),MBTERMU
         MVC   UASTATSU(UASTATSL),MBSTATSU
* ---------------------------------------------------------------------
* FILL TEXT UNITS WITH VALUES
* ---------------------------------------------------------------------
         MVC   UADDNAM(L'UADDNAM),0(R10) DDNAME
         MVI   UASTATS,X'08'             STATUS SHARE
*
         LA    R1,UARBP
         DYNALLOC
* ---------------------------------------------------------------------
* EXIT CODING
* ---------------------------------------------------------------------
         L     R13,4(,R13)     PICK UP CALLER'S SAVE AREA
         L     R14,12(,R13)    GET RETURN ADDRESS
         RETURN (0,12)
*
         LTORG
*
MBDDNAMU DC    AL2(DALDDNAM),X'0001',X'0008'    DDNAME
MBTERMU  DC    AL2(DALTERM),X'0000'             TERMINAL
MBSTATSU DC    AL2(DALSTATS),X'0001',X'0001'    STATUS
         EJECT
* =====================================================================
* PARAMETER AREA
* =====================================================================
PARAMS   DSECT
ENVPTR   DS    A
WORKPTR  DS    A
* =====================================================================
* USER AREA DUMMY SECTION
* =====================================================================
USER     DSECT
USREYE   DS    0CL4            THE EYE CATCHER
         DC    CL4'USER'
USRSA1   DS    18F             SAVE AREA DEPTH 1
USRSA2   DS    18F             SAVE AREA DEPTH 2
* --- ADDRESS FIELDS
USRPASCB DS    F               PTR TO ASCB
USRPASXB DS    F               PTR TO ASXB
USRPECT  DS    F               PTR TO ECT
USRPTCB  DS    F               PTR TO TCB
USRPTIOT DS    F               PTR TO TIOT
USRPCVT  DS    F               PTR TO CVT
USRPSCB  DS    F               PTR TO PSCB
* --- BLDL MACRO
         DS    0F              ALIGNMENT FOR BLDL
USRBLDL  DS    0CL80           BLDL PARAMETER LIST
USRBLDLF DS    H               # BLDL ENTRIES TO SEARCH
USRBLDLL DS    H               LENGTH OF BLDL PARAMTER LIST
USRBLDLN DS    CL8             PROGRAM NAME TO SEARCH
USRBLDLD DS    CL68            BLDL RETURN DATA AREA
* --- EXTRACT MACRO
UEXTADDR DS    3F
ULEXTR   EXTRACT MF=L          EXTRACT PARAMETER LIST
* --- CALL MACROS
ULCALL1  CALL ,(0,0,0),MF=L    CALL PARAMETER LIST W 3 PARMS DEPTH 1
ULCALL2  CALL ,(0,0,0),MF=L    CALL PARAMETER LIST W 3 PARMS DEPTH 2
* --- FLAG FIELDS
USRFLAGS DS    0F
* ALLOCATIONS FOUND
UFLAGS1  DC    X'00'
UF1B8    EQU   X'80' 1... ....  UNSED
UF1B7    EQU   X'40' .1.. ....  UNSED
UF1B6    EQU   X'20' ..1. ....  UNSED
UF1B5    EQU   X'10' ...1 ....  UNSED
UF1RXL   EQU   X'08' .... 1...  RXLIB  ALLOCATION FOUND
UF1ERR   EQU   X'04' .... .1..  STDERR ALLOCATION FOUND
UF1OUT   EQU   X'02' .... ..1.  STDOUT ALLOCATION FOUND
UF1IN    EQU   X'01' .... ...1  STDIN  ALLOCATION FOUND
* ENVIRONMENTS FOUND
UFLAGS2  DC    X'00'
UF2B8    EQU   X'80' 1... ....  UNSED
UF2B7    EQU   X'40' .1.. ....  UNSED
UF2B6    EQU   X'20' ..1. ....  UNSED
UF2B5    EQU   X'10' ...1 ....  UNSED
UF2ISPF  EQU   X'08' .... 1...  ISPF ENVIRONMENT FOUND
UF2EXEC  EQU   X'04' .... .1..  EXEC ENVIRONMENT FOUND
UF2TSOBG EQU   X'02' .... ..1.  TSO BACKGROUND ENVIRONMENT FOUND
UF2TSOFG EQU   X'01' .... ...1  TSO FOREGROUND ENVIRONMENT FOUND
* ALLOCATIONS MADE BY US
UFLAGS3  DC    X'00'
UF3B8    EQU   X'80' 1... ....  UNSED
UF3B7    EQU   X'40' .1.. ....  UNSED
UF3B6    EQU   X'20' ..1. ....  UNSED
UF3VOUT  EQU   X'10' ...1 ....  TMPOUT ALLOCATED
UF3VIN   EQU   X'08' .... 1...  TMPIN  ALLOCATED
UF3ERR   EQU   X'04' .... .1..  STDERR ALLOCATED
UF3OUT   EQU   X'02' .... ..1.  STDOUT ALLOCATED
UF3IN    EQU   X'01' .... ...1  STDIN  ALLOCATED
* SPARE FLAGS
UFLAGS4  DC    X'00'
UF4B8    EQU   X'80' 1... ....  UNSED
UF4B7    EQU   X'40' .1.. ....  UNSED
UF4B6    EQU   X'20' ..1. ....  UNSED
UF4B5    EQU   X'10' ...1 ....  UNSED
UF4B4    EQU   X'08' .... 1...  UNSED
UF4B3    EQU   X'04' .... .1..  UNSED
UF4B2    EQU   X'02' .... ..1.  UNSED
UF4B1    EQU   X'01' .... ...1  UNSED
* --- DYNALLOC REQUEST BLOCK
UARBP    DS    F,CL20          REQUEST BLOCK POINTER AND REQUEST BLOCK
UATUPL   DS    4A              TEXT UNIT POINTER LIST
* --- TEXT UNITS
UADDNAMU DC    H'1,1,8'        KEY,VALCOUNT,LEN
UADDNAML EQU   *-UADDNAMU
UADDNAM  DS    CL8
UATERMU  DC    H'40,0'         KEY,VALCOUNT,LEN
UATERML  EQU   *-UATERMU
UAPERMU  DC    H'52,0'         KEY,VALCOUNT,LEN
UAPERML  EQU   *-UAPERMU
UASTATSU DC    H'4,1,1'        KEY,VALCOUNT,LEN
UASTATSL EQU   *-UASTATSU
UASTATS  DS    X'08'           SHR
UALEN    EQU *-UARBP
USRLEN   EQU *-USER
         EJECT
* =====================================================================
* EVIRONMENT CONTEXT
* =====================================================================
         #ENVCTX                  BREXX ENVIRONMENT CONTEXT
* =====================================================================
* OTHER DUMMY SECTIONS
* =====================================================================
         CVT      DSECT=YES       COMMON VECTOR TABLE
         IHAPSA   DSECT=YES       PREFIXED SAVE AREA
         IHAASCB  DSECT=YES       ADDRESS SPACE CONTOL BLOCK
         IHAASXB  DSECT=YES       ADDRESS SPACE EXTENSION BLOCK
         IHAACEE  ,               ACCESSOR ENVIRONMENT ELEMENT
         IKJEFLWA ,               LOGON WORK AREA
         IKJECT   ,               ENVIRONMENT CONTROL TABLE
         IKJPSCB  ,               PROTECTED STEP CONTROL BLOCK
         IKJTCB   LIST=YES        TASK CONTROL BLOCK
         IKJUPT   ,               USER PROFILE TABLE
         IEFTIOT1 ,               TASK INPUT OUTPUT TABLE
         IEFZB4D0 ,               DYNALLOC PARAMETER LIST
         IEFZB4D2 ,               DYNALLOC TEXT UNIT KEYS
* --- MISSING LENGTH EQUATE
S99RBLEN EQU   (S99RBEND-S99RB)
* --- I/O SERVICE ROUTINE WORK AREA
IOSRL    DSECT                    ECTIOWA -> IOSRL
IOSTELM  DS    A                  TOP STACK ELEMENT POINTER
IOSBELM  DS    A                  BOTTOM ELEMENT POINTER
IOSTLEN  DS    H                  STACK SIZE
IOSNELM  DS    H                  NUMBER OF ELEMENTS
IOSUNUSD DS    F                  SPARE
* --- INPUT STACK ELEMENT
INSTACK  DSECT                    IOSTELM -> TOP ELEMENT
INSCODE  DS    X                  INPUT STACK OPTIONS
INSTERM  EQU   X'80'              TERMINAL INPUT STACK ENTRY
*        EQU   X'40'              .
INSINDD  EQU   X'20'              INPUT FROM DD VIA DCB
INSOTDD  EQU   X'10'              OUTPUT TO DD VIA DCB
INSEXEC  EQU   X'08'              EXEC COMMAND STACK ENTRY
INSPROM  EQU   X'04'              PROMPT ALLOWED
INSPROC  EQU   X'02'              PROCEDURE FLAG
INSLIST  EQU   X'01'              LIST LINES BEFORE EXEC
INSADLSD DS    AL3                POINTER TO LSD
         EJECT
         COPY  MRXREGS
         END   RXINIT
