/* -------------------------------------------------------------------
 * FSS Asynchronous Monitor
 *   Content is be stored in TTARRAY, Color in TCARRAY (int array)
 * ............................. Created by PeterJ on 13. January 2023
 * -------------------------------------------------------------------
 */
FMTMONAR: procedure expose sticky. _screen.
  parse upper arg title,ttarray,tcarray,timeout
  call import FSSAPI
 ADDRESS FSS
  call __fmtmonInit
  call dshSMSG 1,-1,1,20,'#turq+#uscore'
  call FMTMONRecover 1 /* inits the current fss screen */
  newBuffer=1
  newStatic=1
  HighTopLino=SARRAY(TTARRAY)-#scrHeight+1 /* maximum top line to display last page */
  lino=HighTopLino
  stdTimeout=timeout
/* ...................................................................
 * Do for ever loop to monitor Master Trace Table constantly
  #ENTER=125
  #PFK01=241      #PFK13=193
  #PFK02=242      #PFK14=194
  #PFK03=243      #PFK15=195
  #PFK04=244      #PFK16=196
  #PFK05=245      #PFK17=197
  #PFK06=246      #PFK18=198
  #PFK07=247      #PFK19=199
  #PFK08=248      #PFK20=200
  #PFK09=249      #PFK21=201
  #PFK10=122      #PFK22=74
  #PFK11=123      #PFK23=75
  #PFK12=124      #PFK24=76
 * ...................................................................
 */
  do loopCnt=1
   /* newbuffer -1 same buffer (scrolling), 1 new buffer */
     if newbuffer<>0 then call setmonbuffer lino  /* move buffer into screen area */
     if newStatic=1 then call fmtStatic 0
     if sticky.0>0 then call StickyDS /* Display Sticky */
     if stacksarray.0<=1  ,
        then "REFRESH "timeout" 0"   /* REFRESH every xxx ms, wait for action */
        else "REFRESH 0 0"           /* REFRESH and wait for key */
     event=fsskey()
     timeout=stdTimeout
     if event=4711 then call timeOutEvent
     else if event=125 then event=processenter()
     else if event=243 then do
          if stacksarray.0<=1 then leave
          cstack=stacksarray.0
          call sfree(cstack)
          cstack=cstack-1
          stacksarray.0=cstack
          ttarray=stacksarray.cstack
          call fmtmonRefresh 'STACK'
     end
     else if event=244 then leave
     else if event=241 then nop
     else if event=247 then call fmtmonscroll -#scrheight,'PF07'
     else if event=248 then call fmtmonscroll #scrheight,'PF08'
     else if event=124 then call recallCMD
     else nop                        /* if nothing ignore it */
     if event <>4711 then call setINFO ' '  /* don't clear info at timeout */
  end
  if event=243 | event=244 then return 0
 return 512
/* -------------------------------------------------------------------
 * Handle Timeouts
 * -------------------------------------------------------------------
 */
TimeOutEvent:
  newBuffer=IxmonTimeout(loopCnt,ttarray,tcarray) /* if nothing else it's TIMEOUT */
  if newbuffer=0 then oldbuf=oldbuf+1 /* Buffer unchanged */
  else newbuf=newbuf+1                /* new buffer provided     */
return newBuffer
/* -------------------------------------------------------------------
 * Move Buffer Content into displayable FSS Screen area
 * -------------------------------------------------------------------
 */
