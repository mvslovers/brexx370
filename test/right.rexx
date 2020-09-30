say '----------------------------------------'
say 'File right.rexx'
/* These from TRL */

rc = 0

say "Look for RIGHT OK"

if right('abc d',8) \== '   abc d' then do
  say 'failed in test 1 '
  rc = 8 
end

if right('abc def',5) \== 'c def' then do
  say 'failed in test 2 '
  rc = 8 
end

if right('12',5,'0') \== '00012' then do
  say 'failed in test 3 '
  rc = 8 
end

/* These from Mark Hessling. */

if right("",4) \== "    " then do
  say 'failed in test 4 '
  rc = 8 
end

if right("foobar",0) \== "" then do
  say 'failed in test 5 '
  rc = 8 
end

if right("foobar",3) \== "bar" then do
  say 'failed in test 6 '
  rc = 8 
end

if right("foobar",6) \== "foobar" then do
  say 'failed in test 7 '
  rc = 8 
end

if right("foobar",8) \== "  foobar" then do
  say 'failed in test 8 '
  rc = 8 
end

if right("foobar",8,'*') \== "**foobar" then do
  say 'failed in test 9 '
  rc = 8 
end

if right("foobar",4,'*') \== "obar" then do
  say 'failed in test 10 '
  rc = 8 
end

say "RIGHT OK"

exit rc
