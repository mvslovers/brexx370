/* ---------------------------------------------------------------------
 * Create FSS Menu lines and Display/Select Program
 * ............................... Created by PeterJ on 08. October 2019
 * .............................. Amended by PeterJ on 07. February 2020
 * ---------------------------------------------------------------------
 */
/* ---------------------------------------------------------------------
 * Define Menu Line
 * ---------------------------------------------------------------------
 */
FSSMENU:
 PARSE ARG NUM,SHORT,LONG,action,startRow,startCol
 /* ........... Display a generated Screen .......................... */
 if translate(arg(1))='$DISPLAY' then do
    _screen.$_ScreenOwner='FSSMENU'
    if _screen.Ftrace=1 then call fssftrace 'Entering FSSMENU'
    frc=FSSMENUDIALOG(arg(2),arg(3))
    if _screen.Ftrace=1 then call fssftrace 'Leaving FSSMENU',100
    return frc
 end
 if datatype(_MENU.#_num.0)<>'NUM' then do
    _menu.#_menurow =getscrini('menurow',4,'RESET')-1
    _menu.#_menucol =getscrini('menucol',6,'RESET')
    _menu.#_menucol2=getscrini('menucol2',_menu.#_menucol+3,'RESET')
    _menu.#_menucol3=getscrini('menucol3',_menu.#_menucol+14,'RESET')
    if datatype(startrow)='NUM' then _menu.#_menurow=startrow-1
    if datatype(startcol)='NUM' then _menu.#_menucol=startcol
    _menu.#_num.0=0
 end
 mxi=_menu.#_num.0+1
 _menu.#_num.0     =mxi
 _menu.#_num.mxi   =translate(num)   /* option Number     */
 _menu.#_short.mxi =short /* option Short Text */
 _menu.#_long.mxi  =long
 _menu.#_action.mxi=action
RETURN
/* ---------------------------------------------------------------------
 * Menu Dialog Handler
 * ---------------------------------------------------------------------
 */
FSSMENUDIALOG: Procedure expose _screen. _menu. fSSparms. (public)
 call FSSMENULocal
 call FSSMENUCreate 0
 fssmerror=0
 if fssTitleSet<>1 &  ,
    fssCheck('ZERRSM')=0 then call FSSMError 'ZERRSM'
 call fssfield 'ZCMD',3,5,72,#WHITE,'_'
 _callback=arg(1)
 _enterexit=arg(2)
 sel=fssfget('zcmd')
 zcmdln=length(sel)
 zcmdinit=copies(' ',zcmdln)
/* .... Display Menu .....................................*/
 do forever
    call fsscursor 'ZCMD'
   /* UPDATE FIELD VALUES */
    if _callback<>'' then interpret 'call '_callback
   /* ............ REFRESH / SHOW SCREEN .................*/
    _pfkey=fssrefresh()
    error=0
    if pfexit(_pfkey)=1 then return _pfkey
    sel = translate(strip(translate(fssfget('zcmd'))))
    if sel='X'  then return 'PF03'
    if sel='=X' then return 'PF03'
    call fssZerrsm,''
    call fssZerrlm ' '
    call fssfSet 'ZCMD',zcmdinit
   'SET COLOR ZCMD #HI+#RED+#USCORE'  /* Refresh underscore attribute */
    if _screen.Ftrace=1 then call fssftrace "Selection '"sel"'"
    if sel='' & _pfkey='ENTER' then iterate
    if _enterexit<>'' then do
       prc=ProcessEnter()
       if prc=0 then iterate    /* Input processed, proceed  */
       if prc=8 then leave      /* end of menu requested     */
    end
    call findOption
 end
 CALL FSSCLOSE
return _PFKEY
/* ---------------------------------------------------------------------
 * Was END/CANCEL requested?
 * ---------------------------------------------------------------------
 */
pfexit:
 if _pfkey=='PF03' then return 1
 if _pfkey=='PF04' then return 1
 if _pfkey=='PF15' then return 1
 if _pfkey=='PF15' then return 1
 if _pfkey=='PF16' then return 1
return 0
/* ---------------------------------------------------------------------
 * Process Enter Exit
 *   rc =0 then iterate    Enter Exit processed input,proceed
 *   rc =8 then leave      Enter Exit requests End of Menu
 *   rc =4 then nop        Enter Exit says it is not mine
 * ---------------------------------------------------------------------
 */
ProcessEnter:
  if _screen.Ftrace=1 then call fssftrace "Entering "_enterexit sel
  interpret 'call '_enterexit' _pfkey,sel' /*check in user rexx*/
  if _screen.Ftrace=1 then call fssftrace _enterexit" RC "result
  return result
/* ---------------------------------------------------------------------
 * Find Option
 * ---------------------------------------------------------------------
 */
findOption:
 do ki=1 to _scrItems
    if sel<>_scrOption.ki then iterate
    sel=''  /* Reset option to signal it was found */
    _w1=translate(word(_scrAction.ki,1))
    if _w1='CALL' then call fssOPTREXX substr(_scrAction.ki,5)
    else if _w1<>'TSO' then interpret _scrAction.ki
    else do
       _exc=strip(substr(_scrAction.ki,4))
       Address TSO
         _exc
        'CLS'
       ADDRESS FSS
    end
 end
 if error=1 then return 1
 if _w1='CALL' then call FSSMENUCreate recovery
 if sel<>'' then do
    call fssZERRSM 'Invalid Option 'sel,'NOTEST'
    call fssZERRLM 'Option 'sel', is not defined in the Menu'
 end
return 1
/* ---------------------------------------------------------------------
 * Call Option REXX
 * ---------------------------------------------------------------------
 */
FSSOPTREXX: Procedure expose _screen. _menu. fSSparms. (public)
 parse arg _exec
 oldtoken=fsstoken()
 signal on syntax name _optError
 interpret 'CALL '_exec
 signal off syntax
 if oldtoken<>fsstoken() then recovery=1
    else recovery=0
 error=0
return
_optError:
 call fssZERRSM 'unknown REXX '_exec
 call fssZERRLM _exec' is an unknown REXX Script'
 recovery=0
 error=1
 signal off syntax
 return
/* ---------------------------------------------------------------------
 * Create/Re-Create Menu
 * ---------------------------------------------------------------------
 */
FSSMENUCreate:
/*
 if fssstatus()=1 & arg(1)=0 then call FSSFastINIT2 /* recover Vars */
 else do
    call fssclose
    call fssinit 'FSSMENU'
 end
*/
 call fssclose
 call fssinit 'FSSMENU'
 if _scrOption =1  then call fssOption
 if _scrMessage=1  then call fssMessage FSSHeight()-1
 if _scrtitle <>'' then call fsstitle _scrTitle
 if _scrfooter<>'' then call fssfooter _scrFooter
 do mxi=1 to _scrItems
    _mrow=_scrMRow+mxi
    call fsstext _scrOption.mxi, _mrow,_scrMCol ,,#prot+#white
    call fsstext _scrShort.mxi,  _mrow,_scrMCol2,,#prot+#turq
    call fsstext _scrLong.mxi ,  _mrow,_scrMCol3,,#prot+#green
 end
return
/* ---------------------------------------------------------------------
 * Copy Menu Variables to local Variables
 * ---------------------------------------------------------------------
 */
FSSMENULocal:
 _scrOption =getSCRini('MenuOption',0,'RESET')
 _scrMessage=getSCRini('MenuMessage',0,'RESET')
 _scrtitle  =getscrini('Menutitle','','RESET')
 _scrfooter =getscrini('Footer','','RESET')
 _scrMrow   =_menu.#_menurow
 _scrMcol   =_menu.#_menucol
 _scrMCol2  =_menu.#_menucol2
 _scrMCol3  =_menu.#_menucol3
 do mxi=1 to _menu.#_num.0
    _scrOption.mxi=_menu.#_num.mxi
    _scrShort.mxi=_menu.#_short.mxi
    _scrLong.mxi=_menu.#_long.mxi
    _scrAction.mxi=_menu.#_action.mxi
 end
 _scrItems=mxi-1
 _menu.#_num.0=' '
return
/* ---------------------------------------------------------------------
 * Check Mandatory Fields required to run FSSMENU
 * ---------------------------------------------------------------------
 */
FSSMError:
 if fssmerror=0 then say '***** FSS MENU Screen Definition Error *****'
 say "> Mandatory field '"arg(1)"' is not defined"
 fssmerror=1
return
