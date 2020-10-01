say '----------------------------------------'
say 'File x2d.rexx'
/* X2D */

rc = 0

say "Look for X2D OK"

/*
From: The REXX Language
      A Practical Approach to Programming
      Second Edition
      MICHAEL COWLISHAW
      1990
*/

if x2d('0E') \== 14 then do
  say 'failed in test 1 '
  rc = 8 
end

if x2d('81') \== 129 then do
  say 'failed in test 2 '
  rc = 8 
end

if x2d('F81') \== 3969 then do
  say 'failed in test 3 '
  rc = 8 
end

if x2d('FF81') \== 65409 then do
  say 'failed in test 4 '
  rc = 8 
end

/* if x2d('c6 f0'x) \== 240 then say 'failed in test EBCDIC version */

if x2d('F0') \== 240 then do
  say 'failed in test 6 '
  rc = 8 
end

if x2d('81',2) \== -127 then do
  say 'failed in test 7 '
  rc = 8 
end

if x2d('81',4) \== 129 then do
  say 'failed in test 8 '
  rc = 8 
end

if x2d('F081',4) \== -3967 then do
  say 'failed in test 9 '
  rc = 8 
end

if x2d('F081',3) \== 129 then do
  say 'failed in test 10 '
  rc = 8 
end

if x2d('F081',2) \== -127 then do
  say 'failed in test 11 '
  rc = 8 
end

if x2d('F081',1) \== 1 then do
  say 'failed in test 12 '
  rc = 8 
end

/* if x2d('0031',0) \== 0 then say 'failed in test 13 '*/

/* These from Mark Hessling. */

if x2d( 'ff80', 2) \== "-128" then do
  say 'failed in test 14 '
  rc = 8 
end

if x2d( 'ff80', 1) \== "0" then do
  say 'failed in test 15 '
  rc = 8 
end

if x2d( 'ff 80', 1) \== "0" then do
  say 'failed in test 16 '
  rc = 8 
end

if x2d( '' ) \== "0" then do
  say 'failed in test 17 '
  rc = 8 
end

if x2d( '101' ) \== "257" then do
  say 'failed in test 18 '
  rc = 8 
end

if x2d( 'ff' ) \== "255" then do
  say 'failed in test 19 '
  rc = 8 
end

if x2d( 'ffff') \== "65535" then do
  say 'failed in test 20 '
  rc = 8 
end

if x2d( 'ffff', 2) \== "-1" then do
  say 'failed in test 21 '
  rc = 8 
end

if x2d( 'ffff', 1) \== "-1" then do
  say 'failed in test 22 '
  rc = 8 
end

if x2d( 'fffe', 2) \== "-2" then do
  say 'failed in test 23 '
  rc = 8 
end

if x2d( 'fffe', 1) \== "-2" then do
  say 'failed in test 24 '
  rc = 8 
end

if x2d( 'ffff', 4) \== "-1" then do
  say 'failed in test 25 '
  rc = 8 
end

if x2d( 'ffff', 2) \== "-1" then do
  say 'failed in test 26 '
  rc = 8 
end

if x2d( 'fffe', 4) \== "-2" then do
  say 'failed in test 27 '
  rc = 8 
end

if x2d( 'fffe', 2) \== "-2" then do
  say 'failed in test 28 '
  rc = 8 
end

if x2d( 'ffff', 3) \== "-1" then do
  say 'failed in test 29 '
  rc = 8 
end

if x2d( '0fff') \== "4095" then do
  say 'failed in test 30 '
  rc = 8 
end

if x2d( '0fff', 4) \== "4095" then do
  say 'failed in test 31 '
  rc = 8 
end

if x2d( '0fff', 3) \== "-1" then do
  say 'failed in test 32 '
  rc = 8 
end

if x2d( '07ff') \== "2047" then do
  say 'failed in test 33 '
  rc = 8 
end

if x2d( '07ff', 4) \== "2047" then do
  say 'failed in test 34 '
  rc = 8 
end

if x2d( '07ff', 3) \== "2047" then do
  say 'failed in test 35 '
  rc = 8 
end

if x2d( 'ff7f', 1) \== "-1" then do
  say 'failed in test 36 '
  rc = 8 
end

if x2d( 'ff7f', 2) \== "127" then do
  say 'failed in test 37 '
  rc = 8 
end

if x2d( 'ff7f', 3) \== "-129" then do
  say 'failed in test 38 '
  rc = 8 
end

if x2d( 'ff7f', 4) \== "-129" then do
  say 'failed in test 39 '
  rc = 8 
end

if x2d( 'ff7f', 5) \== "65407" then do
  say 'failed in test 40 '
  rc = 8 
end

if x2d( 'ff80', 1) \== "0" then do
  say 'failed in test 41 '
  rc = 8 
end

if x2d( 'ff80', 2) \== "-128" then do
  say 'failed in test 42 '
  rc = 8 
end

if x2d( 'ff80', 3) \== "-128" then do
  say 'failed in test 43 '
  rc = 8 
end

if x2d( 'ff80', 4) \== "-128" then do
  say 'failed in test 44 '
  rc = 8 
end

