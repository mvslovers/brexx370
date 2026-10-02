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
/* the record options of DISKW, read back with DISKR */
do i = 1 to 10
   v.i = 'REC' right(i, 2, '0') word('ODD EVEN', 2 - i // 2)
end
v.0 = 10
call wr 'KEEP',  '* DISKW FULLDD (STEM v. KEEP EVEN',  5, 'REC 02 EVEN'
call wr 'DROP',  '* DISKW FULLDD (STEM v. DROP EVEN',  5, 'REC 01 ODD'
call wr 'SKIP',  '* DISKW FULLDD (STEM v. SKIP 3',     7, 'REC 04 EVEN'
call wr 'count', '4 DISKW FULLDD (STEM v.',            4, 'REC 01 ODD'
call wr 'count+KEEP', '2 DISKW FULLDD (STEM v. KEEP EVEN', 2, 'REC 02 EVEN'
w.0 = 10000
"EXECIO * DISKW FULLDD (STEM w."
call check 'DISKW past the end', rc, 20
say 'Done execfull.rexx'
exit err

wr: /* write with options, read back: count and first record */
parse arg lbl, cmd, n, first          /* check sets WHAT: no PROCEDURE */
"EXECIO" cmd
call check lbl 'rc', rc, 0
drop r.
"EXECIO * DISKR FULLDD (STEM r."
call check lbl 'count', r.0, n
call check lbl 'first', strip(r.1), first
return

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
