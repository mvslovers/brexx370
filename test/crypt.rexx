say '----------------------------------------'
say 'File crypt.rexx'
/* ENCRYPT, DECRYPT, ROTATE and RHASH (#302); DECRYPT round trips    */
/* since it was fixed.                                               */
err = 0
plain = 'Hello World 12345'
e = encrypt(plain, 'secret')
call check 'ENCRYPT changes',  e \== plain, 1
call check 'ENCRYPT length',   length(e), length(plain)
/* DECRYPT used 1 round where ENCRYPT used 7, and stepped its round */
/* value back below 0: nothing came back before this fix            */
call check 'DECRYPT',          decrypt(e, 'secret'), plain
x = encrypt(plain, 'zz9')
call check 'DECRYPT pw 2',     decrypt(x, 'zz9'), plain
call check 'DECRYPT 3 rounds', decrypt(encrypt(plain, 'k', 3), 'k', 3),,
                               plain
call check 'DECRYPT wrong pw', decrypt(e, 'other') \== plain, 1
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
