 call SGFSSini
 slino=5
  do forever
    ADDRESS FSS
    'RESET'
     CALL FSSTITLE 'Stargate Submit Job to Server ',#WHITE
     call fsstext('Job is sent to Server 'getg('SG_IPADDR'),3,7,,#white)
     nxt =sgfield("JCL", "JCL Dataset ===>",slino,3,54)
     call fsstext('sending  just "Do It Again"',18,25,,#white)
     call fssmessage FSSHeight()-1
     call fsscursor("JCL")
     call fssdisplay()
    'GET AID AID'
     if aid=243 | aid=244 then return 4
     call SGfetchVars
     if JCL='' then iterate
     stargate_mslv=4
     selected=listpds(jcl)
     if selected='' then iterate
  end
return 0
ListPDS:
  jcl=upper(arg(1))
  call setg('SG_JCLSUB',jcl)
  if LISTDSIX("'"jcl"'")>0 then return
  /* it is a single Member out of a PDS */
  if SYSDSORG='PO' & SYSDIRBLK='n/a' then NOP   
  else do
     liblst=screate(500)
     call dir("'"jcl"'")
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
     _screen.TopRow.proc='jclhdr'
     _screen.footer='Line cmd S to select JCL Member'
     _screen.Message=1
     call FMTLIST ,,'JCL Members of 'jcl,
            'NAME      CHANGED (sorted by change date)','JCL'
     call sfree(LIBLST)
  end
return 0
jclhdr:
  call fsstext('Select JCL Member to be sent and submitted to '||,
               getg('SG_IPADDR'),1,20,,#white)
return
jcl_s:
  signal off syntax
  socket=getg('sg_clientSocket')
  jcl   =getg('sg_JCLSUB')
  rc=stargate('SEND',"$$$SOCKET",socket,'$$$DELIVER 'jcl'('word(arg(1),1)')')
  subdsn=getg('SG_DSNTarget')
  if subdsn='' then return 0
  rc=stargate('SEND',"$$$SOCKET",socket,'$$$SUBMIT 'subdsn)
  zerrsm='JCL Submitted'
  zerrlm='JOB 'getg("submit_jobname")'('getg("submit_jobnum")') Submitted'
return 0
