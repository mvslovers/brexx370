#import "../bookmaster/bookmaster.typ": *

= Finding and Calling Execs <ug-calling>

#idx("exec", "search order")
An exec is found twice over: once when it is started, as the main exec, and
again whenever it calls a routine that it does not contain itself. This
chapter describes both searches, and what an exec that is called sees of
the variables of its caller.

== Finding the Main Exec <ug-calling-main>

#idx("SYSUEXEC")#idx("SYSUPROC")#idx("SYSEXEC")#idx("SYSPROC")
The name given to #cmd("RX"), #cmd("REXX") or #cmd("BREXX") is looked up in
this order:

+ *A DD statement of that name.* If the name is a DD name of the step or
  session, the exec is read from it. The procedures #cmd("RXTSO") and
  #cmd("RXBATCH") use this: they allocate the exec to #cmd("EXEC") or
  #cmd("RXRUN") and pass that name.
+ *The exec libraries*, as a member, in the order #cmd("SYSUEXEC"),
  #cmd("SYSUPROC"), #cmd("SYSEXEC"), #cmd("SYSPROC"). Each of them may be a
  concatenation, and none of them has to be allocated; at least one
  usually is, by the logon procedure (@ug-install-tso).
+ *A data set name.* A name in quotes is a data set: a member,
  #cmd("'MY.EXEC(MYEXEC)'"), or a sequential data set,
  #cmd("'MY.SEQ.REXX'"). If it does not exist, the call ends with an error
  message.

#idx("REXX comment", "in line 1")
A member found in #cmd("SYSUEXEC") or #cmd("SYSEXEC") is taken for REXX. A
member found in #cmd("SYSUPROC") or #cmd("SYSPROC") is taken for REXX only
if its first line is a comment containing the word #cmd("REXX"), such as
#cmd("/* REXX */"), as in TSO/E. Any other member there is a CLIST, and the
search goes on. Give every exec that lives in a CLIST library such a first
line.

== Calling an External Routine <ug-calling-external>

#idx("external routine")#idx("RXLIB", "search")
An exec calls a routine with #cmd("CALL") #var("name") #var("arguments") or
as a function, #var("value") #cmd("=") #var("name")#cmd("(")#var("arguments")#cmd(")").
When #var("name") is not a label of the exec itself, BREXX/370 looks for it
in this order:

+ the built-in functions of the interpreter, those written in C and those
  written in REXX and carried in the load module (@ug-intro-parts);
+ the library allocated to #cmd("RXLIB"), as a member;
+ the library from which the calling exec was read, as a member: the DD
  statement it came from, or its data set.

The first hit runs. A routine of RXLIB therefore cannot replace a built-in
function, and a member of the caller's library cannot replace a routine of
RXLIB. An exec need not import anything to call a routine: any exec found
this way can be called.

#note[*To be confirmed:* whether the caller's library is searched in all
the data sets of a concatenation or only in the first. The earlier guide
said only the first.]

== The Variables of a Called Exec <ug-calling-scope>

#idx("variable scope", "external routine")
An external routine without a #cmd("PROCEDURE") instruction shares the
variables of its caller: it can read and change them, and the variables it
creates are there for the caller when it returns. A routine that begins
with #cmd("PROCEDURE") has variables of its own, and #cmd("PROCEDURE EXPOSE")
#var("names") shares only the variables named.

#note[*To be confirmed:* TSO/E REXX does not share variables with an
external routine at all. Whether BREXX/370 3.0 still shares them as
described here is to be checked against the interpreter.]
