#import "../bookmaster/bookmaster.typ": *

= Debugging <ug-debug>

#idx("TRACE")#idx("debugging")
The instruction #cmd("TRACE") shows what an exec does while it runs: the
clauses, the results of expressions, the commands and their return codes.
The _BREXX/370 Reference_ lists its options.

== Tracing from the Start <ug-debug-start>

To trace an exec from its first clause without changing it, give the trace
option as a word before its name (@ug-run-batch):

```
RX ?R MYEXEC
REXX '?A' 'HLQ.DATASET(MEMBER)'
```

== Interactive Debugging <ug-debug-interactive>

#idx("interactive debugging")
A trace option with the prefix #cmd("?") makes the trace interactive: the
interpreter stops before each clause it traces and waits for input. You
may then

- enter a null line, to run the clause and go on to the next;
- enter one or more REXX instructions, which run at once. A
  #cmd("DO")#sym.dots#cmd("END") must be complete on the line.

While such input runs, nothing is traced except non-zero return codes of
host commands. #cmd("TRACE ?") again, from the input or from the exec,
ends interactive debugging; any other #cmd("TRACE") instruction changes
what is traced when the exec goes on.

#note[*To be confirmed* for release 3.0: interactive debugging in a batch
job, where the input comes from #cmd("SYSTSIN") or #cmd("STDIN").]
