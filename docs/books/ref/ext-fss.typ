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

#tab(caption: [The commands of ADDRESS FSS])[
  #table(columns: (1in, 1fr),
    [Command], [Purpose],
    [#cmd("INIT")], [Starts the screen services.],
    [#cmd("TERM")], [Ends them and gives the terminal back to TSO.],
    [#cmd("RESET")], [Clears the screen definition.],
    [#cmd("TEXT")], [Defines a protected text at a row and column.],
    [#cmd("FIELD")], [Defines an input field.],
    [#cmd("STATIC")], [Defines a protected text that keeps its place.],
    [#cmd("SET")], [Sets an attribute, the contents of a field, or the
      cursor.],
    [#cmd("GET")], [Reads the contents of a field, the key the user pressed,
      the cursor position, or the size of the screen.],
    [#cmd("SHOW")], [Shows the screen and waits for the user.],
    [#cmd("REFRESH")], [Shows the screen again without waiting.],
    [#cmd("CHECK")], [Tests a field.],
    [#cmd("TEST")], [Tests the screen services.],
  )
] <ext-fss-tab>

Any other command gets return code -3.

#note[*To be converted:* the operands of each command, their attributes and
return codes, from the formatted screens chapter of the Sphinx guide
(fss.rst, “FSS Functions as Host Commands”), checked against
#cmd("fss/") and #cmd("src/hostenv.c").]
