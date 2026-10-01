say '----------------------------------------'
say 'File updmem.rexx'
/* a PDS member opened "w+" (libc370#189): it reads back after the   */
/* writes, but BPAM can neither update nor extend a member, so a     */
/* write after the switch to reading is refused (LINEOUT returns 1). */
/* Appending to an existing member is refused at OPEN (libc370#198). */
err = 0
VER = UPPER(VERSION())
if index(VER,'(') > 0 then do
  VER = DELSTR(VER,INDEX(VER,'('),1)
  VER = DELSTR(VER,INDEX(VER,')'),1)
end
mem = "'BREXX."||VER||".TESTS(UMTMP)'"
file = OPEN(mem,"W")
call check 'open w', file >= 0, 1
do n = 1 to 3
  call lineout file, "Line" n
end
call check 'linein(,1)', linein(file,1), pad('Line 1')
call check 'write after read', lineout(file, "Line 4"), 1
call close file
f = OPEN(mem,"A")
call check 'open a refused', f, -1
f = OPEN(mem,"R")
call check 'lines()', lines(f), 3
call check 'linein(,3) kept', linein(f,3), pad('Line 3')
call close f
say 'Done updmem.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('UPDMEM',8) '-' left(what,24) '.. PASS'
else do
   say left('UPDMEM',8) '-' left(what,24) '.. *FAIL*'
   say '   got ' c2x(got)
   say '   want' c2x(want)
   err = err + 1
end
return

pad: return left(arg(1), 80)     /* an FB80 record as LINEIN sees it */
