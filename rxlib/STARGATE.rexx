/* --------------------------------------------------------------------
 * Call Stargate to transfer Files
 * --------------------------------------------------------------------
 */
stargate:
  parse upper arg mode,tcp,port,senddsn
  batch=0
  ilevel=level()                  /* proc level    */
  call starinit                   /* Init stargate */
  if word(senddsn,1)='$$$QUEUE' then senddsn=buildQueue()
  if      abbrev('SEND',mode,3)    then rc=starsend()
  else if abbrev('RECEIVE',mode,3) then do
     rc=starreceive()
     call TCPTERM     /* Shutdown all open Connections */
  end
fatalError:
return rc
/* --------------------------------------------------------------------
 * Build Input Queue if requested
 * --------------------------------------------------------------------
 */
BuildQueue:
  fromQueue=word(senddsn,2)
  if substr(fromQueue,length(fromQueue),1)<>'.' then fromQueue=fromQueue'.'
  iqueue=''
  if symbol(fromQueue)='LIT' then call xsay GETG('EMSG'),'QUEUE stem does not exist: 'fromQueue
  else do
     qmax=value(fromQueue'0')
     if datatype(qmax)<>'NUM' then call xsay GETG('EMSG'),'QUEUE stem entries not set: 'fromQueue'0'
     else do i=1 to qmax
        if symbol(fromQueue||i) <>'VAR' then iterate
        iqueue=iqueue||value(fromQueue||i)'\'
     end
  end
  if iqueue='' then do
     call xsay GETG('EMSG'),'QUEUE stem clause invalid, terminate'
     exit
  end
return iqueue
/* --------------------------------------------------------------------
 * Handle SEND requests
 * --------------------------------------------------------------------
 */
starsend:
  call setg('SG_TCPMODE','SEND')
  if tcp<>'$$$SOCKET' then call setg('SG_IPADDR',tcp':'port)
  rc=Send2SRV(tcp,port,senddsn)
return rc
/* --------------------------------------------------------------------
 * Handle RECEIVE requests
 * --------------------------------------------------------------------
 */
starreceive:
  call setg('SG_TCPMODE','RECEIVE')
  call setg('SG_TCPTYPE','ACTV')
  if getg('sg_alive')=0 then call xsay GETG('IMSG'),'Server will shutdown after one request'
  rc=starSVR(tcp,port,senddsn)
return rc
/* --------------------------------------------------------------------
 * Client opens a connection to the Server and sends the file(s)
 * The client actively triggers the Server
 * --------------------------------------------------------------------
 */
 send2SRV: procedure
 parse arg tcp,port,sdsn
  call tcpinit
  if tcp='$$$SOCKET' then do
     socket=port
     if socket<0 then do
        call xsay GETG('EMSG'),'Socket not open, please return and re-Logon'
        return 8
     end
     call xsay GETG('IMSG'),'Stargate Client reassumed Socket 'socket
     signal alreadyDone
  end
  else if Connect2SRV()>0 then return 8  /* Connect and fetch socket */
  CALLER_IP=GETG('SG_TCPCaller')
  if word(TCPConfirm(socket,"$$$MODE SEND "socket" "CALLER_IP),2)='OK' then nop
  else do
     call xsay GETG('EMSG'),"Handshake failed '"substr(_data,1,16)"'"
     return 8
  end
  CALLEE_SOCKET=word(_data,3)
  CALLEE_IP     =word(_data,4)
  call SETG('SG_TCPCallee',CALLEE_IP)
  call xsay GETG('IMSG'),"1 Handshake successful, caller/callee socket "socket"/"CALLEE_SOCKET" IP "CALLER_IP'/'CALLEE_IP
  msgs='Connected to Stargate'!!crlf
alreadyDone:
  incmd=sdsn
  do until incmd=''
     parse var incmd command'\'incmd
     if sendCMD(strip(command),1)<0 then return -64 /* Send command and receive files if requested, don't close socket */
  end
  if stargate_clientAlive=0 then call TCPCLOSE(socket) /* close socket at multi command level */
  else do
   call xsay GETG('IMSG'),"Socket remains open for subsequent use "socket
     call setg('sg_clientSocket',socket) /* save socket for later use */
  end
return 0
/* --------------------------------------------------------------------
 * Connect Client to Server
 * --------------------------------------------------------------------
 */
Connect2SRV:
  if TCPOPEN(tcp,port,30)=0 then do
     call xsay GETG('IMSG'),'Stargate Client in SEND Mode started'
     call xsay GETG('XMSG'),'Connected to Server(socket-'_fd'), TCP 'tcp' Port 'port
  end
  else do
     call xsay GETG('EMSG'),"Server connect failed"
     return 8
  end
  call wait(500)
  socket=_fd
return 0
/* --------------------------------------------------------------------
 * Create Target File receiving the sent data
 * --------------------------------------------------------------------
 */
adddsn:
  parse arg ndsn,ndcb
  stcp=getg('SG_TCPLIST')
  ndsn=translate(ndsn,'.','()')   /* Make member part of dsn */
  if substr(ndsn,length(ndsn),1)='.' then ndsn=substr(dsn,1,length(ndsn)-1)
  nrc=create(ndsn,ndcb)
  if nrc=-2 then call sset(STCP,,time('l')' 'ndsn' already defined, re-use it')
  else if nrc=-1 then do
     call sset(STCP,,time('l')' 'ndsn" can't be created")
     return -1
  end
/* PDS requires a explicit confirmation, to start the Member transfer */
  if type='PDS' then call TCPSENDX(_fd,'OK PDS 'ndsn' CREATED',1)
return ndsn
/* --------------------------------------------------------------------
 * Receive the File and store it in the created dsn
 *    Function are executed on Server  (client requested a $$$DELIVER)
 *                  and on the Client  (client requested a $$$RECEIVE)
 * --------------------------------------------------------------------
 */
