#import "../bookmaster/bookmaster.typ": *

= Changes in Release 3.0 <ref-changes>

#idx("release 3.0", "changes")#idx("V2R5M3", "differences")
This chapter lists what an exec written for V2R5M3 can notice when it runs
under release 3.0. The chapters of this book describe release 3.0 only;
here are the places where it differs from V2R5M3, and the reasons to look
twice at an old exec. The _BREXX/370 User's Guide_, “Migrating from
V2R5M3”, has the same changes from the side of the installation and the
procedures.

Release 3.0 follows the TSO/E REXX Reference wherever BREXX/370 and TSO/E
differed and an exec could tell. Most of the entries below are such a
case.

== What an Exec Sees <ref-changes-before-after>

The table shows the same lines run under V2R5M3 (TK5, level L02) and
under release 3.0.

#tab(caption: [The same expression under V2R5M3 and release 3.0])[
  #table(columns: (2.2in, 1.3in, 1fr),
    [Expression], [V2R5M3], [3.0],
    [#cmd("'abc  ' = 'abc'")], [#cmd("0")], [#cmd("1")],
    [#cmd("100.5-50.6 = 49.9")], [#cmd("0")], [#cmd("1")],
    [#cmd("1E-20 = 0")], [#cmd("1")], [#cmd("0")],
    [#cmd("2147483647+1")], [#cmd("-2147483648")], [#cmd("2147483648")],
    [#cmd("2=2=2")], [syntax error 36], [#cmd("0")],
    [#cmd("0**-1")], [abend S0CF], [error 42],
    [#cmd("ARG(100)")], [error 40], [the null string],
    [#cmd("C2D('0102030405'X)")], [#cmd("33752069")], [error 40],
    [#cmd("X2D('123456789')")], [#cmd("591751049")], [error 40],
    [#cmd("X2D('FF',0)")], [#cmd("255")], [#cmd("0")],
    [#cmd("QUOTE('abc','\"')")], [#cmd("'abc'")], [#cmd("\"abc\"")],
    [#cmd("WORDS('a'||'05'X||'b c')")], [#cmd("3")], [#cmd("2")],
    [#cmd("FORMAT(1/3)")], [#cmd("0")], [#cmd("0.333333333333333")],
    [#cmd("FORMAT(12.34)")], [#cmd("12")], [#cmd("12.34")],
    [#cmd("DATATYPE(1E75,'N')")], [#cmd("1")], [#cmd("0")],
    [#cmd("ADDRESS")] + [ to an environment that does not exist],
      [#cmd("RC") -42 and the message #cmd("ERROR> please report this.")],
      [#cmd("RC") -3],
    [#cmd("SELECT") with no true #cmd("WHEN") and no #cmd("OTHERWISE")],
      [runs on], [error 7],
    [#cmd("DECRYPT(ENCRYPT('hello','key'),'key')")], [garbage],
      [#cmd("hello")],
    [#cmd("DATE('GER','20261008','S')")], [#cmd("08.10.0026")],
      [#cmd("08.10.26")],
    [#cmd("ROUND(-0.001,2)")], [#cmd("-0.00")], [#cmd("0.00")],
    [#cmd("PRIVILEGE('OFF')")], [#cmd("8")], [#cmd("0")],
    [#cmd("CONSOLE('D T')")], [a number that is not a result, here
      #cmd("-0.001")], [#cmd("0")],
  )
] <ref-changes-tab>

== Language <ref-changes-language>

- A comparison with #cmd("=") , #cmd("<") or #cmd(">") ignores trailing
  blanks, as the REXX definition says. Numbers are compared rounded to
  #cmd("NUMERIC DIGITS"), at most 15 digits; #cmd("NUMERIC FUZZ 0") is
  accepted, and a #cmd("NUMERIC") instruction run by #cmd("INTERPRET")
  stays in force.
- Arguments are passed by value, and a term keeps its value across a later
  function call in the same clause. A built-in function never changes
  its argument in place.
- #cmd("RETURN") under #cmd("INTERPRET") returns from the routine.
  #cmd("2=2=2"), a lone #cmd("'.'") as a term, repeated prefix operators and
  a prefix #cmd("+") are accepted; #cmd("0**-1") is error 42.
- Words are separated by blanks only. A tab (#cmd("'05'X")) or a new-line
  character (#cmd("'15'X")) is an ordinary character in #cmd("PARSE"),
  #cmd("WORD"), #cmd("WORDS"), #cmd("SUBWORD"), the other word functions,
  #cmd("SPACE"), the #cmd("=") comparison and around numbers.
- #cmd("WITH") is a keyword of #cmd("PARSE VALUE") only. In #cmd("PARSE VAR"),
  #cmd("PULL") and the other templates it is a variable name now:
  #cmd("PARSE VAR x with y") no longer skips #cmd("with"); write
  #cmd("PARSE VAR x y").
- A #cmd("SELECT") with no true #cmd("WHEN") and no #cmd("OTHERWISE") is
  error 7.3. After a #cmd("CALL") of a routine that returns no value,
  #cmd("RESULT") is dropped, so that it keeps no value from an earlier call. A #cmd("PARSE") word target stops at the next
  trigger.
- #cmd("ARG(")#var("n")#cmd(")") beyond the arguments is the null string,
  also for #var("n") above 99.
- Integer results beyond 32 bits go on as real numbers instead of wrapping
  around. A number has at most 15 significant digits, whatever
  #cmd("NUMERIC DIGITS") says.
- A function or subroutine takes up to 32 arguments; the documentation of
  V2R5M3 gave 15. A 33rd is error 40 when the exec is compiled.

== Functions <ref-changes-functions>

#deflist(width: 1.4in,
  [#cmd("C2D"), #cmd("X2D")], [More than four significant bytes for
    #cmd("C2D"), and a value of more than eight digits for #cmd("X2D"), are
    error 40; they gave a wrapped number. #cmd("X2D(")#var("s")#cmd(",0)") is
    0.],
  [#cmd("FORMAT")], [Rounds to #cmd("NUMERIC DIGITS"): #cmd("FORMAT(1/3)")
    gave #cmd("0.8") and #cmd("FORMAT(12.34)") gave #cmd("12"). The
    arguments #var("expp") and #var("expt") have their standard meaning (1 and
    2 no longer select the C formats E and G); the old
    #cmd("FORMAT(x,2,n,2)") is #cmd("FORMAT(x,2,n,2,0)"). A #var("before")
    that is too small is error 40, not a wider result.],
  [#cmd("QUOTE")], [Takes a second argument, the kind of quote
    (@ext-kernel-quote).],
  [#cmd("DATE('GERMAN')")], [Gives #cmd("dd.mm.yy") (@lang-builtin-date).],
  [#cmd("ROUND")], [Rounds once, half away from zero, on the decimal digits
    (@ext-kernel-round). A small negative number gives #cmd("0.00"), not
    #cmd("-0.00").],
  [#cmd("SOUNDEX")], [Gives the codes of EBCDIC letters, not of ASCII ones.],
  [#cmd("DECRYPT")], [Gives back what #cmd("ENCRYPT") made of it.],
  [#cmd("TRUNC")], [Correct in the cases where it was not.],
  [#cmd("SYSDSN")], [Returns the messages of TSO/E, not only #cmd("OK") and
    #cmd("DATASET NOT FOUND") (@ext-tso-sysdsn).],
  [#cmd("PRIVILEGE")], [#cmd("PRIVILEGE('OFF')") returns 0 (@ext-tso-privilege).],
  [#cmd("CONSOLE")], [Returns 0 when the command was sent; it returned no
    value of its own, and what a caller saw was whatever was left in the
    result field.],
  [Arrays and lists], [#cmd("ISORT"), #cmd("SQSORT") and #cmd("SHSORT") with
    #cmd("'D'"), #cmd("SREVERSE") and #cmd("LL2STEM") return the count. An
    index out of range is error 40, not abend S0C4.],
  [#cmd("TCPWAIT")], [Reports one event per call, and a time-out under
    2 seconds is honoured.],
  [#cmd("MATCH")], [#cmd("[a-z]") takes the letters only.],
  [#cmd("RANDOM")], [Covers the whole of a range wider than 32768 (V2R5M3 did not).],
  [#cmd("DATETIME"), #cmd("SEC2TIME")], [#cmd("DATETIME") gives the output
    format that was asked for, not the input format. #cmd("SEC2TIME") keeps
    the hundreds of 100 hours or more.],
  [#cmd("DEFINED")], [Returns 2 for a variable with a numeric value (V2R5M3 returned 1).],
  [#cmd("WORDINS")], [Adds no trailing blank when it inserts after the last
    word.],
  [#cmd("VLIST"), #cmd("LISTVOL")], [#cmd("VLIST.0") counts the elements of a
    stem. #cmd("LISTVOL") works; it called a routine that did not exist.],
  [#cmd("FPOS"), #cmd("FCHANGESTR")], [Do not stop at #cmd("'00'X").],
  [#cmd("MTT"), #cmd("MTTX")], [Each keeps its own mark of the newest entry.],
  [#cmd("EXECIO")], [#cmd("FIFOW") and #cmd("LIFOW") with #cmd("STEM") queue
    the lines (they queued nothing). #cmd("n FIFOR") reads #var("n") lines,
    not #var("n")+1.],
)

== Input and Output <ref-changes-io>

- Stream I/O follows the REXX definition. A stream has a read position and
  a write position of its own; #cmd("LINEOUT(")#var("name")#cmd(")") writes
  nothing; the positions of #cmd("CHAROUT") count from 1; an implicit open
  never truncates; a stream opened for writing can be read back; after a
  failed operation #cmd("STREAM") reports #cmd("NOTREADY") (@lang-builtin-stream).
- #cmd("CHAROUT") and #cmd("LINEOUT") return the number of characters or
  lines *not* written, 0 when all went well. #cmd("CHAROUT") returned the
  length of the string.
- A record of an FB data set keeps its trailing blanks in #cmd("LINEIN"),
  #cmd("EXECIO DISKR") and #cmd("READ"), as in TSO/E. #cmd("STRIP(x,'T')")
  gives the old form. #cmd("SREAD") does the same, so a comparison of two
  data sets with different record lengths reports every line as changed.
- #cmd("EXECIO") with #cmd("SKIP") #var("n") and the stack skips the first
  #var("n") lines.
- Under the TSO terminal monitor program, #cmd("SAY"), #cmd("PULL") and
  the error messages go through TSO (_BREXX/370 User's Guide_, “Running REXX Programs”);
  #cmd("OUTTRAP") traps what commands write, and only that
  (@ext-tso-outtrap). The names of the standard streams are
  #cmd("<STDOUT>"), #cmd("<STDERR>") and #cmd("<STDIN>").
- Outside a TSO session a password-protected data set is refused; V2R5M3
  asked the operator for the password.

== Host Commands and Authorization <ref-changes-host>

- #cmd("ADDRESS") to an environment that does not exist answers
  return code -3, as TSO/E does, without a message (@ext-address).
- #cmd("ADDRESS COMMAND 'CP ...'") takes the authorization it needs
  itself. It no longer ends the task with abend S047 where the user has no
  right to it: it ends with return code -5 (@ext-address-command).
- #cmd("PRIVILEGE"), #cmd("CONSOLE"), #cmd("MTT"), #cmd("MTTX") and
  #cmd("ADDRESS CONSOLE") exist only for a user with READ access to the
  RAKF profile #cmd("SVC244"); #cmd("ADDRESS COMMAND") only for a user with
  READ access to #cmd("DIAG8CMD"). A call of a function that does not exist
  is error 43. A #cmd("PRIVILEGE('ON')") of the exec stays in effect after
  #cmd("CONSOLE"), #cmd("ADDRESS CONSOLE") and #cmd("SYSVAR('SYSCP')"), which
  used to switch it off. The _BREXX/370 User's Guide_ lists the profiles.
- BREXX/370 publishes no environment block, and has no #cmd("IRXEXCOM")
  (@ext-external). A program that an exec calls receives register 0 as
  zero.
- A member found
  in #cmd("SYSUPROC") or #cmd("SYSPROC") counts as REXX only when its first
  line is a comment containing #cmd("REXX").

== Removed <ref-changes-removed>

#cmd("PUTSMF") and the SMF type 242 records; the undocumented CLIST variable
pool (#cmd("VALUE(name,,'CLIST')") is error 40, as for any unknown pool);
#cmd("OPEN(...,'VIO')"); the routines #cmd("IRXISTAT") and #cmd("MVSDUMP");
and #cmd("IRXEXCOM"). A call of #cmd("PUTSMF") is error 51, as for any
function that does not exist.

== Renamed Members <ref-changes-renamed>

#idx("renamed members")#idx("SMP", "element names")#idx("LISTCATX")#idx("LISTALCX")#idx("PRINTX")
RXLIB and SAMPLIB are installed with SMP, and every member is an SMP
element. An element name belongs to the whole SYSMOD, and the CDS of
MVS 3.8j holds IBM elements with some of the names the libraries used
(JES2, DFSMS, TSO and the utilities). SMP must not replace those, so
release 3.0 gives the members below another name. The old names are gone.

#tab(caption: [RXLIB routines that changed their name])[
  #table(columns: (1.2in, 1.2in, 1fr),
    [V2R5M3], [3.0], [Why],
    [#cmd("LISTCAT")], [#cmd("LISTCATX")], [IBM element of the same name],
    [#cmd("LISTALC")], [#cmd("LISTALCX")], [IBM element of the same name],
    [#cmd("PRINT")], [#cmd("PRINTX")], [IBM element of the same name],
  )
]

These are real renames: the member and the file carry the new name, and
no alias is installed. An exec that calls #cmd("LISTCAT()"),
#cmd("LISTALC()") or #cmd("CALL PRINT") must be changed under release 3.0.
It does not end with error 43. As the routine is no longer in RXLIB,
BREXX/370 goes on to the load module of that name (@ext-external-fn), and
#cmd("LISTCAT"), #cmd("LISTALC") and #cmd("PRINT") are also IBM load
modules. They are called with the argument list of BREXX/370 and abend with
S0C4 (in the IBM modules #cmd("IDCSATO") for #cmd("LISTCAT()") and
#cmd("CALL PRINT"), #cmd("IKJPARS") for #cmd("LISTALC()")). BREXX/370
catches the abend, writes message #cmd("BRX0003E") and ends the exec with
return code 8. #cmd("SIGNAL ON SYNTAX") does not trap it, because it is an
abend and not a syntax condition. Only the routines of RXLIB
changed. The TSO commands #cmd("LISTCAT") and #cmd("LISTALC") keep their
names, so #cmd("ADDRESS TSO 'LISTCAT LEVEL(x)'") is as before, and so is
a label #cmd("Print:") inside an exec. The TSO command #cmd("LA") calls
#cmd("LISTALCX") now.

Eight samples are installed under another name than their V2R5M3 name.
The reason is an IBM element of the same name, except for JESQUEUE, which
has the name of an RXLIB routine, and a name is allowed once in a SYSMOD.
The change concerns the installed library only; the source files keep
their names.

#tab(caption: [Samples that changed their name])[
  #table(columns: (1.2in, 1.2in, 1fr),
    [V2R5M3], [3.0], [Why],
    [#cmd("LOCATE")], [#cmd("LOCDSN")], [IBM element of the same name],
    [#cmd("LISTALC")], [#cmd("LISTALCS")], [IBM element of the same name],
    [#cmd("CONSOLE")], [#cmd("CONSOLET")], [IBM element of the same name],
    [#cmd("CODE")], [#cmd("CODEFILE")], [IBM element of the same name],
    [#cmd("JES2")], [#cmd("JES2SPL")], [IBM element of the same name],
    [#cmd("$WAIT")], [#cmd("WAITDEMO")], [IBM element of the same name],
    [#cmd("$WTO")], [#cmd("WTODEMO")], [IBM element of the same name],
    [#cmd("JESQUEUE")], [#cmd("JESQMENU")],
      [the name of the RXLIB routine JESQUEUE],
  )
]

The member #cmd("BUILD") of RXLIB and of the samples is not installed.
It was a note on the last synchronisation of the libraries with the source
repository, not a routine, and no exec called it. The _BREXX/370 Library
and Samples_ describes the routines and the samples under their new names.

== RXLIB <ref-changes-rxlib>

The RXLIB routines #cmd("STDATE") and #cmd("FMTBANNR") returned to their
caller; they ended it with #cmd("EXIT") before. The _BREXX/370 Library and
Samples_ describes the routines.
