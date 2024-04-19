call SGFSSini
do forever
   xref.0=0      /* remove any field which might be active from anoter schreen */
   ADDRESS FSS
  'RESET'
   CALL FSSTITLE 'Stargate Selection Menu',#WHITE
   nxt =sgfield("Option", "Option ===>",2,1,60)
   call fsstext('All Actions are sent to Server 'getg('SG_IPADDR'),4,7,,#white)
   slino=6
   call sgMenu('1','SEND','Send Message to TSO UserId',slino)
   call sgMenu('2','DELIVER','Deliver Dataset',slino+1)
   call sgMenu('3','SELECT' ,'Select and Deliver PDS Member(s)',slino+2)
   call sgMenu('4','RECEIVE','Receive Dataset',slino+3)
   call sgMenu('5','SELECT' ,"Receive Server's PDS List, select Member(s)",slino+4)
   call sgMenu('6','Hash'   ,"Receive Server's PDS Hash",slino+5)
   call sgMenu('7','SUBMIT','Transfer and Submit Job',slino+7)
   call sgMenu('8','RETRIEVE',"Retrieve Server's Output Queue",slino+8)
   call sgMenu('9','LISTCAT',"Retrieve ListCAT",slino+9)
   call sgMenu('10','SYSTEM',"Retrieve Server System Information",slino+10)
   call sgMenu('HB','HEARTBEAT',"Check Server's Heart Beat",slino+12)

   call fsstext('There is  "Something in the Air"',20,20,,#white)
   call fssmessage FSSHeight()
   call fsscursor("OPTION")
   call fssdisplay()
  'GET AID AID'
   if aid=243 | aid=244 then return 4
   call SGfetchVars
   option=upper(option)
   if option=1 then call stargsnd
   else if option=2 then call stargdli
   else if option=3 then call stargsel
   else if option=4 then call stargrcf
   else if option=5 then call stargsl2
   else if option=6 then call stargsl3
   else if option=7 then call stargsub
   else if option=8 then call stargspl
   else if option=9 then call starglct
   else if option=10 then call stargsys
   else if option=16 then call starg2mv
   else if option='XX' then do
      stargate_mslv=3
      socket=getg('sg_clientSocket')
      if socket>=0 then rc=stargate('SEND',"$$$SOCKET",socket,'$$$SHUTDOWN')
   end
   else if option='HB' then do
      stargate_mslv=0
      socket=getg('sg_clientSocket')
      say time('l')'   INFO  Check Heartbeat'
      if socket>=0 then rc=stargate('SEND',"$$$SOCKET",socket,'$$$HEARTBEAT')
   end
end
return 0
sgmenu:
  parse arg mselect,mshort,mlong,mlino
  nxt=FSSTEXT(mselect,mlino,10,10,#PROT+#HI+#white)
  nxt=FSSTEXT(mshort,mlino,nxt,12,#PROT+#HI+#turq)
  nxt=FSSTEXT(mlong,mlino,nxt,45,#PROT+#HI+#green)
return
