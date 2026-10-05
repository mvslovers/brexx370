say '----------------------------------------'
say 'File crypt.rexx'
/* ENCRYPT, DECRYPT, ROTATE and RHASH, before and after they move     */
/* from rxmvs.c to rxcrypt.c (#302).                                  */
err = 0
plain = 'Hello World 12345'
e = encrypt(plain, 'secret')
call check 'ENCRYPT changes',  e \== plain, 1
call check 'ENCRYPT length',   length(e), length(plain)
call check 'ROTATE 3',         rotate('ABCDEF', 3), 'CDEFAB'
call check 'ROTATE 5,4',       rotate('ABCDEF', 5, 4), 'EFAB'
call check 'RHASH stable',     rhash('abc') = rhash('abc'), 1
h = rhash('abc', 10)
call check 'RHASH slots',      h >= 0 & h < 10, 1
say 'Done crypt.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('CRYPT',8) '-' left(what,16) '.. PASS'
else do
   say left('CRYPT',8) '-' left(what,16) '.. *FAIL* got' got,
       'want' want
   err = err + 1
end
return
