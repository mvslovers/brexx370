/* REXX - MVSTEST FULLDD                                               */
say '----------------------------------------'
say 'File execfull.rexx'
/* EXECIO DISKW must report a write that fails (#178): it ignored      */
/* fputs()/fclose() and returned RC 0. mvstest.py gives this step DD   */
/* FULLDD, one track without secondary space (FB 80, 800-byte blocks). */
/* The control writes 10 records, which fit; 10000 do not.             */
err = 0
do i = 1 to 10000
   w.i = 'EXECFULL record' right(i, 5, '0')
end
w.0 = 10
"EXECIO * DISKW FULLDD (STEM w."
call check 'DISKW 10 records', rc, 0
w.0 = 10000
"EXECIO * DISKW FULLDD (STEM w."
call check 'DISKW past the end', rc, 20
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
