IRXEXCOM TITLE 'BREXX VARIABLE EXCHANGE ROUTINE'
         PRINT   GEN
IRXEXCOM START 0                  START MAIN CODE CSECT AT BASE 0
*
*        ENTRY CODING
*
         SAVE  (14,12)            SAVE INPUT REGISTERS
         LR    R12,R15            BASE REGISTER := ENTRY ADDRESS
         USING IRXEXCOM,R12       DECLARE BASE REGISTER
*
         LR    R11,R1             SAVE PARAMS
*
*        ALLOCATE USER AREA
*
         GETMAIN R,LV=USRLEN      GET STORAFE FOR USER AREA
         LR    R10,R1             SAVE GETMAIN POINTER
         USING USER,R10
         MVC   USREYE,=CL4'USER'
*
         ST    R13,USRSAVEA+4     SET BACK POINTER IN CURRENT SAVE AREA
         LR    R2,R13             REMEMBER CALLERS SAVE AREA
         LA    R13,USRSAVEA       SETUP CURRENT SAVE AREA
         ST    R13,8(R2)          SET FORW POINTER IN CALLERS SAVE AREA
*
         SR    R4,R4              SET RC REGISTER TO ZERO
*
*        CHECK FOR REXX ENVBLOCK
*
         IF (LTR,R4,R4,Z)         CHECK PRESENS OF REXX ENVBLOCK
*          IMPLEMENT ENVBLOCK CHECK HERE
           SR R15,R15             DUMMY
           IF (LTR,R15,R15,NZ)
             LA R4,8              SET RC .......
           ENDIF
         ENDIF
*
*        CHECK FOR CL8'IRXEXCOM'  IN FIRST PARMAMETER
*
         IF (LTR,R4,R4,Z)
           L     R2,0(,R11)         GET 1ST PARAMETER => EXCOMID
           IF (CLC,0(L'EXCOMID,R2),NE,EXCOMID)
             LA  R4,12            SET RC ........
           ENDIF
         ENDIF
*
*        LETZ GO
*
         IF (LTR,R4,R4,Z)
           L     R9,12(,R11)      GET SHVBLOCK
           USING SHVBLOCK,R9
*
           MVC     USRNAMA,SHVNAMA
           MVC     USRNAML,SHVNAML
           MVC     USRVALA,SHVVALA
*
           IF (CLI,SHVCODE,EQ,SHVFETCH)
             MVC   USRBUFL,SHVBUFL
             LA    R0,USRVLRET           FIX
             ST    R0,USRVLRET           FIX
             L     R15,=V(GETVAR)
           ELSEIF (CLI,SHVCODE,EQ,SHVSTORE)
*
             L     R1,SHVVALL
             CVD   R1,PNUM
             UNPK  CNUM,PNUM
             OI    CNUM+L'CNUM-1,X'F0'
*
*            TPUT  =C'LENGTH=',7
*            TPUT  CNUM,16
*
             MVC   USRVALL,SHVVALL
             L     R15,=V(SETVAR)
           ENDIF
           LA    R1,USRPARM
           BALR  R14,R15
           IF (LTR,R4,R15,Z)
              MVC  SHVVALL,USRVLRET
           ENDIF
         ENDIF
*
         L     R13,USRSAVEA+4     GET OLD SAVE AREA BACK
         FREEMAIN R,LV=USRLEN,A=(10)
         IF (CH,R4,EQ,=H'0')
           LH   R15,=H'0'
         ELSEIF (CH,R4,EQ,=H'8')   L OTHER POSSIBLE RC'S
           LH   R15,=H'-1'
         ELSEIF (CH,R4,EQ,=H'12')
           LH   R15,=H'-2'
         ELSE
           LH   R15,=H'255'    FALLBACK
         ENDIF
*
         RETURN (14,12),RC=(15)   RETURN TO OS
*
         DS    0D
PNUM     DS    PL8
CNUM     DS    CL16
*
         LTORG
EXCOMID  DC    CL8'IRXEXCOM'
*
         EJECT
* =====================================================================
* USER AREA DUMMY SECTION
* =====================================================================
USER     DSECT
USREYE   DS    0CL4               THE EYE CATCHER
         DC    CL4'USER'
USRSAVEA DS    18F
***********************************************************************
USRPARM  DS    0F     TODO: EXTRACT TO ITS OWN DSECT
USRNAMA  DS    A
USRNAML  DS    F
USRVALA  DS    A
USRVALL  DS    0F
USRBUFL  DS    F
USRVLRET DS    F
         DS    0D
***********************************************************************
USRLEN   EQU *-USER
         EJECT
* =====================================================================
* SHVBLOCK:  LAYOUT OF SHARED-VARIABLE PLIST ELEMENT
* =====================================================================
SHVBLOCK DSECT
SHVNEXT  DS    A     CHAIN POINTER (0 IF LAST BLOCK)
SHVUSER  DS    F     AVAILABLE FOR PRIVATE USE, EXCEPT DURING
*                      "FETCH NEXT" WHEN IT IDENTIFIES THE
*                      LENGTH OF THE BUFFER POINTED TO BY SHVNAMA.
SHVCODE  DS    CL1   INDIVIDUAL FUNCTION CODE INDICATING
*                      THE TYPE OF VARIABLE ACCESS REQUEST
*                      (S,F,D,S,F,D,N, OR P)
SHVRET   DS    XL1   INDIVIDUAL RETURN CODE FLAGS
         DS    H'0'  RESERVED, SHOULD BE ZERO
SHVBUFL  DS    F     LENGTH OF 'FETCH' VALUE BUFFER
SHVNAMA  DS    A     ADDRESS OF VARIABLE NAME
SHVNAML  DS    F     LENGTH OF VARIABLE NAME
SHVVALA  DS    A     ADDRESS OF VALUE BUFFER
SHVVALL  DS    F     LENGTH OF VALUE
SHVBLEN  EQU   *-SHVBLOCK  (LENGTH OF THIS BLOCK = 32)
         SPACE
*
*     FUNCTION CODES (PLACED IN SHVCODE):
*
*     (NOTE THAT THE SYMBOLIC NAME CODES ARE LOWERCASE)
SHVFETCH EQU   C'F'  COPY VALUE OF VARIABLE TO BUFFER
SHVSTORE EQU   C'S'  SET VARIABLE FROM GIVEN VALUE
SHVDROPV EQU   C'D'  DROP VARIABLE
SHVSYSET EQU   C'S'  SYMBOLIC NAME SET VARIABLE
SHVSYFET EQU   C'F'  SYMBOLIC NAME FETCH VARIABLE
SHVSYDRO EQU   C'D'  SYMBOLIC NAME DROP VARIABLE
SHVNEXTV EQU   C'N'  FETCH "NEXT" VARIABLE
SHVPRIV  EQU   C'P'  FETCH PRIVATE INFORMATION
         SPACE
*
*     RETURN CODE FLAGS (STORED IN SHVRET):
*
SHVCLEAN EQU   X'00' EXECUTION WAS OK
SHVNEWV  EQU   X'01' VARIABLE DID NOT EXIST
SHVLVAR  EQU   X'02' LAST VARIABLE TRANSFERRED (FOR "N")
SHVTRUNC EQU   X'04' TRUNCATION OCCURRED DURING "FETCH"
SHVBADN  EQU   X'08' INVALID VARIABLE NAME
SHVBADV  EQU   X'10' VALUE TOO LONG
SHVBADF  EQU   X'80' INVALID FUNCTION CODE (SHVCODE)
* =====================================================================
* OTHER DUMMY SECTIONS
* =====================================================================
         YREGS    ,
         END   IRXEXCOM
