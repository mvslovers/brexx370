#!/bin/bash

# Dual mode: clean and Upload/Assemble/Link

CLASS="A"


if [ $1 = "clean" ]; then

if [ $# = 2 ]; then
    CLASS=$2
fi

cat << JCLCLEAN
//BRCLEAN1 JOB CLASS=A,MSGCLASS=$CLASS,MSGLEVEL=(1,1),
//         USER=HERC01,PASSWORD=CUL8TR
//*********************************************************************
//* DELETE PRIOR VERSIONS OF SOURCE AND OBJECT DATASETS               *
//*********************************************************************
//*
//BRDELETE EXEC PGM=IDCAMS,REGION=1024K
//SYSPRINT DD  SYSOUT=A
//SYSIN    DD  *
    DELETE BREXX.ASM NONVSAM SCRATCH PURGE
    DELETE BREXX.LINKLIB NONVSAM SCRATCH PURGE
    DELETE BREXX.MACLIB NONVSAM SCRATCH PURGE
    DELETE BREXX.RXMVSEXT NONVSAM SCRATCH PURGE
    DELETE BREXX.OBJ NONVSAM SCRATCH PURGE
 /* IF THERE WAS NO DATASET TO DELETE, RESET CC           */
 IF LASTCC = 8 THEN
   DO
       SET LASTCC = 0
       SET MAXCC = 0
   END
/*
//* ------------------------------------------------------------------
//* Delete sys2.linklib members
//* ------------------------------------------------------------------
//BRDLINKL EXEC PGM=IKJEFT01,REGION=8192K
//SYSTSPRT DD   SYSOUT=*
//SYSTSIN  DD   *
  DELETE 'SYS2.LINKLIB(BREXX)'
  DELETE 'SYS2.LINKLIB(BREXXSTD)'
  DELETE 'SYS2.LINKLIB(REXX)'
  DELETE 'SYS2.LINKLIB(RX)'
  COMPRESS 'SYS2.LINKLIB'
/*
JCLCLEAN
exit
fi

if [ $# = 4 ]; then
    CLASS=$4
fi

cat <<END_HEREDOC
//BRUPASLN JOB CLASS=A,MSGCLASS=$CLASS,MSGLEVEL=(1,1),
//         USER=HERC01,PASSWORD=CUL8TR
//*********************************************************************
//* DELETE PRIOR VERSIONS OF SOURCE AND OBJECT DATASETS               *
//*********************************************************************
//*
//BRDELETE EXEC PGM=IDCAMS,REGION=1024K
//SYSPRINT DD  SYSOUT=A
//SYSIN    DD  *
    DELETE BREXX.ASM NONVSAM SCRATCH PURGE
    DELETE BREXX.LINKLIB NONVSAM SCRATCH PURGE
    DELETE BREXX.MACLIB NONVSAM SCRATCH PURGE
    DELETE BREXX.RXMVSEXT NONVSAM SCRATCH PURGE
    DELETE BREXX.OBJ NONVSAM SCRATCH PURGE
 /* IF THERE WAS NO DATASET TO DELETE, RESET CC           */
 IF LASTCC = 8 THEN
   DO
       SET LASTCC = 0
       SET MAXCC = 0
   END
/*
//*********************************************************************
//* CREATE THE ASM AND BIN PDS                                      *
//*********************************************************************
//*
//BRCREATE EXEC PGM=IEFBR14
//DDASM    DD  DSN=BREXX.ASM,DISP=(,CATLG,DELETE),
//             UNIT=3380,VOL=SER=PUB012,SPACE=(TRK,(20,,2)),
//             DCB=(RECFM=FB,LRECL=80,BLKSIZE=800)
//DDBIN    DD  DSN=BREXX.LINKLIB,DISP=(,CATLG,DELETE),
//             UNIT=3380,VOL=SER=PUB012,
//             SPACE=(CYL,(20,0,15)),
//             DCB=(RECFM=U,BLKSIZE=32760)
//MACIN    DD  DSN=BREXX.MACLIB,DISP=(,CATLG,DELETE),
//             UNIT=3380,VOL=SER=PUB012,SPACE=(TRK,(45,,8)),
//             DCB=(RECFM=FB,LRECL=80,BLKSIZE=800)
//ASMOUT   DD  DSN=BREXX.RXMVSEXT,DISP=(NEW,CATLG,CATLG),
//             SPACE=(TRK,3),UNIT=3380,VOL=SER=PUB012,
//             DCB=(RECFM=FB,LRECL=80,BLKSIZE=3200)
//OBJOUT   DD  DSN=BREXX.OBJ,DISP=(,CATLG,DELETE),
//             UNIT=3380,VOL=SER=PUB012,SPACE=(TRK,(34,,10)),
//             DCB=(RECFM=FB,LRECL=80,BLKSIZE=6160)
//*
//*********************************************************************
//* CREATE BREXX ASM/MACLIB PDS CONTENTS                              *
//*********************************************************************
//*
//* This is written in **rdrprep** syntax
//* It will only work with rdrprep
//* ::a path/file means 'include ascii version of file'
//*
//BRUPASM  EXEC PGM=IEBUPDTE,REGION=1024K,PARM=NEW
//SYSUT2   DD  DSN=BREXX.ASM,DISP=SHR
//SYSPRINT DD  SYSOUT=*
//SYSIN    DD  DATA,DLM='##'
END_HEREDOC

# the mvs/asm folder passed as an argument
for f in $1/*; do
	filename=$(basename -- "$f")
	filename="${filename%.*}"
	ASM=$(echo ${filename^^})
cat << EOF
./ ADD NAME=${ASM##*/},LIST=ALL
::a $f
EOF
done

