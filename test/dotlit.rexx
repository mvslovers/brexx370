say '----------------------------------------'
say 'File dotlit.rexx'
/* '.' alone is a constant symbol and can be a term (vlachoudis/brexx
   9c994903, RossPatterson/CMS-370-BREXX expr_ test 1). INTERPRET, so
   that a compile error is a failed case and not a failed program */
err = 0
call try "x = 'blah'.",   'blah.'
call try "x = 'a' .",     'a .'
call try "x = .",         '.'
call try "x = . 'b'",     '. b'
call try "x = 'a'||.",    'a.'
say 'Done dotlit.rexx'
exit err

try:
parse arg clause, want
signal on syntax name bad
interpret clause
signal off syntax
call check clause, x, want
return
bad:
say left('DOTLIT',8) '-' left(arg(1),14) '.. *FAIL* error' rc
err = err + 1
return

check:
parse arg what, got, want
if got == want then say left('DOTLIT',8) '-' left(what,14) '.. PASS'
else do
   say left('DOTLIT',8) '-' left(what,14) '.. *FAIL* got "'got'"',
       'want "'want'"'
   err = err + 1
end
return
