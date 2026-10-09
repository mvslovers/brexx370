/* REXX - LISTVOL in TSO (#386)                                      */
/* MVSTEST TSO                                                       */
/* LISTVOL called a routine SCANUCB that exists nowhere, so every    */
/* volume it found ended in error 43. A volume that is not mounted   */
/* has no device number in IRXVTOC's summary, so the fields moved    */
/* left by one and LISTVOL took the device type for the number.      */
say '----------------------------------------'
say 'File listvol.rexx'
err = 0
call listdsi "'SYS1.LINKLIB'"
vol = sysvolume
call check 'LISTVOL',         lv(vol), 0
call check 'VOLVOLUME',       volvolume, vol
call check 'VOLTRKS',         datatype(voltrks, 'W'), 1
call check 'not mounted',     lv('ZZZZZ9'), 12
say 'Done listvol.rexx'
exit err

lv:
signal on syntax name lvx
return listvol(arg(1))
lvx:
return 'error' rc

check:
parse arg what, got, want
if got == want then say left('LISTVOL',8) '-' left(what,16) '.. PASS'
else do
   say left('LISTVOL',8) '-' left(what,16) '.. *FAIL* got' got 'want' want
   err = err + 1
end
return
