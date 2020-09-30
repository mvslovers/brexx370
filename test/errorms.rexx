say '----------------------------------------'
say 'File errorms.rexx'
/* All error msgs to standard output. */
say "Look for ERRORTEXT OK"
say "printing all errortext"
rc = 0
do j=0 to 90
  call SayIt(j)
/*
  do k=1 to 50
    if k//10 \=0 then do
      rc = 8 
    end
    call Sayit(j'.'k)
  end k
*/
end j
say "ERRORTEXT OK"
exit

Sayit:
text = errortext(arg(1))
if text \== '' then do
  say left(arg(1),6)'['text']'
end
return
