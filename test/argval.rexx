say '----------------------------------------'
say 'File argval.rexx'
/* arguments are passed by value: a routine that changes the variable
   still sees the old value in ARG() (RossPatterson/CMS-370-BREXX #119) */
err = 0
x = 'old'
call chg x
call check 'CALL arg(1)', result, 'old'
call check 'CALL x set', x, 'new'
x = 'old'
call check 'function arg(1)', chg(x), 'old'
x = 'old'; y = 'yold'
call check 'two args', chg2(x, y), 'old yold'
x = 'old'
call check 'omitted arg', chg3(x,,x), 'old 0 old'
x = 'old'
call check 'ARG instruction', chg4(x), 'old'
say 'Done argval.rexx'
exit err

chg:  x = 'new'
      return arg(1)
chg2: x = 'new'; y = 'ynew'
      return arg(1) arg(2)
chg3: x = 'new'
      return arg(1) arg(2,'E') arg(3)
chg4: x = 'new'
      parse arg v
      return v

check:
parse arg what, got, want
if got == want then say left('ARGVAL',8) '-' left(what,16) '.. PASS'
else do
   say left('ARGVAL',8) '-' left(what,16) '.. *FAIL* got "'got'"',
       'want "'want'"'
   err = err + 1
end
return
