say '----------------------------------------'
say 'File digits.rexx'
/* DIGITS */

rc = 0

say "Look for DIGITS OK"

/* These from the Rexx book. */

if digits() \= 9 then do
  say 'failed in test 1 '
  rc = 8 
end

/* These from Mark Hessling. */

say "DIGITS OK"

exit rc
