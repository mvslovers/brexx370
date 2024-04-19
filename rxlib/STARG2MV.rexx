 call SGFSSini
 slino=5
  do forever
     ADDRESS FSS
    'RESET'
     CALL FSSTITLE 'Stargate Connecting Stargate Servers',#WHITE
     call fsstext('Connect this MVS to another MVS',3,7,,#white)
     nxt =sgfield("IPAddr", "IP Address ===>",slino,3,32)
     nxt2=sgfield("MVSPort","Port       ===>",slino+1,3,5)
     call fssmessage FSSHeight()-1
     call fsscursor("IPADDR")
     call fssdisplay()
    'GET AID AID'
     if aid=243 | aid=244 then return 4
     call SGfetchVars
     stargate_mslv=3
     socket=getg('sg_clientSocket')
     rc=stargate('SEND',"$$$SOCKET",socket,'$$$LINK 'IPADDR' 'MVSPort)
  end
return 0
