say '----------------------------------------'
say 'File mvsfix.rexx'
/* rxmvs.c fixes from its SonarCloud findings (#302): LCS terminated  */
/* its result, SPLIT wrote its count into the last word's buffer,     */
/* MVSVAR('CPUS') printed a buffer into itself, ARGV(-1) read beside  */
/* the arguments.                                                     */
err = 0
call check 'LCS',            lcs('ABCBDAB', 'BDCABA'), 'BCBA'
n = split('alpha beta gamma delta', 'w.')
call check 'SPLIT count',    n w.0 w.4, '4 4 delta'
c = mvsvar('CPUS')
call check 'MVSVAR CPUS',    datatype(strip(c), 'X'), 1
call check 'ARGV -1',        argv(-1), ''
say 'Done mvsfix.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('MVSFIX',8) '-' left(what,16) '.. PASS'
else do
   say left('MVSFIX',8) '-' left(what,16) '.. *FAIL* got' got,
       'want' want
   err = err + 1
end
return
