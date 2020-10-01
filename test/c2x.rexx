say '----------------------------------------'
say 'File c2x.rexx'
/* C2X */

rc = 0

say "Look for C2X OK"

/*
From: The REXX Language
      A Practical Approach to Programming
      Second Edition
      MICHAEL COWLISHAW
      1990
*/

/* EBCDIC */

if c2x('72s') \== 'F7F2A2' then do
  say 'failed in test 1 '
  rc = 8 
end

if c2x('0123'x) \== '0123' then do
  say 'failed in test 2 '
  rc = 8 
end

/* These from Mark Hessling. */

if c2x( 'foobar') \== '869696828199' then do
  say 'failed in test 3 '
  rc = 8 
end

if c2x( '' )\== '' then do
  say 'failed in test 4 '
  rc = 8 
end

if c2x( '101'x )\== '0101' then do
  say 'failed in test 5 '
  rc = 8 
end

if c2x( '0123456789abcdef'x )\== '0123456789ABCDEF' then do
  say 'failed in test 6 '
  rc = 8 
end

if c2x( 'ffff'x )\== 'FFFF' then do
  say 'failed in test 7 '
  rc = 8 
end

if c2x( 'ffffffff'x )\== 'FFFFFFFF' then do
  say 'failed in test 8 '
  rc = 8 
end

say "C2X OK"

exit rc
