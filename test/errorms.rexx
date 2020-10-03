say '----------------------------------------'
say 'File errorms.rexx'
/* All error msgs to standard output. */
say "printing all errortext"
rc = 0
do j=0 to 90
  call SayIt(j)
end j
say 'Done errorms.rexx'
exit rc

Sayit:
text = errortext(arg(1))
if text \== '' then do
  say left(arg(1),6)'['text']'
end
return
