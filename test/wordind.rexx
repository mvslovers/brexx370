say '----------------------------------------'
say 'File wordind.rexx'
/* WORDINDEX */

rc = 0

say "Look for WORDINDEX OK"

/* These from the Rexx book. */

if wordindex('Now is the time',3) \=8 then do
  say 'failed in test 1 '
  rc = 8 
end

if wordindex('Now is the time',6) \=0 then do
  say 'failed in test 2 '
  rc = 8 
end

/* These from Mark Hessling. */
  if wordindex('This is certainly a test',1) \==  '1'  then do
    rc = 8
    say 'failed in test          3 '
  end
  if wordindex('  This is certainly a test',1) \==  '3'  then do
    rc = 8
    say 'failed in test          4 '
  end
  if wordindex('This   is certainly a test',1) \==  '1'  then do
    rc = 8
    say 'failed in test          5 '
  end
  if wordindex('  This   is certainly a test',1) \==  '3'  then do
    rc = 8
    say 'failed in test          6 '
  end
  if wordindex('This is certainly a test',2) \==  '6'  then do
    rc = 8
    say 'failed in test          7 '
  end
  if wordindex('This   is certainly a test',2) \==  '8'  then do
    rc = 8
    say 'failed in test          8 '
  end
  if wordindex('This is   certainly a test',2) \==  '6'  then do
    rc = 8
    say 'failed in test          9 '
  end
  if wordindex('This   is   certainly a test',2) \==  '8'  then do
    rc = 8
    say 'failed in test         10 '
  end
  if wordindex('This is certainly a test',5) \==  '21'   then do
    rc = 8
    say 'failed in test         11 '
  end
  if wordindex('This is certainly a   test',5) \==  '23'  then do
    rc = 8
    say 'failed in test         12 '
  end
  if wordindex('This is certainly a test  ',5) \==  '21'  then do
    rc = 8
    say 'failed in test         13 '
  end
  if wordindex('This is certainly a test  ',6) \==  '0'   then do
    rc = 8
    say 'failed in test         14 '
  end
  if wordindex('This is certainly a test',6) \==  '0'     then do
    rc = 8
    say 'failed in test         15 '
  end
  if wordindex('This is certainly a test',7) \==  '0'     then do
    rc = 8
    say 'failed in test         16 '
  end
  if wordindex('This is certainly a test  ',7) \==  '0'    then do
    rc = 8
    say 'failed in test         17 '
  end
say "WORDINDEX OK"

exit rc
