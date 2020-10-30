#!/bin/bash

USER="HERC01"
PASS="CUL8TR"
CLASS="A"

if [ $# = 2 ]; then
    USER=$2
fi

if [ $# = 3 ]; then
    USER=$2
    PASS=$3    
fi

if [ $# = 4 ]; then
    USER=$2
    PASS=$3    
    CLASS=$4
fi

cat <<END_JOBCARD
//BRXLINK  JOB CLASS=A,MSGCLASS=$CLASS,MSGLEVEL=(1,1),
//         USER=$USER,PASSWORD=$PASS
//*********************************************************************
//* BREXX V7R3M0 LINK JOB                                             *
//*********************************************************************
//*
END_JOBCARD

cat << END_LINKSTEP
//BRXLNK   EXEC PGM=IEWL,
//         PARM='AC=1,NCAL,MAP,LIST,XREF,NORENT,SIZE=(999424,65536)'
//SYSUT1   DD UNIT=SYSDA,SPACE=(CYL,(5,2))
//SYSPRINT DD SYSOUT=*
//SYSLIN   DD DATA,DLM=\$\$
::E $1
\$\$
//SYSLMOD  DD DSN=SYS2.LINKLIB(BREXX),DISP=SHR
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
 INCLUDE SYSLMOD(BREXX)
 ALIAS RX1
 ALIAS RX2
 NAME BREXX(R)
/*
//* ------------------------------------------------------------------
//* Rename Fake Aliases into real Aliases
//* ------------------------------------------------------------------
//ALIASES  EXEC PGM=IKJEFT01,REGION=8192K
//SYSTSPRT DD   SYSOUT=*
//SYSTSIN  DD   *
  DELETE 'SYS2.LINKLIB(REXX)'
  DELETE 'SYS2.LINKLIB(RX)'
  RENAME 'SYS2.LINKLIB(RX1)' 'SYS2.LINKLIB(REXX)'
  RENAME 'SYS2.LINKLIB(RX2)' 'SYS2.LINKLIB(RX)'
/*
//
END_LINKSTEP
