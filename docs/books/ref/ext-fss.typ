#import "../bookmaster/bookmaster.typ": *

= The FSS Host Command Environment <ext-fss>

#idx("FSS")#idx("formatted screen")
The formatted screen services (FSS) build a 3270 screen of protected text
and input fields, show it at the terminal, and read back what the user
typed. They are based on Tommy Sprinkle's TSO Full-Screen Services.

The interpreter provides them as the host command environment
#cmd("ADDRESS FSS"), described in this chapter. The function interface
that most execs use -- #cmd("FSSINIT"), #cmd("FSSFIELD"),
#cmd("FSSDISPLAY") and the others -- and the menu and list functions are
written in REXX on top of it and come with RXLIB; the _BREXX/370 Library
and Samples_ describes them. An exec uses FSS at a TSO terminal only.

== Commands <ext-fss-commands>

The words of a command are separated by blanks, commas or parentheses.
Where a command takes a text or a value, it takes the _name of a
variable_ that holds it, not the text itself. Every command but
#cmd("INIT") needs the services started: without them #cmd("TERM"),
#cmd("RESET") and #cmd("TEST") answer return code 4, and every other command
ends the exec with REXX error 69, _FSS not initialised_.

=== INIT <ext-fss-init>

#idx("FSS", "INIT")
```
INIT
```
Starts the screen services and sets variables for the attributes and the
attention keys (@ext-fss-vars). Return code 4 if they are started
already.

=== TERM and RESET <ext-fss-term>

#idx("FSS", "TERM")#idx("FSS", "RESET")
```
TERM
RESET
```
#cmd("TERM") ends the screen services and gives the terminal back to TSO;
#cmd("RESET") clears the screen definition and keeps them started. Both
answer 4 when the services are not started.

=== TEXT <ext-fss-text>

#idx("FSS", "TEXT")
```
TEXT row col attr varname
```
Defines a protected text at #var("row") and #var("col"), with the value of
the variable #var("varname"). #var("attr") is a number, or names of
attributes run together, such as #cmd("#PROT#HI#RED"): each name found in
it adds its value (@ext-fss-vars). #cmd("#ATTR") takes the value of the
variable #cmd("#ATTR").

```
ADDRESS FSS
title = 'Customer data'
'TEXT 1 2 #PROT#HI#WHITE title'
```

=== FIELD <ext-fss-field>

#idx("FSS", "FIELD")
```
FIELD row col attr name length varname
```
Defines an input field #var("name") of #var("length") characters at
#var("row") and #var("col"), showing first the value of the variable
#var("varname"). #var("attr") must be a number here, such as the value of
#cmd("#HI") or the sum of several.

=== STATIC <ext-fss-static>

#idx("FSS", "STATIC")
```
STATIC
```
Begins the fixed part of the screen: the #cmd("TEXT") and #cmd("FIELD")
definitions that follow it are kept by #cmd("RESET"), which clears only
the rest. Each #cmd("STATIC") replaces the fixed part defined before.

=== SET <ext-fss-set>

#idx("FSS", "SET")
```
SET FIELD name varname
SET CURSOR name
SET CURPOS position
SET COLOR name attr
```
#cmd("SET FIELD") puts the value of #var("varname") into the field
#var("name"). #cmd("SET CURSOR") puts the cursor at the start of the field,
#cmd("SET CURPOS") at a position of the screen, counted from 0.
#cmd("SET COLOR") changes the attributes of a field or text; #var("attr")
is written as for #cmd("TEXT"). Any other keyword gives return code -1.

=== GET <ext-fss-get>

#idx("FSS", "GET")
```
GET FIELD name varname
GET AID varname
GET CURPOS varname
GET WIDTH varname
GET HEIGHT varname
GET METRICS varname what
```
Store into the variable #var("varname"): the contents of the field
#var("name"); the attention key the user pressed, to compare with
#cmd("#ENTER"), #cmd("#PFK01") and the others; the cursor position; the
width or the height of the screen. Any other keyword gives return code -1.

#cmd("GET METRICS") stores a description of the screen definition;
#var("what") is #cmd("DETAILS") or #cmd("FIELDS").

=== SHOW and REFRESH <ext-fss-show>

#idx("FSS", "SHOW")#idx("FSS", "REFRESH")
```
SHOW [clear]
REFRESH [milliseconds [clear]]
```
#cmd("SHOW") writes the screen and waits until the user presses an
attention key. #cmd("REFRESH") writes it as well; with #var("milliseconds")
it returns after that time if no key was pressed, with the attention key
4711, which lets an exec update a screen in intervals. #var("clear") (0 or 1) says whether the screen is
erased first; #cmd("SHOW") does not erase by default, #cmd("REFRESH") does.

=== CHECK <ext-fss-check>

#idx("FSS", "CHECK")
```
CHECK FIELD name
CHECK POS row col
```
#cmd("CHECK FIELD") answers 0 if the field exists and 4 if it does not.
#cmd("CHECK POS") answers 4 if a field or a fixed text begins exactly at
that position, and puts its name into the variable #cmd("_fssField")\; 0 if
none does, -1 if #var("row") or #var("col") is not a number. Any other
keyword answers -3.

=== TEST <ext-fss-test>

#idx("FSS", "TEST")
```
TEST
```
Answers 0 when the screen services are started, 4 when they are not.

== Variables Set by INIT <ext-fss-vars>

#idx("FSS", "attribute variables")
#cmd("INIT") sets these variables, whose values an exec adds up for an
attribute or compares with the attention key:

#deflist(width: 1.6in,
  [Field attributes], [#cmd("#PROT"), #cmd("#NUM"), #cmd("#HI"),
    #cmd("#NON")],
  [Colours], [#cmd("#BLUE"), #cmd("#RED"), #cmd("#PINK"), #cmd("#GREEN"),
    #cmd("#TURQ"), #cmd("#YELLOW"), #cmd("#WHITE")],
  [Highlighting], [#cmd("#BLINK"), #cmd("#REVERSE"), #cmd("#USCORE")],
  [Attention keys], [#cmd("#ENTER"), #cmd("#PFK01") to #cmd("#PFK24"),
    #cmd("#CLEAR"), #cmd("#RESHOW")],
)
