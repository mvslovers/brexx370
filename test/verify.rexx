say '----------------------------------------'
say 'File verify.rexx'
/* VERIFY */

rc = 0

say "Look for VERIFY OK"

/*
From: The REXX Language
      A Practical Approach to Programming
      Second Edition
      MICHAEL COWLISHAW
      1990
*/

if verify('123','1234567890') \= 0 then do
  say 'failed in test 1 '
  rc = 8 
end

if verify('1Z3','1234567890') \= 2 then do
  say 'failed in test 2 '
  rc = 8 
end

if verify('AB4T','1234567890','M') \= 3 then do
  say 'failed in test 3 '
  rc = 8 
end

if verify('1P3Q4','1234567890',,3) \= 4 then do
  say 'failed in test 4 '
  rc = 8 
end

if verify('ABCDE','',,3) \= 3 then do
  say 'failed in test 5 '
  rc = 8 
end

if verify('AB3CD5','1234567890','M',4) \= 6 then do
  say 'failed in test 6 '
  rc = 8 
end

/* These from Mark Hessling. */

if verify('foobar', 'barfo', N, 1) \== 0 then do
  say 'failed in test 7 '
  rc = 8 
end

if verify('foobar', 'barfo', M, 1) \== 1 then do
  say 'failed in test 8 '
  rc = 8 
end

if verify('', 'barfo') \== 0 then do
  say 'failed in test 9 '
  rc = 8 
end

if verify('foobar', '') \== 1 then do
  say 'failed in test 10 '
  rc = 8 
end

if verify('foobar', 'barf', N, 3) \== 3 then do
  say 'failed in test 11 '
  rc = 8 
end

if verify('foobar', 'barf', N, 4) \== 0 then do
  say 'failed in test 12 '
  rc = 8 
end

if verify('', '') \== 0 then do
  say 'failed in test 13 '
  rc = 8 
end

say "VERIFY OK"

exit rc
