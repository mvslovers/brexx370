say '----------------------------------------'
say 'File max.rexx'
/* MAX */

rc = 0

say "Look for MAX OK"

/* These from the Rexx book. */

if max(12,6,7,9) \= 12 then do
  say 'failed in test 1 '
  rc = 8 
end

if max(17.3,19,17.03) \= 19 then do
  say 'failed in test 2 '
  rc = 8 
end

if max(-7,-3,-4.3) \= -3 then do
  say 'failed in test 3 '
  rc = 8 
end

/* These from Mark Hessling. */

if max( 10.1 ) \== "10.1" then do
  say 'failed in test 4 '
  rc = 8 
end

if max( -10.1, 3.8 ) \== "3.8" then do
  say 'failed in test 5 '
  rc = 8 
end

if max( 10.1, 10.2, 10.3 ) \== "10.3" then do
  say 'failed in test 6 '
  rc = 8 
end

if max( 10.3, 10.2, 10.3 ) \== "10.3" then do
  say 'failed in test 7 '
  rc = 8 
end

if max( 10.1, 10.2, 10.3 ) \== "10.3" then do
  say 'failed in test 8 '
  rc = 8 
end

if max( 10.1, 10.4, 10.3 ) \== "10.4" then do
  say 'failed in test 9 '
  rc = 8 
end

if max( 10.3, 10.2, 10.1 ) \== "10.3" then do
  say 'failed in test 10 '
  rc = 8 
end

if max( 1, 2, 4, 5 ) \== "5" then do
  say 'failed in test 11 '
  rc = 8 
end

if max( -0, 0 ) \== "0" then do
  say 'failed in test 12 '
  rc = 8 
end

if max( 1,2,3,4,5,6,7,8,7,6,5,4,3,2 ) \== "8" then do
  say 'failed in test 13 '
  rc = 8 
end

say "MAX OK"

exit rc
