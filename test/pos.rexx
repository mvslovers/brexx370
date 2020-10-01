say '----------------------------------------'
say 'File pos.rexx'
/* POS */

rc = 0

say "Look for POS OK"

/*
From: The REXX Language
      A Practical Approach to Programming
      Second Edition
      MICHAEL COWLISHAW
      1990
*/

if pos('day','Saturday') \= 6 then do
  say 'failed in test 1 '
  rc = 8 
end

if pos('x','abc def ghi') \= 0 then do
  say 'failed in test 2 '
  rc = 8 
end

if pos(' ','abc def ghi') \= 4 then do
  say 'failed in test 3 '
  rc = 8 
end

if pos(' ','abc def ghi',5) \= 8 then do
  say 'failed in test 4 '
  rc = 8 
end

/* These from Mark Hessling. */

if pos('foo','a foo foo b') \== 3 then do
  say 'failed in test 5 '
  rc = 8 
end

if pos('foo','a foo foo',3) \== 3 then do
  say 'failed in test 6 '
  rc = 8 
end

if pos('foo','a foo foo',4) \== 7 then do
  say 'failed in test 7 '
  rc = 8 
end

if pos('foo','a foo foo b',30) \== 0 then do
  say 'failed in test 8 '
  rc = 8 
end

if pos('foo','a foo foo b',1) \== 3 then do
  say 'failed in test 9 '
  rc = 8 
end

if pos('','a foo foo b') \== 0 then do
  say 'failed in test 10 '
  rc = 8 
end

if pos('foo','') \== 0 then do
  say 'failed in test 11 '
  rc = 8 
end

if pos('','') \== 0 then do
  say 'failed in test 12 '
  rc = 8 
end

if pos('b' , 'a') \== 0 then do
  say 'failed in test 13 '
  rc = 8 
end

if pos('b','b') \== 1 then do
  say 'failed in test 14 '
  rc = 8 
end

if pos('b','abc') \== 2 then do
  say 'failed in test 15 '
  rc = 8 
end

if pos('b','def') \== 0 then do
  say 'failed in test 16 '
  rc = 8 
end

if pos('foo','foo foo b') \== 1 then do
  say 'failed in test 17 '
  rc = 8 
end

say "POS OK"

exit rc
