/* REXX - OUTTRAP traps what commands write, not the exec's own SAY  */
/* MVSTEST TSO                                                       */
/* Under a TMP SAY and TRACE go through PUTLINE. OUTTRAP STACKs its  */
/* DD only around ADDRESS TSO / ADDRESS COMMAND, so the exec's own   */
/* SAY and TRACE stay in the output, while a command's output, an    */
/* exec run as a command included, is trapped (z/OS TSO/E REXX       */
/* Reference, "OUTTRAP versus MSG function").                        */
say '----------------------------------------'
say 'File outtrap.rexx'
err = 0

call outtrap 'L.'
say 'OUTTRAP-OWN-SAY'
trace r
x = 1
trace o
address tso 'TIME'
call outtrap 'OFF'
call check 'own SAY and TRACE not trapped, TIME is', l.0 = 1, 'L.0' l.0
call check 'trapped line is the TIME message',,
     left(l.1,9) = 'IKJ56650I', 'L.1' l.1

cmd = "BREXX 'BREXX."||VER||".TESTS(OUTTRPB)'"
call outtrap 'A.'
address tso cmd
call outtrap 'OFF'
call check 'SAY of an exec run as a command is trapped',,
     a.0 >= 1 & strip(a.1) = 'OUTTRPB-SAY', 'A.0' a.0 'A.1' a.1
call check 'TRACE of that exec is trapped', a.0 = 3, 'A.0' a.0

call outtrap 'C.'
address tso 'TIME'
address tso 'TIME'
call outtrap 'OFF'
call check 'CONCAT keeps both commands', c.0 = 2, 'C.0' c.0

call outtrap 'N.',,'NOCONCAT'
address tso 'TIME'
address tso 'TIME'
call outtrap 'OFF'
call check 'NOCONCAT keeps the last command', n.0 = 1, 'N.0' n.0

/* options do not carry over: CONCAT again after a NOCONCAT */
call outtrap 'D.'
address tso 'TIME'
address tso 'TIME'
call outtrap 'OFF'
call check 'CONCAT is the default again', d.0 = 2, 'D.0' d.0

/* max given as a string, with CONCAT: the limit stops the second */
call outtrap 'M.', '1'
address tso 'TIME'
address tso 'TIME'
call outtrap 'OFF'
call check 'max 1 line', m.0 = 1, 'M.0' m.0

/* skip amount: the first TIME line is left out */
call outtrap 'S.', , 'CONCAT', 1
address tso 'TIME'
address tso 'TIME'
call outtrap 'OFF'
call check 'skip 1 line', s.0 = 1, 'S.0' s.0

say 'Done outtrap.rexx'
exit err

check:
parse arg what, ok, detail
if ok then say left('OUTTRAP',8) '-' what '.. PASS'
else do
  say left('OUTTRAP',8) '-' what '.. *FAIL*' detail
  err = 1
end
return
