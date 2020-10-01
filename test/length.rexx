say '----------------------------------------'
say 'File length.rexx'
/* LENGTH */

rc = 0

say "Look for LENGTH OK"

/*
From: The REXX Language
      A Practical Approach to Programming
      Second Edition
      MICHAEL COWLISHAW
      1990
*/

if length('abcdefgh') \= 8 then do
  say 'failed in test 1 '
  rc = 8 
end

if length('') \= 0 then do
  say 'failed in test 2 '
  rc = 8 
end

/* These from Mark Hessling. */

if length("") \== 0 then do
  say 'failed in test 3 '
  rc = 8 
end

if length("a") \== 1 then do
  say 'failed in test 4 '
  rc = 8 
end

if length("abc") \== 3 then do
  say 'failed in test 5 '
  rc = 8 
end

if length("abcdefghij") \== 10 then do
  say 'failed in test 6 '
  rc = 8 
end

say "LENGTH OK"

exit rc
