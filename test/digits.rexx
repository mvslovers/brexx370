say '----------------------------------------'
say 'File digits.rexx'
/* DIGITS */

rc = 0

say "Look for DIGITS OK"

/*
From: The REXX Language
      A Practical Approach to Programming
      Second Edition
      MICHAEL COWLISHAW
      1990
*/

if digits() \= 9 then do
  say 'failed in test 1 '
  rc = 8 
end

/* These from Mark Hessling. */

say "DIGITS OK"

exit rc
