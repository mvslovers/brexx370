#!/bin/bash

USER="HERC01"
PASS="CUL8TR"
CLASS="A"
VERSION=$(grep "VERSION " ../../inc/rexx.h|awk  '{gsub(/"/, "", $3); print $3}'|sed "s/[^[:alnum:]]//g" | tr a-z A-Z| cut -c 1-8)
XMI_DIR=../../mvs/install

BUILD_DATE=$(date +"%d %b %Y %T")
BREXX_DATE=$(date -d "@$( stat -c '%Y' brexx.obj )" +"%d %b %Y %T")
PDS="jcl samples rxlib cmdlib install proclib"

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
//BRXXRLSE JOB CLASS=A,MSGCLASS=$CLASS,MSGLEVEL=(1,1),
//         USER=$USER,PASSWORD=$PASS
//* ------------------------------------------------------------------
//* BREXX $VERSION BUILD RELEASE
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
    DELETE BREXX.$VERSION.LINKLIB NONVSAM SCRATCH PURGE
    DELETE BREXX.$VERSION.XMIT NONVSAM SCRATCH PURGE
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


cat <<CREATE_INSTALL_LIBS
/*
//*
//* ------------------------------------------------------------------
//* CREATE THE PDSes
//* ------------------------------------------------------------------
//*
//BRCREATE EXEC PGM=IEFBR14
//DDJCL    DD  DSN=BREXX.$VERSION.LINKLIB,DISP=(,CATLG,DELETE),
//             UNIT=3380,VOL=SER=PUB012,SPACE=(TRK,(20,250,25)),
//             DCB=(RECFM=U,LRECL=0,BLKSIZE=19069)
CREATE_INSTALL_LIBS

for p in $PDS; do
        pds=$(echo $p| tr '[a-z]' '[A-Z]')
        TRK="20"
        TRK2=""
    if [ "$pds" = "INSTALL" ]; then
        TRK="50"
        TRK2="50"
    fi
        cat <<PDS_NAME
//DD$(echo $pds |cut -c1-6) DD  DSN=BREXX.$VERSION.$pds,DISP=(,CATLG,DELETE),
//             UNIT=3380,VOL=SER=PUB012,SPACE=(TRK,($TRK,$TRK2,10)),
//             DCB=(RECFM=FB,LRECL=80,BLKSIZE=800)
PDS_NAME

done

for p in $PDS; do
        pds=$(echo $p| tr '[a-z]' '[A-Z]')
cat << PDS_HEADER
//*
//* ------------------------------------------------------------------
//* ADD $pds RELEASE $VERSION CONTENTS
//* ------------------------------------------------------------------
//*
//* This is written in **rdrprep** syntax
//* It will only work with rdrprep
//* ::a path/file means 'include ascii version of file'
//*
//BR$(echo $pds |cut -c1-6) EXEC PGM=IEBUPDTE,REGION=1024K,PARM=NEW
//SYSUT2   DD  DSN=BREXX.$VERSION.$pds,DISP=SHR
//SYSPRINT DD  SYSOUT=*
//SYSIN    DD  DATA,DLM='#@'
PDS_HEADER

    if [ "$pds" = "INSTALL" ]; then
        DIR=$XMI_DIR/*.*
    else
        DIR=$XMI_DIR/$p/*
    fi
        for s in $DIR; do
                filename=$(basename -- "$s")
                extension="${filename##*.}"
                sed "s/V.R.M./$VERSION/g" $s > $filename
                sed -i "s/ Build Date .*$/ Build Date $BREXX_DATE/g" $filename
                sed -i "s=//\* \.\.\. INSTALLER DATE.*$=//\* \.\.\. INSTALLER DATE $BUILD_DATE=g" $filename                
                cat << EOF
./ ADD NAME=$(basename $s .$extension| tr '[a-z]' '[A-Z]'),LIST=ALL
::a $filename
EOF
        done

echo "#@" 
echo "/*"   
done

echo "Version $VERSION Build Date $BREXX_DATE" > BUILD.txt
echo "INSTALLER PACK DATE $BUILD_DATE" >> BUILD.txt

# upload brexx.obj
cat << COPY_LINKLIB
//*
//* ------------------------------------------------------------------
//* COPY BREXX FROM SYS2.LINKLIB TO BREXX.$VERSION.LINKLIB
//* ------------------------------------------------------------------
//*
//BRCOPYLL EXEC PGM=IEBCOPY
//SYSPRINT DD SYSOUT=A
//SYSUT1 DD DSN=SYS2.LINKLIB,DISP=SHR
//SYSUT2 DD DSN=BREXX.$VERSION.LINKLIB,DISP=SHR
//SYSIN DD *
   COPY OUTDD=SYSUT2,INDD=SYSUT1
   SELECT MEMBER=BREXX
   SELECT MEMBER=REXX
   SELECT MEMBER=RX
/*
COPY_LINKLIB

cat <<XMIT_LINKLIB
//*
//* ------------------------------------------------------------------
//* XMIT BREXX.$VERSION.LINKLIB TO BREXX.$VERSION.INSTALL(LINKLIB)
//* ------------------------------------------------------------------
//*
//XMITLLIB EXEC PGM=XMIT370
//XMITLOG  DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
//SYSIN    DD DUMMY
//SYSUT1   DD DSN=BREXX.$VERSION.LINKLIB,DISP=SHR
//SYSUT2   DD DSN=&&SYSUT2,UNIT=3390,
//         SPACE=(TRK,(255,255)),
//         DISP=(NEW,DELETE,DELETE)
//XMITOUT  DD DSN=BREXX.$VERSION.INSTALL(LINKLIB),DISP=SHR
XMIT_LINKLIB


for p in $PDS; do
    pds=$(echo $p| tr '[a-z]' '[A-Z]')
    if [ "$pds" != "INSTALL" ]; then
cat << XMIT_PDS
//*
//* ------------------------------------------------------------------
//* XMIT BREXX.$VERSION.$pds TO BREXX.$VERSION.INSTALL($pds)
//* ------------------------------------------------------------------
//*
//XMIT$(echo $pds |cut -c1-4) EXEC PGM=XMIT370
//XMITLOG  DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
//COPYR1   DD DUMMY
//SYSIN    DD DUMMY
//SYSUT1   DD DSN=BREXX.$VERSION.$pds,DISP=SHR
//SYSUT2   DD DSN=&&SYSUT2,UNIT=3390,
//         SPACE=(TRK,(255,255)),
//         DISP=(NEW,DELETE,DELETE)
//XMITOUT  DD DSN=BREXX.$VERSION.INSTALL($pds),DISP=SHR
XMIT_PDS
    fi
done

cat << XMIT_RELEASE
//*
//* ------------------------------------------------------------------
//* XMIT BREXX.$VERSION.INSTALL TO BREXX.$VERSION.XMIT
//* ------------------------------------------------------------------
//*
//XMITRLSE EXEC PGM=XMIT370
//XMITLOG  DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
//SYSUDUMP  DD SYSOUT=*
//COPYR1   DD DUMMY
//SYSIN    DD DUMMY
//SYSUT1   DD DSN=BREXX.$VERSION.INSTALL,DISP=SHR
//SYSUT2   DD DSN=&&SYSUT2,UNIT=3390,
//         SPACE=(TRK,(255,255)),
//         DISP=(NEW,DELETE,DELETE)
//XMITOUT  DD DSN=BREXX.$VERSION.XMIT,DISP=(,CATLG,DELETE),
//            UNIT=3380,VOL=SER=PUB012,SPACE=(TRK,(50,50))
XMIT_RELEASE
