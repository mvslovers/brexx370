say '----------------------------------------'
say 'File xrange.rexx'
/* XRANGE */

rc = 0

say "Look for XRANGE OK"

/* These from the Rexx book. */

if xrange('a','f') \== 'abcdef' then do
  say 'failed in test 1 '
  rc = 8 
end

if xrange('03'x,'07'x) \== '0304050607'x then do
  say 'failed in test 2 '
  rc = 8 
end

/* if xrange('04'x) \== '0001020304'x then do */
/* say 'failed in test */
/* end */

if xrange('FE'x,'02'x) \== 'FEFF000102'x then do
  say 'failed in test 4 '
  rc = 8 
end

/* These from Mark Hessling. */

/*if xrange('f','r') \== 'fghijklmnopqr' then do */
/* say 'failed in test */ /* fails ebcdic */

if xrange('7d'x,'83'x) \== '7d7e7f80818283'x then do
  say 'failed in test 6 '
  rc = 8 
end

if xrange('a','a') \== 'a' then do
  say 'failed in test 7 '
  rc = 8 
end

say "XRANGE OK"

exit rc
