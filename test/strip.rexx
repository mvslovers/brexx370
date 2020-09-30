say '----------------------------------------'
say 'File strip.rexx'
/* STRIP */

rc = 0

say "Look for STRIP OK"

/* These from the Rexx book. */

if strip(' ab c ') \== 'ab c' then do
  say 'failed in test 1 '
  rc = 8 
end

if strip(' ab c ','L') \== 'ab c ' then do
  say 'failed in test 2 '
  rc = 8 
end

if strip(' ab c ','t') \== ' ab c' then do
  say 'failed in test 3 '
  rc = 8 
end

if strip('12.7000',,0) \== '12.7' then do
  say 'failed in test 4 '
  rc = 8 
end

if strip('0012.7000',,0) \== '12.7' then do
  say 'failed in test 5 '
  rc = 8 
end

/* These from Mark Hessling. */

if strip(" foo bar ") \== "foo bar" then do
  say 'failed in test 6 '
  rc = 8 
end

if strip(" foo bar ",'L') \== "foo bar " then do
  say 'failed in test 7 '
  rc = 8 
end

if strip(" foo bar ",'T') \== " foo bar" then do
  say 'failed in test 8 '
  rc = 8 
end

if strip(" foo bar ",'B') \== "foo bar" then do
  say 'failed in test 9 '
  rc = 8 
end

if strip(" foo bar ",'B','*') \== " foo bar " then do
  say 'failed in test 10 '
  rc = 8 
end

if strip(" foo bar",,'r') \== " foo ba" then do
  say 'failed in test 11 '
  rc = 8 
end

say "STRIP OK"

exit rc
