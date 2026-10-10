#import "../bookmaster/bookmaster.typ": *

= Built-in Functions <lang-builtin>

#idx("built-in function")
A built-in function is called as a function,
#var("name")#cmd("(")#var("arguments")#cmd(")"), or with #cmd("CALL"),
which puts its value into #cmd("RESULT") (@lang-instr-call). Up to 32
arguments may be given. Where an argument is an option, only its first
letter counts and case does not matter, unless the entry says otherwise.
A call with a wrong number of arguments, or with an argument out of
range, ends in error 40 (_Incorrect call to routine_).

The functions are grouped as in the old _BREXX/370 User's Guide_: REXX
functions, strings, words, arithmetic, conversion and streams. All of
them are part of the interpreter; none is written in REXX. The functions
#cmd("CEIL"), #cmd("FLOOR"), #cmd("ROUND"), #cmd("D2P"), #cmd("P2D") and
#cmd("FILTER") are built in the same way and are described with the
other BREXX additions in @ext-kernel.

== REXX Functions <lang-builtin-rexx>

=== ADDR <lang-builtin-addr>

#idx("ADDR")
```
ADDR(symbol [, [option] [, pool]])
```
Returns the storage address of variable #var("symbol") as a decimal
number, or #cmd("-1") if the variable does not exist. #var("pool") is a
procedure level, from #cmd("0") (the main program) to the current one;
without it, the current level is searched.

#deflist(width: 1.2in,
  [#cmd("D")], [Data: the address of the value (the default).],
  [#cmd("L")], [Lstring: the address of the interpreter's string
    structure that holds the value.],
  [#cmd("V")], [Variable: the address of the variable's entry in the
    variable tree.],
)

A value that the interpreter holds as a number is stored in binary, not
as characters. #cmd("STORAGE") takes a hexadecimal address, so convert
the result with #cmd("D2X") (@lang-builtin-storage).

```
i = 5
SAY addr('i')            /* e.g. 2895880 */
SAY addr('i','V',0)      /* e.g. 2893312 */
SAY addr('j')            /* -1: no variable J */
```

=== ADDRESS <lang-builtin-address>

#idx("ADDRESS")
```
ADDRESS()
```
Returns the name of the current host command environment. If none has
been set, the result is #cmd("MVS").

```
SAY address()            /* e.g. MVS */
```

=== ARG <lang-builtin-arg>

#idx("ARG")
```
ARG([n [, option]])
```
Without arguments, returns the number of arguments passed to the exec or
routine. #cmd("ARG(")#var("n")#cmd(")") returns the #var("n")th
argument, or the null string if it was omitted or not passed;
#var("n") must be 1 or more. With #var("option"), returns #cmd("1") or
#cmd("0"):

