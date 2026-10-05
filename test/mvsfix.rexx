say '----------------------------------------'
say 'File mvsfix.rexx'
/* rxmvs.c fixes from its SonarCloud findings (#302): LCS terminated  */
/* its result, SPLIT wrote its count into the last word's buffer,     */
/* MVSVAR('CPUS') printed a buffer into itself. ARGV(-1) is error 40 */
/* (get_oiv), the bound in R_argv only makes that visible.           */
err = 0
call check 'LCS',            lcs('ABCBDAB', 'BDCABA'), 'BCBA'
n = split('alpha beta gamma delta', 'w.')
call check 'SPLIT count',    n w.0 w.4, '4 4 delta'
c = mvsvar('CPUS')
call check 'MVSVAR CPUS',    datatype(strip(c), 'X'), 1
call check 'ARGV -1',        refused('argv(-1)'), 1
/* DATTIMBASE 'B' was ctime(): now localtime_r() in ctime's format     */
b = dattimbase('B', 1615310123, 'T')
call check 'DATTIMBASE B',   length(b) words(b) word(b, 5), '24 5 2021'
call check 'DATTIMBASE T',   datatype(dattimbase('T', b, 'B'), 'W'), 1
/* RXLIST 'R' never said found. MEMORY is not called here: it holds   */
/* all free storage to map it, and the step's address space then ran  */
/* out of system storage (S40D) in run 37282528282.                   */
call check 'RXLIST R none',  rxlist('R', 'NO-SUCH-EXEC'), -1
call check 'QUOTE',          quote("it's"), '"it''s"'
say 'Done mvsfix.rexx'
exit err

refused:
parse arg expr
signal on syntax name refusedyes
interpret 'x =' expr
signal off syntax
return 0
refusedyes:
signal off syntax
return 1

check:
parse arg what, got, want
if got == want then say left('MVSFIX',8) '-' left(what,16) '.. PASS'
else do
   say left('MVSFIX',8) '-' left(what,16) '.. *FAIL* got' got,
       'want' want
   err = err + 1
end
return
