/* REXX - string arrays stay in bounds (#172)                          */
/* An element index past the capacity, an index or start of 0, an      */
/* empty array and a gap left by SSET must end in Error 40 or work,     */
/* instead of reading or writing past the array. The cases that wrote  */
/* below or past the array come last: they may abend an old build.     */
say '----------------------------------------'
say 'File sarrbnd.rexx'
err = 0
/* I2S of an empty integer array: R_screate(0) took the caller's first */
/* argument, the integer array number, as the size (Error 40 for 0)    */
a = icreate(5)
call ok 'I2S empty',            'e = i2s(' a ')'
call check 'I2S empty count',   sarray(e), 0
call check 'SLSTR empty',       slstr(e), ''
call ifree a
s = screate(10)                         /* capacity 100 */
call sset s, , 'cc'
call sset s, , 'aa'
call sset s, , 'bbb'
call check 'SGET start 2',      sget(s, 3, 2), 'bb'
call check 'SGET start at end', sget(s, 3, 4), ''
call check 'SGET start past',   sget(s, 1, 50), ''
call check 'SGET unset',        sget(s, 50), ''
call check 'SCLC unset',        sign(sclc(s, 50, s, 1)), -1
call e40 'SGET start 0',        'sget(' s ', 1, 0)'
x = sextract(s, 3, 2)
call check 'SEXTRACT to < from', sarray(x), 0
call sfree x
call sdel s, 10, 1
call check 'SDEL past the end', sarray(s), 3
c = scopy(s, 1, 1, , 10)
call check 'SCOPY start past',  sarray(c) sget(c, 1), '1 '
call sfree c
/* SSET past the end leaves a gap; the gap reads as '' and sorts      */
call sset s, 6, 'ab'
call check 'SSET gap count',    sarray(s), 6
call check 'SSET gap entry',    sget(s, 4), ''
call sqsort s
call check 'SQSORT with gap',   sget(s, 1) sget(s, 3) sget(s, 4) sget(s, 6),,
           ' aa ab cc'
/* below or past the array                                            */
call e40 'SGET past capacity',  'sget(' s ', 101)'
call e40 'SSWAP past capacity', 'sswap(' s ', 1, 101)'
call e40 'SCLC past capacity',  'sclc(' s ', 101,' s ', 1)'
/* SINSERT up to the capacity moved an entry one past it              */
f = screate(10)
do i = 1 to 99
   call sset f, , 'f'i
end
call sinsert f, 0, 1
call check 'SINSERT to capacity', sarray(f) sget(f, 1) sget(f, 100), '100  f99'
call sfree f
e = screate(1)
call sreverse e
call check 'SREVERSE empty',    sarray(e) sget(e, 1), '0 '
call sfree e
call check 'SSEARCH from 0',    ssearch(s, 'bbb', 0), 5
call e40 'SSET index 0',        'sset(' s ', 0, "x")'
call e40 'SSET past capacity',  'sset(' s ', 101, "x")'
call e40 'SSET values past',    'sset(' s ', 100, "x", "y")'
call e40 'SDEL from 0',         'sdel(' s ', 0, 1)'
call e40 'SCOPY from 0',        'scopy(' s ', 0)'
call e40 'SQSORT offset 0',     'sqsort(' s ', "A", 0)'
call sfree s
say 'Done sarrbnd.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('SARRBND',8) '-' left(what,22) '.. PASS'
else do
   say left('SARRBND',8) '-' left(what,22) '.. *FAIL* got' got 'want' want
   err = err + 1
end
return

ok:
parse arg what, stmt
signal on syntax name okx
interpret stmt
say left('SARRBND',8) '-' left(what,22) '.. PASS'
return
okx:
say left('SARRBND',8) '-' left(what,22) '.. *FAIL* rc' rc
err = err + 1
e = screate(1)                          /* go on with an empty array */
return

e40: procedure expose err
parse arg what, expr
signal on syntax name e40x
interpret 'x =' expr
say left('SARRBND',8) '-' left(what,22) '.. *FAIL* no error'
err = err + 1
return
e40x:
if rc = 40 then say left('SARRBND',8) '-' left(what,22) '.. PASS'
else do
   say left('SARRBND',8) '-' left(what,22) '.. *FAIL* rc' rc
   err = err + 1
end
return
