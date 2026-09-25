//BRXBLD#2 JOB (BREXX),
//            'BREXX BUILD STEP#2',
//            CLASS=A,
//            MSGCLASS=H,
//            REGION=8M,
//            MSGLEVEL=(1,1)
//********************************************************************
//*
//* BUILDING BREXX VTOC ACCESS ROUTINE - RXVTOC
//*
//********************************************************************
//* -------------------------------------------------------
//*    ASSEMBLE PROCEDURE
//* -------------------------------------------------------
//ASM      PROC MEM=$$$$$$$$$
//ASMVTOC  EXEC  PGM=IFOX00,REGION=1000K,PARM='TEST,RENT,NOOBJ,DECK'
//SYSLIB   DD  DSN=BRXBLD.ASM.SRC,DISP=SHR,DCB=BLKSIZE=32720
//         DD  DSN=SYS1.MACLIB,DISP=SHR,DCB=BLKSIZE=32720
//         DD  DSN=SYS1.AMODGEN,DISP=SHR
//         DD  DSN=BRXBLD.ASM.MACLIB,DISP=SHR
//SYSUT1   DD  DSN=&&SYSUT1,UNIT=VIO,SPACE=(1700,(600,100))
//SYSUT2   DD  DSN=&&SYSUT2,UNIT=VIO,SPACE=(1700,(300,50))
//SYSUT3   DD  DSN=&&SYSUT3,UNIT=VIO,SPACE=(1700,(300,50))
//SYSPUNCH DD  DISP=(OLD,PASS),DSN=&&OBJECT(&MEM)
//SYSPRINT DD  SYSOUT=*
//SYSIN    DD DSN=BRXBLD.ASM.SRC(&MEM),DISP=SHR
//         PEND
//* -------------------------------------------------------
//*     CREATE OBJECT DSN
//* -------------------------------------------------------
//ALLOC   EXEC PGM=IEFBR14
//SYSLIN   DD  DISP=(,PASS),DSN=&&OBJECT,
//             DCB=(BLKSIZE=400,LRECL=80,RECFM=FB),
//             SPACE=(CYL,(1,1,8),RLSE),UNIT=SYSDA
//* -------------------------------------------------------
//*     ASSEMBLE ALL MODULES
//* -------------------------------------------------------
//ASM0     EXEC ASM,MEM=VTOC370
//ASM1     EXEC ASM,MEM=VTOCCHEK
//ASM2     EXEC ASM,MEM=VTOCEXCP
//ASM3     EXEC ASM,MEM=VTOCFORM
//ASM4     EXEC ASM,MEM=VTOCMAP
//ASM5     EXEC ASM,MEM=VTOCMSGS
//ASM6     EXEC ASM,MEM=VTOCPRNT
//ASM7     EXEC ASM,MEM=VTOCSORT
//* -------------------------------------------------------
//*     LINKEDIT VTOC COMMAND
//* -------------------------------------------------------
//VTOCLINK EXEC PGM=IEWL,REGION=1000K,
//            PARM='RENT,REUS,REFR,LIST,XREF,SIZE=(512K,96K)'
//OBJ      DD DISP=(OLD,PASS),DSN=&&OBJECT
//SYSLMOD  DD DISP=SHR,DSN=BRXBLD.LOADLIB
//SYSUT1   DD UNIT=SYSDA,SPACE=(TRK,(10,10))
//SYSPRINT DD SYSOUT=*
//SYSLIN   DD  *
 INCLUDE OBJ(VTOC370)
 INCLUDE OBJ(VTOCCHEK)
 INCLUDE OBJ(VTOCEXCP)
 INCLUDE OBJ(VTOCFORM)
 INCLUDE OBJ(VTOCMAP)
 INCLUDE OBJ(VTOCMSGS)
 INCLUDE OBJ(VTOCPRNT)
 INCLUDE OBJ(VTOCSORT)
 ENTRY VTOCCMD
 NAME IRXVTOC(R)
//
