say '----------------------------------------'
say 'File extdsn.rexx'
/* An external exec named by its data set name (#133): RxFileLoad()   */
/* takes a name with a '.' as a DSN ("(int) strstr(name,".") > 0",    */
/* src/rexx.c), a plain name as a member of the exec library.         */
err = 0
VER = UPPER(VERSION())
if index(VER,'(') > 0 then do
  VER = DELSTR(VER,INDEX(VER,'('),1)
  VER = DELSTR(VER,INDEX(VER,')'),1)
end
dsn = "'BREXX."||VER||".TESTS(EXTDSNX)'"
F = allocate('extdd',dsn)
call check 'allocate', F, 0
file = open('extdd','W')
call lineout file, '/* REXX */'
call lineout file, 'return 42'
call close file
call free 'extdd'

name = strip(dsn,,"'")
call check 'name has a dot', pos('.',name) > 0, 1
interpret "r = '"name"'()"
call check 'call by DSN', r, 42
say 'Done extdsn.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('EXTDSN',8) '-' left(what,24) '.. PASS'
else do
   say left('EXTDSN',8) '-' left(what,24) '.. *FAIL*'
   say '   got ' got
   say '   want' want
   err = err + 1
end
return
