say '----------------------------------------'
say 'File wordpos.rexx'
/* WORDPOS */

rc = 0

say "Look for WORDPOS OK"

/* These from the Rexx book. */

if wordpos('the','Now is the time') \= 3 then do
  say 'failed in test 1 '
  rc = 8 
end

if wordpos('The','Now is the time') \= 0 then do
  say 'failed in test 2 '
  rc = 8 
end

if wordpos('is the','Now is the time') \= 2 then do
  say 'failed in test 3 '
  rc = 8 
end

if wordpos('is the','Now is the time') \= 2 then do
  say 'failed in test 4 '
  rc = 8 
end

if wordpos('be','To be or not to be') \= 2 then do
  say 'failed in test 5 '
  rc = 8 
end

if wordpos('be','To be or not to be',3) \= 6 then do
  say 'failed in test 6 '
  rc = 8 
end

/* These from Mark Hessling. */

if wordpos('This','This is a small test') \== 1 then do
  say 'failed in test 7 '
  rc = 8 
end

if wordpos('test','This is a small test') \== 5 then do
  say 'failed in test 8 '
  rc = 8 
end

if wordpos('foo','This is a small test') \== 0 then do
  say 'failed in test 9 '
  rc = 8 
end

if wordpos(' This ','This is a small test') \== 1 then do
  say 'failed in test 10 '
  rc = 8 
end

if wordpos('This',' This is a small test') \== 1 then do
  say 'failed in test 11 '
  rc = 8 
end

if wordpos('This','This is a small test') \== 1 then do
  say 'failed in test 12 '
  rc = 8 
end

if wordpos('This','this is a small This') \== 5 then do
  say 'failed in test 13 '
  rc = 8 
end

if wordpos('This','This is a small This') \== 1 then do
  say 'failed in test 14 '
  rc = 8 
end

if wordpos('This','This is a small This', 2) \== 5 then do
  say 'failed in test 15 '
  rc = 8 
end

if wordpos('is a ','This is a small test') \== 2 then do
  say 'failed in test 16 '
  rc = 8 
end

if wordpos('is a ','This is a small test') \== 2 then do
  say 'failed in test 17 '
  rc = 8 
end

if wordpos(' is a ','This is a small test') \== 2 then do
  say 'failed in test 18 '
  rc = 8 
end

if wordpos('is a ','This is a small test', 2) \== 2 then do
  say 'failed in test 19 '
  rc = 8 
end

if wordpos('is a ','This is a small test',3) \== 0 then do
  say 'failed in test 20 '
  rc = 8 
end

if wordpos('is a ','This is a small test',4) \== 0 then do
  say 'failed in test 21 '
  rc = 8 
end

if wordpos('test ','This is a small test') \== 5 then do
  say 'failed in test 22 '
  rc = 8 
end

if wordpos('test ','This is a small test',5) \== 5 then do
  say 'failed in test 23 '
  rc = 8 
end

if wordpos('test ','This is a small test',6) \== 0 then do
  say 'failed in test 24 '
  rc = 8 
end

if wordpos('test ','This is a small test ') \== 5 then do
  say 'failed in test 25 '
  rc = 8 
end

if wordpos(' test','This is a small test ',6) \== 0 then do
  say 'failed in test 26 '
  rc = 8 
end

if wordpos('test ','This is a small test ',5) \== 5 then do
  say 'failed in test 27 '
  rc = 8 
end

if wordpos(' ','This is a small test') \== 0 then do
  say 'failed in test 28 '
  rc = 8 
end

if wordpos(' ','This is a small test',3) \== 0 then do
  say 'failed in test 29 '
  rc = 8 
end

if wordpos('','This is a small test',4) \== 0 then do
  say 'failed in test 30 '
  rc = 8 
end

if wordpos('test ','') \== 0 then do
  say 'failed in test 31 '
  rc = 8 
end

if wordpos('','') \== 0 then do
  say 'failed in test 32 '
  rc = 8 
end

if wordpos('',' ') \== 0 then do
  say 'failed in test 33 '
  rc = 8 
end

if wordpos(' ','') \== 0 then do
  say 'failed in test 34 '
  rc = 8 
end

if wordpos(' ','', 3) \== 0 then do
  say 'failed in test 35 '
  rc = 8 
end

if wordpos(' a ','') \== 0 then do
  say 'failed in test 36 '
  rc = 8 
end

if wordpos(' a ','a') \== 1 then do
  say 'failed in test 37 '
  rc = 8 
end

say "WORDPOS OK"

exit rc
