/* REXX - RACCHECK() argument checks (#131)                            */
/* An empty profile hashed to 0 and divided by zero (S0C9); a class    */
/* name longer than 8 overflowed the heap. Both must answer 0 now.     */
say '----------------------------------------'
say 'File raccheck.rexx'
err = 0
say 'SYSRAKF  ' sysvar('SYSRAKF')
rc1 = raccheck('FACILITY', '', 'READ')
call check 'empty profile', rc1
rc2 = raccheck('FACILITYTOOLONG', 'SVC244', 'READ')
call check 'class > 8', rc2
rc3 = raccheck('FACILITY', copies('P', 45), 'READ')
call check 'profile > 44', rc3
/* a valid call still answers 0 or 1 */
rc4 = raccheck('FACILITY', 'SVC244', 'READ')
if rc4 \= 0 & rc4 \= 1 then do
   say left('RACCHECK',8) '- valid call returned' rc4 '.. *FAIL*'
   err = err + 1
end
else say left('RACCHECK',8) '- valid call' rc4 '.. PASS'
say 'Done raccheck.rexx'
exit err

check:
parse arg what, lrc
if sysvar('SYSRAKF') \= 'AVAILABLE' then,
   say left('RACCHECK',8) '-' left(what,16) 'no RAKF, rc='lrc '.. PASS'
else if lrc = 0 then say left('RACCHECK',8) '-' left(what,16) '.. PASS'
else do
   say left('RACCHECK',8) '-' left(what,16) '.. *FAIL* rc='lrc
   err = err + 1
end
return
