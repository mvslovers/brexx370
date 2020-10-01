say '----------------------------------------'
say 'File bitand.rexx'
/* BITAND */

rc = 0

say "Look for BITAND OK"

/*
From: The REXX Language
      A Practical Approach to Programming
      Second Edition
      MICHAEL COWLISHAW
      1990
*/

if bitand('73'x,'27'x) \== '23'x then do
  say 'failed in test 1 '
  rc = 8 
end

if bitand('13'x,'5555'x) \== '1155'x then do
  say 'failed in test 2 '
  rc = 8 
end

if bitand('13'x,'5555'x,'74'x) \== '1154'x then do
  say 'failed in test 3 '
  rc = 8 
end

/* These from Mark Hessling. */

if bitand( '123456'x, '3456'x ) \== '101456'x then do
  say 'failed in test 4 '
  rc = 8 
end

if bitand( '3456'x, '123456'x, '99'x ) \== '101410'x then do
  say 'failed in test 5 '
  rc = 8 
end

if bitand( '123456'x,, '55'x) \== '101454'x then do
  say 'failed in test 6 '
  rc = 8 
end

if bitand( 'foobar' ) \== 'foobar' then do
  say 'failed in test 7 '
  rc = 8 
end

/* This one is ASCII dependent. 

if bitand( 'FooBar' ,, 'df'x) \== 'FOOBAR' then do
  say 'failed in test 8 '
  rc = 8 
end
*/

say "BITAND OK"

exit rc
