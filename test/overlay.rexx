say '----------------------------------------'
say 'File overlay.rexx'
/* These from TRL */

rc = 0

say "Look for OVERLAY OK"

if overlay('.','abcdef',3,2) \== 'ab. ef' then do
  say 'failed in test 1 '
  rc = 8 
end

if overlay(' ','abcdef',3) \== 'ab def' then do
  say 'failed in test 2 '
  rc = 8 
end

if overlay('.','abcdef',3,2) \== 'ab. ef' then do
  say 'failed in test 3 '
  rc = 8 
end

if overlay('qq','abcd') \== 'qqcd' then do
  say 'failed in test 4 '
  rc = 8 
end

if overlay('qq','abcd',4) \== 'abcqq' then do
  say 'failed in test 5 '
  rc = 8 
end

if overlay('123','abc',5,6,'+') \== 'abc+123+++' then do
  say 'failed in test 6 '
  rc = 8 
end

/* These from Mark Hessling. */

if overlay('foo', 'abcdefghi',3,4,'*') \== 'abfoo*ghi' then do
  say 'failed in test 7 '
  rc = 8 
end

if overlay('foo', 'abcdefghi',3,2,'*') \== 'abfoefghi' then do
  say 'failed in test 8 '
  rc = 8 
end

if overlay('foo', 'abcdefghi',3,4,) \== 'abfoo ghi' then do
  say 'failed in test 9 '
  rc = 8 
end

if overlay('foo', 'abcdefghi',3) \== 'abfoofghi' then do
  say 'failed in test 10 '
  rc = 8 
end

if overlay('foo', 'abcdefghi',,4,'*') \== 'foo*efghi' then do
  say 'failed in test 11 '
  rc = 8 
end

if overlay('foo', 'abcdefghi',9,4,'*') \== 'abcdefghfoo*' then do
  say 'failed in test 12 '
  rc = 8 
end

if overlay('foo', 'abcdefghi',10,4,'*') \== 'abcdefghifoo*' then do
  say 'failed in test 13 '
  rc = 8 
end

if overlay('foo', 'abcdefghi',11,4,'*') \== 'abcdefghi*foo*' then do
  say 'failed in test 14 '
  rc = 8 
end

if overlay('', 'abcdefghi',3) \== 'abcdefghi' then do
  say 'failed in test 15 '
  rc = 8 
end

if overlay('foo', '',3) \== '  foo' then do
  say 'failed in test 16 '
  rc = 8 
end

if overlay('', '',3,4,'*') \== '******' then do
  say 'failed in test 17 '
  rc = 8 
end

if overlay('', '') \== '' then do
  say 'failed in test 18 '
  rc = 8 
end

say "OVERLAY OK"

exit rc
