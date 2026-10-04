say '----------------------------------------'
say 'File llist.rexx'
/* The linked list functions moved from rxmvs.c to rxll.c (#302): a   */
/* round trip through LLCREATE, LLADD, LLGET, LLSET, LLDEL, LL2S,     */
/* S2LL and LLFREE.                                                   */
err = 0
ll = llcreate('TESTLIST')
call check 'LLCREATE',       ll >= 0, 1
call lladd ll, 'ALPHA'
call lladd ll, 'BETA'
call lladd ll, 'GAMMA'
call check 'LLGET FIRST',    llget(ll, 'FIRST'), 'ALPHA'
call check 'LLGET LAST',     llget(ll, 'LAST'), 'GAMMA'
n = 0
call llset ll, 'FIRST'
do while llset(ll, 'NEXT') > 0
   n = n + 1
end
call check 'LLSET NEXT walk', n, 2
call llset ll, 'FIRST'
call lldel ll
call check 'LLDEL first',    llget(ll, 'FIRST'), 'BETA'
s = ll2s(ll)
call check 'LL2S count',     sarray(s), 2
call check 'LL2S item 2',    sget(s, 2), 'GAMMA'
l2 = s2ll(s)
call check 'S2LL first',     llget(l2, 'FIRST'), 'BETA'
call sfree s
call llfree l2
call llfree ll
/* a list number beyond the 32 lists read beside llist[]; it is an    */
/* error now, as for a list that was freed                            */
refused = 0
signal on syntax name llbad
call llget 32, 'FIRST'
signal llafter
llbad:
refused = 1
llafter:
signal off syntax
call check 'LLGET 32',       refused, 1
refused = 0
signal on syntax name llbad2
call llget ll, 'FIRST'
signal llafter2
llbad2:
refused = 1
llafter2:
signal off syntax
call check 'LLGET freed',    refused, 1
say 'Done llist.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('LLIST',8) '-' left(what,16) '.. PASS'
else do
   say left('LLIST',8) '-' left(what,16) '.. *FAIL* got' got,
       'want' want
   err = err + 1
end
return
