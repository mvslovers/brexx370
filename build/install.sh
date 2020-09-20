
#!/bin/bash

# This script will generate the JCL required for Brexx install
# It:
#   Installs JCL in mvs/install/proclib to SYS2.PROCLIB and updates the version/build info
#   Installs JCL in mvs/install/proclib to BREXX.$VERSION.JCL and updates version/build info
#   Installs mvs/install/(rxlib,cmdlib,smaples) to BREXX.$VERSION.(RXLIB,CMDLIB,SAMPLES)

USER="HERC01"
PASS="CUL8TR"
CLASS="A"
VERSION=$(grep "VERSION " ../inc/rexx.h|awk  '{gsub(/"/, "", $3); print $3}')
XMI_DIR=../mvs/install

BUILD_DATE=$(date +"%d %b %Y %T")
BREXX_DATE=$BUILD_DATE
PDS="samples rxlib cmdlib"


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
    VERSION=$4
fi
if [ $# = 5 ]; then
    USER=$1
    PASS=$2    
    CLASS=$3   
    VERSION=$4
    BREXX_DATE=$5
fi

cat <<END_JOBCARD
//BRXINSTL JOB CLASS=A,MSGCLASS=$CLASS,MSGLEVEL=(1,1),
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

cat << REMOVE_PROCLIB_MEMBERS
//* ------------------------------------------------------------------
//* Remove Proclib members
//* ------------------------------------------------------------------
//BRDELPRC EXEC PGM=IKJEFT01,REGION=8192K
//SYSTSPRT DD   SYSOUT=*
//SYSTSIN  DD   *
REMOVE_PROCLIB_MEMBERS

for s in $XMI_DIR/proclib/*.jcl; do
        echo " DELETE 'SYS2.PROCLIB($(basename $s .jcl))"
done

cat <<CREATE_INSTALL_LIBS
 LISTDS 'SYS2.LINKLIB'
/*
//*
//* ------------------------------------------------------------------
//* CREATE THE PDS
//* ------------------------------------------------------------------
//*
//BRCREATE EXEC PGM=IEFBR14
//DDJCL    DD  DSN=BREXX.$VERSION.JCL,DISP=(,CATLG,DELETE),
//             UNIT=3380,VOL=SER=PUB012,SPACE=(TRK,(20,,2)),
//             DCB=(RECFM=FB,LRECL=80,BLKSIZE=800)
CREATE_INSTALL_LIBS

for p in $PDS; do
        pds=$(echo $p| tr '[a-z]' '[A-Z]')
        cat << PDS_NAME
//DD$(echo $pds |cut -c1-6) DD  DSN=BREXX.$VERSION.$pds,DISP=(,CATLG,DELETE),
//             UNIT=3380,VOL=SER=PUB012,SPACE=(TRK,(50,,10)),
//             DCB=(RECFM=FB,LRECL=80,BLKSIZE=800)
PDS_NAME
done
cat <<ADD_NEW_PROCLIB
//*
//* ------------------------------------------------------------------
//* ADD PROCLIB RELEASE $VERSION CONTENTS
//* ------------------------------------------------------------------
//*
//* This is written in **rdrprep** syntax
//* It will only work with rdrprep
//* ::a path/file means 'include ascii version of file'
//*
//BRPROCLB EXEC PGM=IEBUPDTE,REGION=1024K,PARM=NEW
//SYSUT2   DD  DSN=SYS2.PROCLIB,DISP=SHR
//SYSPRINT DD  SYSOUT=*
//SYSIN    DD  DATA,DLM='##'
ADD_NEW_PROCLIB

for s in $XMI_DIR/proclib/*.jcl; do
        proclib_file=$(basename $s)
        sed "s://\*RELEASE   SET.*$://*RELEASE   SET '$VERSION':g" $s > $proclib_file
        sed -i "s=//\* \.\.\. BREXX.*$=//\* \.\.\. BREXX Version $VERSION Build Date $BREXX_DATE=g" $proclib_file
        sed -i "s=//\* \.\.\. INSTALLER DATE.*$=//\* \.\.\. INSTALLER DATE $BUILD_DATE=g" $proclib_file
        sed -i "s/BREXX.*./BREXX.$VERSION./g" $proclib_file
        cat << EOF
./ ADD NAME=$(basename $s .jcl),LIST=ALL
::a $proclib_file
EOF
done

cat <<ADD_NEW_JCL
##
/*
//*
//* ------------------------------------------------------------------
//* ADD SAMPLE JCL RELEASE $VERSION CONTENTS
//* ------------------------------------------------------------------
//*
//* This is written in **rdrprep** syntax
//* It will only work with rdrprep
//* ::a path/file means 'include ascii version of file'
//*
//BRJCLLIB EXEC PGM=IEBUPDTE,REGION=1024K,PARM=NEW
//SYSUT2   DD  DSN=BREXX.$VERSION.JCL,DISP=SHR
//SYSPRINT DD  SYSOUT=*
//SYSIN    DD  DATA,DLM='##'
ADD_NEW_JCL

for s in $XMI_DIR/jcl/*.jcl; do
       jcl_file=$(basename $s)
        sed "s://\*RELEASE   SET.*$://*RELEASE   SET '$VERSION':g" $s > $jcl_file
        sed -i "s=//\* \.\.\. BREXX.*$=//\* \.\.\. BREXX Version $VERSION Build Date $BREXX_DATE=g" $jcl_file
        sed -i "s=//\* \.\.\. INSTALLER DATE.*$=//\* \.\.\. INSTALLER DATE $BUILD_DATE=g" $jcl_file
        sed -i "s/BREXX.*\./BREXX.$VERSION\./g" $jcl_file
        cat << EOF
./ ADD NAME=$(basename $s .jcl),LIST=ALL
::a $jcl_file
EOF
done

for p in $PDS; do
        pds=$(echo $p| tr '[a-z]' '[A-Z]')
cat << PDS_HEADER
##
/*
//*
//* ------------------------------------------------------------------
//* ADD SAMPLE $pds RELEASE $VERSION CONTENTS
//* ------------------------------------------------------------------
//*
//* This is written in **rdrprep** syntax
//* It will only work with rdrprep
//* ::a path/file means 'include ascii version of file'
//*
//BR$(echo $pds |cut -c1-6) EXEC PGM=IEBUPDTE,REGION=1024K,PARM=NEW
//SYSUT2   DD  DSN=BREXX.$VERSION.$pds,DISP=SHR
//SYSPRINT DD  SYSOUT=*
//SYSIN    DD  DATA,DLM='##'
PDS_HEADER
        for s in $XMI_DIR/$p/*; do
                filename=$(basename -- "$s")
                extension="${filename##*.}"
                cat << EOF
./ ADD NAME=$(basename $s .$extension| tr '[a-z]' '[A-Z]'),LIST=ALL
::a $s
EOF
        done
done
