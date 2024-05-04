# Instructions

Each REXX instruction is one ore more clauses, the first clause is the
one that identifies the instruction. Instructions end with a semicolon
or with a new line. One instruction may be continued from one line to
the next by using a comma at the end of the line. Open strings or
comments are not affected by line ends.

## General Guidelines

### name;

refers to a variable, which can be assigned any value. name is a
symbol with the following exception: the first character may not be
a digit or a period. The value of name is translated to uppercase
before use, and forms the initial value of the value of the
variable. Some valid names are:

- Fred
- COST?
- next
- index
- A.j

### name:

is a form of labels for CALL instructions, SIGNAL instructions, and
internal function calls. The colon acts as a clause separator.

### template;

is a parsing template, described in a later section.

### instr;

is any one of the listed instructions.

## Instructions

### expression;

the value of expression is issued as a command, normally to the
command interpreter or to the specified environment specified by the
ADDRESS instruction. Look also the section “Issuing Commands to Host
System.”

### name = [expr];

is an assignment: the variable name is set to the value of expr.

```rexx
fred = 'sunset'
a = 1 + 2 * 3
a = /* a contains '' */
```

### ADDRESS [<symbol | string> [expr]] | VALUE expr | (env);

redirect commands or a single command to a new environment. ADDRESS
VALUE expr may be used for an evaluated environment name.

```rexx
address int2e 'dir' /* executes through int2e a dir cmd */
address system /* all the following command will be addressed to system */
env = 'dos'
address value env /* change address to dos */
address (env) /* change address to dos */
```

### ARG <template>;

parse argument string(s) given to program or in an internal routine into variables according to template. Arguments are translated into uppercase before the parsing. Short for PARSE UPPER ARG.

```rexx
 /* program is called with args "autoexec.bat auto.old" */
 arg src dest
 /* src = "AUTOEXEC.BAT", dest="AUTO.OLD" */
 /* a function is called MARMITA('Bill',3) */
 marmita:
 arg firstarg, secondarg
 /* firstarg = "BILL", secondarg = "3" */
```

### CALL [symbol | string] [<expr>] [,<expr>]... ;

### [ON|OFF <condition> [NAME label]];

call an internal routine, an external routine or program, or a
built-in function. Depending on the type of routine called, the
variable RESULT contains the result of the routine. RESULT is
uninitialized if no result is returned.

```rexx
 CALL SUBSTR 'makedonia',2,3
 /* now. variable result = 'ake' */
 /* the same can be obtained with */
 result = SUBSTR('makedonia',2,3)
```

In the following sections there is a description of all the
built-in rexx functions.

Internal functions are sequence of instructions inside the same
program starting at the label that matches the name in the CALL
instruction.

If the function is not found in the current program, then REXX will
search for a file that matches the name in the CALL instruction and
the same extension like the current program, and will load it as an
external rexx function.

External routines are like internal but written in a separate module
that can be used as a library. Rexx libraries are rexx files with
many external routines which must be loaded with the built-in
function LOAD before they are used (see below).

As external routines can be used any DOS command or program that
uses standard input and output.

```rexx
 /* external programs can be called as routines */
 /* and the output of the program (to stdout) will */
 /* be returned as the result string of the function */
 CALL "dir" "*.exe","/w" /* or */
 files = "dir"('*.exe',"/w")
 current_directory = 'cd'()
```

For CALL ON/OFF condition look below at the SIGNAL instruction.

### DO [name=expri [TO exprt] [BY exprb] [FOR exprf]] | [ FOREVER | exprr ] ;

### [UNTIL expru | WHILE exprw] ;

### [instr]... ;

### END[symbol] ;

DO is used to group many instructions together and optionally
executes them repetively.

Simple DO loop are used to execute a block of instructions often
used with IF-THEN statements.

#### NOTE
Simple DO loops are not affected with ITERATE or LEAVE
instructions (see below)

```rexx
 IF name = 'Vivi' THEN DO
         i = i + 1
         SAY 'Hello Vivi'
     END
```

Simple repetitive loops.

#### NOTE
in DO expr, expr must evaluate to an integer number.

```rexx
 DO 3    /* would display 3 'hello' */
     SAY 'hello'
 END
```

Inifinite loops

```rexx
 DO FOREVER    /* infinite loop, display always */
     SAY 'lupe forever'    /* 'hello' */
 END
```

Loops with control variable. name is stepped from expri to exprt in steps of exprb, for a maximum of exprf iterations.

