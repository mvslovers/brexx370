say '----------------------------------------'
say 'File prefix.rexx'
/* prefix operators may repeat, and + normalises the number (#208,
   #193; RossPatterson/CMS-370-BREXX expr_ test 2). INTERPRET, so that
   a compile error is a failed case and not a failed program */
err = 0
b = 0; a = 1
call try "x = -\b",        -1
/* "x = --a" is x = with a comment: -- starts a line comment in
   BREXX (2a581aa); "- -a" is the two prefixes */
call try "x = +-+-\0",      1
call try "x = \\1",         1
call try "x = -(-3)",       3
call try "x = - -a",        1
call try "x = +'1E+2'",   100
call try "x = +.1E2",      10
call try "x = +5",          5
call try "x = -2**2",       4
call try "x = 3 - -a",      4
v = '1.50'
call try "x = -v",       -1.5
call check 'v unchanged', v, '1.50'
signal on syntax name notnum
x = +'abc'
say left('PREFIX',8) "- +'abc'        .. *FAIL* no error, got" x
err = err + 1
signal after
notnum:
call check "+'abc' error", rc, 41
after:
signal off syntax
say 'Done prefix.rexx'
exit err

try:
parse arg clause, want
signal on syntax name bad
interpret clause
signal off syntax
call check clause, x, want
return
bad:
say left('PREFIX',8) '-' left(arg(1),14) '.. *FAIL* error' rc
err = err + 1
return

check:
parse arg what, got, want
if got == want then say left('PREFIX',8) '-' left(what,14) '.. PASS'
else do
   say left('PREFIX',8) '-' left(what,14) '.. *FAIL* got "'got'"',
       'want "'want'"'
   err = err + 1
end
return
