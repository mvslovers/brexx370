#import "../bookmaster/bookmaster.typ": *

= Instructions <lang-instr>

#idx("instruction")
A clause is an instruction when it begins with one of the keywords of this
chapter. A clause that is a symbol followed by #cmd("=") is an assignment,
one followed by a colon is a label, and any other clause is a command: its
value goes to the current host command environment (@ext-address).

```
fred = 'sunset'          /* assignment               */
a = 1 + 2 * 3
loop:                    /* label                    */
'LISTCAT'                /* command                  */
```

The instructions are listed in alphabetical order. #cmd("LOWER") is an
extension of BREXX/370; the others are those of TSO/E REXX.

== ADDRESS <lang-instr-address>

#idx("ADDRESS")
```
ADDRESS [environment [command]]
ADDRESS VALUE expression
ADDRESS (expression)
```
Selects the host command environment for commands. With a command, sends
that one command to the environment and keeps the current one; without,
makes the environment current for the commands that follow.
#cmd("ADDRESS") alone swaps the current and the previous environment.
#cmd("ADDRESS VALUE") and #cmd("ADDRESS (")#var("expression")#cmd(")") take
the name from an expression. An environment that does not exist answers
every command with return code -3. @ext-address lists the environments.

== ARG <lang-instr-arg>

#idx("ARG")
```
ARG [template]
```
Short for #cmd("PARSE UPPER ARG"): parses the argument strings of the exec
or routine, translated to uppercase, by the template (@lang-templates).

== CALL <lang-instr-call>

#idx("CALL")
```
CALL name [expression] [, [expression]] ...
CALL ON condition [NAME label]
CALL OFF condition
```
Calls a routine: a label of the exec, a built-in function, or an external
routine, found as the _BREXX/370 User's Guide_ describes in “Finding and
Calling Execs”. Up to 32 arguments may be given. The value the routine
returns is put into #cmd("RESULT")\; if it returns none, #cmd("RESULT")
is dropped. A routine called by a condition trap leaves #cmd("RESULT")
alone.