```rexx
 DO i = 1 TO 10 BY 3     /* would display the numbers */
     SAY i     /* 1, 4, 7, 10 */
 END
```

#### NOTE
all the expressions are evaluated before the loop is executed and may result to any kind of number, integer or real.

Conditional loops

```rexx
 a = 2        /* would display */
 DO WHILE a < 5     /* 2 */
     SAY a     /* 4 */
     a = a + 2
 END
```

#### NOTE
exprw and expru are evaluated in each iteration and must result to 0 or 1. WHILE expression is evaluated before each iteration, where UNTIL expression is evaluated at the end of each iteration.

You can combine them like:

```rexx
 a = 1            /* would display */
 DO FOR 3 WHILE a < 5     /* 1 */
     SAY a        /* 2 */
     a = a + 1        /* 3 */
 END
```

### DROP <name | (nameind)> [<name | (nameind)>]... ;

DROP (reset) the named variables or group of variables by freeing their memory. It returns them in their original uninitialized state.
If a variable is enclosed in parenthesis then DROP resets all the variables that nameind contains as separate words.
If an exposed variable is named, the variable itself in the older generation will be dropped! If a stem is specified all variables starting with that stem will be dropped.

```rexx
 j = 2
 vars="j b stem."
 DROP a x.1 y.j        /* resets variables A X.1 and Y.2 */
 DROP z.        /* resets all variables with names
     starting with Z. */
 DROP (name)        /* resets variables j b and stem. */
```

### EXIT [expr] ;

leave the program (with return data, expr). EXIT is the same as RETURN except that all internal routines are terminated.

```rexx
 EXIT 12*3    /* will exit the program with RC=36 */
```

### IF expr [;]     THEN [;] instr ;

### [ELSE [;] instr];

if expr evaluates to “1”, executes the instruction following the THEN. Otherwise, when expr evaluates to “0”, the instruction after ELSE is executed, if ELSE is present.

```rexx
 IF name="Vivi"    THEN SAY "Hello Vivian"
     ELSE SAY "Hello stranger"
```

### INTERPRET expr ;

expr is evaluated and then is processed, as it was a part of the program.

```rexx
 cmd = "SAY 'Hello'"
 INTERPRET cmd     /* displayes "Hello" */
```

### ITERATE [name] ;

start next iteration of the innermost repetitive loop (or loop with control variable name).

```rexx
 DO    i = 1 TO 5        /* would display:     1 */
     IF i=3 THEN ITERATE        /*     2 */
     SAY i        /*     4 */
 END         /*     5 */
```

### LEAVE [name] ;

terminate innermost repetitive loop (or loop with control variable name).

```rexx
 DO    i = 1 TO 5        /* would display:     1 */
     IF i=3 THEN LEAVE        /*     2 */
     SAY i
 END
```

### LOWER name [name]...

translate the values of the specified individual variables to lowercase.

```rexx
 name = 'ViVi'
 LOWER name        /* now, name = 'vivi' */
```

### NOP ;

dummy instruction, has no effect.

```default
 IF name^='Vivi' THEN NOP; ELSE SAY 'Hello Vivi.'
```

### NUMERIC DIGITS [expr] | FORM [SCIENTIFIC | ENGINEERING] | FUZZ [expr] ;

Set the number of significant digits used for all arithmetic
operations.

#### NOTE
In BRexx all numerical operations are performed either with
the 32bit integer type or 64 double precission, so the numeric
digits is limited for floating point operations to maximum 22
digits.

### PARSE [type] + ARG + [template] ;

Parse is used to assign data from various sources to one or more
variables according to the template (see below for template
patterns) where the optional type is one of:

- ARG, parses the argument string(s) passed to the program,
  subroutine, or function. UPPER first translates the strings to
  uppercase. See also the ARG instruction.
- AUTHOR parse the author string.
- EXTERNAL, prompts for input and parses the input string
- LINEIN, same as EXTERNAL
- NUMERIC, parse the current NUMERIC settings.
- PULL, read and parse the next string from REXX stack if not empty
  otherwise prompts for input. See the PULL instruction.
- SOURCE, parse the program source description e.g. “MSDOS COMMAND
  prog.r C:REXX.EXE C:DOSCOMMAND.COM”
- VALUE, parse the value of expr.
- VAR, parse the value of name.
- VERSION, parse the version string of the interpreter.

