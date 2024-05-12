 call SGFSSini
 slino=5
  do forever
    ADDRESS FSS
    'RESET'
     CALL FSSTITLE 'Stargate Select PDS Member from Server ',#WHITE
     call fsstext('PDS Member(s) are received from Server 'getg('SG_IPADDR'),3,
                  7,,#white)
     nxt =sgfield("PDS", "PDS Dataset ===>",slino,3,54)
     call fsstext('Select the member(s) from the retrieved member list',
                  slino+2,3,,#white)
     call fsstext('"You get it all"',18,25,,#white)
     call fssmessage FSSHeight()-1
     call fsscursor("PDS")
     call fssdisplay()
    'GET AID AID'
     if aid=243 | aid=244 then return 4
     call SGfetchVars
     if PDS='' then iterate
     stargate_mslv=4
     selected=listRpds(pds)
     if selected='' then iterate
  end
return 0
ListRPDS:
  pds=upper(arg(1))
  call setg('SG_SLIBSND',pds)
  socket=getg('sg_clientSocket')
  stargate_mslv=0    /* all messages in the beginning */
  rc=stargate('SEND',"$$$SOCKET",socket,'$$$PDSLIST 'pds)
  pdslist=getg('SG_pdslist')
  call sqsort(pdslist,'DESC',10)
  buffer.0='ARRAY 'pdslist
  _screen.TopRow=2
  _screen.TopRow.proc='pdshdr'
  _screen.footer='Line cmd S request Job Output'
  call FMTLIST ,,'PDS Member List of 'ipaddr,
      'Member    Date      Time (date sorted)','pdslist'
pdshdr:
  call fsstext('Select PDS Member to be sent to 'getg('SG_IPADDR'),1,
              20,,#white)
return 0
pdslist_s:
  signal off syntax
  pds=getg('SG_SLIBSND')
  member=word(arg(1),1)
  socket=getg('sg_clientSocket')
  rc=stargate('SEND',"$$$SOCKET",socket,'$$$RECEIVE 'pds'('member')')
  zerrsm='Member received'
  zerrlm='PDS Member 'member' received from Server'
return 0
return
pdshdr:
  call fsstext('View PDS of Server 'getg('SG_IPADDR'),1,20,,#white)
return
