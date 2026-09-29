say '----------------------------------------'
say 'File charout.rexx'
/* CHAROUT: returns chars not written; pieces form a record */
err = 0
nl = '15'x                       /* '\n' in the byte view (EBCDIC NL) */
VER = UPPER(VERSION())
if index(VER,'(') > 0 then do
  VER = DELSTR(VER,INDEX(VER,'('),1)
  VER = DELSTR(VER,INDEX(VER,')'),1)
end
F = allocate('ofile',"'BREXX."||VER||".TESTS(COTMP)'")
IF F >= 4 THEN return 8
file = OPEN('ofile',"W")
call check 'charout() rc', charout(file, "Li"), 0
call check 'charout() piece', charout(file, "ne 1"nl), 0
do n = 2 to 5
  call charout file, "Line" n||nl
end
call check 'charout(file) rc', charout(file), 0
call check 'lines()', lines(file), 5
do n = 1 to 5
  call check 'linein()' n, linein(file), pad('Line' n)
end
call check 'linein() at the end', linein(file), ''
call close file
say "Done charout.rexx"
exit err

check:
parse arg what, got, want
if got == want then say left('CHAROUT',8) '-' left(what,24) '.. PASS'
else do
   say left('CHAROUT',8) '-' left(what,24) '.. *FAIL*'
   say '   got ' c2x(got)
   say '   want' c2x(want)
   err = err + 1
end
return

pad: return left(arg(1), 80)     /* an FB80 record as LINEIN sees it */
