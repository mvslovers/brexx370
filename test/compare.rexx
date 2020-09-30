say '----------------------------------------'
say 'File compare.rexx'
/* COMPARE */

rc = 0

say "Look for COMPARE OK"

/* These from the Rexx book. */

if compare('abc','abc') \= 0 then do
  say 'failed in test 1 '
  rc = 8 
end

if compare('abc','ak') \= 2 then do
  say 'failed in test 2 '
  rc = 8 
end

if compare('ab ','ab') \= 0 then do
  say 'failed in test 3 '
  rc = 8 
end

if compare('ab ','ab',' ') \= 0 then do
  say 'failed in test 4 '
  rc = 8 
end

if compare('ab ','ab','x') \= 3 then do
  say 'failed in test 5 '
  rc = 8 
end

if compare('ab-- ','ab','-') \= 5 then do
  say 'failed in test 6 '
  rc = 8 
end

/* These from Mark Hessling. */

say "COMPARE OK"

if compare("foo", "bar") \== 1 then do
  say 'failed in test 7 '
  rc = 8 
end

if compare("foo", "foo") \== 0 then do
  say 'failed in test 8 '
  rc = 8 
end

if compare(" ", "" ) \== 0 then do
  say 'failed in test 9 '
  rc = 8 
end

if compare("foo", "f", "o") \== 0 then do
  say 'failed in test 10 '
  rc = 8 
end

if compare("foobar", "foobag") \== 6 then do
  say 'failed in test 11 '
  rc = 8 
end

exit rc