if x2d( 'ff80', 5) \== "65408" then do
  say 'failed in test 45 '
  rc = 8 
end

if x2d( 'ff81', 1) \== "1" then do
  say 'failed in test 46 '
  rc = 8 
end

if x2d( 'ff81', 2) \== "-127" then do
  say 'failed in test 47 '
  rc = 8 
end

if x2d( 'ff81', 3) \== "-127" then do
  say 'failed in test 48 '
  rc = 8 
end

if x2d( 'ff81', 4) \== "-127" then do
  say 'failed in test 49 '
  rc = 8 
end

if x2d( 'ff81', 5) \== "65409" then do
  say 'failed in test 50 '
  rc = 8 
end

if x2d( 'ffffffffffff', 12) \== "-1" then do
  say 'failed in test 51 '
  rc = 8 
end

/* These from SCXBIFA4 */



if X2D((1&1|0=22*33)) \== '1' then do
  say 'failed in test 53 '
  rc = 8 
end

if X2D(ABS((1&1|0=22*33))) \== '1' then do
  say 'failed in test 56 '
  rc = 8 
end


if X2D(ABS(RIGHT(LEFT(REVERSE(321),2),REVERSE(LEFT(123,ABS(-1)))))),
\== '2' then do
  say 'failed in test 59 '
  rc = 8 
end


if X2D(RIGHT(LEFT(REVERSE(321),2),REVERSE(LEFT(123,ABS(-1))))) \== '2' then do
  say 'failed in test 61 '
  rc = 8 
end

/* These from SCBx2d1 */

/* if X2D('') \== '0' then say 'failed in test 62 ' brexx fails*/

if x2d(''X) \== '0' then do
  say 'failed in test 63 '
  rc = 8 
end

if X2D('a') \== '10' then do
  say 'failed in test 64 '
  rc = 8 
end

if X2D('0f') \== '15' then do
  say 'failed in test 65 '
  rc = 8 
end

if x2D('80') \== '128' then do
  say 'failed in test 66 '
  rc = 8 
end

if x2d('765') \== '1893' then do
  say 'failed in test 67 '
  rc = 8 
end

Numeric Digits 1000

if x2D("eeeeeeeeeeeeeeeeeeeeeeeee") \==,
'1183140560213014108063589658350' then do
  say 'failed in test 68 '
  rc = 8
end

Numeric Digits

if x2d(01234) \== '4660' then do
  say 'failed in test 69 '
  rc = 8 
end

if x2d(1E2) \== '482' then do
  say 'failed in test 70 '
  rc = 8 
end

Signal Off Novalue

if x2d(baba) \== '47802' then do
  say 'failed in test 73 '
  rc = 8 
end

if X2D('',0) \== '0' then do
  say 'failed in test 75 '
  rc = 8 
end

if X2D('',12) \== '0' then do
  say 'failed in test 76 '
  rc = 8 
end

if X2D('abc',0) \== '0' then do
  say 'failed in test 77 '
  rc = 8 
end

if X2D('abc',1) \== '-4' then do
  say 'failed in test 78 '
  rc = 8 
end

if X2D('abc',3) \== '-1348' then do
  say 'failed in test 79 '
  rc = 8 
end

if X2D('abc',5) \== '2748' then do
  say 'failed in test 80 '
  rc = 8 
end

if X2D('abc',12345) \== '2748' then do
  say 'failed in test 81 '
  rc = 8 
end

if x2d(1+3,1+3) \== '4' then do
  say 'failed in test 82 '
  rc = 8 
end

if x2D(256+12,10+2) \== '616' then do
  say 'failed in test 83 '
  rc = 8 
end

if x2d('12',987654321) \== '18' then do
  say 'failed in test 84 '
  rc = 8 
end

if d2x(X2D('12345')) \== '12345' then do
  say 'failed in test 85 '
  rc = 8 
end

/* known to fail */
if X2D((00000000000000001+1-0.000000)) \== '2' then do
  say 'failed in test 52 '
  rc = 8 
end

if X2D((99/3+10*126-(33||2)//5-1099)) \== '402' then do
  say 'failed in test 54 '
  rc = 8 
end

if X2D(ABS((99/3+10*126-(33||2)//5-1099))) \== '402' then do
  say 'failed in test 55 '
  rc = 8 
end

if X2D(COPIES(0,249)||1) \== '1' then do
  say 'failed in test 60 '
  rc = 8 
end

if X2D(ABS((00000000000000001+1-0.000000))) \== '2' then do
  say 'failed in test 57 '
  rc = 8 
end

if X2D(ABS(COPIES(0,249)||1)) \== '1' then do
  say 'failed in test 58 '
  rc = 8 
end
/* exponential representations will currently not work in x2d
if x2d(+1E+2) \== '256' then do
  say 'failed in test 71 '
  rc = 8 
end

if x2d(+.1E2) \== '16' then do
  say 'failed in test 72 '
  rc = 8 
end

if X2D(1 + 1E+2 ) \== '257' then do
  say 'failed in test 74 '
  rc = 8 
end
*/

if rc=0 then say "X2D OK"
   else say "X2D test failed"
exit rc
