/* REXX */
/* --------------------------------------------------------------------
 * FMTLIST Example: integrate your own Top and Bottom lines
 *         the fmtlist output is embedded within it
 * --------------------------------------------------------------------
 */
/* do some tailoring */
_screen.Message=1
_screen.TopRow=4                      /* Reserve 4 lines at the Top */
_screen.BotLines=1                    /* Reserve 1 footer line      */
_screen.TopRow.proc='topLines' /* <--- call back proc to write top lines    */
_screen.BotLines.proc='footerLines' /* <--- call back proc to write footer */
_screen.Footer  ='PF3/PF4 Return'
_screen.color.list2=#TURQ
_screen.color.footer=#red
/* create buffer     */
do i=1 to 50
   Buffer.i=copies(i,22)
end
Buffer.0=i-1
call fmtlist 5,,,,test
return
/* --------------------------------------------------------------------
 * Primary Commands
 *    arg(1)       contains the primary command
 *    _commandLine contains the full line
 * --------------------------------------------------------------------
 */
test_primary:
if arg(1)='SHOW' then say 'SHOW was entered: '_commandLine
else if arg(1)='DISPLAY' then say 'DISPLAY was entered: '_commandLine
else return 8
return 0
/* --------------------------------------------------------------------
 * Line command S
 * --------------------------------------------------------------------
 */
test_s:
Buffer.0=3
Buffer.1=1111
Buffer.2=2222
Buffer.3=3333
call fmtList
return 0
/* --------------------------------------------------------------------
 * Call-Back Proc to write Top Lines
 * --------------------------------------------------------------------
 */
topLines:
ADDRESS FSS
  _tLine=Center('List Screen to Show Student Entries of the Student Database',
                80)
    call fsstext _tline,1,1,length(_tline),#PROT+#HI+#White
  _tLine=Center('Update Date of Database is 'date(),80)
    call fsstext _tline,2,1,length(_tline),#PROT+#HI+#White
  _tLine=Center('For question please call Johan at telephone 743',80)
    call fsstext _tline,3,1,length(_tline),#PROT+#HI+#White
return 0
/* --------------------------------------------------------------------
 * Call-Back Proc to write footer Lines
 * --------------------------------------------------------------------
 */
footerLines:
ADDRESS FSS
  parse arg first /* 1st line rsrvd for footer lines (based on screen hght) */
  first=strip(first,,"'")  /* strip of quotes of parameter */
  _tLine=center('The following Commands are allowed: SHOW, DISPLAY',80)
  call fsstext _tline,first,1,length(_tline),#PROT+#HI+#White
return 0
