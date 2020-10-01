say '----------------------------------------'
say 'File changes.rexx'
/* CHANGESTR */

rc = 0

say "Look for CHANGESTR OK"

if changestr('bc','abcabcabc','xy') \== 'axyaxyaxy' then do
  say 'failed in test 1 '
  rc = 8 
end

if changestr('bc','abcabcabc','') \== 'aaa' then do
  say 'failed in test 2 '
  rc = 8 
end

if changestr('','abcabcabc','xy') \== 'abcabcabc' then do
  say 'failed in test 3 '
  rc = 8 
end

/*
From: The REXX Language
      A Practical Approach to Programming
      Second Edition
      MICHAEL COWLISHAW
      1990
*/

/* These from Mark Hessling. */

if changestr('a','fred','c') \== 'fred' then do
  say 'failed in test 4 '
  rc = 8 
end

if changestr('','','x') \== '' then do
  say 'failed in test 5 '
  rc = 8 
end

if changestr('a','abcdef','x') \== 'xbcdef' then do
  say 'failed in test 6 '
  rc = 8 
end

if changestr('0','0','1') \== '1' then do
  say 'failed in test 7 '
  rc = 8 
end

if changestr('a','def','xyz') \== 'def' then do
  say 'failed in test 8 '
  rc = 8 
end

if changestr('a','','x') \== '' then do
  say 'failed in test 9 '
  rc = 8 
end

if changestr('','def','xyz') \== 'def' then do
  say 'failed in test 10 '
  rc = 8 
end

if changestr('abc','abcdef','xyz') \== 'xyzdef' then do
  say 'failed in test 11 '
  rc = 8 
end

if changestr('abcdefg','abcdef','xyz') \== 'abcdef' then do
  say 'failed in test 12 '
  rc = 8 
end

if changestr('abc','abcdefabccdabcd','z') \== 'zdefzcdzd' then do
  say 'failed in test 13 '
  rc = 8 
end

say "CHANGESTR OK"

exit rc
