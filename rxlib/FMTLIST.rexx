/* ---------------------------------------------------------------------
 * Display Buffer
 *   Content must be stored in STEM BUFFER.
 *   Buffer.0    contains number of lines
 *   Buffer.n    each line in stem as single entry n=1,2,...,maximum
 * .................................. Created by PeterJ on 25. July 2019
 *                                 Changed by PeterJ on 11. January 2022
 * ---------------------------------------------------------------------
 */
fmtlist: procedure  ,
         expose LastCommand. buffer. _screen. _refresh _#bno (public) ,
            old_zerrsm old_zerrlm _exitZERRSM _exitZERRLM sticky. __fmtstack.
signal off syntax
trace off
fssslow=1
parse arg lineareaLen,LineareaChar,##header,##header2 ,
         ,LinecommandAPPL
  signal off syntax
  call import FSSAPI
  Address FSS
  call fmtLinit             /* init and set size of 3270 screen  */
  buffer.0=upper(buffer.0)
  if buffer.0='STACK' then call fetchQueue
  else if pos('ARRAY',buffer.0)>0 then call fetchArray
  else call fetchBuffer 0  /* Copy stem Buffer to internal buffer    */
/* ..... Display first Buffer ..... */
  lino=display(1,1)
/* .....................................................................
 * Screen Handler manages Buffer until PF3/PF4
 * ...........*/
  _rc=screenHandler()   /* Screen Handler manages input keys */
   if _exitproc<>'' then call tryCallBack(_exitproc)
  _#bno=_#bno-1
  _refresh=1
  'RESET'
  if _rc=-16 then call SETG('FMTLIST_EXIT',1)  /* set exit all flag  */
  call setg("__fss"fsstoken," ")
return _rc
/* ---------------------------------------------------------------------
 * Screen Handler
 *   handles ENTER and PF Keys
 * ---------------------------------------------------------------------
 */
screenHandler:
  do forever
     callerror=0
     _pfkey=fssrefresh('CHAR') /* Display Screen, return PF-key/Enter */
     call wait 2
     if msgset=1 then call msgreset
     if _pfkey='PF12' then do ; call LastCommand ; iterate ; end
     call getFields
     if _pfkey='PF03' then leave;
        else if _pfkey='PF15' then leave;
        else if _pfkey='PF04' then return -16
        else if _pfkey='PF16' then return -16
        else if _pfkey='PF01' then do ; call DisplayHelp ; iterate ; end
     trace off
/*  else if _pfkey='ENTER' then do */
/* Run always Enterkey processing in case there are (line) commands */
     $erc=enterKey()
     if $erc=-4  then leave
        else if $erc=-12 then leave  /* PF03 pressed in enterkey proc */
        else if $erc=-16 then return -16
        else if $erc=-20 then do ; call DisplayHelp ; iterate ; end
        else call check4Recovery
     if _pfkey='PF08' then lino=display(lino+ListScroll(command),scol)
     else if _pfkey='PF07' then lino=display(lino-ListScroll(command),scol)
     else if _pfkey='PF11' then lino=display(lino,shft(scol,1,command))
     else if _pfkey='PF10' then lino=display(lino,shft(scol,0,command))
     else if _pfkey='PF05' then lino=display(lino,scol,'FORCE')
  end
return 0
/* ---------------------------------------------------------------------
 * Calculate Buffer Shift left and right
 * ---------------------------------------------------------------------
 */
shft:
parse arg ccol,smode,enterk
  if datatype(enterk)<>'NUM' then enterk=50
  if smode=1 then return ccol+enterk
return ccol-enterk
/* ---------------------------------------------------------------------
 * Check if Recovery is needed
 * ---------------------------------------------------------------------
 */
check4Recovery:
  if _refresh>0 & datatype(_refresh)='NUM' then do
     if _refresh>=100 then do
        _refresh=_refresh//100%1
        call Fetchbuffer 1   /* fetch new Buffer */
        lino=1
        scol=1
     end
     if _refresh=10 then call scrRecover 'KEEP'
        else call scrRecover 'KEEP'     /* ??? Keep also the messages */
     lino=display(lino,scol,'FORCE')
     _refresh=0
  end
  else if _refreshLA=1 then lino=display(lino,scol,'FORCE')
return
/* ---------------------------------------------------------------------
 * Reset Screen Messages
 * ---------------------------------------------------------------------
 */
msgreset:
  call statspart
  if fsscheck("#ZERRLM")=0 & msglong=1 then call ZERRLM ' '
  msgset=0
return
/* ---------------------------------------------------------------------
 * Display Screen
 * ---------------------------------------------------------------------
 */
