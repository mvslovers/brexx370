say '----------------------------------------'
say 'File rdout.rexx'
/* LINEIN on an output-only stream (libc370#203): a SYSOUT DD cannot  */
/* be opened for update, so OPEN 'W' falls back from "w+" to "w".     */
/* The read must return '' instead of abending S400, and leave the    */
/* stream writable. OUTDD is a SYSOUT DD of every mvstest.py step.    */
err = 0
file = OPEN('outdd',"W")
call check 'open', file >= 0, 1
call check 'lineout before', lineout(file, "RDOUT line 1"), 0
call check 'linein()', linein(file), ''
call check 'lineout after', lineout(file, "RDOUT line 2"), 0
call close file
say 'Done rdout.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('RDOUT',8) '-' left(what,24) '.. PASS'
else do
   say left('RDOUT',8) '-' left(what,24) '.. *FAIL*'
   say '   got ' c2x(got)
   say '   want' c2x(want)
   err = err + 1
end
return
