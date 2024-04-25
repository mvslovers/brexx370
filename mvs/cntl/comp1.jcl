//BREXXC   JOB (JCC),
//            'Compile BREXX',
//            CLASS=A,
//            MSGCLASS=H,
//            REGION=8M,
//            MSGLEVEL=(1,1),
//            NOTIFY=&SYSUID
//********************************************************************
//*
//* Name: BREXX.CNTL(COMP1)
//*
//* Desc: Compile a single source file (none reentrant version)
//*
//********************************************************************
//*
//JCCC    EXEC JCCC,INFILE='BREXX.SRC(BINTREE)',
//        JOPTS='-o -fstk -D__MVS__ -list=//DDN:SYSPRINT'
//COMPILE.JCCINCS  DD DISP=SHR,DSN=BREXX.INC
//COMPILE.JCCOASM  DD DISP=SHR,DSN=BREXX.OBJ(BINTREE)
//COMPILE.SYSPRINT DD SYSOUT=*
//COMPILE.LOCK     DD DSN=BREXX.LOCK,DISP=OLD
//
