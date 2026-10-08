say '----------------------------------------'
say 'File vlist.rexx'
/* VLIST.0 counted plain variables only: the elements of a stem, which */
/* BinVarDumpV() lists, were left out (#386). The docs' example shows  */
/* VLIST.0 = 2 for ADDRESS.MIG with two elements.                      */
err = 0
address.pej.city = 'Munich'
address.mig.city = 'Berlin'
address.pej.pub  = 'Hofbrauhaus'
address.mig.pub  = 'Steakhaus'
address = 'set'
l = vlist('ADDRESS.MIG')
call check 'ADDRESS.MIG count', vlist.0, 2
call check 'ADDRESS.MIG lines', words(translate(l, ' ', '0a15'x)), 2
l = vlist('ADDRESS.*.CITY')
call check '*.CITY count',      vlist.0, 2
l = vlist('ADDRESS')
call check 'ADDRESS count',     vlist.0, 5
say 'Done vlist.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('VLIST',8) '-' left(what,18) '.. PASS'
else do
   say left('VLIST',8) '-' left(what,18) '.. *FAIL* got' got 'want' want
   err = err + 1
end
return
