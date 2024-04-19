max=25
/* -------------------------------------------
 * FIFO stack Example
 * -------------------------------------------
 */
call time('R')
st1=FIFO("cREATE",'LIFO Stack')
do i=1 to max
   call FIFO("PUSH",st1,'FRED 'i)
end
say copies('-',50)
say "report on LIFO stack"
say copies('-',50)
do i=1 until llcurrent=0
   say FIFO("PULL",st1)
end
