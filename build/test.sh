#!/bin/bash

# Test brexx install


USER="HERC01"
PASS="CUL8TR"
CLASS="A"
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
    VERSION=$4
fi


cat <<END_JOBCARD
//BRXXTEST JOB CLASS=A,MSGCLASS=$CLASS,MSGLEVEL=(1,1),
//         USER=$USER,PASSWORD=$PASS
//* ------------------------------------------------------------------
//* BREXX $VERSION TEST
//* ------------------------------------------------------------------
//*
//SPLASH   EXEC RXBATCH,SLIB='BREXX.$VERSION.SAMPLES',EXEC=\$VERSION 
//BANNER   EXEC RXBATCH,SLIB='BREXX.$VERSION.SAMPLES',EXEC=BANNER,  
//         P='BREXX 370'                                          
//BLOCK    EXEC RXBATCH,SLIB='BREXX.$VERSION.SAMPLES',EXEC=BLOCK    
//BUZZWORD EXEC RXBATCH,SLIB='BREXX.$VERSION.SAMPLES',EXEC=BUZZWORD 
//FACTRIAL EXEC RXBATCH,SLIB='BREXX.$VERSION.SAMPLES',EXEC=FACTRIAL,
//         P='12'                                                 
//NUMBCONV EXEC RXBATCH,SLIB='BREXX.$VERSION.SAMPLES',EXEC=NUMBCONV,
//         P='53568741'                                           
//PLOT3D   EXEC RXBATCH,SLIB='BREXX.$VERSION.SAMPLES',EXEC=PLOT3D   
//POETRY   EXEC RXBATCH,SLIB='BREXX.$VERSION.SAMPLES',EXEC=POETRY   
//PRIMES   EXEC RXBATCH,SLIB='BREXX.$VERSION.SAMPLES',EXEC=PRIMES,  
//         P='300'                                                
//QT       EXEC RXBATCH,SLIB='BREXX.$VERSION.SAMPLES',EXEC=QT       
//* XXCPS  EXEC RXBATCH,SLIB='BREXX.$VERSION.SAMPLES',EXEC=REXXCPS  
//SINPLOT  EXEC RXBATCH,SLIB='BREXX.$VERSION.SAMPLES',EXEC=SINPLOT  
//TB       EXEC RXBATCH,SLIB='BREXX.$VERSION.SAMPLES',EXEC=TB,P='1' 
//DATE     EXEC RXBATCH,SLIB='BREXX.$VERSION.SAMPLES',EXEC=\$DATE    
//ETIME    EXEC RXBATCH,SLIB='BREXX.$VERSION.SAMPLES',EXEC=\$ETIME
//
END_JOBCARD