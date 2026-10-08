#import "../bookmaster/bookmaster.typ": *

= Introducing BREXX/370 <ug-intro>

#idx("BREXX/370")
BREXX/370 is a REXX interpreter for MVS 3.8j. It runs REXX programs -- execs
-- under TSO, at a terminal or in a batch job, and as an ordinary batch
program. It implements the REXX language as TSO/E REXX does, so most execs
written for TSO/E run unchanged, and it adds functions for the things a
program on MVS needs: data sets and VSAM files, dynamic allocation, the
console, TCP/IP, formatted 3270 screens, arrays and a key/value database.

This chapter describes what BREXX/370 consists of, where it comes from, and
how the three books describe it.

== Where BREXX/370 Comes From <ug-intro-history>

#idx("BREXX")
BREXX was written by Vasilis Vlachoudis as a REXX interpreter for many
platforms. Jason Winter and Jürgen Winkelmann ported it to MVS 3.8j, and the
BREXX/370 releases since have been made by Peter Jacob and Mike Großmann.

Release 3.0 is the same interpreter as V2R5M3, rebuilt with the cc370
cross-toolchain and the libc370 C library instead of the JCC compiler. It
went through a review and cleanup pass, follows TSO/E REXX more closely in
input and output under TSO, and brings an optional TSO integration with
which the TSO #cmd("EXEC") command runs REXX. @ug-migrate lists what a
V2R5M3 user notices.

BREXX is licensed under the GNU General Public License, version 2. The same
terms apply to BREXX/370.

== What BREXX/370 Consists Of <ug-intro-parts>

#idx("load module", "BREXX")
#idx("RXLIB")
BREXX/370 is a load module and a set of libraries:

#deflist(width: 1.6in,
  [the load module #cmd("BREXX")], [the interpreter, with the aliases
    #cmd("REXX") and #cmd("RX"), so that #cmd("RX") #var("name") and
    #cmd("REXX") #var("name") run an exec. Beside it are a few modules that
    the interpreter loads for VSAM and the VTOC.],
  [RXLIB], [a library of functions written in REXX. An exec calls them as
    if they were built in: BREXX/370 finds them through the DD statement
    #cmd("RXLIB").],
  [CMDLIB], [TSO commands written in REXX, such as #cmd("LA") and
    #cmd("WHOAMI").],
  [SAMPLES], [example execs.],
  [PROCLIB], [the JCL procedures #cmd("RXTSO") and #cmd("RXBATCH"), which
    run an exec in a batch job.],
)

#idx("built-in function", "three kinds")
A function that an exec calls can come from three places, and the
difference matters when you look for it or want to replace it:

+ *Built into the interpreter, in C.* The REXX built-in functions and most
  of the BREXX/370 functions are part of the load module.
+ *Built into the interpreter, in REXX.* Some functions -- among them
  #cmd("SYSVAR"), #cmd("MVSVAR"), #cmd("DATETIME") and #cmd("VTOC") -- are
  written in REXX but carried inside the load module. They are always
  there, with no RXLIB allocated, and an RXLIB member of the same name does
  not replace them.
+ *In RXLIB.* The functions of RXLIB, among them the formatted-screen
  functions (#cmd("FSSINIT"), #cmd("FSSDISPLAY") ...) and the key/value
  database, are found only when the DD statement #cmd("RXLIB") is
  allocated.

The _BREXX/370 Reference_ marks which functions are written in REXX; the
_BREXX/370 Library and Samples_ describes RXLIB.

== BREXX/370 and TSO/E REXX <ug-intro-tsoe>

#idx("TSO/E REXX", "compared")
BREXX/370 follows TSO/E REXX in the language, the built-in functions, the
host command environments #cmd("TSO") and #cmd("ISPEXEC"), and the way an
exec is found and called under TSO. It is not TSO/E REXX: MVS 3.8j has
none of the TSO/E services that TSO/E REXX is built on, and BREXX/370
provides what it can by other means. Where the two differ, the _BREXX/370
Reference_ says so at the instruction or function concerned, and
@ug-restrict lists the limits of the implementation.

== The BREXX/370 Books <ug-intro-books>

#deflist(width: 1.6in,
  [ML03-0001], [_BREXX/370 User's Guide_, this book: installing
    BREXX/370, running execs, how they find each other, and working with
    TSO and MVS.],
  [ML03-0002], [_BREXX/370 Reference_: the REXX language as BREXX/370
    implements it, and the functions and host command environments that
    BREXX/370 adds.],
  [ML03-0003], [_BREXX/370 Library and Samples_: RXLIB, the TSO commands
    written in REXX, formatted screens, the key/value database, the
    applications and the samples.],
)
