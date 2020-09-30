say '----------------------------------------'
say 'File delstr.rexx'
/* These from TRL */

rc = 0

say "Look for DELSTR OK"

if delstr('abcd',3) \== 'ab' then do
  say 'failed in test 1 '
  rc = 8 
end

if delstr('abcde',3,2) \== 'abe' then do
  say 'failed in test 2 '
  rc = 8 
end

if delstr('abcde',6) \== 'abcde' then do
  say 'failed in test 3 '
  rc = 8 
end

/* These from Mark Hessling. */

if delstr("Med lov skal land bygges", 6) \== "Med l" then do
  say 'failed in test 4 '
  rc = 8 
end

if delstr("Med lov skal land bygges", 6,10) \== "Med lnd bygges" then do
  say 'failed in test 5 '
  rc = 8 
end

if delstr("Med lov skal land bygges", 1) \== "" then do
  say 'failed in test 6 '
  rc = 8 
end

if delstr("Med lov skal", 30) \== "Med lov skal" then do
  say 'failed in test 7 '
  rc = 8 
end

if delstr("Med lov skal", 8 , 8) \== "Med lov" then do
  say 'failed in test 8 '
  rc = 8 
end

if delstr("Med lov skal", 12) \== "Med lov ska" then do
  say 'failed in test 9 '
  rc = 8 
end

if delstr("Med lov skal", 13) \== "Med lov skal" then do
  say 'failed in test 10 '
  rc = 8 
end

if delstr("Med lov skal", 14) \== "Med lov skal" then do
  say 'failed in test 11 '
  rc = 8 
end

if delstr("", 30) \== "" then do
  say 'failed in test 12 '
  rc = 8 
end

say "DELSTR OK"

exit rc
