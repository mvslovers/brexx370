say '----------------------------------------'
say 'File openvio.rexx'
/* OPEN(..., 'VIO') opened a JCC memory file (//MEM:), which libc370    */
/* does not have: it fails (-1) in the cc370 build. A quoted name went  */
/* on with uninitialised storage after a message (#299).                */
err = 0
call check 'VIO name',            open('viodd', 'W', 'VIO'), -1
call check 'VIO quoted name',     open("'A.B.C'", 'W', 'VIO'), -1
say 'Done openvio.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('OPENVIO',8) '-' left(what,24) '.. PASS'
else do
   say left('OPENVIO',8) '-' left(what,24) '.. *FAIL*'
   say '   got ' got
   say '   want' want
   err = err + 1
end
return
