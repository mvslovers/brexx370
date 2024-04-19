  call SGFSSini
  socket=getg('sg_clientSocket')
  stargate_mslv=0    /* all messages in the beginning */
  rc=stargate('SEND',"$$$SOCKET",socket,'$$$RXRUN SGSYS1')
  outbuf=getg('SG_OUTPUT')
  buffer.0='ARRAY 'outbuf
  _screen.TopRow=2
  _screen.TopRow.proc='syshdr'
  call FMTLIST ,,'System Information of 'ipaddr
return
syshdr:
  call fsstext('System Information of Server 'getg('SG_IPADDR'),1,20,,#white)
return
