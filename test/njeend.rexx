say '----------------------------------------'
say 'File njeend.rexx'
/* An exec that ends while the NJE38 subtask is attached (#328, #505):  */
/* no __NJEDEREGISTER, the step used to end in system abend A03. The    */
/* subtask is ended with the exec, and the job step is not left         */
/* authorized. The step RC is the verdict; a user without READ on       */
/* FACILITY SVC244 never gets as far as the subtask. Needs the NJE38    */
/* started task.                                                        */
me = userid()
signal on syntax name noNje
call __njeinit
signal off syntax

r = __njeregister(me)
if r = 0 then do
   say 'receive' __njereceive(300)
   say left('NJEEND',8) '- exit without __NJEDEREGISTER'
end
else say left('NJEEND',8) '- register returned' r '.. rest SKIPPED'
say 'Done njeend.rexx'
exit 0

noNje:
signal off syntax
say left('NJEEND',8) '- NJE38 is not active or NJERLY is missing' ,
    '.. SKIPPED (rest)'
say 'Done njeend.rexx'
exit 0
