#import "../bookmaster/bookmaster.typ": *

= NJE38 Messages <ext-nje>

#idx("NJE38")#idx("NJE38", "messages")
NJE38 is the network job entry for MVS 3.8j (Bob Polmanter). Five
functions let an exec send a message to a user on another node and wait
for the messages that users send to it. They talk to NJE38 through its
interface module #cmd("NJERLY"). Their names begin with two underscores:
#cmd("__NJEINIT"), #cmd("__NJEREGISTER"), #cmd("__NJERECEIVE"),
#cmd("__NJESEND") and #cmd("__NJEDEREGISTER").

The RXLIB function #cmd("NJE38CMD") sends an operator command to NJE38
instead; it is described in _BREXX/370 Library and Samples_.

== Using the NJE38 Functions <ext-nje-use>

*Requirements.* All of these must hold:

+ The NJE38 started task is running. #cmd("MVSVAR('NJE')") is #cmd("1")
  when it is (@ext-tso-mvsvar).
+ The module #cmd("NJERLY") is in the program search order, like the
  #cmd("BREXX") module.
+ The user may use SVC 244, which is READ access to the RAKF profile
  #cmd("SVC244") in the class #cmd("FACILITY"). BREXX/370 is not
  APF-authorized. NJE38 needs the job step to be authorized while
  #cmd("NJERLY") runs, and the functions take that authorization from
  SVC 244 for the length of one call and give it back afterwards, as
  #cmd("ADDRESS CONSOLE") does. The profile is therefore always
  needed. _Running Authorized_ in the _BREXX/370 User's
  Guide_ describes it.

Without access to SVC 244, #cmd("__NJEREGISTER") and #cmd("__NJESEND")
return #cmd("-5") and write the message #cmd("BRX0010E") (once) to
#cmd("STDERR"). The user is then not registered, so a
#cmd("__NJERECEIVE") that follows ends with error 68 (@ext-nje-errors).
#cmd("__NJERECEIVE") returns #cmd("#ERROR") with #cmd("_RC") #cmd("-5") only
if the access is gone after the registration. Nothing abends.
#cmd("__NJEINIT") and #cmd("__NJEDEREGISTER") need no authorization of
their own.

*Granting the access.* RAKF keeps its profiles in the member
#cmd("PROFILES") of #cmd("SYS1.SECURE.CNTL"), one line per entry: the class
in columns 1 to 8, the profile in columns 9 to 52, the group in columns 53
to 60 (blank for every user), the access in columns 61 to 66. The
profile #cmd("SVC244") needs a line for all users, which gives no access,
and one line for each group that may use it. This is the entry on the TK5
system this example was taken from; the list that ships with TK5 Update 6
may differ:

```
FACILITYSVC244                                              NONE
FACILITYSVC244                                      ADMIN   READ
FACILITYSVC244                                      FTPD    READ
FACILITYSVC244                                      STCGROUPREAD
```

A user gets READ through the group that the member #cmd("USERS") of the
same data set assigns. On the system of this example #cmd("HERC01"),
#cmd("HERC02") and #cmd("IBMUSER") are in the group #cmd("ADMIN") and may
call the functions. #cmd("HERC03") and #cmd("HERC04") are in the group
#cmd("USER"), which the entry does not name: for them the functions return
#cmd("-5"). Look at the member of your own system, and add a line for every
group whose execs use the NJE38 functions.

The lines of the member must stay in ascending order, with the line for all
users first, or RAKF does not initialize the table. RAKF reads the member
when it starts: after a change, start it again with #cmd("S RAKF").

*Order of the calls.* Call #cmd("__NJEINIT") once. Call
#cmd("__NJEREGISTER") with the user ID of the logged-on user, then
#cmd("__NJERECEIVE") in a loop, and #cmd("__NJESEND") whenever the exec
sends a message. At the end call #cmd("__NJEDEREGISTER"). Any other
function called before #cmd("__NJEINIT") ends in error 65 or 67.

*Errors.* These errors end the exec, as any REXX error:

