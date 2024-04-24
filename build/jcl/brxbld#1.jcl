//BRXBLD#1  JOB (BREXX),
//            'BREXX BUILD STEP#1',
//            CLASS=A,
//            MSGCLASS=H,
//            REGION=8M,
//            MSGLEVEL=(1,1)
//********************************************************************
//*
//* BUILDING BREXX INTERNAL ASSEMBLER MODULES
//*
//********************************************************************
//RXSVC    EXEC ASMFC,PARM.ASM=(OBJ,NODECK),MAC1='SYS2.MACLIB',
//         MAC2='SYS1.AMODGEN',MAC3='BRXBLD.ASM.MACLIB'
//ASM.SYSIN DD DSN=BRXBLD.ASM.SRC(RXSVC),DISP=SHR
//ASM.SYSGO DD DSN=&&OBJ,DISP=(,PASS),SPACE=(TRK,3),UNIT=VIO,
//          DCB=(RECFM=FB,LRECL=80,BLKSIZE=3200)
//********************************************************************
//RXABEND  EXEC ASMFC,PARM.ASM=(OBJ,NODECK),MAC1='SYS2.MACLIB',
//         MAC2='SYS1.AMODGEN',MAC3='BRXBLD.ASM.MACLIB'
//ASM.SYSIN DD DSN=BRXBLD.ASM.SRC(RXABEND),DISP=SHR
//ASM.SYSGO DD DSN=&&OBJ,DISP=(MOD,PASS)
//********************************************************************
//RXIKJ441 EXEC ASMFC,PARM.ASM=(OBJ,NODECK),MAC='SYS2.MACLIB',
//         MAC1='SYS1.MACLIB',MAC2='SYS1.AMODGEN',
//         MAC3='BRXBLD.ASM.MACLIB'
//ASM.SYSIN DD DSN=BRXBLD.ASM.SRC(RXIKJ441),DISP=SHR
//ASM.SYSGO DD DSN=&&OBJ,DISP=(MOD,PASS)
//********************************************************************
//RXINIT   EXEC ASMFC,PARM.ASM=(OBJ,NODECK)
//ASM.SYSLIB DD  DSN=SYS2.MACLIB,DISP=SHR
//         DD    DSN=SYS1.MACLIB,DISP=SHR
//         DD    DSN=SYS1.AMODGEN,DISP=SHR
//         DD    DSN=SYS1.APVTMACS,DISP=SHR
//         DD    DSN=BRXBLD.ASM.MACLIB,DISP=SHR
//ASM.SYSIN DD DSN=BRXBLD.ASM.SRC(RXINIT),DISP=SHR
//ASM.SYSGO DD DSN=&&OBJ,DISP=(MOD,PASS)
//********************************************************************
//RXTERM   EXEC ASMFC,PARM.ASM=(OBJ,NODECK),MAC='SYS2.MACLIB',
//         MAC1='SYS1.MACLIB',MAC2='SYS1.AMODGEN',
//         MAC3='BRXBLD.ASM.MACLIB'
//ASM.SYSIN DD DSN=BRXBLD.ASM.SRC(RXTERM),DISP=SHR
//ASM.SYSGO DD DSN=&&OBJ,DISP=(MOD,PASS)
//********************************************************************
//RXTSO    EXEC ASMFC,PARM.ASM=(OBJ,NODECK),MAC='SYS2.MACLIB',
//         MAC1='SYS1.MACLIB',MAC2='SYS1.AMODGEN',
//         MAC3='BRXBLD.ASM.MACLIB'
//ASM.SYSIN DD DSN=BRXBLD.ASM.SRC(RXTSO),DISP=SHR
//ASM.SYSGO DD DSN=&&OBJ,DISP=(MOD,PASS)
//********************************************************************
//RXVSAM   EXEC ASMFC,PARM.ASM=(OBJ,NODECK),MAC='SYS2.MACLIB',
//         MAC1='SYS1.MACLIB',MAC2='SYS1.AMODGEN',
//         MAC3='BRXBLD.ASM.MACLIB'
//ASM.SYSIN DD DSN=BRXBLD.ASM.SRC(RXVSAM),DISP=SHR
//ASM.SYSGO DD DSN=&&OBJ,DISP=(MOD,PASS)
//********************************************************************
//RXCPUTIM EXEC ASMFC,PARM.ASM=(OBJ,NODECK),MAC='SYS2.MACLIB',
//         MAC1='SYS1.MACLIB',MAC2='SYS1.AMODGEN',
//         MAC3='BRXBLD.ASM.MACLIB'
//ASM.SYSIN DD DSN=BRXBLD.ASM.SRC(RXCPUTIM),DISP=SHR
//ASM.SYSGO DD DSN=&&OBJ,DISP=(MOD,PASS)
//********************************************************************
//RXCPCMD  EXEC ASMFC,PARM.ASM=(OBJ,NODECK),MAC='SYS2.MACLIB',
//         MAC1='SYS1.MACLIB',MAC2='SYS1.AMODGEN',
//         MAC3='BRXBLD.ASM.MACLIB'
//ASM.SYSIN DD DSN=BRXBLD.ASM.SRC(RXCPCMD),DISP=SHR
//ASM.SYSGO DD DSN=&&OBJ,DISP=(MOD,PASS)
//********************************************************************
//RXESTAE  EXEC ASMFC,PARM.ASM=(OBJ,NODECK),MAC='SYS2.MACLIB',
//         MAC1='SYS1.MACLIB',MAC2='SYS1.AMODGEN',
//         MAC3='BRXBLD.ASM.MACLIB'
//ASM.SYSIN DD DSN=BRXBLD.ASM.SRC(RXESTAE),DISP=SHR
//ASM.SYSGO DD DSN=&&OBJ,DISP=(MOD,PASS)
//O         DD DISP=(OLD,PASS),DSN=BRXBLD.ASM.OBJ
//********************************************************************
//*
//* ESD to XSD conversion for long names
//*
//********************************************************************
//SCAN    EXEC PGM=OBJSCAN,
//        PARM='//DDN:I //DDN:N //DDN:O'
//STEPLIB   DD DSN=JCC.LINKLIB,DISP=SHR
//STDOUT    DD SYSOUT=*
//I         DD DSN=&&OBJ,DISP=(OLD,DELETE)
//O         DD DISP=(OLD,PASS),DSN=BRXBLD.ASM.OBJ(RXMVSEXT)
//N         DD *
RXIKJ441 call_rxikj441
RXABEND call_rxabend
RXINIT call_rxinit
RXTERM call_rxterm
RXVSAM call_rxvsam
RXTSO call_rxtso
RXSVC call_rxsvc
RXCPUTIM cputime
RXCPCMD systemCP
RXSETJMP _setjmp_estae
RXECANC _setjmp_ecanc
/*
