say '----------------------------------------'
say 'File bitxor.rexx'
/* BITXOR */

rc = 0

say "Look for BITXOR OK"

/* These from the Rexx book. */

if bitxor('12'x,'22'x) \== '30'x then do
  say 'failed in test 1 '
  rc = 8 
end

if bitxor('1211'x,'22'x) \== '3011'x then do
  say 'failed in test 2 '
  rc = 8 
end

/* EBCDIC dependent */

if bitxor('C711'x,'222222'x,' ') \== 'E53362'x then do
  say 'failed in test 3 '
  rc = 8 
end



if bitxor('1111'x,'444444'x,'40'x) \== '555504'x then do
  say 'failed in test 4 '
  rc = 8 
end

if bitxor('1111'x,,'4D'x) \== '5C5C'x then do
  say 'failed in test 5 '
  rc = 8 
end

/* These from Mark Hessling. */

if bitxor( '123456'x, '3456'x ) \== '266256'x then do
  say 'failed in test 6 '
  rc = 8 
end

if bitxor( '3456'x, '123456'x, '99'x ) \== '2662cf'x then do
  say 'failed in test 7 '
  rc = 8 
end

if bitxor( '123456'x,, '55'x) \== '476103'x then do
  say 'failed in test 8 '
  rc = 8 
end

if bitxor( 'foobar' ) \== 'foobar' then do
  say 'failed in test 9 '
  rc = 8 
end

/* This one is ASCII dependent. 

if bitxor( 'FooBar' ,, '20'x) \== 'fOObAR' then do
  say 'failed in test 10 '
  rc = 8 
end
*/

say "BITXOR OK"

exit rc
