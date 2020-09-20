/* ---------------------------------------------------------------------
 * Display Buffer
 *   Content must be stored in STEM BUFFER.
 *   Buffer.0    contains number of lines
 *   Buffer.n    each line in stem as single entry n=1,2,...,maximum
 * .................................. Created by PeterJ on 25. July 2019
 * ---------------------------------------------------------------------
 */
fmtlist: procedure expose buffer. _screen. _fssinit _action. (public)
parse arg lineareaLen,LineareaChar,header,header2
  call import FSSAPI
  Address FSS
  call fmtLinit         /* init and set size of 3270 screen  */
  call fetchBuffer      /* Copy Buffer to internal buffer    */
  lino=display(1,1)     /* Display 1. screen at line 1 & column 1 */
  call screenHandler    /* Screen Handler manages input keys */
  _fssInit=_fssInit-1   /* buffer number -1 */
  if _fssInit=0 then  , /* if initial buffer terminate    */
     call fssclose
return
/* ---------------------------------------------------------------------
 * Handles ENTER and PF Keys
 * ---------------------------------------------------------------------
 */
screenHandler:
  do until AID == _action.3 | AID == _action.15
    'REFRESH'
    call getFields
    if aid==_action.8       then lino=display(lino+scroll(command),scol)
    else if aid==_action.7  then lino=display(lino-scroll(command),scol)
    else if aid==_action.11 then lino=display(lino,scol+50)
    else if aid==_action.10 then lino=display(lino,scol-50)
    else if aid==_action.1  then do
       call fetchHelp       /* Load Help in new Buffer */
       call FMTLIST 1,'.'   /* Display Help in new Buffer */
       call recoverScreen   /* recover old Buffer */
    end
    if aid<>_action.enter then iterate /* if not enter,check line cmd */
  /* ********* no line command support for the moment
    licmd=getLineCmd()
    if licmd<>'' then do
       rc=LineCallBack(licmd)
       lino=display(lino,scol)    /* refresh buffer, drop line cmd */
       iterate
    end
  */
    if command='' then iterate /* enter, but no command */
    wcmd=word(command,1)
    if wcmd='TOP' then lino=display(1,scol)
    else if abbrev('BOTTOM',wcmd,3) then lino=display(99999,scol)
    else if abbrev('EXEC',wcmd,3) then do
       pcmd='CALL 'substr(command,wordindex(command,2))' BUFFER '
       interpret pcmd
       call FMTLIST 5,''
       call RecoverScreen
    end
  end
return
/* ---------------------------------------------------------------------
 * Display Screen
 * ---------------------------------------------------------------------
 */
