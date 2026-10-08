#import "../bookmaster/bookmaster.typ": *

= Tokens, Terms and Expressions <lang-terms>

#idx("clause")
A REXX program is a sequence of clauses. A clause ends at the end of a line
or at a semicolon; a comma at the end of a line continues the clause on the
next. A string or a comment that is still open at the end of a line goes on
across it. This chapter describes the pieces a clause is made of, and how
they combine into expressions.

== Comments <lang-terms-comment>

#idx("comment")
A comment is any text between #cmd("/*") and #cmd("*/"), on one line or on
several. Comments may be nested: #cmd("/* outer /* inner */ outer */") is
one comment. An exec found in #cmd("SYSPROC") or #cmd("SYSUPROC") must
begin with a comment that contains the word #cmd("REXX") (_BREXX/370 User's
Guide_, “Finding and Calling Execs”).

== Strings <lang-terms-string>

#idx("string")#idx("hexadecimal string")#idx("binary string")
A string is a sequence of characters between two single or two double
quotes. A quote of the same kind inside the string is written twice. A
string directly followed by #cmd("X") is hexadecimal, by #cmd("B") binary:

```
"Marmita"
'He''s here'
'C1C2'x        /* 'AB' in EBCDIC */
'1100 0001'b   /* 'A'            */
```

The characters of a string are EBCDIC: #cmd("'C1'x") is the letter
#cmd("A"), not a hexadecimal value.

#note[*To be confirmed:* the old guide documents a suffix #cmd("H") that
makes a string a hexadecimal _number_ (#cmd("'10'h") is 16).]

== Numbers <lang-terms-number>

#idx("number")
A number is a string of decimal digits, with or without a decimal point,
optionally signed and in exponential notation: #cmd("23"),
#cmd("12.07"), #cmd("12.2e6"), #cmd("+5"), #cmd("'-3.14'"). A blank between
the sign and the digits is allowed. BREXX/370 holds a number as a 32-bit
integer or a double; see the _BREXX/370 User's Guide_, “Restrictions”, for
what that means for #cmd("NUMERIC DIGITS").

== Symbols <lang-terms-symbol>

#idx("symbol")
A symbol is a group of the characters #cmd("A")#sym.dots#cmd("Z"),
#cmd("a")#sym.dots#cmd("z"), #cmd("0")#sym.dots#cmd("9") and
#cmd("@ # $ _ . ? !"). Symbols are translated to uppercase. A symbol that
does not begin with a digit or a period may name a variable; its value is
then the value of the variable, or, if it has none, its own name in
uppercase. A symbol may be some 250 characters long.

== Function Calls <lang-terms-function>

#idx("function call")
A function call is a symbol or a string directly followed by a left
parenthesis, the arguments, separated by commas, and a right parenthesis:

```
COPIES('ab', 3)        /* 'ababab' */
```

The function may be internal (a label of the exec), built in, or external
(@lang-instr-call). It may take up to 32 arguments; a 33rd ends with error
40 when the exec is compiled. Any routine can be called as a function or
with #cmd("CALL"); called with #cmd("CALL"), its result is in the variable
#cmd("RESULT").

== Expressions <lang-terms-expr>

#idx("expression")#idx("operator")
An expression combines terms -- strings, symbols, numbers, function calls
and expressions in parentheses -- with operators. It is evaluated from
left to right, by the priority of the operators, highest first:

#tab(caption: [Operators, by priority])[
  #table(columns: (1.6in, 1fr),
    [Operator], [Meaning],
    [#cmd("+ - \\ ¬ ^") (prefix)], [plus, minus; not (the term must be
      0 or 1)],
    [#cmd("**")], [power; the exponent must be a whole number],
    [#cmd("* / % //")], [multiply, divide, integer divide, remainder],
    [#cmd("+ -")], [add, subtract],
    [blank, #cmd("||"), abuttal], [concatenate with a blank, without a
      blank, without a blank],
    [#cmd("= \\= > < >= <= >< <>") and their #cmd("¬")/#cmd("^") forms],
      [comparison: numeric if both terms are numbers, otherwise of the
      strings with leading and trailing blanks ignored],
    [#cmd("== \\== >> << >>= <<=")], [strict comparison: character by
      character, blanks included],
    [#cmd("&")], [and],
    [#cmd("| &&")], [or, exclusive or],
  )
] <lang-terms-op-tab>

```
'marmita' = ' marmita '    /* 1 */
'marmita' == ' marmita '   /* 0 */
'2' = ' 2 '                /* 1: numeric comparison */
5 % 3                      /* 1 */
5 // 3                     /* 2 */
2 ** -3                    /* 0.125 */
```

#idx("arithmetic", "precision")
Arithmetic is done in 32-bit integers or in double precision; it is not
rounded to #cmd("NUMERIC DIGITS") (_BREXX/370 User's Guide_,
“Restrictions”).
