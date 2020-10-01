say '----------------------------------------'
say 'File wordlen.rexx'
/* WORDLENGTH */

rc = 0

say "Look for WORDLENGTH OK"

/*
From: The REXX Language
      A Practical Approach to Programming
      Second Edition
      MICHAEL COWLISHAW
      1990
*/

if wordlength('Now is the time',2) \=2 then do
  say 'failed in test 1 '
  rc = 8 
end

if wordlength('Now comes the time',2) \=5 then do
  say 'failed in test 2 '
  rc = 8 
end

if wordlength('Now is the time',6) \=0 then do
  say 'failed in test 3 '
  rc = 8 
end

/* These from Mark Hessling. */

if wordlength('This is certainly a test',1) \== '4' then do
  say 'failed in test 4 '
  rc = 8 
end

if wordlength('This is certainly a test',2) \== '2' then do
  say 'failed in test 5 '
  rc = 8 
end

if wordlength('This is certainly a test',5) \== '4' then do
  say 'failed in test 6 '
  rc = 8 
end

if wordlength('This is certainly a test ',5) \== '4' then do
  say 'failed in test 7 '
  rc = 8 
end

if wordlength('This is certainly a test',6) \== '0' then do
  say 'failed in test 8 '
  rc = 8 
end

if wordlength('',1) \== '0' then do
  say 'failed in test 9 '
  rc = 8 
end

if wordlength('',10) \== '0' then do
  say 'failed in test 10 '
  rc = 8 
end

say "WORDLENGTH OK"

exit rc
