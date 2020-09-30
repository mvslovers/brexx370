say '----------------------------------------'
say 'File min.rexx'
/* MIN */

rc = 0

say "Look for MIN OK"

/* These from the Rexx book. */

if min(12,6,7,9) \= 6 then do
  exit 8 
end

if min(17.3,19,17.03) \= 17.03 then do
  exit 8
end

if min(-7,-3,-4.3) \= -7 then do
  exit 8  
end

/* These from Mark Hessling. */

if min( 10.1 ) \== "10.1" then do
  exit 8
end

if min( -10.1, 3.8 ) \== "-10.1" then do
  exit 8  
end

if min( 10.1, 10.2, 10.3 ) \== "10.1" then do
  exit 8  
end

if min( 10.1, 10.2, 10.1 ) \== "10.1" then do
  exit 8  
end

if min( 10.1, 10.2, 10.3 ) \== "10.1" then do
  exit 8  
end

if min( 10.4, 10.1, 10.3 ) \== "10.1" then do
  exit 8  
end

if min( 10.3, 10.2, 10.1 ) \== "10.1" then do
  exit 8  
end

if min( 5, 2, 4, 1 ) \== "1" then do
  exit 8  
end

if min( -0, 0 ) \== "0" then do
  exit 8  
end

if min( 8,2,3,4,5,6,7,1,7,6,5,4,3,2 ) \== "1" then do
  exit 8  
end

say "MIN OK"

exit rc
