say '----------------------------------------'
say 'File execfull.rexx'
/* EXECIO DISKW must report a write that fails (#178): it ignored      */
/* fputs()/fclose() and returned RC 0. A one-track data set without    */
/* secondary space fills up; the control writes 10 records that fit.   */
err = 0
VER = UPPER(VERSION())
if index(VER,'(') > 0 then do
  VER = DELSTR(VER,INDEX(VER,'('),1)
  VER = DELSTR(VER,INDEX(VER,')'),1)
end
dsn = "'BREXX."||VER||".EXECFULL'"
call remove dsn                         /* left over from a broken run */
rc = create(dsn, 'recfm=fb,lrecl=80,blksize=800,unit=sysda,pri=1,sec=0')
call check 'create', rc, 0
call check 'allocate', allocate('fulldd', dsn), 0
do i = 1 to 10000
   w.i = 'EXECFULL record' right(i, 5, '0')
end
w.0 = 10
"EXECIO * DISKW fulldd (STEM w."
call check 'DISKW 10 records', rc, 0
w.0 = 10000
"EXECIO * DISKW fulldd (STEM w."
call check 'DISKW past the end', rc, 20
call free 'fulldd'
call remove dsn
say 'Done execfull.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('EXECFULL',8) '-' left(what,24) '.. PASS'
else do
   say left('EXECFULL',8) '-' left(what,24) '.. *FAIL*'
   say '   got ' got
   say '   want' want
   err = err + 1
end
return
