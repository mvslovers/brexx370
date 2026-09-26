/* REXX - ADDRESS LINK/LINKMVS/LINKPGM (issue #129)                    */
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
