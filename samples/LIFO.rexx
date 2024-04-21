max=25
/* -------------------------------------------
 * LIFO stack Example
 * -------------------------------------------
 */
call time('R')
st1=LIFO("cREATE",'LIFO Stack')
do i=1 to max
   call LIFO("PUSH",st1,'Entry 'i)
end
say copies('-',50)
say "report on LIFO stack"
say copies('-',50)
do i=1 until llcurrent=0
   say LIFO("PULL",st1)
end
