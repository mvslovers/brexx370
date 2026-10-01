say '----------------------------------------'
say 'File updvb.rexx'
/* overwrite in place on a VB data set (libc370#189 slice 2): a      */
/* record keeps its length, so a line of the same length replaces    */
/* it and a longer or shorter one is refused (LINEOUT returns 1).    */
err = 0
VER = UPPER(VERSION())
if index(VER,'(') > 0 then do
  VER = DELSTR(VER,INDEX(VER,'('),1)
  VER = DELSTR(VER,INDEX(VER,')'),1)
end
F = allocate('vbdd',"'BREXX."||VER||".TESTSEQV'")
IF F >= 4 THEN return 8
file = OPEN('vbdd',"W")
do n = 1 to 5
  call lineout file, "Line" n
end
call check 'linein(,3)', linein(file,3), 'Line 3'
call check 'same length', lineout(file, "Done 3", 3), 0
call check 'linein(,3) done', linein(file,3), 'Done 3'
call check 'longer refused', lineout(file, "Done 3 Long", 3), 1
call check 'shorter refused', lineout(file, "Done", 3), 1
call close file
/* a fresh open: what is on disk */
f = OPEN('vbdd',"R")
call check 'lines()', lines(f), 5
call check 'linein(,2) kept', linein(f,2), 'Line 2'
say left('UPDVB',8) '- record 3 after the refusals:' linein(f,3)
call check 'linein(,4) kept', linein(f,4), 'Line 4'
call check 'linein(,5) kept', linein(f,5), 'Line 5'
call close f
say 'Done updvb.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('UPDVB',8) '-' left(what,24) '.. PASS'
else do
   say left('UPDVB',8) '-' left(what,24) '.. *FAIL*'
   say '   got ' c2x(got)
   say '   want' c2x(want)
   err = err + 1
end
return