### PROCEDURE [EXPOSE name|(varind) [name|(varind)]...] ;

start a new generation of variables within an internal routine. Optionally named variables or groups of variables from an earlier generation may be exposed. If a stem is specified (variable ending in ‘.’ dot, ie ‘A.’) then every variable starting with this stem will be exposed. Indirect exposure is also posible by enclosing inside parenthesis the variable varind which contains contains as separate words all variables to be exposed

```rexx
 i = 1
 j = 2
 ind = "i j"
 CALL myproc
 CALL myproc2
 EXIT
 myproc: PROCEDURE EXPOSE i     /* would display */
 SAY i j        /* 1 J */
 RETURN
 myproc2: PROCEDURE EXPOSE (ind)     /* would display */
 say i j        /* 1 2 */
 RETURN
```

### PULL [template] ;

pops the next string from rexx internal stack. If stack is empty then it prompts for input. Translates it to uppercase and then parses it according to template. Short for PARSE UPPER PULL.

```rexx
 PUSH 'Vassilis Vlachoudis'
 /* --- many instrs ---- */
 PULL name surname     /* now: name='BILL', */
     /* surname='VLACHOUDIS' */
```

### PUSH [expr] ;

push expr onto head of the rexx queue (stack LIFO)

### QUEUE [expr] ;

add expr to the tail of the rexx queue (stack FIFO)

### RETURN [expr] ;

return control from a procedure to the point of its invocation. if expr exits, then it is returned as the result of the procedure.

```rexx
 num = 6
 SAY num || '! = ' fact(num)
 EXIT
 fact: PROCEDURE        /* calculate factorial with */
 IF arg(1) = 0 THEN RETURN 1        /* recursion */
 RETURN fact(ARG(1)-1) * ARG(1)        /* displayes: 6! = 720 */
```

### SAY [expr];

evaluate expr and then writes the result to standard output (normally user’s console) followed by a newline.

### SELECT ;

### WHEN expr [;] THEN [;] instr;

### [ WHEN expr [;] THEN [;] instr; ]

### [ OTHERWISE [;] [instr]... ];

### END ;

SELECT is used to conditionally process one of several alternatives. Each WHEN expression is evaluated in sequence until one results in “1”. instr, immediately following it, is executed and control leaves the block. If no expr evaluated to “1”, control passes to the instructions following the OTHERWISE expression that must then be present.

```rexx
 num = 10
 SELECT
     WHEN num > 0 THEN SAY num 'is positive'
     WHEN num < 0 THEN SAY num 'is negative'
     OTHERWISE SAY num 'is zero'
 END
```

### SIGNAL     [name] |

### [VALUE] expr |

### <ON | OFF>     + condition + [NAME label];

* **Parameters:**
  **condition** – Can be one of ERROR HALT NOTREADY NOVALUE SYNTAX

- name, jump to the label name specified. Any pending
  instructions, DO … END, IF, SELECT, and INTERPRET are
  terminated.
- VALUE, may be used for an evaluated label name.
- ON|OFF, enable or disable exception traps.
- Condition must be ERROR, HALT, NOTREADY, NOVALUE, or SYNTAX.
  Control passes to the label of the condition name if the event
  occurs while ON or to label if NAME label is specified.

```rexx
 SIGNAL vivi
 ...
 vivi:
 SAY 'Hi!'
```

A condition example:

```rexx
 SIGNAL ON SYNTAX NAME syntax_error
 SAY 1/0     /* Control passes to label syntax_error */
 ...
 syntax_error:
 SAY 'Syntax error in line:' SIGL
```

### TRACE option | VALUE expr;

Trace according to following option. Only first letter of option
is significant.

- A (All) trace all clauses.
- C (Commands) trace all commands.
- E (Error) trace commands with non-zero return codes after
  execution.
- I (Intermediates) trace intermediate evaluation results and name
  substitutions also.
- L (Labels) trace only labels.
- N (Negative or Normal) trace commands with negative return codes
  after execution (default setting).
- O (Off) no trace.
- R (Results) trace all clauses and expressions.
- S (Scan) display rest of program without any execution (shows
  control nesting).
- ? turn interactive debug (pause after trace) on or off, and trace
  according to next character. null restores the default tracing actions.

TRACE VALUE expr may be used for an evaluated trace setting.

### UPPER name [name]...

translate the values of the specified individual variables to uppercase.

```rexx
 name = 'Vivi'
 UPPER name        /* now: name = 'VIVI' */
```
