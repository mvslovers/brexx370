/* REXX RECEIVE WRAPPER */
IF getdsn(0)>0 THEN RETURN 4   /* Fetch Input DSN  */
inputdsn = dsn
IF getdsn(1)>0 THEN RETURN 4   /* Fetch Output DSN */
outputdsn = dsn
 
/* call receive function */
RC = RECEIVE(inputdsn,outputdsn)
RETURN RC
/*********************************************************************
* build and submit xmit370 jcl job                                   *
*********************************************************************/
receive: PROCEDURE
PARSE UPPER ARG input,output
 
userid = USERID()
input  = QUALIFY(STRIP(input))
output = QUALIFY(STRIP(output))
"FREE FILE(tmp)"
"FREE ATTR(@deck)"
 
"ATTR @deck RECFM(f b) LRECL(80) BLKSIZE(19040) DSORG(ps)"
"ALLOC FILE(tmp) NEW REU UNIT(vio) USING(@deck)"
IF RC <> 0 THEN DO
    SAY 'Error allocating temporary jcl file. RC =' RC
    RETURN 16
END
 
x=LISTDSI('TMP FILE')
temp = SYSDSNAME
 
jclStmt.1  = '//'userid'X JOB CLASS=A,MSGCLASS=H,NOTIFY='userid
jclStmt.2  = '//RECV370  EXEC PGM=RECV370,REGION=4096K'
jclStmt.3  = '//SYSPRINT DD SYSOUT=*'
jclStmt.4  = '//RECVLOG  DD SYSOUT=*'
jclStmt.5  = '//SYSIN    DD DUMMY'
jclStmt.6  = '//XMITIN   DD DISP=SHR,DSN='input
jclStmt.7  = '//SYSUT1   DD DSN=&&SYSUT1,UNIT=3390,'
jclStmt.8  = '//         SPACE=(TRK,(1000,500)),'
jclStmt.9  = '//         DISP=(NEW,DELETE,DELETE)'
jclStmt.10 = '//SYSUT2   DD DSN='output',UNIT=3390,'
jclStmt.11 = '//         SPACE=(TRK,(1000,500,100)),'
jclStmt.12 = '//         DISP=(NEW,CATLG,CATLG)'
jclStmt.0  = 12
 
ADDRESS SYSTEM
fp=OPEN("tmp","w")
DO i = 1 TO jclStmt.0
  jclRec = LEFT(jclStmt.i,80)
  nc = WRITE(fp,jclRec)
END
CALL CLOSE(fp)
 
ADDRESS TSO
"SUBMIT '"temp"'"
"FREE ATTR(@deck)"
"FREE FILE(tmp)"
 
RETURN RC
/*********************************************************************
* ask for a dataset name                                             *
*********************************************************************/
getdsn:
PARSE ARG mode
 
ADDRESS TSO
 
DO count=1 TO 3
  /* ask for source DSN */
  IF mode=1 THEN SAY "Enter a target DSN:"
  ELSE SAY           "Enter a source DSN:"
  PARSE UPPER PULL DSN
 
  /* check for END request */
  IF DSN == 'END' THEN DO
    CALL rxmsg 104,'W','END requested'
    RETURN 4
  END
 
  /* check if dataset is available */
  avail=SYSDSN(DSN)
  IF mode=0 THEN DO
    IF avail == 'OK' THEN RETURN 0
    ELSE CALL rxmsg 102,'W','Dataset 'UNQUOTE(DSN)' could not be found.'
  END
  ELSE IF mode=1 THEN DO
    IF avail <> 'OK' THEN RETURN 0
    ELSE CALL rxmsg 103,'W','Dataset 'UNQUOTE(DSN)' already exists.'
  END
END
 
/* quit after 3 attemts */
IF mode=0 THEN DO
  CALL rxmsg 100,'W','Missung source DSN'
END
ELSE IF mode = 1 THEN DO
  CALL rxmsg 101,'W','Missung target DSN'
END
RETURN 4
