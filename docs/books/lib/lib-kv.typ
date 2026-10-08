#import "../bookmaster/bookmaster.typ": *

= The Key/Value Database <lib-kv>

#idx("key/value database")#idx("KEYVALUE")
The key/value database stores records under a key in a VSAM KSDS and lets
an exec link records to one another, so that simple hierarchical or graph
structures can be kept without knowing VSAM. It is written in REXX: the
RXLIB member #cmd("KEYVALUE") holds all its functions, and an exec makes
them available with

```
CALL IMPORT KEYVALUE
```

The functions use the VSAM interface of BREXX/370
(#cmd("ADDRESS MVS \"VSAMIO ...\""), described in the
_BREXX/370 Reference_, "VSAM"). They work in TSO and in batch, as long as
the two clusters can be allocated.

== Structure of the Database <lib-kv-structure>

#idx("key/value database", "key structure")
The database consists of two VSAM clusters, both defined by the install job
#cmd("$CREKEYV"):

#deflist(width: 1.4in,
  [#cmd("BREXX.KEYVALUE")], [The source records. #cmd("KEYS(44 0)"),
    #cmd("RECORDSIZE(64 8192)"), DD name #cmd("KEYVALUE").],
  [#cmd("BREXX.KEYREFS")], [The references (links) between source
    records. #cmd("KEYS(105 0)"), #cmd("RECORDSIZE(128 512)"), DD name
    #cmd("KEYREFS").],
)

The 44-byte key of a source record is made of three parts:

#deflist(width: 1.4in,
  [Room], [2 bytes. A partition of the database (@lib-kv-dbroom). Each
    room is a database of its own; the same key can exist in several
    rooms.],
  [Qualifier], [10 bytes. A record type, such as #cmd("country") or
    #cmd("city"). It is always stored in lowercase. When a key is given
    without a qualifier, the qualifier is #cmd("any").],
  [Key], [32 bytes. The key proper.],
)

A record is the 44-byte key, one status byte and the value: #cmd("S") for a
source record written by #cmd("DBSET"), #cmd("D") for a dummy record that
#cmd("DBLINK") created because one of the records it linked did not exist.
With #cmd("RECORDSIZE(64 8192)") a value can be up to 8147 bytes long.

A reference record has a 105-byte key: a direction byte (#cmd("F") for the
link as made, #cmd("B") for the same link seen from its target), the full
keys of both records and a 16-byte link type. #cmd("DBLINK") writes both
directions.

In a key, qualifier and key are padded with #cmd("_") to their full length
and blanks are replaced by #cmd("_")\; the functions translate them back
when they report a key. Functions take a key as

```
[qualifier.]key
```

With the standard profile the key part is translated to uppercase
(#cmd("ddprof.keyupper=1"), @lib-kv-profile); the qualifier is always
lowercase.

== Installing the Database <lib-kv-install>

#idx("$CREKEYV")
The functions need no installation of their own, but the two clusters must
exist. The member #cmd("$CREKEYV") of the installation library is a job
that creates them: it writes a control record of 255 #cmd("9") characters
with BREXX, then deletes, defines and primes #cmd("BREXX.KEYVALUE") and
#cmd("BREXX.KEYREFS") with IDCAMS. Set the volume in its
#cmd("VOLUMES(XXXXXX)") operands, and the job card, before submitting it.

#note[The job begins with #cmd("DELETE") of both clusters. Run it again
only if the data in the existing database is to be lost.]

The library members involved are:

#deflist(width: 1.4in,
  [#cmd("KEYVALUE")], [RXLIB member with all the functions of this
    chapter.],
  [#cmd("DBPROF")], [RXLIB member with the standard profile
    (@lib-kv-profile).],
  [#cmd("DBWORLD")], [Sample: loads a database of countries, cities and
    trade unions into the room #cmd("WORLD"), with links between them.],
  [#cmd("KVSAMP1")], [Sample: writes and reads a few records.],
)

== A First Example <lib-kv-example>

```
CALL IMPORT KEYVALUE
SAY 'OPEN ' DBOPEN()
CALL DBSET 'Continent.Europe', 'Continent Europe'
CALL DBSET 'Continent.Asia',   'Continent Asia'
CALL DBGET 'Continent.Europe'
SAY dbresult                     /* Continent Europe */
CALL DBGET 'Continent.Asia'
SAY dbresult                     /* Continent Asia   */
SAY 'CLOSE' DBCLOSE()            /* CLOSE 0          */
```

#cmd("DBOPEN") reports the room it checks in to and that the database is
open:

```
KV160I    Check-in Standard Room  (AA)
KV120I    Key/Value DB successfully opened
```

== Variables Set by the Functions <lib-kv-vars>

#idx("key/value database", "variables")
Besides their return value, the record functions set these variables in
the calling exec:

#deflist(width: 1.4in,
  [#var("dbRC")], [The return code of the function.],
  [#var("dbKey")], [The key, without the qualifier.],
  [#var("dbFKey")], [The full 44-byte key: room, qualifier and key.],
  [#var("dbResult")], [The record or value; what it holds depends on the
    function and is given with each.],
  [#var("dbRecStat")], [After #cmd("DBGET"): the status byte, #cmd("S")
    or #cmd("D").],
  [#var("dbQualifier")], [After #cmd("DBNEXT"): the qualifier.],
  [#var("dbLHS"), #var("dbRHS")], [After #cmd("DBLINK") and
    #cmd("DBDELREF"): the full keys of the two records.],
)

== Opening, Closing and Rooms <lib-kv-open>

=== DBOPEN <lib-kv-dbopen>

#idx("DBOPEN")
```
DBOPEN([profile])
```
Runs the profile #var("profile") (default #cmd("DBPROF")), allocates the
two clusters it names, opens them for update and checks in to the standard
room, #cmd("Hilbert's Lobby"). If the database of that profile is already
open, #cmd("DBOPEN") returns #cmd("1") and does nothing. If the profile,
an allocation or an open fails, the exec ends with a message.

#note[*To be confirmed:* the return value of a successful open. The
function returns the special variable #cmd("RC") as it stands after the
open; #cmd("0") and #cmd("4") have both been seen.]

Only one database can be open at a time. To use another one, close the
first with #cmd("DBCLOSE").

=== DBCLOSE <lib-kv-dbclose>

#idx("DBCLOSE")
```
DBCLOSE([profile])
```
Closes and frees both clusters and returns #cmd("0").

=== DBROOM <lib-kv-dbroom>

#idx("DBROOM")
```
DBROOM(room)
```
Checks in to the room #var("room"), creating it if it does not exist, and
returns #cmd("0"). The name is translated to uppercase. All record
functions that follow act in this room only; rooms cannot see one another.
A new room gets a two-character room id, recorded with the name in the
control records of the database. When an information model of the room
exists (@lib-kv-model), it is loaded.

```
CALL DBROOM 'Beverages'
CALL DBSET 'Beer', 'Munich Hofbraeuhaus'
CALL DBROOM 'Booze'
CALL DBSET 'Beer', 'Guinness'
CALL DBGET 'Beer'
SAY dbresult                     /* Guinness */
CALL DBROOM 'Beverages'
CALL DBGET 'Beer'
SAY dbresult                     /* Munich Hofbraeuhaus */
```

=== DBROOMS <lib-kv-dbrooms>

#idx("DBROOMS")
```
CALL DBROOMS
```
Lists all rooms of the database with their room id and the number of
records in each. It returns no value, so call it with #cmd("CALL").

== Reading and Writing Records <lib-kv-records>

=== DBSET <lib-kv-dbset>

#idx("DBSET")
```
DBSET([qualifier.]key, value)
```
Writes the record #var("key") with #var("value"), replacing a record with
the same key. Returns #cmd("0") when the record was written, otherwise the
return code of the VSAM write. #var("dbResult") holds the whole record,
key and status byte included. A value can be built from several parts with
the RXLIB function #cmd("DCL").

```
SAY DBSET('Cont.Europe', 'Continent Europe')   /* 0 */
```

=== DBGET <lib-kv-dbget>

#idx("DBGET")
```
DBGET([qualifier.]key [, details])
```
Reads the record #var("key"). Returns #cmd("0") when it was found, else the
return code of the VSAM read. #var("dbResult") holds the value and
#var("dbRecStat") the status byte.

With #var("details") (any value), the value is split at #cmd(";;") into
the attributes of the information model (@lib-kv-model), and each is
stored into a variable #var("key")#cmd(".#")#var("attribute").

#note[*To be confirmed:* #var("details") for a key that contains blanks or
periods, which the generated variable name cannot hold.]

=== DBDEL <lib-kv-dbdel>

#idx("DBDEL")
```
DBDEL([qualifier.]key)
```
Deletes the record #var("key"). Returns #cmd("0") when it was deleted and
#cmd("8") when it did not exist or could not be deleted. #var("dbResult")
holds the deleted record, key included. Links to and from the record are
not removed; use #cmd("DBDELREFALL").

=== DBLOCATE <lib-kv-dblocate>

#idx("DBLOCATE")
```
DBLOCATE([qualifier.]key)
```
Positions the database at the first record whose key is #var("key") or
follows it, for reading with #cmd("DBNEXT"). #var("key") may be the
beginning of a key, or empty: #cmd("DBLOCATE('city.')") positions at the
first record of the qualifier #cmd("city"). Returns the return code of the
VSAM locate.

=== DBNEXT <lib-kv-dbnext>

#idx("DBNEXT")
```
DBNEXT()
```
Reads the next record after #cmd("DBLOCATE"). Returns #cmd("0") while the
record still begins with what was given to #cmd("DBLOCATE"), #cmd("4")
when it does not or the end of the data is reached, and #cmd("8") when the
read fails. It sets #var("dbKey"), #var("dbFKey"), #var("dbQualifier") and
#var("dbResult"), which here holds the status byte followed by the value.

```
CALL DBLOCATE 'Cont.'
DO WHILE DBNEXT()=0
   SAY dbkey ':' SUBSTR(dbresult, 2)
END
```

#note[*A defect* (brexx370 issue 386): #cmd("DBLOCATE") of a key that
contains blanks. The prefix that #cmd("DBNEXT") compares keeps the
blanks while the stored key has #cmd("_") in their place, so the first
#cmd("DBNEXT") ends the list at once. Write #cmd("_") for the blanks.]

#note[*A defect* (brexx370 issue 386): the record in #cmd("DBRESULT") carries the status byte as its first character.]

== Links Between Records <lib-kv-links>

=== DBLINK <lib-kv-dblink>

#idx("DBLINK")
```
DBLINK([qualifier.]key1, [qualifier.]key2, type [, text])
```
Links the record #var("key1") to #var("key2") with the link type
#var("type") (up to 16 characters, stored in lowercase). #var("text") is
kept in the reference record. The link is written in both directions, so it
can be followed from either record.

If a record does not exist, #cmd("DBLINK") creates a dummy record with the
value #cmd("DUMMY") for it when the profile sets
#cmd("ddprof.EnableDummy=1") (the standard), and fails otherwise. Returns
#cmd("0") when the link was written. #var("dbLHS") and #var("dbRHS") hold
the full keys.

```
CALL DBLINK 'country.Germany', 'city.Berlin', 'capital-is'
CALL DBLINK 'city.Munich', 'country.Germany', 'part-of'
```

=== DBDELREF <lib-kv-dbdelref>

#idx("DBDELREF")
```
DBDELREF([qualifier.]key1, [qualifier.]key2, type)
```
Removes the link of type #var("type") between the two records, in both
directions. Returns #cmd("0"), or #cmd("8") when the link did not exist.

=== DBDELREFALL <lib-kv-dbdelrefall>

#idx("DBDELREFALL")
```
DBDELREFALL([qualifier.]key)
```
Removes all links made from #var("key") to other records, in both
directions. Links that other records made to #var("key") stay. Returns
#cmd("0").

#note[*A defect* (brexx370 issue 386): #cmd("DBDELREFALL") writes a stray line beginning #cmd("to del").]

=== DBRCOUNT <lib-kv-dbrcount>

#idx("DBRCOUNT")
```
DBRCOUNT([qualifier.]key, direction)
```
Returns the number of links of #var("key"). Only the first letter of
#var("direction") counts: #cmd("F") counts the links made from the record,
#cmd("B") those made to it.

#note[The old documentation gave #var("direction") as #cmd("REFERENCES")
or #cmd("USAGES"). Their first letters match no reference record, so they
return #cmd("0").]

#note[*A defect* (brexx370 issue 386): without a direction, #cmd("DBRCOUNT") always answers 0.]

=== DBREFERENCE and DBUSAGE <lib-kv-dbreference>

#idx("DBREFERENCE")#idx("DBUSAGE")
```
DBREFERENCE([qualifier.]key [, [maxlevel] [, mode]])
DBUSAGE([qualifier.]key [, [maxlevel] [, mode]])
```
Follow the links from #var("key") to the records it refers to
(#cmd("DBREFERENCE")) or from the records that refer to it
(#cmd("DBUSAGE")), and from those on, down to #var("maxlevel") levels
(default 999). A record reached a second time is marked #cmd("#") and not
followed again. Both return #cmd("0").

#deflist(width: 1.2in,
  [(omitted)], [A tree with a heading, one line per record and link,
    each with its level.],
  [#cmd("REFS")], [One line per link: link type and target, no heading.],
  [other], [As #cmd("REFS"), with each line marked #cmd(">").],
)

From the sample database (the beginning of the output):

```
CALL DBREFERENCE 'city.Munich'
```
```
References of city.Munich
------------------------------------------------------------------------
 1 city.Munich
 1 +- part-of        ->  country.GERMANY
 2 |  country.GERMANY
 2 |  +- capital-is     ->  city.BERLIN
 3 |  |  city.BERLIN
 3 |  |  +- part-of        ->  country.GERMANY
 4 |  |  |  |- capital-is     -># city.BERLIN
 ...
    -># references have been reported previously
Elements found 14
```

=== DBHOOD <lib-kv-dbhood>

#idx("DBHOOD")
```
DBHOOD([qualifier.]key)
```
Shows the neighbourhood of a record: the records that link to it, the
record in a box, and the records it links to, one level each.

=== DBPRINT <lib-kv-dbprint>

#idx("DBPRINT")
```
DBPRINT([qualifier.]key [, all])
```
Shows the record, split into the attributes of the information model
(@lib-kv-model), and its links. With #var("all") (any value), attributes of
the model that the record does not have are listed with #cmd("?_").
Returns #cmd("0"), or #cmd("8") when the record does not exist.

```
CALL DBPRINT 'country.U.S.A', 'ALL'
```
```
country.U.S.A
// ------------------------------------------
// Source available
//            Attributes
// ------------------------------------------
 *ACRONYM           USA
 *CAPITAL           Washington DC
 *DESCRIPTION       ?_
 *VISITED           ?_
// ------------------------------------------
//            Links to other Records
// ------------------------------------------
 >CAPITAL-IS        city.WASHINGTON DC
 >CONTAINED-IN      continent.NORTH AMERICA
 >MEMBER-OF         union.NORTH AMERICAN FREE TRADE
```

=== DBENCODE <lib-kv-dbencode>

#idx("DBENCODE")
```
CALL DBENCODE array
```
The reverse of #cmd("DBPRINT"): reads a record, in the form
#cmd("DBPRINT") writes it, from the string array #var("array"), writes the
record with its attributes, removes its old links and creates the links
listed. Missing target records are created as dummies.

#note[*To be confirmed:* #cmd("DBENCODE") was not documented by its author;
this description is read from the code.]

== Listing and Removing Records <lib-kv-list>

The following functions select records of the current room by a keyword and
a string. Only the first two letters of the keyword count.

#deflist(width: 1.2in,
  [#cmd("ALL")], [All records of the room (also when the keyword is
    omitted, except for #cmd("DBREMOVE")).],
  [#cmd("QUALIFIER")], [The records of the qualifier #var("string").],
  [#cmd("ONLY")], [The records whose key begins with #var("string").],
  [#cmd("ANY")], [The records whose key contains #var("string").],
  [#cmd("CONTAINS")], [The records whose value contains #var("string").],
)

#note[*To be confirmed:* #var("string") is compared as given. With
#cmd("ddprof.keyupper=1") the keys are stored in uppercase, so
#cmd("ONLY") and #cmd("ANY") need it in uppercase.]

=== DBLIST <lib-kv-dblist>

#idx("DBLIST")
```
DBLIST([keyword, string])
```
Lists the selected records, one per line: qualifier and key,
#cmd("Source") or #cmd("Dummy"), and the value; then their number.

```
CALL DBLIST 'QUALIFIER', 'continent'
```

=== DBKEEP <lib-kv-dbkeep>

#idx("DBKEEP")
```
DBKEEP([keyword, string])
```
Selects as #cmd("DBLIST") does, but keeps the result in a new string array
and returns its number. Each entry is the full key followed by the word
#cmd("active").

```
s1 = DBKEEP('QUALIFIER', 'country')
buffer.0 = 'ARRAY' s1
CALL FMTLIST
```

=== DBREMOVE <lib-kv-dbremove>

#idx("DBREMOVE")
```
DBREMOVE(keyword [, string])
```
Deletes the selected records and lists each one. The keyword is
required: #cmd("DBREMOVE('ALL')") empties the current room. There is no
function that empties the whole database.

== The Information Model <lib-kv-model>

#idx("key/value database", "information model")
An information model divides the value of a record into named attributes,
by qualifier. The attributes are stored in the value separated by
#cmd(";;"). The model belongs to the room; #cmd("DBROOM") loads it, and
#cmd("DBGET"), #cmd("DBPRINT") and #cmd("DBENCODE") use it.

=== DBKVIMADD <lib-kv-dbkvimadd>

#idx("DBKVIMADD")
```
CALL DBKVIMADD 'qualifier: attribute ...'
```
Adds the attributes of one qualifier to the model being built. The names
are translated to uppercase.

=== DBKVIMBUILD <lib-kv-dbkvimbuild>

#idx("DBKVIMBUILD")
```
CALL DBKVIMBUILD
```
Stores the model built with #cmd("DBKVIMADD") in the control record of the
current room. Define the model before the records are loaded:

```
CALL DBROOM 'World'
CALL DBKVIMADD 'country: Acronym Capital Description Visited'
CALL DBKVIMADD 'city: Population Description'
CALL DBKVIMBUILD
CALL DBSET 'country.U.S.A', 'USA;;Washington DC'
```

#note[*To be confirmed:* #cmd("DBKVIMBUILD") does not reload the model;
in the run that builds it, the model may take effect only at the next
#cmd("DBROOM").]

=== DBKVIMSHOW and DBKVIMATTR <lib-kv-dbkvimshow>

#idx("DBKVIMSHOW")#idx("DBKVIMATTR")
```
CALL DBKVIMSHOW
DBKVIMATTR(qualifier, n)
```
#cmd("DBKVIMSHOW") lists the model of the current room.
#cmd("DBKVIMATTR") returns the name of the #var("n")th attribute of
#var("qualifier"), or #cmd("UNDEFINED").

== Messages and Output <lib-kv-output>

#idx("key/value database", "messages")
The functions write messages of the form #cmd("KV")#var("nnn")#var("s"),
where #var("s") is the severity: #cmd("I"), #cmd("W"), #cmd("E") or
#cmd("C"). After #cmd("DBOPEN") only errors and worse are shown, unless an
earlier #cmd("DBMSGLV") set another level.

=== DBMSGLV <lib-kv-dbmsglv>

#idx("DBMSGLV")
```
CALL DBMSGLV level
```
#deflist(width: 1.2in,
  [#cmd("I")], [All messages.],
  [#cmd("W")], [Warnings and worse; a record not found is a warning.],
  [#cmd("E")], [Errors and worse.],
  [#cmd("C")], [Critical messages only.],
  [#cmd("N")], [No messages. The output of the list functions is still
    shown.],
  [#cmd("A")], [Only the messages of #cmd("DBOPEN") (#cmd("KV120I"),
    #cmd("KV160I")); the output of the list functions is suppressed as
    well.],
)

=== DBSAY <lib-kv-dbsay>

#idx("DBSAY")
```
CALL DBSAY line
```
Writes #var("line") the way the key/value functions write their output, so
that an exec can mix its own lines with theirs.

=== Redirecting the Output <lib-kv-outarray>

#idx("dbOutArray")
Messages, #cmd("DBSAY") lines and the output of the list functions go to
the terminal (#cmd("SAY")), unless:

- the global variable #cmd("dbOutArray") holds the number of a string
  array: the lines are appended to it. Set it with #cmd("SETG") and reset
  it to the null string afterwards;
- the profile sets #cmd("ddprof.outexit") to the name of a function: it is
  called with each line.

```
s4 = SCREATE(250)
CALL SETG 'dbOutArray', s4
CALL DBPRINT 'country.U.S.A'
CALL SETG 'dbOutArray', ''
buffer.0 = 'ARRAY' s4
CALL FMTLIST
```

== Saving Stems and Arrays: DBWORKBENCH <lib-kv-dbworkbench>

#idx("DBWORKBENCH")
```
DBWORKBENCH(mode, p1 [, p2])
```
Saves a stem or a string array in the room #cmd("WORKBENCH") of the
database, or loads it back, and returns to the current room.

#deflist(width: 1.4in,
  [#cmd("SSTEM"), #cmd("SAVESTEM")], [Saves the stem #var("p1") (with its
    period, such as #cmd("'BUFFER.'")), entries 0 to #var("p1")#cmd("0").],
  [#cmd("LSTEM"), #cmd("LOADSTEM")], [Loads the stem saved as #var("p1")
    into #var("p2"), or into #var("p1") itself.],
  [#cmd("SARRAY"), #cmd("SAVEARRAY")], [Saves the string array number
    #var("p1") under the name #var("p2"), which is required.],
  [#cmd("LARRAY"), #cmd("LOADARRAY")], [Loads the array saved as
    #var("p1") into a new string array and returns its number.],
)

Every other mode returns #cmd("8").

== Profiles and Additional Databases <lib-kv-profile>

#idx("DBPROF")#idx("key/value database", "profile")
A profile is a REXX member that sets the stem #cmd("ddprof.") and returns
#cmd("0"). #cmd("DBOPEN") runs it. The standard profile #cmd("DBPROF")
sets:

```
ddprof.DDKEY  ='KEYVALUE'        /* DD name of the source cluster    */
ddprof.DDREF  ='KEYREFS'         /* DD name of the reference cluster */
ddprof.DSNKEY ='BREXX.KEYVALUE'  /* source cluster                   */
ddprof.DSNREF ='BREXX.KEYREFS'   /* reference cluster                */
ddprof.keylen =32                /* key length                       */
ddprof.roomlen=2                 /* room length                      */
ddprof.quallen=10                /* qualifier length                 */
ddprof.typelen=16                /* link type length                 */
ddprof.keyupper=1                /* 1: translate keys to uppercase   */
ddprof.EnableDummy=1             /* 1: DBLINK creates dummy records  */
```

To keep another database, write a profile of your own with other names and
lengths, define its clusters from a copy of #cmd("$CREKEYV"), and open it
with #cmd("DBOPEN('")#var("profile")#cmd("')"). The key lengths of the
clusters must agree with the profile:

#deflist(width: 1.6in,
  [Source cluster], [#cmd("KEYS(")#var("k")#cmd(" 0)"), where #var("k") is
    #cmd("roomlen") + #cmd("quallen") + #cmd("keylen").],
  [Reference cluster], [#cmd("KEYS(")#var("r")#cmd(" 0)"), where #var("r")
    is 1 + #cmd("typelen") + 2 × #var("k").],
)

A profile with #cmd("keylen=12"), #cmd("roomlen=2"), #cmd("quallen=4") and
#cmd("typelen=4"), for example, needs #cmd("KEYS(18 0)") and
#cmd("KEYS(41 0)").