sgreceive:
  parse upper arg newdsn
  call wait(250)
  dlen=TCPSENDX(_fd,'OK START SENDING',1)
  tlen=0
  eof=0
  reci=0
  if symbol('rfiles')='LIT' then rfiles=0
  if symbol('ttotal')='LIT' then ttotal=0
  fk1=open(newdsn,'WT')
  if fk1<0 then do
     call TCPSENDX(_fd,'NOK CANNOT OPEN 'newdsn,1)
     call wait(250)
     return 8
  end
  dtotal=0
  do forever
     dlen=TCPRECEIVEX(_fd,1)  /* number of Bytes */
     if dlen>0 then eof=0
     else if dlen<0 then leave
     else do
        eof=eof+1
        if eof>1 then leave
        iterate
     end
     dtotal=dtotal+length(_data)
     call write(fk1,_data)
     reci=reci+1
     tlen=tlen+dlen
  end
  call close(fk1)
  newdsn=translate(userid()'.'newdsn)
  call xsay GETG('IMSG'),'Receiving +++ 'newdsn' completed ('dtotal' bytes)'
  call setg('SG_RECEIVED_DSN',newdsn)
  if pos('.JES2.',newdsn)>0 & pos('.OUTLIST',newdsn)>0  ,
     then call xsay GETG('IMSG'),'Received DSN is an exported Spool file '
  rfiles=rfiles+1
  ttotal=ttotal+dtotal
  call TCPSENDX(_fd,'OK 'newdsn' END OF FILE REACHED',1)
return 0
/* --------------------------------------------------------------------
 * Call MVS Server in active mode, to send files from it.
 * --------------------------------------------------------------------
 */
starSVR: procedure  expose ddprof.
 parse arg tcp,port,idsn
 timeout=3            /* time out 10 seconds */
 crlf='0D0A'x
 reci=0
 stcp=getg('SG_TCPLIST')
 call setg('SG_SERVER',1)
/* .....................................................................
 * This is the call to the generic TCPSF module
 * .....................................................................
 */
  rc=TCPSF(port,timeout,'Stargate','ERROR')  /* start TCP Server, report only errors */
return rc
/* *********************************************************************
 * Here follow the Events, called by TCPSF as call-back
 * #### This part is the EVENT-HANDLER, you need only code what should
 * #### happen and set the RCs properly to tell TCPSF how to proceed
 * *********************************************************************
 */
/* ---------------------------------------------------------------------
 * Receive Data from Client:
 *         arg(1) TCP socket token (channel to client)
 *         arg(2) original data,
 *         arg(3) ebcdic data translated from ascii
 *
 * ---------------------------------------------------------------------
 */
TCPData:
  parse arg _fd,_data,EMSG
  if pos('$$$KILLBILL82061',_data)>0 then do
     call xsay GETG('XMSG'),' Hard forced shut down of Stargate'
     return 8
  end
  status='CLIENT'
  nstatus='SERVER'
  stcp=getg('SG_TCPLIST')
  if getg('SG_TCPTYPE')='PASV' then return 0
  if getg('SG_TCPMODE')='SEND' then scmt='Sending'
     else scmt='Receiving'
  if word(sget(getg('SG_LOGON'),_fd),1)='ACTIVE' then nop
  else do
     if word(_data,1)<>'$$$LOGON' then return cancelClient()
     call xsay GETG('IMSG'),scmt' messages started'
     call sset(getg('SG_LOGON'),_fd,'INIT   'sguser'from '_fd' prepare to logon at 'time('l'))
  end
  call sset(STCP,,time('l')' Receive Data Event 'left(_data,40))
CheckCMD:
   if pos('$$$GETNEXT',_data)>0 then return 0  /* if getnext reaches here, ignore it belongs to $RECIEVE */
   senddsn=getg('SG_DSN')
/* .........................................................................
   Syntax of incoming command requests
     $$$ADD FILE PEJ.EXEC(DBRUN) RECFM=VB,LRECL=255,BLKSIZE=19040,UNIT=SYSDA,PRI=1,SEC=1
     $$$ADD MEMBER PEJ.EXEC(DBRUN)
     $$$LINK ip-address port
     $$$STOP
     $$$SEND
     $$$SHUTDOWN
 */
  parse var _data mode' 'type' 'dsn' 'dcb' 'rem
  if senddsn<>'' then tdsn=senddsn
  else tdsn='$STG.'dsn
  mode=translate(mode)
  if mode='$$$SHUTDOWN' then signal $shutdown/* explicit stop requested   */
  if mode='$$$LOGON'    then signal $logon   /* Logon not yet implemented */
  if mode='$$$GOODBYE'  then signal $goodbye /* Good Bye received         */
  if mode='$$$STOP'     then signal $STOP    /* STOP requested            */
  if mode='$$$SEND'     then signal $send    /* Send received             */
  if mode='$$$SUBMIT'   then signal $submit  /* Send received             */
  if mode='$$$SPOOL'    then signal $spool   /* Send Spool request        */
  if mode='$$$PDSLIST'  then signal $pdslist /* Send PDSLIST request      */
  if mode='$$$LISTCAT'  then signal $listcat /* Send LISTCAT request      */
  if mode='$$$RXRUN'    then signal $rxrun   /* Send RXRUN   request      */
  if mode='$$$JESGET'   then signal $jesget  /* Send JES GET request      */
  if mode='$$$RECEIVE'  then signal $receive /* Send JES GET request      */
  if mode='$$$KVSET'    then signal $kvset   /* Send Key/Value record     */
  if mode='$$$KVGET'    then signal $kvget   /* Send Key/Value record     */
  if mode='$$$HEARTBEAT' then signal $heartbeat /* Send Heartbeat         */
  if mode='$$$LINK'     then do              /* Link to another MVS       */
     call $link
     return 0
  end
  if dsn='' then do                          /* Maybe connection lost     */
     call xsay GETG('EMSG'),'Missing DSN information, possibly connection lost'
     return 8                                /* connection lost, terminate*/
  end
/* ....  Process all mode $$$ADD  ....................................... */
  if type='FILE' then do
     if adddsn(tdsn,dcb)=-1 then return 8    /* cannot create target DSN  */
     if sgreceive(tdsn)=8   then return 8   /* Receive of File failed     */
  end
  else if type='PDS' then do
     if adddsn(tdsn,dcb)=-1 then return 8   /* cannot create target DSN       */
     return 0                               /* step 1 only the PDS is created */
  end                                       /* step 2 $$$ADD MEMBER follows   */
  else if type='MEMBER' then do
     if senddsn<>'' & pos('(',tdsn)=0 then do /* Add Member name for new DSN*/
        parse var dsn xdsn'('xmember')'
        tdsn=tdsn'('xmember')'
     end
     if sgreceive(tdsn)=8 then return 8      /* Receive of File failed     */
  end
