[![Build](https://github.com/mvslovers/brexx370/actions/workflows/build.yml/badge.svg)](https://github.com/mvslovers/brexx370/actions/workflows/build.yml) [![Release Brexx/370](https://github.com/mainframed/brexx370/actions/workflows/release.yml/badge.svg)](https://github.com/mainframed/brexx370/actions/workflows/release.yml)

![Logo](docs/brexx370.png) 
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

Installation instructions are in the BREXX/370 User's Guide (ML03-0001),
chapter "Installing BREXX/370": [BREXX/370 manuals](https://mvslovers.readthedocs.io/projects/brexx370/)

## Documentation

The manuals are on Read the Docs, [BREXX/370 manuals](https://mvslovers.readthedocs.io/projects/brexx370/), as web pages
and PDF: ML03-0001 User's Guide, ML03-0002 Reference, ML03-0003 Library
and Samples. Their sources are in [docs/books](docs/books).

## Building From Source

BREXX/370 builds on the host with [MBT](https://github.com/mvslovers/mbt)
(mbt 3) and the [CC/370 (cc370)](https://github.com/mvslovers/cc370)
toolchain: compile, assemble, link and package on the host, no MVS round
trip. Install mbt 3 and the cc370 toolchain with its LIBC/370 sysroot
(see mbt's [MIGRATION.md](https://github.com/mvslovers/mbt/blob/main/docs/MIGRATION.md),
section 1), then:

```sh
mbt build --all     # all load modules into build/
mbt package         # dist/brexx370-<version>-load.xmit
```

`mbt deploy` and `mbt run mvstest` (the REXX test suite on MVS) talk to
an MVS system that mbt knows as a target: `mbt target import .env --name
<name>` turns an mbt 2 `.env` into one (`~/.mbt/targets.toml`).

See [internals/cc370-migration.md](internals/cc370-migration.md) for how
the build got here and [TODO.md](TODO.md) for the next steps. The former
JCC based build (2.5.3) lives on in the branch
[`v2.5-jcc`](https://github.com/mvslovers/brexx370/tree/v2.5-jcc); it is
no longer maintained.

## License

BREXX/370 is a derivative of [BREXX][1] by Vasilis N. Vlachoudis and is
licensed under the GNU General Public License, version 2 (GPL-2.0); see
[COPYING](COPYING). The freeware terms of the old BREXX 2.x releases no
longer apply.

Bundled third-party code keeps its own license, all compatible with the
GPL-2.0: `fss/`, `src/rxtso.c` and `inc/rxtso.h` (New BSD, Tommy Sprinkle), `map/` (MIT)
and `regex/` (Unlicense).

## Community 

For questions and suggestions you can find us at: [Moshix Discord Channel][3]

##

Please also read the original [README](README).

[1]: https://github.com/vlachoudis/brexx/
[2]: https://github.com/mvslovers/brexx370/releases/tag/V2R5M0
[3]: https://discordapp.com/invite/eyRjj4t