cat <<'EOF'
##
/*
//BRUPMACL EXEC PGM=IEBUPDTE,REGION=1024K,PARM=NEW
//SYSUT2   DD  DSN=BREXX.MACLIB,DISP=SHR
//SYSPRINT DD  SYSOUT=*
//SYSIN    DD  DATA,DLM='##'
EOF

# the mvs/maclib folder passed as an argument
for f in $2/*; do
  filename=$(basename -- "$f")
  filename="${filename%.*}"
  ASM=$(echo ${filename^^})
cat << EOF
./ ADD NAME=${ASM##*/},LIST=ALL
::a $f
EOF
done

cat << JCLPROC
##
/*
//* PROC TO ADD A 4th MACLIB
//ASMFCX   PROC  MAC='SYS1.MACLIB',MAC1='SYS1.MACLIB',
//         MAC2='SYS1.MACLIB',MAC3='SYS1.MACLIB',
//         MAC4='SYS1.MACLIB',SOUT='*'
//ASM      EXEC  PGM=IFOX00,REGION=128K
//SYSLIB   DD    DSN=&MAC,DISP=SHR
//         DD    DSN=&MAC1,DISP=SHR
//         DD    DSN=&MAC2,DISP=SHR
//         DD    DSN=&MAC3,DISP=SHR
//         DD    DSN=&MAC4,DISP=SHR
//SYSUT1   DD    DSN=&&SYSUT1,UNIT=SYSSQ,SPACE=(1700,(600,100)),
//             SEP=(SYSLIB)
//SYSUT2   DD    DSN=&&SYSUT2,UNIT=SYSSQ,SPACE=(1700,(300,50)),
//             SEP=(SYSLIB,SYSUT1)
//SYSUT3   DD    DSN=&&SYSUT3,UNIT=SYSSQ,SPACE=(1700,(300,50))
//SYSPRINT DD    SYSOUT=&SOUT,DCB=BLKSIZE=1089
//SYSPUNCH DD    SYSOUT=B
// PEND
//*********************************************************************
//* ASSEMBLE THE COMPONENTS TO BREXX.RXMVSEXT                         *
//*********************************************************************
//*
JCLPROC

n=${1:-10}

for f in $1/*; do
  filename=$(basename -- "$f")
  filename="${filename%.*}"
  ASM=$(echo ${filename^^})
  STEPNAME=$(printf '%s%*s\n' "$ASM" "$((8-${#ASM}))" "";)

cat << JCLASMPROC
//$STEPNAME EXEC ASMFCX,PARM.ASM=(OBJ,NODECK),MAC='SYS2.MACLIB',
//         MAC1='SYS1.MACLIB',MAC2='SYS1.AMODGEN',
//         MAC3='SYS1.APVTMACS',MAC4='BREXX.MACLIB'
//ASM.SYSIN DD DSN=BREXX.ASM($ASM),DISP=SHR
//ASM.SYSGO DD DSN=BREXX.RXMVSEXT,DISP=(MOD,PASS)
JCLASMPROC
done

cat << JCLOBJSCAN
//BROBJSCN EXEC PGM=OBJSCAN,
//         PARM='//DDN:I //DDN:N //DDN:O'
//STEPLIB  DD DSN=JCC.LINKLIB,DISP=SHR
//STDOUT   DD SYSOUT=*
//I        DD DSN=BREXX.RXMVSEXT,DISP=(OLD,DELETE)
//O        DD DISP=(OLD,PASS),DSN=BREXX.OBJ(RXMVSEXT)
//N        DD *
RXDYNALC call_rxdynalc
RXIKJ441 call_rxikj441
RXPTIME call_rxptime
RXSTIME call_rxstime
RXABEND call_rxabend
RXINIT call_rxinit
RXTERM call_rxterm
RXVSAM call_rxvsam
RXWAIT call_rxwait
RXTSO call_rxtso
RXWTO call_rxwto
RXSVC call_rxsvc
RXCPUTIM cputime
RACAUTH rac_user_auth
/*
//*
//* merge RXMVS routine with JCC library
//*
//COPYOBJS EXEC PGM=IEBCOPY
//SYSUT1   DD  DISP=SHR,DSN=JCC.OBJ
//SYSUT2   DD  DISP=(OLD,PASS),DSN=BREXX.OBJ
//SYSPRINT DD  SYSOUT=*
//SYSIN    DD  DUMMY
//COPYINDX EXEC PGM=IEBGENER
//SYSUT1   DD  DISP=SHR,DSN=JCC.OBJ(LIBLST)
//         DD  *
rxmvsext
/*
//SYSUT2   DD DISP=SHR,DSN=BREXX.OBJ(LIBLST)
//SYSPRINT DD  SYSOUT=*
//SYSIN    DD  DUMMY
JCLOBJSCAN

cat << JCLLINKOBJ
//BRLNAUTH EXEC PGM=IEWL,
//         PARM='AC=1,NCAL,MAP,LIST,XREF,NORENT,SIZE=(999424,65536)'
//SYSUT1   DD UNIT=SYSDA,SPACE=(CYL,(5,2))
//SYSPRINT DD SYSOUT=*
//SYSLIN   DD DATA,DLM=\$\$
::E $3
\$\$
//SYSLMOD  DD DSN=SYS2.LINKLIB(BREXXSTD),DISP=SHR
//* Link Non Authorised
//BRLINK   EXEC PGM=IEWL,
//         PARM='NCAL,MAP,LIST,XREF,NORENT,SIZE=(999424,65536)'
//SYSUT1   DD UNIT=SYSDA,SPACE=(CYL,(5,2))
//SYSPRINT DD SYSOUT=*
//SYSLIN   DD DATA,DLM=\$\$
::E $3
\$\$
//SYSLMOD  DD DSN=BREXX.LINKLIB(BREXXSTD),DISP=SHR
//* -----------------------------------------------------------------
//* !!!!! APF Version
//* Link Aliases separately to avoid interference with BREXX LINK
//*      Use Fake Aliases as there are External names with the Aliases
//* ------------------------------------------------------------------
//LINKAUTH EXEC  PGM=IEWL,
//         PARM='AC=1,NCAL,MAP,LIST,XREF,NORENT,SIZE=(999424,65536)'
//SYSLMOD  DD  DSN=SYS2.LINKLIB,DISP=SHR
//SYSUT1   DD  UNIT=SYSDA,SPACE=(1024,(100,10))
//SYSPRINT DD  SYSOUT=*
//SYSLIN   DD  *
 INCLUDE SYSLMOD(BREXXSTD)
 ALIAS RX1
 ALIAS RX2
 ALIAS RX3
 NAME BREXXSTD(R)
/*
//* -----------------------------------------------------------------
//* !!!!! NON-APF Version
//* Link Aliases separately to avoid interference with BREXX LINK
//*      Use Fake Aliases as there are External names with the Aliases
//* ------------------------------------------------------------------
//LINK     EXEC  PGM=IEWL,
//         PARM='NCAL,MAP,LIST,XREF,NORENT,SIZE=(999424,65536)'
//SYSLMOD  DD  DSN=BREXX.LINKLIB,DISP=SHR
//SYSUT1   DD  UNIT=SYSDA,SPACE=(1024,(100,10))
//SYSPRINT DD  SYSOUT=*
//SYSLIN   DD  *
 INCLUDE SYSLMOD(BREXXSTD)
 ALIAS RX1
 ALIAS RX2
 ALIAS RX3
 NAME BREXXSTD(R)
/*
//* ------------------------------------------------------------------
//* Rename Fake Aliases into real Aliases
//* ------------------------------------------------------------------
//ALIASES  EXEC PGM=IKJEFT01,REGION=8192K
//SYSTSPRT DD   SYSOUT=*
//SYSTSIN  DD   *
  DELETE 'SYS2.LINKLIB(BREXX)'
  DELETE 'SYS2.LINKLIB(REXX)'
  DELETE 'SYS2.LINKLIB(RX)'
  RENAME 'SYS2.LINKLIB(RX1)' 'SYS2.LINKLIB(BREXX)'
  RENAME 'SYS2.LINKLIB(RX2)' 'SYS2.LINKLIB(REXX)'
  RENAME 'SYS2.LINKLIB(RX3)' 'SYS2.LINKLIB(RX)'
  COMPRESS 'SYS2.LINKLIB'
  DELETE 'BREXX.LINKLIB(BREXX)'
  DELETE 'BREXX.LINKLIB(REXX)'
  DELETE 'BREXX.LINKLIB(RX)'
  RENAME 'BREXX.LINKLIB(RX1)' 'BREXX.LINKLIB(BREXX)'
  RENAME 'BREXX.LINKLIB(RX2)' 'BREXX.LINKLIB(REXX)'
  RENAME 'BREXX.LINKLIB(RX3)' 'BREXX.LINKLIB(RX)'
  COMPRESS 'BREXX.LINKLIB'
/*
//
JCLLINKOBJ