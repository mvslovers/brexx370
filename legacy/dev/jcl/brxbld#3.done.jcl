//BRXBLD#3 JOB (BREXX),                                                 00000108
//            'BREXX BUILD STEP#3',                                     00000208
//            CLASS=A,                                                  00000305
//            MSGCLASS=H,                                               00000405
//            REGION=8M,                                                00000505
//            MSGLEVEL=(1,1)                                            00000605
//********************************************************************  00000705
//*                                                                     00000805
//* BUILDING BREXX VSAMIO ROUTINE - RXVSAMIO                            00000905
//*                                                                     00001005
//********************************************************************  00001105
//*                                                                     00001200
//ASM1     EXEC PROC=ASMFCL,                                            00001304
//         MAC='SYS2.MACLIB',                                           00001401
//         MAC1='BRXBLD.ASM.MACLIB',                                    00001505
//         MAC2='BRXBLD.ASM.SRC',                                       00001605
//         SOUT=H                                                       00001701
//ASM.SYSIN    DD DISP=SHR,DSN=BRXBLD.ASM.SRC(RXVSMIO1)                 00001805
//LKED.SYSLMOD DD DISP=SHR,DSN=BRXBLD.LOADLIB(IRXVSMIO)                 00001907
//ASM2     EXEC PROC=ASMFCL,                                            00002004
//         MAC='SYS2.MACLIB',                                           00002104
//         MAC1='BRXBLD.ASM.MACLIB',                                    00002205
//         MAC2='BRXBLD.ASM.SRC',                                       00002305
//         SOUT=H                                                       00002404
//ASM.SYSIN    DD DISP=SHR,DSN=BRXBLD.ASM.SRC(RXVSMIO2)                 00002505
//LKED.SYSLMOD DD DISP=SHR,DSN=BRXBLD.LOADLIB(IRXVSMTR)                 00002607
