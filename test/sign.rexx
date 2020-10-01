say '----------------------------------------'
say 'File sign.rexx'
/* SIGN */

rc = 0

say "Look for SIGN OK"

/*
From: The REXX Language
      A Practical Approach to Programming
      Second Edition
      MICHAEL COWLISHAW
      1990
*/

if sign('12.3') \= 1 then do
  say 'failed in test 1 '
  rc = 8 
end

if sign(0.0) \= 0 then do
  say 'failed in test 2 '
  rc = 8 
end

if sign(' -0.307') \= -1 then do
  say 'failed in test 3 '
  rc = 8 
end

/* These from Mark Hessling. */

if sign("0") \== 0 then do
  say 'failed in test 4 '
  rc = 8 
end

if sign("-0") \== 0 then do
  say 'failed in test 5 '
  rc = 8 
end

if sign("0.4") \== 1 then do
  say 'failed in test 6 '
  rc = 8 
end

if sign("-10") \== -1 then do
  say 'failed in test 7 '
  rc = 8 
end

if sign("15") \== 1 then do
  say 'failed in test 8 '
  rc = 8 
end

say "SIGN OK"

exit rc
