[![Build Status](https://github.com/mvslovers/brexx370/workflows/Build%20Brexx%2F370/badge.svg)](https://github.com/mvslovers/brexx370/actions) [![Release Status](https://github.com/mvslovers/brexx370/workflows/Release%20Brexx%2F370/badge.svg)](https://github.com/mvslovers/brexx370/actions)

![Logo](doc/brexx370.png) 
--------------------------


## BRexx370

System/370 (MVS) version of the ingenious [BRexx][1] interpreter originally 
by Vasilis N. Vlachoudis. 


Currently released version is [V2R5M0][2]

## What is REXX?

REXX is a programming language designed by Michael Cowlishaw of IBM UK 
Laboratories.  In his own words:  "REXX is a procedural language that allows 
programs and  algorithms to be written in a clear and structured way."

Syntactically, REXX doesn't look that different from any other procedural 
language.  Here's a simple REXX program:

```rexx
/* Count some numbers */

say "Counting..."
do i = 1 to 10
    say "Number" i
end
```

## Background

BRexx is an open source version of the classic Rexx developed by Vasilis 
Vlachoudis of the Cern Laboratory in Switzerland. Written as an ANSI C 
language program, BRexx is notable for its high performance. It also provides 
a nice collection of special built-in functions and function libraries that 
offer many extra features over most of the existing Classic Rexx 
implementations.

BRexx was originally written for DOS in the late eighties/early 1990s. 
Then,with the rise of Windows, it was revised for the 32-bit world of Windows 
and 32-bit DOS.  BRexx also runs under the Linux and Unix family of operating 
systems, and has a good set of functions especially written for Windows CE. 
Other operating systems on which it runs include: MacOS, BeOS, and the 
Amiga OS.

One of the outstanding features, among so many, of BRexx is its minuscule 
footprint. The entire product, written in C, including full documentation and 
examples, takes up only a measly few hundred kilobytes. It is small enough to 
fit on a single, ol' school floppy diskette!

Hence, BRexx was prime for re-targeting to MVS/VM for TSO/CMS.  And so it was. 
Recently, the BRexx Rexx Interpreter was made operational onto the MVS 3.8j 
platform as BRexx/370 version V2R1M0 and it was released in April of 2019.  
The MVS 3.8j (now emulated) mainframe platform which pre-dates IBM's official 
release of TSO/CMS Rexx published initially, in the next (i.e. XA) set of 
offerings of IBM mainframe OSes. However, the lack of having a Rexx 
significantly hampers the MVS 3.8j platform of not only the highly utilitarian 
features of Rexx as the powerful glue it provides as an operating system's 
command/macro language, tying all of the vast collection of system resources 
together programmatically, under one umbrella, but also prevents the users and 
the MVS 3.8j community from taking advantage of the treasure trove of Rexx-ware
scripts/programs/applications that exists currently which greatly enhances the 
MVS 3.8j user's and MVS 3.8j community's mainframe computing experience, 
many-fold.

BRexx was made operational, as BRexx/370, targeting the MVS 3.8j platform 
by: **Peter Jacob** (PEJ) and **Mike Groβmann** (MIG). BRexx/370 now provides
a Rexx scripting/command language for the MVS 3.8j platform. 

## Download

Full releases with install instructions are available 
here: https://github.com/mvslovers/brexx370/releases

## Installation

Instalation Instructions can be found 
at [BREXX/370 Installation Instructions](doc/installation.md)

## Documentation

Full documentation is available at [BREXX/370 Documentation](doc/index.md)

## Building From Source

To build BREXX/370 from source please rever to the [README](build/README.md) in
the build directory. 

## Community 

For questions and suggestions you can find us at: [Moshix Discord Channel][3]

##

Please also read the original [README](README).

[1]: https://github.com/vlachoudis/brexx/
[2]: https://github.com/mvslovers/brexx370/releases/tag/V2R5M0
[3]: https://discordapp.com/invite/eyRjj4t