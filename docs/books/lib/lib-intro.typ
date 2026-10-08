#import "../bookmaster/bookmaster.typ": *

= The REXX Library <lib-intro>

#idx("RXLIB")#idx("REXX library")
RXLIB is a library of functions and programs written in REXX that comes
with BREXX/370. An exec calls an RXLIB function by its name, like a
built-in function, and needs nothing else for it than the allocation of
the library. This chapter explains where a called function comes from,
how RXLIB is allocated, and the conventions that its members share. The
members themselves are described in @lib-rxlib and in the chapters that
follow it.

== Where a Function Comes From <lib-intro-layers>

#idx("built-in function", "three kinds")
A function that an exec calls comes from one of three layers:

+ *Built into the interpreter, in C.* The REXX built-in functions and most
  of the BREXX/370 functions are part of the load module #cmd("BREXX").
+ *Built into the interpreter, in REXX.* Some functions, among them
  #cmd("SYSVAR"), #cmd("MVSVAR"), #cmd("SEC2TIME") and
  #cmd("STEMCOPY"), are written in REXX but carried inside the load
  module. They are there with no RXLIB allocated.
+ *In RXLIB.* Members of the library allocated to the DD name
  #cmd("RXLIB").

The _BREXX/370 Reference_ describes the first two layers, this book the
third.

== How a Function Is Found <lib-intro-search>

#idx("RXLIB", "search order")#idx("external routine", "search order")
When an exec calls #var("name"), and #var("name") is not a label of the
exec, BREXX/370 looks for it in this order:

+ the built-in functions written in C;
+ the functions written in REXX and carried in the load module;
+ a member #var("name") of the library allocated to #cmd("RXLIB");
+ a member #var("name") of the library from which the main exec was read;
+ a data set #var("name"), when the name has a period or is longer than
  eight characters.

The first hit runs. An RXLIB member therefore cannot replace a built-in
function: in release 3.0 the member QUOTE is never called, because
#cmd("QUOTE") is built in (@lib-rxlib-quote). A member of the exec's own
library cannot replace an RXLIB member either. The _BREXX/370 User's
Guide_ describes the search in detail ("Calling an External Routine").

#idx("RXLIB", "member name and label")
*The member name counts, not the label.* A member is found by its name
and runs from its first line. Several members begin with a label of
another name -- STEMCLEN with #cmd("stemreor:"), NJE38DSN with
#cmd("RXNJE38DSN:"), SGLDSI with #cmd("sgldis:") -- which does not
matter for the call.

#idx("IMPORT", "RXLIB member")
*Routines inside a member.* When a member has been loaded, all its labels
are known to the rest of the run: an exec can then call a routine of the
member by its label. Some members are meant to be used that way and are
loaded with #cmd("CALL IMPORT ")#var("name") (_BREXX/370 Reference_,
"IMPORT"):

#deflist(width: 1.2in,
  [#cmd("FSSAPI")], [The formatted-screen functions (@lib-fssmenu).],
  [#cmd("KEYVALUE")], [The key/value database (@lib-kv).],
  [#cmd("MVSCBS")], [Addresses of MVS control blocks
    (@lib-rxlib-mvscbs).],
  [#cmd("RXDATE")], [Needed before DAYSBETW (@lib-rxlib-daysbetw).],
)

The member DCL works the same way without an import: its routines
SPLITRECORD and SETRECORD can be called once DCL itself has been called
(@lib-rxlib-dcl).

== Allocating RXLIB <lib-intro-alloc>

#idx("RXLIB", "allocation")
The library is installed as #cmd("BREXX.RXLIB") with release 3.0, and as
#cmd("BREXX.")#var("version")#cmd(".RXLIB") by an installation by hand
(_BREXX/370 User's Guide_, "Installation"). It must be allocated to the
DD name #cmd("RXLIB"):

#deflist(width: 1.4in,
  [TSO session], [by the logon CLIST, as the _User's Guide_ shows
    ("Setting Up TSO"):
    #cmd("ALLOC FILE(RXLIB) DSN('BREXX.RXLIB') SHR").],
  [TSO in batch], [by the procedure #cmd("RXTSO"), from its parameter
    #cmd("LIB=").],
  [Batch without TSO], [by the procedure #cmd("RXBATCH"), from its
    parameter #cmd("LIB=").],
)

#note[*To be confirmed:* the #cmd("LIB=") defaults of the procedures in
release 3.0. In the procedures of the source tree, #cmd("RXBATCH")
names #cmd("BREXX.CURRENT.RXLIB") and #cmd("RXTSO")
#cmd("BREXX.V2R5M3.RXLIB"). Pass #cmd("LIB=") explicitly until this is
settled.]

Without an RXLIB allocation, the members are still found when they are in
the library the main exec was read from.

== Conventions <lib-intro-conv>

#idx("RXLIB", "conventions")
The members of RXLIB share these conventions:

- A *stem* is passed by its name, as a string, with the trailing period:
  #cmd("CALL stemreor 'LIST.'"). Its number of entries is in
  #var("stem")#cmd(".0").
- A *data set name* is passed fully qualified and without quotes; the
  member adds them. READALL and WRITEALL also take a DD name.
- *Results in variables.* Many members leave their result in variables of
  fixed names besides returning a value -- #cmd("LISTALCDSN."),
  #cmd("SORTIN."), #cmd("BUFFER."), #cmd("CONSOLE."). Such a member is not
  a #cmd("PROCEDURE"), or it exposes these names, so they appear in the
  caller. A member without #cmd("PROCEDURE") also shares the caller's other
  variables; prefer names that do not begin with #cmd("_") or #cmd("$"),
  which the members use for their own work variables.
- *Messages.* Members report errors with RXMSG (@lib-rxlib-rxmsg), whose
  variable #cmd("RXMSLV") controls which messages appear and whose
  #cmd("MAXRC") keeps the highest return code.
- *Return codes.* A negative value, usually #cmd("-8"), means the member
  could not do its work; a value from 0 up is a count or a return code.
- *Buffers for screens.* Members that prepare output for a formatted list
  put its lines into the stem #cmd("BUFFER."), which FMTLIST displays
  (@lib-fssmenu).

== Writing Your Own Functions <lib-intro-own>

#idx("RXLIB", "own functions")
A function of your own is an exec in a library that BREXX/370 searches:
the library the main exec is read from, or RXLIB. The value the function returns is the expression of
its #cmd("RETURN") instruction. Begin it with #cmd("PROCEDURE") unless it
is meant to share the caller's variables. Do not give it the name of a
built-in function or of an RXLIB member that it should not replace: the
first hit in the search order runs.

```
/* member ADD3, in the exec's own library */
ADD3: PROCEDURE
  RETURN arg(1) + 3

/* the caller */
SAY add3(4)                 /* 7 */
```
