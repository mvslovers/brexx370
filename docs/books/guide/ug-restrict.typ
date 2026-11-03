#import "../bookmaster/bookmaster.typ": *

= Restrictions <ug-restrict>

#idx("restrictions")
This chapter lists the limits of BREXX/370 and the places where it differs
from the REXX language definition or from TSO/E REXX by design.

== Limits <ug-restrict-limits>

#deflist(width: 1.9in,
  [Names and literals], [The name of a variable or label and a literal
    string may be some 250 bytes long. A longer literal ends the exec with
    error 30, #cmd("Name or string too long").],
  [Arguments], [A function or subroutine takes at most 32 arguments. A
    call with a 33rd ends with error 40 when the exec is compiled.],
  [Nesting], [#cmd("DO"), #cmd("IF"), #cmd("CALL") and the other control
    structures nest to a depth of about 255; deeper nesting ends with
    error 5, #cmd("System resources exhausted"), which the exec can trap
    with #cmd("SIGNAL ON SYNTAX").],
  [Counts], [The #cmd("FOR") count and a simple repetitive count of
    #cmd("DO"), and the exponent of #cmd("**"), must fit a 32-bit
    integer.],
)

== Numbers <ug-restrict-numbers>

#idx("NUMERIC DIGITS", "does not round")
BREXX/370 keeps a number as a 32-bit integer or as a floating-point double
and computes in that form. A result that does not fit an integer goes on as
a double. #cmd("NUMERIC DIGITS") does not round arithmetic: it applies only
to comparisons and to the form in which a result is shown. The REXX
definition rounds the operands and the result of every operation instead,
so results can differ once more than #cmd("DIGITS") digits are involved,
usually by being more precise:

#tab(caption: [Arithmetic with NUMERIC DIGITS 9])[
  #table(columns: (2.6in, 1fr, 1fr),
    [Expression], [BREXX/370], [REXX definition],
    [#cmd("1000000000-1")], [#cmd("999999999")], [#cmd("1.00000000E+9")],
    [#cmd("1e9-6")], [#cmd("999999994")], [#cmd("999999990")],
    [#cmd("123456789 * 0.00005 * 3333.333 * 21.43")], [#cmd("440946454")],
      [#cmd("440946453")],
  )
] <ug-restrict-num-tab>

This is a property of the design and is not going to change.

#idx("DATATYPE", "TYPE")
#cmd("DATATYPE(")#var("value")#cmd(", 'TYPE')") tells what a value looks
like: #cmd("INTEGER") for #cmd("'2'") and #cmd("2 + 1"), #cmd("REAL") for
#cmd("2 + 0.1"), #cmd("STRING") for #cmd("'abc'"). A blank between the
sign and the digits is allowed: #cmd("'- 2'") is a number and has the
value -2.

== Calling Programs and Sharing Variables <ug-restrict-irxexcom>

#idx("IRXEXCOM")#idx("ECTENVBK")
BREXX/370 has no module, alias or entry point #cmd("IRXEXCOM"): the name
belongs to REKX/370 (rekx370). A program that an exec calls -- through
#cmd("ADDRESS TSO"), #cmd("LINK"), #cmd("LINKMVS"), #cmd("LINKPGM"), as a
host command environment or as an external function -- receives register 0
as zero. It can still read and set the exec's variables, the way TSO/E
programs do:

+ While the exec runs, the TSO field #cmd("ECTENVBK") (ECT + X'30') holds
  the address of the environment block of BREXX/370. A program finds the ECT
  through the TSO/E address space (the LWA of the TCB's ASXB), as an
  assembler program under TSO does. Under a batch job without TSO there is
  no ECT, and BREXX/370 publishes nothing.
+ The block has the usual layout. At offset X'1C' it points to the vector
  #cmd("IRXEXTE"), whose address at offset X'10' is the variable
  routine.
+ The program calls that address with the #cmd("IRXEXCOM") parameter list:
  the characters #cmd("IRXEXCOM"), two reserved words, the address of a
  chain of SHVBLOCKs, optionally the address of the environment block and
  the address of a fullword for the return code, with the high bit set in
  the last address.

The routine handles the codes #cmd("F"), #cmd("S") and #cmd("D") (direct:
the name is used as written, a compound name with its tail as written),
#cmd("f"), #cmd("s") and #cmd("d") (symbolic: the name is translated to
upper case and the tail is substituted), #cmd("N") (the next variable) and
#cmd("P") (#cmd("PARM"), #cmd("PARM.")#var("n") and #cmd("VERSION")). The
flags in SHVRET and the return codes follow the _TSO/E REXX Reference_. The
variables are those of the exec at the moment of the call, also while the
interpreter waits for a host command.

BREXX/370 restores the previous value of #cmd("ECTENVBK") at the end of
the exec, also after an abend that it caught, and only when
#cmd("ECTENVBK") still holds its own block. A value that another
environment stored meanwhile stays. This is how it runs beside REKX/370.

Differences from TSO/E REXX:

- The routine is reachable only through the address in #cmd("IRXEXTE"). A
  program that loads or links to #cmd("IRXEXCOM") by name gets REKX/370's
  module, if it is installed.
- The return code (register 15, and the sixth parameter when there is one)
  is the OR of the error flags of all blocks (truncated, bad name, bad
  value, bad function code), -1 for an invalid parameter list, and 28 when
  no exec is running or the environment block is not the one of BREXX/370.
  These rules follow the _TSO/E REXX Reference_; they were not compared
  with an IBM system.
- Only the entry for #cmd("IRXEXCOM") of the vector #cmd("IRXEXTE") is
  filled in; the other entries are zero.
- A fetch of a variable that has no value returns its name in upper case
  (for a compound name with the tail substituted, or the default of its
  stem) and sets #cmd("SHVNEWV").
- #cmd("N") returns the names in the order of the interpreter's variable
  tree, not in the order of their creation. The call after the last
  variable returns no variable and sets #cmd("SHVLVAR"); the walk then
  starts anew. As in TSO/E, a request that is not #cmd("N") also starts
  it anew.
- #cmd("P") knows only the three names above; any other name is a bad
  name.
- The caller must run in the task that runs the exec. The routine is not
  reentrant, and the C runtime refuses a call from a subtask of a C program
  (abend U3101).
- An out-of-storage condition inside the routine ends the exec as it would
  anywhere else in the interpreter and is not reported as a return code.

== Code Pages <ug-restrict-codepages>

#idx("code page")
A data set holds the bytes that the 3270 emulator sent, and which byte a
key sends depends on the host code page set in the emulator. BREXX/370
accepts the REXX syntax characters under three code pages:

#tab(caption: [REXX syntax characters by code page])[
  #table(columns: (1.6in, 0.8in, 1.2in, 0.9in),
    [Character], [CP037], [x3270 "bracket"], [IBM-1047],
    [#cmd("¬") (not)], [X'5F'], [X'5F'], [X'B0'],
    [#cmd("^") (not)], [X'B0'], [X'B0'], [X'5F'],
    [#cmd("\\") (not)], [X'E0'], [X'E0'], [X'E0'],
    [#cmd("|")], [X'4F'], [X'4F'], [X'4F'],
    [#cmd("[") (pattern)], [X'BA'], [X'AD'], [X'AD'],
    [#cmd("]") (pattern)], [X'BB'], [X'BD'], [X'BD'],
  )
] <ug-restrict-cp-tab>

#cmd("¬"), #cmd("^") and #cmd("\\") are all "not", so #cmd("¬=") works under
any of the three. National code pages such as CP273 (German) or CP500 put
#cmd("|") at X'BB' and #cmd("¬") at X'BA': there #cmd("||") is no
concatenation and #cmd("¬") is not "not", while #cmd("^") and #cmd("\\")
still are. A file transfer translates with a table of its own, which may
not match the emulator: check #cmd("¬") and #cmd("|") after uploading an
exec.

== Other Restrictions <ug-restrict-other>

- #cmd("OPEN") with the third parameter #cmd("VIO"), a file in storage, ends
  with error 40.
- #cmd("VARTREE") does not show variables whose names hold non-printable
  characters correctly.
