say '----------------------------------------'
say 'File c2d.rexx'
/* C2D */

rc = 0

say "Look for C2D OK"

/* These from the Rexx book. */

if c2d('09'x) \== 9 then do
  say 'failed in test 1 '
  rc = 8 
end

if c2d('81'x) \== 129 then do
  say 'failed in test 2 '
  rc = 8 
end

if c2d('a'x) \== 129 then do
  say 'failed in test 3 '
  rc = 8 
end

if c2d('FF81'x) \== 65409 then do
  say 'failed in test 4 '
  rc = 8 
end

if c2d('') \== 0 then do
  say 'failed in test 5 '
  rc = 8 
end

if c2d('81'x,1) \== -127 then do
  say 'failed in test 6 '
  rc = 8 
end

if c2d('81'x,2) \== 129 then do
  say 'failed in test 7 '
  rc = 8 
end

if c2d('FF81'x,2) \== -127 then do
  say 'failed in test 8 '
  rc = 8 
end

if c2d('FF81'x,1) \== -127 then do
  say 'failed in test 9 '
  rc = 8 
end

if c2d('FF7F'x,1) \== 127 then do
  say 'failed in test 10 '
  rc = 8 
end

if c2d('F081'x,2) \== -3967 then do
  say 'failed in test 11 '
  rc = 8 
end

if c2d('F081'x,1) \== -127 then do
  say 'failed in test 12 '
  rc = 8 
end




/* These from Mark Hessling. */

if c2d( 'ff80'x, 1) \== '-128' then do
  say 'failed in test 14 '
  rc = 8 
end

/* ASCII 

if c2d( 'foo' ) \== "6713199" then do
  say 'failed in test 15 '
  rc = 8 
end


if c2d( 'bar' ) \== "6447474" then do
  say 'failed in test 16 '
  rc = 8 
end

*/

if c2d( '' ) \== "0" then do
  say 'failed in test 17 '
  rc = 8 
end

if c2d( '101'x ) \== "257" then do
  say 'failed in test 18 '
  rc = 8 
end

if c2d( 'ff'x ) \== "255" then do
  say 'failed in test 19 '
  rc = 8 
end

if c2d( 'ffff'x) \== "65535" then do
  say 'failed in test 20 '
  rc = 8 
end

if c2d( 'ffff'x, 2) \== "-1" then do
  say 'failed in test 21 '
  rc = 8 
end

if c2d( 'ffff'x, 1) \== "-1" then do
  say 'failed in test 22 '
  rc = 8 
end

if c2d( 'fffe'x, 2) \== "-2" then do
  say 'failed in test 23 '
  rc = 8 
end

if c2d( 'fffe'x, 1) \== "-2" then do
  say 'failed in test 24 '
  rc = 8 
end

if c2d( 'ffff'x, 3) \== "65535" then do
  say 'failed in test 25 '
  rc = 8 
end

if c2d( 'ff7f'x, 1) \== "127" then do
  say 'failed in test 26 '
  rc = 8 
end

if c2d( 'ff7f'x, 2) \== "-129" then do
  say 'failed in test 27 '
  rc = 8 
end

if c2d( 'ff7f'x, 3) \== "65407" then do
  say 'failed in test 28 '
  rc = 8 
end

if c2d( 'ff80'x, 1) \== "-128" then do
  say 'failed in test 29 '
  rc = 8 
end

if c2d( 'ff80'x, 2) \== "-128" then do
  say 'failed in test 30 '
  rc = 8 
end

if c2d( 'ff80'x, 3) \== "65408" then do
  say 'failed in test 31 '
  rc = 8 
end

if c2d( 'ff81'x, 1) \== "-127" then do
  say 'failed in test 32 '
  rc = 8 
end

if c2d( 'ff81'x, 2) \== "-127" then do
  say 'failed in test 33 '
  rc = 8 
end

if c2d( 'ff81'x, 3) \== "65409" then do
  say 'failed in test 34 '
  rc = 8 
end

if c2d( 'ffffffffff'x, 5) \== "-1" then do
  say 'failed in test 35 '
  rc = 8 
end

if c2d('0031'x,0) \== 0 then do
  say 'failed in test 36 '
  rc = 8 
end

say "C2D OK"

exit rc
