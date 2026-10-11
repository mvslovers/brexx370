/* REXX - FSSMENU on a 3270 without a title (#424), run by            */
/* test/tso/fssmenu.lua as MENUTST. Without a title the short message */
/* ("Invalid Option") needs a field ZERRSM, which FSSMENU did not     */
/* define: the menu stopped with "Mandatory field 'ZERRSM' is not     */
/* defined" before it was shown.                                      */
call import fssapi
address fss
call fssmenu 1, 'ONE', 'First option',  "_screen.picked='one'"
call fssmenu 2, 'TWO', 'Second option', "_screen.picked='two'"
_screen.picked = 'none'
key = fssmenu('$DISPLAY')
say 'FSSMENU RETURNED' key 'SELECTED' _screen.picked
exit 0