return 0                                 /* wait for next incoming command */
/* ---------------------------------------------------------------------
 * Cancel Client, request needs a LOGON
 * ---------------------------------------------------------------------
 */
CancelClient:
  call TCPSENDX(_fd,'ABORT You are not logged-on',1)
  call xsay GETG('EMSG'),'Session is not logged-on: '_fd
  call sset(getg('SG_LOGON'),_fd,'INACIVE')
  call wait 200
  call tcpclose(_fd)
return 0
/* ---------------------------------------------------------------------
 * LOGON  requested
 * Password so far: 271.441
 * Die kleinste Perrinsche Pseudoprimzahl, 521**2
 * ---------------------------------------------------------------------
 */
$logon:
  credential=subword(_data,2)
  parse upper var credential sguser' 'sgpw
  call xsay GETG('IMSG'),'Receiving LOGON from 'status', 'sguser
  if datatype(sgpw)='NUM' then do
     if sgpw=271441 then do
        call TCPSENDX(_fd,'OK LOGON performed',1)
        call sset(getg('SG_LOGON'),_fd,'ACTIVE 'sguser'from '_fd' logged on at 'time('l'))
        call xsay GETG('IMSG'),'Logon for 'sguser' successful'
        return 0
     end
  end
  call TCPSENDX(_fd,'Nice try jester',1)
  call xsay GETG('IMSG'),'Logon for 'sguser' failed'
  call wait 200
  call tcpclose(_fd)
return 0
/* ---------------------------------------------------------------------
 * GOODBYE  requested
 * ---------------------------------------------------------------------
 */
$goodbye:
  call xsay GETG('IMSG'),'Receiving good-bye from 'status', 'subword(_data,2)
  call TCPSENDX(_fd,'QUIT from 'nstatus'(socket-'_fd') Cheers, see you next time',1)
return 0        /* do not stop server, as disconnect will do it      */
/* ---------------------------------------------------------------------
 * STOP requested
 * ---------------------------------------------------------------------
 */
$STOP:
  if getg('sg_server')<>1 then return 8   /* Close Client         */
  if getg('sg_alive')  =0 then return 8   /* Shut Down Server     */
  call xsay GETG('WMSG'),'STOP request ignored, keep alive mode'
return 0                                  /* Keep Server up       */
/* ---------------------------------------------------------------------
 * SEND Message requested
 * ---------------------------------------------------------------------
 */
$SEND:
   user=type /* 2. word in _data  */
   message=subword(_data,3)
/*   SEND  ''TEXT''  USER('USERID LIST')  NOW/LOGON/SAVE  NOWAIT/WAIT */
   call outtrap('send.')
   ADDRESS TSO
    "SEND '"message"' USER("user") LOGON"
   call outtrap('OFF')
  if pos('UNDEFINED USERID(S)',send.1)=0 then call TCPSENDX(_fd,'OK SEND performed',1)
     else call TCPSENDX(_fd,'NOK SEND failed 'send.1,1)
return 0
/* ---------------------------------------------------------------------
 * HEARTBEAT test if Server is runnning
 * ---------------------------------------------------------------------
 */
$HEARTBEAT:
  call TCPSENDX(_fd,'OK 'time('l')' Heartbeat',1)
return 0
/* ---------------------------------------------------------------------
 * LINK to another Server requested
 * ---------------------------------------------------------------------
 */
$LINK: procedure expose _data _fd
  mvsip=word(_data,2)
  mvsport=word(_data,3)
  TCALLER_IP=GETG('SG_TCPCALLER')
  TCALLEE_IP=GETG('SG_TCPCallee')
  alive=getg('sg_clientAlive')
  tcmode=getg('SG_TCPMODE')
  sgpw=271441
  sgQueue.1='$$$LOGON 'MVSVAR('SYSNAME')'.'STARGATE' 'sgpw
  sgQueue.2='$$$SEND PEJ Servers are connected'
  sgQueue.0=2
  stargate_clientAlive=0  /* Do not keep server/server connection oprn */
  stargate_mslv=0         /* all messages in the beginning */
  rc=stargate('SEND','lzugnkblfjyga3as.myfritz.net',3205,'$$$QUEUE SGQUEUE.')
  call SETG('SG_TCPCALLER',TCALLER_IP)
  call SETG('SG_TCPCallee',TCALLEE_IP)
  call SETG('SG_TCPMode',tcmode)
  call setg('sg_clientAlive',alive)
return 0
/* ---------------------------------------------------------------------
 * SHUTDOWN requested
 * ---------------------------------------------------------------------
 */
$SHUTDOWN:
  call xsay GETG('IMSG'),'Receiving explicit SHUTDOWN from 'status', 'subword(_data,2)
  call TCPSENDX(_fd,'QUIT from 'nstatus'(socket-'_fd') Cheers, see you next time',1)
return 8                                  /* Keep Server up       */
/* ---------------------------------------------------------------------
 * SUBMIT requested
 * ---------------------------------------------------------------------
 */
$SUBMIT:
   jcl="'"type"'"               /* 2. word in _data  */
   call outtrap('submit.')
     ADDRESS TSO "SUBMIT "jcl     /* JOB PEJTEMP(JOB03400) SUBMITTED */
   call outtrap('OFF')
   if rc=0 then do
      parse var submit.1 jobstr' 'subjobname'('subjobnumber') 'substr
      call setg("submit_jobnum",subjobnumber)
      call setg("submit_jobname",subjobname)
      call TCPSENDX(_fd,'OK SUBMIT performed, JOB 'getg("submit_jobname")' 'getg("submit_jobnum"),1)
      call xsay GETG('IMSG'),'JOB Submitted 'getg("submit_jobname")' 'getg("submit_jobnum")
      return 0
   end
   else call TCPSENDX(_fd,'NOK SUBMIT failed',1)
   call xsay GETG('EMSG'),'SUBMIT of 'jcl' failed'
return 0
/* ---------------------------------------------------------------------
 * SPOOL requested
 * ---------------------------------------------------------------------
 */
