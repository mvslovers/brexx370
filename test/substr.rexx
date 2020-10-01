say '----------------------------------------'
say 'File substr.rexx'
/* SUBSTR */

rc = 0

say "Look for SUBSTR OK"

/*
From: The REXX Language
      A Practical Approach to Programming
      Second Edition
      MICHAEL COWLISHAW
      1990
*/

if substr('abc',2) \== 'bc' then do
  say 'failed in test 1 '
  rc = 8 
end

if substr('abc',2,4) \== 'bc  ' then do
  say 'failed in test 2 '
  rc = 8 
end

if substr('abc',2,6,'.') \== 'bc....' then do
  say 'failed in test 3 '
  rc = 8 
end

/* These from Mark Hessling. */

if substr("foobar",2,3) \== "oob" then do
  say 'failed in test 4 '
  rc = 8 
end

if substr("foobar",3) \== "obar" then do
  say 'failed in test 5 '
  rc = 8 
end

if substr("foobar",3,6) \== "obar  " then do
  say 'failed in test 6 '
  rc = 8 
end

if substr("foobar",3,6,'*') \== "obar**" then do
  say 'failed in test 7 '
  rc = 8 
end

if substr("foobar",6,3) \== "r  " then do
  say 'failed in test 8 '
  rc = 8 
end

if substr("foobar",8,3) \== "   " then do
  say 'failed in test 9 '
  rc = 8 
end

say "SUBSTR OK"

exit rc
