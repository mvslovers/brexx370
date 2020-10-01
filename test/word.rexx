say '----------------------------------------'
say 'File word.rexx'
/* WORD */

rc = 0

say "Look for WORD OK"

/*
From: The REXX Language
      A Practical Approach to Programming
      Second Edition
      MICHAEL COWLISHAW
      1990
*/

if word('Now is the time',3) \== 'the' then do
  say 'failed in test 1 '
  rc = 8 
end

if word('Now is the time',5) \== '' then do
  say 'failed in test 2 '
  rc = 8 
end

/* These from Mark Hessling. */

if word('This is certainly a test',1) \== 'This' then do
  say 'failed in test 3 '
  rc = 8 
end

if word(' This is certainly a test',1) \== 'This' then do
  say 'failed in test 4 '
  rc = 8 
end

if word('This is certainly a test',1) \== 'This' then do
  say 'failed in test 5 '
  rc = 8 
end

if word('This is certainly a test',2) \== 'is' then do
  say 'failed in test 6 '
  rc = 8 
end

if word('This is certainly a test',2) \== 'is' then do
  say 'failed in test 7 '
  rc = 8 
end

if word('This is certainly a test',5) \== 'test' then do
  say 'failed in test 8 '
  rc = 8 
end

if word('This is certainly a test ',5) \== 'test' then do
  say 'failed in test 9 '
  rc = 8 
end

if word('This is certainly a test',6) \== '' then do
  say 'failed in test 10 '
  rc = 8 
end

if word('',1) \== '' then do
  say 'failed in test 11 '
  rc = 8 
end

if word('',10) \== '' then do
  say 'failed in test 12 '
  rc = 8 
end

if word('test ',2) \== '' then do
  say 'failed in test 13 '
  rc = 8 
end

say "WORD OK"

exit rc
