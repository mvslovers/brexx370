/* REXX - PARSE SOURCE names the exec that is running (#259)        */
/* An external exec reported the name of the first exec in the chain. */
say '----------------------------------------'
say 'File psname.rexx'
err = 0
VER = UPPER(VERSION())
if index(VER,'(') > 0 then do
  VER = DELSTR(VER,INDEX(VER,'('),1)
  VER = DELSTR(VER,INDEX(VER,')'),1)
end
/* PSNM2 calls PSNM3; both are written into the test PDS. Without
   PROCEDURE an external exec shares its caller's variables in BREXX,
   so each one uses names of its own */
F = allocate('psndd',"'BREXX."||VER||".TESTS(PSNM2)'")
if F >= 4 then do
  say 'PSNAME   - allocate PSNM2 failed' F '.. *FAIL*'
  exit 8
end
file = open('psndd','W')
call lineout file, '/* REXX */'
call lineout file, 'parse source . . n2a .'
call lineout file, 'call psnm3'
call lineout file, 'n2r = result'
call lineout file, 'parse source . . n2b .'
call lineout file, 'return n2a n2r n2b'
call close file
call free 'psndd'
F = allocate('psndd',"'BREXX."||VER||".TESTS(PSNM3)'")
if F >= 4 then do
  say 'PSNAME   - allocate PSNM3 failed' F '.. *FAIL*'
  exit 8
end
file = open('psndd','W')
call lineout file, '/* REXX */'
call lineout file, 'parse source . . n3a .'
call lineout file, "interpret 'parse source . . n3c .'"
call lineout file, 'return n3a n3c sub()'
call lineout file, 'sub: parse source . . n3b .'
call lineout file, 'return n3b'
call close file
call free 'psndd'

parse source . . me .
/* the first exec is named by the DD it came from in batch (RXRUN) */
say 'PSNAME   - own name:' me
call psnm2
call check 'call chain', result, 'PSNM2 PSNM3 PSNM3 PSNM3 PSNM2'
call check 'as function', psnm3(), 'PSNM3 PSNM3 PSNM3'
parse source . . me2 .
call check 'after return', me2, me
interpret 'parse source . . me3 .'
call check 'interpret', me3, me
say 'Done psname.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('PSNAME',8) '-' left(what,20) '.. PASS'
else do
   say left('PSNAME',8) '-' left(what,20) '.. *FAIL* got "'got'"',
       'want "'want'"'
   err = err + 1
end
return
