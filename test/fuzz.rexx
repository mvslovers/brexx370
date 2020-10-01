say '----------------------------------------'
say 'File fuzz.rexx'
/* FUZZ */
say "Look for FUZZ OK"
/*
From: The REXX Language
      A Practical Approach to Programming
      Second Edition
      MICHAEL COWLISHAW
      1990
*/
if fuzz() \= 0 then do
  exit 8 
end
/* These from Mark Hessling. */
say "FUZZ OK"


