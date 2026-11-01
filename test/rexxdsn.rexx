say '----------------------------------------'
say 'File rexxdsn.rexx'
/* The main exec is read through a DD whose JCL says DSN=lib(member),  */
/* as RXRUN (RXBATCH) and EXEC (RXTSO) deliver it (#494). libc370 keeps */
/* the member only for DD:name(member), so RXLIST listed no exec, and  */
/* MVSVAR('REXX') and MVSVAR('REXXDSN') were empty: the samples that   */
/* open MVSVAR('REXXDSN')'(DATA)' failed with error 59.                */
err = 0
call rxlist 'STEM'
call check 'RXLIST member',  word(rxlist.1, 2), 'REXXDSN'
call check 'RXLIST DD',      word(rxlist.1, 3), 'RXRUN'
dsn = mvsvar('REXXDSN')
call check 'MVSVAR REXX',    mvsvar('REXX'), 'REXXDSN'
call check 'MVSVAR REXXDSN', dsn \== '' & word(rxlist.1, 4) == dsn, 1
/* the library holds this exec, and a data member beside it is named by */
/* the two together, as the samples do                                  */
call check 'in library',     exists('"'dsn'(REXXDSN)"'), 1
say 'Done rexxdsn.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('REXXDSN',8) '-' left(what,16) '.. PASS'
else do
   say left('REXXDSN',8) '-' left(what,16) '.. *FAIL* got' got 'want' want
   err = err + 1
end
return
