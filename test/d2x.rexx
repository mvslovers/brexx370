say '----------------------------------------'
say 'File d2x.rexx'
/* D2X */

rc = 0

say "Look for D2X OK"

/*
From: The REXX Language
      A Practical Approach to Programming
      Second Edition
      MICHAEL COWLISHAW
      1990
*/

if d2x(9) \== '9' then do
  say 'failed in test 1 '
  rc = 8 
end

if d2x(129) \== '81' then do
  say 'failed in test 2 '
  rc = 8 
end

if d2x(129,1) \== '1' then do
  say 'failed in test 3 '
  rc = 8 
end

if d2x(129,2) \== '81' then do
  say 'failed in test 4 '
  rc = 8 
end

if d2x(129,4) \== '0081' then do
  say 'failed in test 5 '
  rc = 8 
end

if d2x(257,2) \== '01' then do
  say 'failed in test 6 '
  rc = 8 
end

if d2x(-127,2) \== '81' then do
  say 'failed in test 7 '
  rc = 8 
end

if d2x(-127,4) \== 'FF81' then do
  say 'failed in test 8 '
  rc = 8 
end

if d2x(12,0) \== '' then do
  say 'failed in test 9 '
  rc = 8 
end

/* These from Mark Hessling. */

if d2x(0) \== "0" then do
  say 'failed in test 10 '
  rc = 8 
end

if d2x(127) \== "7F" then do
  say 'failed in test 11 '
  rc = 8 
end

if d2x(128) \== "80" then do
  say 'failed in test 12 '
  rc = 8 
end

if d2x(129) \== "81" then do
  say 'failed in test 13 '
  rc = 8 
end

if d2x(1) \== "1" then do
  say 'failed in test 14 '
  rc = 8 
end

if d2x(-1,2) \== "FF" then do
  say 'failed in test 15 '
  rc = 8 
end

if d2x(-127,2) \== "81" then do
  say 'failed in test 16 '
  rc = 8 
end

if d2x(-128,2) \== "80" then do
  say 'failed in test 17 '
  rc = 8 
end

if d2x(-129,2) \== "7F" then do
  say 'failed in test 18 '
  rc = 8 
end

if d2x(-1,3) \== "FFF" then do
  say 'failed in test 19 '
  rc = 8 
end

if d2x(-127,3) \== "F81" then do
  say 'failed in test 20 '
  rc = 8 
end

if d2x(-128,4) \== "FF80" then do
  say 'failed in test 21 '
  rc = 8 
end

if d2x(-129,5) \== "FFF7F" then do
  say 'failed in test 22 '
  rc = 8 
end

if d2x(129,0) \== "" then do
  say 'failed in test 23 '
  rc = 8 
end

if d2x(129,2) \== "81" then do
  say 'failed in test 24 '
  rc = 8 
end

if d2x(256+129,4) \== "0181" then do
  say 'failed in test 25 '
  rc = 8 
end

if d2x(256*256+256+129,6) \== "010181" then do
  say 'failed in test 26 '
  rc = 8 
end

say "D2X OK"

exit rc
