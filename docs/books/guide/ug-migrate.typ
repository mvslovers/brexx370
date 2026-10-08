#import "../bookmaster/bookmaster.typ": *

= Migrating from V2R5M3 <ug-migrate>

#idx("migration", "from V2R5M3")
Release 3.0 runs most execs written for V2R5M3 unchanged. This appendix
lists what changes for an exec, a procedure or a user, and what to do about
it.

== Input and Output under TSO <ug-migrate-io>

Under the TSO terminal monitor program -- a TSO session, or
#cmd("PGM=IKJEFT01") in batch -- BREXX/370 now reads and writes through TSO,
as TSO/E REXX does (@ug-run-tsobatch):

- #cmd("SAY"), #cmd("TRACE") output and error messages go into
  #cmd("SYSTSPRT") in batch, in order with the messages of TSO, and to the
  terminal in a session.
- #cmd("PULL") and #cmd("PARSE PULL") with an empty stack read the next line
  of #cmd("SYSTSIN") in batch; TSO does not then run that line as a command,
  and at the end of #cmd("SYSTSIN") they return the null string. In a
  session they read the terminal.
- The DD statements #cmd("STDOUT"), #cmd("STDERR") and #cmd("STDIN") are no
  longer used there. *Remove them from your #cmd("RXTSO") procedure.* A job
  that fed #cmd("PULL") from #cmd("STDIN") under #cmd("IKJEFT01") puts those
  lines into #cmd("SYSTSIN") after the command instead.

In a batch step without TSO -- #cmd("PGM=BREXX"), the procedure
#cmd("RXBATCH") -- #cmd("SAY") writes to #cmd("STDOUT"), messages go to
#cmd("STDERR") and #cmd("PULL") reads #cmd("STDIN"), as with V2R5M3. A step
without #cmd("STDOUT") uses #cmd("SYSTSPRT") and #cmd("SYSTSIN") as IRXJCL
does.

#idx("OUTTRAP", "changed")
#cmd("OUTTRAP") now traps what commands write, and only that. The exec's own
#cmd("SAY"), #cmd("TRACE") output and error messages are not trapped; the
output of another exec run as a command is. The options #var("max"),
#cmd("CONCAT")/#cmd("NOCONCAT") and #var("skip") apply to the one
#cmd("OUTTRAP") call that names them.

#idx("standard streams", "names")
*Write to the standard streams as #cmd("<STDOUT>") and #cmd("<STDERR>").*
#cmd("LINEOUT('STDOUT', ...)") names a DD called #cmd("STDOUT"), which the
standard output already holds, so the open fails with error 57. The names
#cmd("<STDOUT>"), #cmd("<STDERR>") and #cmd("<STDIN>"), or the handles 0 to
2, work.

== Removed <ug-migrate-removed>

- #cmd("PUTSMF") and the SMF type 242 records;
- #cmd("MVSDUMP");
- #cmd("OPEN(..., 'VIO')");
- the undocumented CLIST variable pool;
- the #cmd("IRXEXCOM") interface: BREXX/370 publishes no environment block
  any more (@ug-restrict-irxexcom).

== Changed Behaviour <ug-migrate-changed>

- #cmd("ADDRESS") to an environment that does not exist answers return code
  -3, as TSO/E REXX does.
- A member found in #cmd("SYSUPROC") or #cmd("SYSPROC") counts as REXX only
  when its first line is a comment containing #cmd("REXX")\; any other
  member is taken for a CLIST and the search goes on (@ug-calling-main).
- Outside a TSO session a password-protected data set is refused; V2R5M3
  asked the operator for the password.
- #cmd("ADDRESS COMMAND 'CP ...'") obtains the authorization it needs
  itself. Where RAKF denies it, the command ends with return code -5
  instead of abend S047.
- #cmd("SYSDSN") returns the messages of TSO/E, not only #cmd("OK") and
  #cmd("DATASET NOT FOUND").
- A comparison that is not strict ignores trailing blanks, as the REXX
  definition says.
- A real number is shown with at most 15 significant digits.

== Fixed <ug-migrate-fixed>

#tab(caption: [Fixes that an exec may notice])[
  #table(columns: (1.8in, 1fr, 1fr),
    [Case], [V2R5M3], [3.0],
    [#cmd("DECRYPT(ENCRYPT(x))")], [did not give #cmd("x") back],
      [gives #cmd("x") back],
    [#cmd("SOUNDEX")], [wrong codes for EBCDIC letters], [correct codes],
    [stream I/O], [one position for reading and writing; an implicit open
      could truncate], [separate read and write positions; an implicit
      open never truncates],
    [a number of #cmd("1E75") or more in the source], [abend while the
      exec was compiled], [a string: #cmd("DATATYPE(x,'N')") is 0,
      arithmetic gives error 41],
    [#cmd("ARG(")#var("n")#cmd(")") with #var("n") above 99], [error 40],
      [#cmd("''"), as in TSO/E],
    [integer arithmetic beyond 32 bits], [wrapped around], [goes on as a
      real number],
    [a string array index out of range], [abend S0C4], [error 40],
    [#cmd("TRUNC")], [wrong results in some cases], [correct],
    [a built-in function given a variable or literal], [could change it in
      place], [leaves it alone],
  )
] <ug-migrate-fixed-tab>

The cleanup also removed many faults in the interpreter and its support
modules -- uninitialized pointers and buffer overflows among them -- that
could abend an exec or give wrong results.

== Upgrading an Installation <ug-migrate-install>

#note[*To be confirmed* with the SMP package of release 3.0: how an
installation of V2R5M3 made by hand is replaced, and which old data sets
may be deleted afterwards. The preview 3.0.0-dev replaces the load modules
only (@ug-install-preview).]

After an upgrade, change the data set name of the RXLIB allocation in the
logon procedure and in your own JCL to that of the new release.

== Earlier Releases <ug-migrate-older>

An installation older than V2R5M3 is best upgraded to release 3.0
directly. The notes of the releases V2R1M0 to V2R4M1 -- among them the move
of the libraries under a versioned name, the authorized version of V2R3M0
and the removal of the load module #cmd("BREXXSTD") -- are in the
documentation of those releases.