$SPOOL:
  call CONSOLE('$DA,ALL')
  call CONSOLE('$DN')
  SPOOL1=screate(4096)
  call wait(100)
  call mttx(1,SPOOL1)
  SPOOL2=scut(SPOOL1,"SPOOL UTILIZATION","$DA,ALL")
  call sfree(SPOOL1)
  if spool2<0 then signal spoolError1
  SPOOL1=Sselect(SPOOL2,"$HASP000")
  if spool1<0 then call spoolError2
  call sfree(SPOOL2)
  call ssubstr(SPOOL1,15,,'INTERNAL')
  SPOOL2=screate(sarray(SPOOL1))
  do i=1 to sarray(SPOOL1)
     record=joblist(sget(SPOOL1,i))
     if record='' then iterate
     call sset(SPOOL2,,record)
  end
  call sqsort(SPOOL2)
spoolErrorW:
  call sfree(SPOOL1)
  call writebuf SPOOL2
  call sfree(SPOOL2)
return 0
SpoolError2:
  call sfree spool2
SpoolError1:
  SPOOL2=screate(5)
  call xsay GETG('EMSG'),'Unable to locate Spool content'
  call sset(spool2,,'Unable to locate Spool content')
  signal spoolErrorW
return
joblist:
  if pos('$HASP000 NO ACTIVE JOBS',arg(1))>0 then return ''
  parse value arg(1) with jobt' 'jobnum'  'hasp' 'jobname' 'q1' 'n
  jobt    =word(arg(1),1)
  jobnum  =word(arg(1),2)
  jobname =word(arg(1),4)
  jobname =jobname'('jobt||right(jobnum,5,'0')')'
  jobqueue=word(arg(1),5)word(arg(1),7)
  jobhold =word(arg(1),11)
  if pos('AWAITING OUTPUT',arg(1))>0 then jobqueue='OUTPUT'
return jobname':'jobqueue':'jobhold
/* ---------------------------------------------------------------------
 * Request PDS Member List
 * ---------------------------------------------------------------------
 */
$PDSLIST:
  pds=upper(type)              /* 2. word in _data  */
  call setg('SG_SLIBSND',pds)
  if LISTDSI("'"pds"'")>0 then return 0
  liblst=screate(1500)
  call dir("'"pds"'")
  today=date('jdn')-60
  today=date('Standard',today,'JDN')
  __yy=substr(today,3,2)
  __mm=substr(today,5,2)
  __dd=substr(today,7,2)
  today=__yy'-'__mm'-'__dd'*'
  do i=1 to direntry.0
     if symbol('direntry.i.udate')='VAR' then ddate=direntry.i.udate
     else ddate=today
     if symbol('direntry.i.utime')='VAR' then dtime=direntry.i.utime
     else dtime='00:00:00'
     call sset(LIBLST,,dirEntry.i.name'&'Ddate'&'Dtime)
  end
  socket=_fd
  call writebuf LIBLST
  call SFREE LIBLST
return 0
/* ---------------------------------------------------------------------
 * Request LISTCAT
 * ---------------------------------------------------------------------
 */
$LISTCAT:
  LCAT=upper(type)             /* 2. word in _data  */
  call setg('SG_SLIBSND',LCAT)
  call arraygen('ON')
     ADDRESS TSO "LISTCAT LV("lcat")"
  lcatlst=arraygen('OFF')
  call sdrop(lcatlst,'IN-CAT')
  call SSUBSTR(lcatlst,17,,'INTERNAL')
  socket=_fd
  call writebuf LCATLST
  call SFREE LCATLST
return 0
/* ---------------------------------------------------------------------
 * Request RXRUN  rexx-script parms   REXX must return SARRAY number
 * ---------------------------------------------------------------------
 */
$RXRUN:
  signal on syntax name nofunc
  RXC=word(_data,2)
  RXp0=word(_data,3)     /* 1. Parameter is always level */
  RXp1=word(_data,4)     /* 2. Parameter */
  RXp2=word(_data,5)     /* 3. Parameter */
  RXp3=word(_data,6)     /* 4. Parameter */
  Interpret 'slist='rxc'(rxp0,rxp1,rxp2,rxp3)'
  socket=_fd
  call writebuf slist
  call SFREE slist
  signal off syntax
  return 0
nofunc:
  call TCPSENDX(_fd,'NOK REXX 'rxc' not present or failed',1)
  call xsay GETG('EMSG'),'REXX 'rxc' not present or failed'
  signal off syntax
return 0
/* ---------------------------------------------------------------------
 * JESGET request stored spool entry
 * ---------------------------------------------------------------------
 */
$JESGET:
   jobname=type /* 2. word in _data  */
   importname='JES2.'strip(translate(jobname,'. ','()'))
   ADDRESS TSO
     "OUTPUT "jobname" CLASS(H) PRINT("importname") KEEP HOLD"
   if rc=0 then do
       call TCPConfirm(_fd,'OK 'importname' FOR 'jobname' prepared')
       call transferdsn userid()'.'importname'.OUTLIST'
   end
   else do
      call TCPConfirm(_fd,'OK 'importname' prepared')
      if transferdsn(importname)=0 then call TCPSENDX(_fd,'OK transfer completed',1)
      else call TCPSend(socket,'NOK 'importname' transfer failed')
   end
return 0
/* ---------------------------------------------------------------------
 * RECEIVE request for DSN (server side)
 * ---------------------------------------------------------------------
 */
$RECEIVE:
   dsnname=type /* 2. word in _data  */
   if exists("'"dsnname"'")=0 then do
      call TCPSend(socket,'NOK 'dsnname' not present')
      call xsay GETG('EMSG'),dsnname' not present'
   end
   else do
      call TCPConfirm(_fd,'OK 'dsnname' prepared')
      if transferdsn(dsnname)=0 then call TCPSENDX(_fd,'OK transfer completed',1)
      else call TCPSend(socket,'NOK 'dsnname' transfer failed')
   end
return 0
/* ---------------------------------------------------------------------
 * SEND KEY/VALUE Record
 * ---------------------------------------------------------------------
 */
$KVSET:
   key=type   /* 2. word in _data  */
   record=subword(_data,3)
   call xsay GETG('IMSG'),'KEY/VALUE DB SET, Key 'key
   rc=DBSET(key,record)
   if rc=0 then call TCPSENDX(_fd,'OK record 'key' successfully added',1)
   else call TCPSENDX(_fd,'NOK record 'key' not added',1)
return 0
/* ---------------------------------------------------------------------
 * GET KEY/VALUE Record
 * ---------------------------------------------------------------------
 */
$KVGET:
   key=type   /* 2. word in _data  */
   call xsay GETG('IMSG'),'KEY/VALUE DB GET, Key 'key
   rc=DBGET(key)
   call TCPSENDX(_fd,'OK 'dbResult,1)
