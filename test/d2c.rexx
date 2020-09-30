say '----------------------------------------'
say 'File d2c.rexx'
/* D2C */

rc = 0

say "Look for D2C OK"

/* These from the Rexx book. */

if d2c(9) \== '09'x then do
  say 'failed in test 1 '
  rc = 8 
end

if d2c(129) \== '81'x then do
  say 'failed in test 2 '
  rc = 8 
end

if d2c(129,1) \== '81'x then do
  say 'failed in test 3 '
  rc = 8 
end

if d2c(129,2) \== '0081'x then do
  say 'failed in test 4 '
  rc = 8 
end

if d2c(257,1) \== '01'x then do
  say 'failed in test 5 '
  rc = 8 
end

if d2c(-127,1) \== '81'x then do
  say 'failed in test 6 '
  rc = 8 
end

if d2c(-127,2) \== 'FF81'x then do
  say 'failed in test 7 '
  rc = 8 
end

if d2c(-1,4) \== 'FFFFFFFF'x then do
  say 'failed in test 8 '
  rc = 8 
end

if d2c(12,0) \== '' then do
  say 'failed in test 9 '
  rc = 8 
end

/* These from Mark Hessling. */

if d2c(127) \== "7f"x then do
  say 'failed in test 10 '
  rc = 8 
end

if d2c(128) \== "80"x then do
  say 'failed in test 11 '
  rc = 8 
end

if d2c(129) \== "81"x then do
  say 'failed in test 12 '
  rc = 8 
end

if d2c(1) \== "01"x then do
  say 'failed in test 13 '
  rc = 8 
end

if d2c(-1,1) \== "FF"x then do
  say 'failed in test 14 '
  rc = 8 
end

if d2c(-127,1) \== "81"x then do
  say 'failed in test 15 '
  rc = 8 
end

if d2c(-128,1) \== "80"x then do
  say 'failed in test 16 '
  rc = 8 
end

if d2c(-129,1) \== "7F"x then do
  say 'failed in test 17 '
  rc = 8 
end

if d2c(-1,2) \== "FFFF"x then do
  say 'failed in test 18 '
  rc = 8 
end

if d2c(-127,2) \== "FF81"x then do
  say 'failed in test 19 '
  rc = 8 
end

if d2c(-128,2) \== "FF80"x then do
  say 'failed in test 20 '
  rc = 8 
end

if d2c(-129,2) \== "FF7F"x then do
  say 'failed in test 21 '
  rc = 8 
end

if d2c(129,0) \== "" then do
  say 'failed in test 22 '
  rc = 8 
end

if d2c(129,1) \== "81"x then do
  say 'failed in test 23 '
  rc = 8 
end

if d2c(256+129,2) \== "0181"x then do
  say 'failed in test 24 '
  rc = 8 
end

if d2c(256*256+256+129,3) \== "010181"x then do
  say 'failed in test 25 '
  rc = 8 
end

say "D2C OK"

exit rc
