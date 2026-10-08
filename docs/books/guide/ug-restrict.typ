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
    call with more returns its value, but corrupts the clause that makes
    it, without an error; with 64 or more it ends with error 5. This is a
    defect (brexx370 issue 384).],
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

#idx("IRXEXCOM")
BREXX/370 provides no #cmd("IRXEXCOM"). A program that an exec calls --
through #cmd("ADDRESS TSO"), #cmd("LINK"), #cmd("LINKMVS"),
#cmd("LINKPGM"), as a host command environment or as an external function
-- receives register 0 as zero and cannot read or set the exec's
variables. BREXX/370 leaves the TSO field #cmd("ECTENVBK") alone, so that
it can run beside REXX/370.

An external routine shares the variables of its caller unless it begins
with #cmd("PROCEDURE"), which TSO/E REXX does not do
(@ug-calling-scope).

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
