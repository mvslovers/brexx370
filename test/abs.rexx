say '----------------------------------------'
say 'File abs.rexx'
/* ABS */

rc = 0

say "Look for ABS OK"

/* These from the Rexx book. */

if abs('12.3') \= 12.3 then do
  say 'failed in test 1 '
  rc = 8 
end

if abs(' -0.307') \= 0.307 then do
  say 'failed in test 2 '
  rc = 8 
end

/* These from Mark Hessling. */

if abs(-12.345) \== 12.345 then do
  say 'failed in test 3 '
  rc = 8 
end

if abs(12.345) \== 12.345 then do
  say 'failed in test 4 '
  rc = 8 
end

if abs(-0.0) \== 0 then do
  say 'failed in test 5 '
  rc = 8 
end

if abs(0.0) \== 0 then do
  say 'failed in test 6 '
  rc = 8 
end

say "ABS OK"

exit rc
