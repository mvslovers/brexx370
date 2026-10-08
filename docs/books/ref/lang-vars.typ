#import "../bookmaster/bookmaster.typ": *

= Compound and Special Variables <lang-vars>

== Compound Variables <lang-vars-compound>

#idx("compound variable")#idx("stem")
A variable name that contains periods is compound: its first part, up to
and including the first period, is the stem, the rest the tail. Each part
of the tail that is a symbol is replaced by its value, and the resulting
name is the variable:

```
j = 5
a.j = 'fred'      /* sets A.5 */
```

The values are used as they are, without translation to uppercase: with
#cmd("t = 'ma'"), #cmd("a.t") is #cmd("A.ma"), a variable apart from
#cmd("A.MA"). Compound variables serve as arrays, as tables indexed by
strings, and for indirect addressing.

The stem alone stands for all variables that begin with it.
#cmd("a. = 0") gives every possible variable #cmd("A.")#var("tail") the
value 0; #cmd("DROP") and #cmd("PROCEDURE EXPOSE") with a stem act on all of
them.

== Special Variables <lang-vars-special>

#idx("RC")#idx("RESULT")#idx("SIGL")
Three variables are set by the interpreter:

#deflist(width: 1.2in,
  [#cmd("RC")], [the return code of the last host command. Return code -3
    means that the environment does not exist or is not available;
    #cmd("SYNTAX") conditions set it to the error number.],
  [#cmd("RESULT")], [the value that a routine called with #cmd("CALL")
    returned. It is dropped when the routine returns no value.],
  [#cmd("SIGL")], [the line number of the clause from which the last
    #cmd("CALL") or #cmd("SIGNAL") transferred control, or in which a
    trapped condition was raised.],
)