#tab(caption: [Errors of the NJE38 functions])[
  #table(columns: (0.6in, 1fr, 1.8in),
    [Error], [Text], [Raised by],
    [40], [_Incorrect call to routine_ (a wrong number of arguments, or a
       user ID of more than 8 characters)],
      [all but #cmd("__NJEINIT"); the user ID only for
       #cmd("__NJEREGISTER") and #cmd("__NJEDEREGISTER"), checked before
       the state of NJE38 (errors 65 and 67)],
    [65], [_NJE38 STC not active_],
      [all five: #cmd("__NJEINIT") finds NJE38 not running, or another
       function was called before it],
    [66], [_NJE38 interface modul NJERLY not found_],
      [#cmd("__NJEINIT")],
    [67], [_NJE38 subsystem not initialized_],
      [all but #cmd("__NJEINIT"), when called before it and NJE38 is
       running],
    [68], [_NJE38 user "..." not registered_ (the text shows the user ID
       of the last #cmd("__NJEREGISTER"), #cmd("(none)") if there was none)],
      [#cmd("__NJERECEIVE")],
    [71], [_NJE38 user "..." is not the logged-on user_ (the text shows the
       user ID as given, in upper case\; for an empty one the text ends
       after the first quotation mark)],
      [#cmd("__NJEREGISTER"), checked before the state of NJE38 (errors 65
       and 67)],
  )
] <ext-nje-errors>

*The subtask.* The first #cmd("__NJERECEIVE") attaches a subtask of the
address space. It registers the user with #cmd("NJERLY"), waits for
messages and queues them for #cmd("__NJERECEIVE"). It is ended by
#cmd("__NJEDEREGISTER"). The subtask waits only while a
#cmd("__NJERECEIVE") is in progress, and only then is the job step
authorized by SVC 244: the authorization is the one of the whole job step,
not of the subtask, so it ends with the call. Between two calls, and after
#cmd("__NJERECEIVE") has returned, the job step is as unauthorized as it
was (#cmd("SYSVAR('SYSAUTH')") shows it). An exec that ends without
#cmd("__NJEDEREGISTER"), by an error or by an abend that BREXX/370 catches,
ends the subtask and returns the authorization itself. @ext-nje-limits
lists what the subtask cannot cope with.

*One receiving user.* #cmd("__NJERECEIVE") has no user argument. It
receives for the user that #cmd("__NJEREGISTER") registered, the
logged-on user. An exec cannot register another user.

*Registering again.* A user stays known to the functions until the exec
ends. After #cmd("__NJEDEREGISTER"), #cmd("__NJEREGISTER") of the same
user returns #cmd("24"), and #cmd("__NJERECEIVE") returns the event
#cmd("#STOP") at once. Run a new exec.

#tab(caption: [Variables set by the NJE38 functions])[
  #table(columns: (1.1in, 1fr),
    [Variable], [Contents],
    [#cmd("#MSG")], [1, the event of a message.],
    [#cmd("#STOP")], [2, the event of a subtask that has stopped.],
    [#cmd("#TIMEOUT")], [3, the event of a timeout.],
    [#cmd("#ERROR")], [4, the event of an error.],
    [#cmd("#COMPLETE")], [5. No function returns it.],
    [#cmd("_DATA")], [The text of a message, set by
      #cmd("__NJERECEIVE").],
    [#cmd("_RC")], [The return code of #cmd("NJERLY"), set by
      #cmd("__NJERECEIVE") when it returns #cmd("#STOP") or
      #cmd("#ERROR").],
  )
] <ext-nje-vars>

The event constants are set by #cmd("__NJEINIT").

== NJE38 Functions <ext-nje-functions>

=== \_\_NJEINIT <ext-nje-njeinit>

#idx("__NJEINIT")
```
__NJEINIT()
```
Checks that the NJE38 started task is running and that the module
#cmd("NJERLY") can be loaded, and sets the event constants
(@ext-nje-vars). It must be called before any other NJE38 function. If
NJE38 is not running it ends in error 65, if #cmd("NJERLY") is not found
in error 66. It returns no value; call it with #cmd("CALL").

```
CALL __njeinit
```

=== \_\_NJEREGISTER <ext-nje-njeregister>

#idx("__NJEREGISTER")
```
__NJEREGISTER(userid)
```
Makes #var("userid") known to the NJE38 functions. The user ID is
converted to upper case and has at most 8 characters; a longer one ends
in error 40. It must be the user ID of the logged-on user, that is the
user of the job or TSO session, the value of #cmd("USERID()"). Any other
user ID, an empty one, or a call from an address space without a user,
ends in error 71 and registers nothing: an exec cannot receive the NJE38
messages of another user, also when it runs authorized. Returns #cmd("0")
if the user was registered, #cmd("24") if it already was, and #cmd("-5") if
the user has no access to SVC 244 (@ext-nje-use). The call does
not contact NJE38; the registration with #cmd("NJERLY") is made by the
subtask that the first #cmd("__NJERECEIVE") starts.

```
IF __njeregister(userid()) = 24 THEN SAY 'already registered'
```

=== \_\_NJERECEIVE <ext-nje-njereceive>

#idx("__NJERECEIVE")
```
__NJERECEIVE([timeout])
```
Waits for a message for the registered user, at most #var("timeout")
milliseconds (default 5000, counted in steps of 100). The first call
starts the subtask (@ext-nje-use) and waits up to a second for it to
become ready. It returns the number of the event:

#deflist(width: 1.2in,
  [#cmd("#MSG")], [A message arrived. Its text, of up to 120 characters,
    is in #cmd("_DATA"). One call returns one message.],
  [#cmd("#STOP")], [The subtask has stopped: after
    #cmd("__NJEDEREGISTER"), or because #cmd("NJERLY") ended its wait with
    return code 8 or 32. After #cmd("NJERLY") ended its wait, #cmd("_RC")
    holds its return code (8 or 32). After #cmd("__NJEDEREGISTER") the
    value of #cmd("_RC") is not defined.],
  [#cmd("#TIMEOUT")], [No message arrived in time.],
  [#cmd("#ERROR")], [The subtask failed. #cmd("_RC") holds the return code
    of #cmd("NJERLY"), or #cmd("-1") if the subtask could not be attached,
    #cmd("-2") if it ended in a system abend (the abend is not reported
    otherwise), #cmd("-5") if the user has no access to SVC 244. In that
    case the next call tries to attach it again.],
)

After #cmd("#STOP") or #cmd("#ERROR"), every further call returns the
same event at once. Call #cmd("__NJEDEREGISTER") then.

```
CALL __njeinit
CALL __njeregister userid()
DO FOREVER
  ev = __njereceive(30000)
  IF ev = #MSG THEN SAY _data
  ELSE IF ev <> #TIMEOUT THEN LEAVE
END
CALL __njederegister userid()
```

=== \_\_NJESEND <ext-nje-njesend>

#idx("__NJESEND")
```
__NJESEND(node, userid, text)
```
Sends #var("text") to user #var("userid") on the node #var("node"). It
issues the TSO command #cmd("NJE38 MSG") #var("node") #var("userid")
#var("text") the way #cmd("ADDRESS TSO") does, and returns its return
code. It therefore runs only under TSO, as a command processor: in an
ordinary batch step, without the terminal monitor program, it returns
#cmd("-3") and sends nothing. It also returns #cmd("-3") if the command
#cmd("NJE38") is not found, and #cmd("-4") if the command line, from
#cmd("NJE38") to the end of #var("text"), is longer than 265 characters.
It returns #cmd("-5") if the user has no access to SVC 244
(@ext-nje-use).

```
rc = __njesend('MVSA', 'HERC01', 'HELLO')
IF rc <> 0 THEN SAY 'message not sent, rc' rc
```

Under #cmd("IKJEFT01") a message to oneself, #cmd("__NJESEND") to the node
of #cmd("SYSVAR('SYSNODE')") and the own user ID, arrives at the
#cmd("__NJERECEIVE") of the same exec. Without access to SVC 244 it returns
#cmd("-5") and writes the message #cmd("BRX0010E") (once) to
#cmd("STDERR").

=== \_\_NJEDEREGISTER <ext-nje-njederegister>

#idx("__NJEDEREGISTER")
```
__NJEDEREGISTER(userid)
```
Ends the subtask of #var("userid") and waits until it has ended. The user
ID is converted to upper case and limited to 8 characters, as with
#cmd("__NJEREGISTER"). Returns:

#deflist(width: 1.2in,
  [#cmd("0")], [The subtask ended normally, or there was nothing to end:
    #cmd("__NJERECEIVE") was never called for that user, or the user was
    deregistered before, or the subtask had stopped by itself
    (#cmd("#STOP")).],
  [#cmd("28")], [The user is not registered.],
  [#cmd("-2")], [The subtask had ended in a system abend.],
  [other], [The return code of the subtask: the one that #cmd("NJERLY")
    gave when it deregistered the user or, if the subtask failed while
    registering the user, the one it gave then.],
)

```
rc = __njederegister(userid())
```

== Limits <ext-nje-limits>

- *#cmd("PRIVILEGE('ON')") and the first #cmd("__NJERECEIVE").* If
  #cmd("PRIVILEGE('ON')") is in effect when the first #cmd("__NJERECEIVE")
  attaches the subtask, the job step runs in key 0 and the subtask ends in
  system abend S306. #cmd("__NJERECEIVE") returns #cmd("#ERROR") with
  #cmd("_RC") #cmd("-2"). Call #cmd("PRIVILEGE('OFF')") before the first
  #cmd("__NJERECEIVE").
- *A user abend of the job step.* An abend such as #cmd("ABEND 100") is no
  clean end: NJE38 keeps the registration of the user, and the next
  #cmd("__NJERECEIVE") of that user returns #cmd("#ERROR") with #cmd("_RC")
  #cmd("24"), the return code of NJE38 for a user that is registered
  already. It stays so until the operator restarts NJE38 (#cmd("P NJE38"),
  #cmd("S NJE38")).
- *#cmd("__NJESEND") only under TSO.* It runs the command #cmd("NJE38") and
  returns #cmd("-3") in a step without the terminal monitor program
  (@ext-nje-njesend).
- *#cmd("NOSTAE").* Without the abend handler of BREXX/370, nothing gives
  the authorization back after an abend inside #cmd("__NJESEND"); the job
  step stays authorized, as it does after an abend with
  #cmd("PRIVILEGE('ON')"). This is read from the source, not measured.
- *A subtask that abends while it takes the authorization.* The take runs
  under a lock. If the subtask abends inside it, the lock may stay taken,
  and the end of the exec then waits for it. This is not measured; it is
  possible if SVC 244 is not installed.
