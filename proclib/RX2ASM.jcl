//RX2ASM   PROC SLIB=,           //* SOURCE LIBRARY OF RX MEMBER        00000100
//         REXX=,                //* REXX TO COMPILE                    00000200
//         LIB='BREXX.RXLIB',    //* RXLIB                              00000300
//         MODE=1,               //* COMPILE MODE                       00000400
//         LLIB=                 //* LINK INTO LIBRARY                  00000500
//* --------------------------------------------------------            00000600
//* GENERATE ASSEMBLER PROGRAM                                          00000700
//* --------------------------------------------------------            00000800
//EXEC   EXEC PGM=BREXX,PARM='RXRUN &SLIB(&REXX),MODE=&MODE',           00000900
//         REGION=8192K                                                 00001000
//RXRUN    DD DSN=&LIB(RX2ASM),DISP=SHR                                 00001100
//RXLIB    DD DSN=&LIB,DISP=SHR                                         00001200
//STDIN    DD DUMMY                                                     00001300
//STDOUT   DD SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)            00001400
//STDERR   DD SYSOUT=*,DCB=(RECFM=FB,LRECL=140,BLKSIZE=5600)            00001500
//RXOUT    DD DSN=&&RXASM,DISP=(NEW,PASS),UNIT=SYSDA,                   00001600
//            SPACE=(TRK,(10,19)),                                      00001700
//            DCB=(RECFM=FB,LRECL=80,BLKSIZE=6400)                      00001800
//RXLNK    DD DSN=&&RXLNK,DISP=(NEW,PASS),UNIT=SYSDA,                   00001900
//            SPACE=(TRK,(1,1)),                                        00002000
//            DCB=(RECFM=FB,LRECL=80,BLKSIZE=6400)                      00002100
//* --------------------------------------------------------            00002200
//* ASSEMBLY OF GENERATED PROGRAM                                       00002300
//* --------------------------------------------------------            00002400
//ASM    EXEC PGM=IFOX00,PARM=(OBJ,NORENT),REGION=128K                  00002500
//SYSIN    DD DISP=SHR,DSN=&&RXASM                                      00002600
//SYSLIB   DD DSN=SYS1.MACLIB,DISP=SHR                                  00002700
//         DD DSN=SYS2.MACLIB,DISP=SHR                                  00002800
//         DD DSN=BREXX.RUNTIME.MACLIB,DISP=SHR                         00002900
//SYSUT1   DD DSN=&&SYSUT1,UNIT=SYSSQ,SPACE=(1700,(600,100)),           00003000
//            SEP=(SYSLIB)                                              00003100
//SYSUT2   DD DSN=&&SYSUT2,UNIT=SYSSQ,SPACE=(1700,(300,50)),            00003200
//            SEP=(SYSLIB,SYSUT1)                                       00003300
//SYSUT3   DD DSN=&&SYSUT3,UNIT=SYSSQ,SPACE=(1700,(300,50))             00003400
//SYSPRINT DD SYSOUT=H,DCB=BLKSIZE=1089                                 00003500
//SYSPUNCH DD SYSOUT=B                                                  00003600
//SYSGO    DD DSN=&&OBJSET,UNIT=SYSSQ,SPACE=(80,(200,50)),              00003700
//            DISP=(MOD,PASS)                                           00003800
//* --------------------------------------------------------            00003900
//* LINKAGE OF GENERATED PROGRAM                                        00004000
//* --------------------------------------------------------            00004100
//LKED   EXEC PGM=IEWL,REGION=128K,COND=(8,LT,ASM),                     00004200
//            PARM='AC=0,XREF,LIST,CALL,NORENT,SIZE=(999424,65536)'     00004300
//SYSLIB   DD DISP=SHR,DSN=SYS2.LINKLIB                                 00004400
//SYSLIN   DD DSN=&&OBJSET,DISP=(OLD,DELETE)                            00004500
//         DD DDNAME=SYSIN                                              00004600
//SYSIN    DD DSN=&&RXLNK,DISP=(OLD,DELETE)                             00004700
//SYSPRINT DD SYSOUT=H,DCB=BLKSIZE=1089                                 00004800
//SYSUT1   DD DSN=&&SYSUT1,UNIT=(SYSDA,SEP=(SYSLIN,SYSLMOD)),           00004900
//            SPACE=(1024,(50,20))                                      00005000
//SYSLMOD  DD DSN=&LLIB(&REXX),DISP=SHR                                 00005100
//* PEND                                                                00005200
