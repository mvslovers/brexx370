/* ---------------------------------------------------------------------
 * FSS API
 * .................................. Created by PeterJ on 31. July 2019
 * .............................. Amended by PeterJ on 07. February 2020
 * ............................. Changed by PeterJ on 28. September 2021
 * ............................... Changed by PeterJ on 14. January 2023
 * ---------------------------------------------------------------------
 */
/* ---------------------------------------------------------------------
 * Create Panel Text Field
 * ---------------------------------------------------------------------
 */
fsstext:
  parse arg txt,#ROW,#COL,tlen,attr
  if sRange(#ROW,1,FSSSCRHEIGHT)>0 then call FSSHeightError txt
  if datatype(tlen)='NUM' then txt=left(txt,tlen)
     else tlen=length(txt)
  if sRange(#COL+tlen,1,FSSSCRWIDTH)>0 then do
  /* txt=substr(txt,1,tlen-_Roverflow)  */
     call FSSWidthError txt,tlen
  end
  if attr='' then attr=#GREEN
  attr=addSCR(attr,#PROT) /* Add protection byte, if not set yet */
/* FSS requires offset as real offset of text or fileld, therefore +1 */
  #COL=#COL+1
  _txt=txt
 'TEXT '#ROW #COL attr' _txt'
return #COL+tlen
/* ---------------------------------------------------------------------
 * Create Panel Input Field
 * ---------------------------------------------------------------------
 */
fssfield:
  parse arg _field,#ROW,#COL,vlen,attr,vinit
  _field=strip(translate(_field))
  if vlen='' then vlen=25
  if sRange(#ROW,1,FSSSCRHEIGHT)>0 then call FSSHeightError _field
 if sRange(#COL+vlen,1,FSSSCRWIDTH)>0 then call FSSWidthError _field,vlen
  if FSSparms._#var._field=1 then call FSSDupField _field
  if attr='' then attr=#GREEN
  FSSparms._#var._field=1
  FSSparms._#fieldcount=FSSparms._#fieldcount+1
  _fcount=FSSparms._#fieldcount
  FSSparms._#field._fcount=_field
/* FSS requires offset as real offset of text or fileld, therefore +1 */
  #COL=#COL+1
  if vinit='' then vinit=' '
  if length(vinit)=1 then _preset=copies(substr(vinit,1,1),vlen)
     else _preset=left(vinit,vlen)
 'FIELD  '#ROW #COL attr _field vlen ' _preset'
return #COL+vlen
fssfieldSH:
  parse upper arg _field,#ROW,#COL,vlen,attr,vinit
  if attr='' then attr=#GREEN
  #COL=#COL+1
  vinit=copies(' ',vlen)
 'FIELD  '#ROW #COL attr _field vlen ' vinit'
return #COL+vlen
/* ---------------------------------------------------------------------
 * Define and Set Title of Screen
 * ---------------------------------------------------------------------
 */
FSSTITLE:
  parse arg fssTitle,fssattr,delim
  if delim='' then delim='-'
     else delim=substr(delim,1,1)
  if fssattr='' then fssattr=#WHITE
  fssattr=addSCR(fssattr,#PROT) /* Add protection byte */
  fssFullTitle=CENTER(' 'fsstitle' ',FSSSCRWIDTH,delim)
  nxt=FSSField('ZTITLE',1,1,FSSSCRWIDTH-1,fssattr,fssFULLTitle)
  fssTitleSet=1
  fssTitlemod=0
return fssTitle
/* ---------------------------------------------------------------------
 * Define Message Line of Screen
 * ---------------------------------------------------------------------
 */
FSSMessage:
  if fsscheck("#ZERRLM")=0 then return 0  /* already defined */
  parse arg _fsROW,_fsatr
  if _fsatr='' then _fsatr=#RED
  if _fsROW='' then _fsROW=3
  fssattr=addSCR(_fsatr,#PROT) /* Add protection byte */
  nxt=FSSField('#ZERRLM',_fsROW,1,FSSSCRWIDTH-2,_fsatr,' ')
return 0
/* ---------------------------------------------------------------------
 * Set Footer Line of Screen
 * ---------------------------------------------------------------------
 */
FSSFooter:
  if FSSparms._#var.FOOTER<>1 then do
     if arg(2)='' then fssattr=#white
        else fssattr=arg(2)
     fssattr=addSCR(fssattr,#PROT) /* Add protection byte */
     _#noDupcheck=1
     nxt=FSSField('ZFooter',fssscrheight,1,FSSSCRWIDTH-2,fssattr,arg(1))
     return
  end
  CALL FSSFSET 'ZFOOTER',arg(1)
return fssTitle
/* ---------------------------------------------------------------------
 * Set Short Message of Screen
 * ---------------------------------------------------------------------
 */
FSSZERRSM:
  parse arg _fzmsg
  if FSSparms._#var.ZERRSM=1 then call FSSZERRSET _fzmsg
  else if fssTitleSet<>1     then call FSSZERRSET _fzmsg
  else do  /* ZERRSM is part of title line */
     if strip(_fzmsg)='' then do
        call FSSFSET 'ZTITLE',fssfulltitle
        fssTitlemod=0  /* Title has been reset */
     end
     else do
        erln=length(_fzmsg)+1
        if erln>25 then erln=25
        _title=substr(fssFullTitle,1,FSSSCRWIDTH-erln-1)' '_fzmsg
        call FSSFSET 'ZTITLE',_title
        fssTitlemod=1  /* Title has been modified */
     end
  end
return 0
/* ---------------------------------------------------------------------
 * Fast FSSFSET, without deeper checking of type, etc.
 * ---------------------------------------------------------------------
 */
FSSZERRSET:
  _TMPI=arg(1)' '     /* Add Blank to enforce it as String */
/* handle ZERRSM over FSSZERRSM */
 Address FSS
  'SET FIELD ZERRSM _TMPI'
return
/* ---------------------------------------------------------------------
 * Set Long Message of Screen
 * ---------------------------------------------------------------------
 */
FSSZERRLM:
  if fsscheck("#ZERRLM")>0 then return 0
/* if FSSparms._#var.#ZERRLM<>1 then return */ /* no long message defined */
  parse arg _zerrlm
  if _zerrlm=='' then return
  call FSSFSET '#ZERRLM',_zerrlm
  fssLongmsg=1  /* Long message set */
return
/* ---------------------------------------------------------------------
 * Set Option Line (default Line 2)
 * ---------------------------------------------------------------------
 */
FSSOPTION:
  return FSSTOPLINE('Option ===>',arg(1),arg(2),arg(3),arg(4))
return
/* ---------------------------------------------------------------------
 * Set Command Line (default Line 2)
 * ---------------------------------------------------------------------
 */
FSSCOMMAND:
  return FSSTOPLINE('COMMAND ===>',arg(1),arg(2),arg(3),arg(4))
/* ---------------------------------------------------------------------
 * Set Top Input Line (default Line 2) OPTION,COMMAND etc.
 * ---------------------------------------------------------------------
 */
FSSTOPLINE:
  parse arg ttitle,cROW,llen,fssattr1,fssattr2
  if cROW='' then cROW=2
  if fssattr1='' then fssattr1=#PROT+#WHITE
  if fssattr2='' then fssattr2=#HI+#RED+#USCORE
  nxt=FSSTEXT(ttitle,cROW,1,,fssattr1)
  if llen='' then llen=FSSSCRWIDTH-nxt
  nxt=FSSFIELD("ZCMD",cROW,nxt,llen,fssattr2)
return llen
/* ---------------------------------------------------------------------
 * Defines Message Line (Default Line 3)
 * ---------------------------------------------------------------------
 */
FSSMSG:
  parse arg cROW,fssattr
  if cROW='' then cROW=3
  if fssattr='' then fssattr=#prot+#hi+#red
  CALL FSSFIELD 'ZMSG',cROW,1,FSSSCRWIDTH-2,fssattr
RETURN
/* ---------------------------------------------------------------------
 * Pre-Set Input Field with value
 * ---------------------------------------------------------------------
 */
FSSFSET:
  parse arg _field,_content
  _field=strip(translate(_field))
  if FSSparms._#var._field<>1 | fsscheck(_field)=4 then do
    'GET FIELD '_field' _has'
     if strip(_has)='' then do
        if _field<>'ZERRSM' then call FSSnoField  /* also exit */
        if FSSparms._#var.#ZERRLM=1 then _field=ZERRLM
        else if FSSparms._#var.ZMSG=1 then _field=ZMSG
        if _field='ZERRSM' then call FSSnoField  /* also exit */
     end
  end
/* FSS SET Field seems to have problems with plain integers  */
  _TMPI=_content' '      /* Add Blank to enforce it as String */
/* handle ZERRSM over FSSZERRSM */
  if _field='ZERRSM' then call FSSZERRSM   /* also exit */
     else 'SET FIELD '_field' _TMPI'
return 0
/* ---------------------------------------------------------------------
 * Quick set of Input Field with value, check was already performed
 * ---------------------------------------------------------------------
 */
FSSQSET:
  parse arg _field,_content
  _field=upper(_field)' '     /* Add Blank to enforce it as String */
  _content=_content' '          /* Add Blank to enforce it as String */
  'SET FIELD '_field' _content'
return
/* ---------------------------------------------------------------------
 * Check existence of field in FSS Buffer
 * ---------------------------------------------------------------------
 */
FSSCHECK:
  parse upper arg _field
 'CHECK FIELD '_field
return rc
/* ---------------------------------------------------------------------
 * Retrieve User Value from Input Field
 * ---------------------------------------------------------------------
 */
FSSFGET:
  parse upper arg _field
  if FSSparms._#var._field<>1 then call FSSnoField _field
 'GET FIELD '_field' _content'
return _content
/* ---------------------------------------------------------------------
 * Fetch contents of all Fields
 * ---------------------------------------------------------------------
 */
FSSFGETALL:
  do #k=1 to FSSparms._#fieldcount
     _field=FSSparms._#field.#k
    'GET FIELD '_field' '_field
    interpret _field'=strip('_field')'
  end
return FSSparms._#fieldcount
/* ---------------------------------------------------------------------
 * Set Cursor field
 * ---------------------------------------------------------------------
 */
FSScursor:
  parse upper arg  _field
  if FSSparms._#var._field<>1 then call FSSnoField _field
 'SET CURSOR '_field
return _content
/* ---------------------------------------------------------------------
 * Set Cursor field
 * ---------------------------------------------------------------------
 */
FSScursor:
  parse upper arg  _field
  if FSSparms._#var._field<>1 then call FSSnoField _field
 'SET CURSOR '_field
return _content
fssgetcurpos:
 'GET CURPOS _cpos'
return _cpos
fsssetcurpos:
 'SET CURPOS 'arg(1)
return _cpos
curs2pos:
  parse arg _row,_col
return (_row-1)*fssWidth()+(_col-1)
pos2curs:
  parse arg offset
  max_col=fsswidth()
  row = (offset % max_col)+1;
  col = (int(offset // max_col))+1;
return row'/'col
/* ---------------------------------------------------------------------
 * Set color of field
 * ---------------------------------------------------------------------
 */
FSScolour:
FSScoLor:
  parse upper arg  _field,_fcolor
    'SET COLOR '_field' '_fcolor
  return 0
/* ---------------------------------------------------------------------
 * Fetch Return Key
 * ---------------------------------------------------------------------
 */
FSSKEY:
 parse upper arg _temp
 'GET AID _returnKey'
 if _temp='' then return _returnKey
 if abbrev('CHAR',_temp)>0 then return FSSUsedKey(_returnKey)
return _returnKey
/* ---------------------------------------------------------------------
 * Display Formatted Screen
 * ---------------------------------------------------------------------
 */
FSSDISPLAY:
FSSREFRESH:
 parse upper arg _rtp
 if _screen.Ftrace<>1 then do
   'REFRESH '
    return fsskey(_rtp)
 end
 /* else Function Trace is requested */
 'REFRESH '
  _temp=fsskey(_rtp)
  if arg(1)='' then say time('L')' User Action 'FSSUsedKey(_temp)
     else say time('L')' User Action '_temp
return _temp
/* ---------------------------------------------------------------------
 * Init FSS Environment
 * ---------------------------------------------------------------------
 */
FSSINIT:
 'INIT'
 drop FSSparms.
 FSSSCRWIDTH=FSSWidth()
 FSSSCRHEIGHT=FSSHeight()
 FSSparms._#fieldcount=0
FSSAPPL:
 parse upper arg _fssappl
 if _fssappl='' then _fssappl='UNKNOWN'
 PARSE VALUE TIME('L') WITH __HH':'__MM':'__SS'.'__HS
 __hhsec= __HH*360000+__MM*6000+__SS*100+__HS
 _SCREEN.$_SCREENAPPL=_fssappl' '__hhsec
return
/* ---------------------------------------------------------------------
 * Fetch Variables, when SCREEN is still active, but REXX vars are lost
 * ---------------------------------------------------------------------
 */
FSSFastINIT:
  call FSSAPPL arg(1)
  FSSparms._#fieldcount=0
FSSFastINIT2:
  #PROT=    48
  #NUM=     16
  #HI=      8
  #NON=     12
  #BLINK=   15794176
  #REVERSE= 15859712
  #USCORE=  15990784
  #BLUE=    61696
  #RED=     61952
  #PINK=    62208
  #GREEN=   62464
  #TURQ=    62720
  #YELLOW=  62976
  #WHITE=   63232
  FSSSCRWIDTH=FSSWidth()
  FSSSCRHEIGHT=FSSHeight()
  #ENTER=125
  #PFK01=241
  #PFK02=242
  #PFK03=243
  #PFK04=244
  #PFK05=245
  #PFK06=246
  #PFK07=247
  #PFK08=248
  #PFK09=249
  #PFK10=122
  #PFK11=123
  #PFK12=124
  #PFK13=193
  #PFK14=194
  #PFK15=195
  #PFK16=196
  #PFK17=197
  #PFK18=198
  #PFK19=199
  #PFK20=200
  #PFK21=201
  #PFK22=74
  #PFK23=75
  #PFK24=76
  #CLEAR=109
  #RESHOW=110
return
/* ---------------------------------------------------------------------
 * Terminate FSS Environment
 * ---------------------------------------------------------------------
 */
FSSTERM:
FSSTERMINATE:
FSSCLOSE:
 ADDRESS FSS 'TERM'
 _SCREEN.$_SCREENAPPL=''
 return
/* ---------------------------------------------------------------------
 * Return Screen Width
 * ---------------------------------------------------------------------
 */
FSSwidth:
 'GET WIDTH _scrw'
return _scrw
/* ---------------------------------------------------------------------
 * Return Screen Height
 * ---------------------------------------------------------------------
 */
FSSheight:
 'GET HEIGHT _scrh'
return _scrh
/* ---------------------------------------------------------------------
 * Return Screen Height
 * ---------------------------------------------------------------------
 */
 FSSMetrics:
  parse upper arg __details
 'GET METRICS _#defined '__details
  __fi=0
  do until _#defined=''
     parse value _#defined with _fentry';'_#defined
     if _fentry='' then iterate
     __FI=__fi+1
     if __details='DETAILS' then do
        parse value _fentry with _fssName.__FI' '||,
                    _fssOffset.__FI' '_fssLength.__FI
        _fssRow.__FI=_fssOffset.__FI%FSSSCRWIDTH+1
        _fssCol.__FI=_fssOffset.__FI//FSSSCRWIDTH%1+1
     end
     else _fssName.__FI=_fentry
  end
  _fssName.0=__FI
return
/* ---------------------------------------------------------------------
 * Return Used Key after getting control in Screens or Menus
 * ---------------------------------------------------------------------
 */
FSSUsedKey:
  parse arg #inkey
  if GETG('_3270KEY_init')='' then do
     CALL SETG('_3270KEY_241','PF01')
     CALL SETG('_3270KEY_242','PF02')
     CALL SETG('_3270KEY_243','PF03')
     CALL SETG('_3270KEY_244','PF04')
     CALL SETG('_3270KEY_245','PF05')
     CALL SETG('_3270KEY_246','PF06')
     CALL SETG('_3270KEY_247','PF07')
     CALL SETG('_3270KEY_248','PF08')
     CALL SETG('_3270KEY_249','PF09')
     CALL SETG('_3270KEY_122','PF10')
     CALL SETG('_3270KEY_123','PF11')
     CALL SETG('_3270KEY_124','PF12')
     CALL SETG('_3270KEY_193','PF13')
     CALL SETG('_3270KEY_194','PF14')
     CALL SETG('_3270KEY_195','PF15')
     CALL SETG('_3270KEY_196','PF16')
     CALL SETG('_3270KEY_197','PF17')
     CALL SETG('_3270KEY_198','PF18')
     CALL SETG('_3270KEY_199','PF19')
     CALL SETG('_3270KEY_200','PF20')
     CALL SETG('_3270KEY_20' ,'PF21')
     CALL SETG('_3270KEY_74' ,'PF22')
     CALL SETG('_3270KEY_75' ,'PF23')
     CALL SETG('_3270KEY_76' ,'PF24')
     CALL SETG('_3270KEY_125','ENTER')
     CALL SETG('_3270KEY_109','CLEAR')
     CALL SETG('_3270KEY_110','RESHOW')
     CALL SETG('_3270KEY_init',1)
  end
  return GETG('_3270key_'#inkey)
/* ---------------------------------------------------------------------
 * Test Range of value
 * ---------------------------------------------------------------------
 */
SRange:
  parse arg _tvalue,_tfrom,_tto
  if _tvalue<_tfrom then return 8  /* less than minimum value ? */
  if _tvalue<=_tto  then return 0  /* Less EQ than maximum value ? */
  _Roverflow=_tvalue-_tto
return 8   /* Range exceeds maximum value */
/* ---------------------------------------------------------------------
 * Add SCreen Attribute Byte
 * ---------------------------------------------------------------------
 */
addSCR:
return c2d(bitor(d2C(arg(1),3),d2C(arg(2),3)))
/* ---------------------------------------------------------------------
 * FSS FTRACE reporting
 * ---------------------------------------------------------------------
 */
FSSFtrace:
  say time('L')' 'arg(1)
  if datatype(arg(2))='NUM' then call wait arg(2)
return
/* ---------------------------------------------------------------------
 * FSS Height Error
 * ---------------------------------------------------------------------
 */
FSSHeightError:
  parse arg _tf
  _tf=strip(_tf)
  say '***** FSS Formatted Screen Definition Error *****'
  say "> Definition '"_tf"' ROW "#ROW" outside Range 1 to "FSSSCRHEIGHT
  say '+++++ Formatted Screen Creation Terminated  +++++'
exit 8
/* ---------------------------------------------------------------------
 * GET Screen INI Variable
 * ---------------------------------------------------------------------
 */
GetScrIni:
  parse upper arg _#varname
  _#varvalue=value('_SCREEN.'_#varname)
  if _#varvalue=''         |  ,
     _#varvalue='_SCREEN.' |  ,
    '_SCREEN.'_#varname=_#varvalue then do /* if not defnd,set default*/
     interpret '_screen.'_#varname"='"arg(2)"'"
     return arg(2)
  end
  if arg(3)='RESET' then interpret '_screen.'_#varname"=''"
  if substr(_#varvalue,1,1)='#' then return value(_#varvalue) /* color*/
return _#varvalue
/* ---------------------------------------------------------------------
 * FSS Width Error
 * ---------------------------------------------------------------------
 */
FSSwidthError:
  parse arg _tf,_tl
  _tf=strip(_tf)
  say '***** FSS Formatted Screen Definition Error *****'
  say "> Definition '"_tf"' at column "#COL", length "_tl,
      " outside Range 1 to "FSSSCRWIDTH
  say '+++++ Formatted Screen Creation Terminated  +++++'
exit 8
/* ---------------------------------------------------------------------
 * FSS Error Duplicate Field Name
 * ---------------------------------------------------------------------
 */
FSSDupField:
  if _#noDupcheck=1 then do
     _#noDupcheck=0
     return 0
  end
  return 0
  say '***** FSS Formatted Screen Definition Error *****'
  say "> Field '"_field"' already defined"
  say '+++++ Formatted Screen Creation Terminated  +++++'
exit 8
/* ---------------------------------------------------------------------
 * FSS Error Requested Field Name not defined
 * ---------------------------------------------------------------------
 */
FSSNoField:
  say '***** FSS Formatted Screen Definition Error *****'
  say "> Field '"_field"' not defined"
  say 'Defined Fields'
  say '--------------'
  do _fni=1 to FSSparms._#fieldcount
     say '    'FSSparms._#field._fni
  end
  say '+++++ Formatted Screen Creation Terminated  +++++'
exit 8