return 0
/* ---------------------------------------------------------------------
 * Connect to socket was requested
 *         arg(1): socket number
 * This is just an informal call. All TCP related activites are done.
 * you can for example maintain a list of users, etc.
 *     RC  0   proceed
 *     RC  4   cancel socket
 *     RC  8   stop server
 * ---------------------------------------------------------------------
 */
TCPconnect:
   parse arg socket
   senddsn=getg('SG_DSN')
   call wait 200
   dlen=TCPRECEIVEX(socket,2)
   if dlen<=0 then do
      call xsay GETG('EMSG'),'Handshake failed, socket closed'
      return 4
   end
   msgs='Connected to Stargate'!!crlf
   call xsay GETG('IMSG'),"Client(socket-"socket') connected in 'getg('SG_TCPTYPE')' mode, transfer mode 'getg('SG_TCPmode' )
   if word(_data,2)='SEND' & getg('SG_TCPMODE')='RECEIVE' then nop
   else if word(_data,2)='RECEIVE' & getg('SG_TCPMODE')='SEND' then nop
   else do
      call xsay GETG('EMSG'),'Requested Modes are not compatible '_data' / 'getg('SG_TCPMODE')
      call TCPSENDX(socket,'Requested Modes are not compatible '_data' / 'getg('SG_TCPMODE'),1)
      call wait 200
      return 4
   end
   call wait 200
   CALLER_IP=GETG('sg_tcpcaller')
   CALLEE_SOCKET=word(_data,3)
   CALLEE_IP     =word(_data,4)
   call SETG('SG_TCPCallee',CALLEE_IP)
   call TCPSENDX(socket,"$$$MODE OK "socket" "CALLER_IP,1)
   call xsay GETG('IMSG'),"Handshake successful, caller/callee socket "socket"/"CALLEE_SOCKET" IP "CALLER_IP'/'CALLEE_IP
   call wait 200
   if getg('SG_TCPTYPE')<>'PASV' then return 0 /* continue to run */
/* .... Passive mode  ....... */
   if sendCMD(senddsn,0)<0 then return -64
return 8     /* stop Server */
/* ---------------------------------------------------------------------
 * Sends Command and receive files if requested (client side)
 * ---------------------------------------------------------------------
 */
SendCMD:
  parse arg sdsn,socclose
  if sget(getg('SG_LOGON'),socket)='INACTIVE' then  return SessionClosed(socket)
  ww1=translate(word(sdsn,1))
  if ww1='$$$'              then return 0
  else if ww1='$$$KILLBILL' then if sendCheckReply(ww1)=-64 then return -64 ; else nop
  else if ww1='$$$SHUTDOWN' then if sendCheckReply(ww1)=-64 then return -64 ; else nop
  else if ww1='$$$SEND'     then if sendCheckReply(ww1)=-64 then return -64 ; else nop
  else if ww1='$$$LOGON'    then if sendCheckReply(ww1)=-64 then return -64 ; else nop
  else if ww1='$$$LINK'     then if sendCheckReply(ww1)=-64 then return -64 ; else nop
  else if ww1='$$$KVGET'    then if sendCheckReply(ww1)=-64 then return -64 ; else nop
  else if ww1='$$$KVSET'    then if sendCheckReply(ww1)=-64 then return -64 ; else nop
  else if ww1='$$$HEARTBEAT' then if sendCheckReply(ww1)=-64 then return -64 ; else nop
  else if ww1='$$$KILLBILL82061' then if sendCheckReply(ww1)=-64 then return -64 ; else nop
  else if ww1='$$$SPOOL'    then call #spool
  else if ww1='$$$PDSLIST'  then call #pdslist
  else if ww1='$$$LISTCAT'  then call #listcat
  else if ww1='$$$RXRUN'    then call #rxrun word(sdsn,3)  /* level clause is 3. word */
  else if ww1='$$$SUBMIT'   then call #submit
  else if ww1='$$$JESGET'   then call #receive
  else if ww1='$$$RECEIVE'  then call #receive
  else if ww1='$$$DELIVER'  then call transferDSN(word(sdsn,2))
  else call transferDSN(sdsn)

  if getg('sg_alive')=0 then call #goodbye
  if socclose=1 then return 0
  call TCPCLOSE(socket)
return 8     /* stop Server       */
/* ---------------------------------------------------------------------
 * SUBMIT Client side
 * ---------------------------------------------------------------------
 */
#SUBMIT:
  if sendCheckReply(ww1)=-64 then return -64
  call xsay "SUBMIT "_data
  call setg("submit_jobname",word(_data,5))
  call setg("submit_jobnum",word(_data,6))
return
/* ---------------------------------------------------------------------
 * SPOOL Client side
 * ---------------------------------------------------------------------
 */
#SPOOL:
  if sendCheckReply(ww1)=-64 then return -64
  if getg('SG_spool')>=0 then call sfree getg('SG_spool')
  sspool=screate(512)           /* up to 512 Entries */
  call setg('SG_spool',sspool)
  do until _data=''
     parse var _data jobname':'jobqueue':'jobhold';;'_data
     call sset(getg('SG_spool'),,left(jobname,20)' 'left(jobqueue,9)' 'jobhold)
  end
return
/* ---------------------------------------------------------------------
 * PDSLIST Client side
 * ---------------------------------------------------------------------
 */
#PDSLIST:
  pdsbuf=''
  stcp=getg('SG_TCPLIST')
  call TCPSENDX(socket,sdsn,1)
  call wait 50
  iwait=8
  do forever
     dlen=TCPRECEIVEX(socket,iwait)  /* number of Bytes */
     if dlen<=0 then leave
     if substr(_data,1,14)='OK EOF REACHED' then leave
     pdsbuf=pdsbuf||_data
     iwait=2
  end
  ppi=pos('OK EOF REACHED',pdsbuf)
  if ppi>1 then pdsbuf=substr(pdsbuf,1,ppi-1)
  if getg('SG_pdslist')>=0 then call sfree getg('SG_pdslist')
  pdslist=screate(2048)          /* up to 512 Entries */
  call setg('SG_pdslist',pdslist)
  do until pdsbuf=''
     parse var pdsbuf pdsmember'&'pdsdate'&'pdstime';;'pdsbuf
     call sset(getg('SG_pdslist'),,left(pdsmember,9)' 'left(pdsdate,9)' 'pdstime)
  end
  pdsbuf=''
