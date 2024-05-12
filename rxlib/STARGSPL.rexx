  call SGFSSini
  socket=getg('sg_clientSocket')
  stargate_mslv=0    /* all messages in the beginning */
  rc=stargate('SEND',"$$$SOCKET",socket,'$$$SPOOL')
  spool=getg('SG_spool')
  buffer.0='ARRAY 'spool
  _screen.TopRow=2
  _screen.TopRow.proc='spoolhdr'
  _screen.footer='Line cmd S request Job Output'
  call FMTLIST ,,'Spool Queue of Server 'ipaddr,
    'Job Name             QUEUE   STATUS','Spool'
return
spoolhdr:
  call fsstext('View Spool Queue of Server 'getg('SG_IPADDR'),1,20,,#white)
return
spool_s:
  signal off syntax   /* to avoid any error handling of FMTLIST */
  socket=getg('sg_clientSocket')
  job=word(arg(1),1)
  stargate_mslv=0    /* all messages in the beginning */
  rc=stargate('SEND',"$$$SOCKET",socket,'$$$JESGET 'job)
  spooldsn=getg('SG_RECEIVED_DSN')
  sspool=sread("'"spooldsn"'")
  if sspool<0 then do
     zerrsm='no Output'
     zerrlm='for job 'job' no output received'
     return 0
  end
  buffer.0='ARRAY 'sspool
  call fmtlist
  call sfree sspool
return 0
