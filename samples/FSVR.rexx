/* ---------------------------------------------------------------------
 * FILE Server
 * ---------------------------------------------------------------------
 */
if FILEinit()=8 then exit 8
/* ---------------------------------------------------------------------
 * Handle WEB Requests
 * ---------------------------------------------------------------------
 */
do forever
    event = tcpwait(2)
    select
        when event = #receive then do
             bytes = tcpreceive(_fd); /* received data are in _DATA */
             crc=checkdata()
             if crc=128 then leave
             if crc>0   then iterate
             call tcpsend(_fd,reply)
        end
        when event = #stop  then signal opStop
        when event = #error then signal tcpError
    end
end
signal opStop
/* ---------------------------------------------------------------------
 * Handle Errors or STOP commands from Console
 * ---------------------------------------------------------------------
 */
opStop:
  call wto "FILE Server will be stopped"
  exc=0
  signal svrClose
tcpError:
  call wto "FILE Server got an error event"
  exc=event
  signal svrClose
/* ---------------------------------------------------------------------
 * Get and Check Input
 * ---------------------------------------------------------------------
 */
checkdata:
  func=strip(substr(_data,1,4))
  data=substr(_data,5)
  if func='SEND' then do
     tdsn=data
     say 'Sending Data to 'tdsn
     fk=open('TEmp.EXChange',"WT,recfm=vb,lrecl=512,blksize=5120,
             ,unit=sysda,pri=5,sec=5")
     if fk>0 then reply='OK'
        else reply='NOK'
  end
  else if func='RECV' then do
     say 'Receiving Data from 'data
     fk=open(data,"RT")
     if fk>0 then reply='OK'
        else reply='NOK'
  end
  else if func='PUT' & fk>0 then do
        call write(fk,data,'nl')
        Reply='OK '
  end
  else if func='GET' & fk>0 then do
        if eof(fk) then do
           reply='EOF'read(fk)
           call close fk
           fk=0
        end
        else reply='OK 'read(fk)
  end
  else if func='EOF' & fk>0 then do
       call close fk
       fk=0
       if dsncopy('temp.exchange',tdsn,'R')=0 then reply='OK'
       if reply='OK' then if remove('temp.exchange')=0 then reply='OK'
                          else reply='NOK'
       else reply='NOK'
  end
  else Reply='NOK'
  say func': 'reply
return 0
/* ---------------------------------------------------------------------
 * Shutdown FILE Server
 * ---------------------------------------------------------------------
 */
svrClose:
  call wto 'FILE SERVER Receive Events '_$server.evenr
  CALL TCPTerm()
  call wto 'FILE SERVER has been stopped, rc='exc
  say 'FILE SERVER has been stopped, rc='exc
exit exc
/* ---------------------------------------------------------------------
 * Init FILE Server
 * ---------------------------------------------------------------------
 */
fileinit:
  call tcpinit()
  _port=4711
  ret = tcpserve(_port)
  if ret=0 then call wto 'FILE SERVER started, port '_port
     else call wto 'FILE SERVER failed to start, rc='ret
  if ret=0 then say 'FILE SERVER started, port '_port
     else say 'FILE SERVER failed to start, rc='ret
return 0