return
/* ---------------------------------------------------------------------
 * LISTCAT Client side
 * RXRUN  generic call
 * ---------------------------------------------------------------------
 */
#LISTCAT:
#rxrun:
  parse arg level
  OUTBUF=''
  stcp=getg('SG_TCPLIST')
  call TCPSENDX(socket,sdsn,1)
  call wait 50
  iwait=60     /* use a long wait for large RXRUN preparation */
  do forever
     dlen=TCPRECEIVEX(socket,iwait)  /* number of Bytes */
     if dlen<=0 then leave
     eofi=pos('OK EOF REACHED',_data)
     if eofi>0 then do
        OUTBUF=OUTBUF||substr(_data,1,eofi-1)
        leave
     end
     OUTBUF=OUTBUF||_data
     iwait=2
  end
  if getg('SG_output'level)>=0 then call sfree getg('SG_output'level)
  listcat=screate(2048)          /* up to 2048 Entries */
  call setg('SG_output'level,listcat)
  do until OUTBUF=''
     parse var OUTBUF outline';;'OUTBUF
     call sset(getg('SG_output'level),,outline)
  end
  lcatbuf=''
return
/* ---------------------------------------------------------------------
 * Receive Client side, handles also JESGET
 * ---------------------------------------------------------------------
 */
#RECEIVE:
  if sendCheckReply(ww1)=-64 then return -64
  if word(_data,1)='OK' then do
     call TCPCONFIRM(socket,"GO Ahead",1)
     _fd=socket
     do forever
        receiveDSN=word(_data,3)
        if receiveDSN='' then leave
        call setg('SG_DSN',receiveDSN)   /* set target dsn */
        call checkcmd
        call TCPCONFIRM(socket,"$$$GETNEXT",1)  /* request next DSN, if there is any */
        if word(_data,1)='OK' & pos('transfer completed',_data)>0 then leave
        if word(_data,1)='NOK' then leave
     end
  end
  else call xsay GETG('EMSG'),'NO 'ww1' Confirmation received '_data
return
/* ---------------------------------------------------------------------
 * Send Good Bye to Server
 * ---------------------------------------------------------------------
 */
#GOODBYE:
  call xsay GETG('IMSG'),'Sending Good-bye to opponent(socket-'socket')'
  call TCPConfirm(socket,'$$$GOODBYE Good-bye transfer completed')
  if strip(_data)<>'' then call xsay GETG('IMSG'),'>> '_data /* Reply from Host */
  call TCPSENDX(socket,"$$$STOP",1)
  call wait 500
return
/* ---------------------------------------------------------------------
 * Send Request and check reply
 * ---------------------------------------------------------------------
 */
sendCheckReply:
  call TCPConfirm(socket,sdsn)
  call wait 200
  call xsay GETG('IMSG'),'Reply 'arg(1)': '_data
  if word(_data,1)='ABORT' then return SessionClosed(socket)
  else if word(_data,1)='QUIT' then return SessionClosed(socket)
return 0
/* ---------------------------------------------------------------------
 * Handle Request if client socket has been closed by Server
 * ---------------------------------------------------------------------
 */
SessionClosed:
   call xsay GETG('XMSG'),'Server cancelled Client session'
   call sset(getg('SG_LOGON'),arg(1),'INACTIVE')
   call TCPCLOSE(arg(1))
return -64
/* ---------------------------------------------------------------------
 * Time out occurred, here you can perform non TCP related work.
 * ---------------------------------------------------------------------
 */
TCPtimeout: procedure expose otime
  if datatype(otime) <>'NUM' then otime=time('s')
  if time('s')-otime<30 then return 0
  return 0
  call xsay GETG('IMSG'),'Timeout staying alive'
  TCALLER_IP=GETG('SG_TCPCALLER')
  TCALLEE_IP=GETG('SG_TCPCallee')
  alive=getg('sg_clientAlive')
  tcmode=getg('SG_TCPMODE')
  sgpw=271441
  sgQueue.1='$$$LOGON 'MVSVAR('SYSNAME')'.'STARGATE' 'sgpw
  sgQueue.2='$$$SEND PEJ Server Message for you, there is a timeout'
  sgQueue.0=2
  stargate_clientAlive=0  /* Do not keep server/server connection oprn */
  stargate_mslv=0    /* all messages in the beginning */
  rc=stargate('SEND','eitri.mike-grossmann.de',3205,'$$$QUEUE SGQUEUE.')
  call SETG('SG_TCPCALLER',TCALLER_IP)
  call SETG('SG_TCPCallee',TCALLEE_IP)
  call SETG('SG_TCPMode',tcmode)
  call setg('sg_clientAlive',alive)
  otime=time('s')
return 0     /* proceed normally  */
/* ---------------------------------------------------------------------
 * Close one client socket
 *         arg(1): socket number
 * This is just an informal call. The close has already be performed
 * you can for example update your list of users, etc.
 * ---------------------------------------------------------------------
 */
TCPcloseS: call xsay GETG('PMSG'),'Close Event 'arg(1)
  call sset(getg('SG_LOGON'),arg(1),'INACTIVE')
  if getg('sg_alive')=0 then return 8     /* stop Server       */
  call xsay GETG('PMSG'),'Client ended, Server continues, keep alive mode'
return 0     /* keep Server up and running */
/* ---------------------------------------------------------------------
 * Shut Down, application cleanup. TCP cleanup is done internally
 * This is just an informal call. The TCP shutdown has been performed
 * you can do a final cleanup, etc.
 * ---------------------------------------------------------------------
 */
TCPshutDown:
return
/* ---------------------------------------------------------------------
 * Transfer One File or Member
 * ---------------------------------------------------------------------
 */
