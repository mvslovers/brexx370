/* -------------------------------------------------------------
 * Sieve of Sundaram
 * -------------------------------------------------------------
 */
arg pmax
  if pmax='' then pmax=300
  call time('r')
  ix=icreate(pmax,'SUNDARAM')
 /* print all primes  */
  line = ""
  np = 0
  do i = 1 to pmax
     line = line right(iget(ix,i),8)
     if length(line) <=123 then iterate
     say line
     line = ""
  end
  if length(line) > 0 then say line
  say pmax "primes found in "time('e')" seconds"
return
