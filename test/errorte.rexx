say '----------------------------------------'
say 'File errorte.rexx'
/* ERRORTEXT */
rc = 0
say "Look for ERRORTEXT OK"
/*
From: The REXX Language
      A Practical Approach to Programming
      Second Edition
      MICHAEL COWLISHAW
      1990
*/

if errortext(16) \== 'Label not found' then do
  say 'failed in test 1 '
  rc = 8 
end
if errortext(90) \== '' then do
  say 'failed in test 2 '
  rc = 8 
end
/* These from Mark Hessling. */
if errortext(10) \== "Unexpected or unmatched END" then do
  say 'failed in test 3 '
  rc = 8 
end

if errortext(40) \== "Incorrect call to routine" then do
  say 'failed in test 4 '
  rc = 8 
end

/* There is a 50 these days
if errortext(50) \== "" then do
  exit
  rc = 8 
end
*/

if errortext( 1) \== "" then do
  say 'failed in test 5 '
  rc = 8 
end

say "ERRORTEXT OK"

exit rc