Display:
  parse arg lino,scol,forcedisp
  if lino<1 then lino=1
     else if lino>linc then lino=linc
  if scol<1 then scol=1
     else if scol>255 then scol=LastScol
  if lastLino=lino & lastScol=scol & forcedisp='' then return lino
  lini=lino
  if botcolor>0 & botindx>0 then call resetBotColor botindx
  botindx=0   /* reset bottom line index, will be newly determined */
  if scol<>LastScol then call disHeader  scol    /* Display Header */
 /* Display top lines and Header lines, if any */
  if lini<=1 then do
     i=setLine(1,#lastar,topdata,0)
     call SetTopColor 1
  end
  else i=0
/* Display Buffer Content of curent screen page  */
  if topcolor=1 then call resetTopColor lini
  if topcolor=100 then topcolor=1
  do i=i+1 to #lstheight
     if lini<=linc &linc>0 then call bufline /* display content lines */
     else if lini+lino=0 then call endline   /* Display END OF DATA   */
     else if lini=linc+1 then call endline   /* Display END OF DATA   */
     else call dummyLine                     /* Display emtpy line    */
  end
  lastLino=lino
  lastScol=scol
  if msgset=0 then call statsPart
  if sticky.0>0 then call StickyDS   /* Display Sticky */
return lino
/* ---------------------------------------------------------------------
 * Refresh Statistics at Top of Screen
 * ---------------------------------------------------------------------
 */
statsPart:
/* Update other parts of the List Screen   */
  _fs='ROWS 'right(lino,5,'0')'/'right(linc,5,'0'),
      'COL 'right(scol,3,'0'),
      'B'right(_#BNO,2,'0')
  'SET FIELD STATS _fs'
  'SET CURSOR CMD'
return
mycolor:
parse arg slino p0 p1 p2 p3
parse var p2 xy'.'blino
if p3=61696 then p4='BLUE'
if p3=61952 then p4='RED'
if p3=62208 then p4='PINK'
if p3=62464 then p4='GREEN'
if p3=62720 then p4='TURQ'
if p3=62976 then p4='YELLOW'
if p3=63232 then p4='WHITE'
return
/* ---------------------------------------------------------------------
 * Reset Color of first line and Header Lines
 * ---------------------------------------------------------------------
 */
setTopColor:
  parse arg tlino
  if #LineArea=1 then ,
    'SET COLOR LINEA.'tlino colortop1
  'SET COLOR _LIST.'tlino colortop2
   topcolor=100
return
/* ---------------------------------------------------------------------
 * Reset Color of first line and Header Lines
 * ---------------------------------------------------------------------
 */
resetTopColor:
 if #LineArea=1 then ,
   'SET COLOR LINEA.1' colorlist1
 'SET COLOR _LIST.1' colorlist2
  topcolor=0
return
/* ---------------------------------------------------------------------
 * Reset Color of List Line(s)
 * ---------------------------------------------------------------------
 */
resetBotColor:
  botcolor=arg(1)
 if #LineArea=1 then ,
   'SET COLOR LINEA.'botcolor colorlist1
 'SET COLOR _LIST.'botcolor colorlist2
  botcolor=0
return
/* ---------------------------------------------------------------------
 * Set Color of Last Line
 * ---------------------------------------------------------------------
 */
setBotColor:
  botcolor=arg(1)
 if #LineArea=1 then ,
   'SET COLOR LINEA.'botcolor colorbot1
 'SET COLOR _LIST.'botcolor colorbot2
return
/* ---------------------------------------------------------------------
 * Set Error Message  short/long ZERRSM/ZERRLM
 * ---------------------------------------------------------------------
 */
zerrsm:
  parse arg _msg
  zerrsm=_msg
  if strip(_msg)='' then return
 'SET FIELD STATS _msg'
  msgset=1
return
/* Set Error Message Long (ZERRLM) */
zerrlm:
  zerrlm=arg(1)
  if msglong<>1 then return
  call fssZERRLM arg(1)
  msgset=1
return
/* ---------------------------------------------------------------------
 * Write Buffer Line
 * ---------------------------------------------------------------------
 */
BufLine:
  #line=substr(sget(fmt_s,lini),scol,#lstwidth)
  if #lch=='' then call setline i,right(lini,#lal,'0'),#line
    else call setline i,#labnch,#line
  if _LIST.xbufcolindx1.lini>0 then do
     if #LineArea=1 then ,
       'SET COLOR LINEA.'i _LIST.XBUFCOLINDX1.lini
     if _LIST.XBUFCOLINDX2.lini>0 then ,
    'SET COLOR _LIST.'i _LIST.XBUFCOLINDX2.lini
     _LIST.XBUFCOLOR.i=1
  end
  lini=lini+1                         /* set to next buffer line */
return
/* ---------------------------------------------------------------------
 * Write End of Data Line
 * ---------------------------------------------------------------------
 */
dummyLine:
 if #LineArea=1 then do
   'SET FIELD LINEA.'i' _blk0'
    if #lal2>0 then 'SET FIELD LINEA2.'i' _blk0'
 end
 'SET FIELD _LIST.'i' _blk0'
  _linArea.i=-1
return
/* ---------------------------------------------------------------------
 * Write Empty line into Screen (after End of Data)
 * ---------------------------------------------------------------------
 */
EndLine:
  botl=center(' End of Data ',#LSTWIDTH,'*')
  call setLine i,#lastar,botl,1   /* say it's end of buffer line */
  if colorbot1<>'' then call setBotColor i
  botindx=i   /* bottom line is in screen line number ...  */
  lini=linc+9 /* Set beyond line count to init empty lines */
return
/* ---------------------------------------------------------------------
 * Set single Line in Buffer
 * ---------------------------------------------------------------------
 */
SetLine:
  parse arg indx,_la,_lc,_eob
  if #LineArea=1 then do
    'SET FIELD LINEA.'indx' _la'
    if #lal2>0 then do
       _lb='.'
      'SET FIELD LINEA2.'indx' _lb'
    end
  end
/*   Linecommands are not saved (anymore) coding dropped
  if #LineArea=1 then if _savela.indx='' | 
  _eob=1 then 'SET FIELD LINEA.'indx' _la'
            else if #LineArea=1 then 'SET FIELD LINEA.'indx' _savela.indx'
 */
  _savela.indx=''
 'SET FIELD _LIST.'indx' _lc'
  _linArea.indx=_la
  if _LIST.xbufcolor.indx>0 then do
     if #LineArea=1 then 'SET COLOR LINEA.'indx colorlist1
    'SET COLOR _LIST.'indx colorlist2
     _LIST.xbufcolor.indx=0
  end
return indx
/* ---------------------------------------------------------------------
 * Enter Key was pressed on LIST Screen
 * ---------------------------------------------------------------------
 */
enterkey:
  if LinecommandAPPL<>'' & #LineArea=1 then do
     lcr=checkLineCommands()
     if GETG('FMTLIST_EXIT')=1 then return -16 /* set exit all flag */
     if lcr=-12 then return -12  /* PF03 */
     if lcr=-16 then return -16  /* PF04 */
     if lcr=-20 then return -20  /* PF01 */
/*   if lcr=4   then call SCRRECOVER*/  /* refresh screen, was overlaid */
  end
 'GET AID _action'
 'SET CURSOR CMD'
/*   check if there was scrolling key */
  if pos(_action,'247 248 197 198 122 123')>0 then isScroll=1
     else isScroll=0
  wcmd=word(command,1)
  _commandLine=command
  if command<>'' then nop /* command provided */
  else do
      /* no command and no special Enter call back defined */
     if _enterproc='' then return 0      
     else do
        if tryCallBack(_enterproc,fmt_s)=64 then do
           record='_screen.enter.proc not defined'
           _enterproc=''
        end
        _refresh=1
     end
     return 0        /* no command provided */
  end
  if wcmd='TOP' then lino=display(1,scol)
  else if wcmd='M' & isScroll=1 then nop
  else if wcmd='END' then return -12   /* Leave Buffer = PF03 */
  else if wcmd='EXIT' then return -16  /* Exit application = PF04 */
  else if datatype(wcmd)='NUM' & isScroll=1 then nop
  else if wcmd='STICKY' then do
     rrc=sticky(subword(command,2))
     call scrRecover
     if rrc>0 then do
        call zerrsm wcmd' invalid sub command'
        call zerrlm wcmd' is an invalid STICKY command or sub command, RC='rrc
     end
     lino=display(lino,scol,'FORCE')
     return 0
  end
  else if abbrev('BOTTOM',wcmd,3) then lino=display(99999,scol)
  else if abbrev('QUIT',wcmd,4) then return -4
  else if abbrev('HELP',wcmd,3) then call DisplayHelp
  else if abbrev('ISPF',wcmd,4) then call rxispf word(command,2)
  else if abbrev('SPF',wcmd,3)  then call rxispf word(command,2)
  else if abbrev('RESET',wcmd,3) then do
     call colorreset
     return 0
  end
  else do
     if #primcmd=0 then do
        call zerrsm 'No Primary Commands'
        call zerrlm 'Primary User Commands are disabled'
     end
     else do
       rrc=runRexx(command)
       if GETG('FMTLIST_EXIT')=1 then return -16 /* set exit all flag */
       if rrc=-16 then return -16
       call check4Recovery
       if callError=1 | rrc=64 | rrc>0 then do
        call zerrsm wcmd' invalid command'
        call zerrlm wcmd' is an invalid or unsupported primary command, RC='rrc
       end
     end
  end
return 0
/* ---------------------------------------------------------------------
 * Run REXX which was requested from the Command line
 * ---------------------------------------------------------------------
 */
runrexx:
  parse arg called_rexx exparms
  parse var exparms "'"nexparms"'"
  if nexparms='' then parse var exparms '"'nexparms'"'
  if nexparms='' then nexparms=exparms
  _rebuild=0
/* ...... Now call REXX ............................................ */
  signal on syntax name __FMTNOFUNC
/*
  if #CMDPREF='CMD' then interpret "call "called_rexx" '"nexparms"'"
     else interpret "call "#CMDPREF'_primary 'called_rexx" '"nexparms"'"
 */
  lrc=0
  if #CMDPREF='CMD' then lrc=tryRexx(called_rexx,"'"nexparms"'")
  else do
       lrc=tryRexx(#CMDPREF'_primary',called_rexx,"'"nexparms"'")
       if lrc=64 then ,
          lrc=tryRexx(#CMDPREF'_'called_rexx,"'"nexparms"'")
  end
  if result=6 | lrc=6 then do      /* new buffer created by call-back*/
     _refresh=110
     call resetcolors
     return 0
  end
  if result=7 | lrc=7 then call lookaside /* new buffer created by call-back*/
  if _rebuild=1 then call resetcolors
return lrc
/* ---------------------------------------------------------------------
 * Create a Lookaside Buffer on top of the last one
 * ---------------------------------------------------------------------
 */
lookaside:
  if zerrsm<>'ZERRSM' then old_zerrsm=zerrsm
     else old_zerrsm=''
  if zerrLm<>'ZERRLM' then old_zerrlm=zerrlm
     else old_zerrlm=''
  _h1=getg('HDR1')
  _h2=getg('HDR2')
  if _h1='' then newhdr=##header
     else newhdr=_h1
  if _h2='' then newhdr2=##header2
     else newhdr2=_h2
  call fmtlist lineareaLen,LineareaChar,newhdr,newhdr2,LinecommandAPPL
  zerrsm=''
  zerrlm=''
  old_zerrsm=''
  old_zerrlm=''
  if _exitZERRSM<>'_EXITZERRSM' & strip(_exitZERRSM)<>'' then 
      zerrsm=strip(_exitZERRSM)
  if _exitZERRLM<>'_EXITZERRLM' & strip(_exitZERRLM)<>'' then 
      zerrlm=strip(_exitZERRLM)
  if zerrsm='' &  zerrlm='' then _refresh=1
     else _refresh=10    /* keep messages, if set in exitProc */
  call resetcolors
return 0
/* ---------------------------------------------------------------------
 * Try to run a primary command
 * ---------------------------------------------------------------------
 */
tryRexx:
  trc=0
  _p1=translate(arg(2),"'",'"')
  interpret 'call 'arg(1)'("'_p1'",'arg(3)')'
  signal off syntax
  callError=0
return result
/* ---------------------------------------------------------------------
 * Error Exit, if called Rexx is not available
 * ---------------------------------------------------------------------
 */
__FMTNOFUNC:
  signal off syntax
  callError=1
return 64
/* ---------------------------------------------------------------------
 * Reset Colors of entire Buffer
 * ---------------------------------------------------------------------
 */
colorreset:
  do kli=1 to linc
     if _LIST.xbufcolindx1.kli>0 then _LIST.xbufcolindx1.kli=0
     if _LIST.xbufcolindx2.kli>0 then _LIST.xbufcolindx2.kli=0
  end
  _refreshLA=1
return
/* ---------------------------------------------------------------------
 * Check if there was a line command issued
 * ---------------------------------------------------------------------
 */
checkLineCommands:
  _licmdindx=0
  _refresh=0
  _refreshLA=0
  _hiRefresh=0
  do for 80 /* until _licmdindx<0 */
     licmd=getLineCmd(_licmdindx+1)
     if _licmdindx<0 then leave /*_licmdindx contains list # in screen*/
     setcolor1=-1
     setcolor2=0
     rc=8
     #action=''
     lrc=LineCMDLocal(LinecommandAPPL,licmd)
     if #action='PF03' then return -12
     if #action='PF04' then return -16
     if #action='PF01' then return -20
     if lrc=-16         then return -16
     if lrc>4 then do    /* _linecmd comes from getLineCMD */
        call zerrsm 'Invalid Line Command '_lineCmd
        if msglong=1 then ,
      call zerrLM _lineCMD' is an invalid Line Command'
       'SET CURSOR LINEA.'_LICMDINDX
       leave
     end
     _savela._licmdindx=''
     if lrc<=4 then do
       'SET FIELD LINEA.'_LICMDINDX _linArea._LICMDINDX
        if zerrsm<>'' then call zerrsm zerrsm
        if fsscheck("#ZERRLM")=0 & msglong=1 & zerrlm<>'' then 
         call zerrLM zerrlm
     end
    'GET FIELD _LIST.'_LICMDINDX' _LINE'
     if setcolor1>0 then do
       'SET COLOR LINEA.'_LICMDINDX setcolor1
        _LIST.xbufcolindx1.buflino=setcolor1
        _LIST.xbufcolor._licmdindx=1
     end
     if setcolor2>0 then do
       'SET COLOR _LIST.'_LICMDINDX setcolor2
        _LIST.xbufcolindx2.buflino=setcolor2
        _LIST.xbufcolor._licmdindx=1
     end
    'SET CURSOR LINEA.'_LICMDINDX
     if _refresh>_hiRefresh then _hiRefresh=_refresh
  end
  if _hirefresh>0 then return 4
return 0
/* ---------------------------------------------------------------------
 * Retrieve Last Command
 * ---------------------------------------------------------------------
 */
LastCommand:
  llcm=lastCommand.LCMptr
  if llcm<1 then llcm=lastCommand.0
  if llcm=0 then return
  _cml=overlay(lastCommand.llcm,_clearcmd,1)
 'SET FIELD CMD _cml'
  lastCommand.LCMPTR=llcm-1
return
/* ---------------------------------------------------------------------
 * Retrieve Line Command
 *   _licmdindx    List line number in screen (not in buffer)
 *   #lstrow       List line number in screen kept for recall
 *   #fssrow       line number in screen (not just in LIST)
 *   lino          line number in buffer
 *   linc          maximum line number in buffer
 * ---------------------------------------------------------------------
 */
LineCMDLocal:
  if lino<=1 then ksi=2       /* top line is first line, -> +1 */
     else ksi=1
  do ksi=ksi to _licmdindx    /* clear previous line commands, if any */
     _savela.ksi=''
  end
  xlino=lino
  do ksi=_licmdindx   to #lstHeight    /* save remaining line area */
    xlino=xlino+1
    if xlino>linc then leave
   'GET FIELD LINEA.'ksi' _savela.ksi'
  end
PrimCMDLocal:
/* try to perform line command, in arg(1) is prefix for linecmd */
  applid=arg(1)
/*  if datatype('_licmdindx')<>'NUM' then _licmdindx=0 */
  #lstrow=_licmdindx     /* List Row selected, refers to Screen Row   */
  #fssrow=#lstrow+#lstOFF /* physical row on screen, needed 4 lineupd */
  lrc=LineCMDLocalR(applid,arg(2))  /* complete line */
  address FSS 'TEST'                /* Test if FSS env has been terminated */
  if rc>0 then do
     address FSS 'INIT'   /* if so, init it */
     _refresh=10
  end
  if lrc=5 then return deleteLine()
  if lrc=6 then do                  /* new buffer created by call-back*/
     _refresh=110
     _rebuild=1
     return 0
  end
  if lrc=7 then do                  /* new buffer created and stacked */
     call lookaside
     return 0
  end
  if lrc=4 &newline<>'' then do   /* new content of line defined */
     call sset(fmt_s,buflino,newline)
     _refresh=1
  end
  else if lrc=4 &addlines<>'' then return insertLine(addlines)
 
return lrc
/* ---------------------------------------------------------------------
 * Perform Line Command, embedded in Procedure to keep local Variables
 * ---------------------------------------------------------------------
 */
LineCMDLocalR: Procedure expose  ,
  zerrsm zerrlm msglong FSSPARMS._#VAR.#ZERRLM,
  newline #action addlines __fmtstack.,
  _refresh _#bno setcolor1 setcolor2,
  (public) #fssrow #lstrow #lal buffer. sticky.
 parse arg appl,licmd
  zerrsm=''
  zerrlm=''
  newline=''
  addlines=0
  parse value licmd with linecmd';'llino';'licmd
  signal on syntax name nolincmd
  interpret 'lrc='appl'_'linecmd'(licmd,llino)'
  if setcolor1<0 then setcolor1=62976
  signal off syntax
return lrc
noLincmd:
  signal off syntax
  callError=1
  setcolor1=61952
/* say 'ERROR' llino appl'_'linecmd licmd */
return 8
/* ---------------------------------------------------------------------
 * Display input line for certain Lino
 *   #lstrow       List row number in screen kept for recall
 *   #fssrow       row number in screen (not just in LIST)
 * ---------------------------------------------------------------------
 */
lineEdit:
   parse arg _edln,_preset
   flino=#fssrow     /* #fssrow is the physical row on screen  */
   _linal=#lal+3     /* offset in row=line area length +3      */
 ADDRESS FSS         /* open EDIT mask on it and set cursor    */
   _maxed=FSSWidth()-_linal+1   /* max available input field   */
   if datatype(_edln)<>'NUM' then _edln=_maxed-1
   if _edln>_maxed then _edln=_maxed
   if _preset='' then _preset=copies('_',_edln)
      else _preset=left(_preset,_edln)
  'GET FIELD _LIST.'#lstrow' _curl'
  'FIELD  'flino _linal '61952 EXPDSN '_edln' _preset'
  'SET COLOR EXPDSN '#white
  'SET CURSOR EXPDSN'
   if zerrlm<>'' then call zerrlm zerrlm
  'REFRESH 0'
   #action=fsskey('CHAR')          /* wait for editing */
   if #action<>'ENTER' then return ''
/*'GET FIELD _LIST.'#lstrow' _lc' */
  'GET FIELD EXPDSN  _lc'
   if _lc=_curl then return ''
   _lc=strip(translate(left(_lc,_edln),,'_'))
return _lc
/* ---------------------------------------------------------------------
 * DELETE line requested from user line command
 * ---------------------------------------------------------------------
 */
deleteLine:
  call sset(fmt_s,buflino,'')
  call sdrop(fmt_s,'')
/*  is now an array
  do dl=buflino to linc-1
     _fr=dl+1
     _LIST.dl=_LIST._fr
     if symbol('_savela.'_fr )='VAR' then _savela.ksi=_savela._fr
        else _savela.ksi=''
  end
 */
  setcolor1=0
  setcolor2=0
  linc=linc-1
  xlino=lino
  do ksi=_licmdindx to #lstHeight    /* save remaining line area */
     xlino=xlino+1
     if xlino>linc then leave
     _fr=ksi+1
     if symbol('_LIST.xbufcolindx1.'_fr)='VAR' then ,
        _LIST.xbufcolindx1.ksi=_LIST.xbufcolindx1._fr
     if symbol('_LIST.xbufcolindx2.'_fr)='VAR' then ,
        _LIST.xbufcolindx2.ksi=_LIST.xbufcolindx2._fr
  end
  _refresh=10
return 0
/* ---------------------------------------------------------------------
 * INSERT line(s) requested from user line command
 * ---------------------------------------------------------------------
 */
insertLine:
  parse arg addlines
  if datatype(addlines)<>'NUM' then addlines=1
  if addlines<=0 then return 0
  addl=_LICMDINDX+1
  addb=buflino+1
  emptyl='...'
 'SET FIELD _LIST.'addl' emptyl'
  do alb=_list.0+addlines to addb by -1
     alx=alb-addlines
     _list.alb=_LIST.alx
  end
  _list.0=_list.0+addlines
  linc=linc+addlines
  do addb=addb for addlines
     _LIST.addb=emptyl
  end
  xlino=lino
  /* shift remaining line cmds and color settings */
  do ksi=#lstHeight to _licmdindx+1 by -1
     xlino=xlino+1
     if xlino>linc then leave
     _fr=ksi+addlines
     if symbol('_savela.'ksi)='VAR' then _savela._fr=_savela.ksi
        else _savela._fr=''
     _savela.ksi=''
     if symbol('_LIST.xbufcolindx1.'ksi)='VAR' then ,
        _LIST.xbufcolindx1._fr=_LIST.xbufcolindx1.ksi
     _LIST.xbufcolindx1.ksi=0
     if symbol('_LIST.xbufcolindx2.'_fr)='VAR' then ,
        _LIST.xbufcolindx2._fr=_LIST.xbufcolindx2.ksi
     _LIST.xbufcolindx2.ksi=0
  end
  ksi=_licmdindx+1
  _savela.ksi=''
  _refresh=10
return 0
/* ---------------------------------------------------------------------
 * Calculate Scroll Amount
 * ---------------------------------------------------------------------
 */
ListScroll:
  parse arg incr' 'ign
  if incr='M' then incr=99999
  if datatype(incr)<>'NUM' then do
     if lino<=1 then incr=#lstheight-1
        else incr=#LSTHEIGHT
  end
return incr
/* ---------------------------------------------------------------------
 * Reset Colors if new or swap screen is displayed
 * ---------------------------------------------------------------------
 */
resetColors:
/* Reset line area and line colors */
  do ixt=1 to  #lstheight
    'SET COLOR LINEA.'ixt colorlist1
    'SET COLOR _LIST.'ixt colorlist2
     _list.xbufcolindx1.ixt=0
     _list.xbufcolindx2.ixt=0
  end
return
/* ---------------------------------------------------------------------
 * Create Panel Text Field
 * ---------------------------------------------------------------------
 */
fsstextl:
  parse arg row,col,attr,txt,embed
  col=col+1+leftcolx-1
  row=row+toprowx-1
  nxtcol=col+length(txt)
  _txt=txt
 'TEXT 'row col attr' _txt'
  /* close attribute with unprotect byte */
  if embed<>'' then 'TEXT 'row' 'nxtcol' #RED '
return 1
/* ---------------------------------------------------------------------
 * Create Panel Input Field
 * ---------------------------------------------------------------------
 */
fssfieldL:
  parse arg row,col,attr,field,vlen,vinit
  if vlen<1 then return 1
  len=length(vinit)
  if len=0 then vinit=' '
  if len<=1 then vinit=copies(vinit,vlen)
     else vinit=Left(vinit,vlen)
  col=col+1+leftcolx-1
  row=row+toprowx-1
 'FIELD  'row col attr field vlen ' vinit'
return 1
/* ---------------------------------------------------------------------
 * Fetch Values of all Input Fields
 * ---------------------------------------------------------------------
 */
GetFields:
 'GET AID AID'
 'GET FIELD CMD _CMD'
 'GET FIELD STATS _STATS'
  command=strip(strip(translate(_cmd,,#cmdchar)))
  ppos=pos(';',command)
  if ppos>0 then command=strip(substr(command,1,ppos-1))
  if command<>'' then do
     lastcommand.0=lastcommand.0+1
     lcm=lastcommand.0
     lastcommand.lcm=command
     lastCommand.LCMptr=lcm
     command=translate(command)
  end
 'SET FIELD CMD  _clearcmd'
return
/* ---------------------------------------------------------------------
 * Check for Line Commands
 * ---------------------------------------------------------------------
 */
GetLineCMD:
  if lino<=1 then buflino=lino-2 /* just if TOP OF DATA is displayed */
     else buflino=lino-1    /* bufno is index in Buffer. stem */
     buflino=buflino+_licmdindx
  do _licmdindx=arg(1) to #lstheight
     buflino=buflino+1
    'GET FIELD LINEA.'_LICMDINDX' _LINA'
     if _lina==_linarea._licmdindx then iterate
     if _lina=='' then leave
     _linecmd=extractlincmd(_lina, _linarea._licmdindx)
     _linecm2=filter(_linecmd,'.*-+=')
     if strip(_linecm2)=='' then do
       'SET FIELD LINEA.'_licmdindx _linarea._licmdindx
       if rc<0 then do
          call listit linea.
       end
        _refreshLA=1
        iterate
     end
    'GET FIELD _LIST.'_LICMDINDX' _LINE'
     if #lal2>0 then do
      'GET FIELD LINEA2.'_LICMDINDX' _lina2'
       call setg('_linecmd2',_lina2)
       if _lina2<>'' then do
          _tmp='.'
         'SET FIELD LINEA2.'_LICMDINDX' _tmp'
       end
     end
     return _linecmd';'buflino';'_line
  end
  _licmdindx=-1
return ''
/* ---------------------------------------------------------------------
 * Extract Line Command from Line Area
 * ---------------------------------------------------------------------
 */
extractLincmd:
  selcmd=''
  do _li=1 to #lal
     st1=substr(arg(1),_li,1)
     st2=substr(arg(2),_li,1)
/*   if st1==st2 then iterate */
     if st1==st2 then selcmd=selcmd' 'st1
     else selcmd=selcmd''st1
  end
  call setg('full_lineCommand','')
  if strip(selcmd)='' then return ''
  if datatype(selcmd)='NUM' then return ''
  call setg('full_lineCommand',selcmd)
return translate(word(selcmd,1))
/* ---------------------------------------------------------------------
 * Move BUFFER Stem into internal Buffer
 * ---------------------------------------------------------------------
 */
fetchBuffer:
parse arg __btype
  if pos('ARRAY',upper(buffer.0))>0 then do
     call fetchArray
     return
  end
  if datatype(buffer.0)<>'NUM' then do
     buffer.0=2
     buffer.1='BUFFER.0 is not set, number of entries necessary'
     buffer.2='FMTLIST does not show Buffer content'
  end
  if __btype=1 then call sfree(fmt_s)
  fmt_s=screate(buffer.0+50)
  do k=1 for buffer.0
     call sset(fmt_s,,buffer.k)
  end
  linc=buffer.0
return
/* ---------------------------------------------------------------------
 * Fetch Array to be processed as Buffer
 * ---------------------------------------------------------------------
 */
fetchArray:
  newbuf=word(buffer.0,2)
  if datatype(newbuf)<>'NUM' then do
     say 'invalid Array Number specified: 'newbuf
     exit 8
  end
  if symbol('fmt_s')='VAR' then if sarray(fmt_s)>=0 then call sfree(fmt_s)
  fmt_s=newbuf
  linc=sarray(fmt_s)
return
/* ---------------------------------------------------------------------
 * Move BUFFER Queue into internal Buffer
 * ---------------------------------------------------------------------
 */
fetchQueue:
  linc=queued('T')
  fmt_s=screate(linc+50)
  if linc=0 then do
     call sset(fmt_s,,'BUFFER.0 is not set, number of entries necessary')
     call sset(fmt_s,,'FMTLIST does not show Buffer content')
     return
  end
  do for linc
     parse PULL bline
     if queueproc='' then call sset(fmt_s,,bline)
     else do
        record=''
        if tryCallBack(queueproc,bline)=64 then do
           record='_screen.Queue.proc not defined'
           queueproc=''
        end
        if record='' then iterate
        call sset(fmt_s,,record)
     end
  end
return
/* ---------------------------------------------------------------------
 * Attach Messages to a FMTLIST screen (maybe stacked=
 * ---------------------------------------------------------------------
 */
FMTStack:
  parse upper arg __mode
  if __mode='' | __mode='CURRENT' then return __fmtstack.0
  parse arg __stack,__errsm,__errlm
  __fmtstack.__stack.#zerrsm=__errsm
  __fmtstack.__stack.#zerrlm=__errlm
return
/* ---------------------------------------------------------------------
 * Recover Screen if returning from another FMT Screen
 * ---------------------------------------------------------------------
 */
SCRRECOVER:
 'GET FIELD STATS zerrsm'     /* Messages, RESET will delete it */
 'GET FIELD #ZERRLM zerrlm'
 'RESET'
  if fssslow=1 then call screeninit
  else interpret 'call __fss'fsstoken
  if botline<>'' then Call FSSFooter botline,colorfoot
  call statspart
  if arg(1)='KEEP' then do
     if symbol('ZERRSM')='VAR' then call zerrsm zerrsm
     if symbol('ZERRLM')='VAR' then call zerrlm zerrlm
  end
  if __fmtstack.__currrentFMT.#zerrsm<>'' then 
   call zerrsm __fmtstack.__currrentFMT.#zerrsm
  if __fmtstack.__currrentFMT.#zerrlm<>'' then 
   call zerrlm __fmtstack.__currrentFMT.#zerrlm
return
/* ---------------------------------------------------------------------
 * Try to perform a call-back rexx
 * ---------------------------------------------------------------------
 */
tryCallBack:
  parse arg called_rexx,exparms
/* ...... Now call REXX ............................................ */
  signal on syntax name __FMTNOFUNC
  lrc=tryRexx(called_rexx,"'"exparms"'")
  signal off syntax name __FMTNOFUNC
return lrc
/* ---------------------------------------------------------------------
 * INIT FSS and setup List Screen
 * ---------------------------------------------------------------------
 */
ScrEENINIT:
  ADDRESS FSS
   cmdpref=#CMDPREF' ==>'
   cmdoffs=length(cmdpref)+2
   statsoffset=#scrwidth-28-1-leftColx+1
   if titleA='' then cmdlen=statsoffset-cmdoffs
      else cmdlen=#scrwidth-cmdoffs-1
 /* FSS requires offset as real offset of text or fileld
    as this is not easy readable we re-calculate in the FSSTEXT/FSSFIELD
    function. The call has now real offset, which means the 1. byte
    contains attribute byte, byte starts with real output value
  */
   if toprowx>1 & toprowproc<>'' then do
      if tryCallBack(toprowproc)=64 then say _screen.toprow.proc' not defined'
   end
   topdata=center(' Top of Data ',#LSTWIDTH,'*')
   toplina=#lastar
   blk=copies(' ',#LSTWIDTH)
   loff=2+#lal
   topl=1
   if titleA<>'' then do
   call fsstextL topl,1,#PROT+#HI+#White,center(' 'titleA' ',statsoffset-1,'-')
      topl=topl+1
   end
   do j=1 to #lstheight
      call fssfieldL j+#lstOFF,1, colorlist1,'LINEA.'j,#LAL,#lablnk
      if #lal2>0 then ,
         call fssfieldL j+#lstOFF,2+#lal, colorlist1,'LINEA2.'j,#lal2,'.'
      if #LineArea=1 then ,
         call fssfieldL j+#lstOFF,loff+#lal2,
               #prot+#hi+colorlist2,'_LIST.'j,#LSTWIDTH-#lal2d,blk
      else call fssfieldL j+#lstOFF,1,#prot+#hi+colorlist2,
               '_LIST.'j,#LSTWIDTH,blk
   end
/* add Sticky notes */
   if sticky.0>0 then call stickyDf
   if botrowx>=1 & botrowproc<>'' then do
      if tryCallBack(botrowproc,#lstheight+#lstoff+toprowx)=64 then ,
         say _screen.botlines.proc' not defined'
   end
   call DisHeader 1     /* Display Header lines */
   lastScol=1
   call fsstextL  topl,1,  #PROT+#HI+COLORCMD,cmdpref
   if #cmdchar=' ' then 
      call fssfieldL topl,cmdoffs,  #HI+#uscore+COLORCMD,'CMD',cmdlen,#cmdchar
      else call fssfieldL topl,cmdoffs,  #HI+COLORCMD,'CMD',cmdlen,#cmdchar
   call fssfieldL 1   ,STATSOFFSET,#PROT+#HI+colorstats,stats,28," "
   if msglong=1 then Call FSSMessage #msgpos
   if botline<>'' then Call FSSFooter botline,colorfoot
  'SET CURSOR CMD'
   if old_zerrsm<>'OLD_ZERRSM' & old_zerrsm='' then call zerrsm old_zerrsm
   if old_zerrlm<>'OLD_ZERRlM' & old_zerrlm='' then call zerrlm old_zerrlm
  if fssslow=1 then return
  ADDRESS FSS
     'GET METRICS __currentScreen FIELDS'
      _fssstack='__#g=" "'
     do until __currentScreen=""
        parse var __currentScreen _fsset';1;'_fssdef';2;'__currentScreen
        if _fsset=='' then _fssstack=_fssstack';'_fssdef
           else _fssstack=_fssstack';'_fsset';'_fssdef
     end
     call setg("__fss"fsstoken,_fssstack)
return
/* ---------------------------------------------------------------------
 * Display Help Information
 * ---------------------------------------------------------------------
 */
displayhelp:
  _licmdindx=0   /* Set line command row to 0, it's a primary command */
  rrc=PrimCMDLocal(LinecommandAPPL,'help')
  if rrc=-16 then return -16
  if callError=1 | rrc>4 then do
     call zerrsm 'Help System not defined'
     call zerrlm 'Help System not defined'
  end
  call check4Recovery
return 0
/* ---------------------------------------------------------------------
 * Display Header Lines (above list output)
 * ---------------------------------------------------------------------
 */
 disHeader:
   if _header1=1 then do
      /* last byte must be an unprotect byte */
      sheader=left(substr(#header1,arg(1)),#lstwidth-1)               
      /* as next line must begin unprotected */
      call fsstextL topl+1,#lal+2+#lal2,#PROT+colorhdr1,sheader,#RED  
   end
   if _header2=1 then do
      sheader=left(substr(#header2,arg(1)),#lstwidth-1)
      call fsstextL topl+2,#lal+2+#lal2,#PROT+colorhdr2,sheader,#RED
   end
return
/* ---------------------------------------------------------------------
 * INIT Environment, set 3270 screen size
 * ---------------------------------------------------------------------
 */
fmtLInit:
  fsstoken=time('LS')
  __currrentFMT=fsstoken
  __fmtstack.0=__currrentFMT           /* current stack */
  __fmtstack.__currrentFMT.#zerrsm=''
  __fmtstack.__currrentFMT.#zerrlm=''
  ADDRESS FSS
 'RESET'
  CALL FSSINIT 'FMTLIST'
  if symbol('LastCommand.0')<>'VAR' then do
     LastCommand.0=0
     LastCommand.LCMptr=0
  end
  #lal=5
  lastinstr=SYSVAR('RXINSTRC')
  if datatype(lineareaLen)='NUM' then #LAL=LineareaLen
  if #lal>12 then #lal=12
  #lal2=GetScrIni('lina2',0)   /* is second line area wanted */
  #lal2d=#lal2
  if #lal2>0 then #lal2=#lal2+1   /* +1 beacause of screent attr */
  if #lal>0 then #LineArea=1
  else do
     #lal=0
     #lal2=0
     #lal2d=0
     #LineArea=0
  end
  #lal=trunc(#lal)
  #lastar=copies('*',#LAL)
  #laperd=copies('.',#LAL)
  #lablnk=copies(' ',#LAL)
  _blk0=''
  msgset=0
  _screen.FMTLIST=1  /* first setup  _screen. variable] */
  toprowx=GetScrIni('toprow',1)  /* avoid same name as in stem */
  toprowproc=GetScrIni('TopRow.proc')
  /* Free bottom Lines between LIST and Message Line */
  botrowx=GetScrIni('botlines',0)  
  botrowproc=GetScrIni('botlines.proc')
  _exitproc=GetScrIni('Exit.proc')
  _enterproc=GetScrIni('Enter.proc')
  queueproc=GetScrIni('Queue.proc')
  leftColx=GetScrIni('LeftCol',1)
  linearea2=GetScrIni('LineArea2',1)
/* ----- Screen Dimensions and Definitions --- */
  #scrheight=fssheight()-toprowx+1 /* number of lines  in 3270  screen */
  #scrWidth=FSSWidth()       /* Number of columns in 3270  screen */
  /* Number of Columns in list area  */
  #lstWidth =#scrwidth-3-#LAL-#lal2d-leftColx+1 
  #lstHeight=#scrHeight-1-botrowx        /* Number of Lines   in list area  */
  #lablln=copies(' ',#LSTWIDTH)
  if LineareaChar==''then #lch='' /* Line Area default is numbering */
  else do
     #lch=substr(LineareaChar,1,1)
     #labnch=copies(#lch,#lal)
  end
/* ----- List Area Color Setting ------------- */
  colorbot1 =GetScrIni('Color.bot1',#red)
  colorbot2 =GetScrIni('Color.bot2',#blue)
  colortop1 =GetScrIni('Color.top1',#red)
  colortop2 =GetScrIni('Color.top2',#blue)
  colorlist1=GetScrIni('Color.list1',#white)
  colorlist2=GetScrIni('Color.list2',#green)
  colorcmd  =GetScrIni('Color.cmd',#red)
  colorstats=GetScrIni('Color.stats',#white)
  colorfoot =GetScrIni('Color.footer',#white)
  colorhdr1 =GetScrIni('Color.header1',#blue)
  colorhdr2 =GetScrIni('Color.header2',#blue)
  botcolor=0
  topcolor=0
  #scrrow=2
  #lstoff=1
/* ----- Others ------------------------------ */
  #msgpos=FSSHeight()         /* position message, if requested */
  botline=GetScrIni('Footer','')
  if botline<>'' then do
     #lstHeight=#lstHeight-1
     #msgpos=#msgpos-1
  end
  Titlea=GetScrIni('Title1','')
  if titlea<>'' then do
     #lstOff=#lstOff+1
     #lstHeight=#lstHeight-1
     #scrrow=#scrrow+1
  end
  msglong=GetScrIni('Message',0)
  if msglong=1 then #lstHeight=#lstHeight-1
  if datatype(_#BNO)<>'NUM' then _#BNO=1
     else _#BNO=_#BNO+1
/* ----- Headers, Buffer Number, etc. -------- */
  if ##header='' then _header1=0
  else do
     _header1=1
     #header1=##header
     #lstHeight=#lstHeight-1
     #lstOff=#lstOff+1
     #scrrow=#scrrow+1
     if ##header2='' then _header2=0
     else do
        #header2=##header2
        _header2=1
        #lstHeight=#lstHeight-1
        #lstOff=#lstOff+1
        #scrrow=#scrrow+1
     end
  end
  #CMDPREF=LinecommandAPPL
  if #cmdpref='' then #cmdpref='CMD'
  #primcmd=GetScrIni('primary',1)
/* ----- INIT Screen definitions ------------------------------------ */
  #cmdchar=GetScrIni('cmdchar',' ')
  if translate(#cmdchar)="BLANK" then #cmdchar='0'x
  else #cmdchar=substr(#cmdchar,1,1)
  call SCREENINIT
  _clearcmd=Copies(#cmdchar,cmdlen)
/* ----- Now we can define Text and Fields -------------------------- */
  _savela.=''
return