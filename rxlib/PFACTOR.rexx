/* ---------------------------------------------------------------------
 * Prime Factorization
 *   PFACTOR(number)
 *     returns primefactors in stem PRIMES.
 * ............................... Created by PeterJ on 2. February 2022
 * ---------------------------------------------------------------------
 */
pfactor: Procedure expose primes.
  parse arg number
  say number
  number=number%1
  primes.0=0
  if number = 1 then return primes.0
  p0=0
  factor=2
  do while factor*factor<=number
     if number//factor \= 0 then factor=factor+1
     else do
        p0=p0+1
        primes.p0=factor
        number=number/factor%1
     end
  end
  p0=p0+1
  primes.p0=number
  primes.0=p0
return p0
