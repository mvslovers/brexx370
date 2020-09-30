say '----------------------------------------'
say 'File delword.rexx'
/* These from TRL */

rc = 0

say "Look for DELWORD OK"

if delword('Now is the time',2,2) \== 'Now time' then do
  say 'failed in test 1 '
  rc = 8 
end

if delword('Now is the time ',3) \== 'Now is ' then do
  say 'failed in test 2 '
  rc = 8 
end

if delword('Now time',5) \== 'Now time' then do
  say 'failed in test 3 '
  rc = 8 
end

/* These from Mark Hessling. */

if delword("Med lov skal land bygges", 3) \== "Med lov " then do
  say 'failed in test 4 '
  rc = 8 
end

if delword("Med lov skal land bygges", 1) \== "" then do
  say 'failed in test 5 '
  rc = 8 
end

if delword("Med lov skal land bygges", 1,1) \== "lov skal land bygges" then do
  say 'failed in test 6 '
  rc = 8 
end

if delword("Med lov skal land bygges", 2,3) \== "Med bygges" then do
  say 'failed in test 7 '
  rc = 8 
end

if delword("Med lov skal land bygges", 2,10) \== "Med " then do
  say 'failed in test 8 '
  rc = 8 
end

if delword("Med lov skal land bygges", 3,2) \== "Med lov bygges" then do
  say 'failed in test 9 '
  rc = 8 
end

if delword("Med lov skal land bygges", 3,2) \== "Med lov bygges" then do
  say 'failed in test 10 '
  rc = 8 
end

if delword("Med lov skal land bygges", 3,2) \== "Med lov bygges" then do
  say 'failed in test 11 '
  rc = 8 
end

if delword("Med lov skal land bygges", 3,0) \==,
 "Med lov skal land bygges" then do
  say 'failed in test 12 '
  rc = 8 
end

if delword("Med lov skal land bygges", 10) \==,
 "Med lov skal land bygges" then do
  say 'failed in test 13 '
  rc = 8 
end

if delword("Med lov skal land bygges", 9,9) \==,
"Med lov skal land bygges" then do
  say 'failed in test 14 '
  rc = 8 
end

if delword("Med lov skal land bygges", 1,0) \==,
"Med lov skal land bygges" then do
  say 'failed in test 15 '
  rc = 8 
end

if delword(" Med lov skal", 1,0) \== " Med lov skal" then do
  say 'failed in test 16 '
  rc = 8 
end

if delword(" Med lov skal ", 4) \== " Med lov skal " then do
  say 'failed in test 17 '
  rc = 8 
end

if delword("", 1) \== "" then do
  say 'failed in test 18 '
  rc = 8 
end

say "DELWORD OK"

exit rc
