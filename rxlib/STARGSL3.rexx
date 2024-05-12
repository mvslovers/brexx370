 call SGFSSini
 slino=5
  do forever
    ADDRESS FSS
    'RESET'
     CALL FSSTITLE 'Stargate Compare Server/Client PDSes',#WHITE
     call fsstext('Compare PDS Timestamps Server/Local 'getg('SG_IPADDR'),3,
                  7,,#white)
     nxt =sgfield("PDSS", "PDS Dataset ===>",slino,3,54)
     call fsstext('Local PDS',slino+2,5,,#white)
     nxt =sgfield("PDSL", "PDS Dataset ===>",slino+3,3,54)
     call fssmessage FSSHeight()-1
     call fsscursor("PDSS")
     call fssdisplay()
    'GET AID AID'
     if aid=243 | aid=244 then return 4
     call SGfetchVars
     if PDS='' then iterate
     stargate_mslv=4
     selected=listHshpds(pdsS)
     if selected='' then iterate
  end
return 0
ListHshPDS:
  signal off syntax
  pds=upper(arg(1))
  file=word(arg(1),1)
  socket=getg('sg_clientSocket')
  rc=stargate('SEND',"$$$SOCKET",socket,'$$$PDSLIST 'pds)
/*                                            Level number x      */
/*         Level number x ---------------------------------x      */
  pdsdet=getg('SG_pdslist')
  call dir("'"pdsl"'")
  stem0=STEMtoArray()
  call slist pdsdet
  call slist stem0
  today=date('jdn')-60
  today=date('Standard',today,'JDN')
  __yy=substr(today,3,2)
  __mm=substr(today,5,2)
  __dd=substr(today,7,2)
  today=__yy'-'__mm'-'__dd'*'
  pdsres=screate(PDSDET)
  do i=1 to sarray(PDSDET)
     xline=sget(pdsdet,i)
     member=word(xline,1)
     __itimst=subword(xline,2)
     __idate=word(xline,2)
     __itime=word(xline,3)
     call _stsearch(stem0,member)
     if __ddate='' then trx='  >> to client'
     else if __itimst<>__dtimst then trx='  ++ check'
     else trx=''
     call sset(PDSres,,left(member,10)left(__idate,11)' 'left(__itime,10)||,
              '  'left(__ddate,11)' 'left(__dtime,10)'  'trx)
  end
  do i=1 to sarray(stem0)
     member=sget(stem0,i)
     if member='' then iterate
     __idate=''
     __itime=''
     if symbol('direntry.i.udate')='VAR' then __DDATE=direntry.i.udate
     else __DDATE=today
     if symbol('direntry.I.utime')='VAR' then __DTIME=direntry.I.utime
     else __DTIME='00:00:00'
     trx='  << to server'
     call sset(PDSres,,left(member,10)left(__idate,11)' 'left(__itime,10)||,
              '  '||,left(__ddate,11)' 'left(__dtime,10)'  'trx)
  end
  buffer.0='ARRAY 'PDSres
  _screen.TopRow=2
  _screen.TopRow.proc='lhshhdr'
  hdr1='Member    Server Timestamp        Client Timestamp'
  call FMTLIST ,,hdr1
  pdsdet=getg('SG_pdslist')
  call sfree(pdsdet)
  zerrsm='Details received'
  zerrlm='Dataset 'file' details received from Server'
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
lhshhdr:
  call fsstext('View PDS Timestamps Server/Client 'getg('SG_IPADDR'),1,20,,
              #white)
return
_stsearch:
  parse arg parray,xmember
  __ddate=''
  __dtime=''
  ssi=ssearch(parray,xmember)
  if ssi=0 then return 4
  call sset(parray,ssi,'')
  if symbol('direntry.ssi.udate')='VAR' then __DDATE=direntry.SSI.udate
  else __DDATE=today
  if symbol('direntry.SSI.utime')='VAR' then __DTIME=direntry.SSI.utime
  else __DTIME='00:00:00'
  __dtimst=__ddate'  '__dtime
return 0
stemTOArray:
  axn=screate(direntry.0)
  do __i=1 to direntry.0
     call sset(axn,,direntry.__i.name)
  end
return axn
