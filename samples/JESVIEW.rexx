/* -------------------------------------------------------------
 * Print JES2 Spool Queue
 * -------------------------------------------------------------
 */
spool=JESQUEUE()
say '      Job Name   Number    Class'
say copies('-',40)
do i=1 to sarray(spool)
   say right(i,3)'   'sget(spool,i)
end
