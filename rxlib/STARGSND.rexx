 call SGFSSini
 slino=5
  do forever
     ADDRESS FSS
    'RESET'
     CALL FSSTITLE 'Stargate Send Message ',#WHITE
     call fsstext('Message(s) are sent via Server 'getg('SG_IPADDR'),3,7,,
                  #white)
     nxt =sgfield("UserID", "User ID ===>",slino,3,8)
     nxt2=sgfield("Message","Message ===>",slino+1,3,60)
     call fsstext('sending  "Message in a Bottle"',18,25,,#white)
     call fssmessage FSSHeight()-1
     call fsscursor("USERID")
     call fssdisplay()
    'GET AID AID'
     if aid=243 | aid=244 then return 4
     call SGfetchVars
     if UserId='' then iterate
     stargate_mslv=0
     socket=getg('sg_clientSocket')
     rc=stargate('SEND',"$$$SOCKET",socket,'$$$SEND 'userid' 'message)
  end
return 0
