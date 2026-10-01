/* REXX - ADDRESS LINK/LINKMVS/LINKPGM (issues #129, #102)             */
/* The end-of-list bit must not reach FREE, a call without parameters  */
/* must not flag the word in front of the parameter list.              */
say '----------------------------------------'
say 'File addrlink.rexx'
err = 0
v1 = 'HELLO'
v2 = 'WORLD'
address LINKPGM 'IEFBR14 V1 V2'
call check 'LINKPGM two parms', rc
address LINKPGM 'IEFBR14 V1'
call check 'LINKPGM one parm', rc
address LINKPGM 'IEFBR14'
call check 'LINKPGM no parms', rc
address LINKMVS 'IEFBR14 V1 V2'
call check 'LINKMVS two parms', rc
address LINKMVS 'IEFBR14'
call check 'LINKMVS no parms', rc
address LINK 'IEFBR14 SOME ARGS'
call check 'LINK with args', rc
address LINK 'IEFBR14'
call check 'LINK no args', rc
/* the variables must survive the calls */
if v1 \= 'HELLO' | v2 \= 'WORLD' then do
   say 'ADDRLINK - variables changed .. *FAIL*' v1 v2
   err = err + 1
end
/* #102: the variables take what the program returns. TSTLINK is a     */
/* test module (test/tstlink.asm), in the TESTLIB of make test-mvs.    */
mode = 'LMVS'
a = 'ORIGINAL VALUE'
b = 'AB'
c = 'SOMETHING'
d = 'KEEP'
address LINKMVS 'TSTLINK MODE A B C D'
call check 'LINKMVS TSTLINK', rc
call same 'LINKMVS shorter',  a, 'CHANGED'
call same 'LINKMVS 500 bytes', b, copies('X', 500)
call same 'LINKMVS length 0', c, ''
call same 'LINKMVS length -1', d, 'KEEP'
call same 'LINKMVS parm 1',   mode, 'LMVS'
mode = 'LPGM'
e = 'ABCDEF'
address LINKPGM 'TSTLINK MODE E'
call check 'LINKPGM TSTLINK', rc
call same 'LINKPGM changed',  e, 'XYZDEF'
call same 'LINKPGM parm 1',   mode, 'LPGM'
say 'Done addrlink.rexx'
exit err

check:
parse arg what, lrc
if lrc = 0 then say left('ADDRLINK',8) '-' left(what,20) '.. PASS'
else do
   say left('ADDRLINK',8) '-' left(what,20) '.. *FAIL* rc='lrc
   err = err + 1
end
return

same:
parse arg what, got, want
if got == want then say left('ADDRLINK',8) '-' left(what,20) '.. PASS'
else do
   say left('ADDRLINK',8) '-' left(what,20) '.. *FAIL*',
       'length' length(got) 'value' left(got, 40)
   err = err + 1
end
return
