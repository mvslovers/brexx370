//BRXBLD#7 JOB (BREXX),
//            'BREXX BUILD STEP#7',
//            CLASS=A,
//            MSGCLASS=H,
//            REGION=8M,
//            NOTIFY=&SYSUID,
//            MSGLEVEL=(1,1)
//********************************************************************
//*
//* BUILDING BREXX PDSSTAT SUPPORT ROUTINE - RXPDSTAT
//*
//********************************************************************
//*
//ASM      EXEC PROC=ASMFCL,
//         MAC='SYS1.MACLIB',
//         MAC1='BRXBLD.ASM.MACLIB',
//         SOUT=H
//ASM.SYSIN    DD DISP=SHR,DSN=BRXBLD.ASM.SRC(RXPDSTAT)
//*LKED.SYSLMOD DD DISP=SHR,DSN=BRXBLD.LOADLIB(IRXISTAT)
//LKED.SYSLMOD DD DISP=SHR,DSN=SYS2.LINKLIB(IRXISTAT)
//
