#!/bin/bash

USER="HERC01"
PASS="CUL8TR"
CLASS="A"
TYPE=""
XMI_DIR=../mvs/install
PDS="samples rxlib cmdlib"
RELEASE_PDS="jcl samples rxlib cmdlib install proclib"
VERSION=$(grep "VERSION " ../inc/rexx.h|awk  '{gsub(/"/, "", $3); print $3}')


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

if [ $# = 4 ]; then
    USER=$1
    PASS=$2
    CLASS=$3
    TYPE=$4
fi

cat <<END_JOBCARD
//BRXCLEAN JOB CLASS=A,MSGCLASS=$CLASS,MSGLEVEL=(1,1),
//         USER=$USER,PASSWORD=$PASS
//*********************************************************************
//* BREXX V7R3M0 CLEAN JOB                                            *
//*********************************************************************
//*
END_JOBCARD


cat <<END_CLEAN_LINKLIB_STEP
//* ------------------------------------------------------------------
//* DELETE SYS2.LINKLIB MEMBERS
//* ------------------------------------------------------------------
//BRXDEL1  EXEC PGM=IKJEFT01,REGION=8192K
//SYSTSPRT DD   SYSOUT=*
//SYSTSIN  DD   *
  DELETE 'SYS2.LINKLIB(RXMIG)'
  COMPRESS 'SYS2.LINKLIB'
/*
END_CLEAN_LINKLIB_STEP


if [ "${TYPE}" = "A" ] || [ "${TYPE}" == "asm" ]; then
cat << END_CLEAN_ASM_STEP
//BRXDEL2  EXEC PGM=IDCAMS,REGION=1024K
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
END_CLEAN_ASM_STEP
fi

if [ "${TYPE}" = "U" ] || [ "${TYPE}" == "uninstall" ] ; then

cat << REMOVE_PROCLIB_MEMBERS
//* ------------------------------------------------------------------
//* Remove Proclib members
//* ------------------------------------------------------------------
//BRXDEL3   EXEC PGM=IKJEFT01,REGION=8192K
//SYSTSPRT DD   SYSOUT=*
//SYSTSIN  DD   *
REMOVE_PROCLIB_MEMBERS

for s in $XMI_DIR/proclib/*.jcl; do
        echo " DELETE 'SYS2.PROCLIB($(basename $s .jcl))"
done

cat <<CLEAN_FIRST
 LISTDS 'SYS2.LINKLIB'
/*
//* ------------------------------------------------------------------
//* DELETE DATASETS
//* ------------------------------------------------------------------
//*
//BRXDEL4   EXEC PGM=IDCAMS,REGION=1024K
//SYSPRINT DD  SYSOUT=A
//SYSIN    DD  *
    DELETE BREXX.$VERSION.JCL NONVSAM SCRATCH PURGE
CLEAN_FIRST

for p in $PDS; do
        pds=$(echo $p| tr '[a-z]' '[A-Z]')
echo "    DELETE BREXX.$VERSION.$pds NONVSAM SCRATCH PURGE"
done

cat << END_CLEANUP
 /* IF THERE WAS NO DATASET TO DELETE, RESET CC           */
 IF LASTCC = 8 THEN
   DO
       SET LASTCC = 0
       SET MAXCC = 0
   END
/*
END_CLEANUP
fi

if [ "${TYPE}" = "R" ] || [ "${TYPE}" == "unrelease" ] ; then


cat <<CLEAN_FIRST
/*
//* ------------------------------------------------------------------
//* DELETE DATASETS
//* ------------------------------------------------------------------
//*
//BRXDEL4   EXEC PGM=IDCAMS,REGION=1024K
//SYSPRINT DD  SYSOUT=A
//SYSIN    DD  *
    DELETE BREXX.$VERSION.XMIT NONVSAM SCRATCH PURGE
    DELETE BREXX.$VERSION.LINKLIB NONVSAM SCRATCH PURGE
CLEAN_FIRST

for p in $RELEASE_PDS; do
        pds=$(echo $p| tr '[a-z]' '[A-Z]')
echo "    DELETE BREXX.$VERSION.$pds NONVSAM SCRATCH PURGE"
done

cat << END_CLEANUP
 /* IF THERE WAS NO DATASET TO DELETE, RESET CC           */
 IF LASTCC = 8 THEN
   DO
       SET LASTCC = 0
       SET MAXCC = 0
   END
/*
END_CLEANUP
fi


exit
