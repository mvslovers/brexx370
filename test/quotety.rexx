say '----------------------------------------'
say 'File quotety.rexx'
/* QUOTE took no qtype: the RXLIB QUOTE that had one was never reached */
/* (the built-in wins), and an empty string read before its start      */
/* (#386).                                                              */
err = 0
call check 'QUOTE ""',        t("quote('abc', '""')"), '"abc"'
call check 'QUOTE (',         t("quote('abc', '(')"), '(abc)'
call check 'QUOTE [',         t("quote('abc', '[')"), '[abc]'
call check 'QUOTE <',         t("quote('abc', '<')"), '<abc>'
call check "QUOTE '",         t("quote('abc', ""'"")"), "'abc'"
call check 'QUOTE empty',     t("quote('')"), "''"
call check 'QUOTE plain',     quote('abc'), "'abc'"
call check 'QUOTE quoted',    quote("'abc'"), "'abc'"
call check 'QUOTE with quote', quote("it's"), '"it''s"'
say 'Done quotety.rexx'
exit err

t: procedure
signal on syntax name tx
interpret 'r =' arg(1)
return r
tx: return 'error' rc

check:
parse arg what, got, want
if got == want then say left('QUOTETY',8) '-' left(what,16) '.. PASS'
else do
   say left('QUOTETY',8) '-' left(what,16) '.. *FAIL* got' got 'want' want
   err = err + 1
end
return
