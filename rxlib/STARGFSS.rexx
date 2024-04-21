  call TCPINIT
  call SGFSSini()
  do forever
     if stargScreen()=4 then leave
     call DisplayMenu
     histchecked=1
  end
  call TCPTERM     /* Shutdown all open Connections */
return
/* ------------------------------------------------------------
 * Define and display Connect Screen
 * ------------------------------------------------------------
 */
stargScreen:
  xref.0=0
  if mserror<>'' then do
     lerror=mlerror
     serror=mserror
  end
  else do
     lerror=''
     serror=''
  end
  reuse =0
  ADDRESS FSS
  do forever
     call stargfssDefine
     call fssdisplay()
    'GET AID AID'
     lerror=''
     serror=''
     reuse=0
     if aid=243 | aid=244 then return 4
     if aid=245 then do               /* refresh of active servers requested */
        histchecked=0
        iterate
     end
     if SGfetchVars(1)>0 then iterate /* fetch variables, if select change just display */
     if IPADDR<>'' & port<>'' & sgpw<>'' then leave
     call missingAttributes
  end
return 0
/* ------------------------------------------------------------
 * Define Connect Screen
 * ------------------------------------------------------------
 */
stargfssDefine:
  slino=5
 'RESET'
  call fsstext('Select the Server to connect to, it must be ACTIVE',3,10,,#white)
  rtitle=' IP 3270 Session 'myIP
  title=center(' Stargate ',width,'-')
  title=overlay(rtitle,title,width-length(rtitle))
  CALL FSSTITLE title,#WHITE
  hlino=checkHistory(reuse,slino+4)       /* check active IPs first */
  nxt =sgfield("IPADDR","IP Address        ===>",slino,3,32,,word(sget(tcpadr,firstactive()),1))
  nxt2=sgfield("PORT","Port ===>",slino,nxt,6,,word(sget(tcpadr,histdef),2))
  nxt =sgfield("SGPW",  "Stargate Password ===>",slino+2,3,16,#NON)
  call fsstext('All later selected transactions will be transferred and performed on this MVS',hlino+2,2,,#turq)
  call fsstext('"You Ain'"'"'t Seen Nothing Yet"',24,25,,#white)
  call fssmessage FSSHeight()-1
  Call FSSFooter 'F3/F4 END    F5 Refresh Environment List',#blue
  call fsscursor("IPADDR")
  if serror<>'' then call fssZerrsm serror
  if lerror<>'' then call fssZerrlm lerror
return
/* ------------------------------------------------------------
 * Connect and call Menu Screen
 *   mslv 0 print everything
 *   mslv 1 print system information and higher
 *   mslv 2 print information and higher
 *   mslv 3 pprint warnings and higher
 *   mslv=4 errors and higher
 * ------------------------------------------------------------
 */
DisplayMenu:
/* check if Server is active and part of the list */
  si=ssearch(tcpadr,ipaddr)
  if si>0 & hstatus.si=1 then nop   /* entry found and server activated */
  else do
     if si>0 then do
        mserror='not active'
        mlerror='Server 'ipaddr' is not active, must be started (F5 to refresh list)'
     end
     else do
        mserror='Server unknown'
        mlerror='Server 'ipaddr' is unknown, not in provided List'
     end
     return 4
  end
/* Connect to server and Logon */
  sgpw=271441
  sgQueue.1='$$$LOGON 'MVSVAR('SYSNAME')'.'userid()' 'sgpw
  sgQueue.0=1
  stargate_mslv=0    /* all messages in the beginning */
  socket=setg('sg_clientSocket',-1)    /* pre set to -1 */
  rc=stargate('SEND',ipaddr,port,'$$$QUEUE SGQUEUE.')
  socket=getg('sg_clientSocket')
  if socket<0 | rc>0 then do
     if socket>=0 then call tcpclose(socket)
     socket=setg('sg_clientSocket',-1)    /* reset to -1 */
     buffer.0='ARRAY 'getg('SG_STOUT')
     call fmtlist ,,hdr,copies('-',250)
     mserror='not connected'
     mlerror='Connection to 'ipaddr' failed'
     return 0
  end
  call stargmen
  mserror=''
  mlerror=''
return 4     /* Connect failed, re-display */
/* ------------------------------------------------------------
 * Fetch input variables of Connect Screen
 * ------------------------------------------------------------
 */
SGfetchVars:
  do i=1 to xref.0
     vval=strip(FSSFGET(xref.i),,'_')
     vval=strip(vval)
     interpret xref.i'=vval'
  end
  if arg(1)='' then return 0
  do j=1 to sarray(tcpadr)
     if select.j='' then iterate
     histdef=j
     reuse=1
     return 4
  end
return 0
/* ------------------------------------------------------------
 * Define a field associated with a text prior to it
 * ------------------------------------------------------------
 */
SGfield:
  parse arg var,txt,sgROW,sgcol,inlen,fieldattr,input
  tnxt=FSSTEXT(txt,sgrow,sgcol,,#PROT+#HI+#GREEN)
  if fieldattr='' then fieldattr=#red
  if input='' then fnxt=FSSFIELD(var,sgrow,tnxt,inlen,fieldattr+#uscore,copies(' ',inlen))
  else fnxt=FSSFIELD(var,sgrow,tnxt,inlen,fieldattr+#uscore,input)
  ki=xref.0+1
  xref.ki=var
  xref.0=ki
return fnxt
/* ------------------------------------------------------------
 * Missing Attributes, create Error message
 * ------------------------------------------------------------
 */
missingAttributes:
  missing=''
  if IPADDR='' then missing='IP Address, '
  if PORT=''   then missing=missing||'Port, '
  if sgpw=''   then missing=missing||'Password'
  missing=strip(missing)
  if substr(missing,length(missing),1)=',' then missing=substr(missing,1,length(missing)-1)
  lerror='Input missing for 'strip(missing)
  serror='Input missing'
  reuse=1
return
/* ------------------------------------------------------------
 * Add the environments used until now
 * ------------------------------------------------------------
 */
checkHistory:
  parse arg reuse,nlino
  call fsstext('Selecting an environment puts it to the IP/PORT fields',nlino+1,3,,#green)
  call fsstext("Recently used environments",nlino+2,3,,#white)
  call fsstext("Update List in "userid()".EXEC(SGTCPLST)",nlino+2,41,,#turq)
  nlino=nlino+2
  do i=1 to sarray(tcpadr)
     mvs=sget(tcpadr,i)
     nlino=nlino+1
     mvst=left(mvs,width-17-1)
     call fsstext(mvst,nlino,17,,#white)
     if reuse=0 & histchecked=0 then do
        stoken=tcpopen(word(mvs,1),word(mvs,2),1)
        if stoken<0 then hstatus.i=0
        else do
           call tcpclose(_fd)
           hstatus.i=1
         end
     end
     if hstatus.i=1 then call fsstext('ACTIVE',nlino,6,,#TURQ)
     else call fsstext('INACTIVE',nlino,6,,#BLUE)
     fnxt=FSSFIELD('Select.'i,nlino,16,1,#red+#uscore,' ')
     ki=xref.0+1
     xref.ki='Select.'i
     xref.0=ki
  end
return nlino
/* ------------------------------------------------------------
 * Find 1. active IP Address
 * ------------------------------------------------------------
 */
firstactive:
  if reuse=1 then return histdef
  do fi=1 to sarray(tcpadr)
     if hstatus.fi=1 then return fi
  end
  return 1
/* ------------------------------------------------------------
 * Determine the IP Address of the accessed MVS
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
/* ------------------------------------------------------------
 * Init Stargate FSS Environment
 * ------------------------------------------------------------
 */
SGFSSini:
  call import fssapi
  ADDRESS FSS
  CALL FSSINIT
  xref.0=0
  tcpadr=sread("'"userid()".exec(SGTCPLST)'")
  call sdrop(tcpadr,';;')
  if tcpadr<0 then do
     history.0=0
     mlerror='no MVS list in userid.exec(stargtcp), one line per MVS format: IP PORT comment'
     mserror='MVS List missing'
     tcpadr=0
     return 8
  end
  myIP=myIPADDR()
  histdef=1
  lerror=''
  serror=''
  mlerror=''
  mserror=''
  histchecked=0
  width=fsswidth()
return 0
