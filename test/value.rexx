say '----------------------------------------'
say 'File value.rexx'
/* VALUE */

rc = 0

say "Look for VALUE OK"

/* These from the Rexx book. */

drop A3; A33=7; K=3; fred='K'; list.5='?'

if value('a'k) \== 'A3' then do
  say 'failed in test 1 '
  rc = 8 
end

if value('a'k||k) \== '7' then do
  say 'failed in test 2 '
  rc = 8 
end

if value('fred') \== 'K' then do
  say 'failed in test 3 '
  rc = 8 
end

if value(fred) \== '3' then do
  say 'failed in test 4 '
  rc = 8 
end

if value(fred,5) \== '3' then do
  say 'failed in test 5 '
  rc = 8 
end

if value(fred) \== '5' then do
  say 'failed in test 6 '
  rc = 8 
end

if value('LIST.'k) \== '?' then do
  say 'failed in test 7 '
  rc = 8 
end

/* These from Mark Hessling. */

x.a = 'asdf'

x.b = 'foo'

x.c = 'A'

a = 'B'

b = 'C'

c = 'A'

if value('a') \== 'B' then do
  say 'failed in test 8 '
  rc = 8 
end

if value(a) \== 'C' then do
  say 'failed in test 9 '
  rc = 8 
end

if value(c) \== 'B' then do
  say 'failed in test 10 '
  rc = 8 
end

if value('c') \== 'A' then do
  say 'failed in test 11 '
  rc = 8 
end

if value('x.A') \== 'foo' then do
  say 'failed in test 12 '
  rc = 8 
end

if value(x.B) \== 'B' then do
  say 'failed in test 13 '
  rc = 8 
end

if value('x.B') \== 'A' then do
  say 'failed in test 14 '
  rc = 8 
end

if value('x.'||a) \== 'A' then do
  say 'failed in test 15 '
  rc = 8 
end

if value(value(x.b)) \== 'C' then do
  say 'failed in test 16 '
  rc = 8 
end

xyzzy = 'foo'

if value('xyzzy') \== 'foo' then do
  say 'failed in test 17 '
  rc = 8 
end

if value('xyzzy','bar') \== 'foo' then do
  say 'failed in test 18 '
  rc = 8 
end

if value('xyzzy') \== 'bar' then do
  say 'failed in test 19 '
  rc = 8 
end

if value('xyzzy','bar') \== 'bar' then do
  say 'failed in test 20 '
  rc = 8 
end

if value('xyzzy') \== 'bar' then do
  say 'failed in test 21 '
  rc = 8 
end

if value('xyzzy','foo') \== 'bar' then do
  say 'failed in test 22 '
  rc = 8 
end

if value('xyzzy') \== 'foo' then do
  say 'failed in test 23 '
  rc = 8 
end

xyzzy = 'void'

if os = 'UNIX' Then
  envvar = '$xyzzy'
else
  envvar = '%xyzzy%'

/* System dependent

call value 'xyzzy', 'bar', 'SYSTEM'

if value('xyzzy', 'bar', 'SYSTEM') \== 'bar' then do
  say 'failed in test 24 '
  rc = 8 
end

if value('xyzzy',, 'SYSTEM') \== 'bar' then do
  say 'failed in test 25 '
  rc = 8 
end

if value('xyzzy', , 'SYSTEM') \== 'echo'(envvar) then do
  say 'failed in test 26 '
  rc = 8 
end

if value('xyzzy', 'foo', 'SYSTEM') \== 'bar' then do
  say 'failed in test 27 '
  rc = 8 
end

if value('xyzzy', 'bar', 'SYSTEM') \== 'foo' then do
  say 'failed in test 28 '
  rc = 8 
end

if value('xyzzy', , 'SYSTEM') \== 'echo'(envvar) then do
  say 'failed in test 29 '
  rc = 8 
end

if value('xyzzy', , 'SYSTEM') \== 'bar' then do
  say 'failed in test 30 '
  rc = 8 
end

if value('xyzzy', 'foo', 'SYSTEM') \== 'bar' then do
  say 'failed in test 31 '
  rc = 8 
end

if value('xyzzy', , 'SYSTEM') \== 'echo'(envvar) then do
  say 'failed in test 32 '
  rc = 8 
end

*/

say "VALUE OK"

exit rc
