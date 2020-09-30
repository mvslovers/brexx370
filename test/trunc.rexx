say '----------------------------------------'
say 'File trunc.rexx'
/* These from TRL */

rc = 0

say "Look for TRUNC OK"

if trunc(12.3) \== 12 then do
  say 'failed in test 1 '
  rc = 8 
end

if trunc(127.09782,3) \== 127.097 then do
  say 'failed in test 2 '
  rc = 8 
end

if trunc(127.1,3) \== 127.100 then do
  say 'failed in test 3 '
  rc = 8 
end

if trunc(127.2) \== 127.00 then do
  say 'failed in test 4 '
  rc = 8 
end

/* These from Mark Hessling. */

if trunc(1234.5678, 2) \== '1234.56' then do
  say 'failed in test 5 '
  rc = 8 
end

if trunc(-1234.5678) \== '-1234' then do
  say 'failed in test 6 '
  rc = 8 
end

if trunc(.5678) \== '0' then do
  say 'failed in test 7 '
  rc = 8 
end

if trunc(.00123) \== '0' then do
  say 'failed in test 8 '
  rc = 8 
end

if trunc(.00123,4) \== '0.0012' then do
  say 'failed in test 9 '
  rc = 8 
end

if trunc(.00127,4) \== '0.0012' then do
  say 'failed in test 10 '
  rc = 8 
end

if trunc(.1678) \== '0' then do
  say 'failed in test 11 '
  rc = 8 
end

if trunc(1234.5678) \== '1234' then do
  say 'failed in test 12 '
  rc = 8 
end

if trunc(4.5678, 7) \== '4.5678000' then do
  say 'failed in test 13 '
  rc = 8 
end

if trunc(10000005.0,2) \== 10000005.00 then do
  say 'failed in test 14 '
  rc = 8 
end

if trunc(10000000.5,2) \== 10000000.50 then do
  say 'failed in test 15 '
  rc = 8 
end

if trunc(10000000.05,2) \== 10000000.10 then do
  say 'failed in test 16 '
  rc = 8 
end

if trunc(10000000.005,2) \== 10000000.00 then do
  say 'failed in test 17 '
  rc = 8 
end

if trunc(10000005.5,2) \== 10000005.50 then do
  say 'failed in test 18 '
  rc = 8 
end

if trunc(10000000.55,2) \== 10000000.60 then do
  say 'failed in test 19 '
  rc = 8 
end

if trunc(10000000.055,2) \== 10000000.10 then do
  say 'failed in test 20 '
  rc = 8 
end

if trunc(10000000.0055,2) \== 10000000.00 then do
  say 'failed in test 21 '
  rc = 8 
end

if trunc(10000000.04,2) \== 10000000.00 then do
  say 'failed in test 22 '
  rc = 8 
end

if trunc(10000000.045,2) \== 10000000.00 then do
  say 'failed in test 23 '
  rc = 8 
end

if trunc(10000000.45,2) \== 10000000.50 then do
  say 'failed in test 24 '
  rc = 8 
end

if trunc(10000000.05,2) \== 10000000.10 then do
  say 'failed in test 25 '
  rc = 8 
end

if trunc(10000000.05,2) \== 10000000.10 then do
  say 'failed in test 26 '
  rc = 8 
end

if trunc(10000000.05,2) \== 10000000.10 then do
  say 'failed in test 27 '
  rc = 8 
end

if trunc(99999999.,2) \== 99999999.00 then do
  say 'failed in test 28 '
  rc = 8 
end

if trunc(99999999.9,2) \== 99999999.90 then do
  say 'failed in test 29 '
  rc = 8 
end

if trunc(99999999.99,2) \== 100000000.00 then do
  say 'failed in test 30 '
  rc = 8 
end

if trunc(1E2,0) \== 100 then do
  say 'failed in test 31 '
  rc = 8 
end

if trunc(12E1,0) \== 120 then do
  say 'failed in test 32 '
  rc = 8 
end

if trunc(123.,0) \== 123 then do
  say 'failed in test 33 '
  rc = 8 
end

if trunc(123.1,0) \== 123 then do
  say 'failed in test 34 '
  rc = 8 
end

if trunc(123.12,0) \== 123 then do
  say 'failed in test 35 '
  rc = 8 
end

if trunc(123.123,0) \== 123 then do
  say 'failed in test 36 '
  rc = 8 
end

if trunc(123.1234,0) \== 123 then do
  say 'failed in test 37 '
  rc = 8 
end

if trunc(123.12345,0) \== 123 then do
  say 'failed in test 38 '
  rc = 8 
