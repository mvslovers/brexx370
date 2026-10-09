say '----------------------------------------'
say 'File llnull.rexx'
/* Linked lists without a current entry, at position 0 and past the   */
/* end (#386): LLGET NEXT/PREVIOUS and LLINSERT used a NULL or the     */
/* root as an entry, LLGET PREVIOUS from the first entry returned the  */
/* root as data, LLLINK into an empty list lost the entry, at the root */
/* it detached the list, and it never set the successor's back link.   */
/* S2LL took from 0 and an array that was never created.               */
err = 0
l = llcreate()
call lladd l, 'a'
call lladd l, 'b'
call check 'NEXT past the end',   llget(l, 'NEXT'), '$$EMPTY$$'
call check 'NEXT again',          llget(l, 'NEXT'), '$$EMPTY$$'
call check 'FIRST',               llget(l, 'FIRST'), 'a'
call check 'PREVIOUS of first',   llget(l, 'PREVIOUS'), '$$EMPTY$$'
call check 'list',                fwd(l) '/' bwd(l), 'a b / b a'
/* LLINSERT at position 0, and past the end */
call llset l, 'POSITION', 0
call llinsert l, 'z'
call check 'insert at 0',         fwd(l) '/' bwd(l), 'z a b / b a z'
x = llget(l, 'LAST')
x = llget(l, 'NEXT')
call llinsert l, 'y'
call check 'insert past end',     fwd(l) '/' bwd(l), 'z a b y / y b a z'
/* LLLINK into an empty list, then add behind it */
m = llcreate()
call llset l, 'POSITION', 2
d = lldelink(l)
call check 'delinked',            fwd(l), 'z b y'
call lllink m, d
call lladd m, 'x'
call check 'link into empty',     fwd(m) '/' bwd(m), 'a x / x a'
/* LLLINK before an entry and at position 0 */
call llset l, 'POSITION', 2
d = lldelink(l)
call llset m, 'POSITION', 2
call lllink m, d
call check 'link before entry',   fwd(m) '/' bwd(m), 'a b x / x b a'
call llset l, 'POSITION', 1
d = lldelink(l)
call llset m, 'POSITION', 0
call lllink m, d
call check 'link at 0',           fwd(m) '/' bwd(m), 'z a b x / x b a z'
/* S2LL bounds */
s = screate(5)
call sset s, , 'p'; call sset s, , 'q'
call e40 'S2LL from 0',           's2ll(' s ', 0)'
n = s2ll(s, 1, 9)
call check 'S2LL to clipped',     fwd(n), 'p q'
call e40 'S2LL not created',      's2ll(120)'
/* LLGET FIFO/LIFO free the entry they take (it leaked) */
q = fifo('CREATE')
call fifo 'PUSH', q, 'a'; call fifo 'PUSH', q, 'b'
call check 'FIFO pulls',          fifo('PULL', q) fifo('PULL', q), 'a b'
q = lifo('CREATE')
call lifo 'PUSH', q, 'a'; call lifo 'PUSH', q, 'b'
call check 'LIFO pulls',          lifo('PULL', q) lifo('PULL', q), 'b a'
say 'Done llnull.rexx'
exit err

fwd: procedure
parse arg ll
r = ''; e = llget(ll, 'FIRST')
do 20 while e \== '$$EMPTY$$'
   r = r e; e = llget(ll, 'NEXT')
end
return strip(r)

bwd: procedure
parse arg ll
r = ''; e = llget(ll, 'LAST')
do 20 while e \== '$$EMPTY$$'
   r = r e; e = llget(ll, 'PREVIOUS')
end
return strip(r)

check:
parse arg what, got, want
if got == want then say left('LLNULL',8) '-' left(what,18) '.. PASS'
else do
   say left('LLNULL',8) '-' left(what,18) '.. *FAIL* got' got 'want' want
   err = err + 1
end
return

e40: procedure expose err
parse arg what, expr
signal on syntax name e40x
interpret 'x =' expr
say left('LLNULL',8) '-' left(what,18) '.. *FAIL* no error'
err = err + 1
return
e40x:
if rc = 40 then say left('LLNULL',8) '-' left(what,18) '.. PASS'
else do
   say left('LLNULL',8) '-' left(what,18) '.. *FAIL* rc' rc
   err = err + 1
end
return
