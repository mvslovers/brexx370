say '----------------------------------------'
say 'File symbol.rexx'
/* SYMBOL */

rc = 0

say "Look for SYMBOL OK"

/*
From: The REXX Language
      A Practical Approach to Programming
      Second Edition
      MICHAEL COWLISHAW
      1990
*/

drop A.3; j=3

if symbol('J') \== 'VAR' then do
  say 'failed in test 1 '
  rc = 8 
end

if symbol(J) \== 'LIT' then do
  say 'failed in test 2 '
  rc = 8 
end

if symbol('a.j') \== 'LIT' then do
  say 'failed in test 3 '
  rc = 8 
end

if symbol(2) \== 'LIT' then do
  say 'failed in test 4 '
  rc = 8 
end

if symbol('*') \== 'BAD' then do
  say 'failed in test 5 '
  rc = 8 
end

/* These from Mark Hessling. */

parse value 'foobar' with alpha 1 beta 1 omega 1 gamma.foobar

omega = 'FOOBAR'

if symbol("HEPP") \== "LIT" then do
  say 'failed in test 6 '
  rc = 8 
end

if symbol("ALPHA") \== "VAR" then do
  say 'failed in test 7 '
  rc = 8 
end

if symbol("Un*x") \== "BAD" then do
  say 'failed in test 8 '
  rc = 8 
end

if symbol("gamma.delta") \== "LIT" then do
  say 'failed in test 9 '
  rc = 8 
end

if symbol("gamma.FOOBAR") \== "VAR" then do
  say 'failed in test 10 '
  rc = 8 
end

if symbol("gamma.alpha") \== "LIT" then do
  say 'failed in test 11 '
  rc = 8 
end

if symbol("gamma.omega") \== "VAR" then do
  say 'failed in test 12 '
  rc = 8 
end

/* Supposed to be BAD

if symbol("gamma.Un*x") \== "LIT" then do
  say 'failed in test 13 '
  rc = 8 
end

*/

if symbol("Un*x.gamma") \== "BAD" then do
  say 'failed in test 14 '
  rc = 8 
end

if symbol("!!") \== "LIT" then do
  say 'failed in test 15 '
  rc = 8 
end

if symbol("") \== "BAD" then do
  say 'failed in test 16 '
  rc = 8 
end

if symbol("00"x) \== "BAD" then do
  say 'failed in test 17 '
  rc = 8 
end

if symbol("foo-bar") \== "BAD" then do
  say 'failed in test 18 '
  rc = 8 
end

say "SYMBOL OK"

exit rc
