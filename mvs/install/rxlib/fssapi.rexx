/* ---------------------------------------------------------------------
 * Create Panel Text Field
 * ---------------------------------------------------------------------
 */
fsstext:
  parse arg txt,row,col,tlen,attr
  if sRange(row,1,FSSSCRHEIGHT)>0 then call FSSHeightError txt
  if datatype(tlen)='NUM' then txt=left(txt,tlen)
     else tlen=length(txt)
  if sRange(col+tlen,1,FSSSCRWIDTH)>0 then call FSSWidthError txt,tlen
  if attr='' then attr=#GREEN
  attr=addSCR(attr,#PROT) /* Add protection byte, if not set yet */
/* FSS requires offset as real offset of text or fileld, therefore +1 */
  col=col+1
  _txt=txt
 'TEXT 'row col attr' _txt'
return col+tlen
/* ---------------------------------------------------------------------
 * Create Panel Input Field
 * ---------------------------------------------------------------------
 */
fssfield:
  parse arg _field,row,col,vlen,attr,vinit
  _field=translate(_field)
  if sRange(row,1,FSSSCRHEIGHT)>0 then call FSSHeightError _field
 if sRange(col+vlen,1,FSSSCRWIDTH)>0 then call FSSWidthError _field,vlen
  if FSSparms._#var._field=1 then call FSSDupField _field
  if attr='' then attr=#GREEN
  FSSparms._#var._field=1
  fssFieldCount=fssFieldCount+1
  FSSparms._#field.fssfieldCount=_field
/* FSS requires offset as real offset of text or fileld, therefore +1 */
  col=col+1
  if vinit='' then vinit=' '
  if length(vinit)=1 then _preset=copies(substr(vinit,1,1),vlen)
     else _preset=left(vinit,vlen)
 'FIELD  'row col attr _field vlen ' _preset'
return col+vlen
/* ---------------------------------------------------------------------
 * Set Title of Screen
 * ---------------------------------------------------------------------
 */
FSSTITLE:
  parse arg fssTitle,fssattr,delim
  if delim='' then delim='-'
     else delim=substr(delim,1,1)
  if fssattr='' then fssattr=#WHITE
  fssattr=addSCR(fssattr,#PROT) /* Add protection byte */
  fssFullTitle=CENTER(' 'fsstitle' ',FSSSCRWIDTH-1,delim)
  nxt=FSSField('ZTITLE',1,1,FSSSCRWIDTH-1,fssattr,fssFULLTitle)
  fssTitleSet=1
  fssTitlemod=0
return fssTitle
/* ---------------------------------------------------------------------
 * Set Title of Screen
 * ---------------------------------------------------------------------
 */
FSSZERRSM:
  parse arg zerrsm
  if fssTitleSet<>1 then call FSSFSET 'ZERRSM',zerrsm
  else do
     erln=length(zerrsm)+1
     if erln>25 then erln=25
     _title=substr(fssFullTitle,1,FSSSCRWIDTH-erln-1)' 'zerrsm
     call FSSFSET 'ZTITLE',_title
     fssTitlemod=1  /* Title has been modified */
  end
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
  parse arg ttitle,crow,llen,fssattr1,fssattr2
  if crow='' then crow=2
  if fssattr1='' then fssattr1=#PROT+#WHITE
  if fssattr2='' then fssattr2=#HI+#RED+#USCORE
  nxt=FSSTEXT(ttitle,crow,1,,fssattr1)
  if llen='' then llen=FSSSCRWIDTH-nxt
  nxt=FSSFIELD("ZCMD",crow,nxt,llen,fssattr2)
return ''
/* ---------------------------------------------------------------------
 * Defines Message Line (Default Line 3)
 * ---------------------------------------------------------------------
 */
FSSMSG:
  parse arg crow,fssattr
  if crow='' then crow=3
  if fssattr='' then fssattr=#prot+#hi+#red
  CALL FSSFIELD 'ZMSG',crow,1,FSSSCRWIDTH,fssattr
RETURN
/* ---------------------------------------------------------------------
 * Pre-Set Input Field with value
 * ---------------------------------------------------------------------
 */
FSSFSET:
  parse arg _field,_content,dropTest
  _field=translate(_field)
  if FSSparms._#var._field<>1 then call FSSnoField _field
/* FSS SET Field seems to have problems with plain integers  */
  _TMPI=_content' '      /* Add Blank to enforce it as String */
 'SET FIELD '_field' _TMPI'
return
/* ---------------------------------------------------------------------
 * Retrieve User Value from Input Field
 * ---------------------------------------------------------------------
 */
FSSFGET:
  parse upper arg _field,droptest
  if FSSparms._#var._field<>1 then call FSSnoField _field
 'GET FIELD '_field' _content'
return _content
/* ---------------------------------------------------------------------
 * Fetch contents of all Fields
 * ---------------------------------------------------------------------
 */
FSSFGETALL:
  do #k=1 to fssFieldCount
     _field=FSSparms._#field.#k
    'GET FIELD '_field' '_field
    interpret _field'=strip('_field')'
  end
return fssFieldCount
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
 * Set Color of field
 * ---------------------------------------------------------------------
 */
FSScolour:
FSScolor:
  parse upper arg  _field,color
    'SET COLOR '_field' 'color
  return
/* ---------------------------------------------------------------------
 * Fetch Return Key
 * ---------------------------------------------------------------------
 */
FSSKEY:
 'GET AID _returnKey'
return _returnKey
/* ---------------------------------------------------------------------
 * Display Formatted Screen
 * ---------------------------------------------------------------------
 */
FSSDISPLAY:
FSSREFRESH:
 'REFRESH'
return fssKey()
/* ---------------------------------------------------------------------
 * Init FSS Environment
 * ---------------------------------------------------------------------
 */
FSSINIT:
 'INIT'
 drop FSSparms.
 FSSSCRWIDTH=FSSWidth()
 FSSSCRHEIGHT=FSSHeight()
 call fssmaxbuf
 fssFieldCount=0
return
/* ---------------------------------------------------------------------
 * Limit size of Screen to 4096 Byte
 * ---------------------------------------------------------------------
 */
 fssmaxbuf:
  _fssbuflen=FSSSCRWIDTH*FSSSCRHeight
  if _fssbuflen<=4096 then return
  _twidth=trunc(4096/FSSSCRHeight)
  _theight=FSSSCRHeight
  if _twidth<80 then do
     _twidth=80
     _theight=trunc(4096/_twidth)
     if _theight>FSSSCRHeight then _theight=FSSSCRHeight
  end
  FSSSCRWIDTH=_twidth
  FSSSCRHEIGHT=_theight
  _fssbuflen=FSSSCRWIDTH*FSSSCRHeight
return
/* ---------------------------------------------------------------------
 * Terminate FSS Environment
 * ---------------------------------------------------------------------
 */
FSSTERM:
FSSTERMINATE:
FSSCLOSE:
 'TERM'
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
 * Test Range of value
 * ---------------------------------------------------------------------
 */
SRange:
  parse arg _tvalue,_tfrom,_tto
  if _tvalue<_tfrom then return 8  /* less than minimum value ? */
  if _tvalue>_tto   then return 8  /* greater than maximum value ? */
return 0   /* Range is ok */
/* ---------------------------------------------------------------------
 * Add SCreen Attribute Byte
 * ---------------------------------------------------------------------
 */
addSCR:
return c2d(bitor(d2C(arg(1),3),d2C(arg(2),3)))
/* ---------------------------------------------------------------------
 * FSS Height Error
 * ---------------------------------------------------------------------
 */
FSSHeightError:
  parse arg _tf
  _tf=strip(_tf)
  say '***** FSS Formatted Screen Definition Error *****'
  say "> Definition '"_tf"' row "row" outside Range 1 to "FSSSCRHEIGHT
  say '+++++ Formatted Screen Creation Terminated  +++++'
exit 8
/* ---------------------------------------------------------------------
 * FSS Width Error
 * ---------------------------------------------------------------------
 */
FSSwidthError:
  parse arg _tf,_tl
  _tf=strip(_tf)
  say '***** FSS Formatted Screen Definition Error *****'
  say "> Definition '"_tf"' at column "col", length "_tl,
      " outside Range 1 to "FSSSCRWIDTH
  say '+++++ Formatted Screen Creation Terminated  +++++'
exit 8
/* ---------------------------------------------------------------------
 * FSS Error Duplicate Field Name
 * ---------------------------------------------------------------------
 */
FSSDupField:
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
  do _fni=1 to FSSFieldCount
     say '    'FSSparms._#field._fni
  end
  say '+++++ Formatted Screen Creation Terminated  +++++'
exit 8
