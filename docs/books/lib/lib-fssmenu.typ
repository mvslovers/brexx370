#import "../bookmaster/bookmaster.typ": *

= Formatted Screens: the FSS API, Menus and Dialogs <lib-fssmenu>

#idx("FSS")#idx("formatted screen")
The interpreter provides formatted 3270 screens through the host command
environment #cmd("ADDRESS FSS"), which the _BREXX/370 Reference_ describes
in "The FSS Host Command Environment". This chapter describes what RXLIB
builds on it:

- the FSS API, the RXLIB member #cmd("FSSAPI"): functions that define text
  and input fields, title, command and message lines, show the screen and
  read what the user typed;
- input screens laid out automatically: #cmd("FMTCOLUM")\;
- menus: #cmd("FSSMENU") and #cmd("FMTMENU")\;
- a scrollable list with line and primary commands: #cmd("FMTLIST")\;
- a list that refreshes itself at intervals: #cmd("FMTMON") and its
  variants.

All of them work at a TSO terminal only. The screen has the size the
terminal has: 24 rows of 80 columns on a model 2, more on the larger
models. #cmd("FSSWIDTH()") and #cmd("FSSHEIGHT()") tell an exec which.

== Samples <lib-fssmenu-samples>

The SAMPLES library holds these examples; the FSS samples begin with
#cmd("#"):