end

if trunc(1E2,1) \== 100.0 then do
  say 'failed in test 39 '
  rc = 8 
end

if trunc(12E1,1) \== 120.0 then do
  say 'failed in test 40 '
  rc = 8 
end

if trunc(123.,1) \== 123.0 then do
  say 'failed in test 41 '
  rc = 8 
end

if trunc(123.1,1) \== 123.1 then do
  say 'failed in test 42 '
  rc = 8 
end

if trunc(123.12,1) \== 123.1 then do
  say 'failed in test 43 '
  rc = 8 
end

if trunc(123.123,1) \== 123.1 then do
  say 'failed in test 44 '
  rc = 8 
end

if trunc(123.1234,1) \== 123.1 then do
  say 'failed in test 45 '
  rc = 8 
end

if trunc(123.12345,1) \== 123.1 then do
  say 'failed in test 46 '
  rc = 8 
end

if trunc(1E2,2) \== 100.00 then do
  say 'failed in test 47 '
  rc = 8 
end

if trunc(12E1,2) \== 120.00 then do
  say 'failed in test 48 '
  rc = 8 
end

if trunc(123.,2) \== 123.00 then do
  say 'failed in test 49 '
  rc = 8 
end

if trunc(123.1,2) \== 123.10 then do
  say 'failed in test 50 '
  rc = 8 
end

if trunc(123.12,2) \== 123.12 then do
  say 'failed in test 51 '
  rc = 8 
end

if trunc(123.123,2) \== 123.12 then do
  say 'failed in test 52 '
  rc = 8 
end

if trunc(123.1234,2) \== 123.12 then do
  say 'failed in test 53 '
  rc = 8 
end

if trunc(123.12345,2) \== 123.12 then do
  say 'failed in test 54 '
  rc = 8 
end

if trunc(1E2,3) \== 100.000 then do
  say 'failed in test 55 '
  rc = 8 
end

if trunc(12E1,3) \== 120.000 then do
  say 'failed in test 56 '
  rc = 8 
end

if trunc(123.,3) \== 123.000 then do
  say 'failed in test 57 '
  rc = 8 
end

if trunc(123.1,3) \== 123.100 then do
  say 'failed in test 58 '
  rc = 8 
end

if trunc(123.12,3) \== 123.120 then do
  say 'failed in test 59 '
  rc = 8 
end

if trunc(123.123,3) \== 123.123 then do
  say 'failed in test 60 '
  rc = 8 
end

if trunc(123.1234,3) \== 123.123 then do
  say 'failed in test 61 '
  rc = 8 
end

if trunc(123.12345,3) \== 123.123 then do
  say 'failed in test 62 '
  rc = 8 
end

if trunc(1E2,4) \== 100.0000 then do
  say 'failed in test 63 '
  rc = 8 
end

if trunc(12E1,4) \== 120.0000 then do
  say 'failed in test 64 '
  rc = 8 
end

if trunc(123.,4) \== 123.0000 then do
  say 'failed in test 65 '
  rc = 8 
end

if trunc(123.1,4) \== 123.1000 then do
  say 'failed in test 66 '
  rc = 8 
end

if trunc(123.12,4) \== 123.1200 then do
  say 'failed in test 67 '
  rc = 8 
end

if trunc(123.123,4) \== 123.1230 then do
  say 'failed in test 68 '
  rc = 8 
end

if trunc(123.1234,4) \== 123.1234 then do
  say 'failed in test 69 '
  rc = 8 
end

if trunc(123.12345,4) \== 123.1234 then do
  say 'failed in test 70 '
  rc = 8 
end

if trunc(1E2,5) \== 100.00000 then do
  say 'failed in test 71 '
  rc = 8 
end

if trunc(12E1,5) \== 120.00000 then do
  say 'failed in test 72 '
  rc = 8 
end

if trunc(123.,5) \== 123.00000 then do
  say 'failed in test 73 '
  rc = 8 
end

if trunc(123.1,5) \== 123.10000 then do
  say 'failed in test 74 '
  rc = 8 
end

if trunc(123.12,5) \== 123.12000 then do
  say 'failed in test 75 '
  rc = 8 
end

if trunc(123.123,5) \== 123.12300 then do
  say 'failed in test 76 '
  rc = 8 
end

if trunc(123.1234,5) \== 123.12340 then do
  say 'failed in test 77 '
  rc = 8 
end

if trunc(123.12345,5) \== 123.12345 then do
  say 'failed in test 78 '
  rc = 8 
end

say "TRUNC OK"

exit rc
