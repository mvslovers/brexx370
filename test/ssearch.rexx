say '----------------------------------------'
say 'File ssearch.rexx'
/* SSEARCH and SSELECT on a string array (#133: their match test is   */
/* "(int) strstr(...) > 0"). Both the hit and the miss of every       */
/* branch: CASE, NOCASE, FROM, and SSELECT with and without a column. */
err = 0
s = screate(10)
call sset s, , 'ALPHA one'
call sset s, , 'beta Two'
call sset s, , 'GAMMA three'
call sset s, , 'alpha four'

/* SSEARCH, case-sensitive (the default) */
call check 'case hit',        ssearch(s, 'ALPHA'), 1
call check 'case 2nd',        ssearch(s, 'alpha'), 4
call check 'case miss',       ssearch(s, 'Alpha'), 0
call check 'case mid-string', ssearch(s, 'Two'), 2
call check 'from',            ssearch(s, 'ALPHA', 2), 0
call check 'from hit',        ssearch(s, 'three', 2), 3
call check 'from past end',   ssearch(s, 'ALPHA', 9), 0

/* SSEARCH, NOCASE */
call check 'nocase hit',      ssearch(s, 'Alpha', 1, 'N'), 1
call check 'nocase from',     ssearch(s, 'Alpha', 2, 'N'), 4
call check 'nocase miss',     ssearch(s, 'delta', 1, 'N'), 0

/* SSELECT: entries that contain one of the search strings */
t = sselect(s, 'alpha', 'Two')
call check 'select count',    sarray(t), 2
call check 'select 1',        sget(t, 1), 'beta Two'
call check 'select 2',        sget(t, 2), 'alpha four'
call sfree t
t = sselect(s, 'delta')
call check 'select none',     sarray(t), 0
call sfree t

/* SSELECT with a column: search 1 must start at position 1, length 5 */
sselect.from.1 = 1
sselect.length.1 = 5
t = sselect(s, 'GAMMA')
call check 'select column',   sarray(t), 1
call check 'select column 1', sget(t, 1), 'GAMMA three'
call sfree t
t = sselect(s, 'three')
call check 'column miss',     sarray(t), 0
call sfree t
drop sselect.

call sfree s
say 'Done ssearch.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('SSEARCH',8) '-' left(what,24) '.. PASS'
else do
   say left('SSEARCH',8) '-' left(what,24) '.. *FAIL*'
   say '   got ' got
   say '   want' want
   err = err + 1
end
return
