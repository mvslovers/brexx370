RXESTAE   TITLE 'BREXX/370 ESATE IMPLEMENTATION'                        00000100
* --------------------------------------------------------------------- 00000200
*   AUTHOR     : MIKE GROSSMANN (MIG)                                   00000300
*   CREATED    : 20.07.2021  MIG                                        00000400
* --------------------------------------------------------------------- 00000500
         PRINT   GEN                                                    00000600
RXESTAE  CSECT                                                          00000700
         DS    0H                                                       00000800
         EJECT                                                          00000900
         ENTRY RXSETJMP                                                 00001000
* --------------------------------------------------------------------- 00001100
* RXSETJMP    Entry Point                                               00001200
* C call:                                                               00001300
*    int _setjmp_estae (jmp_buf jbs, char * sdwa512);                   00001400
* where:                                                                00001500
*    jbs       stores program state information.                        00001600
*    sdwa512   sdwa returned on abend                                   00001700
* returns:                                                              00001800
*    (int)     0 if estae was installed                                 00001900
*    (int)     1 if abend occured                                       00002000
* --------------------------------------------------------------------- 00002100
RXSETJMP DS    0H                                                       00002200
*                                                                       00002300
         ST    R14,12(R13)    SAVE THE RETURN ADDRESS                   00002400
         L     R15,0(R1)      GET 1ST PARAMETER - JMPBUF                00002500
         STM   R1,R14,0(R15)  SAVE REGISTER TO JMPBUF                   00002600
*                                                                       00002700
         BALR  R12,0          ESTABLISH ADDRESSABILITY                  00002800
         USING *,R12                                                    00002900
*                                                                       00003000
         LR    R2,R1          BACKUP R1                                 00003100
         LR    R5,R15         BACKUP R15                                00003200
*                                                                       00003300
         GETMAIN R,LV=WORKL   GET STORAGE FOR WORK AREA                 00003400
         LR    R6,R1          SAVE GETMAIN POINTER                      00003500
         USING WORK,R6        R6 IS POINTING NOW TO OUR WORK AREA       00003600
*                                                                       00003700
         ST    R5,JMPBUF      SAVE JMPBUF INTO OUR WORK AREA            00003800
         L     R5,4(R2)       GET 2ND PARAMETER - SDWABUF               00003900
         ST    R5,SDWABUF     SAVE SDWABUF INTo OUR WORK AREA           00004000
*                                                                       00004100
         MVC   PARMLIST(ESTAEL),ESTAE   MOVE ESTAE PARM LIST            00004200
         L     R7,=A(RECOVERY) GET ADDRESS OF THE RECOVERY ROUTINE      00004300
         ESTAE (R7),          ISSUE ESTAE                              x00004400
               CT,                                                     x00004500
               TERM=YES,                                               x00004600
               PARAM=(R6),    PARAM POINTS TO OUR WORK AREA            x00004700
               MF=(E,PARMLIST)                                          00004800
*                                                                       00004900
         L     R15,JMPBUF                                               00005000
         LM    R1,R14,0(R15)                                            00005100
         SR    R15,R15        RETURN RC=0                               00005200
         L     R14,12(R13)    RESTORE RETURN ADDRESS                    00005300
         BR    R14            RETURN TO CALLER                          00005400
* --------------------------------------------------------------------- 00005500
* THE RECOVERY ROUTINE                                                  00005600
* --------------------------------------------------------------------- 00005700
RECOVERY DS    0H                                                       00005800
*                                                                       00005900
         LR    R12,R15        SET UP BASE REG                           00006000
         USING RECOVERY,R12   ESTABLISH ADDRESSABILITY                  00006100
*                                                                       00006200
         SETRP RC=4,          CALL OUR RETRY ROUTINE                   X00006300
               RETADDR=RETRY, ADDRESS OF OUR RETRY ROUTINE             X00006400
               DUMP=NO        DO NOT DO ANY FURTHER DUMP                00006500
*                                                                       00006600
         LA    R15,0          RETURN RC=0                               00006700
*                                                                       00006800
         BR    R14                                                      00006900
*                                                                       00007000
* --------------------------------------------------------------------- 00007100
* THE RETRY ROUTINE - PASS CONTROL BACK TO C                            00007200
* --------------------------------------------------------------------- 00007300
RETRY    DS    0H                                                       00007400
*                                                                       00007500
         LR    R12,R15        SET UP BASE REG                           00007600
         USING RETRY,R12      ESTABLISH ADDRESSABILITY                  00007700
*                                                                       00007800
         LTR   R1,R1          CHECK FOR SDWA                            00007900
         BZ    BACK2C         SKIP SDWA COPY                            00008000
*                                                                       00008100
         L     R6,0(,R1)      GET ADDRESS OF PASSED WORK AREA           00008200
         USING WORK,R6                                                  00008300
*                                                                       00008400
         L     R4,SDWABUF     GET TARGET FOR SDWA COPY                  00008500
         LA    R5,512         SET SDWA LENGTH                           00008600
         LR    R2,R1          GET SOURCE FOR SDWA COPY                  00008700
         LR    R3,R5          ...                                       00008800
         MVCL  R4,R2          COPY SDWA                                 00008900
*                                                                       00009000
         ESTAE 0                                                        00009100
         FREEMAIN R,LV=SDWALEN,A=(1)                                    00009200
*                                                                       00009300
         L     R15,JMPBUF                                               00009400
         LM    R1,R14,0(R15)                                            00009500
*                                                                       00009600
         LA    R15,1                                                    00009700
BACK2C   EQU *                                                          00009800
         BR    R14                                                      00009900
*                                                                       00010000
         LTORG                                                          00010100
ESTAE    ESTAE 0,MF=L                                                   00010200
ESTAEL   EQU   *-ESTAE                                                  00010300
*                                                                       00010400
WORK     DSECT                                                          00010500
JMPBUF   DS    A                                                        00010600
SDWABUF  DS    A                                                        00010700
PARMLIST DS    16F                                                      00010800
         DS    0D                                                       00010900
WORKL    EQU   *-WORK                                                   00011000
*                                                                       00011100
         YREGS                                                          00011200
         IHASDWA                                                        00011300
         END RXESTAE                                                    00011400
