say '----------------------------------------'
say 'File x2c.rexx'
/* X2C */

rc = 0

say "Look for X2C OK"

/* These from the Rexx book. */

/* if x2c('F7F2 A2') \== '72s' then say 'failed in test EBCDIC */

/* if x2c('F7F2a2') \== '72s' then say 'failed in test EBCDIC */

if x2c('F') \== '0F'x then do
  say 'failed in test 3 '
  rc = 8 
end

/* These from Mark Hessling. */

if x2c("C18283") \== "Abc" then do
  say 'failed in test 4 '
  rc = 8 
end

if x2c("DeadBeef") \== "deadbeef"x then do
  say 'failed in test 5 '
  rc = 8 
end

if x2c("1 02 03") \== "010203"x then do
  say 'failed in test 6 '
  rc = 8 
end

if x2c("11 0222 3333 044444") \== "1102223333044444"x then do
  say 'failed in test 7 '
  rc = 8 
end

if x2c("") \== "" then do
  say 'failed in test 8 '
  rc = 8 
end

if x2c("2") \== "02"x then do
  say 'failed in test 9 '
  rc = 8 
end

if x2c("1 02 03") \== "010203"x then do
  say 'failed in test 10 '
  rc = 8 
end

say "X2C OK"



exit rc
