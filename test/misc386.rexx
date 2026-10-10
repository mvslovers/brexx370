say '----------------------------------------'
say 'File misc386.rexx'
/* FPOS and FCHANGESTR stopped at X'00' (strstr); MATCH's [a-z] took   */
/* the EBCDIC bytes in the gaps after i and r; STREAM() reported READY */
/* after a LINEOUT that raised NOTREADY; FSS took any RC 8 for not    */
/* initialised (#386).                                                 */
err = 0
/* FPOS / FCHANGESTR past X'00' */
h = 'ab'x2c('00')'cd'
call check 'FPOS X00',        fpos('cd', h), 4
call check 'FPOS of X00',     fpos(x2c('00'), h), 3
x = c2x(fchangestr('cd', h, 'xy'))
call check 'FCHANGESTR X00',  x, c2x('ab'x2c('00')'xy')
/* MATCH ranges: [a-z] is not 0x81..0xA9 */
ob = x2c('BA'); cb = x2c('BB')
call check 'MATCH a-z k',     match(ob'a-z'cb, 'k'), 0
call check 'MATCH a-z gap',   match(ob'a-z'cb, x2c('8A')), -1
call check 'MATCH a-z gap 2', match(ob'a-z'cb, x2c('A1')), -1
call check 'MATCH A-Z gap',   match(ob'A-Z'cb, x2c('CA')), -1
call check 'MATCH 0-9',       match(ob'0-9'cb, 'x7'), 1
call check 'MATCH not abc',   match(ob||x2c('B0')'abc'cb, 'abcx'), 3
/* STREAM after NOTREADY */
VER = UPPER(VERSION())
if index(VER,'(') > 0 then do
  VER = DELSTR(VER,INDEX(VER,'('),1)
  VER = DELSTR(VER,INDEX(VER,')'),1)
end
dsn = "'BREXX."||VER||".TESTS(MISCTMP)'"
call allocate 'miscdd', dsn
w.0 = 1; w.1 = 'one'
"EXECIO * DISKW miscdd (STEM w."
call free 'miscdd'
r = lineout(dsn, 'two')
say 'MISC386  - LINEOUT to the member:' r stream(dsn)
if r = 1 then call check 'STREAM NOTREADY', stream(dsn), 'NOTREADY'
call lineout dsn
/* FSS before INIT is still error 69 */
call check 'FSS not INIT',    fss('GET CURSOR x'), 69
say 'Done misc386.rexx'
exit err

fss: procedure
signal on syntax name fssx
address fss arg(1)
return 'rc' rc
fssx: return rc

check:
parse arg what, got, want
if got == want then say left('MISC386',8) '-' left(what,16) '.. PASS'
else do
   say left('MISC386',8) '-' left(what,16) '.. *FAIL* got' got 'want' want
   err = err + 1
end
return
