say '----------------------------------------'
say 'File lastpos.rexx'
/* LASTPOS */

rc = 0

say "Look for LASTPOS OK"

/* These from the Rexx book. */

if lastpos(' ','abc def ghi') \= 8 then do
  say 'failed in test 1 '
  rc = 8 
end

if lastpos(' ','abcdefghi') \= 0 then do
  say 'failed in test 2 '
  rc = 8 
end

if lastpos(' ','abc def ghi',7) \= 4 then do
  say 'failed in test 3 '
  rc = 8 
end

/* These from Mark Hessling. */

if lastpos('b', 'abc abc') \== 6 then do
  say 'failed in test 4 '
  rc = 8 
end

if lastpos('b', 'abc abc',5) \== 2 then do
  say 'failed in test 5 '
  rc = 8 
end

if lastpos('b', 'abc abc',6) \== 6 then do
  say 'failed in test 6 '
  rc = 8 
end

if lastpos('b', 'abc abc',7) \== 6 then do
  say 'failed in test 7 '
  rc = 8 
end

if lastpos('x', 'abc abc') \== 0 then do
  say 'failed in test 8 '
  rc = 8 
end

if lastpos('b', 'abc abc',20) \== 6 then do
  say 'failed in test 9 '
  rc = 8 
end

if lastpos('b', '') \== 0 then do
  say 'failed in test 10 '
  rc = 8 
end

if lastpos('', 'c') \== 0 then do
  say 'failed in test 11 '
  rc = 8 
end

if lastpos('', '') \== 0 then do
  say 'failed in test 12 '
  rc = 8 
end

if lastpos('b', 'abc abc',20) \== 6 then do
  say 'failed in test 13 '
  rc = 8 
end

if lastpos('bc', 'abc abc') \== 6 then do
  say 'failed in test 14 '
  rc = 8 
end

if lastpos('bc ', 'abc abc',20) \== 2 then do
  say 'failed in test 15 '
  rc = 8 
end

if lastpos('abc', 'abc abc',6) \== 1 then do
  say 'failed in test 16 '
  rc = 8 
end

if lastpos('abc', 'abc abc') \== 5 then do
  say 'failed in test 17 '
  rc = 8 
end

if lastpos('abc', 'abc abc',7) \== 5 then do
  say 'failed in test 18 '
  rc = 8 
end

/* These from elsewhere. */

if pos('abc','abcdefabccdabcd',4) \== 7 then do
  say 'failed in test 19 '
  rc = 8 
end

say "LASTPOS OK"

exit rc
