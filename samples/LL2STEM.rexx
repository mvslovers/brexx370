max=1000
/* -------------------------------------------
 * Copy LLIST into STEM
 * -------------------------------------------
 */
LL1=LLCREATE("LLIST")
do i=1 to max
   call LLADD(LL1,'FRED 'i)
end
call ll2stem(LL1,'myStem.')
do i=mystem.0-10 to mystem.0
   say i mystem.i
end
exit
