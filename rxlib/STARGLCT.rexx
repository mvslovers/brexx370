 call SGFSSini
 slino=5
  do forever
    ADDRESS FSS
    'RESET'
     CALL FSSTITLE 'Stargate ListCat from Server ',#WHITE
     call fsstext('Show LISTCAT received from Server 'getg('SG_IPADDR'),3,7,,
                  #white)
     nxt =sgfield("LCAT", "LISTCAT Prefix ===>",slino,3,54)
     call fsstext('"You get it all"',18,25,,#white)
     call fssmessage FSSHeight()-1
     call fsscursor("LCAT")
     call fssdisplay()
    'GET AID AID'
     if aid=243 | aid=244 then return 4
     call SGfetchVars
     if LCAT='' then iterate
     stargate_mslv=4
     selected=listRLCAT(LCAT)
     if selected='' then iterate
  end
return 0
ListRLCAT:
  LCAT=upper(arg(1))
  call setg('SG_SLIBSND',LCAT)
  socket=getg('sg_clientSocket')
  stargate_mslv=0    /* all messages in the beginning */
  rc=stargate('SEND',"$$$SOCKET",socket,'$$$LISTCAT 'LCAT)
  LCATlist=getg('SG_output')
  call sqsort(LCATLIST)
  buffer.0='ARRAY 'LCATlist
  _screen.TopRow=2
  _screen.TopRow.proc='lcathdr'
  _screen.footer='Line cmd S request Job Output'
  call FMTLIST ,,'LISTCAT List of 'LCAT' from 'ipaddr,'Member','lcatlist'
lcathdr:
  call fsstext('Select ListCat entry to be sent to 'getg('SG_IPADDR'),1,20,,
                #white)
return 0
lcatlist_s:
  signal off syntax
  LCATlist=getg('SG_output')
  file=word(arg(1),1)
  socket=getg('sg_clientSocket')
  /* create level 1 output */
  rc=stargate('SEND',"$$$SOCKET",socket,'$$$RXRUN SGLDSI 1 'file) 
  LCATdet=getg('SG_output1')
  buffer.0='ARRAY 'LCATdet
  _screen.TopRow=2
  _screen.TopRow.proc='ldethdr'
  call FMTLIST ,,'Details of 'file
  LCATdet=getg('SG_output1')
  call sfree(lcatdet)
  zerrsm='Details received'
  zerrlm='Dataset 'file' details received from Server'
return 0
ldethdr:
  call fsstext('View Details of Dataset at Server 'getg('SG_IPADDR'),1,20,,
                #white)
return
