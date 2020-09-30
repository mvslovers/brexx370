say '----------------------------------------'
say 'File form.rexx'
/* FORM */
say "Look for FORM OK"
/* These from the Rexx book. */
if form() \= 'SCIENTIFIC' then do
  exit 8 
end
/* These from Mark Hessling. */
say "FORM OK"
