say '----------------------------------------'
say 'File bitor.rexx'
/* BITOR */

rc = 0

say "Look for BITOR OK"

/*
From: The REXX Language
      A Practical Approach to Programming
      Second Edition
      MICHAEL COWLISHAW
      1990
*/

if bitor('15'x,'24'x) \= '35'x then do
  say 'failed in test 1 '
  rc = 8 
end

if bitor('15'x,'2456'x) \= '3556'x then do
  say 'failed in test 2 '
  rc = 8 
end

if bitor('15'x,'2456'x,'F0'x) \= '35F6'x then do
  say 'failed in test 3 '
  rc = 8 
end

if bitor('1111'x,,'4D'x) \= '5D5d'x then do
  say 'failed in test 4 '
  rc = 8 
end

/* These from Mark Hessling. */

if bitor( '123456'x, '3456'x ) \== '367656'x then do
  say 'failed in test 5 '
  rc = 8 
end

if bitor( '3456'x, '123456'x, '99'x ) \== '3676df'x then do
  say 'failed in test 6 '
  rc = 8 
end

if bitor( '123456'x,, '55'x) \== '577557'x then do
  say 'failed in test 7 '
  rc = 8 
end

if bitor( 'foobar' ) \== 'foobar' then do
  say 'failed in test 8 '
  rc = 8 
end

/* This one is ASCII dependent 

if bitor( 'FooBar' ,, '20'x) \== 'foobar' then do
  say 'failed in test 9 '
  rc = 8 
end
*/

say "BITOR OK"

exit rc
