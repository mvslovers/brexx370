/* REXX TRANSMIT WRAPPER */
IF getdsn(0)>0 THEN RETURN 4   /* Fetch Input DSN  */
inputdsn = dsn
IF getdsn(1)>0 THEN RETURN 4   /* Fetch Output DSN */
outputdsn = dsn
/* call transmit function */
RC = TRANSMIT(inputdsn,outputdsn)
RETURN RC
/*********************************************************************
* build and submit xmit370 jcl job                                   *
*********************************************************************/
transmit: PROCEDURE
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
jclStmt.2  = '//XMIT370  EXEC PGM=XMIT370,REGION=4096K'
jclStmt.3  = '//XMITIN   DD DUMMY'
jclStmt.4  = '//SYSIN    DD DUMMY'
jclStmt.5  = '//SYSPRINT DD SYSOUT=*'
jclStmt.6  = '//XMITLOG  DD SYSOUT=*'
jclStmt.7  = '//SYSUT1   DD DISP=SHR,DSN='input
jclStmt.8  = '//SYSUT2   DD DSN=&&SYSUT2,UNIT=3390,'
jclStmt.9  = '//            SPACE=(TRK,(1000,250)),'
jclStmt.10 = '//            DISP=(NEW,DELETE,DELETE)'
jclStmt.11 = '//XMITOUT  DD DSN='output',UNIT=3390,'
jclStmt.12 = '//            SPACE=(TRK,(1000,150),RLSE),'
jclStmt.13 = '//            DISP=(NEW,CATLG,DELETE)'
jclStmt.0  = 13
 
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
