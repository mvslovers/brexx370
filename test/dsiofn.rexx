say '----------------------------------------'
say 'File dsiofn.rexx'
/* CREATE, SWRITE and SREAD with a data set name (#299: their opens    */
/* moved from jcc_fopen() to BREXX's dsio). Same results before and    */
/* after the move.                                                     */
err = 0
VER = UPPER(VERSION())
if index(VER,'(') > 0 then do
  VER = DELSTR(VER,INDEX(VER,'('),1)
  VER = DELSTR(VER,INDEX(VER,')'),1)
end
dsn = "'BREXX."||VER||".DSIOFN'"
call remove dsn                         /* left over from a broken run */
call check 'CREATE new',     create(dsn, 'recfm=fb,lrecl=80,blksize=3120'), 0
call check 'CREATE again',   create(dsn, 'recfm=fb,lrecl=80,blksize=3120'), -2
call check 'EXISTS',         exists(dsn), 1
s = screate(5)
do i = 1 to 5
   call sset s, , 'DSIOFN record' i
end
call check 'SWRITE to DSN',  swrite(s, dsn), 5
call sfree s
t = sread(dsn)
call check 'SREAD count',    sarray(t), 5
call check 'SREAD first',    strip(sget(t, 1)), 'DSIOFN record 1'
call check 'SREAD last',     strip(sget(t, 5)), 'DSIOFN record 5'
call sfree t
call check 'REMOVE',         remove(dsn), 0
call check 'EXISTS after',   exists(dsn), 0
say 'Done dsiofn.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('DSIOFN',8) '-' left(what,24) '.. PASS'
else do
   say left('DSIOFN',8) '-' left(what,24) '.. *FAIL*'
   say '   got ' got
   say '   want' want
   err = err + 1
end
return
