say '----------------------------------------'
say 'File execstk.rexx'
/* EXECIO FIFOW/LIFOW wrote a stem to the stack, but never took the  */
/* stem name from the command: they read an uninitialised buffer and */
/* queued nothing, RC 0 (#386). FIFOR had the name and worked.       */
err = 0
s.1 = 'one'; s.2 = 'two'; s.3 = 'three'; s.0 = 3
address mvs 'EXECIO * FIFOW (STEM S.'
call check 'FIFOW rc', rc, 0
call check 'FIFOW queued', queued(), 3
call check 'FIFOW order', pullall(), 'one two three'
address mvs 'EXECIO * LIFOW (STEM S.'
call check 'LIFOW queued', queued(), 3
call check 'LIFOW order', pullall(), 'three two one'
address mvs 'EXECIO 2 FIFOW (STEM S.'
call check 'FIFOW 2 lines', pullall(), 'one two'
address mvs 'EXECIO * FIFOW (STEM S. KEEP t'
call check 'FIFOW KEEP', pullall(), 'two three'
queue 'a'; queue 'b'
address mvs 'EXECIO * FIFOR (STEM T.'
call check 'FIFOR stem', t.0 t.1 t.2, '2 a b'
say 'Done execstk.rexx'
exit err

pullall: procedure
l = ''
do queued()
   parse pull x
   l = l x
end
return strip(l)

check:
parse arg what, got, want
if got == want then say left('EXECSTK',8) '-' left(what,16) '.. PASS'
else do
   say left('EXECSTK',8) '-' left(what,16) '.. *FAIL* got' got 'want' want
   err = err + 1
end
return
