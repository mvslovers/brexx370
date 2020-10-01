say '----------------------------------------'
say 'File abbrev.rexx'
/* ABBREV */

rc = 0

say "Look for ABBREV OK"

/*
From: The REXX Language
      A Practical Approach to Programming
      Second Edition
      MICHAEL COWLISHAW
      1990
*/

if \abbrev('Print','Pri') then do
  say 'failed in test 1 '
  rc = 8 
end

if abbrev('PRINT','Pri') then do
  say 'failed in test 2 '
  rc = 8 
end

if abbrev('PRINT','PRI',4) then do
  say 'failed in test 3 '
  rc = 8 
end

if abbrev('PRINT','PRY') then do
  say 'failed in test 4 '
  rc = 8 
end

if \abbrev('PRINT','') then do
  say 'failed in test 5 '
  rc = 8 
end

if abbrev('PRINT','',1) then do
  say 'failed in test 6 '
  rc = 8 
end

/* These from Mark Hessling. */

if \abbrev('information','info',4) then do
  say 'failed in test 7 '
  rc = 8 
end

if \abbrev('information','',0) then do
  say 'failed in test 8 '
  rc = 8 
end

if abbrev('information','Info',4) then do
  say 'failed in test 9 '
  rc = 8 
end

if abbrev('information','info',5) then do
  say 'failed in test 10 '
  rc = 8 
end

if abbrev('information','info ') then do
  say 'failed in test 11 '
  rc = 8 
end

if \abbrev('information','info',3) then do
  say 'failed in test 12 '
  rc = 8 
end

if abbrev('info','information',3) then do
  say 'failed in test 13 '
  rc = 8 
end

if abbrev('info','info',5) then do
  say 'failed in test 14 '
  rc = 8 
end

say "ABBREV OK"

exit rc
