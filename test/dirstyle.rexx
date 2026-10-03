say '----------------------------------------'
say 'File dirstyle.rexx'
/* DIR() set the JCC layer's global _style to "//DSN:" and set it     */
/* back only when it could open the data set (#299). __SWRITE, which  */
/* SWRITE calls with a DD name and which only inherits the style,     */
/* then opened the DD name as a data set name. OUTDD is a SYSOUT DD   */
/* of every mvstest.py step.                                          */
err = 0
VER = UPPER(VERSION())
if index(VER,'(') > 0 then do
  VER = DELSTR(VER,INDEX(VER,'('),1)
  VER = DELSTR(VER,INDEX(VER,')'),1)
end
s = screate(3)
call sset s, , 'DIRSTYLE line 1'
call sset s, , 'DIRSTYLE line 2'
call sset s, , 'DIRSTYLE line 3'
call check 'SWRITE before DIR', swrite(s, 'OUTDD'), 3
call dir "'BREXX."||VER||".TESTS'"
call check 'SWRITE after DIR', swrite(s, 'OUTDD'), 3
call check 'DIR of a missing PDS', dir("'BREXX.NO.SUCH.PDS'"), 8
call check 'SWRITE after that', swrite(s, 'OUTDD'), 3
call sfree s
say 'Done dirstyle.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('DIRSTYLE',8) '-' left(what,24) '.. PASS'
else do
   say left('DIRSTYLE',8) '-' left(what,24) '.. *FAIL*'
   say '   got ' got
   say '   want' want
   err = err + 1
end
return