setmonbuffer:
  parse arg from
  if from<1 then from=1
  if newbuffer>0 then do
     HighTopLino=max(1,SARRAY(TTARRAY)-#scrHeight+1)
  end
  if from>HighTopLino | newbuffer>0 then from=HighTopLino
  newBuffer=0
  lino=from
  k=0
  do j=from to SARRAY(TTARRAY)
     k=k+1
     if k>#scrHeight then return
    'CHECK FIELD lineC.'k    /* check if field is really set */
     if rc/=0 then iterate
     call fssqset('lineC.'k,left(SGET(TTARRAY,j),#lstWidth))

     if stacksarray.0>1 then 'SET COLOR LINEC.'k #green
     else do
        color=iget(tcarray,j)
        if color>0 then 'SET COLOR LINEC.'k color
     end
  end
  do j=j to #scrheight
     call fssqset('lineC.'j,copies(' ',#lstWidth))
  end
  call bufferstats
return
/* -------------------------------------------------------------------
 * Rfresh FMTMON Buffer
 * -------------------------------------------------------------------
 */
fmtmonRefresh:
  if arg(1)='STACK' then do
     if stacksarray.0==1 then loopCnt=-1 /* enforce buffer refresh of very first buffer */
  end
  else loopCnt=-1 /* enforce buffer refresh of very first buffer */
  newbuffer=1
  newstatic=1
  timeout=5
return 0
/* -------------------------------------------------------------------
 * Scroll forward/backward
 * -------------------------------------------------------------------
 */
fmtmonscroll:
  parse arg nlino lines,scrmode
  if substr(scrmode,1,2)='PF' then inamount=upper(strip(fssfget('INPUT')))
     else inamount=''
  if inamount<>'' then do
     if type(inamount)='INTEGER' then lines=inamount
     if scrmode='PF08' then do
        if inamount='M'  then nlino='BOT'
        else nlino='DOWN'
     end
     else if scrmode='PF07' then do
        if inamount='M'  then nlino='TOP'
        else nlino='UP'
     end
  end
  olino=lino
  if nlino='TOP'      then lino=1
  else if nlino='BOT'  then lino=HighTopLino
  else if nlino='UP'   then lino=checkBuffLimit(lino,'-'lines)
  else if nlino='DOWN' then lino=checkBuffLimit(lino,lines)
  else lino=checkBuffLimit(lino,nlino)
  newStatic=1
  if olino=lino then return /* nothing has been changed */
  newbuffer=-1              /* screen refresh after scrolling action */
  call bufferstats
return
/* -------------------------------------------------------------------
 * Set Buffer Statistics
 * -------------------------------------------------------------------
 */
bufferstats:
  tmax=SARRAY(TTARRAY)      /* if tmax=0 then tlino=0 */
  tlino=lino
  if tlino>tmax then tlino=tmax
  call SETSMSG 'ROWS 'right(tlino,5,'0')'/'right(tmax,5,'0')' B'right(stacksarray.0,2,'0')
return
/* -------------------------------------------------------------------
 * Check Buffer/Screen limits
 * -------------------------------------------------------------------
 */
checkBuffLimit:
  parse arg clino,clinum
  if datatype(clinum)<>'NUM' then do
     if substr(clinum,1,1)='-' then clinum=-1
        else clinum=1
  end
  clino=clino+clinum
  if clino>HighTopLino then clino=HighTopLino
  if clino<1 then clino=1
return clino
/* -------------------------------------------------------------------
 * Enter Key was pressed, process it
 * -------------------------------------------------------------------
 */
processEnter:
  scrcmd='UP DOWN TOP BOTTOM'
  rrc=0
  msg=strip(fssfget('INPUT'))
  if strip(msg)='' then return 0
  umsg=translate(msg)
  wmsg=word(umsg,1)
  if wmsg='/R' then return fmtmonRefresh()
  newStatic=1
  call fssfSET("INPUT",copies(' ',#scrWidth))
  if wmsg='' then return 0
  recall=fmtmonRecall.0+1
  fmtmonRecall.recall=msg
  fmtmonRecall.0=recall
  if wmsg='ISPF' then do
     call rxispf word(umsg,2)
     Address FSS 'RESET'
     return FMTreconstruct()
  end
/* ... is it a manual scrolling command ... */
  if length(wmsg)>1 &   ,
     pos(word(umsg,1),scrcmd)>0 then call fmtmonscroll umsg,'ENTER' /* display first or tlast page */
  else do
   /* ... now pass on control to Enter Call-Back proc ... */
     curAPPL=_SCREEN.$_SCREENAPPL
     altersarray=-1
     rrc=ixMonEnter(msg,ttarray)
     if altersarray>0 then do
        cstack=stacksarray.0+1
        stacksarray.cstack=altersarray
        ttarray=altersarray
        stacksarray.0=cstack
     end
   /* Was there another FSS application active, if so recover */
     if curAPPL=_SCREEN.$_SCREENAPPL then do
        if rrc=0 then newbuffer=1
           else newbuffer=0
     end
     else rrc=FMTreconstruct
     HighTopLino=SARRAY(TTARRAY)-#scrHeight+1
     lino=HighTopLino
  end
  if rrc=0  then do
     timeout=200   /* change timeout temporarily maybe new output is coming */
     return 0
  end
  if rrc=4  then return 0
  if rrc=8  then return 243
  if rrc=12 then return 244
return 244
/* -------------------------------------------------------------------
 * FMTMON Recall Command Line
 * -------------------------------------------------------------------
 */
RecallCMD:
  if recallc<=1 then recallc=fmtmonRecall.0
  else recallc=recallc-1
  if recallc<1 then recallc=fmtmonRecall.0
  if recallc=0 then return 0
  cmdcontent=left(fmtmonRecall.recallc,160)
  newStatic=1
return 0
/* -------------------------------------------------------------------
 * FMT Buffer needs to be reconstructed
 * -------------------------------------------------------------------
 */
FMTreconstruct:
/*call CLRSCRN   */
  call FMTMONRecover 1
  newbuffer=1
return 0
/* -------------------------------------------------------------------
 * Init synchronous Moniror
 * -------------------------------------------------------------------
 */
FMTMONRecover:
  call fssclose
  call fssinit 'FMTMON'
/*header=center(title,fsswidth()-2) */
  header=copies(' ',24)title
  call FMTMONinit
  if arg(1)=1 then NewBuffer=IXmonTimeout(0,ttarray,tcarray)
     else NewBuffer=0
return
/* -------------------------------------------------------------------
 * ixmonTimeout  Fields
 * -------------------------------------------------------------------
 */
ixMonTimeout: procedure expose sticky. fmtmon. oldsize
return monTimeout(arg(1),arg(2),arg(3))
/* -------------------------------------------------------------------
 * ixmonEnter    Fields
 * -------------------------------------------------------------------
 */
ixMonEnter: procedure expose fmtmon. sticky. altersarray stacksarray. stdTimeout
return monEnter(arg(1),arg(2),arg(3))
/* -------------------------------------------------------------------
 * FMTMON Static Fields
 * -------------------------------------------------------------------
 */
FMTStatic:
 "STATIC"
  if stacksarray.0=1 then nxt=fsstext(CMD,fssHeight(),1,length(cmd),#red)
     else nxt=fsstext(">SEARCH",fssHeight(),1,length(cmd),#red)
  call fsstext(header,1,1,#scrWidth-1,#white+#uscore)
  call fssfield("INPUT",fssHeight(),nxt,#scrwidth-nxt,#blue+#uscore,' ',#prot)
  if cmdcontent<>'' then call fssfSET("INPUT",cmdcontent)
  cmdcontent=''
  call fsscursor("INPUT")
  "SHOW "arg(1)
  newStatic=0
return
/* -------------------------------------------------------------------
 * Init some variables
 * -------------------------------------------------------------------
 */
__fmtmonInit:
  if title='' then title='FMT Monitor'
  if datatype(timeout)<>'NUM' then timeout=1000
  else if timeout<=50 then timeout=50
  oldbuf=0
  newbuf=0
return
 /* -------------------------------------------------------------------
  * Init synchronous Monitor
  _screen.TopRow=4
  _screen.BotLines=1
  #lstHeight=#scrHeight-1-botrowx       Number of Lines   in list area
  * -------------------------------------------------------------------
  */
FMTMONinit:
  if sticky.0>0 then call StickyDF   /* Display Sticky */
  settime=0
  fmtmonRecall.0=0
  recallc=0
  stacksarray.0=1
  stacksarray.1=ttarray
  cmd='CONSOLE'
  cmdcontent=''
  #scrWidth=FSSWidth()-1
  #lstWidth=#scrWidth-1
  toprowx=GetScrIni('toprow',2)    /* avoid same name as in stem */
  if toprowx<2 | toprowx>fssheight()-1 then toprowx=2  /* must be under title line   */
  botrowx=GetScrIni('botlines',0)  /* Free bottom Lines between LIST and Message Line */
  #scrheight=fssheight()-toprowx-botrowx   /* number of lines  in 3270  screen */
  if #scrheight<1 then #scrheight=1   /* number of lines  in 3270  screen */
  call fmtStatic 1
/* Define last all dynamic lines -1 */
  do j=1 to #scrHeight-1
     call fssfieldSH('lineC.'j,j+toprowx-1,1,#lstwidth,#blue+#prot,' ') /* use quick variant, all checks done */
  end
/* Define last dynamic line */
  call fssfieldSH('lineC.'j,j+toprowx-1,1,#lstwidth,#blue+#prot+#uscore,' ') /* use quick variant, all checks done */
return
