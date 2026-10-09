#import "../bookmaster/bookmaster.typ": *

= Additional Kernel Functions <ext-kernel>

#idx("BREXX function")
BREXX/370 adds functions of its own to the REXX language. They are part
of the interpreter's load module and are found before any external exec:
a member of the same name in #cmd("RXLIB") or in the library of the
program does not replace them. None of them exists in TSO/E REXX.

Most of them are written in C. Some are written in REXX and carried in
the load module as source text; the entry says so. They are called in
the same way as the others.

The functions #cmd("CEIL"), #cmd("FLOOR"), #cmd("ROUND"), #cmd("D2P"),
#cmd("P2D") and #cmd("FILTER") belong to the built-in function table
(@lang-builtin) and are described here with the other additions. The
functions for arrays and linked lists are in @ext-array, those for data
sets in @ext-dataset, for TSO in @ext-tso and for global variables in
@ext-global.

In the formats, an argument in brackets may be omitted. A wrong number
of arguments, or an argument of the wrong kind, ends in error 40
(_Incorrect call to routine_) unless the entry says otherwise.

== Strings <ext-kernel-strings>

=== AFTER <ext-kernel-after>

#idx("AFTER")
```
AFTER(needle, string)
```
Returns the part of #var("string") that follows the first occurrence of
#var("needle"), or the null string if #var("needle") does not occur.

Written in REXX and carried in the load module.

```
s = 'The quick brown fox jumps over the lazy dog'
SAY after('fox', s)        /* ' jumps over the lazy dog' */
SAY after('cat', s)        /* ''                         */
```

=== BEFORE <ext-kernel-before>

#idx("BEFORE")
```
BEFORE(needle, string)
```
Returns the part of #var("string") that precedes the first occurrence of
#var("needle"). The result is the null string if #var("needle") does not
occur, or if #var("string") starts with it.

Written in REXX and carried in the load module.

```
s = 'The quick brown fox jumps over the lazy dog'
SAY before('fox', s)       /* 'The quick brown ' */
```

=== LASTWORD <ext-kernel-lastword>

#idx("LASTWORD")
```
LASTWORD(string [, n])
```
Returns the last word of #var("string"), or with #var("n") the
#var("n")th word counted from the end. If #var("string") has fewer
words, the result is the null string.

```
SAY lastword('one two three')      /* three */
SAY lastword('one two three', 2)   /* two   */
SAY lastword('a b', 5)             /* ''    */
```

=== JOIN <ext-kernel-join>

#idx("JOIN")
```
JOIN(string, target [, table])
```
Merges #var("string") into #var("target") position by position. Where
the character of #var("target") is one of the characters of
#var("table"), it is replaced by the character of #var("string") at the
same position; every other character of #var("target") stays.
#var("table") defaults to a blank. If either string is null, the other
one is returned. Where #var("string") is longer than #var("target"), the
rest of it is appended; where #var("target") is longer, the rest of
#var("target") stays as it is, characters of #var("table") included.

```
SAY join('abcdef', '12 4  ')          /* 12c4ef */
SAY join('     PETER      MUNICH',,
         'NAME=      CITY=        ')  /* NAME=PETER CITY=MUNICH */
```

=== SPLIT <ext-kernel-split>

#idx("SPLIT")
```
SPLIT(string, stem [, delimiters])
```
Splits #var("string") into words and stores them in
#var("stem")#cmd("1"), #var("stem")#cmd("2"), and so on;
#var("stem")#cmd("0") receives their number, which is also the result.
A word ends at any of the characters in #var("delimiters"), which
defaults to a blank; consecutive delimiters do not make empty words. A
missing period at the end of #var("stem") is added. Quote the stem
name, or its value is used instead.

```
n = split('a,b,,c', 'w.', ',')
SAY n w.1 w.3                                    /* 3 a c  */
SAY split('City=London,Floor(7)', 'x.', '()=,')  /* 4      */
SAY x.2                                          /* London */
```

=== SPLITBS <ext-kernel-splitbs>

#idx("SPLITBS")
```
SPLITBS(string, stem [, separator])
```
As #cmd("SPLIT"), but the words are separated by the string
#var("separator") as a whole, and two separators in a row make an empty
word. Without #var("separator"), #cmd("SPLITBS") is #cmd("SPLIT") with
blanks. The stem is dropped before it is filled; a null #var("stem")
means #cmd("MYSTEM.").

Written in REXX and carried in the load module.

```
SAY splitbs('today</N>tomorrow</N>yesterday', 'd.', '</N>')  /* 3 */
SAY d.2                                          /* tomorrow */
```

=== WORDDEL <ext-kernel-worddel>

#idx("WORDDEL")
```
WORDDEL(string, n)
```
Returns #var("string") without its #var("n")th word. If there is no such
word, #var("string") is returned unchanged.

Written in REXX and carried in the load module.

```
SAY worddel('I really love BREXX', 2)    /* I love BREXX        */
SAY worddel('I really love BREXX', 5)    /* I really love BREXX */
```

=== WORDINS <ext-kernel-wordins>

#idx("WORDINS")
```
WORDINS(new, string, n)
```
Inserts the word #var("new") after the #var("n")th word of
#var("string"). With #var("n") less than 1, #var("new") becomes the first
word; with #var("n") beyond the last word, it is appended.

Written in REXX and carried in the load module.

```
SAY wordins('really', 'I love BREXX', 1)   /* I really love BREXX */
SAY wordins('really', 'I love BREXX', 0)   /* really I love BREXX */
SAY wordins('really', 'I love BREXX', 3)   /* I love BREXX really */
```

=== WORDREP <ext-kernel-wordrep>

#idx("WORDREP")
```
WORDREP(new, string, n)
```
Replaces the #var("n")th word of #var("string") by #var("new"). If there
is no such word, #var("string") is returned unchanged.

Written in REXX and carried in the load module.

```
SAY wordrep('!!!', 'I love BREXX', 2)      /* I !!! BREXX */
```

=== UPPER <ext-kernel-upper>

#idx("UPPER")
```
UPPER(string)
```
Returns #var("string") in uppercase. The #cmd("UPPER") instruction
(@lang-instr) changes variables in place instead.

```
SAY upper('abc')         /* ABC */
```

=== LOWER <ext-kernel-lower>

#idx("LOWER")
```
LOWER(string)
```
Returns #var("string") in lowercase.

```
SAY lower('AbC')         /* abc */
```

=== FILTER <ext-kernel-filter>

#idx("FILTER")
```
FILTER(string, table [, option])
```
Removes, keeps or blanks out the characters of #var("string") that occur
in #var("table"). Only the first letter of #var("option") counts:

#deflist(width: 1.2in,
  [#cmd("D")], [Drop: remove the characters in #var("table") (the
    default).],
  [#cmd("K")], [Keep: remove every character that is not in
    #var("table").],
  [#cmd("B")], [Blank: replace the characters in #var("table") by
    blanks; the length stays.],
)

