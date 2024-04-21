/* --------------------------------------------------------------------------
 * FMTMON is an FSS application that refreshes itself every xxx milliseconds
 *    the refresh takes place in the call-back procedure MonTimeOut it must
 *    provide a new buffer or just return
 *    execute commands, e.g. CONSOLE and modify the buffer if wanted
 *
 *   Content must be stored in SARRAY ttarray
 *   colors  of each line Iarray tcarray
 * --------------------------------------------------------------------------
 */
 parse arg filter_proc
 call setg('MTTLOG_filter_proc',filter_proc)
 /* ..... Set additional fields as DASH definitions */
  call dshINFO -1,-1,1,20,'#turq+#uscore'
  call dshhdr  2,2,1,-1,'#Turq+#reverse'
  call sethdr left('Type   Time    Job ID   Trace Table Entry',160) /* assume max screen width */
 /* ..... Start FMTMON at Line 3  */
  _screen.TopRow=3
  call setINFO 'MTT startet'
  ttarray=screate(4096)
  tcarray=icreate(4096)
  ADDRESS FSS 'RESET'
  call fmtmonAR "MVS Master Trace Table",ttarray,tcarray,1500
  call fssclose
  call sfree ttarray ,'KEEP'
  call ifree(tcarray)
  sticky.0=0
  _screen.TopRow=''
return 0
/* --------------------------------------------------------------------------------------------------------
 * MONENTER Call Back PROC of FMTMON  Enter key pressed, do something
 *   return 0  continue normally
 *          4  continue normally, buffer is not touched
 *          8  end monitor (as PF3)
 *         12  end monitor (as PF4)
 * exposed fields of FMTMONAR
 *   altersarray    return an alternative string array number which is stacked on top of the original ones
 *   stacksarray.x  stack source array, stacksarray.1 = original one, .0 contains number of entries
 *   stdTimeout     is current time out used to refresh the screen, can be changed
 * --------------------------------------------------------------------------------------------------------
 */
MonEnter:
  parse upper arg ttcmd,sarray
  if strip(ttcmd)='' then return 4
  if substr(word(ttcmd,1),1,1)='@' then do
     call wto('@FROM 'userid()': 'substr(arg(1),2))
  end
  else if word(ttcmd,1)='/S' | stacksarray.0>1 then do
     tw=translate(ttcmd,,',')
     tw=strip(tw)
     if stacksarray.0=1 then do
        tw=subword(tw,2)
        if tw='' then altersarray=scopy(sarray)
        else altersarray=sselect(sarray,word(tw,1),word(tw,2),word(tw,3),word(tw,4),word(tw,5),word(tw,6),word(tw,7))
     end
     else altersarray=sselect(sarray,word(tw,1),word(tw,2),word(tw,3),word(tw,4),word(tw,5),word(tw,6),word(tw,7))
  end
  else if word(ttcmd,1)='/T' then do
     tw=word(ttcmd,2)
     if datatype(tw)='NUM' then stdTimeout=tw
  end
  else if word(ttcmd,1)='/HB' then do
     tw=word(ttcmd,2)
     if datatype(tw)='NUM' then do
        tw=max(tw,5)
        fmtmon.heartbeat=tw
        fmtmon.heartbeatnext=time('s')+tw
        call wto('Heartbeat')
     end
     else fmtmon.heartbeatnext='OFF'      /* not numeric switches off */
  end
  else do
     call CONSOLE arg(1)   /* action requested console command */
  end
  call setINFO translate(arg(1))' performed'
return 0
/* -------------------------------------------------------------------
 * MONTIMEOUT  Call Back PROC of FMTMON  Enter key pressed, do something
 *          Timeout in FSS, you can provide new content in
 *   arg(1) 0   build / rebuild MTT
 *   arg(2) 0   target source array receiving MTT
 *   arg(3) 0   Colour integer array allows specific colour of each line
 *
 *   return 0  continue buffer is unchanged
 *          1  continue new buffer provided
 * -------------------------------------------------------------------
 */
MonTimeout:                                     /* arg(1) 0: build/rebuild TT */
  parse arg ttopt,sarray,iarray
  if datatype(fmtmon.heartbeatnext)='NUM' then do
     if time('s')>fmtmon.heartbeatnext then do
        fmtmon.heartbeatnext=time('s')+fmtmon.heartbeat
        call wto('Heartbeat')
     end
  end
  curmax=sarray(sarray)
  if arg(1)=0 then do                           /* arg(1)=0 force Refresh */
     mrc=mttx('REFRESH',sarray)
     call sreverse(sarray)
     curmax=0
  end
  else mrc=MTTx(,sarray)                       /* master trace table: -1  no new entry */

  call setINFO ' '
  if mrc==-1 | mrc==curmax then return 0      /* master trace table: -1  no new entry */
/* if arg(1)>0 sarray will be appended, we must reverse the new entries */
  if arg(1)>0 then do
     smax=sarray(sarray)
     rmax=(smax-curmax+1)%2
     Do i=curmax+1 for rmax
        call sswap(sarray,i,smax)
        smax=smax-1
     end
  end
  fproc=getg('MTTLOG_filter_proc')
  if fproc<>'' then interpret 'sarray='fproc'(sarray)'
/*  Color variables are not set, as there are not exposed in the Proc call
  #PROT=    48       #BLINK=   15794176
  #NUM=     16       #REVERSE= 15859712
  #HI=      8        #USCORE=  15990784
  #NON=     12
  #BLUE=    61696    #GREEN=   62464
  #RED=     61952    #YELLOW=  62976
  #PINK=    62208    #WHITE=   63232
*/
/*  set Color variables for all/only new entries */
  Do i=curmax+1 to sarray(sarray)
     Tline=sget(sarray,i)
     wrd1=word(tline,1)
     if wrd1='0000'         then call iset(iarray,i,62976)          /* yellow */
     else if wrd1='FFFF'    then do
        if pos('@',tline)=0 then call iset(iarray,i,61952)          /* red    */
        else do
           if pos(userid(),tline)>0 then call iset(iarray,i,62208)  /* pink   */
           else call iset(iarray,i,62976)                           /* yellow */
        end
     end
     else if length(wrd1)=3 then call iset(iarray,i,63232)          /* white  */
     else if pos('$HASP373',tline)>0 then call iset(iarray,i,63464) /* green  */
     else if pos('$HASP395',tline)>0 then call iset(iarray,i,63464) /* green  */
     else call iset(iarray,i,61696)                                 /* blue   */
  end
  call setINFO 'New TT Entries'
return 1                      /* 1: new buffer provided, else buffer unchanged */
