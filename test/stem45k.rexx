/* REXX - 45000 stem entries fit the 8192K region of the step (#504)   */
/* A stem entry is four small blocks (variable, name, value, tree      */
/* leaf). libc370 gives every block at least 64 bytes, so an entry took */
/* 256 bytes, 11.5 MB for 45000, and the step ran out of memory (the   */
/* sieve of samples/PRIMES.rexx, 30000 entries, was on the edge). The  */
/* pool of bmem.c needs about 150 bytes, 6.7 MB.                       */
say '----------------------------------------'
say 'File stem45k.rexx'
n = 0
do i = 0 to 44999
   k = (i * 7919) // 45007   /* all different, in no order: a flat tree */
   s.k = i
   n = n + 1
end
if n <> 45000 | s.0 <> 0 | s.7919 <> 1 then do
   say 'STEM45K  - wrong entries .. *FAIL*'
   exit 1
end
say 'Done stem45k.rexx'
exit 0
