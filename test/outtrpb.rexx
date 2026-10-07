/* REXX - the command that test/outtrap.rexx runs under OUTTRAP      */
/* Its SAY and TRACE output belongs to a command, so the caller's    */
/* OUTTRAP traps it. Run on its own it only says hello.              */
say 'OUTTRPB-SAY'
trace r
y = 2
trace o
exit 0
