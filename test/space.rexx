say '----------------------------------------'
say 'File space.rexx'
/* SPACE */

rc = 0

say "Look for SPACE OK"

/* These from the Rexx book. */

if space('abc def ') \== 'abc def' then do
  say 'failed in line 1 '
  rc = 8 
end

if space(' abc def',3) \== 'abc   def' then do
  say 'failed in line 2 '
  rc = 8 
end

if space('abc def ',1) \== 'abc def' then do
  say 'failed in line 3 '
  rc = 8 
end

if space('abc def ',0) \== 'abcdef' then do
  say 'failed in line 4 '
  rc = 8 
end

if space('abc def ',2,'+') \== 'abc++def' then do
  say 'failed in line 5 '
  rc = 8 
end

/* These from Mark Hessling. */

if space(" foo ") \== "foo" then do
  say 'failed in line 6 '
  rc = 8 
end

if space(" foo") \== "foo" then do
  say 'failed in line 7 '
  rc = 8 
end

if space("foo ") \== "foo" then do
  say 'failed in line 8 '
  rc = 8 
end

if space(" foo ") \== "foo" then do
  say 'failed in line 9 '
  rc = 8 
end

if space(" foo bar ") \== "foo bar" then do
  say 'failed in line 10 '
  rc = 8 
end

if space(" foo bar ") \== "foo bar" then do
  say 'failed in line 11 '
  rc = 8 
end

if space(" foo bar " , 2) \== "foo  bar" then do
  say 'failed in line 12 '
  rc = 8 
end

if space(" foo bar ",,"-") \== "foo-bar" then do
  say 'failed in line 13 '
  rc = 8 
end

if space(" foo bar ",2,"-") \== "foo--bar" then do
  say 'failed in line 14 '
  rc = 8 
end

if space(" f-- b-- ",2,"-") \== "f----b--" then do
  say 'failed in line 15 '
  rc = 8 
end

if space(" f o o b a r ",0) \== "foobar" then do
  say 'failed in line 16 '
  rc = 8 
end

say "SPACE OK"

exit rc
