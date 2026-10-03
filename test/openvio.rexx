say '----------------------------------------'
say 'File openvio.rexx'
/* OPEN(..., 'VIO') opened a JCC memory file (style MEM), which libc370 */
/* does not have: it failed in every cc370 build, and a quoted name    */
/* abended SB0A. VIO is gone (#299): the call is an error 40 now. Any  */
/* other third argument is ignored, as it always was. OUTDD is a       */
/* SYSOUT DD of every mvstest.py step.                                 */
err = 0
got = 'no error'
signal on syntax name vioerr
call open 'viodd', 'W', 'VIO'
vioback:
call check 'VIO is an error', got, 40
f = open('outdd', 'W', 'RECFM=FB')
call check 'other 3rd arg ignored', f >= 0, 1
call close f
say 'Done openvio.rexx'
exit err

vioerr:
got = rc
signal vioback

check:
parse arg what, got2, want
if got2 == want then say left('OPENVIO',8) '-' left(what,24) '.. PASS'
else do
   say left('OPENVIO',8) '-' left(what,24) '.. *FAIL*'
   say '   got ' got2
   say '   want' want
   err = err + 1
end
return
