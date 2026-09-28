/* REXX - LINEIN, EXECIO DISKR and READ() keep FB blanks (#146)     */
say '----------------------------------------'
say 'File fbpad.rexx'
err = 0
VER = UPPER(VERSION())
if index(VER,'(') > 0 then do
  VER = DELSTR(VER,INDEX(VER,'('),1)
  VER = DELSTR(VER,INDEX(VER,')'),1)
end
F = allocate('fbpdd',"'BREXX."||VER||".TESTS(FBPTMP)'")
if F >= 4 then do
  say 'FBPAD    - allocate failed' F '.. *FAIL*'
  exit 8
end
file = open('fbpdd','W')
call lineout file, 'END'
call lineout file, 'Line 2'
call close file
/* LINEIN */
file = open('fbpdd','R')
l = linein(file)
call close file
call check 'LINEIN len', length(l), 80
call check 'LINEIN = END', l = 'END', 1
call check 'LINEIN strip', strip(l), 'END'
/* EXECIO DISKR */
"EXECIO * DISKR fbpdd (STEM e. FINIS"
call check 'EXECIO rc', rc, 0
call check 'EXECIO e.0', e.0, 2
call check 'EXECIO len', length(e.1), 80
call check 'EXECIO = END', e.1 = 'END', 1
call check 'EXECIO strip', strip(e.2), 'Line 2'
/* READ() in line mode */
file = open('fbpdd','R')
r = read(file)
call close file
call check 'READ len', length(r), 80
call check 'READ = END', r = 'END', 1
/* all three read the same record */
call check 'LINEIN == EXECIO', l == e.1, 1
call check 'READ == EXECIO', r == e.1, 1
call free 'fbpdd'
say 'Done fbpad.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('FBPAD',8) '-' left(what,20) '.. PASS'
else do
   say left('FBPAD',8) '-' left(what,20) '.. *FAIL* got "'got'" want "'want'"'
   err = err + 1
end
return
