/* REXX - ISEARCH(), ISEARCHNN(), LLSEARCH() (#167)                    */
/* ISEARCH/ISEARCHNN compared an uninitialised index with the array    */
/* size, LLSEARCH compared its counter with a "from" that was never    */
/* set: depending on the stack both returned 0 for a present entry.    */
say '----------------------------------------'
say 'File uninit.rexx'
err = 0
a = icreate(10, 'NULL')
call iset a, 3, 42
call check 'ISEARCH found',      isearch(a, 42),    3
call check 'ISEARCH from 4',     isearch(a, 42, 4), 0
call check 'ISEARCHNN',          isearchnn(a),      3
call ifree a
l  = llcreate()
pa = lladd(l, 'alpha')
pb = lladd(l, 'beta')
call check 'LLSEARCH first',     llsearch(l, 'alpha'), pa
call check 'LLSEARCH second',    llsearch(l, 'beta'),  pb
call check 'LLSEARCH missing',   llsearch(l, 'gamma'), 0
call llfree l
say 'Done uninit.rexx'
exit err

check:
parse arg what, got, want
if got = want then say left('UNINIT',8) '-' left(what,20) '.. PASS'
else do
   say left('UNINIT',8) '-' left(what,20) '.. *FAIL* got' got 'want' want
   err = err + 1
end
return
