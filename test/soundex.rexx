/* REXX - SOUNDEX on EBCDIC (#40)                                      */
/* The letter was looked up at c - 65 (ASCII 'A'); on EBCDIC that is   */
/* 128..168 for every letter, past the 26-entry table. Expected values */
/* are those of the same algorithm on ASCII (BREXX documentation).     */
say '----------------------------------------'
say 'File soundex.rexx'
err = 0
call check 'monday',    'M530'
call check 'mandei',    'M530'
call check 'Robert',    'R163'
call check 'Rupert',    'R163'
call check 'Tymczak',   'T522'
call check 'Knight',    'C523'
call check 'Philip',    'F410'
call check 'Lloyd',     'L430'
call check 'Jackson',   'J222'
call check 'Szymanski', 'S255'
call check "O'Hara",    'O600'
call check 'Tim-O',     'T500'
call check 'a',         'A000'
say 'Done soundex.rexx'
exit err

check:
parse arg word, want
got = soundex(word)
if got == want then say left('SOUNDEX',8) '-' left(word,10) got '.. PASS'
else do
   say left('SOUNDEX',8) '-' left(word,10) '.. *FAIL*'
   say '   got  "'c2x(got)'"x want "'want'"'
   err = err + 1
end
return
