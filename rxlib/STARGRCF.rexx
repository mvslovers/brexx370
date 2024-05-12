call SGFSSini
slino=5
do forever
   ADDRESS FSS
  'RESET'
   CALL FSSTITLE 'Stargate Request Dataset from Server',#WHITE
   call fsstext('File(s) are requested from Server 'getg('SG_IPADDR'),3,7,,
               #white)
   nxt =sgfield("Dataset", "Dataset ===>",slino,3,52)
   call fsstext('Enter fully qualified ds-name or dsn(member)',slino+2,3,,
               #white)
   call fsstext('A partitioned dsn (w.o. member) will be entirely received',
               slino+3,3,,#white)
   call fsstext('"What Ever You Want"',18,25,,#white)
   call fssmessage FSSHeight()-1
   call fsscursor("Dataset")
   call fssdisplay()
  'GET AID AID'
   if aid=243 | aid=244 then return 4
   call SGfetchVars
   if dataset='' then iterate
   stargate_mslv=0    /* All Messages ! */
   socket=getg('sg_clientSocket')
   if socket<0 then return 8
   rc=stargate('SEND',"$$$SOCKET",socket,'$$$RECEIVE 'Dataset' 'message)
end
return 0
