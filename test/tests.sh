#!/bin/bash

# Test brexx install
# ./test.sh > tests.jcl;rdrprep tests.jcl;nc -w1 localhost 3505 < reader.jcl
USER="HERC01"
PASS="CUL8TR"
CLASS="A"
VERSION=$(grep "VERSION " ../inc/rexx.h|awk  '{gsub(/"/, "", $3); print $3}'|sed "s/[^[:alnum:]]//g" | tr a-z A-Z| cut -c 1-8)
#TESTS_DIR=../tests
#VERSION="V2R3M0"
TESTS_DIR=.

if [ $# = 1 ]; then
    USER=$1
fi

if [ $# = 2 ]; then
    USER=$1
    PASS=$2
fi

if [ $# = 3 ]; then
    USER=$1
    PASS=$2
    CLASS=$3
fi


cat <<END_JOBCARD
//BREXXTST JOB CLASS=A,MSGCLASS=$CLASS,MSGLEVEL=(1,1),
//         USER=$USER,PASSWORD=$PASS
//* ------------------------------------------------------------------
//* BREXX $VERSION INSTALL
//* ------------------------------------------------------------------
//*
END_JOBCARD

cat <<CLEAN_FIRST
//* ------------------------------------------------------------------
//* DELETE DATASETS IF ALREADY INSTALLED
//* ------------------------------------------------------------------
//*
//BRDELETE EXEC PGM=IDCAMS,REGION=1024K
//SYSPRINT DD  SYSOUT=A
//SYSIN    DD  *
    DELETE BREXX.$VERSION.TESTS NONVSAM SCRATCH PURGE
 /* IF THERE WAS NO DATASET TO DELETE, RESET CC           */
 IF LASTCC = 8 THEN
   DO
       SET LASTCC = 0
       SET MAXCC = 0
   END
/*
//*
//* ------------------------------------------------------------------
//* CREATE RTEST IN REXXLIB
//* ------------------------------------------------------------------
//*
//RTESTLIB EXEC PGM=IEBUPDTE,REGION=1024K,PARM=NEW
//SYSUT2   DD  DSN=BREXX.$VERSION.RXLIB,DISP=SHR
//SYSPRINT DD  SYSOUT=*
//SYSIN    DD  DATA,DLM='##'
./ ADD NAME=RTEST,LIST=ALL
::a rxtest.rxlib
##
/*
//*
//* ------------------------------------------------------------------
//* CREATE THE PDS
//* ------------------------------------------------------------------
//*
//BRCREATE EXEC PGM=IEFBR14
//DDJCL    DD  DSN=BREXX.$VERSION.TESTS,DISP=(,CATLG,DELETE),
//             UNIT=3380,VOL=SER=PUB012,SPACE=(TRK,(255,,10)),
//             DCB=(RECFM=FB,LRECL=80,BLKSIZE=800)
CLEAN_FIRST

cat << PDS_HEADER
//*
//* ------------------------------------------------------------------
//* ADD TESTS RELEASE $VERSION CONTENTS
//* ------------------------------------------------------------------
//*
//* This is written in **rdrprep** syntax
//* It will only work with rdrprep
//* ::a path/file means 'include ascii version of file'
//*
//BR$(echo TESTS |cut -c1-6) EXEC PGM=IEBUPDTE,REGION=1024K,PARM=NEW
//SYSUT2   DD  DSN=BREXX.$VERSION.TESTS,DISP=SHR
//SYSPRINT DD  SYSOUT=*
//SYSIN    DD  DATA,DLM='##'
PDS_HEADER
for s in $TESTS_DIR/*.rexx; do
    filename=$(basename -- "$s")
    extension="${filename##*.}"
    cat << EOF
./ ADD NAME=$(basename $s .$extension| tr '[a-z]' '[A-Z]'),LIST=ALL
::a $s
EOF
done
cat << TEST_JCL
##
//*
//* ------------------------------------------------------------------
//* TESTING BREXX VERSION $VERSION
//* ------------------------------------------------------------------
//*
TEST_JCL
for s in $TESTS_DIR/*.rexx; do
    filename=$(basename -- "$s")
    extension="${filename##*.}"
    f=$(basename $s .$extension| tr '[a-z]' '[A-Z]')
    printf "//%-8s EXEC RXBATCH,SLIB='BREXX.$VERSION.TESTS',EXEC=%s\\n" "$f" "$f"
done
cat <<END_CLEAN_LINKLIB_STEP
//* ------------------------------------------------------------------
//* DELETE BREXX.$VERSION.RXLIB(RTEST)
//* ------------------------------------------------------------------
//BRXDEL1  EXEC PGM=IKJEFT01,REGION=8192K
//SYSTSPRT DD   SYSOUT=*
//SYSTSIN  DD   *
  DELETE 'BREXX.$VERSION.RXLIB(RTEST)'
  COMPRESS 'BREXX.$VERSION.RXLIB'
/*
END_CLEAN_LINKLIB_STEP
