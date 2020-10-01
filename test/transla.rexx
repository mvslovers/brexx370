say '----------------------------------------'
say 'File transla.rexx'
/* TRANSLATE */

rc = 0

say "Look for TRANSLATE OK"

/*
From: The REXX Language
      A Practical Approach to Programming
      Second Edition
      MICHAEL COWLISHAW
      1990
*/

if translate('abcdef') \== 'ABCDEF' then do
  say 'failed in test 1 '
  rc = 8 
end

if translate('abbc','&','b') \== 'a&&c' then do
  say 'failed in test 2 '
  rc = 8 
end

if translate('abcdef','12','ec') \== 'ab2d1f' then do
  say 'failed in test 3 '
  rc = 8 
end

if translate('abcdef','12','abcd','.') \== '12..ef' then do
  say 'failed in test 4 '
  rc = 8 
end

if translate('4123','abcd','1234') \== 'dabc' then do
  say 'failed in test 5 '
  rc = 8 
end

/* These from Mark Hessling. */

if translate("Foo Bar") \== "FOO BAR" then do
  say 'failed in test 6 '
  rc = 8 
end

if translate("Foo Bar",,"") \== "Foo Bar" then do
  say 'failed in test 7 '
  rc = 8 
end

if translate("Foo Bar","",) \== "       " then do
  say 'failed in test 8 '
  rc = 8 
end

if translate("Foo Bar","",,'*') \== "*******" then do
  say 'failed in test 9 '
  rc = 8 
end

/* ASCII
if translate("Foo Bar",xrange('01'x,'ff'x)) \==  "Gpp!Cbs" then do
  say 'failed in test 10 '
  rc = 8 
end
*/

if translate("","klasjdf","woieruw") \== "" then do
  say 'failed in test 11 '
  rc = 8 
end

if translate("foobar","abcdef","fedcba") \== "aooefr" then do
  say 'failed in test 12 '
  rc = 8 
end

say "TRANSLATE OK"

exit rc
