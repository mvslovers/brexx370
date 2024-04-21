/* -------------------------------------------------------------------
 * FSS Asynchronous Monitor
 *   Content must be stored in STRING ARRAY
 *   SGET(SNAME,n) each line  n=1,2,...,maximum
 * ................................ Created by PeterJ on 22. June 2021
 *                                  Amended by PeterJ on 05. July 2022
 * -------------------------------------------------------------------
 */
FMTMONx: procedure expose sticky. _screen. sname
  parse upper arg title,timeout
  call import FSSAPI
 ADDRESS FSS
  parse arg title,timeout
  call __fmtmonInit
  call dshSMSG 1,-1,1,16,'#turq'
  call FMTMONRecover 1 /* inits the current fss screen */
  newBuffer=1
  newStatic=1
  _slinc=sarray(sname)
  HighTopLino=_slinc-#scrHeight+1 /* maximum top line to display        lastpage */
  lino=HighTopLino
/* ...................................................................
 * Do for ever loop to monitor Master Trace Table constantly
 * ...................................................................
 */
  do loopCnt=1
   /* newbuffer -1 same buffer (scrolling), 1 new buffer */
     if newbuffer<>0 then call setbuffer lino  /* move buffer into screen area */
     if newStatic=1 then call fmtStatic 0
     if sticky.0>0 then call StickyDS  /* Display Sticky */
     if loopcnt=1 then call wto "First Screen "time('e')
    "REFRESH "timeout" 0"              /* REFRESH every xxx ms, wait foraction */
     event=fsskey()
     if event=125 then event=processenter()
     if event=243 then leave /* p-Enter may return a new action key */
     else if event=244 then leave
     else if event=241 then call FMTmonHelp  /* PF1 Help */
     else if event=0   then nop  /* p-enter DO NOTHING*/
     else if event=247 then call fmtmonscroll -#scrheight
     else if event=248 then call fmtmonscroll #scrheight
     else if event=124 then call recallCMD
     else call TimeOutEvent          /* if nothing else it's TIMEOUT */
  end
  if event=243 | event=244 then return 0
 return 512
/* -------------------------------------------------------------------
 * Handle Timeouts
 * -------------------------------------------------------------------
 */
TimeOutEvent:
  newBuffer=IxmonTimeout(loopCnt)     /* if nothing else it's TIMEOUT */
  if newbuffer=0 then oldbuf=oldbuf+1 /* Buffer unchanged */
  else newbuf=newbuf+1                /* new buffer provided     */
  _slinc=sarray(sname)
return newBuffer
/* -------------------------------------------------------------------
 * Move Buffer Content into displayable FSS Screen area
 * -------------------------------------------------------------------
 */
