/* REXX - FSSMENU on a 3270 without an option line (#413, #422).      */
/* Run by test/tso/fssmenu.lua: option 2 sets _SCREEN.PICKED, PF3     */
/* ends the menu. ZCMD was preset with '_', so before #413 every      */
/* option was "Invalid Option" and PICKED stayed NONE.                */
call import fssapi
address fss
/* without a title FSSMENU wants a field ZERRSM of its own */
_screen.MenuTitle = 'FSSMENU TEST'
call fssmenu 1, 'ONE', 'First option',  "_screen.picked='one'"
call fssmenu 2, 'TWO', 'Second option', "_screen.picked='two'"
_screen.picked = 'none'
key = fssmenu('$DISPLAY')
say 'FSSMENU RETURNED' key 'SELECTED' _screen.picked
exit 0
