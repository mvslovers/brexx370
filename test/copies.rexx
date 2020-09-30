say '----------------------------------------'
say 'File copies.rexx'
/* These from TRL */

rc = 0

say "Look for COPIES OK"

if copies('abc',3) \== 'abcabcabc' then do
  say 'failed in test 1 '
  rc = 8 
end

if copies('abc',0) \== '' then do
  say 'failed in test 2 '
  rc = 8 
end

/* These from Mark Hessling. */

if copies("foo",3) \== "foofoofoo" then do
  say 'failed in test 3 '
  rc = 8 
end

if copies("x", 10) \== "xxxxxxxxxx" then do
  say 'failed in test 4 '
  rc = 8 
end

if copies("", 50) \== "" then do
  say 'failed in test 5 '
  rc = 8 
end

if copies("", 0) \== "" then do
  say 'failed in test 6 '
  rc = 8 
end

if copies("foobar",0 ) \== "" then do
  say 'failed in test 7 '
  rc = 8 
end

say "COPIES OK"

exit rc
