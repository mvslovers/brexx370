 call SGFSSini
 slino=5
  do forever
    ADDRESS FSS
    'RESET'
     CALL FSSTITLE 'Stargate Select Member and send it to Server',#WHITE
     call fsstext('PDS Member(s) are sent to Server 'getg('SG_IPADDR'),3,7,,#white)
     nxt =sgfield("PDS", "PDS Dataset ===>",slino,3,54)
     call fsstext('Select the member(s) to send from the created member list',slino+2,3,,#white)
     call fsstext('"You get it all"',18,25,,#white)
     call fssmessage FSSHeight()-1
     call fsscursor("PDS")
     call fssdisplay()
    'GET AID AID'
     if aid=243 | aid=244 then return 4
     call SGfetchVars
     if pds='' then iterate
     stargate_mslv=4
     selected=listSpds(pds)
     if selected='' then iterate
  end
return 0
ListSPDS:
  pds=upper(arg(1))
  call setg('SG_SLIBSND',pds)
  if LISTDSI("'"pds"'")>0 then return
  if SYSDSORG='PO' & SYSDIRBLK='n/a' then NOP   /* it is a single Member out of a PDS */
  else do
     liblst=screate(500)
     call dir("'"pds"'")
     do i=1 to direntry.0
        if symbol('direntry.i.udate')='VAR' then ddate=direntry.i.udate
        else ddate=''
        if symbol('direntry.i.utime')='VAR' then dtime=direntry.i.utime
        else dtime=''
        call sset(LIBLST,,left(dirEntry.i.name,10)left(Ddate,10)left(Dtime,10))
     end
     call sqsort LIBLST,'DESC',10
     buffer.0='ARRAY 'LIBLST
     _screen.TopRow=2
     _screen.TopRow.proc='pdshdr'
     _screen.footer='Line cmd S to select PDS Member to be sent'
     _screen.Message=1
     call FMTLIST ,,'Source Members of 'pds,'NAME      CHANGED (sorted by change date)','pdslib'
     call sfree(LIBLST)
  end
return 0
pdshdr:
  call fsstext('Select PDS Member to be sent to 'getg('SG_IPADDR'),1,20,,#white)
return
pdslib_s:
  signal off syntax
  pds=getg('SG_SLIBSND')
  member=word(arg(1),1)
  socket=getg('sg_clientSocket')
  rc=stargate('SEND',"$$$SOCKET",socket,'$$$DELIVER 'pds'('member')')
  zerrsm='Member sent'
  zerrlm='PDS Member 'mmber' sent to Server'
return 0
