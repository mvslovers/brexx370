#import "../bookmaster/bookmaster.typ": *

= Global Variables <ext-global>

#idx("global variable")
A global variable is a named value that every part of a program can
reach, whatever #cmd("PROCEDURE") hides: the main program, its internal
routines and the external execs it calls. Global variables are not REXX
variables. They are set and read only through the functions
#cmd("SETG") and #cmd("GETG"), never by assignment or by name in an
expression. TSO/E REXX has no such functions.

The store belongs to the interpreter. It is created when the interpreter
starts and freed when it ends, so a value does not survive from one
#cmd("RX") call to the next.

Names are changed to uppercase, so #cmd("'city'") and #cmd("'CITY'")
are the same global variable. A name is a plain string: there are no
stems, and #cmd("'A.1'") is simply a name that contains a period, with
no relation to #cmd("'A.2'") or #cmd("'A.'").

The same store also holds the source of routines made by #cmd("LOADRX")
(@ext-kernel-loadrx), under the routine's name, and of routines defined
with #cmd("ADDRESS DYNREXX") (@ext-address), and some functions written
in REXX keep internal entries there whose names start with #cmd("__").
#cmd("SETG") with the name of such a routine replaces its source, and
#cmd("GETG") with that name returns it. Do not use names starting with
#cmd("__") for your own values.

== SETG <ext-global-setg>

#idx("SETG")
```
SETG(name, value)
```
Sets the global variable #var("name") to #var("value"), replacing any
value it had, and returns #var("value").

```
CALL setg 'city', 'Munich'
SAY setg('ctime', time('L'))       /* e.g. 19:45:12.538474 */
```

== GETG <ext-global-getg>

#idx("GETG")
```
GETG(name)
```
Returns the value of the global variable #var("name"), or the null
string if it has not been set.

```
CALL setg 'ctime', time('L')
CALL setg 'city', 'Munich'
CALL testproc
EXIT 0

testproc: PROCEDURE
  /* the caller's variables are hidden, its global variables are not */
  SAY getg('ctime')                /* e.g. 19:45:12.538474 */
  SAY getg('city')                 /* Munich               */
  SAY getg('country')              /* ''                   */
RETURN 0
```