#deflist(width: 1.2in,
  [#cmd("#TSOAPPL")], [A menu built from single FSS API calls, with its own
    dialog loop.],
  [#cmd("#LOGON"), #cmd("#SELMEM")], [Further screens built with the FSS
    API.],
  [#cmd("#BROWSE")], [Shows the allocated data sets in #cmd("FMTLIST")
    instead of with #cmd("SAY").],
  [#cmd("#FSS1COL") \ to #cmd("#FSS4COL")], [Input screens with
    #cmd("FMTCOLUM"), in one to four columns.],
  [#cmd("#FSS4CLX")], [A four-column input screen with an input check.],
  [#cmd("FMTOPBOT")], [#cmd("FMTLIST") inside lines of the exec's own,
    above and below it, with primary and line commands.],
  [#cmd("@STUDENL")], [The front end of the VSAM student database sample,
    an #cmd("FMTLIST") application.],
  [#cmd("MTT")], [The master trace table in a self-refreshing
    #cmd("FMTMONAR") list.],
)

== Using the FSS API <lib-fssmenu-api>

#idx("FSSAPI")
The functions of the FSS API are labels in the RXLIB member
#cmd("FSSAPI"). An exec includes them with #cmd("IMPORT"), makes
#cmd("FSS") its host command environment and starts the screen services
with #cmd("FSSINIT"):

```
CALL IMPORT FSSAPI
ADDRESS FSS
CALL FSSINIT
```

The functions issue FSS commands without naming the environment, so
#cmd("ADDRESS FSS") must be in effect when they are called. An exec that
switches to another environment, #cmd("ADDRESS TSO") for example, must
switch back before it calls them again.

The functions have no #cmd("PROCEDURE") instruction: they run with the
variables of the exec. Besides the attribute and key variables of
@lib-fssmenu-attr they use names beginning with #cmd("FSS"), #cmd("_") and
#cmd("#"), and the stem #cmd("_screen.") for settings. Avoid such names for
variables of your own.

A screen is defined field by field and shown only when the exec calls
#cmd("FSSDISPLAY")\; the definitions are collected until then. There is one
screen definition at a time. To show a different screen, end the services
with #cmd("FSSTERM") and start them again, or clear the definition with the
FSS command #cmd("RESET"). Keeping each screen in a routine of its own
makes switching easy.

Positions are given as row and column, both counted from 1. Every text and
field begins with an attribute byte, which takes up the position given and
is not visible; the text or field itself begins one column further right.
A definition that does not fit on the screen ends the exec with a message
and return code 8. Other checks are few: overlapping definitions, for
example, are not detected.

== Attributes <lib-fssmenu-attr>

#idx("FSS", "attributes")
#cmd("FSSINIT") sets variables for the attributes of texts and fields.
Several are combined by adding them, such as #cmd("#PROT+#HI+#RED")\; give
one colour at most.

#deflist(width: 1.2in,
  [#cmd("#PROT")], [Protected: the user cannot type into it. Texts are
    always protected.],
  [#cmd("#NUM")], [Numeric input only.],
  [#cmd("#HI")], [High intensity.],
  [#cmd("#NON")], [Not displayed, for example for a password.],
  [#cmd("#BLINK")], [Blinking.],
  [#cmd("#REVERSE")], [Reverse video.],
  [#cmd("#USCORE")], [Underscored.],
  [#cmd("#BLUE"), #cmd("#RED"), #cmd("#PINK"), #cmd("#GREEN"),
   #cmd("#TURQ"), #cmd("#YELLOW"), #cmd("#WHITE")], [Colour.],
)

The attention keys the user can press have variables as well; they are
listed with #cmd("FSSKEY") (@lib-fssmenu-fsskey).

== Functions of the FSS API <lib-fssmenu-functions>

=== FSSINIT <lib-fssmenu-fssinit>

#idx("FSSINIT")
```
CALL FSSINIT [application]
```
Starts the screen services (FSS command #cmd("INIT")), clears the field
list of the API and sets the variables of @lib-fssmenu-attr and
@lib-fssmenu-fsskey. #var("application") is a name for the screen
application, kept for the list and menu functions; it defaults to
#cmd("UNKNOWN"). Call it before any other function of this chapter.

=== FSSTERM <lib-fssmenu-fssterm>

#idx("FSSTERM")#idx("FSSTERMINATE")#idx("FSSCLOSE")
```
CALL FSSTERM
CALL FSSTERMINATE
CALL FSSCLOSE
```
Ends the screen services and gives the terminal back to TSO. The three
names are the same function.

=== FSSTEXT <lib-fssmenu-fsstext>

#idx("FSSTEXT")
```
FSSTEXT(text, row, col [, [length] [, attr]])
```
Defines a protected text at #var("row") and #var("col"). #var("length")
cuts or pads the text to that length; it defaults to the length of the
text. #var("attr") defaults to #cmd("#GREEN")\; #cmd("#PROT") is always
added. Returns the column that follows the text, where the next definition
of the row can begin.

```
nxt = FSSTEXT('Name ===>', 5, 1, , #WHITE)
nxt = FSSFIELD('NAME', 5, nxt, 30, #RED+#USCORE)
```

=== FSSFIELD <lib-fssmenu-fssfield>

#idx("FSSFIELD")
```
FSSFIELD(name, row, col [, [length] [, [attr] [, init]]])
```
Defines the input field #var("name") of #var("length") characters
(default 25) at #var("row") and #var("col"). The name is translated to
uppercase; give it in quotes, so that it is not replaced by the value of a
variable of that name. #var("attr") defaults to #cmd("#GREEN").
#var("init") is the first content of the field: a single character fills
the whole field, a longer value is cut or padded to its length. The default
is blank. Returns the column that follows the field.

=== FSSTITLE <lib-fssmenu-fsstitle>

#idx("FSSTITLE")
```
FSSTITLE(title [, [attr] [, fill]])
```
Defines a title line in row 1: #var("title") centred across the screen,
filled to both sides with #var("fill") (default #cmd("-")). #var("attr")
defaults to #cmd("#WHITE"). The title is the protected field
#cmd("ZTITLE")\; #cmd("FSSZERRSM") writes its short messages into the right
end of it. Returns #var("title").

=== FSSTOPLINE, FSSOPTION and FSSCOMMAND <lib-fssmenu-fsstopline>

#idx("FSSTOPLINE")#idx("FSSOPTION")#idx("FSSCOMMAND")
```
FSSTOPLINE(prefix [, [row] [, [length] [, [attr1] [, attr2]]]])
FSSOPTION([row] [, [length] [, [attr1] [, attr2]]])
FSSCOMMAND([row] [, [length] [, [attr1] [, attr2]]])
```
Define an input line: the text #var("prefix") in column 1, followed by the
input field #cmd("ZCMD"). #cmd("FSSOPTION") uses the prefix
#cmd("Option ===>"), #cmd("FSSCOMMAND") #cmd("COMMAND ===>").

#deflist(width: 1.2in,
  [#var("row")], [Row of the line, default 2.],
  [#var("length")], [Length of the input field; default: the rest of the
    row.],
  [#var("attr1")], [Attribute of the prefix, default #cmd("#PROT+#WHITE").],
  [#var("attr2")], [Attribute of the field, default
    #cmd("#HI+#RED+#USCORE").],
)

They return the length of the field. Read the input with
#cmd("FSSFGET('ZCMD')").

```
Option ===> ____________________________________________________________
```

=== FSSMESSAGE <lib-fssmenu-fssmessage>

#idx("FSSMESSAGE")
```
FSSMESSAGE([row] [, attr])
```
Defines a message line across the screen in #var("row") (default 3), the
field #cmd("#ZERRLM"), with #var("attr") (default #cmd("#RED")). If the
line exists already, nothing is done. The line is protected. #cmd("FSSZERRLM") writes into it.
Returns #cmd("0").

=== FSSMSG <lib-fssmenu-fssmsg>

#idx("FSSMSG")
```
CALL FSSMSG [row] [, attr]
```
Defines the field #cmd("ZMSG") across #var("row") (default 3) with
#var("attr") (default #cmd("#PROT+#HI+#RED")).

=== FSSFOOTER <lib-fssmenu-fssfooter>

#idx("FSSFOOTER")
```
CALL FSSFOOTER text [, attr]
```
Defines a footer line with #var("text") in the last row of the screen, the
protected field #cmd("ZFOOTER"), with #var("attr") (default
#cmd("#WHITE")). A later call changes the text of that line.

=== FSSZERRSM and FSSZERRLM <lib-fssmenu-fsszerrsm>

#idx("FSSZERRSM")#idx("FSSZERRLM")
```
CALL FSSZERRSM message
CALL FSSZERRLM message
```
#cmd("FSSZERRSM") shows a short message. If the exec defined a field
#cmd("ZERRSM") with #cmd("FSSFIELD"), the message goes there; otherwise,
when the screen has a title line, it replaces the right end of the title,
at most 24 characters of it. A blank message restores the title.

#cmd("FSSZERRLM") shows a long message in the message line defined by
#cmd("FSSMESSAGE"). Without that line it does nothing. A null message is
ignored; to clear the line, pass a blank.

```
CALL FSSZERRSM 'Invalid input'
CALL FSSZERRLM 'Field 1 must contain a valid data set name'
```

=== FSSFSET <lib-fssmenu-fssfset>

#idx("FSSFSET")
```
FSSFSET(field, value)
```
Puts #var("value") into #var("field"), which is normally one defined with
#cmd("FSSFIELD"). Give the name in quotes. Returns #cmd("0"). A field
that does not exist ends the exec with a message that lists the fields
defined. For a short message use #cmd("FSSZERRSM"), not
#cmd("FSSFSET('ZERRSM',")#var("message")#cmd(")"): on a screen with a
field #cmd("ZERRSM") that call clears the message instead\; on one
without, #var("message") goes into the message line of #cmd("FSSMESSAGE")
or else the field #cmd("ZMSG") of #cmd("FSSMSG"), and without either the
exec ends.

=== FSSFGET <lib-fssmenu-fssfget>

#idx("FSSFGET")
```
FSSFGET(field)
```
Returns the content of #var("field") as the user left it, preset
characters that were not typed over included. The field must have been
defined with #cmd("FSSFIELD")\; otherwise the exec ends with a message that
lists the fields defined.

=== FSSFGETALL <lib-fssmenu-fssfgetall>

#idx("FSSFGETALL")
```
FSSFGETALL()
```
Reads every field defined with #cmd("FSSFIELD") into the REXX variable of
the same name, with leading and trailing blanks removed, and returns the
number of fields.

```
CALL FSSFIELD 'DSNAME', 4, 20, 44
...
n = FSSFGETALL()
SAY dsname
```

=== FSSCURSOR <lib-fssmenu-fsscursor>

#idx("FSSCURSOR")
```
CALL FSSCURSOR field
```
Puts the cursor at the start of #var("field"), which must have been defined
with #cmd("FSSFIELD").

=== FSSCOLOUR <lib-fssmenu-fsscolour>

#idx("FSSCOLOUR")#idx("FSSCOLOR")
```
CALL FSSCOLOUR field, attr
CALL FSSCOLOR field, attr
```
Changes the attributes of #var("field") to #var("attr"): a number, such as
#cmd("#RED"), or attribute names run together, such as
#cmd("'#PROT#HI#RED'") (FSS command #cmd("SET COLOR")).

=== FSSDISPLAY <lib-fssmenu-fssdisplay>

#idx("FSSDISPLAY")#idx("FSSREFRESH")
```
FSSDISPLAY([CHAR])
FSSREFRESH([CHAR])
```
Erases the terminal, writes the screen as defined, with the contents the
fields have now, and waits for the user to press an attention key. Returns
the key as #cmd("FSSKEY") does: its number, or with #cmd("CHAR") its name.
The two names are the same function.

=== FSSKEY <lib-fssmenu-fsskey>

#idx("FSSKEY")#idx("FSSUSEDKEY")
```
FSSKEY([CHAR])
FSSUSEDKEY(number)
```
#cmd("FSSKEY") returns the attention key that ended the last display, as
the number that compares with the variables below. With #cmd("CHAR"), or
any abbreviation of it, it returns the name in the right column instead.
#cmd("FSSUSEDKEY") turns such a number into the name.

#tab(caption: [Attention keys])[
  #table(columns: (1.1in, 0.8in, 1fr),
    [Variable], [Number], [Name],
    [#cmd("#ENTER")], [125], [#cmd("ENTER")],
    [#cmd("#PFK01") to #cmd("#PFK09")], [241 to 249], [#cmd("PF01") to
      #cmd("PF09")],
    [#cmd("#PFK10") to #cmd("#PFK12")], [122 to 124], [#cmd("PF10") to
      #cmd("PF12")],
    [#cmd("#PFK13") to #cmd("#PFK21")], [193 to 201], [#cmd("PF13") to
      #cmd("PF21")],
    [#cmd("#PFK22") to #cmd("#PFK24")], [74 to 76], [#cmd("PF22") to
      #cmd("PF24")],
    [#cmd("#CLEAR")], [109], [#cmd("CLEAR")],
    [#cmd("#RESHOW")], [110], [#cmd("RESHOW")],
  )
] <lib-fssmenu-aid-tab>

=== FSSWIDTH and FSSHEIGHT <lib-fssmenu-fsswidth>

#idx("FSSWIDTH")#idx("FSSHEIGHT")
```
FSSWIDTH()
FSSHEIGHT()
```
Return the number of columns and of rows of the terminal (FSS commands
#cmd("GET WIDTH") and #cmd("GET HEIGHT")). #cmd("FSSINIT") also keeps them
in the variables #cmd("FSSSCRWIDTH") and #cmd("FSSSCRHEIGHT"). To centre a
group of lines, for example:

```
startrow = FSSHEIGHT()%2 - lines%2
startcol = FSSWIDTH()%2 - 30
```

=== FSSCHECK <lib-fssmenu-fsscheck>

#idx("FSSCHECK")
```
FSSCHECK(field)
```
Returns #cmd("0") if the field exists on the screen and #cmd("4") if it
does not (FSS command #cmd("CHECK FIELD")).

=== Cursor Positions <lib-fssmenu-curpos>

#idx("FSSGETCURPOS")#idx("FSSSETCURPOS")#idx("CURS2POS")#idx("POS2CURS")
```
FSSGETCURPOS()
CALL FSSSETCURPOS position
CURS2POS(row, col)
POS2CURS(position)
```
A cursor position is the offset on the screen, counted from 0.
#cmd("FSSGETCURPOS") returns the position of the cursor after the last
display, #cmd("FSSSETCURPOS") sets it. #cmd("CURS2POS") turns a row and
column into a position, #cmd("POS2CURS") a position into
#var("row")#cmd("/")#var("col").

== A Dialog Loop <lib-fssmenu-dialog>

#idx("FSS", "dialog loop")
A screen is shown in a loop that displays it, looks at the key the user
pressed, reads the input and answers it:

```
CALL IMPORT FSSAPI
ADDRESS FSS
CALL FSSINIT
CALL FSSTITLE 'Allocate a Data Set'
CALL FSSOPTION
CALL FSSMESSAGE FSSHEIGHT()
nxt = FSSTEXT('Data set name ===>', 4, 1, , #WHITE)
CALL FSSFIELD 'DSNAME', 4, nxt, 44, #RED+#USCORE, '_'
DO FOREVER
   key = FSSDISPLAY('CHAR')
   IF key='PF03' | key='PF15' THEN LEAVE
   IF key<>'ENTER' THEN ITERATE
   dsn = STRIP(FSSFGET('DSNAME'), , '_')
   IF dsn='' THEN DO
      CALL FSSZERRSM 'Input missing'
      CALL FSSZERRLM 'Enter the name of a data set'
      ITERATE
   END
   CALL FSSZERRSM ' '
   CALL FSSZERRLM ' '
   /* ... process dsn ... */
END
CALL FSSTERM
```

Compare with the variables instead, if the key is fetched as a number:
#cmd("key = FSSDISPLAY()") and #cmd("IF key = #PFK03").

== Input Screens: FMTCOLUM <lib-fssmenu-fmtcolum>

#idx("FMTCOLUM")
```
FMTCOLUM(columns, title, text1 [, text2 ...])
```
Builds an input screen from a list of prompts, shows it and returns the
input. Each #var("text") is a prompt followed by an input field; the
prompts are distributed over #var("columns") columns of equal width (1 to
9), left to right and then down, starting in row 3. A field takes the rest
of its column; in the last column, the rest of the row. Row 1 holds the
title, the row above the last one a message line, the last row a footer
when #cmd("_screen.footer") is set.

After the user has pressed a key, the input of field #var("n") is in
#cmd("_screen.input.")#var("n") without trailing blanks, and
#cmd("_screen.input.0") holds the number of fields. Preset characters the
user did not type over stay in the value. #cmd("FMTCOLUM") returns the key
by its name, such as #cmd("ENTER") or #cmd("PF03"). It clears the screen
definition at the end (FSS command #cmd("RESET")) but does not end the
screen services.

```
frc = FMTCOLUM(1, 'One Columned Formatted Screen',,
               '1. First Name  ===>',,
               '2. Family Name ===>',,
               '3. UserId      ===>',,
               '4. Department  ===>')
DO i=1 TO _screen.input.0
   SAY "User's input" i':' _screen.input.i
END
```
```
 ------------------------ One Columned Formatted Screen ------------------------

 1. First Name  ===> ___________________________________________________________
 2. Family Name ===> ___________________________________________________________
 3. UserId      ===> ___________________________________________________________
 4. Department  ===> ___________________________________________________________
```

With #cmd("2") as the first argument, the same prompts appear in two
columns:

```
 ------------------------ Two Columned Formatted Screen ------------------------

 1. First Name  ===> ___________________ 2. Family Name ===> ___________________
 3. UserId      ===> ___________________ 4. Department  ===> ___________________
```

=== Special Prompts <lib-fssmenu-fmtcolum-special>

A #var("text") that begins with #cmd("%") or #cmd("/") is not a prompt:

#deflist(width: 1.2in,
  [#cmd("%T")#var("text")], [Text without a field, in the next column
    position.],
  [#cmd("%L")#var("text")], [Text without a field on a row of its own.],
  [#cmd("%C")#var("nnn")#var("text")], [Text in the row of the last field,
    at column #var("nnn") (three digits).],
  [#cmd("%F")], [A field without a prompt, the whole column wide.],
  [#cmd("/N")], [Continue in the next row.],
  [#cmd("/C")], [Continue in the next column.],
)

An empty #var("text") leaves its position empty.

=== Settings <lib-fssmenu-fmtcolum-settings>

Set these variables before calling #cmd("FMTCOLUM")\; #var("n") is the
number of the field, counted from 1:

#deflist(width: 1.6in,
  [#cmd("_screen.preset")], [The character that fills empty fields,
    default #cmd("_"). A longer value is shown as given.],
  [#cmd("_screen.init.")#var("n")], [A value shown in field #var("n").],
  [#cmd("_screen.length.")#var("n")], [A field length shorter than the
    space the column leaves.],
  [#cmd("_screen.attribute.")#var("n")], [The attribute of field
    #var("n"): a number, or the name of a variable such as
    #cmd("'#RED'"). Default #cmd("#BLUE").],
  [#cmd("_screen.footer")], [The text of the footer line.],
  [#cmd("_screen.ActionKey")], [The name of a routine that checks the
    input (below).],
)

=== Checking the Input <lib-fssmenu-fmtcolum-check>

Without #cmd("_screen.ActionKey"), #cmd("FMTCOLUM") returns after any key.
With it, the routine is called with the name of the key after every key
but PF3, PF4, PF15 and PF16, which always end the screen. It must not
have a #cmd("PROCEDURE") instruction, so that it can see
#cmd("_screen.input."), and it must return a value:

#deflist(width: 1.2in,
  [#cmd("0")], [The input is accepted; #cmd("FMTCOLUM") returns.],
  [#var("n")], [Field #var("n") is in error: the screen is shown again
    with the cursor in that field.],
  [#cmd("128")], [Show the screen again.],
  [#cmd("256")], [End the screen; #cmd("FMTCOLUM") returns
    #cmd("Termination by Exit").],
)

The routine can set messages with #cmd("FSSZERRSM") and #cmd("FSSZERRLM")\;
they are cleared at the next key.

```
_screen.ActionKey = 'CHECKINPUT'
frc = FMTCOLUM(2, 'Two Columned Formatted Screen',,
               '1. First Name  ===>', '2. Family Name ===>')
EXIT
checkinput:
IF STRIP(_screen.input.1, , '_') = '' THEN DO
   CALL FSSZERRSM 'Field 1 is mandatory'
   CALL FSSZERRLM 'Please enter a first name'
   RETURN 1
END
RETURN 0
```

== Menus <lib-fssmenu-menus>

=== FSSMENU <lib-fssmenu-fssmenu>

#idx("FSSMENU")
```
CALL FSSMENU option, short, long, action [, [row] [, col]]
FSSMENU('$DISPLAY' [, [update] [, enterexit]])
```
Each call of the first form adds one line to a menu: the option
#var("option") (translated to uppercase), a short and a long description,
and the #var("action") to perform when the option is selected. The second
form shows the menu and handles the selections until the user leaves it.

#var("action") is one of:

#deflist(width: 1.2in,
  [#cmd("TSO")#var(" command")], [The TSO command #var("command") is
    issued, followed by the TSO command #cmd("CLS").],
  [#cmd("CALL")#var(" routine")], [The routine is called, and the menu is
    built again afterwards.],
  [other], [The text is run as a REXX instruction (#cmd("INTERPRET")).],
)

The first menu line is placed in #var("row") (default 4), the option in
column #var("col") (default 6), the short description 3 and the long one 14
columns further right. #var("row") and #var("col") count only in the first
call of a menu. The colours are white, turquoise and green.

```
CALL FSSMENU 1, 'TIME', 'Time of day', 'TSO TIME'
CALL FSSMENU 2, 'HELP', 'General TSO help', 'TSO HELP'
CALL FSSMENU 3, 'LIST', 'My data sets', 'CALL MYLIST'
key = FSSMENU('$DISPLAY')
```

#cmd("$DISPLAY") ends and starts the screen services again, so it builds
its screen from nothing: the menu lines, an input field #cmd("ZCMD") in row
3, and what the settings below ask for. In the loop it then

+ calls the routine #var("update"), if given, before every display, so that
  it can change fields of the screen. It must not have a
  #cmd("PROCEDURE") instruction;
+ shows the screen and reads #cmd("ZCMD"). #cmd("X") or #cmd("=X") ends the
  menu and returns #cmd("PF03")\;
+ calls the routine #var("enterexit"), if given, with the key and the input
  as arguments. It returns #cmd("0") when it has handled the input (the
  menu is shown again), #cmd("4") when it has not (the input is taken as
  an option), or #cmd("8") to end the menu;
+ looks the input up among the options and performs the action, or shows
  #cmd("Invalid Option") in the messages.

PF3, PF4, PF15 and PF16 end the menu and return the key's name, such as
#cmd("PF03"). #var("enterexit") gets the key by that name as well.

These variables tailor the menu. Each is used by one #cmd("$DISPLAY") and
then reset:

#deflist(width: 1.6in,
  [#cmd("_screen.MenuRow")], [Row of the first menu line (default 4).],
  [#cmd("_screen.MenuCol")], [Column of the options (default 6).],
  [#cmd("_screen.MenuCol2")], [Column of the short descriptions (default
    #cmd("MenuCol")+3).],
  [#cmd("_screen.MenuCol3")], [Column of the long descriptions (default
    #cmd("MenuCol")+14).],
  [#cmd("_screen.MenuTitle")], [A title line with this text.],
  [#cmd("_screen.MenuOption")], [#cmd("1"): an option line
    (#cmd("FSSOPTION")) in row 2, which is then the field #cmd("ZCMD")
    instead of the one in row 3.],
  [#cmd("_screen.MenuMessage")], [#cmd("1"): a message line in the row
    above the last one.],
  [#cmd("_screen.Footer")], [A footer line with this text.],
)

The row and column settings are read at the first menu line, the others at
#cmd("$DISPLAY")\; the arguments #var("row") and #var("col") take precedence
over them.

=== FMTMENU <lib-fssmenu-fmtmenu>

#idx("FMTMENU")
```
CALL FMTMENU option, short, long, rexx
FMTMENU('$DISPLAY', title)
```
A complete menu screen in two steps. The first form adds a line, as
#cmd("FSSMENU") does, whose action is always #cmd("CALL")
#var("rexx")\; #var("rexx") can be an exec or a routine of the calling exec,
which may in turn issue TSO commands. The second form starts the screen
services and shows the menu through #cmd("FSSMENU") with a title line
#var("title") in row 1, an option line in row 2, a message line in the row
above the last and, if #cmd("_screen.footer") is set, a footer in the last
row. The options are placed in column 8, the descriptions 6 and 18 columns
further right; the settings of #cmd("FSSMENU") change that.

```
CALL FMTMENU 1, 'LIST',  'List my data sets', 'MYLIST'
CALL FMTMENU 2, 'QUEUE', 'Show the JES2 queue', 'MYQUEUE'
_screen.footer = 'PF3 Return'
key = FMTMENU('$DISPLAY', 'My Applications')
```

== Lists: FMTLIST <lib-fssmenu-fmtlist>

#idx("FMTLIST")
```
FMTLIST([[length] [, [char] [, [header1] [, [header2] [, appl]]]]])
```
Shows lines in a list that the user can scroll up, down, left and right,
instead of writing them with #cmd("SAY"). The lines are taken from the stem
#cmd("BUFFER."), as #cmd("EXECIO") reads them:

```
ADDRESS TSO
"ALLOC FILE(INDD) DSN('hlq.RXLIB(RXDATE)') SHR"
"EXECIO * DISKR INDD (STEM BUFFER. FINIS"
"FREE FILE(INDD)"
CALL FMTLIST
```
```
CMD ==>                                           ROWS 00001/00199 COL 001 B01
***** ***************************** Top of Data ******************************
00001 /* REXX */
00002 /* ---------------------------------------------------------------------
...
```

#cmd("BUFFER.0") holds the number of lines and #cmd("BUFFER.1") onwards the
lines. Instead of a number, #cmd("BUFFER.0") can hold
#cmd("ARRAY")#var(" n") (or #cmd("SARRAY")#var(" n")) to show the string
array #var("n"), or #cmd("STACK") to show the lines in the data stack.

#deflist(width: 1.2in,
  [#var("length")], [Width of the line area to the left of the lines,
    default 5, at most 12; #cmd("0") shows none.],
  [#var("char")], [A character to fill the line area with. Without it, the
    line area shows the line numbers.],
  [#var("header1")], [A line shown above the list, kept in place while the
    list scrolls.],
  [#var("header2")], [A second such line; only with #var("header1").],
  [#var("appl")], [An application id. It enables line commands and is the
    prefix of the routines that handle them (@lib-fssmenu-fmtlist-cmds).
    It is also shown in front of the command line instead of
    #cmd("CMD").],
)

The top line shows the first line displayed, the number of lines, the first
column and the number of the list (#cmd("B01")\; a list started from a list
is #cmd("B02"), and so on). #cmd("FMTLIST") returns #cmd("0") after PF3 or
PF15 and #cmd("-16") after PF4 or PF16.

=== Keys and Commands <lib-fssmenu-fmtlist-keys>

#deflist(width: 1.2in,
  [PF1], [Help: calls the routine #var("appl")#cmd("_HELP"), if there is
    one.],
  [PF3, PF15], [End this list.],
  [PF4, PF16], [End this list and all lists it was started from.],
  [PF5], [Show the screen again.],
  [PF7, PF8], [Scroll a page up or down. With a number in the command line,
    that many lines; with #cmd("M"), to the top or the bottom.],
  [PF10, PF11], [Shift 50 columns left or right; with a number in the
    command line, that many.],
  [PF12], [Retrieve the previous commands, one per key.],
)

#deflist(width: 1.2in,
  [#cmd("TOP")], [Show the first line.],
  [#cmd("BOTTOM"), #cmd("BOT")], [Show the last line.],
  [#cmd("END")], [As PF3.],
  [#cmd("EXIT")], [As PF4.],
  [#cmd("QUIT")], [End this list.],
  [#cmd("HELP")], [As PF1.],
  [#cmd("RESET")], [Reset the colours set by line commands.],
  [#cmd("ISPF"), #cmd("SPF")], [Start ISPF.],
  [#cmd("STICKY")], [Control sticky windows (@lib-fssmenu-sticky).],
)

Any other word in the command line is a primary command
(@lib-fssmenu-fmtlist-cmds).

=== Line and Primary Commands <lib-fssmenu-fmtlist-cmds>

When #cmd("FMTLIST") is called with an application id #var("appl") and a
line area, the user can type a command into the line area of a line. For
the command #var("cmd"), #cmd("FMTLIST") calls the routine
#var("appl")#cmd("_")#var("cmd") of the calling exec as a function, with the
line and its number in the list as arguments. It returns:

#deflist(width: 1.2in,
  [#cmd("0")], [The command was processed.],
  [#cmd("4")], [The command was processed; if the variable
    #cmd("NEWLINE") is set, it replaces the line. If the variable
    #cmd("ADDLINES") is a positive number, that many lines, shown as
    #cmd("..."), are inserted below the line.],
  [#cmd("5")], [Delete the line from the list.],
  [#cmd("6")], [The routine has put new lines into #cmd("BUFFER."), which
    replace the list.],
  [#cmd("7")], [The routine has put new lines into #cmd("BUFFER."), which
    are shown as a new list on top of this one; PF3 returns to this one.],
  [#cmd("8")], [Invalid line command; it is reported.],
)

The routine runs inside #cmd("FMTLIST") and sees only the variables
#cmd("BUFFER."), #cmd("NEWLINE"), #cmd("ADDLINES"), #cmd("ZERRSM") and #cmd("ZERRLM") (messages
to show), #cmd("SETCOLOR1") and #cmd("SETCOLOR2") (colours of the line area
and of the line, such as #cmd("#GREEN")), and those named in the variable
#cmd("PUBLIC") of the exec. Setting #cmd("#ACTION") to #cmd("PF03"),
#cmd("PF04") or #cmd("PF01") acts as that key.

A word in the command line that is not one of the commands above is a
primary command. With an application id, #cmd("FMTLIST") calls the routine
#var("appl")#cmd("_PRIMARY") with the command and its operands, or if that
does not exist #var("appl")#cmd("_")#var("command") with the operands.
Without one, it calls the exec #var("command") with the operands. The
return codes #cmd("6") and #cmd("7") work as for line commands, and the
variable #cmd("_commandLine") holds the whole command line.
#cmd("_screen.primary=0") turns primary commands off.

```
CALL FMTLIST , , , , 'MYLIST'
EXIT
mylist_s:                          /* line command S */
  SAY arg(1)
  RETURN 0
mylist_d:                          /* line command D */
  RETURN 5
mylist_primary:
  IF arg(1) = 'SHOW' THEN SAY 'SHOW was entered:' _commandLine
  ELSE RETURN 8
  RETURN 0
```

=== Settings <lib-fssmenu-fmtlist-settings>

These variables change the list. Unlike those of the menus, they stay set
for later lists.

#deflist(width: 1.6in,
  [#cmd("_screen.TopRow")], [Row in which the list begins, default 1. The
    rows above it are free for the exec.],
  [#cmd("_screen.TopRow.proc")], [A routine of the exec that writes the
    rows above the list, with #cmd("FSSTEXT").],
  [#cmd("_screen.BotLines")], [Number of rows kept free below the list,
    default 0.],
  [#cmd("_screen.BotLines.proc")], [A routine that writes them. It gets the
    first free row as its argument, enclosed in quotes:
    #cmd("first = STRIP(arg(1), , \"'\")").],
  [#cmd("_screen.Footer")], [A footer line in the last row.],
  [#cmd("_screen.Message")], [#cmd("1"): a line for long messages.],
  [#cmd("_screen.cmdchar")], [The character that fills the command line;
    default blank, #cmd("BLANK") for X'00'.],
  [#cmd("_screen.lina2")], [Width of a second line area, default 0.],
  [#cmd("_screen.LeftCol")], [The column in which the list begins.],
  [#cmd("_screen.primary")], [#cmd("0"): no primary commands.],
  [#cmd("_screen.Enter.proc")], [A routine called when a key is pressed
    with an empty command line.],
  [#cmd("_screen.Exit.proc")], [A routine called when the list ends.],
  [#cmd("_screen.Queue.proc")], [With #cmd("BUFFER.0='STACK'"): a routine
    called for every line taken from the stack.],
  [#cmd("_screen.Color.")#var("part")], [The colours of the parts:
    #cmd("Cmd") (red), #cmd("Stats") (white), #cmd("Top1"), #cmd("Top2")
    and #cmd("Bot1"), #cmd("Bot2") (line area and line of the top and
    bottom lines, red and blue), #cmd("List1"), #cmd("List2") (line area
    and lines, white and green), #cmd("Header1"), #cmd("Header2") (blue),
    #cmd("Footer") (white).],
)

```
_screen.TopRow = 4
_screen.TopRow.proc = 'TOPLINES'
_screen.Footer = 'PF3/PF4 Return'
_screen.Message = 1
CALL FMTLIST
EXIT
toplines:
  CALL FSSTEXT 'Student Database', 1, 1, , #PROT+#HI+#WHITE
  CALL FSSTEXT 'Updated' DATE(), 2, 1, , #PROT+#HI+#WHITE
  RETURN 0
```

=== FMTLISTC <lib-fssmenu-fmtlistc>

#idx("FMTLISTC")
```
FMTLISTC([appl])
```
Shows #cmd("BUFFER.") with #cmd("FMTLIST") in a standard frame: the list
from row 2, a message line, and the headers and footer taken from the
variables #cmd("_fmtheader"), #cmd("_fmtheader2") and #cmd("_fmtfooter").
Without #var("appl"), the name of the calling exec is the application id.

== Self-Refreshing Lists: FMTMON <lib-fssmenu-fmtmon>

#idx("FMTMON")
```
FMTMON([title] [, [interval] [, prompt]])
```
Shows the stem #cmd("_LINE.") (#cmd("_LINE.0") lines) like a list, and
calls a routine of the exec every #var("interval") milliseconds (default
1000, at least 10) to renew it. #var("title") is shown in row 1 (default
#cmd("FMT Monitor")); the last row holds #var("prompt") (default
#cmd("CONSOLE")) followed by an input line. The list shows its last page
first. #cmd("FMTMON") returns #cmd("0") when the user ends it.

The exec provides two routines:

#deflist(width: 1.2in,
  [#cmd("MONTIMEOUT")], [Called when the interval has passed, with a
    counter as argument. It returns #cmd("0") when it left #cmd("_LINE.")
    as it was, any other value when it put new lines into it.],
  [#cmd("MONENTER")], [Called with the input line when the user presses
    ENTER. It returns #cmd("0") to go on with new lines in #cmd("_LINE."),
    #cmd("4") to go on, #cmd("8") to end as with PF3 and #cmd("12") to end
    as with PF4.],
)

Apart from #cmd("_LINE.") and the stem #cmd("sticky."), they see none
of the variables of the exec\; #cmd("MONTIMEOUT") also sees the stem
#cmd("COLOR."), in which #cmd("COLOR.")#var("n") sets the colour of line
#var("n"), such as #cmd("#GREEN").

Some input is handled by #cmd("FMTMON") itself: #cmd("TOP"),
#cmd("BOTTOM"), #cmd("UP")#var(" n") and #cmd("DOWN")#var(" n") scroll;
#cmd("ISPF") starts ISPF; #cmd("STICKY") controls sticky windows;
#cmd("RX")#var(" name") calls the routine or exec #var("name"). The keys are
PF1 (help), PF3 and PF4 (end), PF7 and PF8 (scroll a page) and PF12
(retrieve the last input). The rows used can be changed with
#cmd("_screen.TopRow") (default 2) and #cmd("_screen.BotLines").

```
CALL FMTMON 'Time', 1000, 'COMMAND'
EXIT
montimeout:
  _line.1 = TIME('L')
  _line.0 = 1
  RETURN 1
monenter:
  _line.1 = 'You entered:' arg(1)
  _line.0 = 1
  RETURN 0
```

#idx("FMTMONX")#idx("FMTMONAR")
Two variants take the lines from string arrays instead:

```
FMTMONX([title] [, interval])
FMTMONAR(title, textarray, colourarray [, interval])
```
#cmd("FMTMONX") shows the string array whose number is in the variable
#cmd("SNAME"). #cmd("FMTMONAR") shows the string array #var("textarray")
with the colour of each line taken from the integer array
#var("colourarray")\; its #cmd("MONENTER") gets the array number as second
argument. The sample #cmd("MTT") uses #cmd("FMTMONAR") to follow the master
trace table.

== Sticky Windows <lib-fssmenu-sticky>

#idx("FSSTICKY")#idx("FSSDASH")
```
FSSTICKY(title, name [, [row] [, [col] [, [rows] [, [cols]
         [, [colour] [, frame]]]]]])
FSSDASH(title, name, row, col, rows, cols [, [colour] [, frame]])
```
Define a small window that #cmd("FMTLIST") and #cmd("FMTMON") show on top
of their list, its lines kept in the stem #cmd("sticky.")#var("name")#cmd(".").
#cmd("FSSTICKY") places windows one below the other from row 3, 10 rows of
25 columns each, unless told otherwise; #cmd("FSSDASH") needs every
position and size. Without #var("colour") the windows take turns of
colours. #var("frame") is #cmd("NOFRAME"), #cmd("PLAIN") (three letters are
enough) or, by default, a frame. Both return the number of the window, or
#cmd("4") if a window #var("name") exists already. The command
#cmd("STICKY") of the lists switches the windows on and off; the RXLIB
members #cmd("STICKY") and #cmd("STICKYDS") display them.

== Tracing <lib-fssmenu-trace>

#idx("FSS", "trace")
With #cmd("_screen.FTRACE=1") set in the exec, #cmd("FSSDISPLAY") writes a
line with the time and the key the user pressed after every display, also
when it is called by #cmd("FMTLIST") or #cmd("FMTCOLUM").
#cmd("FMTCOLUM") and #cmd("FSSMENU") write in addition when they are
entered and left; #cmd("FSSMENU") also writes each selection and the return
code of its #var("enterexit") routine.
