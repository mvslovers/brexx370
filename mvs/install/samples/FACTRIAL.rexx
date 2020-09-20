/* recursion test of factorial */
/* note: this implementation of rexx uses two kinds of
         of numbers integers (C long (4-bytes) numbers from -2E9 upto 2E9),
         and real (C double precision numbers). It's better
         to use a real number ie 45.0 instead of 45 for large
         factorials since the later will result to a factorial using
     integer arithmetic resulting in a crazy result
         (15 is the largest integer factorial that can be calculated
          with out any error )
*/
numeric digits 20
if arg() ^= 1 then do
    say 'Enter a number'
    pull num
end; else do
    num = arg(1)
end
 
if datatype(num) ^= 'NUM' | num < 0 then do
    say 'Invalid number "'num'"'
    exit 2
end
 
/* you can even translate the number to real with the following instr */
/* num = num + 0.0 /* so from now on num will be treated as real */ */
 
say num'! = ' trunc(fact(num))
exit
 
fact: procedure
if arg(1)<=0 then return 1
return  fact(arg(1)-1)*arg(1)
