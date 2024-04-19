/* ---------------------------------------------------------------------
 * Create FMT Menu Full Screen Menu definition, Display and Select REXX
 * .............................. Created by PeterJ on 07. February 2020
 * ---------------------------------------------------------------------
 */
/* ---------------------------------------------------------------------
 * Request Input from user via Formatted Screen in 3 Column Format
 * ---------------------------------------------------------------------
 */
FMTMENU:
  PARSE ARG _p0,_p1,LONG,action
  if translate(_p0)='$DISPLAY' then return FMTMENUDISPLAY(_p1)
  if datatype(_$menu.#_num.0)<>'NUM' then _$menu.#_num.0=0
  mxi=_$menu.#_num.0+1
  _$menu.#_num.0    =mxi
  _$menu.#_num.mxi  =_p0   /* option number     */
  _$menu.#_short.mxi=_p1   /* option short text */
  _$menu.#_long.mxi =long
  _$menu.#_action.mxi='call 'action
return 0
/* ---------------------------------------------------------------------
 * Display define Menu
 * ---------------------------------------------------------------------
 */
FMTMENUDISPLAY:
  parse arg title
  call import FSSAPI
  ADDRESS FSS
  call FSSINIT
  botline=GetScrIni('footer')
 /* ..... Create Title Line ..... */
  _screen.Menutitle=title
  _screen.MenuOption=1
  _screen.MenuMessage=1
  _screen.MenuFooter=botline
  _screen.MenuRow =GetScrIni('MenuRow',4)
  _screen.MenuCol =GetScrIni('MenuCol',8)
  _screen.MenuCol2=GetScrIni('MenuCol2',_screen.MenuCol+6)
  _screen.MenuCol3=GetScrIni('MenuCol3',_screen.MenuCol2+12)
 /* ..... PUSH Menu Items in FSSMENU definitions ........... */
  mxi=_$menu.#_num.0
  _$menu.#_num.0=0
  do #fxi=1 to mxi
     call fssmenu _$MENU.#_num.#fxi,
        ,_$MENU.#_short.#fxi,
        ,_$MENU.#_long.#fxi,
        ,_$MENU.#_action.#fxi
  end
/* ---------------------------------------------------------------------
 * Display Screen and handle User's Input
 * ---------------------------------------------------------------------
 */
return FSSMENU('$DISPLAY')       /* FSS Env.will be closed in FSSMENU */
