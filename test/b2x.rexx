say '----------------------------------------'
say 'File b2x.rexx'
/* B2X */

rc = 0

say "Look for B2X OK"

/* These from the Rexx book. */

if b2x('11000011') \== 'C3' then do
  say 'failed in test 1 '
  rc = 8 
end

if b2x('10111') \== '17' then do
  say 'failed in test 2 '
  rc = 8 
end

if b2x('101') \== '5' then do
  say 'failed in test 3 '
  rc = 8 
end

if b2x('1 1111 0000') \== '1F0' then do
  say 'failed in test 4 '
  rc = 8 
end

if x2d(b2x('10111')) \== '23' then do
  say 'failed in test 5 '
  rc = 8 
end

/* These from Mark Hessling. */

if b2x("") \== "" then do
  say 'failed in test 6 '
  rc = 8 
end

if b2x("0") \== "0" then do
  say 'failed in test 7 '
  rc = 8 
end

if b2x("1") \== "1" then do
  say 'failed in test 8 '
  rc = 8 
end

if b2x("10") \== "2" then do
  say 'failed in test 9 '
  rc = 8 
end

if b2x("010") \== "2" then do
  say 'failed in test 10 '
  rc = 8 
end

if b2x("1010") \== "A" then do
  say 'failed in test 11 '
  rc = 8 
end

if b2x("1 0101") \== "15" then do
  say 'failed in test 12 '
  rc = 8 
end

if b2x("1 01010101") \== "155" then do
  say 'failed in test 13 '
  rc = 8 
end

if b2x("1 0101 0101") \== "155" then do
  say 'failed in test 14 '
  rc = 8 
end

if b2x("10101 0101") \== "155" then do
  say 'failed in test 15 '
  rc = 8 
end

if b2x("0000 00000000 0000") \== "0000" then do
  say 'failed in test 16 '
  rc = 8 
end

if b2x("11111111 11111111") \== "FFFF" then do
  say 'failed in test 17 '
  rc = 8 
end

if rc=0 then say "B2X OK"
   else say "B2X test failed"
exit rc
