*                                                                       00010000
*   VTOC ERROR MESSAGE ROUTINE, R1 POINTS TO VTOC COMMON AT ENTRY       00020000
*                                                                       00030000
*         MODIFICATIONS                                                 00040002
* NUMBER    DATE    PERSON    REASON                                    00050002
*  001G    050284   GATES     RENAME VTOCOM MACRO TO VTCCOM,            00060002
*                              RENAME VTLEAVE MACRO TO VTCLEAVE,        00070002
*                               RENAME ENTER TO VTCENTER,               00080004
*                              VTOC MORE TRANSPORTABLE.                 00090002
*                                                                       00100002
VTOCMSG  VTCENTER 12,0        DO THE STANDARD HOUSEKEEPING         001G 00110003
         LR    R11,R1         GET THE PARM REGISTER                     00120000
         USING VTOCOM,R11     SET ADDRESSABILITY                        00130000
         SPACE                                                          00140000
         LM    R0,R1,MSGADDRS GET THE MESSAGE(S) TO SEND                00150000
         LTR   R0,R0          SECOND LEVEL MSG?                         00160000
         BZ    ERRORM1        NO                                        00170000
         SPACE                                                          00180000
         MVC   MSGTEXT1,0(R1) INSURE MSG IN WORK AREA                   00190000
         LA    R1,MSGTEXT1                                              00200000
         SPACE                                                          00210000
         LH    R14,0(R1)      LENGTH OF FIRST LEVEL MSG                 00220000
         LA    R15,0(R14,R1)  ADDR OF END OF MSG                        00230000
         LA    R14,1(R14)     JUMP MSG LENGTH                           00240000
         STH   R14,0(R1)                                                00250000
         MVI   0(R15),C'+'    INDICATE SECOND LEVEL MSG EXISTS          00260000
         SPACE 2                                                        00270000
         SR    R14,R14        CLEAR CHAIN FIELD                         00280000
         LA    R15,1          ONE SEGMENT IN 2ND MSG                    00290000
         STM   R14,R0,PUTOLD2 CREATE SECOND-LEVEL                       00300000
*                             OUTPUT LINE DESCRIPTOR ('OLD')            00310000
         LA    R0,PUTOLD2                                               00320000
         SPACE 3                                                        00330000
ERRORM1  LR    R14,R0         NEXT 'OLD' ADDR OR ZERO                   00340000
         LA    R15,1          ONE SEGMENT                               00350000
         LR    R0,R1          MSG ADDR                                  00360000
         STM   R14,R0,PUTOLD1 FIRST LEVEL 'OLD'                         00370000
         SPACE                                                          00380000
         LA    R1,PARMLIST                                              00390000
         USING IOPL,R1                                                  00400000
         SPACE                                                          00410000
         MVC   IOPLECT,ADDRECT                                          00420000
         MVC   IOPLUPT,ADDRUPT                                          00430000
         SPACE                                                          00440000
         LA    R0,ATTNECB                                               00450000
         ST    R0,IOPLECB                                               00460000
         MVI   ATTNECB,0                                                00470000
         SPACE 3                                                        00480000
         XC    PARMLIST+16(4),PARMLIST+16                               00490000
         PUTLINE PARM=PARMLIST+16,MF=(E,(1)),                          X00500000
               OUTPUT=(PUTOLD1,TERM,MULTLVL,INFOR)                      00510000
         SPACE 3                                                        00520000
         VTCLEAVE EQ                                               001G 00530002
         SPACE 3                                                        00540000
         IKJIOPL                                                        00550000
         SPACE 3                                                        00560000
         VTCCOM                                                    001G 00570002
         END                                                            00580000
