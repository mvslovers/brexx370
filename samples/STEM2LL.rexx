max=1000
/* -------------------------------------------
 * Copy STEM into LLIST
 * -------------------------------------------
 */
do i=1 to max
   myStem.i=i". Record"
end
mystem.0=max
call time('r')
ll1=stem2ll('myStem.')
say "STEM2LL "time('e')
call lllist ll1,max-10,max
