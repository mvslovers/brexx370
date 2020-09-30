say '----------------------------------------'
say 'File center.rexx'
/* These from TRL */

rc = 0

say "Look for CENTER OK"

if centre(abc,7) \== '  ABC  ' then do
  say 'failed in test 1 '
  rc = 8 
end

if center(abc,7) \== '  ABC  ' then do
  say 'failed in test 2 '
  rc = 8 
end

if center(abc,8,'-') \== '--ABC---' then do
  say 'failed in test 3 '
  rc = 8 
end

if center('The blue sky',8) \== 'e blue s' then do
  say 'failed in test 4 '
  rc = 8 
end

if center('The blue sky',7) \== 'e blue ' then do
  say 'failed in test 5 '
  rc = 8 
end

/* These from Mark Hessling. */

if center('****',8,'-') \=='--****--' then do
  say 'failed in test 6 '
  rc = 8 
end

if center('****',7,'-') \=='-****--' then do
  say 'failed in test 7 '
  rc = 8 
end

if center('*****',8,'-') \=='-*****--' then do
  say 'failed in test 8 '
  rc = 8 
end

if center('*****',7,'-') \=='-*****-' then do
  say 'failed in test 9 '
  rc = 8 
end

if center('12345678',4,'-') \=='3456' then do
  say 'failed in test 10 '
  rc = 8 
end

if center('12345678',5,'-') \=='23456' then do
  say 'failed in test 11 '
  rc = 8 
end

if center('1234567',4,'-') \=='2345' then do
  say 'failed in test 12 '
  rc = 8 
end

if center('1234567',5,'-') \=='23456' then do
  say 'failed in test 13 '
  rc = 8 
end

say "CENTER OK"

exit rc
