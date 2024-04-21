/* ////////////////////////////////////////////////////////// */
/* // Name: Peter M. Maurer                                   */
/* // Program: Sieve of Eratosthenes                          */
/* // Due: Never                                              */
/* // Language: REXX                                          */
/* ////////////////////////////////////////////////////////// */

arg pmax
call time('r')
/* define the sieve data structure */
do i=0 to pmax - 1
    /* everything is potentially prime until proven otherwise */
    Candidates.i = 1
end
/* Neither 1 nor 0 is prime, so flag them off  */
Candidates.0 = 0
Candidates.1 = 0
/* start the sieve with the integer 0 */
i = 0
do while i < pmax
    /* advance to the next un-crossed out number. */
    /* this number must be a prime */
    do while (i < pmax) & (Candidates.i = 0)
        i = i + 1
    end
    /* insure against running off the end of the data structure */
    if i<pmax then do
        /* cross out all multiples of the prime, starting with 2*p. */
        j = 2
        k = i * j
        do while k<pmax
            Candidates.k =  0
            j = j + 1
            k = i * j
        end
        /* advance to the next candidate */
        i = i + 1
    end
end
/* all uncrossed-out numbers are prime (and only those numbers)  */
/* print all primes  */
line = ""
np = 0
do i = 0 to pmax - 1
    if Candidates.i <> 0 then do
        line = line right(i,8)
        np = np + 1
        if length(line) > 123 then do
            say line
            line = ""
        end
    end
end i
if length(line) > 0 then say line
say np "primes found in "time('e')" seconds"