Any other letter is taken as #cmd("D"). If #var("table") is null,
#var("string") is returned unchanged.

```
s = 'The quick brown fox'
SAY filter(s, ' o')            /* Thequickbrwnfx      */
SAY filter(s, 'aeiou', 'K')    /* euioo               */
SAY filter(s, 'o', 'B')        /* The quick br wn f x */
```

=== ROTATE <ext-kernel-rotate>

#idx("ROTATE")
```
ROTATE(string, position [, length])
```
Returns the substring of #var("string") that starts at #var("position")
and continues from the start of #var("string") when it reaches the end,
as if the string were a ring. #var("length") defaults to the length of
#var("string"); a longer one goes on round the ring. A #var("position")
beyond the length is taken modulo the length.

```
SAY rotate('1234567890ABCDEF', 10, 10)   /* 0ABCDEF123       */
SAY rotate('1234567890ABCDEF', 5)        /* 567890ABCDEF1234 */
SAY rotate('ABCDEF', 5, 4)               /* EFAB             */
SAY rotate('ABCD', 4)                    /* DABC             */
SAY rotate('ABCD', 2, 10)                /* BCDABCDABC       */
```

=== LCS <ext-kernel-lcs>

#idx("LCS")
```
LCS(string1, string2)
```
Returns the longest common subsequence of the two strings: the longest
string whose characters occur in both, in the same order but not
necessarily next to each other. Both strings must be non-null. The
function needs a table of
(#cmd("LENGTH(")#var("string1")#cmd(")+1")) ×
(#cmd("LENGTH(")#var("string2")#cmd(")+1")) fullwords; if it cannot get
the storage, the program ends with #cmd("LCS: not enough storage").

```
SAY lcs('thisisatest', 'testing123testing')   /* tsitest */
SAY lcs('ABCBDAB', 'BDCABA')                  /* BCBA    */
```

=== CHAR <ext-kernel-char>

#idx("CHAR")
```
CHAR(string, n [, pad])
```
Returns the #var("n")th character of #var("string"), or #var("pad") (a
blank by default) if #var("string") is shorter.

```
SAY char('hello', 2)       /* e */
SAY char('ab', 5, '*')     /* * */
```

=== FPOS <ext-kernel-fpos>

#idx("FPOS")
```
FPOS(needle, haystack [, start])
```
Returns the position of the first #var("needle") in #var("haystack"),
searching from #var("start") (default 1), or 0 if it does not occur. A
faster #cmd("POS") for long strings.

#note[*A defect* (brexx370 issue 386): #cmd("FPOS") searches with the C
library and stops at a byte #cmd("'00'X"), so it misses a #var("needle")
behind one in binary data, where #cmd("POS") finds it.
#cmd("FCHANGESTR") does the same.] A #var("start") beyond the end of
#var("haystack") gives 0.

```
SAY fpos('lo', 'hello world')      /* 4 */
SAY fpos('o', 'hello world', 6)    /* 8 */
```

=== FCHANGESTR <ext-kernel-fchangestr>

#idx("FCHANGESTR")
```
FCHANGESTR(needle, haystack, new)
```
Replaces every #var("needle") in #var("haystack") by #var("new"), like
#cmd("CHANGESTR") but searching as #cmd("FPOS") does. A null
#var("needle") returns #var("haystack") unchanged.

```
SAY fchangestr('o', 'foo boo', '0')   /* f00 b00 */
```

=== QUOTE <ext-kernel-quote>

#idx("QUOTE")
```
QUOTE(string)
```
Returns #var("string") in apostrophes, or in double quotes if it
contains an apostrophe. A string that already starts and ends with the
same kind of quote is returned unchanged. Useful for data set names.

```
SAY quote('SYS1.MACLIB')     /* 'SYS1.MACLIB' */
SAY quote("'abc'")           /* 'abc'         */
SAY quote("it's")            /* "it's"        */
```

=== MASKBLK <ext-kernel-maskblk>

#idx("MASKBLK")
```
MASKBLK(string, delimiter, replacement)
```
Replaces each blank between a pair of #var("delimiter") characters by
#var("replacement"), so that a quoted phrase counts as one word for the
word functions. Only the first character of #var("delimiter") and of
#var("replacement") is used.

```
SAY maskblk('a "b c" d', '"', '_')   /* a "b_c" d */
```

=== MATCH <ext-kernel-match>

#idx("MATCH")
```
MATCH(pattern, string)
```
Searches #var("string") for the regular expression #var("pattern") and
returns the offset of the first match, counted from 0, or #cmd("-1")
if there is none. The expressions are simple:

#deflist(width: 1.2in,
  [#cmd(".")], [Any character.],
  [#cmd("^")], [Start of the string (as the first character).],
  [#cmd("$")], [End of the string.],
  [#cmd("*") #cmd("+") #cmd("?")], [Zero or more, one or more, zero or
    one of the item before.],
  [#cmd("[abc]") #cmd("[a-z]")], [One character of the class or range.],
  [#cmd("\\d") #cmd("\\D")], [A digit, a non-digit.],
  [#cmd("\\w") #cmd("\\W")], [An alphanumeric character or #cmd("_"),
    and its opposite.],
  [#cmd("\\s") #cmd("\\S")], [White space, and its opposite.],
)

The brackets and the caret are accepted in all the forms 3270 code
pages give them: #cmd("'BA'X"), #cmd("'BB'X"), #cmd("'B0'X") (CP037),
#cmd("'AD'X"), #cmd("'BD'X") and #cmd("'5F'X") (IBM-1047 and the x3270
bracket page). A range compares EBCDIC values, so #cmd("[a-z]") also
takes the characters between #cmd("i") and #cmd("j") and between
#cmd("r") and #cmd("s").

#note[*A defect* (brexx370 issue 386): ranges compare EBCDIC values, as
described above, and the inverted class #cmd("[^abc]") is marked as
broken in the source of the regular expression code. The lowercase
letters can be written as #cmd("[a-ij-rs-z]").]

```
SAY match('[0-9]+', 'ab12')   /* 2  */
SAY match('^ab', 'xab')       /* -1 */
SAY match('^ab', 'abc')       /* 0  */
```

=== DEFAULT <ext-kernel-default>

#idx("DEFAULT")
```
DEFAULT(value, default)
```
Returns #var("value"), or #var("default") if #var("value") is null.

Written in REXX and carried in the load module.

```
PARSE ARG dsn
dsn = default(dsn, 'TEST.DATA')
```

== Conversion <ext-kernel-conversion>

=== A2E <ext-kernel-a2e>

#idx("A2E")
```
A2E(string)
```
Translates #var("string") from ASCII (ISO-8859-1) to EBCDIC with the
interpreter's own table. #cmd("A2E") and #cmd("E2A") are exact inverses:
every one of the 256 byte values comes back unchanged. The table is not
CP037 in every position: it maps #cmd("[") and #cmd("]") to
#cmd("'4A'X") and #cmd("'5A'X"), #cmd("!") to #cmd("'4F'X") and
#cmd("|") to #cmd("'6A'X"), and the line feed #cmd("'0A'X") to
#cmd("'25'X").

```
SAY c2x(a2e('41'x))        /* C1 */
```

=== E2A <ext-kernel-e2a>

#idx("E2A")
```
E2A(string)
```
Translates #var("string") from EBCDIC to ASCII; the inverse of
#cmd("A2E"). The newline character of BREXX/370 output,
#cmd("'15'X") (NEL), becomes #cmd("'85'X"), not a line feed; only
#cmd("'25'X") becomes #cmd("'0A'X").

```
SAY c2x(e2a('C1'x))        /* 41 */
```

=== B2C <ext-kernel-b2c>

#idx("B2C")
```
B2C(bits)
```
Converts a string of binary digits into the characters they encode;
the same as #cmd("X2C(B2X(")#var("bits")#cmd("))").

Written in REXX and carried in the load module.

```
SAY b2c('1100000111000010')    /* AB */
SAY b2c('1111000111110000')    /* 10 */
```

=== C2B <ext-kernel-c2b>

#idx("C2B")
```
C2B(string)
```
Converts #var("string") into a string of binary digits, eight per
character; the same as #cmd("X2B(C2X(")#var("string")#cmd("))").

Written in REXX and carried in the load module.

```
SAY c2b('AB')              /* 1100000111000010 */
SAY c2b('64'x)             /* 01100100         */
```

=== C2U <ext-kernel-c2u>

#idx("C2U")
```
C2U(string)
```
Returns the binary value of #var("string") as an unsigned decimal
number. Only the rightmost four bytes count. A null string gives
#cmd("0"). #cmd("C2D") gives the same bytes as a signed number.

```
SAY c2d('B5918B39'x)       /* -1248752839 */
SAY c2u('B5918B39'x)       /* 3046214457  */
SAY c2u('FFFFFFFF'x)       /* 4294967295  */
```

=== D2P <ext-kernel-d2p>

#idx("D2P")
```
D2P(number [, length [, decimals]])
```
Converts #var("number") into a packed decimal field of #var("length")
bytes (default 6). The number is first formatted with #var("decimals")
digits after the point (default 0); the point is then dropped, so a
packed field carries no decimal point and #var("decimals") scales the
value. The sign half-byte is #cmd("F") for a positive number and
#cmd("D") for a negative one. The field is padded on the left with
zeros; if the number does not fit into #var("length") bytes, the
program ends with error 42 (_Arithmetic overflow_).

```
SAY c2x(d2p(123, 3))        /* 00123F   */
SAY c2x(d2p(-12.5, 3, 1))   /* 00125D   */
SAY c2x(d2p(1.25, 4, 2))    /* 0000125F */
```

=== P2D <ext-kernel-p2d>

#idx("P2D")
```
P2D(packed [, length [, decimals]])
```
Converts a packed decimal field back into a number. #var("length") is
accepted for symmetry with #cmd("D2P") and ignored; the whole of
#var("packed") is converted. With #var("decimals"), the result is
divided by 10 that many times and shown with that many decimals. The
sign half-byte #cmd("D") or #cmd("B") makes the number negative,
#cmd("A"), #cmd("C") or #cmd("F") positive; any other sign writes
#cmd("Invalid Packed Sign") and ends the program with error 15.

```
SAY p2d('00125D'x)            /* -125  */
SAY p2d('00125D'x, , 1)       /* -12.5 */
SAY p2d(d2p(1.25, 4, 2), , 2) /* 1.25  */
```

=== BASE64ENC <ext-kernel-base64enc>

#idx("BASE64ENC")
```
BASE64ENC(string)
```
Encodes #var("string") in Base64. The bytes are encoded as they are, that
is, in EBCDIC: the result is not the Base64 form of the same text on an
ASCII system. Base64 is an encoding, not an encryption.

Written in REXX and carried in the load module.

```
SAY base64enc('Hello')     /* yIWTk5Y= */
```

=== BASE64DEC <ext-kernel-base64dec>

#idx("BASE64DEC")
```
BASE64DEC(string)
```
Decodes a Base64 string. The URL form, with #cmd("-") and #cmd("_") in
place of #cmd("+") and #cmd("/"), is accepted too.

Written in REXX and carried in the load module.

```
str = 'The quick brown fox jumps over the lazy dog'
enc = base64enc(str)
SAY enc    /* 44iFQJikiYOSQIKZlqaVQIaWp0CRpJSXokCWpYWZQKOIhUCTgamoQISWhw== */
SAY base64dec(enc) == str                         /* 1 */
```

== Arithmetic <ext-kernel-arith>

=== CEIL <ext-kernel-ceil>

#idx("CEIL")
```
CEIL(number)
```
Returns the smallest integer that is greater than or equal to
#var("number").

```
SAY ceil(2.1)              /* 3  */
SAY ceil(-2.1)             /* -2 */
```

=== FLOOR <ext-kernel-floor>

#idx("FLOOR")
```
FLOOR(number)
```
Returns the largest integer that is less than or equal to
#var("number").

```
SAY floor(2.9)             /* 2  */
SAY floor(-2.1)            /* -3 */
```

=== ROUND <ext-kernel-round>

#idx("ROUND")
```
ROUND(number, decimals)
```
Rounds #var("number") to #var("decimals") digits after the decimal
point, half away from zero. The result always has exactly
#var("decimals") decimals, padded with zeros.

#note[*A defect* (brexx370 issue 386): #cmd("ROUND") rounds twice. It
adds half a unit of the last digit and then formats with the C library,
which rounds as well, so a value whose dropped digits are below one half
can be rounded up: #cmd("ROUND(3.141,2)") gives #cmd("3.15").]

```
SAY round(2.5, 0)          /* 3 */
```

=== INT <ext-kernel-int>

#idx("INT")
```
INT(number)
```
Returns the integer part of #var("number"); the fraction is cut off, not
rounded. A string that is not a number ends the program with
#cmd("Invalid Number").

```
SAY int(7.9)               /* 7  */
SAY int(-7.9)              /* -7 */
```

=== MOD <ext-kernel-mod>

#idx("MOD")
```
MOD(number, divisor)
```
Returns the remainder of #var("number") divided by #var("divisor"), as
#cmd("//") does, but cut to an integer with #cmd("INT"): for integers
the two agree, for numbers with a fraction they do not.

Written in REXX and carried in the load module.

```
SAY mod(17, 5)             /* 2                 */
SAY mod(7.5, 2)            /* 1 (7.5//2 is 1.5) */
```

=== ROOT <ext-kernel-root>

#idx("ROOT")
```
ROOT(number, n)
```
Returns the #var("n")th root of #var("number"), computed as
#cmd("POW(")#var("number")#cmd(",1/")#var("n")#cmd(")").

Written in REXX and carried in the load module.

```
SAY root(27, 3)            /* 3, possibly with a rounding error */
```

== Encryption and Hashing <ext-kernel-crypt>

=== ENCRYPT <ext-kernel-encrypt>

#idx("ENCRYPT")
```
ENCRYPT(string, password [, rounds])
```
Encrypts #var("string") with #var("password") in #var("rounds") rounds
(default 7; 0 also means 7). Each round shifts every byte by a value
derived from the password and XORs the string with a rotated copy of the
password. The result is as long as #var("string") and may contain any
byte value. With a null #var("password"), #var("string") is returned
unchanged. The method keeps casual readers out; it is no protection
against a determined attack.

```
e = encrypt('The quick brown fox', 'myPassword')
SAY length(e)              /* 19 */
```

=== DECRYPT <ext-kernel-decrypt>

#idx("DECRYPT")
```
DECRYPT(string, password [, rounds])
```
Reverses #cmd("ENCRYPT"). #var("password") and #var("rounds") must be
those given to #cmd("ENCRYPT"); #var("rounds") defaults to 7 in both.
Before BREXX/370 3.0, #cmd("DECRYPT") ran a single round and did not
give back what #cmd("ENCRYPT") had made.

#note[*Text encrypted before BREXX/370 3.0.* With a password of 7
characters or fewer and the default of 7 rounds -- more generally, with
at least as many rounds as the password has characters -- the older
#cmd("ENCRYPT") fed a stray byte into the key, and such text may not
decrypt. Text encrypted with a password of 8 characters or more, or with
fewer rounds than the password has characters, decrypts unchanged.]

```
e = encrypt('Hello World', 'secret')
SAY decrypt(e, 'secret')                    /* Hello World */
SAY decrypt(encrypt('abc', 'k', 3), 'k', 3) /* abc         */
```

=== RHASH <ext-kernel-rhash>

#idx("RHASH")
```
RHASH(string [, slots])
```
Returns a hash value of #var("string") from 0 to #var("slots") minus 1,
computed as a polynomial rolling hash. #var("slots") defaults to
2147483647. Different strings may give the same value.

```
SAY rhash('abc') = rhash('abc')   /* 1      */
h = rhash('abc', 10)              /* 0 to 9 */
```

== Date and Time <ext-kernel-date>

The built-in functions #cmd("DATE") and #cmd("TIME") already accept the
BREXX formats, among them input formats for #cmd("DATE") and the
#cmd("MS"), #cmd("US"), #cmd("HS"), #cmd("LS") and #cmd("CPU") options of
#cmd("TIME"); see @lang-builtin-date and @lang-builtin-time.

=== DATETIME <ext-kernel-datetime>

#idx("DATETIME")
```
DATETIME([format [, timestamp [, input-format]]])
```
Converts a time stamp from #var("input-format") into #var("format").
Without #var("timestamp"), the current date and time are used.

#deflist(width: 1.2in,
  [#cmd("T")], [Seconds since 1 January 1970: #cmd("1615310123").],
  [#cmd("O")], [Ordered: #cmd("2020/12/09-11:41:13") (the default
    #var("format")).],
  [#cmd("E")], [European: #cmd("09/12/2020-11:41:13").],
  [#cmd("EI")], [European with hyphens: #cmd("09-12-2020-11:41:13");
    output only.],
  [#cmd("U")], [USA: #cmd("12/09/2020-11:41:13").],
  [#cmd("UI")], [USA with hyphens: #cmd("12-09-2020-11:41:13"); output
    only.],
  [#cmd("B")], [Base: #cmd("Wed Dec  9 11:41:13 2020").],
)

#var("input-format") is one of #cmd("T"), #cmd("O"), #cmd("E"),
#cmd("U") and #cmd("B"), and is needed whenever #var("timestamp") is
given: without it, the call ends in error 40, #cmd("invalid input
format"). An input date may separate its parts with any
of #cmd(", : . ; / -") or blanks; a month may be given by the first
three letters of its English name.

Written in REXX and carried in the load module.

The conversion from #cmd("T") into #cmd("B"), #cmd("O"), #cmd("E") or
#cmd("U") gives local time, by the time zone of the system\; the
conversion into #cmd("T") takes its input as is, without the time zone.
On a system whose time zone is not UTC, converting a time stamp into
#cmd("T") and back therefore changes it by the time-zone offset.

```
t = datetime('T')                       /* e.g. 1791454873         */
SAY datetime('E', t, 'T')               /* e.g. 08/10/2026-10:21:13 */
SAY datetime('T', '2026/10/08-10:21:13', 'O')
```

=== EPOCH2DATE <ext-kernel-epoch2date>

#idx("EPOCH2DATE")
```
EPOCH2DATE(seconds)
```
Converts a Unix time stamp, the seconds since 1 January 1970, into the
date in European format, a blank and the time as #cmd("hh:mm:ss"). The
date is made by #cmd("RXDATE"), a member of #cmd("RXLIB"), which must
therefore be allocated.

Written in REXX and carried in the load module.

```
SAY epoch2date(1600630022)        /* e.g. 20/09/2020 19:27:02 */
```

=== SEC2TIME <ext-kernel-sec2time>

#idx("SEC2TIME")
```
SEC2TIME(seconds [, 'DAYS' [, label]])
```
Formats a number of seconds as #cmd("hh:mm:ss"), the hours counting on
past 24, with as many digits as they need: 360000 seconds are
#cmd("100:00:00"). With #cmd("DAYS") (or #cmd("D")), whole days are split off and
put in front, followed by #var("label") in uppercase, which defaults to
#cmd("day(s)"). Fractions of a second are dropped.

Written in REXX and carried in the load module.

```
SAY sec2time(3725)                    /* 01:02:05             */
SAY sec2time(1339432, 'DAYS')         /* 15 day(s) 12:03:52   */
SAY sec2time(1339432, 'D', 'Tage')    /* 15 TAGE 12:03:52     */
```

=== IPLDATE <ext-kernel-ipldate>

#idx("IPLDATE")
```
IPLDATE([format])
```
Returns the date and time of the last IPL: the date in the
#cmd("DATE") format #var("format") (@lang-builtin-date), a blank, and
the time as #cmd("hh:mm:ss"). It is computed from
#cmd("MVSVAR('MVSUP')") (@ext-tso-mvsvar), so it may be off by a second.

Written in REXX and carried in the load module.

```
SAY ipldate()              /* e.g. 23/09/2026 08:12:40 */
SAY ipldate('S')           /* e.g. 20260923 08:12:40   */
```

== Variables and Procedures <ext-kernel-vars>

=== DEFINED <ext-kernel-defined>

#idx("DEFINED")
```
DEFINED(name)
```
Tells whether a variable has a value. Quote #var("name"), or the value of
the variable is tested instead of its name.

#deflist(width: 1.2in,
  [#cmd("-1")], [#var("name") is not a valid symbol.],
  [#cmd("0")], [The variable has no value.],
  [#cmd("1")], [The variable has a value that is not a number.],
  [#cmd("2")], [The variable has a numeric value.],
)

Written in REXX and carried in the load module.

```
a = 'x'; b = 5
SAY defined('a') defined('b') defined('c')   /* 1 2 0 */
IF defined('myvar') > 0 THEN SAY 'set'
```

=== LISTIT <ext-kernel-listit>

#idx("LISTIT")
```
LISTIT([prefix])
```
Writes the variables of the current procedure whose names start with
#var("prefix") to the terminal, or all of them without #var("prefix"). A
stem is listed with all its elements. Quote #var("prefix").

```
v2 = 'simple Variable'
v21.1 = 'Stem Variable, item 1'
CALL listit 'V2'
/* List Variables with Prefix 'V2'          */
/* -------------------------------          */
/* [0001]  "V2" => "simple Variable"        */
/* [0002]  "V21." =>                        */
/* >[0001] "|.1" => "Stem Variable, item 1" */
```

=== VLIST <ext-kernel-vlist>

#idx("VLIST")
```
VLIST([pattern [, option [, stem]]])
```
Returns the variables of the current procedure that match
#var("pattern"), one per line, each line ending with a newline. A
pattern is a name of up to five parts separated by periods; #cmd("*")
stands for any value in that place. A pattern of one part selects every
variable whose name contains it; a pattern of more parts selects stem
elements, the first part being the stem name. A pattern ending in a
period lists the whole stem. Without #var("pattern"), every variable is
listed. #cmd("VLIST.0") is set to the number of variables listed, stem
elements included.

#deflist(width: 1.2in,
  [#cmd("V")], [Values: each line is #var("name")#cmd("=\"")#var("value")#cmd("\"")
    (the default).],
  [#cmd("N")], [Names only.],
  [#cmd("A")], [As: list the elements of the stem in #var("pattern")
    under the stem name #var("stem"); both must end in a period.],
)

```
ADDRESS.PEJ.CITY = 'Munich'
ADDRESS.MIG.CITY = 'Berlin'
ADDRESS.MIG.PUB  = 'Steakhaus'
SAY vlist('ADDRESS.*.CITY')
/* ADDRESS.MIG.CITY="Berlin" */
/* ADDRESS.PEJ.CITY="Munich" */
SAY vlist('ADDRESS.MIG', 'N')
/* ADDRESS.MIG.CITY          */
/* ADDRESS.MIG.PUB           */
```

=== DUMPVAR <ext-kernel-dumpvar>

#idx("DUMPVAR")
```
DUMPVAR(name)
```
Writes the value of variable #var("name") to the terminal in hexadecimal
and as characters, as #cmd("DUMPIT") does, under a heading with the
name and length. The dump shows the length of the value plus 8 bytes.
Quote #var("name"). Returns 0.

Written in REXX and carried in the load module.

```
v21.1 = 'Stem Variable, item 1'
CALL dumpvar 'v21.1'
```

=== LEVEL <ext-kernel-level>

#idx("LEVEL")
```
LEVEL()
```
Returns the current procedure level: 0 in the main program, one more for
each #cmd("CALL") or function call that has not yet returned.

#note[With an argument, #cmd("LEVEL") writes a line #cmd("level")
#var("n") to the terminal and returns no value. This form is a
debugging aid.]

```
SAY level()              /* 0 */
CALL sub
EXIT
sub: SAY level()         /* 1 */
RETURN
```

=== ARGV <ext-kernel-argv>

#idx("ARGV")
```
ARGV(n [, level])
```
Returns the #var("n")th argument of a procedure further up the call
chain, or the null string if it has no such argument.
#cmd("ARGV(0,")#var("level")#cmd(")") returns the number of its
arguments.

#deflist(width: 1.2in,
  [#cmd("0")], [The current procedure.],
  [#cmd("-1")], [Its caller (the default); #cmd("-2") the caller's
    caller, and so on.],
  [#cmd("1"), #cmd("2"), ...], [Counted from the main program upwards.
    A level beyond the current one means the current one.],
)

```
/* main, called as: RX MAIN EUROPE */
CALL sub1 'Germany', 'Italy'
EXIT
sub1: CALL sub2 'Munich', 'Rome'; RETURN
sub2:
SAY argv(1, 0)           /* Munich */
SAY argv(2, -1)          /* Italy  */
SAY argv(1, -2)          /* EUROPE */
RETURN
```

=== LOADRX <ext-kernel-loadrx>

#idx("LOADRX")
```
LOADRX(source, lines, name)
```
Makes a routine called #var("name") from lines of REXX source held in
the program. With #var("source") #cmd("STEM"), the lines are in the stem
#var("lines") (#var("lines")#cmd("0") holding their number); with any
other #var("source"), #var("lines") is the number of a string array
(@ext-array). After the call, #var("name") can be called like an
external routine. The source is kept in the global variable store
(@ext-global) under #var("name"). Returns 0.

The routine is searched for after #cmd("RXLIB") and the library of the
main program, so a member of the same name there wins.

Written in REXX and carried in the load module.

Once called, a routine stays loaded: a second #cmd("LOADRX") of the
same name has no effect.

```
x.1 = 'c = arg(1) + 1'
x.2 = 'return c * 2'
x.0 = 2
CALL loadrx 'STEM', 'x.', 'MYCALC'
SAY mycalc(4)            /* 10 */
```

=== GETDATA <ext-kernel-getdata>

#idx("GETDATA")
```
GETDATA([exec])
```
Reads the data sections of the running exec, or of #var("exec"), into
variables or arrays. A data section is a comment whose first line names
the target, and whose other lines are the data:

```
/* DATA STEM BANDS.
LED ZEPPELIN       STAIRWAY TO HEAVEN
EAGLES             HOTEL CALIFORNIA
*/
```

The third word of the first line is the kind of target, the fourth its
name:

#deflist(width: 1.2in,
  [#cmd("STEM")], [The lines go into the stem, #var("stem")#cmd("0")
    holding their number.],
  [#cmd("SARRAY")], [A string array is created; its number is assigned
    to the variable.],
  [#cmd("IARRAY")], [An integer array is created; its number is assigned
    to the variable.],
  [#cmd("FARRAY")], [A float array is created; its number is assigned
    to the variable.],
)

The arrays are described in @ext-array; none needs to exist before the
call. A section ends with the line holding #cmd("*/"). Any other kind
ends the program with #cmd("invalid GETDATA syntax").

Written in REXX and carried in the load module.

```
CALL getdata
DO i = 1 TO bands.0
  SAY i bands.i     /* 1 LED ZEPPELIN       STAIRWAY TO HEAVEN */
END
```

=== SGETREXX <ext-kernel-sgetrexx>

#idx("SGETREXX")
```
SGETREXX([exec])
```
Returns the number of a new string array (@ext-array) that holds the
source of #var("exec"), one line per element. Without #var("exec"), the
source of the running exec is taken. Free the array with #cmd("SFREE")
when it is no longer needed. #cmd("GETDATA") reads data sections this
way.

Written in REXX and carried in the load module.

The source is split at the newline character #cmd("'15'X"), and blank
lines are dropped, so the element numbers are not the line numbers of the
source. The same holds for #cmd("GETDATA").

#note[*To be confirmed:* which exec "the running exec" is when
#cmd("SGETREXX") is called from an external routine was not checked.]

```
s = sgetrexx()
SAY sarray(s)            /* number of source lines */
CALL sfree s
```

=== STEM2STR <ext-kernel-stem2str>

#idx("STEM2STR")
```
STEM2STR(stem)
```
Returns the elements #var("stem")#cmd("1") to #var("stem")#var("n") of
a stem, where #var("stem")#cmd("0") is #var("n"), joined into one string
with a semicolon before each element and one at the end. Quote the stem
name. #cmd("LOADRX") uses it to turn a stem of REXX lines into one
string of clauses.

Written in REXX and carried in the load module.

```
x.1 = 'a = 1'; x.2 = 'say a'; x.0 = 2
SAY stem2str('x.')       /* ;a = 1;say a; */
```

=== XPULL <ext-kernel-xpull>

#idx("XPULL")
```
XPULL()
```
Returns the next line from the stack, as #cmd("PARSE PULL") reads it:
without changing it to uppercase, unlike #cmd("PULL").

Written in REXX and carried in the load module.

```
QUEUE 'Mixed Case'
SAY xpull()              /* Mixed Case */
```

=== TYPE <ext-kernel-type>

#idx("TYPE")
```
TYPE(value)
```
Returns #cmd("INTEGER"), #cmd("REAL") or #cmd("STRING"): how the
interpreter holds #var("value"), or would hold it as a number. A faster
form of #cmd("DATATYPE") for telling numbers from strings.

```
SAY type(42) type(4.2) type('abc')   /* INTEGER REAL STRING */
```

=== STEMHI <ext-kernel-stemhi>

#idx("STEMHI")
```
STEMHI(stem)
```
Returns the highest numeric tail set in #var("stem"), regardless of
#var("stem")#cmd("0"), or 0 if there is none. For a compound stem such
as #cmd("'A.B.'"), the highest #var("n") of #cmd("A.B.")#var("n") is
returned. Quote the stem name; a missing final period is added.

```
x.1 = 'a'; x.7 = 'b'; x.0 = 2
SAY stemhi('x.')           /* 7 */
```

=== STEMCOPY <ext-kernel-stemcopy>

#idx("STEMCOPY")
```
STEMCOPY(source, target)
```
Copies #var("source")#cmd("0") to #var("source")#var("n") into the same
tails of #var("target"), where #var("n") is the value of
#var("source")#cmd("0"), and returns #var("n"). Quote both stem names,
with their periods. A missing name, or a #var("source")#cmd("0") that is
not a number, ends the program with a message.

Written in REXX and carried in the load module.

```
a.1 = 'x'; a.2 = 'y'; a.0 = 2
SAY stemcopy('a.', 'b.') b.2   /* 2 y */
```

=== ARGIN <ext-kernel-argin>

#idx("ARGIN")
```
ARGIN(n [, , stem])
```
In a procedure, makes the variable whose name was passed as the
#var("n")th argument available as if it were exposed, and returns that
name in uppercase. If the name does not occur as a symbol anywhere in
the program, #cmd("-1") is returned. A third argument is accepted and
ignored: the old documentation said it listed the stem under another
name, which 3.0 does not do.

#note[*To be confirmed:* the exact effect. The 3.0 source exposes the
variable in the current procedure; how this interacts with
#cmd("PROCEDURE EXPOSE") and nested calls was not measured.]

```
CALL show 'CITY.'
EXIT
show: PROCEDURE
  name = argin(1)          /* CITY. */
RETURN
```

== Storage <ext-kernel-storage>

The #cmd("PEEK") functions take a storage address as a decimal number and
read with #cmd("STORAGE") (@lang-builtin-storage).

=== PEEKS <ext-kernel-peeks>

#idx("PEEKS")
```
PEEKS(address, length)
```
Returns #var("length") bytes of storage from #var("address"); the same as
#cmd("STORAGE(D2X(")#var("address")#cmd("),")#var("length")#cmd(")").

Written in REXX and carried in the load module.

```
SAY c2x(peeks(peeka(16), 8))     /* the first 8 bytes of the CVT */
```

=== PEEKA <ext-kernel-peeka>

#idx("PEEKA")
```
PEEKA(address)
```
Returns the fullword at #var("address") as a decimal number, typically
an address to pass on to the next #cmd("PEEK").

Written in REXX and carried in the load module.

```
cvt = peeka(16)          /* the CVT address, from location 16 */
```

=== PEEKU <ext-kernel-peeku>

#idx("PEEKU")
```
PEEKU(address)
```
Returns the fullword at #var("address") as an unsigned decimal number,
as #cmd("C2U") converts it.

Written in REXX and carried in the load module.

=== PEEKN <ext-kernel-peekn>

#idx("PEEKN")
```
PEEKN(address, length)
```
Returns #var("length") bytes at #var("address") as a decimal number, as
#cmd("C2D") converts them.

Written in REXX and carried in the load module.

=== DUMPIT <ext-kernel-dumpit>

#idx("DUMPIT")
```
DUMPIT(address, length)
```
Writes #var("length") bytes of storage from #var("address") to the
terminal, 16 bytes a line, in hexadecimal and as characters.
#var("address") is hexadecimal, so convert a decimal address with
#cmd("D2X"). With one argument, nothing is written.

```
CALL dumpit d2x(peeka(16)), 32
/* address  (+offset)   | four words in hex          | characters */
```

=== MEMORY <ext-kernel-memory>

#idx("MEMORY")
```
MEMORY(['NOPRINT'])
```
Returns the storage the program can still obtain, in bytes, as the sum
of the free blocks it finds. Without an argument it also writes the
blocks, largest first, to the terminal. With an argument that starts
with #cmd("N"), nothing is written.

```
SAY memory('N')          /* e.g. 2398208 */
CALL memory
/* MVS Free Storage Map           */
/* ---------------------------    */
/* AT ADDR  7909376    1176 KB    */
/* ...                            */
```

== System and Job <ext-kernel-system>

=== USERID <ext-kernel-userid>

#idx("USERID")
```
USERID()
```
Returns the user ID the program runs under, in TSO and in batch.

```
SAY userid()             /* e.g. IBMUSER */
```

=== JOBINFO <ext-kernel-jobinfo>

#idx("JOBINFO")
```
JOBINFO()
```
Returns the job name and sets these variables of the caller:

#deflist(width: 1.2in,
  [#cmd("JOB.NAME")], [The job name (the user ID in TSO).],
  [#cmd("JOB.NUMBER")], [The job number, for example
    #cmd("JOB00123") or #cmd("TSU02077").],
  [#cmd("JOB.STEP")], [The step name, as
    #var("procstep")#cmd(".")#var("step") when the step runs in a
    procedure.],
  [#cmd("JOB.PROGRAM")], [The program of the step, for example
    #cmd("IKJEFT01").],
)

Written in REXX and carried in the load module.

```
SAY jobinfo()            /* IBMUSER  */
SAY job.number           /* TSU02077 */
SAY job.program          /* IKJEFT01 */
```

=== VERSION <ext-kernel-version>

#idx("VERSION")
```
VERSION(['FULL'])
```
Returns the BREXX/370 version, the second word of
#cmd("PARSE VERSION") (@lang-instr). With #cmd("FULL") or any
abbreviation of it, the result is #cmd("Version") #var("version")
#cmd("Build Date") #var("day")#cmd(".") #var("month") #var("year").

Written in REXX and carried in the load module.

```
SAY version()            /* e.g. 3.0.0                                */
SAY version('F')         /* e.g. Version 3.0.0 Build Date 8. Oct 2026 */
```

=== RXLIST <ext-kernel-rxlist>

#idx("RXLIST")
```
RXLIST([option [, name]])
```
Reports the execs the interpreter has loaded, the main exec first, and
returns their number. Only the first letter of #var("option") counts,
and it is not translated to uppercase: #cmd("rxlist('s')") writes the
table.

#deflist(width: 1.2in,
  [(none)], [Write a table of name, member, DD name and data set name to
    the terminal.],
  [#cmd("S")], [Stem: set #cmd("RXLIST.")#var("i") to the name,
    member, DD name and data set name, separated by blanks, and
    #cmd("RXLIST.0").],
  [#cmd("L")], [List: set #cmd("RXLIST.")#var("i") to the names only.],
  [#cmd("R")], [Remove #var("name") from the list: 0 if it was found,
    #cmd("-1") if not.],
)

```
CALL rxlist
/* Loaded Rexx Modules                          */
/*     REXX      Member   DDNAME   DSN          */
/* -------------------------------------------- */
/*   1 #RXL      RXL      SYSUEXEC PEJ.EXEC     */
/*   2 RXSORT    RXSORT   RXLIB    BREXX.RXLIB  */
```

=== BLDL <ext-kernel-bldl>

#idx("BLDL")
```
BLDL(program)
```
Returns 1 if the load module #var("program") can be found in the
program search order of the task (#cmd("STEPLIB") or #cmd("JOBLIB"),
the link list), 0 if not.

```
IF bldl('IEBGENER') THEN SAY 'IEBGENER is available'
```

=== SUBMIT <ext-kernel-submit>

#idx("SUBMIT")
```
SUBMIT(source [, array])
```
Writes JCL to the internal reader, which submits it as a job. The JCL
comes from:

#deflist(width: 1.2in,
  [#var("dsname")], [A data set or member, named as in TSO: in quotes
    when fully qualified, else prefixed.],
  [#var("stem")#cmd(".")], [A stem: #var("stem")#cmd("1") to
    #var("stem")#var("n"), where #var("stem")#cmd("0") is
    #var("n").],
  [#cmd("*")], [The stack: every line queued.],
  [#cmd("SARRAY")], [The string array whose number is #var("array").],
  [#cmd("LLIST")], [The linked list whose number is #var("array").],
)

Returns 0 if the JCL was written, #cmd("-1") if the internal reader could
not be allocated, #cmd("-2") if it could not be opened, #cmd("-3") if the
data set could not be opened. An empty stack, stem or array returns 0;
nothing is submitted. Any #var("source") that ends in a period is taken
for a stem, and any that contains #cmd("SARRAY") or #cmd("LLIST") for an
array or list. The internal reader does not know the user, so
#cmd("&SYSUID") in the JCL is not replaced, and no #cmd("SUBMITTED")
message is written.

```
CALL submit "'IBMUSER.JCL(COMPILE)'"
CALL submit 'job.'
QUEUE '//IBMUSERA JOB CLASS=A'; QUEUE '//S1 EXEC PGM=IEFBR14'
CALL submit '*'
```

=== WAIT <ext-kernel-wait>

#idx("WAIT")
```
WAIT(milliseconds)
```
Suspends the program for #var("milliseconds") thousandths of a second.

```
CALL wait 1000           /* one second */
```

=== WTO <ext-kernel-wto>

#idx("WTO")
```
WTO(message)
```
Writes #var("message") to the operator console; it also appears in the
job log. Returns 0.

```
CALL wto 'BACKUP COMPLETED'
```

=== ABEND <ext-kernel-abend>

#idx("ABEND")
```
ABEND(code)
```
Ends the program with user abend #var("code"), a number from 1 to 3999.

```
CALL abend 100           /* U0100 */
```

=== STCSTOP <ext-kernel-stcstop>

#idx("STCSTOP")
```
STCSTOP()
```
In a started task, returns 1 if the operator has entered a
#cmd("STOP") (#cmd("P")) command for it, else 0. Outside a started task
the result is 0. A program that runs as a started task tests it in its
main loop and ends when it is 1.

```
DO FOREVER
  IF stcstop() = 1 THEN DO
    CALL wto 'STC STOP COMMAND RECEIVED'
    LEAVE
  END
  CALL wait 1000
  /* the work of the started task */
END
```

=== LOCK <ext-kernel-lock>

#idx("LOCK")
```
LOCK(resource [, mode [, timeout]])
```
Serialises the use of #var("resource"), any string such as a data set
name, with programs that lock the same name. Returns 0 when the lock is
held and 4 when it could not be had within #var("timeout")
milliseconds; without #var("timeout"), #cmd("LOCK") tries once. With
#cmd("TEST") it returns the return code of the #cmd("ENQ") as it
stands.
#var("mode") is matched by its first letter:

#deflist(width: 1.2in,
  [#cmd("SHARED")], [Others may hold shared locks at the same time, but
    no exclusive one (the default).],
  [#cmd("EXCLUSIVE")], [No other program may hold the resource.],
  [#cmd("TEST")], [Only tells whether the resource is free; nothing is
    locked.],
)

While waiting, #cmd("LOCK") retries every 100 milliseconds and counts
the attempts in the variable #cmd("LCKTRY"). A null #var("resource") ends
the program.

Written in REXX and carried in the load module.

```
IF lock('PAYROLL.MASTER', 'EXCLUSIVE', 5000) = 0 THEN DO
  /* update the data sets */
  CALL unlock 'PAYROLL.MASTER'
END
```

=== UNLOCK <ext-kernel-unlock>

#idx("UNLOCK")
```
UNLOCK(resource)
```
Releases a lock taken by #cmd("LOCK"). Returns 0 if it was released.

Written in REXX and carried in the load module.

=== ENQ <ext-kernel-enq>

#idx("ENQ")
```
ENQ(resource, flags)
```
Issues an MVS #cmd("ENQ") (SVC 56) for #var("resource"), changed to
uppercase, under the major name #cmd("BREXX370"), and returns the
return code of the request. #var("flags") is the ENQ option byte as a
decimal number; #cmd("LOCK") uses these:

#deflist(width: 1.2in,
  [#cmd("67")], [Exclusive, #cmd("RET=USE").],
  [#cmd("195")], [Shared, #cmd("RET=USE").],
  [#cmd("71")], [Exclusive, #cmd("RET=TEST").],
  [#cmd("64")], [Exclusive, unconditional: waits.],
  [#cmd("192")], [Shared, unconditional: waits.],
)

Prefer #cmd("LOCK") and #cmd("UNLOCK"), which choose the flags.

```
IF enq('MY.RESOURCE', 67) = 0 THEN SAY 'held'
```

=== DEQ <ext-kernel-deq>

#idx("DEQ")
```
DEQ(resource, flags)
```
Issues an MVS #cmd("DEQ") (SVC 48) for #var("resource") under the major
name #cmd("BREXX370") and returns its return code. #cmd("UNLOCK") uses
the flags 65.

```
CALL deq 'MY.RESOURCE', 65
```

=== RACCHECK <ext-kernel-raccheck>

#idx("RACCHECK")
```
RACCHECK(class, profile, access)
```
Asks RAKF whether the user has #var("access") (#cmd("READ"),
#cmd("UPDATE"), #cmd("CONTROL") or #cmd("ALTER")) to #var("profile") in
#var("class"). Returns 1 if so, 0 if not. A class longer than 8, a
profile longer than 44 or a null one gives 0. Without RAKF, every check
gives 1. The answers are kept for the rest of the run, so a change in
RAKF during the run is not seen.

```
IF raccheck('FACILITY', 'SVC244', 'READ') THEN SAY 'may use PRIVILEGE'
```

=== SCANDD <ext-kernel-scandd>

#idx("SCANDD")
```
SCANDD()
```
Returns the number of a new string array (@ext-array) with one element
for each DD of the step, read from the TIOT, in the form
#cmd("#")#var("ddname") #cmd("$")#var("dsname") #cmd("*")#var("member").
A concatenated data set has a blank DD name in the TIOT and is given the
name of the DD before it. #cmd("SYSALC") (@ext-tso-sysalc) is built on
it.

Written in REXX and carried in the load module.

```
s = scandd()
CALL slist s     /* e.g. #SYSEXEC $IBMUSER.EXEC * ... */
CALL sfree s
```

=== CLRSCRN <ext-kernel-clrscrn>

#idx("CLRSCRN")
```
CLRSCRN()
```
Clears the screen by issuing the TSO command #cmd("CLS") and returns 0.

Written in REXX and carried in the load module.

#note[*To be confirmed:* #cmd("CLS") is not part of BREXX/370 or of its
command library; #cmd("CLRSCRN") works only where such a command is
installed.]

=== ERROR <ext-kernel-error>

#idx("ERROR")
```
ERROR(message)
```
Ends the program with error 40 and #var("message"), changed to
uppercase, as the explanation. It is the way the functions written in
REXX report a wrong call, and a program can use it in the same way.

```
IF arg(1) = '' THEN CALL error 'data set name missing'
```

== Operator Console <ext-kernel-console>

The functions in this section are defined only for users with
#cmd("READ") access to the RAKF profile #cmd("SVC244") in class
#cmd("FACILITY"). For anyone else, a call ends in error 43 (_Routine not
found_). They run the console services with the privilege of that
profile and drop it afterwards; a #cmd("PRIVILEGE('ON')") the program set
itself stays in effect.

=== CONSOLE <ext-kernel-console-fn>

#idx("CONSOLE")
```
CONSOLE(command)
```
Issues #var("command"), changed to uppercase, as an operator command.
Returns 0 if the command was sent and 8 if the privilege was refused.
The output of the command is not returned; read it from the Master
Trace Table with #cmd("MTT").

A #var("command") longer than 124 characters ends in error 40. MVS itself
takes at most 100 characters of an operator command, so the characters
from 101 to 124 are cut off.

```
CALL console 'D A,L'
```

=== MTT <ext-kernel-mtt>

#idx("MTT")
```
MTT(['REFRESH'])
```
Copies the Master Trace Table, the recent console messages, into the
stem #cmd("_LINE."), oldest entry first, and returns the number of
entries. If the newest entry is the same as on the previous call, the
stem is left alone and the result is #cmd("-1"), unless #cmd("REFRESH")
(any word starting with #cmd("R")) is given. If the table cannot be
read, the result is #cmd("-1") and the message
#cmd("BREXX/370 MTT FUNCTION IN ERROR") goes to the console.

```
CALL mtt 'REFRESH'
DO i = 1 TO _line.0
  SAY _line.i
END
/* 4000 08.48.51 JOB  891  IEF403I BRXLINK - STARTED - TIME=08.48.51 */
```

=== MTTX <ext-kernel-mttx>

#idx("MTTX")
```
MTTX(option, array [, max [, search]])
```
Reads the Master Trace Table into the string array #var("array")
(@ext-array), newest entry first, and returns the number of entries the
array then holds. The array must exist; it is not resized, so create it
large enough (4000 elements or more). Only the first letter of
#var("option") counts:

#deflist(width: 1.2in,
  [#cmd("R")], [Refresh: replace the content of the array with the whole
    table.],
  [#cmd("N")], [No refresh: add the entries that are new since the last
    call at the end of the array (the default). An empty array is
    filled as with #cmd("R").],
  [#cmd("M")], [Modified: replace the content of the array with the new
    entries only.],
)

#var("max") limits the number of entries (by default the size of the
array; 0 ends in error 40); with #var("search"), only entries that contain that string are
taken. If nothing is new, the array is left alone and the result is
#cmd("-1"); so it is if the table cannot be read, with the message
#cmd("BREXX/370 MTT FUNCTION IN ERROR") on the console. With #cmd("M"),
the array is emptied before that check, so a call that finds nothing new
leaves it empty.

#note[*Defects* (brexx370 issue 386): #cmd("MTT") and #cmd("MTTX")
remember the newest entry in the same place, so a call of one changes
what the other regards as new. And both translate their first argument
to uppercase in place: after #cmd("CALL mtt opt"), the variable
#cmd("OPT") of the caller is in uppercase. Given as a literal, the
argument changes every equal literal of the exec.]

```
s = screate(4000)
n = mttx('R', s, , '$HASP373')    /* the job starts still in the table */
DO i = 1 TO n
  SAY sget(s, i)
END
CALL sfree s
```