#deflist(width: 1.2in,
  [#cmd("E")], [Exists: #cmd("1") if the #var("n")th argument was given.],
  [#cmd("O")], [Omitted: #cmd("1") if it was not.],
)

```
CALL myproc 'a',,2
...
myproc:
SAY arg()                /* 3 */
SAY arg(1)               /* a */
SAY arg(2,'O')           /* 1 */
SAY arg(2,'E')           /* 0 */
```

=== CONDITION <lang-builtin-condition>

#idx("CONDITION")
```
CONDITION([option])
```
Returns information about the condition trap that was taken last. Before
any condition has been trapped, every option returns the null string.
The condition name and its description are kept in 64 characters.

#deflist(width: 1.2in,
  [#cmd("C")], [Condition name, for example #cmd("ERROR") or
    #cmd("NOVALUE").],
  [#cmd("D")], [Description: the text that came with the condition, such
    as the command that raised #cmd("ERROR") or the variable that raised
    #cmd("NOVALUE").],
  [#cmd("I")], [Instruction: #cmd("CALL") or #cmd("SIGNAL"), the way the
    trap was taken (the default).],
  [#cmd("S")], [State of the trap now: #cmd("ON"), #cmd("OFF") or
    #cmd("DELAY").],
)

```
SIGNAL ON NOVALUE
SAY undefined
EXIT
novalue:
SAY condition('C') condition('I')   /* NOVALUE SIGNAL */
```

An option that is not one of these is not an error: #cmd("CONDITION")
returns the null string for it.

=== DATATYPE <lang-builtin-datatype>

#idx("DATATYPE")
```
DATATYPE(string [, type])
```
Without #var("type"), returns #cmd("NUM") if #var("string") is a valid
REXX number and #cmd("CHAR") otherwise. With #var("type"), returns
#cmd("1") if #var("string") is of that type and #cmd("0") if not:

#deflist(width: 1.2in,
  [#cmd("A")], [Alphanumeric: only letters and digits.],
  [#cmd("B")], [Binary: only #cmd("0") and #cmd("1"); blanks only
    between groups of four digits.],
  [#cmd("L")], [Lowercase: only #cmd("a") to #cmd("z").],
  [#cmd("M")], [Mixed case: only letters.],
  [#cmd("N")], [Number: a valid REXX number.],
  [#cmd("S")], [Symbol: only letters, digits and #cmd("@#$_.?!").],
  [#cmd("U")], [Uppercase: only #cmd("A") to #cmd("Z").],
  [#cmd("W")], [Whole number.],
  [#cmd("X")], [Hexadecimal: only #cmd("0")-#cmd("9"),
    #cmd("A")-#cmd("F") and #cmd("a")-#cmd("f"); blanks only between
    pairs of digits.],
  [#cmd("T")], [Type, a BREXX extension: returns how the value is held,
    #cmd("INTEGER"), #cmd("REAL") or #cmd("STRING").],
)

The null string is a valid #cmd("B") and #cmd("X") string and of no
other type. An unknown #var("type") returns #cmd("-1"), where TSO/E REXX
ends with an error.

```
SAY datatype('123')            /* NUM */
SAY datatype('21a')            /* CHAR */
SAY datatype('0100 1001','B')  /* 1 */
i = 5
SAY datatype(i,'T')            /* e.g. INTEGER */
```

=== DATE <lang-builtin-date>

#idx("DATE")
```
DATE([format [, date [, input-format]]])
```
Returns today's date, or #var("date"), in the form that #var("format")
asks for. Without #var("format"), or with a null one, the result is
#cmd("XEUROPEAN"), #cmd("dd/mm/yyyy") -- not #cmd("dd Mon yyyy") as in
TSO/E REXX. #cmd("OPTIONS('DATE',")#var("name")#cmd(")") changes this
default to #cmd("XEUROPEAN"), #cmd("EUROPEAN"), #cmd("XGERMAN"),
#cmd("GERMAN"), #cmd("XUSA") or #cmd("USA").

#var("format") is matched by its first letters, and some formats need
more than one: the capitals in the list show how many. The examples are
for Thursday, 8 October 2026.

#deflist(width: 1.2in,
  [#cmd("Base")], [Days since 1 January 0001.],
  [#cmd("Century")], [Days since 1 January of the year #var("xx")#cmd("00"),
    counting today.],
  [#cmd("Days")], [Days in this year, counting today: #cmd("281").],
  [#cmd("DEC")], [#cmd("08-OCT-26").],
  [#cmd("European")], [#cmd("08/10/26").],
  [#cmd("GERman")], [#cmd("08.10.26"), #cmd("dd.mm.yy"). The name
    needs at least #cmd("GER")\; #cmd("G") alone is error 40.],
  [#cmd("International")], [#cmd("2026-10-08").],
  [#cmd("JDN")], [Julian Day Number: days since 24 November 4714 BC.],
  [#cmd("Julian")], [#cmd("2026281"), #cmd("yyyyddd") (TSO/E:
    #cmd("yyddd")).],
  [#cmd("Long")], [#cmd("08 October 2026").],
  [#cmd("Month")], [#cmd("October").],
  [#cmd("Normal")], [#cmd("8 Oct 2026"), the day without a leading zero,
    as in TSO/E.],
  [#cmd("Ordered")], [#cmd("2026/10/08") (TSO/E: #cmd("yy/mm/dd")).],
  [#cmd("Qualified")], [#cmd("Thursday, October 08, 2026").],
  [#cmd("SHort")], [#cmd("08 Oct 2026").],
  [#cmd("Standard")], [#cmd("20261008"). #cmd("Sorted") gives the
    same.],
  [#cmd("Time")], [Seconds from 1 January 1970 to the start of the day.],
  [#cmd("USA")], [#cmd("10/08/26").],
  [#cmd("UNix")], [Days since 1 January 1970.],
  [#cmd("Weekday")], [#cmd("Thursday").],
  [#cmd("XDEc")], [#cmd("08-OCT-2026").],
  [#cmd("XEuropean")], [#cmd("08/10/2026").],
  [#cmd("XGerman")], [#cmd("08.10.2026").],
  [#cmd("XUsa")], [#cmd("10/08/2026").],
  [#cmd("YEar")], [#cmd("2026").],
)

With #var("date"), the function converts a date: #var("input-format")
says how #var("date") is written and must then be given (error 40.45
otherwise). The input formats are #cmd("Base"), #cmd("JDN"),
#cmd("UNix"), #cmd("Time"), #cmd("Julian"), #cmd("Standard"),
#cmd("Ordered"), #cmd("International"), #cmd("European"),
#cmd("XEuropean"), #cmd("German"), #cmd("USA"), #cmd("XUsa"),
#cmd("DEC"), #cmd("XDEc"), #cmd("Normal"), #cmd("SHort"), #cmd("Long")
and #cmd("Qualified"). A month may be given by name, of which the first
three letters count. In an #cmd("European"), #cmd("USA") or
#cmd("DEC") date, a two-digit year up to the last two digits of the
current year is taken as #cmd("20")#var("yy"), a larger one as
#cmd("19")#var("yy").

```
SAY date()                      /* 08/10/2026 */
SAY date('N')                   /* 8 Oct 2026 */
SAY date('W','20261224','S')    /* Thursday */
SAY date('S','24/12/26','E')    /* 20261224 */
```

=== DESBUF <lang-builtin-desbuf>

#idx("DESBUF")
```
DESBUF()
```
Deletes all buffers of the data stack, with their lines, and returns the
number of lines deleted. In TSO/E, #cmd("DESBUF") is a command, not a
function.

```
PUSH 'hello'
CALL desbuf              /* stack is empty, RESULT is 1 */
```

=== DIGITS <lang-builtin-digits>

#idx("DIGITS")
```
DIGITS()
```
Returns the current setting of #cmd("NUMERIC DIGITS").

=== DROPBUF <lang-builtin-dropbuf>

#idx("DROPBUF")
```
DROPBUF([n])
```
Deletes the #var("n") most recent buffers of the data stack (default 1)
with their lines, and returns the number of lines deleted. When only the
first buffer is left, its lines are deleted and the buffer stays.
#cmd("DROPBUF(0)") deletes nothing and returns the number of lines in
the most recent buffer. In TSO/E, #cmd("DROPBUF") is a command.

```
PUSH 'in buffer 1'
CALL makebuf
PUSH 'in buffer 2'
CALL dropbuf             /* RESULT is 1, one buffer remains */
```

=== ERRORTEXT <lang-builtin-errortext>

#idx("ERRORTEXT")
```
ERRORTEXT(n)
```
Returns the message text of REXX error #var("n").

```
SAY errortext(8)         /* Unexpected THEN or ELSE */
```

=== FORM <lang-builtin-form>

#idx("FORM")
```
FORM()
```
Returns the current setting of #cmd("NUMERIC FORM"):
#cmd("SCIENTIFIC") or #cmd("ENGINEERING").

=== FUZZ <lang-builtin-fuzz>

#idx("FUZZ")
```
FUZZ()
```
Returns the current setting of #cmd("NUMERIC FUZZ").

=== HASHVALUE <lang-builtin-hashvalue>

#idx("HASHVALUE")
```
HASHVALUE(string)
```
Returns an integer hash of #var("string"), computed as Java computes
one for a string: #cmd("h = 31*h + c") for each character #var("c"), over
at most the first 255 characters. The characters are EBCDIC, so the
value differs from the one an ASCII system gives.

```
SAY hashvalue('monday')  /* an integer, the same on every call */
```

=== IMPORT <lang-builtin-import>

#idx("IMPORT")#idx("LOAD")
```
IMPORT(name)
LOAD(name)
```
Loads the REXX exec #var("name") as a library: it is found as an
external exec is found, compiled and added to the running program, so
that its routines can be called. #cmd("LOAD") is the same function.
Returns:

#deflist(width: 1.2in,
  [#cmd("-1")], [The exec was already loaded.],
  [#cmd("0")], [It was loaded.],
  [#cmd("1")], [It could not be loaded.],
)

```
CALL import 'MYLIB'
```

=== MAKEBUF <lang-builtin-makebuf>

#idx("MAKEBUF")
```
MAKEBUF()
```
Creates a new buffer on the data stack and returns the number of
buffers, the first one included. In TSO/E, #cmd("MAKEBUF") is a command.

```
PUSH 'hello'
SAY queued() queued('T')   /* 1 1 */
CALL makebuf               /* RESULT is 2 */
PUSH 'aloha'
SAY queued() queued('T')   /* 2 1 */
```

=== QUEUED <lang-builtin-queued>

#idx("QUEUED")
```
QUEUED([option])
```
Returns the number of lines on the data stack. The option is a BREXX
extension:

#deflist(width: 1.2in,
  [#cmd("A")], [All: lines in all buffers (the default).],
  [#cmd("B")], [Buffers: the number of buffers.],
  [#cmd("T")], [Top: lines in the most recent buffer.],
)

```
PUSH 'hi'
SAY queued('A') queued('B') queued('T')   /* 1 1 1 */
CALL makebuf
SAY queued('A') queued('B') queued('T')   /* 1 2 0 */
PUSH 'hello'
SAY queued('A') queued('B') queued('T')   /* 2 2 1 */
CALL desbuf
SAY queued('A') queued('B') queued('T')   /* 0 1 0 */
```

=== SOUNDEX <lang-builtin-soundex>

#idx("SOUNDEX")
```
SOUNDEX(word)
```
Returns the four-character Soundex code of #var("word"), a letter and
three digits, for phonetic comparison. At most the first 20 characters
are used, and characters that are not letters are skipped. An initial
#cmd("K") is coded as #cmd("C"), an initial #cmd("PH") as #cmd("F").

```
SAY soundex('monday')    /* M530 */
SAY soundex('Mandei')    /* M530 */
```

=== SOURCELINE <lang-builtin-sourceline>

#idx("SOURCELINE")
```
SOURCELINE([n])
```
Without an argument, returns the number of lines of the exec; otherwise
line #var("n").

```
SAY sourceline()         /* e.g. 100 */
SAY sourceline(1)        /* the first line */
```

=== STORAGE <lang-builtin-storage>

#idx("STORAGE")
```
STORAGE([address [, [length] [, data]]])
```
Returns #var("length") bytes (default 1) of storage starting at
#var("address"), a hexadecimal number. Only the low 24 bits of the
address are used. With #var("data"), the storage at #var("address") is
then overwritten with #var("data"), whatever its length; the result is
still the old content. Without arguments, #cmd("STORAGE") returns
#cmd("0").

```
a = 'Hello'
SAY storage(d2x(addr('a')),5,'aaa')   /* Hello */
SAY a                                 /* aaalo */
SAY c2x(storage(10,4))                /* the address of the CVT */
```

=== SYMBOL <lang-builtin-symbol>

#idx("SYMBOL")
```
SYMBOL(name)
```
Returns #cmd("BAD") if #var("name") contains a character that is not
valid in a symbol, #cmd("VAR") if it is the name of a variable that has
a value, and #cmd("LIT") otherwise.

```
i = 5
SAY symbol('i')          /* VAR */
SAY symbol(i)            /* LIT */
SAY symbol(':asd')       /* BAD */
```

=== TIME <lang-builtin-time>

#idx("TIME")
```
TIME([option])
```
Returns the local time of day as #cmd("hh:mm:ss"), or in the form that
#var("option") asks for. #cmd("MS"), #cmd("US"), #cmd("CPU"), #cmd("HS")
and #cmd("LS") are matched as whole words; the other options by their
first letter.

#deflist(width: 1.2in,
  [#cmd("C")], [Civil: #cmd("3:07pm").],
  [#cmd("E")], [Elapsed: seconds and microseconds since the interpreter
    started or since the last #cmd("TIME('R')"), #cmd("s.uuuuuu"). In
    TSO/E, the first #cmd("TIME('E')") starts the clock.],
  [#cmd("H")], [Hours since midnight.],
  [#cmd("L")], [Long: #cmd("hh:mm:ss.uuuuuu").],
  [#cmd("M")], [Minutes since midnight.],
  [#cmd("N")], [Normal: #cmd("hh:mm:ss") (the default).],
  [#cmd("R")], [Reset: as #cmd("E"), then restarts the clock.],
  [#cmd("S")], [Seconds since midnight.],
  [#cmd("U")], [Unix time: seconds since 1 January 1970.],
  [#cmd("MS")], [Seconds since midnight with milliseconds,
    #cmd("s.mmm").],
  [#cmd("US")], [Seconds since midnight with microseconds,
    #cmd("s.uuuuuu").],
  [#cmd("HS")], [Hundredths of a second since midnight.],
  [#cmd("LS")], [Seconds since midnight in five digits, followed by six
    digits of microseconds, without a point.],
  [#cmd("CPU")], [CPU time used, in seconds with three decimals.],
)

The options from #cmd("U") on are BREXX extensions.

```
SAY time()               /* 15:07:42 */
SAY time('C')            /* 3:07pm */
CALL time 'R'
...
SAY time('E')            /* e.g. 2.034561 */
```

=== TRACE <lang-builtin-trace>

#idx("TRACE")
```
TRACE([option])
```
Returns the current trace setting, a letter preceded by #cmd("?") while
interactive tracing is on. With #var("option"), the trace is then set as
the #cmd("TRACE") instruction sets it (@lang-instr-trace).

```
SAY trace()              /* N */
old = trace('R')
```

=== VALUE <lang-builtin-value>

#idx("VALUE")
```
VALUE(name [, [newvalue] [, pool]])
```
Returns the value of the variable #var("name"). With #var("newvalue"),
the variable is then set to it. #var("pool") selects the variables of
another routine level: #cmd("0") is the main program, and each nested
routine call one more; a negative number counts back from the current
level. Any other #var("pool") ends in error 40.37: BREXX/370 has no
named pools, and #var("pool") is not the selector of TSO/E REXX.

```
i = 5
j = 'i'
SAY value(j)             /* 5 */
SAY value('j',10)        /* i */
SAY j                    /* 10 */
CALL proc
EXIT
proc: PROCEDURE
i = 'I-var'
SAY value('i')           /* I-var */
SAY value('i',,0)        /* 5 */
SAY value('i',,-1)       /* 5 */
RETURN
```

=== VARDUMP <lang-builtin-vardump>

#idx("VARDUMP")
```
VARDUMP([symbol] [, option])
```
Returns the variables of the current routine level, one per line, as
#var("NAME")#cmd("=\"")#var("value")#cmd("\""). With #var("symbol"),
only that variable, or all variables of the stem #var("symbol"). A
symbol that is not a variable returns the null string.

#deflist(width: 1.2in,
  [#cmd("D")], [Depth: each line begins with the variable's depth in the
    variable tree.],
  [#cmd("H")], [Hexadecimal: the value is written in hexadecimal,
    #var("NAME")#cmd("=\"C1C2\"x"). #cmd("X") is the same.],
)

```
a = 'AB'
SAY vardump('a')         /* A="AB" */
SAY vardump('a','H')     /* A="C1C2"x */
```

== String Functions <lang-builtin-string>

=== ABBREV <lang-builtin-abbrev>

#idx("ABBREV")
```
ABBREV(information, info [, length])
```
Returns #cmd("1") if #var("info") is equal to the beginning of
#var("information") and at least #var("length") characters long
(default: the length of #var("info")), else #cmd("0").

```
SAY abbrev('PRINT','PRI')     /* 1 */
SAY abbrev('PRINT','PRI',4)   /* 0 */
SAY abbrev('PRINT','PRX')     /* 0 */
```

=== CENTRE <lang-builtin-centre>

#idx("CENTRE")#idx("CENTER")
```
CENTRE(string, length [, pad])
CENTER(string, length [, pad])
```
Returns #var("string") centred in a string of #var("length")
characters, padded with #var("pad") (default blank) or truncated on both
sides.

```
SAY center('rexx',2)          /* ex */
SAY center('rexx',8,'-')      /* --rexx-- */
```

=== CHANGESTR <lang-builtin-changestr>

#idx("CHANGESTR")
```
CHANGESTR(target, string, replace)
```
Returns #var("string") with every occurrence of #var("target") replaced
by #var("replace").

```
SAY changestr('aa','aabbccaabbccaa','--')   /* --bbcc--bbcc-- */
```

=== COMPARE <lang-builtin-compare>

#idx("COMPARE")
```
COMPARE(string1, string2 [, pad])
```
Returns #cmd("0") if the strings are equal, else the position of the
first character that differs. The shorter string is padded with
#var("pad") (default blank).

```
SAY compare('bill','bill')    /* 0 */
SAY compare('bill','big')     /* 3 */
SAY compare('bi ','bi')       /* 0 */
SAY compare('bi--*','bi','-') /* 5 */
```

=== COPIES <lang-builtin-copies>

#idx("COPIES")
```
COPIES(string, n)
```
Returns #var("n") copies of #var("string") concatenated.

```
SAY copies('Vivi',3)          /* ViviViviVivi */
```

=== COUNTSTR <lang-builtin-countstr>

#idx("COUNTSTR")
```
COUNTSTR(target, string)
```
Returns the number of occurrences of #var("target") in #var("string").

```
SAY countstr('aa','aabbccaabbccaa')   /* 3 */
```

=== DELSTR <lang-builtin-delstr>

#idx("DELSTR")
```
DELSTR(string, n [, length])
```
Returns #var("string") with #var("length") characters deleted from
position #var("n") on; without #var("length"), the rest of the string.

```
SAY delstr('bill',3)          /* bi */
SAY delstr('bill',2,2)        /* bl */
```

=== INDEX <lang-builtin-index>

#idx("INDEX")
```
INDEX(haystack, needle [, start])
```
Returns the position of #var("needle") in #var("haystack"), searching
from position #var("start") (default 1), or #cmd("0"). The first two
arguments are in the opposite order to those of #cmd("POS").

```
SAY index('bilil','il')       /* 2 */
SAY index('bilil','il',3)     /* 4 */
```

=== INSERT <lang-builtin-insert>

#idx("INSERT")
```
INSERT(new, target [, [n] [, [length] [, pad]]])
```
Inserts #var("new"), padded with #var("pad") (default blank) or
truncated to #var("length"), into #var("target") after character
#var("n") (default 0: at the front).

```
SAY insert('.','BNV',2)       /* BN.V */
SAY insert('.','BNV',2,2)     /* BN. V */
SAY insert('','BNV',2,2,'.')  /* BN..V */
```

=== LASTPOS <lang-builtin-lastpos>

#idx("LASTPOS")
```
LASTPOS(needle, haystack [, start])
```
Returns the position of the last occurrence of #var("needle") in
#var("haystack"), or #cmd("0"). With #var("start"), only the first
#var("start") characters of #var("haystack") are searched.

```
SAY lastpos('il','bilil')     /* 4 */
SAY lastpos('il','bilil',4)   /* 2 */
```

=== LEFT <lang-builtin-left>

#idx("LEFT")
```
LEFT(string, length [, pad])
```
Returns the first #var("length") characters of #var("string"), padded on
the right with #var("pad") (default blank).

```
SAY left('Hello',2)           /* He */
SAY left('Hello',10,'.')      /* Hello..... */
```

=== LENGTH <lang-builtin-length>

#idx("LENGTH")
```
LENGTH(string)
```
Returns the number of characters in #var("string").

```
SAY length('Hello')           /* 5 */
```

=== OVERLAY <lang-builtin-overlay>

#idx("OVERLAY")
```
OVERLAY(new, target [, [n] [, [length] [, pad]]])
```
Overlays #var("target"), from position #var("n") (default 1), with
#var("new") padded or truncated to #var("length"). If #var("n") lies
beyond the end of #var("target"), #var("target") is first padded with
#var("pad") (default blank).

```
SAY overlay('.','abcd',2)         /* a.cd */
SAY overlay('.','abcd')           /* .bcd */
SAY overlay('.','abcd',6,3,'+')   /* abcd+.++ */
```

=== POS <lang-builtin-pos>

#idx("POS")
```
POS(needle, haystack [, start])
```
Returns the position of #var("needle") in #var("haystack"), searching
from position #var("start") (default 1), or #cmd("0").

```
SAY pos('ll','Bill')          /* 3 */
```

=== REVERSE <lang-builtin-reverse>

#idx("REVERSE")
```
REVERSE(string)
```
Returns #var("string") end to end.

```
SAY reverse('Bill')           /* lliB */
```

=== RIGHT <lang-builtin-right>

#idx("RIGHT")
```
RIGHT(string, length [, pad])
```
Returns the last #var("length") characters of #var("string"), padded on
the left with #var("pad") (default blank).

```
SAY right('abcde',2)          /* de */
SAY right('7',3,'0')          /* 007 */
```

=== STRIP <lang-builtin-strip>

#idx("STRIP")
```
STRIP(string [, [option] [, char]])
```
Returns #var("string") without its leading, trailing, or leading and
trailing #var("char") characters (default blank).

#deflist(width: 1.2in,
  [#cmd("B")], [Both (the default).],
  [#cmd("L")], [Leading.],
  [#cmd("T")], [Trailing.],
)

```
SAY strip(' abc ')            /* 'abc' */
SAY strip(' abc ','T')        /* ' abc' */
SAY strip('-abc--',,'-')      /* 'abc' */
```

=== SUBSTR <lang-builtin-substr>

#idx("SUBSTR")
```
SUBSTR(string, n [, [length] [, pad]])
```
Returns #var("length") characters of #var("string") from position
#var("n") on (default: the rest), padded with #var("pad") (default
blank) where #var("string") ends.

```
SAY substr('abcde',2,2)       /* bc */
SAY substr('abcde',2)         /* bcde */
SAY substr('abcde',4,3,'-')   /* de- */
```

=== TRANSLATE <lang-builtin-translate>

#idx("TRANSLATE")
```
TRANSLATE(string [, [tableo] [, [tablei] [, pad]]])
```
Returns #var("string") with each character that occurs in #var("tablei")
replaced by the character at the same position in #var("tableo"), which
is padded with #var("pad") (default blank). With #var("string") alone,
translates it to uppercase.

```
SAY translate('abc')             /* ABC */
SAY translate('aabc','-','a')    /* --bc */
SAY translate('aabc','-+','ab')  /* --+c */
```

=== VERIFY <lang-builtin-verify>

#idx("VERIFY")
```
VERIFY(string, reference [, [option] [, start]])
```
Returns the position of the first character of #var("string"), from
position #var("start") (default 1) on, that is not in #var("reference"),
or #cmd("0") if there is none. With option #cmd("M") (Match), the
position of the first character that is in #var("reference");
#cmd("N") (Nomatch) is the default.

```
SAY verify('abc','abcdef')       /* 0 */
SAY verify('a0c','abcdef')       /* 2 */
SAY verify('12a','abcdef','M')   /* 3 */
```

=== XRANGE <lang-builtin-xrange>

#idx("XRANGE")
```
XRANGE([start] [, end])
```
Returns all characters from #var("start") (default #cmd("'00'x")) to
#var("end") (default #cmd("'FF'x")), in the order of their codes; if
#var("start") is greater than #var("end"), the range wraps from
#cmd("'FF'x") to #cmd("'00'x"). The codes are EBCDIC: the letters
#cmd("A") to #cmd("Z") are not contiguous, and #cmd("XRANGE('A','Z')")
is 41 characters long.

```
SAY xrange('a','e')              /* abcde */
SAY c2x(xrange('FE'x,'02'x))     /* FEFF000102 */
SAY length(xrange('A','Z'))      /* 41 */
```

== Word Functions <lang-builtin-word>

A word is a sequence of characters other than blanks; words are
separated by one or more blanks.

=== DELWORD <lang-builtin-delword>

#idx("DELWORD")
```
DELWORD(string, n [, length])
```
Returns #var("string") with #var("length") words deleted from word
#var("n") on; without #var("length"), the rest of the string.

```
SAY delword('one day in the year',3)     /* 'one day ' */
SAY delword('one day in the year',3,2)   /* one day year */
```

=== FIND <lang-builtin-find>

#idx("FIND")
```
FIND(string, phrase [, start])
```
Returns the number of the word in #var("string") at which the words of
#var("phrase") begin, searching from word #var("start") (default 1), or
#cmd("0") if #var("phrase") is not found. #cmd("WORDPOS") is the same
search with the first two arguments in the standard order.

```
SAY find('one day in the year','in the')   /* 3 */
```

=== JUSTIFY <lang-builtin-justify>

#idx("JUSTIFY")
```
JUSTIFY(string, length [, pad])
```
Returns the words of #var("string") spread to fill #var("length")
characters exactly, by adding #var("pad") characters (default blank)
between the words. If the words are longer than #var("length"), the
result is truncated.

```
SAY justify('one day in the year',22)   /* one  day  in  the year */
```

=== SPACE <lang-builtin-space>

#idx("SPACE")
```
SPACE(string [, [n] [, pad]])
```
Returns the words of #var("string") with #var("n") #var("pad")
characters (default 1 blank) between each two words, and no leading or
trailing blanks.

```
SAY space('one  day   in the year')     /* one day in the year */
SAY space('one day in the year',2)      /* one  day  in  the  year */
SAY space('one day',1,'-')              /* one-day */
```

=== SUBWORD <lang-builtin-subword>

#idx("SUBWORD")
```
SUBWORD(string, n [, length])
```
Returns #var("length") words of #var("string") from word #var("n") on;
without #var("length"), the rest of the string.

```
SAY subword('one day in the year',2,2)   /* day in */
```

=== WORD <lang-builtin-word-fn>

#idx("WORD")
```
WORD(string, n)
```
Returns word #var("n") of #var("string"), or the null string if there is
none.

```
SAY word('one day in the year',2)        /* day */
```

=== WORDINDEX <lang-builtin-wordindex>

#idx("WORDINDEX")
```
WORDINDEX(string, n)
```
Returns the character position at which word #var("n") of
#var("string") begins, or #cmd("0").

```
SAY wordindex('one day in the year',2)   /* 5 */
```

=== WORDLENGTH <lang-builtin-wordlength>

#idx("WORDLENGTH")
```
WORDLENGTH(string, n)
```
Returns the length of word #var("n") of #var("string"), or #cmd("0").

```
SAY wordlength('one day in the year',2)  /* 3 */
```

=== WORDPOS <lang-builtin-wordpos>

#idx("WORDPOS")
```
WORDPOS(phrase, string [, start])
```
Returns the number of the word in #var("string") at which the words of
#var("phrase") begin, searching from word #var("start") (default 1), or
#cmd("0") if #var("phrase") is not found.

```
SAY wordpos('day in','one day in the year')   /* 2 */
```

=== WORDS <lang-builtin-words>

#idx("WORDS")
```
WORDS(string)
```
Returns the number of words in #var("string").

```
SAY words('One day in the year')         /* 5 */
```

== Arithmetic Functions <lang-builtin-math>

=== ABS <lang-builtin-abs>

#idx("ABS")
```
ABS(number)
```
Returns the absolute value of #var("number").

```
SAY abs(-2.3)            /* 2.3 */
```

=== FORMAT <lang-builtin-format>

#idx("FORMAT")
```
FORMAT(number [, [before] [, [after] [, [expp] [, expt]]]])
```
Rounds and formats #var("number") as TSO/E REXX does. The number is first
rounded to #cmd("NUMERIC DIGITS"), as though #var("number")#cmd("+0")
had been computed; with #var("number") alone, that is the result.
#cmd("FORMAT") keeps the digits that the REXX standard keeps:
#cmd("FORMAT('12.3400')") is #cmd("12.3400"), while BREXX arithmetic
(#cmd("'12.3400'+0")) gives #cmd("12.34").

#var("before") and #var("after") are the number of characters for the
integer part, sign included, and for the decimal part; omitted, as many
as are needed. If #var("before") is too small, error 40 results; a
larger #var("before") pads with blanks on the left. The number is
rounded, or extended with zeros, to #var("after") decimal places;
#cmd("0") rounds to a whole number.

#var("expp") is the number of places for the exponent, #var("expt") the
trigger for exponential notation (default #cmd("NUMERIC DIGITS")): it is
used when the integer part needs more than #var("expt") places or the
decimal part more than twice #var("expt"). #var("expt") #cmd("0") always
uses exponential notation, #var("expp") #cmd("0") never. An exponent of
0 is not shown, or is shown as #var("expp")+2 blanks when #var("expp")
is given. Under #cmd("NUMERIC FORM ENGINEERING") the exponent is a
multiple of 3.

```
SAY format(2.66)                 /* 2.66 */
SAY format(2.66,1,1)             /* 2.7 */
SAY format('-.76',4,1)           /* '  -0.8' */
SAY format('12345.73',,,2,2)     /* 1.234573E+04 */
SAY format('12345.73',,3,,0)     /* 1.235E+4 */
SAY format(26.6,1,1,2,0)         /* 2.7E+01 */
```

#note[Before release 3.0.0, #var("expp") 1 and 2 selected the C formats
#cmd("G") and #cmd("E") and #var("expt") was ignored. The old
#cmd("FORMAT(x,2,n,2)") is #cmd("FORMAT(x,2,n,2,0)") now.]

=== IAND <lang-builtin-iand>

#idx("IAND")
```
IAND(n, m [, m] ...)
```
Returns the bitwise AND of the whole numbers #var("n") and #var("m"),
taken as 32-bit integers. More than two arguments, a BREXX extension,
are combined from left to right.

```
SAY iand(2,3)            /* 2 */
SAY iand(7,6,3)          /* 2 */
```

=== INOT <lang-builtin-inot>

#idx("INOT")
```
INOT(n)
```
Returns the bitwise complement of the whole number #var("n").

```
SAY inot(2)              /* -3 */
```

=== IOR <lang-builtin-ior>

#idx("IOR")
```
IOR(n, m [, m] ...)
```
As #cmd("IAND"), with OR.

```
SAY ior(2,3)             /* 3 */
SAY ior(1,2,4)           /* 7 */
```

=== IXOR <lang-builtin-ixor>

#idx("IXOR")
```
IXOR(n, m [, m] ...)
```
As #cmd("IAND"), with exclusive OR.

```
SAY ixor(2,3)            /* 1 */
```

=== MAX <lang-builtin-max>

#idx("MAX")
```
MAX(number [, number] ...)
```
Returns the largest of the numbers.

```
SAY max(2,3,1,5)         /* 5 */
```

=== MIN <lang-builtin-min>

#idx("MIN")
```
MIN(number [, number] ...)
```
Returns the smallest of the numbers.

```
SAY min(2,3,1,5)         /* 1 */
```

=== RANDOM <lang-builtin-random>

#idx("RANDOM")
```
RANDOM([min] [, [max] [, seed]])
```
Returns a pseudo-random whole number from #var("min") (default 0) to
#var("max") (default 999), both included; neither may be negative.
#var("seed") starts a repeatable sequence; without one, the first call
seeds the generator from the time of day. Unlike TSO/E REXX, BREXX does
limit #var("max") #cmd("-") #var("min") to 100000\; it covers the whole of
any range.

```
SAY random(1,6)          /* e.g. 4 */
```

#note[*A defect:* the numbers are not evenly spread. #cmd("RANDOM")
takes the remainder of the C library's #cmd("rand()"). Up to LIBC/370 2.6.2,
#cmd("rand()") returns only the values 0 to 4095 and 32768 to 36863, so
the results are unevenly spread, and a wide range is covered in parts only
(libc370 issue 387). With LIBC/370 2.6.3 and later it returns 0 to 32767, and the spread
is even for ranges of up to 32768 values.]

=== SIGN <lang-builtin-sign>

#idx("SIGN")
```
SIGN(number)
```
Returns #cmd("-1"), #cmd("0") or #cmd("1") as #var("number") is
negative, zero or positive.

```
SAY sign(-5.2)           /* -1 */
SAY sign(0.0)            /* 0 */
SAY sign(5.2)            /* 1 */
```

=== TRUNC <lang-builtin-trunc>

#idx("TRUNC")
```
TRUNC(number [, n])
```
Returns #var("number") rounded to #cmd("NUMERIC DIGITS") and then
truncated to #var("n") decimal places (default 0), without exponent.

```
SAY trunc(2.6)           /* 2 */
SAY trunc(127.96,1)      /* 127.9 */
```

The functions from #cmd("ACOS") to #cmd("TANH") are BREXX extensions.
They compute in floating point with the C library function of the same
name and return the result as a real number. Angles are in radians.

=== ACOS <lang-builtin-acos>

#idx("ACOS")
```
ACOS(x)
```
Returns the arc cosine of #var("x").

=== ASIN <lang-builtin-asin>

#idx("ASIN")
```
ASIN(x)
```
Returns the arc sine of #var("x").

=== ATAN <lang-builtin-atan>

#idx("ATAN")
```
ATAN(x)
```
Returns the arc tangent of #var("x").

=== ATAN2 <lang-builtin-atan2>

#idx("ATAN2")
```
ATAN2(y, x)
```
Returns the arc tangent of #var("y")/#var("x"), the signs of both choosing the quadrant.

```
y = atan2(1,1) * 4         /* pi */
```

=== COS <lang-builtin-cos>

#idx("COS")
```
COS(x)
```
Returns the cosine of #var("x").

=== COSH <lang-builtin-cosh>

#idx("COSH")
```
COSH(x)
```
Returns the hyperbolic cosine of #var("x").

=== EXP <lang-builtin-exp>

#idx("EXP")
```
EXP(x)
```
Returns #var("e") raised to the power #var("x").

=== LOG <lang-builtin-log>

#idx("LOG")
```
LOG(x)
```
Returns the natural logarithm of #var("x").

=== LOG10 <lang-builtin-log10>

#idx("LOG10")
```
LOG10(x)
```
Returns the logarithm of #var("x") to base 10.

=== POW <lang-builtin-pow>

#idx("POW")
```
POW(x, y)
```
Returns #var("x") raised to the power #var("y"), which need not be a whole number.

=== POW10 <lang-builtin-pow10>

#idx("POW10")
```
POW10(x)
```
Returns 10 raised to the power #var("x").

=== SIN <lang-builtin-sin>

#idx("SIN")
```
SIN(x)
```
Returns the sine of #var("x").

=== SINH <lang-builtin-sinh>

#idx("SINH")
```
SINH(x)
```
Returns the hyperbolic sine of #var("x").

=== SQRT <lang-builtin-sqrt>

#idx("SQRT")
```
SQRT(x)
```
Returns the square root of #var("x"). A negative #var("x") ends in error 42.

```
x = sqrt(2)                /* the square root of 2 */
```

=== TAN <lang-builtin-tan>

#idx("TAN")
```
TAN(x)
```
Returns the tangent of #var("x").

=== TANH <lang-builtin-tanh>

#idx("TANH")
```
TANH(x)
```
Returns the hyperbolic tangent of #var("x").

== Conversion Functions <lang-builtin-conv>

The conversions work on the EBCDIC codes of the characters: #cmd("'A'")
is #cmd("'C1'x"), #cmd("'a'") is #cmd("'81'x"), #cmd("'0'") is
#cmd("'F0'x") and a blank is #cmd("'40'x").

=== B2X <lang-builtin-b2x>

#idx("B2X")
```
B2X(binary-string)
```
Returns the hexadecimal form of a string of binary digits. Blanks in
#var("binary-string") are ignored; any character other than #cmd("0"),
#cmd("1") or blank ends in error 15.

```
SAY b2x('11000001')      /* C1 */
SAY b2x('1 0000')        /* 10 */
```

=== BITAND <lang-builtin-bitand>

#idx("BITAND")
```
BITAND(string1 [, [string2] [, pad]])
```
Returns the two strings combined bit by bit with AND. The shorter string
is extended with #var("pad"); without #var("pad"), the rest of the
longer string is taken unchanged.

```
SAY c2x(bitand('61'x,'52'x))       /* 40 */
SAY c2x(bitand('6162'x,'5253'x))   /* 4042 */
SAY c2x(bitand('6162'x,,'FE'x))    /* 6062 */
```

=== BITOR <lang-builtin-bitor>

#idx("BITOR")
```
BITOR(string1 [, [string2] [, pad]])
```
As #cmd("BITAND"), with OR.

```
SAY bitor('abc','40'x)        /* Abc */
SAY bitor('abc','40'x,'40'x)  /* ABC */
```

=== BITXOR <lang-builtin-bitxor>

#idx("BITXOR")
```
BITXOR(string1 [, [string2] [, pad]])
```
As #cmd("BITAND"), with exclusive OR.

```
SAY c2x(bitxor('C1'x,'FF'x))      /* 3E */
```

=== C2D <lang-builtin-c2d>

#idx("C2D")
```
C2D(string [, n])
```
Returns the decimal value of the binary string #var("string"). With
#var("n"), the rightmost #var("n") bytes are taken as a signed number.
Without #var("n"), a string of fewer than four bytes is unsigned. At
most four bytes count: a longer string, or #var("n") greater than 4,
uses the rightmost four, and four bytes are always signed. So
#cmd("C2D('FFFFFFFF'x)") is #cmd("-1"), where TSO/E REXX gives
#cmd("4294967295"). More than four significant bytes are error 40: leading
#cmd("'00'x") bytes are allowed, and so, for a negative value with
#var("n"), are leading #cmd("'FF'x") bytes (#cmd("C2D('FFFFFFFFFF'x,5)") is
#cmd("-1")).

```
SAY c2d('09'x)           /* 9 */
SAY c2d('A')             /* 193 */
SAY c2d('FF40'x)         /* 65344 */
SAY c2d('81'x,1)         /* -127 */
SAY c2d('81'x,2)         /* 129 */
```

=== C2X <lang-builtin-c2x>

#idx("C2X")
```
C2X(string)
```
Returns the hexadecimal form of #var("string").

```
SAY c2x('abc')           /* 818283 */
SAY c2x('0506'x)         /* 0506 */
```

=== D2C <lang-builtin-d2c>

#idx("D2C")
```
D2C(wholenumber [, n])
```
Returns the binary form of #var("wholenumber"), #var("n") bytes long
(at most 4); without #var("n"), as many bytes as are needed. A negative
number is in two's complement.

```
SAY c2x(d2c(5))          /* 05 */
SAY d2c(193)             /* A */
SAY c2x(d2c(-1,2))       /* FFFF */
```

=== D2X <lang-builtin-d2x>

#idx("D2X")
```
D2X(wholenumber [, n])
```
Returns the hexadecimal form of #var("wholenumber"), #var("n") digits
long; without #var("n"), as many digits as are needed.

```
SAY d2x(5)               /* 5 */
SAY d2x(193)             /* C1 */
SAY d2x(5,4)             /* 0005 */
```

=== X2B <lang-builtin-x2b>

#idx("X2B")
```
X2B(hex-string)
```
Returns the binary digits of #var("hex-string"), four for each
hexadecimal digit. Blanks are ignored; any other character that is not
a hexadecimal digit ends in error 15.

```
SAY x2b('C1')            /* 11000001 */
```

=== X2C <lang-builtin-x2c>

#idx("X2C")
```
X2C(hex-string)
```
Returns the characters whose codes #var("hex-string") gives. Blanks may
separate groups of digits; a group with an odd number of digits gets a
leading #cmd("0").

```
SAY x2c('C1C2C3')        /* ABC */
SAY x2c('F1 F2')         /* 12 */
```

=== X2D <lang-builtin-x2d>

#idx("X2D")
```
X2D(hex-string [, n])
```
Returns the decimal value of #var("hex-string"). With #var("n"), the
rightmost #var("n") digits (at most 8) are taken as a signed number. As
with #cmd("C2D"), at most eight digits count, and eight digits are
always signed: #cmd("X2D('FFFFFFFF')") is #cmd("-1").

```
SAY x2d('C1')            /* 193 */
SAY x2d('81',2)          /* -127 */
SAY x2d('81',4)          /* 129 */
```

== Stream Functions <lang-builtin-stream>

#idx("stream")
There are two families of input and output functions: the REXX stream
functions #cmd("CHARIN"), #cmd("CHAROUT"), #cmd("CHARS"),
#cmd("LINEIN"), #cmd("LINEOUT"), #cmd("LINES") and #cmd("STREAM"), and
the C-style functions of BREXX, #cmd("OPEN"), #cmd("CLOSE"),
#cmd("READ"), #cmd("WRITE"), #cmd("SEEK"), #cmd("EOF") and
#cmd("FLUSH"). Do not mix the two families on one stream.

*Naming a stream.* A stream is named by a string, or by the handle
number that #cmd("OPEN") returns. A name in quotes, such as
#cmd("\"'HERC01.TEST.DATA'\""), is a data set name and is used as it
is. A name without quotes is taken, when a data set prefix is set, as
the data set #var("prefix")#cmd(".")#var("name"), and if that cannot be
opened, as a DD name, provided it contains no #cmd(".") and no
parentheses. When no prefix is set, a name without quotes can only be a
DD name; any other ends in error 62. A name may carry a member in
parentheses.

The prefix is that of the TSO user, wherever BREXX/370 runs under the
terminal monitor program: at a terminal, in a batch job under
#cmd("IKJEFT01"), and under the TSO command #cmd("CALL") alike. A batch step
without TSO (#cmd("PGM=BREXX")) has none.

*Standard streams.* Three streams are always open:

#deflist(width: 1.2in,
  [#cmd("0")], [#cmd("<STDIN>"), standard input.],
  [#cmd("1")], [#cmd("<STDOUT>"), standard output.],
  [#cmd("2")], [#cmd("<STDERR>"), standard error.],
)

Write to them by these names or numbers, for example
#cmd("CALL LINEOUT '<STDERR>', 'message'"). A name without the angle
brackets, such as #cmd("'STDOUT'"), is not a standard stream but a name
like any other. An omitted or null stream name is standard input for
#cmd("CHARIN"), #cmd("LINEIN"), #cmd("CHARS"), #cmd("LINES") and
#cmd("READ"), and standard output for #cmd("CHAROUT"), #cmd("LINEOUT")
and #cmd("WRITE"). Which DD each standard stream uses is described in
the _BREXX/370 User's Guide_. The interpreter closes all streams that
are still open when it ends.

*Positions.* Each stream that the REXX stream functions use has a read
position and a write position of its own. The read position starts at
the beginning (1), the write position of an existing data set at its
end, so #cmd("LINEOUT") and #cmd("CHAROUT") append to an existing data
set and never truncate it. Reading does not move the write position, and
writing does not move the read position: a stream opened with
#cmd("OPEN(")#var("name")#cmd(",'w')") can be written and then read back
from the beginning. Positions count bytes as the C library sees the data
set: an FB record is its LRECL plus one byte for the line end, so in an
FB 80 data set line #var("n") starts at byte (#var("n")-1)×81+1. A
terminal or a SYSOUT data set has only the one position where it is.

*NOTREADY.* When the #cmd("NOTREADY") condition is trapped (@lang-instr-call),
it is raised when #cmd("CHARIN") returns fewer characters than asked
for, when #cmd("LINEIN") finds no more lines, when a start position lies
beyond the end, and when #cmd("CHAROUT") or #cmd("LINEOUT") cannot write
everything, for example because the C library refuses the write.

#cmd("LINEIN") returns a record of fixed length with its trailing blanks,
as #cmd("EXECIO DISKR") and #cmd("READ") do; use
#cmd("STRIP(")#var("line")#cmd(",'T')") where they are not wanted. An
existing member of a partitioned data set cannot be extended: writing to it
in append mode fails.

Such a write raises #cmd("NOTREADY"), and #cmd("LINEOUT") returns 1 (the
line was not written)\; #cmd("STREAM") then reports #cmd("NOTREADY") until
the next actual read or write, or #cmd("STREAM(")#var("name")#cmd(",'C','RESET')").
A #cmd("LINEOUT") or #cmd("CHAROUT") without data and position only flushes
the stream and does not clear it.

=== CHARIN <lang-builtin-charin>

#idx("CHARIN")
```
CHARIN([stream] [, [start] [, length]])
```
Reads #var("length") characters (default 1) from #var("stream"),
starting at the read position, or at character #var("start") (1 is the
first), and returns them. #var("length") #cmd("0") reads nothing and
only sets the position. A stream that is not open is opened for reading.

```
ch = charin('INFILE')         /* one character */
ch = charin('INFILE',3,2)     /* two characters from position 3 */
```

=== CHAROUT <lang-builtin-charout>

#idx("CHAROUT")
```
CHAROUT([stream] [, [string] [, start]])
```
Writes #var("string") to #var("stream") at the write position, or at
character #var("start"), and returns the number of characters that were
#emph[not] written, #cmd("0") on success. Without #var("string"),
nothing is written: with #var("start") the write position is set,
without it the stream is flushed and the write position moved to its
end. A stream that is not open is opened without being truncated, and
created if it does not exist.

```
CALL charout 'OUTFILE','hello'    /* writes hello */
CALL charout 'OUTFILE','hi',2     /* writes hi at position 2 */
```

=== CHARS <lang-builtin-chars>

#idx("CHARS")
```
CHARS([stream])
```
Returns the number of characters from the read position to the end of
#var("stream"). For a stream without positions -- a terminal, a SYSOUT
data set or a standard stream -- returns #cmd("1") while the end has not
been reached, then #cmd("0").

```
SAY chars('INFILE')           /* e.g. 810 */
```

=== CLOSE <lang-builtin-close>

#idx("CLOSE")
```
CLOSE(stream)
```
Closes #var("stream"), given by name or handle, and returns #cmd("0"),
or the return code of the C library. A stream that is not open ends in
error 59.

```
hnd = open('OUTFILE','w')
...
CALL close hnd
```

=== EOF <lang-builtin-eof>

#idx("EOF")
```
EOF(stream)
```
Returns #cmd("1") if the end of #var("stream") has been reached,
#cmd("0") if not, and #cmd("-1") if no stream of that name is open. A
handle number that is not open ends in error 59.

```
hnd = open('INFILE','r')
DO FOREVER
  line = read(hnd)
  IF eof(hnd) THEN LEAVE
  SAY line
END
CALL close hnd
```

=== FLUSH <lang-builtin-flush>

#idx("FLUSH")
```
FLUSH(stream)
```
Writes the buffered output of #var("stream") and returns #cmd("0") or
the return code of the C library. It returns #cmd("-1") if no stream of
that name is open; a handle number that is not open ends in error 59.

```
CALL flush 'OUTFILE'
```

=== LINEIN <lang-builtin-linein>

#idx("LINEIN")
```
LINEIN([stream] [, [start] [, count]])
```
Reads a line from #var("stream"), at the read position or at line
#var("start"), and returns it without the line end. A #var("count")
greater than 1 is a BREXX extension: that many lines are read and
returned joined by the line end character. #var("count") #cmd("0") reads
nothing and only sets the position. A stream that is not open is opened
for reading.

```
line = linein('INFILE')       /* the next line */
line = linein('INFILE',3)     /* line 3 */
DO WHILE lines('INFILE') > 0
  SAY linein('INFILE')
END
```

=== LINEOUT <lang-builtin-lineout>

#idx("LINEOUT")
```
LINEOUT([stream] [, [string] [, start]])
```
Writes #var("string") and a line end to #var("stream"), at the write
position or at line #var("start"), and returns #cmd("0") on success or
#cmd("1") if the line was not written. Without #var("string"), nothing
is written (no empty line): with #var("start") the write position is
set, without it the stream is flushed and the write position moved to
its end. A stream that is not open is opened without being truncated,
and created if it does not exist.

```
CALL lineout 'OUTFILE','hello'   /* appends the line hello */
CALL lineout 'OUTFILE','hi',2    /* rewrites line 2 */
CALL lineout 'OUTFILE'           /* flush */
```

=== LINES <lang-builtin-lines>

#idx("LINES")
```
LINES([stream])
```
Returns the number of lines from the read position to the end of
#var("stream"). For a stream without positions, returns #cmd("1") while
the end has not been reached, then #cmd("0").

```
SAY lines('INFILE')           /* e.g. 10 */
```

=== OPEN <lang-builtin-open>

#idx("OPEN")
```
OPEN(stream, mode [, allocation])
```
Opens #var("stream") and returns its handle number, or #cmd("-1") if it
cannot be opened. #cmd("OPEN") keeps #var("stream") in lowercase, and the
other functions compare names exactly, so refer to a stream that
#cmd("OPEN") opened by its handle. #var("mode") is a mode of the C function
#cmd("fopen"):

#deflist(width: 1.2in,
  [#cmd("r")], [Read.],
  [#cmd("w")], [Write; the data set is emptied first.],
  [#cmd("a")], [Append.],
  [#cmd("+")], [Added to a mode: read and write.],
  [#cmd("b")], [Added to a mode: binary.],
)

#cmd("w") and #cmd("a") are opened as #cmd("w+") and #cmd("a+"), so that
what was written can be read back; a terminal or SYSOUT, which cannot be
opened that way, is opened as asked.

#var("allocation") is used for a write open (#cmd("w") or #cmd("a")) of
a data set that does not exist: the data set is first created with these
attributes. It is a list of #var("keyword")#cmd("=")#var("value") items
separated by commas, with the keywords #cmd("DSORG") (#cmd("PS") or
#cmd("PO")), #cmd("RECFM"), #cmd("LRECL"), #cmd("BLKSIZE"),
#cmd("PRI"), #cmd("SEC") (in tracks; default 1 and 1),
#cmd("DIRBLKS") and #cmd("UNIT") (default #cmd("SYSDA")). For a name
with a member, the data set is created partitioned. A data set that
exists keeps its attributes. If the allocation information is not valid
or the data set cannot be created, #cmd("OPEN") returns #cmd("-1"). #cmd("VIO"), which opened a memory file in
older releases, ends in error 40.

```
hnd = open("'HERC01.TEST.DATA'",'w','RECFM=FB,LRECL=80,PRI=5')
IF hnd = -1 THEN SAY 'cannot open'
```

=== READ <lang-builtin-read>

#idx("READ")
```
READ([stream] [, length | option])
```
Reads from #var("stream") and returns what was read: a line, without its
line end, unless the second argument says otherwise. A number reads that
many bytes; an option:

#deflist(width: 1.2in,
  [#cmd("C")], [Char: one character.],
  [#cmd("L")], [Line: one line (the default).],
  [#cmd("F")], [File: the rest of the stream.],
)

A stream that is not open is opened for reading.

```
reply = read()                /* a line from standard input */
line  = read('INFILE')        /* a line */
ch    = read('INFILE','C')    /* a character */
all   = read('INFILE','F')    /* the rest of the data set */
```

=== SEEK <lang-builtin-seek>

#idx("SEEK")
```
SEEK(stream [, offset [, origin]])
```
Moves the position of #var("stream"), which must be open, by
#var("offset") bytes from #var("origin"), and returns the new position.
Without #var("offset"), returns the current position.

#deflist(width: 1.2in,
  [#cmd("TOF")], [Top of file (the default).],
  [#cmd("CUR")], [The current position.],
  [#cmd("EOF")], [The end of the file.],
)

```
size = seek(hnd,0,'EOF')      /* the size in bytes */
CALL seek hnd,0,'TOF'         /* back to the start */
pos  = seek(hnd,-5,'CUR')     /* 5 bytes back */
```

=== STREAM <lang-builtin-stream-fn>

#idx("STREAM")
```
STREAM(stream [, [option] [, command]])
```
Returns the state of #var("stream"), or carries out #var("command") on
it.

#deflist(width: 1.2in,
  [#cmd("S")], [Status (the default): #cmd("READY"), #cmd("NOTREADY")
    when the end has been reached, or #cmd("UNKNOWN") when the stream is
    not open.],
  [#cmd("D")], [Description: the same as #cmd("S").],
  [#cmd("C")], [Command: carries out #var("command") and returns
    #cmd("READY"). A stream that cannot be opened ends in error 57, an
    unknown command in error 40.],
)

Each open command first closes the stream if it is open. The commands,
with the synonyms that are accepted:

#deflist(width: 1.2in,
  [#cmd("READ")], [#cmd("OPEN"), #cmd("OPEN READ"): open for reading.],
  [#cmd("WRITE")], [#cmd("OPEN WRITE"): open for writing; the data set is
    emptied.],
  [#cmd("APPEND")], [#cmd("OPEN WRITE APPEND"): open for appending.],
  [#cmd("UPDATE")], [#cmd("OPEN BOTH"): open for reading and writing;
    the data set must exist.],
  [#cmd("CREATE")], [#cmd("OPEN WRITE REPLACE"): open for writing and
    reading; the data set is emptied.],
  [#cmd("CLOSE")], [Close the stream.],
  [#cmd("FLUSH")], [Write the buffered output.],
  [#cmd("RESET")], [Set the read and write positions to the beginning.],
)

#cmd("READBINARY"), #cmd("WRITEBINARY"), #cmd("APPENDBINARY"),
#cmd("UPDATEBINARY") and #cmd("CREATEBINARY") (or the open command
followed by #cmd("BINARY")) open in the binary mode of the C library.

```
CALL stream 'OUTFILE','C','WRITE'
CALL lineout 'OUTFILE','first line'
CALL stream 'OUTFILE','C','CLOSE'
SAY stream('OUTFILE')         /* UNKNOWN: it is closed */
```

=== WRITE <lang-builtin-write>

#idx("WRITE")
```
WRITE([stream] [, [string] [, newline]])
```
Writes #var("string") to #var("stream") and returns the number of
characters written. Without #var("string"), writes a line end. With a
third argument, whatever its value, a line end is added. A stream that
is not open is opened with mode #cmd("w"): an existing data set is
emptied, unlike with #cmd("LINEOUT").

```
CALL write 'OUTFILE','First line',''   /* a line */
CALL write ,'a'                        /* a to standard output, no line end */
CALL write '','one line',''            /* a line to standard output */
```
