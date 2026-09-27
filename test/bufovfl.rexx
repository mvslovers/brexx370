/* REXX - buffer overflows in the interpreter core (#130)              */
say '----------------------------------------'
say 'File bufovfl.rexx'
err = 0
/* FORMAT formatted into str[50] */
f = format(1, 60)
call check 'FORMAT(1,60) len', length(f), 60
call check 'FORMAT(1,60) val', strip(f), 1
f = format(1, 2, 60)
call check 'FORMAT(1,2,60) len', length(f), 63
/* D2P: the result buffer was n+15 bytes, plen bytes were written */
p = d2p(12345, 100)
call check 'D2P(,100) len', length(p), 100
call check 'D2P(,100) tail', right(c2x(p), 6), '12345F'
call check 'D2P(,100) head', left(c2x(p), 4), '0000'
/* EXECIO SUBSTR pads to its length; the record was copied into 4098 */
VER = UPPER(VERSION())
if index(VER,'(') > 0 then do
  VER = DELSTR(VER,INDEX(VER,'('),1)
  VER = DELSTR(VER,INDEX(VER,')'),1)
end
F = allocate('ovfdd',"'BREXX."||VER||".TESTS(OVFTMP)'")
if F >= 4 then do
  say 'BUFOVFL  - allocate failed' F '.. *FAIL*'
  exit 8
end
w.0 = 2
w.1 = 'FIRST RECORD'
w.2 = 'SECOND RECORD'
"EXECIO * DISKW ovfdd (STEM w."
call check 'EXECIO DISKW rc', rc, 0
"EXECIO * DISKR ovfdd (STEM r. SUBSTR 1 5000"
call check 'EXECIO DISKR rc', rc, 0
call check 'EXECIO r.0', r.0, 2
call check 'EXECIO r.1 len', length(r.1), 5000
call check 'EXECIO r.1 val', strip(r.1), 'FIRST RECORD'
call free 'ovfdd'
say 'Done bufovfl.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('BUFOVFL',8) '-' left(what,20) '.. PASS'
else do
   say left('BUFOVFL',8) '-' left(what,20) '.. *FAIL* got "'got'" want "'want'"'
   err = err + 1
end
return
