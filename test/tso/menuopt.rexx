/* REXX - FSSMENU on a 3270 with an option line (_SCREEN.MENUOPTION), */
/* run by test/tso/fssmenu.lua, as MENUTST (#413, #422).              */
call import fssapi
address fss
_screen.MenuOption = 1
call fssmenu 1, 'ONE', 'First option',  "_screen.picked='one'"
call fssmenu 2, 'TWO', 'Second option', "_screen.picked='two'"
_screen.picked = 'none'
key = fssmenu('$DISPLAY')
say 'FSSMENU RETURNED' key 'SELECTED' _screen.picked
exit 0
