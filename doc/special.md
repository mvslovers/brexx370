# Special Variables

There are three special variables:

## SIGL

holds the line number of the instruction that was last executed before
control of program was transferred to another place. This can be caused
by a SIGNAL instruction, a CALL instruction or a trapped error
condition.

## RC

is set to the errorlevel (return-code) after execution of every command (to host).

## RESULT

is set by a RETURN instruction in a CALLed procedure.