#cmd("CALL ON") enables a condition trap that is taken by a call; the
condition is #cmd("ERROR"), #cmd("FAILURE"), #cmd("HALT") or
#cmd("NOTREADY"). When the condition is raised, the routine at the label of
the condition's name, or at #var("label"), is called after the clause that
raised it has ended; #cmd("SIGL") holds that clause's line. After its
#cmd("RETURN") the exec goes on with the next clause; the routine does not
change #cmd("RESULT"). While it runs, the trap is delayed
(#cmd("CONDITION('S')") is #cmd("DELAY")) and a new #cmd("ERROR") or
#cmd("FAILURE") is ignored; afterwards the trap is on again -- unlike a trap
taken by #cmd("SIGNAL"), which is turned off.

```
CALL ON ERROR NAME cmd_error
ADDRESS LINKMVS 'IEBGENER'
SAY 'continued'
EXIT
cmd_error:
SAY 'RC' rc 'from' CONDITION('D') 'in line' SIGL
RETURN
```

== DO <lang-instr-do>

#idx("DO")#idx("loop")
```
DO [repetitor] [conditional]
  instructions
END [name]

repetitor:   name = expri [TO exprt] [BY exprb] [FOR exprf]
             | exprr | FOREVER
conditional: WHILE exprw | UNTIL expru
```
Groups instructions and may repeat them. Without a repetitor or a
conditional, #cmd("DO")#sym.dots#cmd("END") is a simple group, for
#cmd("THEN") and #cmd("ELSE"). #var("exprr") repeats the group that many
times; #cmd("FOREVER") until #cmd("LEAVE") or another transfer of control.
With a control variable, #var("name") goes from #var("expri") to
#var("exprt") in steps of #var("exprb"), at most #var("exprf") times; these
expressions are evaluated once, before the first pass. #cmd("WHILE") is
tested before each pass, #cmd("UNTIL") after it.

```
DO i = 1 TO 10 BY 3      /* 1 4 7 10 */
  SAY i
END
a = 1
DO FOR 3 WHILE a < 5     /* 1 2 3 */
  SAY a
  a = a + 1
END
```

== DROP <lang-instr-drop>

#idx("DROP")
```
DROP name | (names) ...
```
Returns variables to the state of never having been set. A stem drops all
variables that begin with it. A name in parentheses is a variable whose
value is a list of names to drop. A variable exposed by
#cmd("PROCEDURE EXPOSE") is dropped in the caller as well.

```
vars = 'j b stem.'
DROP a x.1 y.j     /* A, X.1 and Y.value-of-j */
DROP z.            /* every Z.tail            */
DROP (vars)        /* J, B and every STEM.tail */
```

== EXIT <lang-instr-exit>

#idx("EXIT")
```
EXIT [expression]
```
Ends the exec, from any routine. The value of the expression is the return
code of the exec, or, for an exec called as a function, its result.

== IF <lang-instr-if>

#idx("IF")
```
IF expression [;] THEN [;] instruction
[ELSE [;] instruction]
```
Runs the instruction after #cmd("THEN") if the expression is 1, the one
after #cmd("ELSE") if it is 0. Any other value is error 34.

== INTERPRET <lang-instr-interpret>

#idx("INTERPRET")
```
INTERPRET expression
```
Runs the value of the expression as REXX clauses, as if it stood in the
exec at this place.

== ITERATE and LEAVE <lang-instr-iterate>

#idx("ITERATE")#idx("LEAVE")
```
ITERATE [name]
LEAVE [name]
```
#cmd("ITERATE") goes on with the next pass of the innermost repetitive
#cmd("DO"), or of the one whose control variable is #var("name").
#cmd("LEAVE") ends that loop. Neither applies to a simple
#cmd("DO")#sym.dots#cmd("END").

== LOWER and UPPER <lang-instr-lower>

#idx("LOWER")#idx("UPPER")
```
LOWER name [name] ...
UPPER name [name] ...
```
Translate the values of the named variables to lowercase or uppercase.
#cmd("LOWER") is an extension of BREXX/370.

== NOP <lang-instr-nop>

#idx("NOP")
Does nothing; it stands where an instruction is required:
#cmd("IF a = 1 THEN NOP; ELSE SAY 'not one'").

== NUMERIC <lang-instr-numeric>

#idx("NUMERIC")
```
NUMERIC DIGITS [expression]
NUMERIC FORM SCIENTIFIC | ENGINEERING
NUMERIC FUZZ [expression]
```
Set the precision used to compare and show numbers, the form of
exponential notation, and the number of digits ignored in a numeric
comparison. Arithmetic itself is done in 32-bit integers or in double
precision and is not rounded to #cmd("DIGITS") (@lang-terms-expr). A
real number is shown with at most 15 significant digits, so a
#cmd("DIGITS") above 15 changes nothing; #cmd("DIGITS()") returns the value
set all the same.

== PARSE <lang-instr-parse>

#idx("PARSE")
```
PARSE [UPPER] source [template]

source: ARG | AUTHOR | EXTERNAL | LINEIN | NUMERIC | PULL | SOURCE
        | VALUE [expression] WITH | VAR name | VERSION
```
Parses a string by the template (@lang-templates); #cmd("UPPER")
translates it to uppercase first. The string is:

#deflist(width: 1.3in,
  [#cmd("ARG")], [the argument strings of the exec or routine.],
  [#cmd("AUTHOR")], [the author of BREXX, #cmd("Vasilis.Vlachoudis@cern.ch").
    An extension of BREXX/370.],
  [#cmd("EXTERNAL"), #cmd("LINEIN")], [a line read from the terminal, or
    from #cmd("SYSTSIN") or #cmd("STDIN") in batch.],
  [#cmd("NUMERIC")], [the current settings of #cmd("DIGITS"),
    #cmd("FUZZ") and #cmd("FORM"): #cmd("9 0 SCIENTIFIC") by default.],
  [#cmd("PULL")], [the next line of the stack, or, if it is empty, a line
    read as for #cmd("EXTERNAL").],
  [#cmd("SOURCE")], [four words: the system, always #cmd("MVS")\; the
    call type, #cmd("COMMAND")\; the name of the exec as it was given; and
    the name of the command that ran it, such as #cmd("BREXX") or
    #cmd("RX"). TSO/E REXX gives more words, and #cmd("TSO") as the
    system.],
  [#cmd("VALUE")], [the value of the expression.],
  [#cmd("VAR")], [the value of the variable #var("name").],
  [#cmd("VERSION")], [#cmd("BREXX/370"), the version, and the build
    date in parentheses.],
)

```
PARSE SOURCE src;   SAY src  /* MVS COMMAND 'IBMUSER.LIB(PSRC)' RX  */
PARSE VERSION ver;  SAY ver  /* BREXX/370 3.0.0 (Oct  8 2026)       */
```

== PROCEDURE <lang-instr-procedure>

#idx("PROCEDURE")
```
PROCEDURE [EXPOSE name | (names) ...]
```
The first instruction of a routine: gives it variables of its own. The
variables named after #cmd("EXPOSE") -- a stem stands for all its
variables, a name in parentheses for the list in its value -- remain those
of the caller.

```
i = 1; j = 2; ind = 'i j'
CALL p1; CALL p2
EXIT
p1: PROCEDURE EXPOSE i
SAY i j          /* 1 J */
RETURN
p2: PROCEDURE EXPOSE (ind)
SAY i j          /* 1 2 */
RETURN
```

An external routine without #cmd("PROCEDURE") shares all variables of its
caller, unlike TSO/E REXX (_BREXX/370 User's Guide_, “Finding and Calling
Execs”).

== PULL, PUSH and QUEUE <lang-instr-pull>

#idx("PULL")#idx("PUSH")#idx("QUEUE")#idx("stack")
```
PULL [template]
PUSH [expression]
QUEUE [expression]
```
#cmd("PUSH") puts a line on top of the stack, #cmd("QUEUE") at its bottom.
#cmd("PULL") -- short for #cmd("PARSE UPPER PULL") -- takes the top line,
or reads one if the stack is empty, and parses it in uppercase.

== RETURN <lang-instr-return>

#idx("RETURN")
```
RETURN [expression]
```
Returns from a routine, with the value of the expression as its result.
In the main exec it ends the exec, as #cmd("EXIT") does.

== SAY <lang-instr-say>

#idx("SAY")
```
SAY [expression]
```
Writes the value of the expression as a line: to the terminal, to
#cmd("SYSTSPRT") under TSO in batch, to #cmd("STDOUT") in batch without
TSO (_BREXX/370 User's Guide_, “Running REXX Programs”).

== SELECT <lang-instr-select>

#idx("SELECT")
```
SELECT
  WHEN expression [;] THEN [;] instruction
  ...
  [OTHERWISE [;] [instructions]]
END
```
Runs the instruction of the first #cmd("WHEN") whose expression is 1, or
the instructions after #cmd("OTHERWISE") if none is. Without
#cmd("OTHERWISE"), when no #cmd("WHEN") is true, the exec ends with error
7.3, _All WHEN expressions of SELECT are false\; OTHERWISE expected_.
#cmd("OTHERWISE NOP") says that nothing is to be done.

== SIGNAL <lang-instr-signal>

#idx("SIGNAL")#idx("condition trap")
```
SIGNAL label
SIGNAL [VALUE] expression
SIGNAL ON condition [NAME label]
SIGNAL OFF condition
```
#cmd("SIGNAL") #var("label") goes to the label and ends every active
#cmd("DO"), #cmd("IF"), #cmd("SELECT") and #cmd("INTERPRET").
#cmd("SIGNAL ON") enables a trap for one of the conditions #cmd("ERROR"),
#cmd("FAILURE"), #cmd("HALT"), #cmd("NOTREADY"), #cmd("NOVALUE") or
#cmd("SYNTAX"): when it is raised, control goes to the label of the
condition's name or to #var("label"), and the trap is turned off.
#cmd("FAILURE") is raised by a negative return code of a command; if
#cmd("FAILURE") is not trapped, #cmd("ERROR") is raised instead.

```
SIGNAL ON SYNTAX NAME syntax_error
SAY 1/0
...
syntax_error:
SAY 'Syntax error in line' SIGL
```

== TRACE <lang-instr-trace>

#idx("TRACE")
```
TRACE [?] option
TRACE VALUE expression
```
Sets what is traced. Only the first letter of the option counts:

#deflist(width: 1.4in,
  [#cmd("A") (All)], [every clause, before it runs.],
  [#cmd("C") (Commands)], [every command, before it runs.],
  [#cmd("E") (Error)], [commands with a non-zero return code, after they
    ran.],
  [#cmd("F") (Failure), #cmd("N") (Normal)], [commands with a negative
    return code, after they ran; #cmd("N") is the default.],
  [#cmd("I") (Intermediates)], [every clause and every intermediate
    result.],
  [#cmd("L") (Labels)], [labels passed.],
  [#cmd("M") (Members)], [the loading of members for external routines.
    An extension of BREXX/370.],
  [#cmd("O") (Off)], [nothing.],
  [#cmd("R") (Results)], [every clause and the result of each
    expression.],
  [#cmd("S") (Scan)], [the rest of the exec, without running it.],
)

The prefix #cmd("?") turns interactive debugging on or off (_BREXX/370
User's Guide_, “Debugging”). The prefix #cmd("!"), which in TSO/E REXX
suppresses commands, is accepted and ignored.
