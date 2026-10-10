#import "../bookmaster/bookmaster.typ": *

= Templates for PARSE, ARG and PULL <lang-templates>

#idx("template")#idx("PARSE", "template")
The instructions #cmd("PARSE"), #cmd("ARG") and #cmd("PULL") split a string
into variables by a template.

== Words <lang-templates-words>

The simplest template is a list of variables. Each takes one word of the
string; the last takes the rest:

```
PARSE VALUE 'one two three four ' WITH a b c
/* a = 'one', b = 'two', c = 'three four ' */
PARSE VALUE 'one two three four ' WITH a b c d e
/* a = 'one', ..., d = 'four', e = '' */
```

A period in place of a variable skips a word:

```
PARSE VALUE 'one two three four' WITH a . . d
/* a = 'one', d = 'four' */
```

== Patterns <lang-templates-patterns>

#idx("template", "pattern")
Patterns between the variables say where the string is split:

#deflist(width: 1.4in,
  [#var("n")], [a column: the string is split at character #var("n"),
    counted from 1.],
  [#cmd("=(")#var("name")#cmd(")")], [the column held in the variable
    #var("name").],
  [#cmd("+")#var("n"), #cmd("-")#var("n")], [a column relative to the
    previous one.],
  [#var("'string'")], [the next occurrence of the string; it is not part of
    either variable.],
  [#cmd("(")#var("name")#cmd(")")], [the next occurrence of the value of
    #var("name").],
)

```
PARSE VALUE 'one two three four' WITH 2 a 6 b
/* a = 'ne t', b = 'wo three four' */
PARSE VALUE 'one two three four' WITH 2 a +2 b
/* a = 'ne', b = ' two three four' */
PARSE VALUE 'marmita/bill/vivi' WITH a '/' b '/' c
/* a = 'marmita', b = 'bill', c = 'vivi' */
t = '%%'
PARSE VALUE 'aabbcc%%ddeeff%%gg' WITH . (t) middle (t) .
/* middle = 'ddeeff' */
```

== Several Strings <lang-templates-comma>

A comma in the template moves on to the next string, where there are
several -- the arguments of a routine:

```
CALL myproc 'Hi', 3, 4
...
myproc:
PARSE ARG first, second, third   /* 'Hi', 3, 4 */
```
