say '----------------------------------------'
say 'File words.rexx'
/* WORDS */

rc = 0

say "Look for WORDS OK"

/*
From: The REXX Language
      A Practical Approach to Programming
      Second Edition
      MICHAEL COWLISHAW
      1990
*/

if words('Now is the time') \= 4 then do
  say 'failed in test 1 '
  rc = 8 
end

if words(' ') \= 0 then do
  say 'failed in test 2 '
  rc = 8 
end

/* These from Mark Hessling. */

if words('This is certainly a test') \== 5 then do
  say 'failed in test 3 '
  rc = 8 
end

if words(' This is certainly a test') \== 5 then do
  say 'failed in test 4 '
  rc = 8 
end

if words('This is certainly a test') \== 5 then do
  say 'failed in test 5 '
  rc = 8 
end

if words('This is certainly a test ') \== 5 then do
  say 'failed in test 6 '
  rc = 8 
end

if words(' hepp ') \== 1 then do
  say 'failed in test 7 '
  rc = 8 
end

if words(' hepp hepp ') \== 2 then do
  say 'failed in test 8 '
  rc = 8 
end

if words('') \== 0 then do
  say 'failed in test 9 '
  rc = 8 
end

if words(' ') \== 0 then do
  say 'failed in test 10 '
  rc = 8 
end

say "WORDS OK"

exit rc
