/* ---------------------------------------------------------------------
 * TCP Server Facility
 *     This is the generic TCP Server module which handles all events
 *     The user specific handling of the events is performed
 *     by a call-back to the calling REXX
 *         connect
 *         receive
 *         close
 *         stop
 * ---------------------------------------------------------------------
 */
tcpsf:
  parse arg port,timeout,svrname,MSLV
  if timeout=''  then timeout=60
  if svrname='' then svrname='DUMMY'
  if mslv='' then mslv=0
  else if mslv='NOMSG' then mslv=12
  else if mslv='ERROR' then mslv=8
  else if mslv='WARN'  then mslv=4
  else if mslv='INFO'  then mslv=0
  tcpmsg.0='..BASIC'
  tcpmsg.1='  INFO '
  tcpmsg.4='**WARN '
  tcpmsg.8='++ERROR'
  maxrc=0
  tcpstarted=0
  if datatype(port)<>'NUM' then do
     call _#SVRMSG 8,"Port Number missing or invalid "port
     return 8
  end
  call tcpinit()
  call _#SVRMSG 0,'TCP Server start at Port: 'port
  call _#SVRMSG 1,'TCP Time out set to     : 'timeout' seconds'
  rc=tcpserve(port)
  if rc <> 0 then do
     tcpstarted=1
     call _#SVRMSG 8,"TCP Server start ended with rc: "rc
     return 8
  end
  call _#SVRMSG 1,'TCP Server has been started'
  if nomsg=0 then call wto 'TCP Server has been started, port 'port
  call eventhandler
  call _#SVRMSG 1,"TCP Server will be closed"
  if tcpStarted=1 then call tcpTerm()
  call _#SVRMSG 1,"TCP Server has been closed"
  if nomsg=0 then call wto 'TCP Server 'svrname' has been closed, port 'port
return 0
/* ---------------------------------------------------------------------
 * TCP Event Handler
 * ---------------------------------------------------------------------
 */
EventHandler:
  stopServer=0
  do forever
     event = tcpwait(timeout)
     if event <= 0 then call eventerror event
     select
        when event = #receive then call _#receive _fd
        when event = #connect then call _#connect _fd
        when event = #timeout then call _#timeout
        when event = #close   then call _#close _fd
        when event = #stop    then leave
        when event = #error   then call eventError
        otherwise  call eventError
     end
     if stopServer=1 then leave
  end
  call _#stop     /* is /F console cmd */
return
/* ---------------------------------------------------------------------
 * Time out
 * ---------------------------------------------------------------------
 */
_#timeout:
  parse arg #fd
  newtimeout=0
  rrc=TCPtimeout()
  if datatype(newtimeout)='NUM' & newtimeout>0 then do
     timeout=newtimeout
     call _#SVRMSG 1,'Timeout set to 'timeout
     if nomsg=0 then call wto 'Timeout set to 'timeout
  end
  if rrc=0 then return 0
  if rrc=8 then stopServer=1
return 0
/* ---------------------------------------------------------------------
 * Connect
 * ---------------------------------------------------------------------
 */
_#connect:
  parse arg #fd
  rrc=TCPconnect(#fd)
  if rrc=0 then return 0
  if rrc=4 then call _#close #fd
  if rrc=8 then stopServer=1
return 0
/* ---------------------------------------------------------------------
 * Receive Input
 * ---------------------------------------------------------------------
 */
_#receive:
  parse arg #fd
  dlen=TCPReceive(#fd)   /* Anzahl Byte */
  adata=a2e(_data)
/*  call _#SVRMSG 1,'Data from Client ' */
  if pos('/CANCEL',_data)>0 then StopServer=1 /* shut down server */
  if pos('/CANCEL',adata)>0 then StopServer=1 /* shut down server */
  if pos('/QUIT',_data)>0 | pos('/QUIT',adata)>0 then do
     call _#close #fd
     return 0
  end
  newtimeout=0
  rrc=TCPData(#fd,_data,adata)
  if datatype(newtimeout)='NUM' & newtimeout>0 then do
     timeout=newtimeout
     call _#SVRMSG 1,'Timeout set to 'timeout
     if nomsg=0 then call wto 'Timeout set to 'timeout
  end
  if rrc=0 then return 0
  if rrc=4 then call _#close #fd
  if rrc=8 then stopServer=1
return 0
/* ---------------------------------------------------------------------
 * Close Client
 * ---------------------------------------------------------------------
 */
_#close:
  parse arg #fd
  call _#SVRMSG 1,"close event from client Socket "#fd
  if tcpclose(#fd)=0 then call _#SVRMSG 1,"Client Socket "#fd" closed"
     else call _#SVRMSG 8,"Client Socket "#fd" can't be closed"
  rrc=TCPcloseS(#fd)   /* handle socket close  */
  if rrc=0 then return 0
  if rrc=8 then stopServer=1
return 0
/* ---------------------------------------------------------------------
 * Shut Down
 * ---------------------------------------------------------------------
 */
_#stop:
  call _#SVRMSG 1,"shut down event from client Socket "_fd
  call tcpTerm()
  call TCPshutdown   /* User's shut down processing */
return
/* ---------------------------------------------------------------------
 * Event Error
 * ---------------------------------------------------------------------
 */
eventError:
  if arg(1)<>'' then CALL _#SVRMSG 8,"TCPWait() error: "event
  else CALL _#SVRMSG 8,'TCP error: 'event
  call tcpTerm()
return 8
/* ---------------------------------------------------------------------
 * Set Message and Error Code
 * ---------------------------------------------------------------------
 */
_#SVRMSG:
parse arg _mslv
  if _mslv>=mslv | _mslv=0 then do           /* 0 is essential message */
     if _FD='_FD' then _fd=' '
     say time('L')' 'tcpmsg._mslv' 'port' 'right(_fd,4)' 'svrname' 'arg(2)
  end
  if _mslv>maxrc then maxrc=_mslv
return _mslv
