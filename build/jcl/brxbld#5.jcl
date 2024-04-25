//BRXBLD#5 JOB (BREXX),
//            'BREXX BUILD STEP#5',
//            CLASS=A,
//            MSGCLASS=H,
//            REGION=8M,
//            MSGLEVEL=(1,1)
//********************************************************************
//*
//* BUILDING BREXX NJE38 SUPPORT ROUTINE - RXNJE38
//*
//********************************************************************
//*
//ASM      EXEC PROC=ASMFCL,
//         MAC='SYS1.MACLIB',
//         MAC1='BRXBLD.ASM.MACLIB',
//         MAC2='SYS2.NJE38.MACLIB',
//         SOUT=H
//ASM.SYSIN    DD DISP=SHR,DSN=BRXBLD.ASM.SRC(RXNJE38)
//LKED.SYSLMOD DD DISP=SHR,DSN=BRXBLD.LOADLIB(IRXNJE38)
//LKED.SYSLIB1 DD DISP=SHR,DSN=SYS2.LINKLIB
//LKED.SYSLIB2 DD DISP=SHR,DSN=SYS2.NJE38.AUTHLIB
//LKED.SYSIN DD *
  INCLUDE SYSLIB2(NJESPOOL)
/*
//