transferDSN:
  parse upper arg file
  if word(file,1)='$$$DELIVER' then file=word(file,2)
  tfile=file  /* save original file name, in case it will be modified */
  tfiles=0    /* number of sent files */
  stotal=0    /* number of sent bytes */
  dcbf=getdcb("'"file"'")
  if dcbf='' then do
     call xsay GETG('WMSG'),file' not present, or accessible'
     call xsay GETG('EMSG'),'Sending file(s) failed, 'tfiles' transferred'
     return 8
  end
  if pos('(',file)>0 then do   /* Transfer just one PDS Member */
     dsorg='PS'
     file=translate(file,'. ','()')   /* Make member part of dsn */
     file=strip(file)
     ppx=pos(',DIRBLKS',dcbf)
     if ppx>2 then dcbf=left(dcbf,ppx-1)
  end
  if dsorg='PO' then buffer='$$$ADD PDS 'file' 'dcbf
     else buffer='$$$ADD FILE 'file' 'dcbf
  call TCPConfirm(socket,buffer)
  call xsay GETG('IMSG'),'Sending file(s) started'
  if dsorg='PO' then rc=writePDS(tfile)
  else rc=writeSEQ(tfile,'SEQ')
  call xsay GETG('IMSG'),'Sending file(s) completed, 'tfiles' transferred, 'stotal' bytes in total'
return 0
/* ---------------------------------------------------------------------
 * Fetch Spool Buffer
 * ---------------------------------------------------------------------
 */
SpoolBuffer:
  parse upper arg file
  call xsay GETG('IMSG'),'Receiving Spool Buffer started'
  rc=writeSEQ(tfile,'SEQ')
  call xsay GETG('IMSG'),'Receiving Spool Buffer completed'
return 0
/* ---------------------------------------------------------------------
 * Send an entire PDS
 * ---------------------------------------------------------------------
 */
writePDS:
  parse arg pfile
  call dir("'"pfile"'")
  do i=1 to direntry.0
     rc=writeMember(pfile,direntry.i.name)
     if rc=8 then leave
  end
return rc
/* ---------------------------------------------------------------------
 * Send a Member of the PDS
 * ---------------------------------------------------------------------
 */
writeMEMBER:
  parse arg tfile,tmember
  buffer='$$$ADD MEMBER 'tfile'('tmember') '
  call TCPConfirm(socket,buffer)
  rc=writeSEQ(tfile'('tmember')','PDS')
return rc
/* ---------------------------------------------------------------------
 * Send the sequential file or PDS Member
 * ---------------------------------------------------------------------
 */
writeSeq:
  parse arg sfile,mode
  stcp=getg('SG_TCPLIST')
  fk1=open("'"sfile"'",'RT')
  if fk1<0 then do
     call sset(STCP,,time('L')' 'sfile' not present')
     return 8
  end
  reci=0
  call wait(100)
  buftot=0
  do until eof(fk1)
      buffer=read(fk1,4000)  /* max TCP buffer is 4K */
      buflen=length(buffer)
      if buflen>0 then call TCPSENDX(socket,buffer,1)
      buftot=buftot+buflen
      reci=reci+1
      call wait(5)
  end
  call close(fk1)
  dlen=TCPRECEIVEX(socket,3)
  if dlen>0 & word(_data,1)<>'NOK' then do
     targetDSN=word(_data,2)
     call sset(STCP,,time('l')" Sending "sfile" completed ("buftot" bytes) "left(_data,40))
     call xsay GETG('IMSG'),"Sending +++ "sfile" completed ("buftot" bytes) "left(_data,40)
     tfiles=tfiles+1
     stotal=stotal+buftot
     call setg('SG_DSNTarget',targetdsn)
  end
  else do   /* bad or no transfer received, abort  */
     call sset(STCP,,time('l')" Sending "sfile" aborted "_data)
     call xsay GETG('IMSG'),"Sending *** "sfile" completed "left(_data,40)
     return 8
  end
return 0
/* ---------------------------------------------------------------------
 * Send internally created buffer
 * ---------------------------------------------------------------------
 */
writeBuf:
  parse arg sbuffer
  stcp=getg('SG_TCPLIST')
  reci=0
  call wait(100)
  buftot=0
  spoolbuffer=''
  do si=1 to sarray(sbuffer)
     buffer=sget(sbuffer,si)
     if buffer='' then iterate
     buflen=length(buffer)
     if si=1 then spoolbuffer=buffer
     else spoolbuffer=Spoolbuffer';;'buffer
     buftot=buftot+buflen
     reci=reci+1
  end
  spoollen=length(spoolbuffer)
  if spoollen<4000 then call TCPSENDX(socket,spoolbuffer,1)
  else do until spoollen<=0
     buffers=left(spoolbuffer,4000)
     call TCPSENDX(socket,buffers,1)
     spoolbuffer=substr(spoolbuffer,4001)
     spoollen=length(spoolbuffer)
     call wait(5)
  end
  call TCPSENDX(socket,'OK EOF REACHED',1)
  spoolbuffer=''
  buffers=''
  if dlen>0 & word(_data,1)<>'NOK' then do
     call sset(STCP,,time('l')" Sending SARRAY "sbuffer" completed ("buftot" bytes): "left(_data,40))
     call xsay GETG('IMSG'),"Sending SARRAY +++ "sbuffer" completed ("buftot" bytes): "left(_data,40)
  end
  else do   /* bad or no transfer received, abort  */
     call sset(STCP,,time('l')" Sending SARRAY "sbuffer" aborted "_data)
     call xsay GETG('IMSG'),"Sending SARRAY *** "sbuffer" completed "left(_data,40)
     return 8
  end
return 0
/* ---------------------------------------------------------------------
 * TCPSENDX DEBUG
 * ---------------------------------------------------------------------
 */
TCPSENDX:
  if GETG('SG_DEBUG')=1 then do
     call sset(STCP,,time('l')' TCPSEND')
     call sset(STCP,,'    TCP token 'arg(1))
     call sset(STCP,,'    Buffer    'substr(arg(2),1,32))
     call sset(STCP,,'    Timeout   'arg(3))
  end
  rc=TCPSEND(arg(1),arg(2),arg(3))
  if GETG('SG_DEBUG')=1 then call sset(STCP,,' rc 'rc)
return rc
/* ---------------------------------------------------------------------
 * TCPRECEIVE debug
 * ---------------------------------------------------------------------
 */
TCPRECEIVEX:
  stcp=getg('SG_TCPLIST')
  if GETG('SG_DEBUG')=1 then do
     call sset(STCP,,time('l')' TCPRECEIVE')
     call sset(STCP,,'    TCP token 'arg(1))
     call sset(STCP,,'    Timeout   'arg(2))
  end
  rc=TCPRECEIVE(arg(1),arg(2))
  if GETG('SG_DEBUG')=1 then do
     call sset(STCP,,'    Data Rec  'left(_data,40))
     call sset(STCP,,'    Length    'rc)
  end
