# Interactive Debugging

You can enter the interactive debuging either by executing a TRACE
instruction with a prefix ‘?’ or when calling REXX from command line
issuing as a first argument the trace option:

rexx ‘?A’ ‘HLQ.DATASET(MEMBER)’

In interactive debug, interpreter pauses before the execution of the
instructions that are to be traced and prompts for input. You may do one
of following things:

- Enter a null line to continue execution.
- Enter a list of REXX instructions, which are interpreted immediately
  (DO-END instructions must be complete, etc.).

During the execution of the string, no tracing takes place, except that
non-zero return codes from host commands are displayed. Execution of a
TRACE instruction with the “?” prefix turns off interactive debug mode.
Other TRACE instructions affect the tracing that occurs when normal
execution continues.
