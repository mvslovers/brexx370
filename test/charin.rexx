say '----------------------------------------'
say 'File charin.rexx'
/* CHARIN: own read position, starting at 1 */
err = 0
nl = '15'x                       /* '\n' in the byte view (EBCDIC NL) */
VER = UPPER(VERSION())
if index(VER,'(') > 0 then do
  VER = DELSTR(VER,INDEX(VER,'('),1)
  VER = DELSTR(VER,INDEX(VER,')'),1)
end
F = allocate('ofile',"'BREXX."||VER||".TESTS(CITMP)'")
IF F >= 4 THEN return 8
file = OPEN('ofile',"W")
do n = 1 to 5
  call lineout file, "Line" n
end
call check 'lineout() rc', lineout(file), 0
call check 'charin()', charin(file), 'L'
call check 'charin(,,5)', charin(file,,5), 'ine 1'
call check 'charin(,,75) record end', charin(file,,75), copies(' ',74)nl
call check 'charin(82,6)', charin(file,82,6), 'Line 2'
call check 'charin(1,81)', charin(file,1,81), pad('Line 1')nl
call check 'charin(406) at end', charin(file,406), ''
call close file
say "Done charin.rexx"
exit err

check:
parse arg what, got, want
if got == want then say left('CHARIN',8) '-' left(what,24) '.. PASS'
else do
   say left('CHARIN',8) '-' left(what,24) '.. *FAIL*'
   say '   got ' c2x(got)
   say '   want' c2x(want)
   err = err + 1
end
return

pad: return left(arg(1), 80)     /* an FB80 record as LINEIN sees it */
