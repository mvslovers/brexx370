say '----------------------------------------'
say 'File x2b.rexx'
/* X2B */

rc = 0

say "Look for X2B OK"

/* These from the Rexx book. */

if x2b('C3') \== '11000011' then do
  say 'failed in test 1 '
  rc = 8 
end

if x2b('7') \== '0111' then do
  say 'failed in test 2 '
  rc = 8 
end

if x2b('1 C1') \== '000111000001' then do
  say 'failed in test 3 '
  rc = 8 
end

if x2b(c2x('C3'x)) \== '11000011' then do
  say 'failed in test 4 '
  rc = 8 
end

if x2b(d2x('129')) \== '10000001' then do
  say 'failed in test 5 '
  rc = 8 
end

if x2b(d2x('12')) \== '1100' then do
  say 'failed in test 6 '
  rc = 8 
end

/* These from Mark Hessling. */

if x2b("416263") \== "010000010110001001100011" then do
  say 'failed in test 7 '
  rc = 8 
end

if x2b("DeadBeef") \== "11011110101011011011111011101111" then do
  say 'failed in test 8 '
  rc = 8 
end

if x2b("1 02 03") \== "00010000001000000011" then do
  say 'failed in test 9 '
  rc = 8 
end

if x2b("102 03") \== "00010000001000000011" then do
  say 'failed in test 10 '
  rc = 8 
end

if x2b("102") \== "000100000010" then do
  say 'failed in test 11 '
  rc = 8 
end

if x2b("11 2F") \== "0001000100101111" then do
  say 'failed in test 12 '
  rc = 8 
end

if x2b("") \== "" then do
  say 'failed in test 13 '
  rc = 8 
end

say "X2B OK"

exit rc
