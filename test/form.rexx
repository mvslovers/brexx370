say '----------------------------------------'
say 'File form.rexx'
/* FORM */
say "Look for FORM OK"
/*
From: The REXX Language
      A Practical Approach to Programming
      Second Edition
      MICHAEL COWLISHAW
      1990
*/
if form() \= 'SCIENTIFIC' then do
  exit 8 
end
/* These from Mark Hessling. */
say "FORM OK"