setbuffer:
  parse arg from
  if from<1 then from=1
  if newbuffer>0 then HighTopLino=max(1,_SLINC-#scrHeight+1)
  if from>HighTopLino | newbuffer>0 then from=HighTopLino
  newBuffer=0
  lino=from
  k=0
  do j=from to _SLINC
     k=k+1
     if k>#scrHeight then return
    'CHECK FIELD lineC.'k    /* check if field is really set */
     if rc=0 then do
        _temp=left(SGET(SNAME,j),#lstWidth)
       'SET FIELD LINEC.'k '_temp'
/*      call fssfset('lineC.'k,left(SGET(SNAME,j),#lstWidth)) */
        if color.k<>'' then call fsscolor('lineC.'k,color.j)
     end
  end
  do j=j to #scrheight
     call fssfset('lineC.'j,copies(' ',#lstWidth))
  end
  call SETSMSG 'ROWS 'right(from,5,'0')'/'right(_SLINC,5,'0'),'RIGHT'
return
/* -------------------------------------------------------------------
 * Scroll forward/backward
 * -------------------------------------------------------------------
 */
fmtmonscroll:
  parse arg nlino lines
  olino=lino
  if nlino='TOP'       then lino=1
  else if nlino='BOT'  then lino=HighTopLino
  else if nlino='UP'   then lino=checkBuffLimit(lino,'-'lines)
  else if nlino='DOWN' then lino=checkBuffLimit(lino,lines)
  else lino=checkBuffLimit(lino,nlino)
  newStatic=1
  if olino=lino then return /* nothing has been changed */
  newbuffer=-1              /* screen refresh after scrolling action */
  call SETSMSG 'ROWS 'right(lino,5,'0')'/'right(_SLINC,5,'0')
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
  msg=strip(fssfGET('INPUT'))
  umsg=translate(msg)
  wmsg=word(umsg,1)
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
  if abbrev('STICKY',wmsg,3)>0 then do
     strc=sticky(subword(msg,2))
     return FMTreconstruct()
  end
  if wmsg='RX' then do
     interpret 'call 'word(umsg,2)
     return FMTreconstruct()
  end
/* ... is it a manual scrolling command ... */
  if length(wmsg)>1 &   ,
     pos(word(umsg,1),scrcmd)>0 then call fmtmonscroll umsg /* display first or tlast page */
  else do
   /* ... now pass on control to Enter Call-Back proc ... */
     curAPPL=_SCREEN.$_SCREENAPPL
     rrc=ixMonEnter(msg)
   /* Was there another FSS application active, if so recover */
     if curAPPL=_SCREEN.$_SCREENAPPL then do
        if rrc=0 then newbuffer=1
           else newbuffer=0
     end
     else rrc=FMTreconstruct
     HighTopLino=_SLINC-#scrHeight+1
     lino=HighTopLino
  end
  if rrc=0  then return 0
  if rrc=4  then return 0
  if rrc=8  then return 243
  if rrc=12 then return 244
return 244
/* -------------------------------------------------------------------
 * FMTMON Recall Command Line
 * -------------------------------------------------------------------
 */
RecallCMD:
  recall=fmtmonRecall.0
  cmd=fmtmonRecall.recall
  call fssfSET("INPUT","XXX",8)
  newStatic=1
return FMTreconstruct()
/* -------------------------------------------------------------------
 * FMTMON HELP
 * -------------------------------------------------------------------
 */
FMTMONHELP:
 ADDRESS FSS
  'RESET'
   _LINE.0=14
   _LINE.1='FMT Monitor'
   _LINE.2='-----------'
   _LINE.3='Enter valid Console Command'
   _LINE.4='    or ISPF to switch to ISPF'
   _LINE.5='    DOWN nn scrolls down nn lines'
   _LINE.6='    UP   nn scrolls up   nn lines'
   _LINE.7='    TOP  show first screen'
   _LINE.8='    BOT  show last screen'
   _LINE.9='supported PF Keys'
   _LINE.10='    PF1  this Help screen'
   _LINE.11='    PF3  exit FMTMON'
   _LINE.12='    PF4  exit FMTMON'
   _LINE.13='    PF7  scroll back one page'
   _LINE.14='    PF8  scroll forward one page'
   call fmtlist
return FMTreconstruct()
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
  call fssinit 'FMTMON'
  header=center(title,fsswidth()-2)
  if arg(1)=1 then NewBuffer=IXmonTimeout(0)
     else NewBuffer=0
  call FMTMONinit
return
/* -------------------------------------------------------------------
 * ixmonTimeout  Fields
 * -------------------------------------------------------------------
 */
ixMonTimeout: procedure expose sname sticky. fmtmon. color. oldsize
return monTimeout(arg(1))
/* -------------------------------------------------------------------
 * ixmonEnter    Fields
 * -------------------------------------------------------------------
 */
ixMonEnter: procedure expose sname fmtmon. sticky.
return monEnter(arg(1))
/* -------------------------------------------------------------------
 * FMTMON Static Fields
 * -------------------------------------------------------------------
 */
FMTStatic:
 "STATIC"
  nxt=fsstext(CMD,fssHeight(),1,length(cmd),#red)
  call fsstext(header,1,1,#scrWidth-1,#white+#uscore)
  call fssfield("INPUT",fssHeight(),nxt,#scrwidth-nxt,#blue+#uscore,' ',#prot)
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
  #lstHeight=#scrHeight-1-botrowx        /* Number of Lines   in list area  */
  * -------------------------------------------------------------------
  */
FMTMONinit:
  if sticky.0>0 then call StickyDF   /* Display Sticky */
  if symbol('_SLINC')<>'VAR' then _SLINC=0
  settime=0
  fmtmonRecall.0=0
  cmd='CONSOLE'
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
     call fssfield('lineC.'j,j+toprowx-1,1,#lstwidth,#blue+#prot,' ')
  end
/* Define last dynamic line */
  call fssfield('lineC.'j,j+toprowx-1,1,#lstwidth,#blue+#prot+#uscore,' ')
/* ...........................
  call fssmetrics 'details'
  call listit '_fss'
  ADDRESS TSO 'CLS'
 'CHECK POS 2 2'
 say rc _fssField
 */
return
