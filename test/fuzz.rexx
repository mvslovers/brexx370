say '----------------------------------------'
say 'File fuzz.rexx'
/* FUZZ */
say "Look for FUZZ OK"
/* These from the Rexx book. */
if fuzz() \= 0 then do
  exit 8 
end
/* These from Mark Hessling. */
say "FUZZ OK"


