/* REXX - ENVBLOCK+X'130' holds the input stack top of the exec (#602) */
/* MVSTEST TSO                                                         */
/* MVSTEST SYSTSIN TSTVPOOL CHKZERO                                    */
/* Contract field for IKJCT441: while an exec runs, the word at        */
/* ENVBLOCK+X'130' is the current top element of the input stack       */
/* (ECT -> ECTIOWA -> IOSRL, IOSTELM at +0); a nested exec puts its    */
/* own value there and the outer value is back when it ended, also    */
/* when it ended in an abend; X'134' to X'13B' are not touched.        */
/* The word of the outermost exec cannot be read after its end (the    */
/* ENVBLOCK is gone), so the restore is observed with nested execs.    */
/* The inner exec ends with RC 7 (8 after its abend). A failure sets   */
/* ECTENVBK to a foreign value (TSTVPOOL STEAL) so that the trailing   */
/* CHKZERO fails as well. Without TSO (no ECT) the word cannot be      */
/* reached from outside; the batch step prints PASS and ends.          */
err = 0
parse arg inner .
parse source . . dsn .
dsn = strip(dsn, 'B', "'")

if inner = 'INNER' | inner = 'INABT' then do
  address tso 'TSTVPOOL TOPADDR'
  top = rc
  address tso 'TSTVPOOL TOPWORD'
  say left('VARSTACK', 8) '-' inner 'exec: IOSTELM =' d2x(top) ,
      'word =' d2x(rc)
  address tso 'TSTVPOOL IOSTK'
  call check inner 'exec: word is the top element, RC' rc, rc = 0
  if inner = 'INABT' then do
    if err = 0 then address tso 'TSTVPOOL ABEND'
    exit 1
  end
  exit 7 + err
end

say '----------------------------------------'
say 'File varstack.rexx'

ascb = peeka(548)                      /* PSAAOLD                     */
asxb = peeka(ascb + 108)               /* ASCBASXB                    */
lwa  = peeka(asxb + 20)                /* ASXBLWA                     */
if lwa = 0 then do
  say left('VARSTACK', 8) '- batch without TSO .. PASS'
  say 'Done varstack.rexx'
  exit 0
end

address tso 'TSTVPOOL ENVADDR'
env = rc
address tso 'TSTVPOOL TOPADDR'
top = rc
address tso 'TSTVPOOL TOPWORD'
word = rc
say left('VARSTACK', 8) '- outer exec: ENVBLOCK' d2x(env) ,
    'IOSTELM' d2x(top) 'word' d2x(word)
call check 'the word is the input stack top', word = top
address tso 'TSTVPOOL IOSTK'
call check 'IOSTK: word = IOSTELM, X134-X13B are 0, RC' rc, rc = 0

call round 'nested exec', "BREXX '"dsn"' INNER", 7
call round 'nested exec with an abend', "BREXX '"dsn"' INABT", 8

/* the reserved words keep what someone else put there across a call */
drop b c d2 long2 bin lowset
a = 'old'
address tso 'TSTVPOOL RSVMARK'
call mod 'STORE'
address tso 'TSTVPOOL RSVCHK'
call check 'X134-X13B are untouched by a routine call, RC' rc, rc = 0
address tso 'TSTVPOOL TOPWORD'
call check 'the word is unchanged by the routine call', rc = word

if err then address tso 'TSTVPOOL STEAL'
say 'Done varstack.rexx'
exit err

round: procedure expose err env top word
parse arg what, cmd, want
address tso cmd
call check what 'ended with RC' want', RC' rc, rc = want
address tso 'TSTVPOOL ENVADDR'
call check what': ECTENVBK is the outer block again', rc = env
address tso 'TSTVPOOL TOPWORD'
call check what': the outer word is back', rc = word
address tso 'TSTVPOOL IOSTK'
call check what': IOSTK for the outer exec, RC' rc, rc = 0
return

mod:
parse arg m
address tso 'TSTVPOOL' m
call check m': the routine call, RC' rc, rc = 0
return

check:
parse arg ckwhat, ckok
if ckok then say left('VARSTACK', 8) '-' ckwhat '.. PASS'
else do
  say left('VARSTACK', 8) '-' ckwhat '.. *FAIL*'
  err = 1
end
return
