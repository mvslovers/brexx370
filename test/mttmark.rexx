say '----------------------------------------'
say 'File mttmark.rexx'
/* MTT and MTTX shared one "newest entry" marker, so an MTT() call     */
/* made a later MTTX(N) report nothing new; and both uppercased their  */
/* option argument in the caller's variable (get_modev, #386).         */
err = 0
marker = 'BRXMTTM' right(time('S'),5,'0') || right(random(0,99999),5,'0')
sa = screate(8192)
n = mttx('R', sa)
call check 'MTTX R',          n > 0, 1
call wto marker
found = 0
do try = 1 to 20 until found
   call wait 100
   m = mtt('R')
   do i = 1 to m
      if pos(marker, _line.i) > 0 then found = 1
   end
end
call check 'WTO in MTT',      found, 1
/* MTT() moved the marker; MTTX's own still points before the WTO */
nx = mttx('N', sa, , marker)
call check 'MTTX N after MTT', nx > n, 1
call check 'MTTX N marker',   pos(marker, sget(sa, n + 1)) > 0, 1
/* the option is not changed in place */
o = 'r'
x = mtt(o)
call check 'option kept',     o, 'r'
say 'Done mttmark.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('MTTMARK',8) '-' left(what,16) '.. PASS'
else do
   say left('MTTMARK',8) '-' left(what,16) '.. *FAIL* got' got 'want' want
   err = err + 1
end
return
