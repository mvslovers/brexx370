call SGFSSini
slino=5
do forever
   ADDRESS FSS
  'RESET'
   CALL FSSTITLE 'Stargate Deliver Dataset ',#WHITE
   call fsstext('File(s) are sent to Server 'getg('SG_IPADDR'),3,7,,#white)
   nxt =sgfield("Dataset", "Dataset ===>",slino,3,52)
   call fsstext('Enter fully qualified ds-name or dsn(member)',slino+2,3,,#white)
   call fsstext('A partitioned dsn (w.o. member) will be entirely sent',slino+3,3,,#white)
   call fsstext('"You know it don'"'"'t come easy"',18,25,,#white)
   call fssmessage FSSHeight()-1
   call fsscursor("Dataset")
   call fssdisplay()
  'GET AID AID'
   if aid=243 | aid=244 then return 4
   call SGfetchVars
   if dataset='' then iterate
   stargate_mslv=0    /* All Messages ! */
   socket=getg('sg_clientSocket')
   rc=stargate('SEND',"$$$SOCKET",socket,'$$$DELIVER 'Dataset)
end
return 0
