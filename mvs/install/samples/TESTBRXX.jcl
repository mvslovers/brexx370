//BRXXTEST JOB (BREXX),
//             'BREXX VERIFICATION',
//             CLASS=A,
//             MSGCLASS=H,
//             REGION=8600K,
//             MSGLEVEL=(0,0)
//             USER=HERC01,PASSWORD=CUL8TR,NOTIFY=HERC01
//SPLASH   EXEC RXBATCH,SLIB='BREXX.V2R3M0.SAMPLES',PARM.EXEC=''
//EXEC     DD   DUMMY
//BANNER   EXEC RXBATCH,SLIB='BREXX.V2R3M0.SAMPLES',EXEC=BANNER,P='BREXX JCC'
//*ALLCHARS EXEC RXBATCH,SLIB='BREXX.V2R3M0.SAMPLES',EXEC=ALLCHARS
//*BANNER   DD   DSN=BREXX.V2R2M0.SAMPLES(BANNER),DISP=SHR
//BLOCK    EXEC RXBATCH,SLIB='BREXX.V2R3M0.SAMPLES',EXEC=BLOCK
//BUZZWORD EXEC RXBATCH,SLIB='BREXX.V2R3M0.SAMPLES',EXEC=BUZZWORD
//FACTRIAL EXEC RXBATCH,SLIB='BREXX.V2R3M0.SAMPLES',EXEC=FACTRIAL,P='12'
//NUMBCONV EXEC RXBATCH,SLIB='BREXX.V2R3M0.SAMPLES',EXEC=NUMBCONV,P='53568741'
//PLOT3D   EXEC RXBATCH,SLIB='BREXX.V2R3M0.SAMPLES',EXEC=PLOT3D
//POETRY   EXEC RXBATCH,SLIB='BREXX.V2R3M0.SAMPLES',EXEC=POETRY
//PRIMES   EXEC RXBATCH,SLIB='BREXX.V2R3M0.SAMPLES',EXEC=PRIMES,P='30000'
//QT       EXEC RXBATCH,SLIB='BREXX.V2R3M0.SAMPLES',EXEC=QT
//REXXCPS  EXEC RXBATCH,SLIB='BREXX.V2R3M0.SAMPLES',EXEC=REXXCPS
//TB       EXEC RXBATCH,SLIB='BREXX.V2R3M0.SAMPLES',EXEC=TB,P='1'
//SINPLOT  EXEC RXBATCH,SLIB='BREXX.V2R3M0.SAMPLES',EXEC=SINPLOT
//