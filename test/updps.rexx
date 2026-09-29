say '----------------------------------------'
say 'File updps.rexx'
/* overwrite in place on PS (libc370#189 slice 2) */
err = 0
nl = '15'x                       /* '\n' in the byte view (EBCDIC NL) */
VER = UPPER(VERSION())
if index(VER,'(') > 0 then do
  VER = DELSTR(VER,INDEX(VER,'('),1)
  VER = DELSTR(VER,INDEX(VER,')'),1)
end
F = allocate('psdd',"'BREXX."||VER||".TESTSEQ'")
IF F >= 4 THEN return 8
file = OPEN('psdd',"W")
do n = 1 to 5
  call lineout file, "Line" n
end
call check 'lineout(,,3)', lineout(file, "Done 3", 3), 0
call check 'lines() still 5', lines(file), 5
call check 'linein(,3)', linein(file,3), pad('Done 3')
call check 'linein(,4) kept', linein(file,4), pad('Line 4')
/* line 2 starts at byte 82 in the byte view */
call check 'charout(,,82)', charout(file, "Done 2", 82), 0
call check 'linein(,2)', linein(file,2), pad('Done 2')
call check 'longer line', lineout(file, "Done 3 Long", 3), 0
call check 'linein(,3) long', linein(file,3), pad('Done 3 Long')
call check 'lines() from line 4', lines(file), 2
call close file
say 'Done updps.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('UPDPS',8) '-' left(what,24) '.. PASS'
else do
   say left('UPDPS',8) '-' left(what,24) '.. *FAIL*'
   say '   got ' c2x(got)
   say '   want' c2x(want)
   err = err + 1
end
return

pad: return left(arg(1), 80)     /* an FB80 record as LINEIN sees it */