return rc
/* ---------------------------------------------------------------------
 * TCPSENDX with request of confirmation
 * ---------------------------------------------------------------------
 */
TCPConfirm:
  stcp=getg('SG_TCPLIST')
  if GETG('SG_DEBUG')=1 then do
     call sset(STCP,,' ')
     call sset(STCP,,time('l')' +++ TCP Handshake')
  end
  call TCPSENDX(arg(1),arg(2),1)
  dlen=TCPRECEIVEX(arg(1),3)
  if GETG('SG_DEBUG')=1 then do
     call sset(STCP,,time('l')' --- TCP Reply 'left(_data,40))
     call sset(STCP,,' ')
  end
return _data
/* ---------------------------------------------------------------------
 * SAY Command
 *     MSLV BASIC  /* mslv=0 */
 *          IMSG   /* mslv=4 */
 *          WMSG   /* mslv=8 */
 *          EMSG   /* mslv=16 */
 * ---------------------------------------------------------------------
 */
xsay:
  parse arg mslv,mstx
  if mslv<getg('SG_MSLV') then return
  saymsg=left(time('l') getg('MSGT.'mslv)' 'mstx,getg('SG_SCRWIDTH')-1)
  if getg('SG_BATCH')=1 then say saymsg
  else do
    if getg('SG_NOPRINT')=0 & getg('SG_SCRLINC')>=getg('SG_SCRHEIGHT')-5 then do
       Say '******* To avoid Screen overflow subsequent messages will be suppressed'
       call setg('SG_NOPRINT',1)
    end
    call sset(getg('SG_STOUT'),,time('l') getg('MSGT.'mslv) mstx)
    call setg('SG_SCRLINC',getg('SG_SCRLINC')+1)
    if getg('SG_NOPRINT')=0 then say saymsg
  end
return
/* ---------------------------------------------------------------------
 * Build the DCB of a DSN
 * ---------------------------------------------------------------------
 */
getdcb: procedure expose dsorg
  if LISTDSIX(arg(1))>0 then return ''
  dcb1='RECFM='SYSRECFM',LRECL='SYSLRECL',BLKSIZE='SYSBLKSIZE
  if SYSDSORG='PO' & SYSDIRBLK='n/a' then do   /* It is a single Member out of a PDS */
     lsize=SYSsize%16000+1  /* assume max recsize 16000, it's wrong anyway */
     dcb2=',UNIT=SYSDA,PRI='lsize',SEC='lsize%2+1
  end
  else do
     dcb2=',UNIT=SYSDA,PRI='SYSTRACKS',SEC='SYSTRACKS%3+1
     if sysdsorg='PO' then dcb2=dcb2',DIRBLKS='SYSDIRBLK
  end
  dsorg=sysdsorg
return dcb1''dcb2
/*   */
/* ------------------------------------------------------------
 * Determine IP Address of 3270 Terminal Session
 * ------------------------------------------------------------
 */
myIPADDR: procedure
  ipaddr=''
  call privilege('on')
  CALL ARRAYGEN('ON')
    ADDRESS COMMAND 'CP DEVLIST'
  S1=ARRAYGEN('OFF')
  call privilege('off')
  S2=sselect(s1,'3270')
  call sfree(s1)
  do i=1 to sarray(s2)
     ipi=pos('3270',sget(s2,i))
     xipaddr=word(substr(sget(s2,i),ipi+4),1)
     if words(translate(xipaddr,,'.'))<4 then iterate
     ipaddr=xipaddr
  end
  call sfree(s2)
return ipaddr
/* ---------------------------------------------------------------------
 * Init Stargate
 * ---------------------------------------------------------------------
 */
starinit:
  if getg('SG_TCPLIST')  ='' then stcp=screate(5000)
  if getg('SG_stout')='' then stout=screate(7500)
  if getg('SG_logon')='' then slogon=screate(512)           /* up to 255 users   */
  if getg('SG_TCPLIST')  ='' then call setg('SG_TCPLIST',stcp)
  if getg('SG_logon')='' then call setg('SG_LOGON',slogon)
  if getg('SG_stout')='' then call setg('SG_STOUT',stout)
  call setg('sg_tcpcallee',tcp)
  call setg('SG_PORT',port)
  call setg('SG_TCPCALLER',myIPADDR())
  call setg('SG_DSN',senddsn)
  call setg('SG_SERVER',0)
  call setg('SG_DEBUG',1)
  if symbol('stargate_mslv')='VAR' then call setg('SG_MSLV',stargate_mslv)
     else call setg('SG_MSLV',0)
  call setg('SG_BATCH',batch)
  call setg('XMSG',1)   /* mslv 1 system information */
  call setg('IMSG',2)   /* mslv 2 information */
  call setg('WMSG',3)   /* mslv 3 warning */
  call setg('EMSG',4)   /* mslv 4 error   */
  call setg('PMSG',5)   /* mslv 5 pointless information */
  call setg('MSGT.1','..ESSNT')   /* mslv 1 system information */
  call setg('MSGT.2','  INFO ')   /* mslv 2 information */
  call setg('MSGT.3','**WARN ')   /* mslv 3 warning */
  call setg('MSGT.4','++ERROR')   /* mslv=4 error   */
  call setg('MSGT.5','  INFO ')   /* mslv 5 poinless information */
  call setg('SG_NOPRINT',0)
  call IMPORT FSSAPI
  ADDRESS FSS
    call fssinit
    call setg('SG_SCRHEIGHT',fssheight())
    call setg('SG_SCRWIDTH',fsswidth())
    call setg('SG_SCRLINC',0)
/*  ADDRESS TSO
    'CLS'  */
  call setg('sg_clientSocket',-1) /* default socket to -1 for later use */
  if symbol('stargate_clientAlive')='LIT' ,
     then call setg('sg_clientAlive',0) /*keep client alive */
  else do
     if stargate_clientAlive=1  ,
        then call setg('sg_clientAlive',1)  /* Keep client alive  */
     else call setg('sg_clientAlive',0)     /* Stop client at end */
  end
  if symbol('stargate_keepAlive')='LIT' then call setg('sg_alive',1) /* keep Server alive at end of transaction */
  else do
     if stargate_keepAlive=1 then call setg('sg_alive',1)            /* Keep server session alive        */
     else call setg('SG_ALIVE',0)                                    /* End server at end of transaction */
  end
  rc=8
return
