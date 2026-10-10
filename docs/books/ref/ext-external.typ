#import "../bookmaster/bookmaster.typ": *

= Calling External Programs <ext-external>

#idx("external function")#idx("load module", "as a function")
A load module, written for example in assembler or PL/I, can be called
from an exec like a function. BREXX/370 passes the arguments in an
external function parameter list (EFPL) modelled on the one of TSO/E
REXX, and takes the value of the function from an evaluation block. A
compiled program is much faster than the same algorithm in REXX, which
pays for numeric work.

This chapter describes that interface. To run a program with a
parameter, as a command, use #cmd("ADDRESS LINK"), #cmd("LINKMVS") or
#cmd("LINKPGM") instead (@ext-address-link).

== Calling a Load Module <ext-external-call>

=== External Function Call <ext-external-fn>

#idx("external function", "call")
```
name([argument [, argument] ...])
CALL name [argument [, argument] ...]
```
#var("name") is the name of the load module; a longer name is cut to
its first 8 characters.
BREXX/370 calls a load module only when #var("name") is none of the
following, which it tries first: a label of the exec, a built-in
function, or an exec found in RXLIB, in the library of the main exec or
as a data set. The load module must then be in the program search
order (STEPLIB, JOBLIB, link list); it is called with #cmd("LINK").

Up to 32 arguments can be passed, as to any function. An omitted
argument, as in #cmd("F(a,,c)"), arrives with length 0.

The value of the function is the data the program puts into the
evaluation block, up to 4096 bytes. The return code of the program
(register 15) is put into #cmd("RC"), and the value also into
#cmd("RESULT"), whether the module was called as a function or with
#cmd("CALL"). If the program returns no data, #cmd("RC") is set to
#cmd("-3"), and the value of the function is not defined.

```
SAY rxpi()               /* 3.14159265358979323846... */
SAY rc                   /* the program's return code */
```

Differences from TSO/E REXX: TSO/E passes the address of the REXX
environment block in register 0, BREXX/370 passes 0, so the program
cannot use REXX services such as IRXEXCOM to read or set variables.
The evaluation block holds 4096 bytes and cannot be replaced by a
larger one (TSO/E: IRXRLT). TSO/E does not set #cmd("RC") for a
function, and a call as a function that returns no data ends in
error 44 there.

== The Program Interface <ext-external-interface>

=== Registers and EFPL <ext-external-efpl>

#idx("EFPL")
On entry to the program:

#deflist(width: 1.2in,
  [Register 0], [0.],
  [Register 1], [The address of the EFPL, with the high-order bit
    on.],
  [Register 13], [The address of a save area.],
  [Register 14], [The return address.],
  [Register 15], [The entry point address.],
)

The EFPL consists of six fullwords:

#deflist(width: 1.2in,
  [#cmd("EFPLCOM")], [Reserved, 0.],
  [#cmd("EFPLBARG")], [Reserved, 0.],
  [#cmd("EFPLEARG")], [Reserved, 0.],
  [#cmd("EFPLFB")], [Reserved, 0.],
  [#cmd("EFPLARG")], [The address of the argument table.],
  [#cmd("EFPLEVAL")], [The address of a fullword that holds the address
    of the evaluation block.],
)

=== Argument Table <ext-external-argtable>

#idx("argument table")
The argument table has an entry of two fullwords for each argument:

#deflist(width: 1.2in,
  [#cmd("ARGTABLE_ARGSTRING_PTR")], [The address of the argument.],
  [#cmd("ARGTABLE_ARGSTRING_LENGTH")], [Its length.],
)

Entry #var("i") describes argument #var("i"). The entries after the
last argument are filled with #cmd("X'FF'"), so that the first entry
whose address is #cmd("X'FFFFFFFF'") ends the list, as in TSO/E. An
argument is passed up to its
first #cmd("X'00'") byte, and is followed by #cmd("X'00'") in storage.

=== Evaluation Block <ext-external-evalblock>

#idx("EVALBLOCK")
#deflist(width: 1.2in,
  [#cmd("EVPAD1")], [Fullword, reserved, 0.],
  [#cmd("EVSIZE")], [Fullword: the size of the whole block in
    doublewords, 514 (16 bytes of header and 4096 of data).],
  [#cmd("EVLEN")], [Fullword: the length of the result. BREXX/370 sets
    it to #cmd("X'80000000'"); the program stores the length of its
    result here.],
  [#cmd("EVPAD2")], [Fullword, reserved, 0.],
  [#cmd("EVDATA")], [The result, up to 4096 bytes.],
)

To return a value, the program moves it into #cmd("EVDATA") and its
length into #cmd("EVLEN"), and sets register 15 to the return code it
wants in #cmd("RC").

A length over 4096 in #cmd("EVLEN") is cut to 4096.

=== PL/I Sample <ext-external-pli>

#idx("PL/I")
Two sample jobs of the JCL library compile and link a PL/I external
function with the PL/I F compiler: #cmd("PL1PI") builds #cmd("RXPI"),
which computes 500 digits of pi, and #cmd("PL1CUT") builds
#cmd("RXCUT"). Both link the module into #cmd("SYS2.LINKLIB"). Their
source begins with the interface declarations, which can be moved into
a library member #cmd("RXCOMM") and included with
#cmd("%INCLUDE RXCOMM;"). After it, the program finds:

#deflist(width: 1.2in,
  [#cmd("ARGNUM")], [The number of the last argument given.],
  [#cmd("ARG(")#var("i")#cmd(")")], [Argument #var("i"), up to 255
    characters.],
  [#cmd("ARG_LEN(")#var("i")#cmd(")")], [Its length.],
  [#cmd("RESULT")], [The result to return, declared
    #cmd("CHAR(1024)").],
  [#cmd("RESULT_LEN")], [Its length.],
)

```
RXPI:  PROCEDURE(EFPL_PTR) OPTIONS(MAIN);
  %INCLUDE RXCOMM;
  ...
  RESULT='3.'||SUBSTR(PI,3);
  RESULT_LEN=LENGTH(PI);
END RXPI;
```

The declarations limit a program built with them to 1024 bytes of
result and 255 bytes per argument, less than the interface allows.

#note[*To be confirmed:* the old _User's Guide_ measured #cmd("RXPI")
at about 0.5 seconds against about 300 seconds for the same algorithm in
REXX, some 600 times faster; this has not been measured with 3.0.]
