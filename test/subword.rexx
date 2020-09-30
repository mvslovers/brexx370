say '----------------------------------------'
say 'File subword.rexx'
/* SUBWORD */

rc = 0

say "Look for SUBWORD OK"

/* These from the Rexx book. */

if subword('Now is the time',2,2) \== 'is the' then do
  say 'failed in test 1 '
  rc = 8 
end

if subword('Now is the time',3) \== 'the time' then do
  say 'failed in test 2 '
  rc = 8 
end

if subword('Now is the time',5) \== '' then do
  say 'failed in test 3 '
  rc = 8 
end

/* These from Mark Hessling. */

if subword(" to be or not to be ",5) \== "to be" then do
  say 'failed in test 4 '
  rc = 8 
end

if subword(" to be or not to be ",6) \== "be" then do
  say 'failed in test 5 '
  rc = 8 
end

if subword(" to be or not to be ",7) \== "" then do
  say 'failed in test 6 '
  rc = 8 
end

if subword(" to be or not to be ",8,7) \== "" then do
  say 'failed in test 7 '
  rc = 8 
end

if subword(" to be or not to be ",3,2) \== "or not" then do
  say 'failed in test 8 '
  rc = 8 
end

if subword(" to be or not to be ",1,2) \== "to be" then do
  say 'failed in test 9 '
  rc = 8 
end

if subword(" to be or not to be ",4,2) \== "not to" then do
  say 'failed in test 10 '
  rc = 8 
end

if subword("abc de f", 3) \== 'f' then do
  say 'failed in test 11 '
  rc = 8 
end

say "SUBWORD OK"

exit rc
