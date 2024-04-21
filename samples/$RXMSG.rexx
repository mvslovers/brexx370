say '**** Print all Messages'
call display
say '**** Print only Warning Messages and above'
rxmslv='W'    /* Print only Warning Messages and above  */
call display
say '**** Print only Error Messages and above'
rxmslv='E'    /* Print only Error Messages */
call display
exit
/* ---------------------------------------------------------------------
 * Demonstrate usage of Message Command
 * ---------------------------------------------------------------------
 */
Display:
rc=rxmsg( 10,'I','Program started')
call vars
rc=rxmsg(200,'W','Value missing')
call vars
rc=rxmsg(100,'E','Value not Numeric')
call vars
rc=rxmsg(999,'C','Divisor is zero')
call vars
return
/* ---------------------------------------------------------------------
 * Message Variables return
 * ---------------------------------------------------------------------
 */
vars:
say '*** Variables returned from RXMSG Call'
say '  RC  : 'rc
say '  MSLV: 'mslv
say '  MSTX: 'mstx
say '  MSLN: 'msln
return