Display:
  parse arg lino,scol
  if lino<1 then lino=1
  if lino>linc then lino=linc
  if scol<1 then scol=1
  if scol>255 then scol=255-70
  headi=0
  lini=lino
  topd=0
 /* Display Buffer */
  i=0
  do until i>#lstheight
     i=i+1
     if lini=1 & topd=0 &header='' then call topline /* Top Line */
     else if headi=0 & header<>'' then do
        #line=substr(header,scol,#lstwidth)
        call setLine i,copies('.',#LAL),#line
        headi=1
        if header2<>'' then do
           i=i+1
           #line=substr(header2,scol,#lstwidth)
           call setLine i,copies('.',#LAL),#line
        end
     end
     else if lini<=linc then call bufline /* display content lines  */
     else call endLine                    /* Display END OF DATA    */
  end
  _rw='ROWS 'right(lino,5,'0')'/'right(linc,5,'0')
  _cl='COL 'right(scol,3,'0')
  _cm=Copies('_',54)
  _fsi='B'right(_fssinit,2,'0')
  'SET FIELD ROWS _rw'
  'SET FIELD OFS  _cl'
  'SET FIELD CMD  _cm'
  'SET FIELD BUFNO _fsi'
  'SET CURSOR CMD'
return lino
/* ---------------------------------------------------------------------
 * Write Top Line of Buffer
 * ---------------------------------------------------------------------
 */
topLine:
  call setLine i,copies('*',#LAL),center(' Top of Data ',#LSTWIDTH,'*')
  topd=1
return
/* ---------------------------------------------------------------------
 * Write Buffer Line
 * ---------------------------------------------------------------------
 */
bufLine:
  #line=substr(ibuffer.lini,scol,#lstwidth)
  if #lch=='' then  ,
     call setline i,right(lini,#lal,'0'),#line
  else call setline i,copies(#lch,#lal),#line
  lini=lini+1                         /* set to next buffer line */
return
/* ---------------------------------------------------------------------
 * Write End Line of Buffer
 * ---------------------------------------------------------------------
 */
endLine:
/*
  instrCount=SYSVAR('RXINSTRC')
  instr=InstrCount-LastInstr
  LastInstr=instrCount
 */
  if lini=linc+1 then do
     botl=center(' End of Data ',#LSTWIDTH,'*')
/*   botl=overlay(instr'/'InstrCount,botl,53) */
     call setLine i,copies('*',#LAL),botl
     lini=lini+1 /* set to next buffer element (not existing) */
  end
  else call setLine i,copies(' ',#LAL),center(' ',#LSTWIDTH)
return
/* ---------------------------------------------------------------------
 * Set single Line in Buffer
 * ---------------------------------------------------------------------
 */
SetLine:
  parse arg indx,_la,_lc
  'SET FIELD LINEA.'indx' _la'
  'SET FIELD IBUFFER.'indx' _lc'
return
/* ---------------------------------------------------------------------
 * Returning from a higher Buffer requires recovery from the current one
 * ---------------------------------------------------------------------
 */
RecoverScreen:
  CALL FSSCLOSE
  CALL FSSINIT
  call SCREENINIT         /* re-Setup current Screen Definitions */
  lino=Display(lino,scol) /* Display old Buffer */
return
/* ---------------------------------------------------------------------
 * Calculate Scroll Amount
 * ---------------------------------------------------------------------
 */
scroll:
  parse arg incr' 'ign
  if incr='M' then incr=99999
  if datatype(incr)<>'NUM' then do
     if lino<=1 then incr=#lstheight-1
     else do
        incr=#LSTHEIGHT
        if heading<>''  then incr=incr-1
     end
     if heading2<>'' then incr=incr-1
  end
return incr
/* ---------------------------------------------------------------------
 * Create Panel Text Field
 * ---------------------------------------------------------------------
 */
fsstextl:
  parse arg row,col,attr,txt
  col=col+1
  _txt=txt
 'TEXT 'row col attr' _txt'
return 1
/* ---------------------------------------------------------------------
 * Create Panel Input Field
 * ---------------------------------------------------------------------
 */
fssfieldL:
  parse arg row,col,attr,field,vlen,vinit,reread
  if reread='' then reread=1
  len=length(vinit)
  if len=0 then vinit=' '
  if len<=1 then vinit=copies(vinit,vlen)
     else vinit=Left(vinit,vlen)
  col=col+1
 'FIELD  'row col attr field vlen ' vinit'
  if reread=0 then return 0
  if datatype(_screen.inputvar.0)<>'NUM' then _screen.inputvar.0=0
  lhi=_screen.inputvar.0+1
  _screen.inputvar.lhi=field
  _screen.inputvar.0=lhi
return 1
/* ---------------------------------------------------------------------
 * Fetch Values of all Input Fields
 * ---------------------------------------------------------------------
 */
GetFields:
 'GET AID AID'
  do _i=1 to _screen.inputvar.0
     'GET FIELD '_screen.INPUTVAR._i' _'_screen.INPUTVAR._i
  end
  command=translate(strip(translate(_cmd,,'_')))
  _cm=Copies('_',54)
  'SET FIELD CMD  _cm'
return
/* ---------------------------------------------------------------------
 * Check for Line Commands
 * ---------------------------------------------------------------------
 */
GetLineCMD:
  do _i=1 to #lstheight
    'GET FIELD LINEA.'_i' _lina'
     if datatype(_lina)='NUM' then iterate
     if _lina='' then leave
     if substr(_lina,1,1)='.' then iterate
     if substr(_lina,1,1)='*' then leave
    'GET FIELD IBUFFER.'_i' _line'
     return _lina';'_line
  end
return ''
/* ---------------------------------------------------------------------
 * Move BUFFER Stem into internal Buffer
 * ---------------------------------------------------------------------
 */
fetchBuffer:
  drop ibuffer.
  do k=0 to BUFFER.0
     ibuffer.k=buffer.k
  end
linc=IBUFFER.0
return
/* ---------------------------------------------------------------------
 * INIT FSS and setup List Screen
 * ---------------------------------------------------------------------
 */
SCREENINIT:
  cmdlen=#scrWidth-38
  nxtoff=cmdlen+9
/* FSS requires offset as real offset of text or fileld
   as this is not easy readable we re-calculate in the FSSTEXT/FSSFIELD
   function. The call has now real offset, which means the 1. byte
   contains attribute byte, byte starts with real output value
 */
  call fsstextL  1,1,  #PROT+#HI+#RED,'CMD ==>'
  call fssfieldL 1,9,  #HI+#RED,CMD,cmdlen,"_"
  call fssfieldL 1,nxtoff, #PROT+#HI+#RED,ROWS,17," "
  call fssfieldL 1,nxtoff+17, #PROT+#YELLOW,OFS,7,"COL 001"
  call fssfieldL 1,nxtoff+25, #PROT+#HI+#WHITE,BUFNO,3," "
  topdata=center(' Top of Data ',#LSTWIDTH,'*')
  toplina=copies('*',#LAL)
  blk=copies(' ',#LSTWIDTH)
  loff=2+#lal
  do j=1 to #lstheight
     call fssfieldL j+1,1, #white,'LINEA.'j,#LAL,copies(' ',#LAL),0
     call fssfieldL j+1,loff,#prot+#hi+#green,'IBUFFER.'j,#LSTWIDTH,blk,0
  end
 'SET CURSOR CMD'
  do i=1 to #SCRHEIGHT
     _action.i=value('#PFK'right(i,2,'0'))
  end
  _action.enter=#Enter
return
/* ---------------------------------------------------------------------
 * Display Help Information
 * ---------------------------------------------------------------------
 */
fetchhelp:
drop buffer.
Buffer.1=copies('-',#LSTWIDTH)
Buffer.2='Display REXX Results in Formatted List Screens'
Buffer.3=copies('-',#LSTWIDTH)
Buffer.4='The results to be displayed need to be stored in the'
Buffer.5='Stem Variable BUFFER.n, n is line number. BUFFER.0 must'
Buffer.6='contain the number of lines stored in Buffer.'
Buffer.7=' '
Buffer.8='To Display the Buffer CALL FMTLIST.'
Buffer.9=' '
Buffer.10='FMTLIST supports the following PF Keys:'
Buffer.11='   PF1    Display Help '
Buffer.12='   PF3    Return to previous FMTLIST Buffer if any, or leave'
Buffer.13='   PF7    Scroll Forward, full page or lines given in Command Line'
Buffer.14='   PF8    Scroll Backward, full page or lines given in Command Line'
Buffer.15='   PF10   Show Output shifted 50 Bytes to the left'
Buffer.16='   PF11   Show Output shifted 50 Bytes to the right'
Buffer.0=16
return
/* ---------------------------------------------------------------------
 * INIT Environment, set 3270 screen size
 * ---------------------------------------------------------------------
 */
fmtLInit:
  CALL FSSCLOSE
  CALL FSSINIT
  #lal=5
  lastinstr=SYSVAR('RXINSTRC')
  if datatype(lineareaLen)='NUM' then #LAL=LineareaLen
  if #lal>12 then #lal=12
  if #lal<1 then #lal=1
  #lal=trunc(#lal)
  if LineareaChar==''then #lch='' /* Line Area default is numbering */
     else #lch=substr(LineareaChar,1,1)
  #scrHeight=FSSHeight()     /* Number of lines   in 3270  screen */
  #scrWidth=FSSWidth()       /* Number of columns in 3270  screen */
  if #scrHeight*#scrWidth > 4096 then do
     _twidth=trunc(4096/#scrheight)
     _theight=#scrheight
     if _twidth<80 then do
        _twidth=80
        _theight=trunc(4096/_twidth)
        if _theight>#scrheight then _theight=#scrheight
     end
     #scrwidth=_twidth
     #scrheight=_theight
  end
  #lstWidth =#scrwidth-3-#LAL  /* Number of Columns in list area  */
  #lstHeight=#scrHeight-1      /* Number of Lines   in list area  */
  if datatype(buffer.0)<>'NUM' then call fetchHelp
  if datatype(_fssinit)<>'NUM' then _fssinit=1
     else _fssinit=_fssinit+1
  call SCREENINIT
return
