/* REXX - VTOC(), LISTDSIX() and LISTVOL() outside TSO                 */
/* IRXVTOC needs the TSO environment. In a plain batch step the        */
/* preloaded functions must say so (-16) and leave the caller alone,   */
/* not call the program and abend.                                     */
say '----------------------------------------'
say 'File vtocbat.rexx'
err = 0
call listdsi "'SYS1.LINKLIB'"
vol = sysvolume
call check 'SYSTSO',           sysvar('SYSTSO'), 0
call check '__EXVTOC',         __exvtoc(vol, 'NOHEADING NOPRINT'), -16
call check '__EXVTOC no vol',  __exvtoc('', 'NOHEADING NOPRINT'), -8
call check 'LISTVOL',          listvol(vol), -16
call vtoc vol
call check 'VTOC',             result, -16
call listdsix "'SYS1.LINKLIB'"
call check 'LISTDSIX',         result, -16
say 'Done vtocbat.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('VTOC',8) '-' left(what,20) '.. PASS'
else do
   say left('VTOC',8) '-' left(what,20) '.. *FAIL* got' got 'want' want
   err = err + 1
end
return
