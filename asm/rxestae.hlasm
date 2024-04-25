RXESTAE   TITLE 'BREXX/370 ESATE IMPLEMENTATION'                        00000100
* --------------------------------------------------------------------- 00000200
*   AUTHOR     : MIKE GROSSMANN (MIG)                                   00000300
*   CREATED    : 20.07.2021  MIG                                        00000400
* --------------------------------------------------------------------- 00000500
         PRINT   GEN                                                    00000600
RXESTAE  CSECT                                                          00000700
         DS    0H                                                       00000800
         EJECT                                                          00000900
         ENTRY RXECANC                                                  00001000
* --------------------------------------------------------------------- 00001100
* RXECANC     Entry Point                                               00001200
* C call:                                                               00001300
*    int _setjmp_ecanc (void);                                          00001400
* --------------------------------------------------------------------- 00001500
RXECANC  DS    0H                                                       00001600
*                                                                       00001700
         ESTAE 0                                                        00001800
*                                                                       00001900
         BR    R14                                                      00002000
*                                                                       00002100
         ENTRY RXSETJMP                                                 00002200
* --------------------------------------------------------------------- 00002300
* RXSETJMP    Entry Point                                               00002400
* C call:                                                               00002500
*    int _setjmp_estae (jmp_buf jbs, char * sdwa512);                   00002600
* where:                                                                00002700
*    jbs       stores program state information.                        00002800
*    sdwa512   sdwa returned on abend                                   00002900
* returns:                                                              00003000
*    (int)     0 if estae was installed                                 00003100
*    (int)     1 if abend occured                                       00003200
* --------------------------------------------------------------------- 00003300
RXSETJMP DS    0H                                                       00003400
*                                                                       00003500
         ST    R14,12(R13)    SAVE THE RETURN ADDRESS                   00003600
         L     R15,0(R1)      GET 1ST PARAMETER - JMPBUF                00003700
         STM   R1,R14,0(R15)  SAVE REGISTER TO JMPBUF                   00003800
*                                                                       00003900
         BALR  R12,0          ESTABLISH ADDRESSABILITY                  00004000
         USING *,R12                                                    00004100
*                                                                       00004200
         LR    R2,R1          BACKUP R1                                 00004300
         LR    R5,R15         BACKUP R15                                00004400
*                                                                       00004500
         GETMAIN R,LV=WORKL   GET STORAGE FOR WORK AREA                 00004600
         LR    R6,R1          SAVE GETMAIN POINTER                      00004700
         USING WORK,R6        R6 IS POINTING NOW TO OUR WORK AREA       00004800
*                                                                       00004900
         ST    R5,JMPBUF      SAVE JMPBUF INTO OUR WORK AREA            00005000
         L     R5,4(R2)       GET 2ND PARAMETER - SDWABUF               00005100
         ST    R5,SDWABUF     SAVE SDWABUF INTo OUR WORK AREA           00005200
*                                                                       00005300
         MVC   PARMLIST(ESTAEL),ESTAE   MOVE ESTAE PARM LIST            00005400
         L     R7,=A(RECOVERY) GET ADDRESS OF THE RECOVERY ROUTINE      00005500
         ESTAE (R7),          ISSUE ESTAE                              x00005600
               CT,                                                     x00005700
               TERM=YES,                                               x00005800
               PARAM=(R6),    PARAM POINTS TO OUR WORK AREA            x00005900
               MF=(E,PARMLIST)                                          00006000
*                                                                       00006100
         L     R15,JMPBUF                                               00006200
         LM    R1,R14,0(R15)                                            00006300
         SR    R15,R15        RETURN RC=0                               00006400
         L     R14,12(R13)    RESTORE RETURN ADDRESS                    00006500
         BR    R14            RETURN TO CALLER                          00006600
* --------------------------------------------------------------------- 00006700
* THE RECOVERY ROUTINE                                                  00006800
* --------------------------------------------------------------------- 00006900
RECOVERY DS    0H                                                       00007000
*                                                                       00007100
         LR    R12,R15        SET UP BASE REG                           00007200
         USING RECOVERY,R12   ESTABLISH ADDRESSABILITY                  00007300
*                                                                       00007400
         SETRP RC=4,          CALL OUR RETRY ROUTINE                   X00007500
               RETADDR=RETRY, ADDRESS OF OUR RETRY ROUTINE             X00007600
               DUMP=NO        DO NOT DO ANY FURTHER DUMP                00007700
*                                                                       00007800
         LA    R15,0          RETURN RC=0                               00007900
*                                                                       00008000
         BR    R14                                                      00008100
*                                                                       00008200
* --------------------------------------------------------------------- 00008300
* THE RETRY ROUTINE - PASS CONTROL BACK TO C                            00008400
* --------------------------------------------------------------------- 00008500
RETRY    DS    0H                                                       00008600
*                                                                       00008700
         LR    R12,R15        SET UP BASE REG                           00008800
         USING RETRY,R12      ESTABLISH ADDRESSABILITY                  00008900
*                                                                       00009000
         LTR   R1,R1          CHECK FOR SDWA                            00009100
         BZ    BACK2C         SKIP SDWA COPY                            00009200
*                                                                       00009300
         L     R6,0(,R1)      GET ADDRESS OF PASSED WORK AREA           00009400
         USING WORK,R6                                                  00009500
*                                                                       00009600
         L     R4,SDWABUF     GET TARGET FOR SDWA COPY                  00009700
         LA    R5,512         SET SDWA LENGTH                           00009800
         LR    R2,R1          GET SOURCE FOR SDWA COPY                  00009900
         LR    R3,R5          ...                                       00010000
         MVCL  R4,R2          COPY SDWA                                 00010100
*                                                                       00010200
         ESTAE 0                                                        00010300
         FREEMAIN R,LV=SDWALEN,A=(1)                                    00010400
*                                                                       00010500
         L     R15,JMPBUF                                               00010600
         LM    R1,R14,0(R15)                                            00010700
*                                                                       00010800
         LA    R15,1                                                    00010900
BACK2C   EQU *                                                          00011000
         BR    R14                                                      00011100
*                                                                       00011200
         LTORG                                                          00011300
ESTAE    ESTAE 0,MF=L                                                   00011400
ESTAEL   EQU   *-ESTAE                                                  00011500
*                                                                       00011600
WORK     DSECT                                                          00011700
JMPBUF   DS    A                                                        00011800
SDWABUF  DS    A                                                        00011900
PARMLIST DS    16F                                                      00012000
         DS    0D                                                       00012100
WORKL    EQU   *-WORK                                                   00012200
*                                                                       00012300
         YREGS                                                          00012400
         IHASDWA                                                        00012500
         END RXESTAE                                                    00012600
