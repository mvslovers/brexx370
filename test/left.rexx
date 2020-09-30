say '----------------------------------------'
say 'File left.rexx'
/* These from TRL */

rc = 0

say "Look for LEFT OK"

if left('abc d',8) \== 'abc d   ' then do
  say 'failed in test 1 '
  rc = 8 
end

if left('abc d',8,'.') \== 'abc d...' then do
  say 'failed in test 2 '
  rc = 8 
end

if left('abc  def',7) \== 'abc  de' then do
  say 'failed in test 3 '
  rc = 8 
end

/* These from Mark Hessling. */

if left("foobar",1) \== "f" then do
  say 'failed in test 4 '
  rc = 8 
end

if left("foobar",0) \== "" then do
  say 'failed in test 5 '
  rc = 8 
end

if left("foobar",6) \== "foobar" then do
  say 'failed in test 6 '
  rc = 8 
end

if left("foobar",8) \==      "foobar  " then do
  say 'failed in test 7 '
  rc = 8 
end

if left("foobar",8,'*') \== "foobar**" then do
  say 'failed in test 8 '
  rc = 8 
end

if left("foobar",1,'*') \== "f" then do
  say 'failed in test 9 '
  rc = 8 
end

say "LEFT OK"

exit rc
