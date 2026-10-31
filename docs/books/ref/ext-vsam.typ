#import "../bookmaster/bookmaster.typ": *

= VSAM <ext-vsam>

#idx("VSAM")#idx("VSAMIO")
BREXX/370 reads and writes VSAM key-sequenced data sets (KSDS) with the
host command #cmd("VSAMIO"). The interface is based on Steve Scott's
VSAM API (#cmd("RXVSAM")), with his kind permission. The API itself can
handle KSDS, RRDS and ESDS; #cmd("VSAMIO") uses only KSDS.

== Using VSAMIO <ext-vsam-use>

#cmd("VSAMIO") is a host command, written as a string like
#cmd("EXECIO"). BREXX/370 carries it out itself, under
#cmd("ADDRESS MVS") and under #cmd("ADDRESS TSO"), also without TSO
(@ext-address); under any other environment the return code is
#cmd("-3"). Each command names the data set by a DD name, which must be
allocated beforehand, by a DD statement, the TSO command
#cmd("ALLOCATE") or the function #cmd("ALLOCATE") (@ext-dataset-allocate);
a data set name is not accepted.

```
"VSAMIO OPEN VSIN (READ"
"VSAMIO READ VSIN (KEY" key "VAR RECORD"
"VSAMIO CLOSE VSIN"
```

The command is split into words at blanks, parentheses and commas.
Keywords may be written in any case; the DD name, the key and the
variable name are passed as written. A variable name in the string must
therefore be in upper case (#cmd("VAR RECORD")): REXX knows the variable
#cmd("record") as #cmd("RECORD").

*Keys.* The key is part of the record, and the commands that need one
take it again with #cmd("KEY"). A key shorter than the key length of
the cluster is generic: it stands for the first record whose key begins
with it, or the next higher one. A key is a single word: it cannot
contain blanks, parentheses or commas. Replace blanks in a key, for
example with #cmd("key = TRANSLATE(key,'_',' ')"), and store the records
that way.

*Records.* #cmd("READ") stores a record in the variable named by
#cmd("VAR") with its full length. Without #cmd("VAR"), the record is
queued on the data stack instead, up to its first #cmd("X'00'").
#cmd("WRITE") and #cmd("INSERT") take the record from the variable named
by #cmd("VAR"), or without #cmd("VAR") pull it from the stack; in both
cases the record ends before its first #cmd("X'00'"), so a record cannot
contain that byte. The variable name after #cmd("VAR") may be up to 250
characters long, the key after #cmd("KEY") up to 254; a missing or longer
one is error 40.

*Random and sequential access.* #cmd("READ"), #cmd("WRITE") and
#cmd("DELETE") with #cmd("KEY") access a record directly. With
#cmd("NEXT") they work sequentially, from the position that
#cmd("LOCATE") set or that the previous sequential command left. The
two kinds of access use separate VSAM strings and do not affect each
other: a #cmd("READ") with #cmd("KEY") does not set the position for
#cmd("READ NEXT"); use #cmd("LOCATE") for that. Neither kind sees the
changes of the other. After a record has been updated, inserted or
deleted by one kind of access, the other kind may still return the old
state or fail with #cmd("RCX") #cmd("008-00020") or #cmd("008-00092")
(exclusive control). When a data set is being changed, do not mix the
two kinds on it: do one kind of work, #cmd("CLOSE") the data set, and
open it again for the other.

*Return codes.* After each command, #cmd("RC") is:

#deflist(width: 1.2in,
  [#cmd("0")], [Done.],
  [#cmd("4")], [A warning, typically: no record with that key, or the
    end of the data set.],
  [#cmd("8")], [An error.],
  [#cmd("16")], [A request that the interface does not know.],
  [#cmd("-1")], [The DD name is empty or longer than 8 characters.],
)

#idx("RCX")
The variable #cmd("RCX") holds the extended return code,
#var("rrr")#cmd("-")#var("vvvvv"): #var("rrr") is the return code of the
function and #var("vvvvv") the VSAM return code. Their meaning is listed
under message IDC3351I in IBM's _OS/VS2 System Messages_. A command
that is not valid, or that lacks a required keyword, ends in error 40.

*The VSAM subtask.* The I/O runs in a subtask of the address space,
which is attached by the first #cmd("VSAMIO") command and ends itself
when the last open data set is closed. It loads the module
#cmd("IRXVSMIO"), which must be in the program search order, like the
#cmd("BREXX") module. Close every data set before the exec ends.

An exec that ends while a data set is still open, or that ends
abnormally, gets system abend A03 (a task that ends while its subtask is
still active). A failed #cmd("OPEN") leaves nothing behind: its data set
is not counted as open, and the subtask ends if no other data set is
open.

*Limitations.* The interface has been tested with clusters defined
#cmd("UNIQUE"), not with suballocated ones. An empty KSDS cannot be
processed: load one record into it first, for example with IDCAMS
#cmd("REPRO"); after that, #cmd("VSAMIO") can add records.

*Tracing.* If the DD name on #cmd("OPEN") begins with #cmd("#%"), the
interface loads the trace module #cmd("IRXVSMTR") instead of
#cmd("IRXVSMIO"). The trace module writes a message to the console for
every request, for example #cmd("ACCESS TRACE, REQUEST = READO"). The
prefix takes two of the eight characters of the DD name, so the data set
must be allocated under a DD name of at most six characters. The
following commands name the data set without the prefix:

```
"VSAMIO OPEN #%VSIN (READ"
"VSAMIO READ VSIN (KEY" key "VAR RECORD"
"VSAMIO CLOSE ALL"
```

== VSAMIO Commands <ext-vsam-commands>

=== VSAMIO OPEN <ext-vsam-open>

#idx("VSAMIO OPEN")
```
"VSAMIO OPEN ddname (READ|UPDATE|LOAD|RESET"
```
Opens the data set allocated to #var("ddname"):

#deflist(width: 1.2in,
  [#cmd("READ")], [For reading only.],
  [#cmd("UPDATE")], [For reading, updating, inserting and deleting.],
  [#cmd("LOAD")], [Resets the data set to empty and opens it for
    loading.],
  [#cmd("RESET")], [Resets the data set to empty and opens it for
    update.],
)

#cmd("LOAD") and #cmd("RESET") need a cluster defined #cmd("REUSE"). On
any other cluster the #cmd("OPEN") fails with #cmd("RC") 8 and
#cmd("RCX") #cmd("008-00232"). Opening a data set that #cmd("VSAMIO")
has already open also gives #cmd("RC") 8 (#cmd("008-00004")). For a DD
name that is not allocated, #cmd("RCX") is #cmd("008-00128").

```
"VSAMIO OPEN VSIN1 (READ"
"VSAMIO OPEN VSIN2 (UPDATE"
SAY rc rcx
```

=== VSAMIO READ <ext-vsam-read>

#idx("VSAMIO READ")
```
"VSAMIO READ ddname (KEY key [UPDATE] [VAR name]"
"VSAMIO READ ddname (NEXT [UPDATE] [VAR name]"
```
With #cmd("KEY"), reads the record with key #var("key") (random
access). With #cmd("NEXT"), reads the next record from the current
position (sequential access); without an earlier #cmd("LOCATE"), that
is the first record. #cmd("UPDATE") announces that the record is to be
written back or deleted; it requires #cmd("OPEN") with #cmd("UPDATE").
A record that is not found gives #cmd("RC") 4. A generic key reads the
first record whose key begins with it, or the next higher one.

```
"VSAMIO READ VSIN1 (KEY" key1 "VAR RECORD1"
"VSAMIO READ VSIN2 (KEY" key2 "UPDATE VAR RECORD2"
```

=== VSAMIO LOCATE <ext-vsam-locate>

#idx("VSAMIO LOCATE")#idx("VSAMIO POINT")
```
"VSAMIO LOCATE ddname (KEY key"
"VSAMIO POINT ddname (KEY key"
```
Positions to the record with the key #var("key"), or, if there is none,
to the next higher one; a generic key positions to the first record
whose key begins with it. A following #cmd("READ NEXT") reads from there. #cmd("RC") 4 means
that no record follows. #cmd("POINT") is the same command.

```
"VSAMIO LOCATE VSIN (KEY" prefix
DO FOREVER
   "VSAMIO READ VSIN (NEXT VAR RECORD"
   IF rc <> 0 THEN LEAVE
   SAY record
END
```

=== VSAMIO WRITE <ext-vsam-write>

#idx("VSAMIO WRITE")
```
"VSAMIO WRITE ddname (KEY key [VAR name]"
"VSAMIO WRITE ddname (NEXT [VAR name]"
```
With #cmd("KEY"), writes the record with key #var("key"). If the last
request was a #cmd("READ ... (KEY ... UPDATE") that found the record, the
record is replaced; otherwise it is inserted, which fails if a record
with that key exists. So read the key with #cmd("UPDATE") first, as the
old _User's Guide_ required, whether or not the record exists. With
#cmd("NEXT"), writes back the record that the last
#cmd("READ NEXT UPDATE") read.

```
"VSAMIO READ VSIN (KEY" key "UPDATE VAR CURRENT"
"VSAMIO WRITE VSIN (KEY" key "VAR RECORD"
IF rc <> 0 THEN SAY key 'not written:' rcx
```

=== VSAMIO INSERT <ext-vsam-insert>

#idx("VSAMIO INSERT")
```
"VSAMIO INSERT ddname (KEY key [VAR name]"
```
Inserts a new record with key #var("key"). No preceding #cmd("READ") is
needed. If a record with that key exists, #cmd("RC") is 8 and #cmd("RCX")
#cmd("008-00008"). Two more cases are errors: a record longer than the
maximum record size of the cluster (#cmd("008-00108")), and an
#cmd("INSERT") or #cmd("WRITE") on a data set opened #cmd("READ")
(#cmd("008-00068")).

=== VSAMIO DELETE <ext-vsam-delete>

#idx("VSAMIO DELETE")
```
"VSAMIO DELETE ddname (KEY key"
"VSAMIO DELETE ddname (NEXT"
```
With #cmd("KEY"), deletes the record with key #var("key"); a
#cmd("READ ... UPDATE") before it is not needed. If there is no record
with that key, nothing is deleted and #cmd("RC") is 8 (#cmd("RCX")
#cmd("004-00004")). With #cmd("NEXT"), deletes the record that the last
#cmd("READ NEXT UPDATE") read. The key #cmd("$NEXT") means the same as
#cmd("NEXT"). A generic key is not allowed. The data set must be open
for #cmd("UPDATE").

```
"VSAMIO OPEN VSIN (UPDATE"
"VSAMIO LOCATE VSIN (KEY" prefix
DO FOREVER
   "VSAMIO READ VSIN (NEXT UPDATE VAR RECORD"
   IF rc <> 0 THEN LEAVE
   "VSAMIO DELETE VSIN (NEXT"
END
```

=== VSAMIO CLOSE <ext-vsam-close>

#idx("VSAMIO CLOSE")
```
"VSAMIO CLOSE ddname"
"VSAMIO CLOSE ALL"
```
Closes the data set allocated to #var("ddname"), or, with #cmd("ALL"),
every data set that #cmd("VSAMIO") has open. When the last one is
closed, the VSAM subtask ends.

```
"VSAMIO CLOSE ALL"
```

== Sample Application <ext-vsam-sample>

The installation includes a small student database as an example: a
KSDS of fictitious students with name, birth date, field of study and
address. These members of the JCL library run it in batch:

#deflist(width: 1.2in,
  [#cmd("STUDENTC")], [Defines the cluster and loads a first record.],
  [#cmd("STUDENTI")], [Inserts the student records.],
  [#cmd("STUDENTK")], [Reads the records by key.],
  [#cmd("STUDENTN")], [Reads the records sequentially.],
)

The execs they run are in the samples library:

#deflist(width: 1.2in,
  [#cmd("@STUDENI")], [Inserts the student records.],
  [#cmd("@STUDENK")], [Reads the records by key.],
  [#cmd("@STUDENN")], [Reads the records sequentially.],
  [#cmd("@STUDENL")], [Queries the records with formatted screens
    (@ext-fss); run it in TSO.],
)
