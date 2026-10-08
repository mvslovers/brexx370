#import "../bookmaster/bookmaster.typ": *

= Arrays, Matrices and Linked Lists <ext-array>

#idx("array")
#idx("linked list")
#idx("matrix")
Besides compound variables (stems), BREXX/370 offers storage structures
that live outside the variable pool and are addressed by a number. They are
not part of the REXX language. A function that creates one returns its
number, the _handle_; every other function of the family takes that number
as its first argument. An item is addressed by an index that starts at 1.

A stem entry is found through the variable tree by its name; an array entry
is found directly through its index. Reading and adding entries is therefore
faster, the storage overhead is smaller, and a whole array can be sorted,
searched or filtered by one call that runs in C.

#tab(caption: [Kinds of arrays])[
  #table(columns: (1.3in, 0.7in, 1fr),
    [Kind], [At most], [Use],
    [String array], [128], [Records of any length: a data set read into
      storage, lists to sort, search, select and combine
      (@ext-array-string).],
    [Fixed-string array], [16], [Strings of one fixed maximum length
      (@ext-array-fixed).],
    [Integer array, integer matrix], [64], [Whole numbers, counters,
      indexes into a string array, hash values (@ext-array-int).],
    [Bit array], [64], [One bit per item: flags (@ext-array-bit).],
    [Float array, matrix], [128], [Numbers with a fraction, matrix
      arithmetic. A float array is a matrix of one column, so both count
      against the same 128 (@ext-array-float, @ext-array-matrix).],
    [Linked list], [32], [Entries that are inserted, removed or moved at
      any position (@ext-array-ll).],
  )
] <ext-array-kinds-tab>

The numbers are kept in one table per kind and count from 0. BREXX/370
creates string array 0 itself when it starts, so the first string array a
program creates is normally number 1. Arrays are not released at the end of
a procedure; free each one when it is no longer needed.

#idx("error 40")
A call with an array number that has not been created, or with an index
outside the size of the array, ends in error 40 (_Incorrect call to
routine_). When a table is full, creating a string array, matrix, float
array or linked list also ends in error 40, with a message; creating an
integer array or a fixed-string array returns #cmd("-8") instead. A call
takes at most 32 arguments, which limits the functions that take a list of
strings or numbers.

Strings are compared byte by byte in EBCDIC (CP037). Sorting therefore puts
lower-case letters before upper-case letters, and letters before digits.

Functions marked _Written in REXX and carried in the load module_ are REXX
procedures inside the interpreter, built on the functions in C. They behave
like the others but run at REXX speed.

== String Arrays <ext-array-string>

#idx("string array")
A string array holds entries of any length. An entry is kept as a C string:
a value is cut at its first #cmd("'00'x"). The array has a _size_, the
number of entries it can hold, and a _count_, the highest entry set.
#cmd("SSET") cannot go beyond the size; #cmd("SRESIZE") changes it.
Functions that read a data set or append entries grow the array as needed.

=== SCREATE <ext-array-screate>

#idx("SCREATE")
```
SCREATE(size)
```
Creates an empty string array that can hold #var("size") entries, at least
100, and returns its number. When all 128 string arrays are in use, the call
ends in error 40.

```
s1 = screate(500)
SAY s1                       /* e.g. 1 */
```

=== SRESIZE <ext-array-sresize>

#idx("SRESIZE")
```
SRESIZE(array, size)
```
Changes the size of #var("array") to #var("size") entries. Returns
#cmd("0"), or #cmd("4") without a change if #var("size") is not larger than
the count. Sets the variables #cmd("SARRAYHI") (the count) and
#cmd("SARRAYMAX") (the new size).

```
s1 = screate(100)
SAY sresize(s1, 2000)        /* 0 */
```

=== SSET <ext-array-sset>

#idx("SSET")
```
SSET(array, [index], value [, value]...)
```
Sets entry #var("index") to #var("value"), and the entries after it to the
further values. Without #var("index") the value is appended after the
count. An index of 0, or values that would end beyond the size, end in
error 40. Entries skipped between the count and #var("index") are set to the
null string. Returns #cmd("0").

```
s1 = screate(100)
CALL sset s1, , 'first'
CALL sset s1, 3, 'third', 'fourth'
SAY sarray(s1)               /* 4 */
SAY '>'sget(s1,2)'<'         /* >< */
```

=== SGET <ext-array-sget>

#idx("SGET")
```
SGET(array, index [, offset])
```
Returns entry #var("index"), from character #var("offset") (default 1) on.
An entry never set, or shorter than #var("offset"), returns the null string.
An index of 0 or beyond the size, or an offset of 0, ends in error 40.

```
s1 = screate(100)
CALL sset s1, 1, 'ABCDEF'
SAY sget(s1, 1)              /* ABCDEF */
SAY sget(s1, 1, 4)           /* DEF */
```

=== SFREE <ext-array-sfree>

#idx("SFREE")
```
SFREE([array [, option]])
```
Frees #var("array") and all its entries. Without an argument, frees every
string array, including array 0 that BREXX/370 created. Call it with
#cmd("CALL").

#deflist(width: 1.2in,
  [#cmd("KEEP")], [Frees the entries but keeps the array and its number;
    the count becomes 0. Any option beginning with #cmd("K") or #cmd("R")
    has this effect.],
)

```
CALL sfree s1, 'KEEP'        /* empty, still allocated */
CALL sfree s1                /* gone */
```

=== SARRAY <ext-array-sarray>

#idx("SARRAY")
```
SARRAY([array])
```
Returns the count of #var("array"), or #cmd("-1") if it does not exist.
Sets the variables #cmd("SARRAYHI") (the count), #cmd("SARRAYMAX") (the
size) and #cmd("SARRAYADDR") (the storage address of the array). Without an
argument, returns the number of string arrays possible, #cmd("128").

```
SAY sarray(s1)               /* e.g. 22 */
SAY sarraymax                /* e.g. 3000 */
```

=== SLIST <ext-array-slist>

#idx("SLIST")
```
SLIST(array [, [from] [, [to] [, heading]]])
```
Prints entries #var("from") (default 1) to #var("to") (default the count),
each with its index, under a heading. #var("heading") replaces the word
#cmd("Data") in the heading. Returns #cmd("0").

```
CALL slist s1, 1, 2, 'Band and song'
/*      Entries of Source Array: 1      */
/* Entry   Band and song                */
/* -----------------------------------  */
/* 00001   LED ZEPPELIN   STAIRWAY ...  */
/* 00002   EAGLES         HOTEL ...     */
/* 2 Entries                            */
```

=== SSWAP <ext-array-sswap>

#idx("SSWAP")
```
SSWAP(array, index1, index2)
```
Exchanges two entries. Only the pointers move, not the strings. Returns
#cmd("0").

=== SCLC <ext-array-sclc>

#idx("SCLC")
```
SCLC(array1, index1, array2, index2)
```
Compares entry #var("index1") of #var("array1") with entry #var("index2")
of #var("array2") and returns a negative number, #cmd("0") or a positive
number when the first is lower than, equal to or higher than the second.
Both may be the same array.

```
CALL sset s1, 1, 'ABC', 'ABD'
SAY sclc(s1, 1, s1, 2) < 0   /* 1 */
```

=== SQSORT <ext-array-sqsort>

#idx("SQSORT")
```
SQSORT(array [, [order] [, offset]])
```
Sorts the entries in place with a quick sort, comparing each entry from
character #var("offset") (default 1) to its end. Returns the count.

#deflist(width: 1.2in,
  [#cmd("ASCENDING")], [Lowest first (the default).],
  [#cmd("DESCENDING")], [Highest first. Only the first letter counts.],
)

#note[*To be confirmed:* #cmd("SQSORT") accepts four more arguments (a
first and last entry, a chunk size, and a flag). Whether the first and last
entry restrict the sort is not clear from the source.]

```
CALL sqsort s1, 'D', 31      /* descending, from column 31 */
```

=== SHSORT <ext-array-shsort>

#idx("SHSORT")
```
SHSORT(array [, [order] [, offset]])
```
Sorts like #cmd("SQSORT"), with a shell sort. Returns the count.

=== SREVERSE <ext-array-sreverse>

#idx("SREVERSE")
```
SREVERSE(array)
```
Reverses the order of the entries in place: the first becomes the last.
Only the pointers move.

#note[*To be confirmed:* the value returned. It is not the count; use
#cmd("SARRAY") for that.]

=== SMERGE <ext-array-smerge>

#idx("SMERGE")
```
SMERGE(array1, array2)
```
Sorts both arrays in place in ascending order, then merges them into a new
array, which is sorted as well. Returns the number of the new array.

```
s3 = smerge(s1, s2)
SAY sarray(s3)               /* sarray(s1) + sarray(s2) */
```

=== SSEARCH <ext-array-ssearch>

#idx("SSEARCH")
```
SSEARCH(array, string [, [from] [, option]])
```
Returns the index of the first entry from #var("from") (default 1) on that
contains #var("string"), or #cmd("0") if none does.

#deflist(width: 1.2in,
  [#cmd("CASE")], [Upper and lower case differ (the default).],
  [#cmd("NOCASE")], [Case does not matter. Only the first letter
    counts.],
)

```
i = ssearch(s1, 'ON')
DO WHILE i > 0
  SAY i sget(s1, i)
  i = ssearch(s1, 'ON', i+1)
END
```

=== SSEARCHI <ext-array-ssearchi>

#idx("SSEARCHI")
```
SSEARCHI(array, string [, option])
```
Searches like #cmd("SSEARCH"), with its options #cmd("CASE") and
#cmd("NOCASE"), for every entry that contains #var("string") and returns a new integer array holding their indexes. Sets the variable
#cmd("SCOUNT") to the number found. Free the integer array with
#cmd("IFREE") when done. Written in REXX and carried in the load module.

```
i1 = ssearchi(s1, 'xyz')
SAY scount                   /* e.g. 25 */
SAY iget(i1, 1)              /* index of the first hit */
CALL ifree i1
```

=== SSELECT <ext-array-sselect>

#idx("SSELECT")
```
SSELECT(array, string [, string]...)
```
Creates a new array with the entries that contain at least one of the
strings, in their order, and returns its number. The search is
case-sensitive; a null string is skipped. At most 31 strings may be given.
To look only at part of each entry for string #var("n"), set the variables
#cmd("SSELECT.FROM.")#var("n") (first character) and
#cmd("SSELECT.LENGTH.")#var("n") (length; default the rest).

```
s2 = sselect(s1, 'ON', 'OF', 'EE')
```

=== SCOUNT <ext-array-scount>

#idx("SCOUNT")
```
SCOUNT(array, string [, string]...)
```
Counts the entries that contain each string and returns the total. An entry
that holds a string twice counts once for it; an entry that holds two of
the strings counts twice.

```
SAY scount(s1, 'AC', 'IN')   /* e.g. 14 */
```

=== SDROP <ext-array-sdrop>

#idx("SDROP")
```
SDROP(array, string [, string]...)
```
Removes, in place, every entry that contains one of the strings. At most 31
strings may be given. Returns #cmd("0"); #cmd("SARRAY") gives the new count.

To drop an entry only when string #var("n") starts at a certain column, set
the variable #cmd("SDROP.AT.")#var("n") to that column.

A null string drops empty entries. With a null string among the arguments,
trailing blanks are removed from every entry, and an entry that is then
empty is dropped.

```
CALL sdrop s1, 'AC', 'IN'
sdrop.at.1 = 1
CALL sdrop s1, '*'           /* drop entries starting with * */
```

=== SKEEP <ext-array-skeep>

#idx("SKEEP")
```
SKEEP(array, string [, string]...)
```
Keeps, in place, the entries that contain at least one of the strings and
removes the others. To match string #var("n") only at one column, set
#cmd("SKEEP.AT.")#var("n"). Returns #cmd("0").

```
CALL skeep s1, 'AC', 'IN'
```

=== SKEEPAND <ext-array-skeepand>

#idx("SKEEPAND")
```
SKEEPAND(array, string [, string]...)
```
Keeps, in place, the entries that contain all of the strings. The variables
#cmd("SKEEP.AT.")#var("n") apply as for #cmd("SKEEP"). Returns #cmd("0").

```
CALL skeepand s1, 'AC', 'IN'
```

=== SCHANGE <ext-array-schange>

#idx("SCHANGE")
```
SCHANGE(array, from, to [, from, to]...)
```
Replaces in every entry each occurrence of #var("from") by #var("to"), pair
by pair. A later pair works on the result of an earlier one. The pairs must
be complete; a null #var("from") is skipped. Returns the number of entries
changed.

```
SAY schange(s1, 'IN', '**', 'EE', '+++')
```

=== SSUBSTR <ext-array-ssubstr>

#idx("SSUBSTR")
```
SSUBSTR(array, start [, [length] [, option]])
```
Applies #cmd("SUBSTR") with #var("start") and #var("length") to every
entry. Without #var("length"), the rest of the entry is taken. Returns the
number of the array that holds the result.

#deflist(width: 1.2in,
  [#cmd("EXTERNAL")], [The result goes into a new array (the default).],
  [#cmd("INTERNAL")], [The entries are replaced in place. Any option not
    beginning with #cmd("E") has this effect.],
)

```
CALL ssubstr s1, 31, , 'INTERNAL'
```

=== SWORD <ext-array-sword>

#idx("SWORD")
```
SWORD(array, n [, option])
```
Replaces every entry by its #var("n")th word, as #cmd("WORD") does. The
options #cmd("EXTERNAL") and #cmd("INTERNAL") work as for
#cmd("SSUBSTR"). Returns the number of the array that holds the result.

```
s2 = sword(s1, 2)
```

=== SUPPER <ext-array-supper>

#idx("SUPPER")
```
SUPPER(array [, option])
```
Translates every entry to upper case. The options #cmd("EXTERNAL") and
#cmd("INTERNAL") work as for #cmd("SSUBSTR"). Returns the number of the
array that holds the result.

```
CALL supper s1, 'INTERNAL'
```

=== SCONC <ext-array-sconc>

#idx("SCONC")
```
SCONC(array, index, string)
```
Appends #var("string") to entry #var("index"). Call it with #cmd("CALL").
Written in REXX and carried in the load module.

```
CALL sset s1, 1, 'ABC'
CALL sconc s1, 1, 'DEF'
SAY sget(s1, 1)              /* ABCDEF */
```

=== SNUMBER <ext-array-snumber>

#idx("SNUMBER")
```
SNUMBER(array [, length])
```
Puts the index, #var("length") digits with leading zeros (default 6), and a
blank in front of every entry. Call it with #cmd("CALL"). Written in REXX
and carried in the load module.

```
CALL snumber s1, 4
SAY sget(s1, 1)              /* e.g. 0001 record 1 */
```

=== SINSERT <ext-array-sinsert>

#idx("SINSERT")
```
SINSERT(array, after, count)
```
Inserts #var("count") empty entries after entry #var("after"), or at the
front if #var("after") is 0; the entries behind move down. An #var("after")
beyond the count is taken as the count. The array grows as needed. Returns
#cmd("0").

```
CALL sinsert s1, 0, 2        /* two empty entries in front */
```

=== SPASTE <ext-array-spaste>

#idx("SPASTE")
```
SPASTE(array, after, source [, [from] [, count]])
```
Inserts #var("count") entries of #var("source"), starting at its entry
#var("from") (default 1), after entry #var("after") of #var("array").
Without #var("count"), all entries from #var("from") to the last are
taken. The entries are copied; #var("source") does not change. Returns
#cmd("0").

```
CALL spaste s1, 5, s2        /* all of s2 after entry 5 of s1 */
```

=== SDEL <ext-array-sdel>

#idx("SDEL")
```
SDEL(array, from, count)
```
Deletes #var("count") entries from entry #var("from") on; the entries
behind move up. Returns #cmd("0"), or #cmd("8") with a message if
#var("from") is beyond the size.

```
CALL sdel s1, 3, 2           /* entries 3 and 4 */
```

=== SCOPY <ext-array-scopy>

#idx("SCOPY")
```
SCOPY(array [, [from] [, [to] [, [target] [, [start] [, length]]]]])
```
Copies entries #var("from") (default 1) to #var("to") (default the count)
into a new array, or appends them to #var("target"). With #var("start"),
each copy begins at that character of its entry; #var("length") then cuts
it to that length. A #var("start") of 1 is ignored, and #var("length")
with it. Returns the number of the array copied into.

```
s2 = scopy(s1, 10, 20)
CALL scopy s1, , , s2, 31, 20
```

=== SAPPEND <ext-array-sappend>

#idx("SAPPEND")
```
SAPPEND(target, array [, [from] [, [to] [, [start] [, length]]]])
```
Appends entries of #var("array") to #var("target"), with the arguments of
#cmd("SCOPY"). An array may be appended to itself. Returns #var("target").
Written in REXX and carried in the load module.

```
CALL sappend s1, s1, 10, 20  /* entries 10 to 20 once more */
```

=== SEXTRACT <ext-array-sextract>

#idx("SEXTRACT")
```
SEXTRACT(array, from [, to])
```
Copies entries #var("from") to #var("to") (default the count) into a new
array and returns its number.

```
s2 = sextract(s1, 6, 10)
```

=== SCUT <ext-array-scut>

#idx("SCUT")
```
SCUT(array, begin, end [, [from] [, option]])
```
Searches from entry #var("from") (default 1) for the first entry that
contains #var("begin") and the next entry after it that contains
#var("end"), and copies the entries between them into a new array. Returns
the number of the new array, or #cmd("-1") if either string is not found.
Sets the variables #cmd("_FIRSTLINE") (the entry that contains
#var("begin")) and #cmd("_LASTLINO") (the index of the last entry copied).
Written in REXX and carried in the load module.

#deflist(width: 1.2in,
  [#cmd("NO-DELIMITER")], [The entries with #var("begin") and #var("end")
    are left out (the default). Abbreviations down to #cmd("NO") are
    accepted, in upper case.],
  [#cmd("DELIMITER")], [They are copied too. Any other option has this
    effect.],
)

```
s2 = scut(s1, 'From Here', 'End')
```

=== SREAD <ext-array-sread>

#idx("SREAD")
```
SREAD(dataset [, [size] [, skip]])
```
Reads a sequential data set or a member into a new string array and returns
its number, or #cmd("-1") if it cannot be opened. #var("dataset") in
quotes is a data set name, which is allocated for the read and freed
afterwards; without quotes, it is the name of an allocated DD. The array
starts with #var("size") entries (default 3000, at least 1000) and grows as
needed. Trailing blanks are removed; a #cmd("'00'x") in a record becomes a
blank. With #var("skip") #cmd("1"), empty records and records of one
character are left out. Written in REXX and carried in the load module.

```
s1 = sread("'USER.SONGS'")
s2 = sread('INDD')
```

=== SWRITE <ext-array-swrite>

#idx("SWRITE")
```
SWRITE(array, dataset)
```
Writes all entries of #var("array") to #var("dataset"), a data set name in
quotes or the name of an allocated DD, and returns the number of records
written, or #cmd("-1") if the data set cannot be opened. A write error ends
in error 40. Written in REXX and carried in the load module.

```
SAY swrite(s1, "'USER.SONGS2'") 'records written'
```

=== SLSTR <ext-array-slstr>

#idx("SLSTR")
```
SLSTR(array)
```
Returns all entries as one string: the first entry, a semicolon, then every
further entry followed by a newline character.

#note[*To be confirmed:* the newline character is #cmd("'15'x").]

== Set Operations on String Arrays <ext-array-set>

#idx("set operations")
These functions treat a string array as a set. #cmd("SINTERSECT"),
#cmd("SDIFFERENCE"), #cmd("STDROP") and #cmd("SDIFFSYM") expect each array
sorted in ascending order and free of duplicates, as #cmd("SUNIFY") leaves
it; otherwise the result is unpredictable. #cmd("SUNION") sorts and unifies
its result itself. Except #cmd("SUNIFY"), they leave their input
unchanged.

=== SUNIFY <ext-array-sunify>

#idx("SUNIFY")
```
SUNIFY(array)
```
Sorts #var("array") in place and removes duplicate entries. When there were
duplicates, empty and blank entries are removed as well, and trailing
blanks are removed from every entry. Returns #cmd("0"). Written in REXX and
carried in the load module.

```
CALL sset s1, 1, '0005', '0003', '0005', '0001'
CALL sunify s1
CALL slist s1                /* 0001 0003 0005 */
```

=== SUNION <ext-array-sunion>

#idx("SUNION")
```
SUNION(array1, array2)
```
Returns a new array with the entries of both arrays, sorted and without
duplicates. Written in REXX and carried in
the load module.

```
s3 = sunion(s1, s2)
```

=== SINTERSECT <ext-array-sintersect>

#idx("SINTERSECT")
```
SINTERSECT(array1, array2)
```
Returns a new array with the entries that are in both arrays.

```
s3 = sintersect(s1, s2)
```

=== SDIFFERENCE <ext-array-sdifference>

#idx("SDIFFERENCE")
```
SDIFFERENCE(array1, array2)
```
Returns a new array with the entries of #var("array1") that are not in
#var("array2"): #var("array1") − #var("array2").

```
s3 = sdifference(s1, s2)
```

=== STDROP <ext-array-stdrop>

#idx("STDROP")
```
STDROP(array1, array2)
```
The same as #cmd("SDIFFERENCE"). Written in REXX and carried in the load
module.

=== SDIFFSYM <ext-array-sdiffsym>

#idx("SDIFFSYM")
```
SDIFFSYM(array1, array2)
```
Returns a new array with the entries that are in exactly one of the
arrays, the symmetric difference #var("array1") ∆ #var("array2"). Written
in REXX and carried in the load module.

```
s3 = sdiffsym(s1, s2)
```

== Fixed-String Arrays <ext-array-fixed>

#idx("fixed-string array")
A fixed-string array holds a set number of strings of one maximum length in
a single block of storage. At most 16 exist at a time.

=== SFCREATE <ext-array-sfcreate>

#idx("SFCREATE")
```
SFCREATE(size, length)
```
Creates a fixed-string array of #var("size") entries of up to
#var("length") characters each, all set to the null string, and returns
its number, or #cmd("-8") if 16 are in use.

```
f1 = sfcreate(1000, 8)
```

=== SFSET <ext-array-sfset>

#idx("SFSET")
```
SFSET(array, index, string)
```
Sets entry #var("index") to #var("string"), cut to the length of the
array. Returns #cmd("0").

=== SFGET <ext-array-sfget>

#idx("SFGET")
```
SFGET(array, index)
```
Returns entry #var("index").

```
CALL sfset f1, 1, 'SYS1.MACLIB'
SAY sfget(f1, 1)             /* SYS1.MAC */
```

=== SFFREE <ext-array-sffree>

#idx("SFFREE")
```
SFFREE(array)
```
Frees the array. Returns #cmd("0").

== Integer Arrays and Matrices <ext-array-int>

#idx("integer array")
An integer array holds whole numbers of 32 bits, without a fraction. Like a
string array it has a size and a count, the highest item set. An integer
matrix is an integer array whose items are addressed by row and column.
Integer arrays and integer matrices share one table of 64. When it is full,
the functions that create one return #cmd("-8").

=== ICREATE <ext-array-icreate>

#idx("ICREATE")
```
ICREATE(size [, mode])
```
Creates an integer array of #var("size") items and returns its number, or
#cmd("-8") if 64 are in use. Without #var("mode") the items are not
initialised and the count is 0. With #var("mode") the array is filled and
the count is #var("size"). Only the first letter of #var("mode") counts.

#deflist(width: 1.2in,
  [#cmd("ELEMENT")], [Each item holds its index: 1, 2, 3, ...],
  [#cmd("NULL")], [Each item is 0.],
  [#cmd("DESCENT")], [The indexes in reverse order: #var("size"), ..., 1.],
  [#cmd("F")], [The Fibonacci numbers 1, 1, 2, 3, 5, ...; items beyond
    the 46th are 0.],
  [#cmd("SUNDARAM")], [The prime numbers, found with the sieve of
    Sundaram.],
  [#cmd("PRIME")], [The prime numbers, found by trial division.],
)

#note[*A defect* (brexx370 issue 386): with #cmd("PRIME"), the count is
#var("size") minus 1 although #var("size") primes are stored.]

```
i1 = icreate(10, 'SUNDARAM')
SAY iget(i1, 5)              /* 11 */
```

=== ISET <ext-array-iset>

#idx("ISET")
```
ISET(array, [index], value)
```
Sets item #var("index") to #var("value"). Without #var("index") the value
is appended after the count. Raises the count if #var("index") is beyond
it. Returns #cmd("0").

```
i1 = icreate(100)
CALL iset i1, , 42
CALL iset i1, , 43
SAY iarray(i1)               /* 2 */
```

=== IGET <ext-array-iget>

#idx("IGET")
```
IGET(array, index)
```
Returns item #var("index"). An item within the size but never set returns
whatever the storage holds.

=== IADD <ext-array-iadd>

#idx("IADD")
```
IADD(array, [index], value)
```
Adds #var("value") to item #var("index") and returns the new value.
Without #var("index") the item after the count is used.

=== ISUB <ext-array-isub>

#idx("ISUB")
```
ISUB(array, [index], value)
```
Subtracts #var("value") from item #var("index") and returns the new value.
Without #var("index") the item after the count is used.

```
i1 = icreate(10, 'NULL')
CALL iadd i1, 3, 5
SAY isub(i1, 3, 2)           /* 3 */
```

=== ICMP <ext-array-icmp>

#idx("ICMP")
```
ICMP(array1, index1, array2, index2)
```
Compares two items and returns #cmd("-1"), #cmd("0") or #cmd("1") when the
first is lower than, equal to or higher than the second.

=== ISEARCH <ext-array-isearch>

#idx("ISEARCH")
```
ISEARCH(array, value [, from])
```
Returns the index of the first item from #var("from") (default 1) up to the
count that equals #var("value"), or #cmd("0").

```
i1 = icreate(10, 'ELEMENT')
SAY isearch(i1, 7)           /* 7 */
```

=== ISEARCHNN <ext-array-isearchnn>

#idx("ISEARCHNN")
```
ISEARCHNN(array [, from])
```
Returns the index of the first item from #var("from") (default 1) up to the
count that is greater than 0, or #cmd("0").

=== ISORT <ext-array-isort>

#idx("ISORT")
```
ISORT(array [, order])
```
Sorts the items up to the count in place, in ascending order or, with
#cmd("DESCENDING") (first letter), in descending order.

#note[*A defect* (brexx370 issue 386): the value returned is the count
minus 1 (the highest index), and -1 for an empty array.]

```
CALL isort i1, 'D'
```

=== IAPPEND <ext-array-iappend>

#idx("IAPPEND")
```
IAPPEND(array1, array2)
```
Creates a new integer array with the items of #var("array1") followed by
those of #var("array2"), up to their counts, and returns its number, or
#cmd("-8") if 64 are in use.

=== IARRAY <ext-array-iarray>

#idx("IARRAY")
```
IARRAY(array [, option])
```
Returns the count of #var("array").

#deflist(width: 1.2in,
  [#cmd("ROWS")], [The number of rows: the size of an integer array, the
    rows of a matrix.],
  [#cmd("COLUMNS")], [The number of columns: 1 for an integer array. Only
    the first letter counts.],
)

=== ILIST <ext-array-ilist>

#idx("ILIST")
```
ILIST(array [, [from] [, [to] [, heading]]])
```
Prints items #var("from") (default 1) to #var("to") (default the last) of
an integer array, or rows of an integer matrix, under a heading.
#var("heading") replaces the word #cmd("Data"). Written in REXX and carried
in the load module.

```
CALL ilist i1, 1, 3
```

=== IFREE <ext-array-ifree>

#idx("IFREE")
```
IFREE(array)
```
Frees an integer array or integer matrix. Written in REXX and carried in
the load module; it calls #cmd("MFREE(")#var("array")#cmd(",'INDEX')").

=== IMCREATE <ext-array-imcreate>

#idx("IMCREATE")
```
IMCREATE(rows, columns)
```
Creates an integer matrix of #var("rows") × #var("columns") items, all 0,
and returns its number, or #cmd("-8") if 64 integer arrays are in use.

=== IMSET <ext-array-imset>

#idx("IMSET")
```
IMSET(matrix, row, column, value)
```
Sets an item to #var("value") and returns #var("value").

=== IMGET <ext-array-imget>

#idx("IMGET")
```
IMGET(matrix, row, column)
```
Returns an item.

=== IMADD <ext-array-imadd>

#idx("IMADD")
```
IMADD(matrix, row, column, value)
```
Adds #var("value") to an item and returns the new value.

=== IMSUB <ext-array-imsub>

#idx("IMSUB")
```
IMSUB(matrix, row, column, value)
```
Subtracts #var("value") from an item and returns the new value.

```
m1 = imcreate(3, 4)
CALL imset m1, 2, 3, 10
SAY imadd(m1, 2, 3, 5)       /* 15 */
SAY iarray(m1, 'C')          /* 4 */
```

=== IMINFIX <ext-array-iminfix>

#idx("IMINFIX")
```
IMINFIX(matrix, array, n [, option])
```
Copies the items of integer array #var("array"), up to its count, into row
#var("n") of #var("matrix") or, with #cmd("COLUMN"), into column
#var("n"). The array must fit the row or column. Returns #cmd("0").
Any option not beginning with #cmd("R") (#cmd("ROW"), the default) means
the column.

```
v1 = icreate(4, 'ELEMENT')
CALL iminfix m1, v1, 1       /* row 1 is 1 2 3 4 */
```

=== PRIME <ext-array-prime>

#idx("PRIME")
```
PRIME(n)
```
Returns the #var("n")th prime number.

```
SAY prime(1) prime(2) prime(10)   /* 2 3 29 */
```

== Bit Arrays <ext-array-bit>

#idx("bit array")
A bit array holds one bit per item and so needs one byte for eight items.
All its functions are requests of one function, #cmd("BITARRAY"). At most
64 bit arrays exist at a time; there is no request to free one.

=== BITARRAY <ext-array-bitarray>

#idx("BITARRAY")
```
BITARRAY('CREATE', size)
BITARRAY('SET', array, index [, value])
BITARRAY('GET', array, index)
BITARRAY('DUMP', array, index)
```

#deflist(width: 1.2in,
  [#cmd("CREATE")], [Creates a bit array of #var("size") items, all 0,
    and returns its number. When 64 are in use, the call ends in
    error 40.],
  [#cmd("SET")], [Sets item #var("index") to #var("value"): #cmd("0") or
    #cmd("1") (the default; any other value counts as 1). Use it with
    #cmd("CALL").],
  [#cmd("GET")], [Returns item #var("index"), #cmd("0") or #cmd("1").],
  [#cmd("DUMP")], [Prints the byte that holds item #var("index"), bit by
    bit. Returns #cmd("0").],
)

```
b1 = bitarray('CREATE', 10000)
CALL bitarray 'SET', b1, 17
SAY bitarray('GET', b1, 17)  /* 1 */
SAY bitarray('GET', b1, 18)  /* 0 */
```

== Float Arrays <ext-array-float>

#idx("float array")
A float array holds numbers with a fraction, as double-precision floating
point. It is a matrix of one column (@ext-array-matrix) and counts against
the 128 matrices. Its functions are built on the matrix functions.

=== FCREATE <ext-array-fcreate>

#idx("FCREATE")
```
FCREATE(size)
```
Creates a float array of #var("size") items and returns its number. It is
#cmd("MCREATE(")#var("size")#cmd(",1)"). Written in REXX and carried in
the load module.

=== FSET <ext-array-fset>

#idx("FSET")
```
FSET(array, index, value)
```
Sets item #var("index") to #var("value"). Returns #cmd("0"). Written in
REXX and carried in the load module.

=== FGET <ext-array-fget>

#idx("FGET")
```
FGET(array, index)
```
Returns item #var("index"). Written in REXX and carried in the load
module.

```
f1 = fcreate(100)
CALL fset f1, 1, 3.25
SAY fget(f1, 1)              /* e.g. 3.25 */
```

=== FARRAY <ext-array-farray>

#idx("FARRAY")
```
FARRAY(array)
```
Returns the highest index set with #cmd("FSET"). Sets the variables of
#cmd("MPROPERTY") as well. Written in REXX and carried in the load
module.

#note[*A defect* (brexx370 issue 386): the highest index is not reset
when a matrix number is freed and used again; a new float array may report the highest
index of the one before it until #cmd("FSET") goes beyond it.]

=== FLIST <ext-array-flist>

#idx("FLIST")
```
FLIST(array [, [from] [, [to] [, heading]]])
```
Prints items #var("from") (default 1) to #var("to") (default the highest
set) under a heading. #var("heading") replaces the word #cmd("Data").
Written in REXX and carried in the load module.

=== FFREE <ext-array-ffree>

#idx("FFREE")
```
FFREE(array)
```
Frees the float array. It is
#cmd("MFREE(")#var("array")#cmd(",'MATRIX')"). Written in REXX and
carried in the load module.

== Matrices <ext-array-matrix>

#idx("matrix")
A matrix holds numbers with a fraction, as double-precision floating point,
in #var("rows") × #var("columns") items. At most 128 matrices, float arrays
included, exist at a time. Except #cmd("MSET") and #cmd("MGET"), the
functions leave their input unchanged and return the number of a new
matrix. When the sizes of two matrices do not fit together, a function
prints a message and returns #cmd("8"); as 8 can also be a matrix number,
check the sizes before the call.

Some functions report results in variables whose names carry the matrix
number #var("m") and, for a column or row, its number #var("i"), as in
#cmd("_ROWMEAN.")#var("m")#cmd(".")#var("i"). What these call a variance is
the sample standard deviation of the column, the square root of
Σ(#var("x") − #var("mean"))² / (#var("n") − 1).

=== MCREATE <ext-array-mcreate>

#idx("MCREATE")
```
MCREATE(rows, columns [, name])
```
Creates a matrix and returns its number. #var("name") is shown only in
debugging output. When 128 are in use, or the matrix is too large, the call
ends in error 40.

```
m1 = mcreate(3, 3)
```

=== MSET <ext-array-mset>

#idx("MSET")
```
MSET(matrix, row, column, value)
```
Sets an item to #var("value"). Returns #cmd("0").

=== MGET <ext-array-mget>

#idx("MGET")
```
MGET(matrix, row, column)
```
Returns an item.

```
CALL mset m1, 1, 1, 2.5
SAY mget(m1, 1, 1)           /* e.g. 2.5 */
```

=== MCOPY <ext-array-mcopy>

#idx("MCOPY")
```
MCOPY(matrix)
```
Returns a copy of #var("matrix").

=== MTRANSPOSE <ext-array-mtranspose>

#idx("MTRANSPOSE")
```
MTRANSPOSE(matrix)
```
Returns the transposed matrix: a matrix of #var("r") × #var("c") becomes
one of #var("c") × #var("r").

=== MMULTIPLY <ext-array-mmultiply>

#idx("MMULTIPLY")
```
MMULTIPLY(matrix1, matrix2)
```
Returns the matrix product #var("matrix1") × #var("matrix2"). The number of
columns of #var("matrix1") must equal the number of rows of
#var("matrix2"); the product has the rows of #var("matrix1") and the
columns of #var("matrix2").

```
m3 = mmultiply(m1, m2)
```

=== MINVERT <ext-array-minvert>

#idx("MINVERT")
```
MINVERT(matrix)
```
Returns the inverse of a square matrix. A matrix that is not square
returns #cmd("8") with a message; a singular one ends in error 40.

#note[*A defect* (brexx370 issue 386): the inversion keeps its work
tables in 1000 entries on the stack and does not check the size; a
matrix of more than 999 rows overwrites storage. Do not invert one.]

=== MSCALAR <ext-array-mscalar>

#idx("MSCALAR")
```
MSCALAR(matrix, number)
```
Returns a matrix with every item multiplied by #var("number").

=== MADD <ext-array-madd>

#idx("MADD")
```
MADD(matrix1, matrix2)
```
Returns the sum of two matrices of the same size, item by item.

=== MSUBTRACT <ext-array-msubtract>

#idx("MSUBTRACT")
```
MSUBTRACT(matrix1, matrix2)
```
Returns #var("matrix1") minus #var("matrix2"), item by item. Both must have
the same size.

=== MPROD <ext-array-mprod>

#idx("MPROD")
```
MPROD(matrix1, matrix2)
```
Returns the product of two matrices of the same size, item by item.

=== MSQR <ext-array-msqr>

#idx("MSQR")
```
MSQR(matrix)
```
Returns a matrix with every item squared. For each row #var("i") of the new
matrix #var("n"), sets #cmd("_ROWSUM.")#var("n")#cmd(".")#var("i") (the sum
of the original items) and #cmd("_ROWSQR.")#var("n")#cmd(".")#var("i") (the
sum of their squares).

=== MINSCOL <ext-array-minscol>

#idx("MINSCOL")
```
MINSCOL(matrix, value)
```
Returns a matrix with a new first column whose items are all
#var("value"); the old columns follow.

=== MDELROW <ext-array-mdelrow>

#idx("MDELROW")
```
MDELROW(matrix, row [, row]...)
```
Returns a matrix without the rows given. Row numbers outside the matrix are
ignored.

=== MDELCOL <ext-array-mdelcol>

#idx("MDELCOL")
```
MDELCOL(matrix, column [, column]...)
```
Returns a matrix without the columns given. Column numbers outside the
matrix are ignored.

```
m2 = mdelcol(m1, 1, 3)
```

=== MNORMALISE <ext-array-mnormalise>

#idx("MNORMALISE")
```
MNORMALISE(matrix [, mode])
```
Returns a matrix with every column normalised. Only the first letter of
#var("mode") counts. For each column #var("j") of the new matrix #var("n"),
sets #cmd("_ROWMEAN.")#var("n")#cmd(".")#var("j"),
#cmd("_ROWVARIANCE.")#var("n")#cmd(".")#var("j") (both of the result) and
#cmd("_ROWFACTOR.")#var("n")#cmd(".")#var("j") (the divisor of mode
#cmd("L"), else 1).

#deflist(width: 1.2in,
  [#cmd("STANDARD")], [Each item minus the mean of its column, divided by
    the standard deviation: mean 0, deviation 1 (the default). A column
    whose deviation is 0 is left unchanged.],
  [#cmd("MEAN")], [Each item minus the mean of its column.],
  [#cmd("ROWS")], [Each item divided by the number of rows.],
  [#cmd("L")], [Each item divided by 10#super[#var("k")], where
    #var("k") is the integer part of the decimal logarithm of the absolute
    value of the highest item of its column.],
)

=== MPROPERTY <ext-array-mproperty>

#idx("MPROPERTY")
```
MPROPERTY(matrix [, option])
```
Sets variables that describe matrix #var("m"). Use it with #cmd("CALL").
Always set:

#deflist(width: 1.2in,
  [#cmd("_ROWS.")#var("m")], [Number of rows.],
  [#cmd("_COLS.")#var("m")], [Number of columns.],
  [#cmd("_MROWS.")#var("m")], [Highest row set with #cmd("MSET").],
)

With any #var("option"), such as #cmd("FULL"), these are set as well, for
each column #var("j") and each row #var("i"):

#deflist(width: 1.2in,
  [#cmd("_ROWMEAN.")#var("m")#cmd(".")#var("j")], [Mean of the column.],
  [#cmd("_ROWVARIANCE.")#var("m")#cmd(".")#var("j")], [Its standard
    deviation.],
  [#cmd("_ROWLOW.")#var("m")#cmd(".")#var("j")], [Lowest item.],
  [#cmd("_ROWHIGH.")#var("m")#cmd(".")#var("j")], [Highest item.],
  [#cmd("_ROWSUM.")#var("m")#cmd(".")#var("j")], [Sum of the column.],
  [#cmd("_ROWSQR.")#var("m")#cmd(".")#var("j")], [Square of that sum.],
  [#cmd("_COLSUM.")#var("m")#cmd(".")#var("i")], [Sum of the row.],
  [#cmd("_COLSQR.")#var("m")#cmd(".")#var("i")], [Square of that sum.],
)

```
CALL mproperty m1, 'FULL'
SAY _rows.m1 _cols.m1        /* e.g. 3 3 */
```

=== MUSED <ext-array-mused>

#idx("MUSED")
```
MUSED()
```
Prints a table of the matrices in use, with their rows, columns and storage
size, and the total. Use it with #cmd("CALL").

=== MFREE <ext-array-mfree>

#idx("MFREE")
```
MFREE([number, type])
```
Without arguments, frees all matrices, float arrays and integer arrays.
Otherwise frees one, as #var("type") says (first letter): #cmd("MATRIX")
for a matrix or float array, #cmd("INDEX") for an integer array or integer
matrix. An integer array that does not exist ends in error 40. Use it with
#cmd("CALL").

```
CALL mfree m1, 'MATRIX'
```

== Linked Lists <ext-array-ll>

#idx("linked list")
A linked list is a chain of entries, each linked to the entry before and
the entry after it, so that an entry can be inserted, removed or moved
without moving the others. At most 32 lists exist at a time; a list has a
name of up to 15 characters, which the listings show.

An entry is identified by its storage address. The functions return it as
a decimal number, or in hexadecimal after
#cmd("LLSET(")#var("list")#cmd(",'AMODE','HEX')"), and take it back in the
same form. An address that does not belong to a list entry ends in
error 40.

Each list has a _current entry_. Most functions work on it when no address
is given, and move it. #cmd("LLGET") sets the variable #cmd("LLCURRENT") to
the address of the current entry, or 0 when there is none.

=== LLCREATE <ext-array-llcreate>

#idx("LLCREATE")
```
LLCREATE([name])
```
Creates an empty list and returns its number. #var("name") is cut to 15
characters; without it the list is called #cmd("UNNAMED"). When 32 lists
are in use, the call ends in error 40.

```
ll1 = llcreate('SONGS')
```

=== LLADD <ext-array-lladd>

#idx("LLADD")
```
LLADD(list, string)
```
Adds an entry at the end of the list, makes it the current entry, and
returns its address.

```
CALL lladd ll1, 'one'
CALL lladd ll1, 'two'
CALL lladd ll1, 'three'
```

=== LLINSERT <ext-array-llinsert>

#idx("LLINSERT")
```
LLINSERT(list, string [, address])
```
Inserts an entry before the current entry, or before the entry at
#var("address"), makes it the current entry, and returns its address. In an
empty list it adds the first entry.

```
CALL llset ll1, 'POSITION', 2
CALL llinsert ll1, 'one and a half'
```

=== LLGET <ext-array-llget>

#idx("LLGET")
```
LLGET(list [, option | address])
```
Returns the current entry, or moves as #var("option") says and returns the
entry it arrives at. Without #var("option"), on a list positioned before
its first entry, returns the first entry. With #var("address"), moves to
that entry. Returns #cmd("$$EMPTY$$") when the list is empty or the move
went past its end. Sets #cmd("LLCURRENT").

#deflist(width: 1.2in,
  [#cmd("FIRST")], [The first entry. At least #cmd("FIR").],
  [#cmd("LAST")], [The last entry. At least #cmd("LA").],
  [#cmd("NEXT")], [The entry after the current one. At least #cmd("NE").],
  [#cmd("PREVIOUS")], [The entry before the current one. At least
    #cmd("PR").],
  [#cmd("LIFO")], [Returns the last entry and removes it from the list.],
  [#cmd("FIFO")], [Returns the first entry and removes it from the
    list.],
)

```
entry = llget(ll1, 'FIRST')
DO WHILE llcurrent <> 0
  SAY entry                  /* one, two, three */
  entry = llget(ll1, 'NEXT')
END
```

=== LLSET <ext-array-llset>

#idx("LLSET")
```
LLSET(list [, option [, value]])
```
Moves the current entry and returns its address. Returns #cmd("0") when
the move went past the first or the last entry, and #cmd("-8") when the
list is empty (#cmd("POSITION")) or has no current entry (#cmd("NEXT"),
#cmd("PREVIOUS")). Without #var("option"), moves to the next entry.

#deflist(width: 1.2in,
  [#cmd("FIRST")], [The first entry.],
  [#cmd("NEXT")], [The entry after the current one.],
  [#cmd("PREVIOUS")], [The entry before the current one.],
  [#cmd("LAST")], [The last entry.],
  [#cmd("CURRENT")], [No move; returns the current entry.],
  [#cmd("POSITION")], [Entry number #var("value"). A number beyond the
    last entry gives the last; 0 positions before the first entry.],
  [#cmd("ADDRESS")], [The entry at address #var("value").],
  [#cmd("AMODE")], [Not a move: with #var("value") #cmd("HEX"), addresses
    are returned and taken in hexadecimal from now on; with any other
    value, in decimal. Returns #cmd("1") for hexadecimal, #cmd("0") for
    decimal.],
)

For #cmd("POSITION"), #cmd("ADDRESS") and #cmd("AMODE") two letters are
enough; for the others, the first letter.

```
SAY llget(ll1, 'FIRST')
DO WHILE llset(ll1, 'NEXT') > 0
  SAY llget(ll1)
END
```

=== LLDEL <ext-array-lldel>

#idx("LLDEL")
```
LLDEL(list [, address])
```
Removes the current entry, or the entry at #var("address"), and frees it.
The entry after it becomes the current entry, or the one before it if it
was the last. Returns the address of the new current entry, or #cmd("-8")
if the list is empty.

```
CALL llset ll1, 'POSITION', 3
CALL lldel ll1
```

=== LLDELINK <ext-array-lldelink>

#idx("LLDELINK")
```
LLDELINK(list [, address])
```
Removes the current entry, or the entry at #var("address"), from the list
like #cmd("LLDEL"), but keeps it in storage as an orphan. Returns its
address, which #cmd("LLLINK") takes to link it in again, in the same or
another list. This moves an entry without copying its data.

=== LLLINK <ext-array-lllink>

#idx("LLLINK")
```
LLLINK(list, orphan [, address])
```
Links the orphan entry at address #var("orphan") into #var("list"), before
the current entry or before the entry at #var("address"), and makes it the
current entry. Returns its address. An #var("address") that is itself an
orphan ends in error 40.

```
adr = lldelink(ll1, llset(ll1, 'POSITION', 2))
CALL lllink ll2, adr
```

=== LLSEARCH <ext-array-llsearch>

#idx("LLSEARCH")
```
LLSEARCH(list, string [, address])
```
Returns the address of the first entry that contains #var("string"),
searching from the first entry or from the entry at #var("address"), which
then becomes the current entry. Returns #cmd("0") if no entry contains it.
The address is always decimal.

=== LLENTRY <ext-array-llentry>

#idx("LLENTRY")
```
LLENTRY(list)
```
Prints the current entry: its address, data, and the addresses of the
entries after and before it. Use it with #cmd("CALL").

=== LLLIST <ext-array-lllist>

#idx("LLLIST")
```
LLLIST(list [, [from] [, to]])
```
Prints entries #var("from") to #var("to") (default all) with their
addresses and links, followed by the address of the list, its count and its
current entry. Returns the number of entries in the list.

```
CALL lllist ll1
/*      Entries of Linked List: 0 (SONGS)          */
/* Entry Entry Address     Next    Previous  Data  */
/* ...                                             */
```

=== LLDETAILS <ext-array-lldetails>

#idx("LLDETAILS")
```
LLDETAILS(list [, option])
```
Returns a figure about the list; without #var("option"), the count. Only
the first letter counts.

#deflist(width: 1.2in,
  [#cmd("COUNT")], [The number of entries, as kept by the list.],
  [#cmd("ADDED")], [The number of entries added and inserted.],
  [#cmd("DELETED")], [The number of entries removed.],
  [#cmd("LIST")], [The number of entries, counted by walking the chain.
    It must equal #cmd("COUNT"); a difference means the list is
    damaged.],
  [#cmd("FULL")], [Prints all of these and the current entry. Use it
    with #cmd("CALL").],
)

=== LLCLEAR <ext-array-llclear>

#idx("LLCLEAR")
```
LLCLEAR(list)
```
Removes and frees all entries but keeps the list and its name. The
counters and the address form (#cmd("AMODE")) are reset. Returns
#cmd("0").

=== LLFREE <ext-array-llfree>

#idx("LLFREE")
```
LLFREE(list)
```
Frees the list and all its entries. Returns #cmd("0").

=== LLCOPY <ext-array-llcopy>

#idx("LLCOPY")
```
LLCOPY(list [, [from] [, [to] [, [target] [, name]]]])
```
Copies entries #var("from") to #var("to") (default all) to a new list, or
appends them to list #var("target"), and returns the number of the list
copied into. #var("name") names that list. A new list without
#var("name") is named after the number of #var("list").

#note[*A defect* (brexx370 issue 386): a #var("to") of 1 is taken as no
limit, as if it were omitted.]

```
ll3 = llcopy(ll1, , , ll2, 'Copied')
```

=== LLSORT <ext-array-llsort>

#idx("LLSORT")
```
LLSORT(list [, [order] [, offset]])
```
Sorts the list with the arguments of #cmd("SQSORT") and returns its
number. The entries are copied into a string array, sorted and copied
back, so every entry gets a new address and the counters are reset.
Written in REXX and carried in the load module.

```
CALL llsort ll1, 'A', 31
```

=== LLREAD <ext-array-llread>

#idx("LLREAD")
```
LLREAD(dataset)
```
Reads a data set into a new list, as #cmd("SREAD") reads it into a string
array, and returns the number of the list. Written in REXX and carried in
the load module.

```
ll1 = llread("'USER.SONGS'")
```

=== LLWRITE <ext-array-llwrite>

#idx("LLWRITE")
```
LLWRITE(list, dataset)
```
Writes all entries to a data set, as #cmd("SWRITE") does, and returns the
number of records written. Written in REXX and carried in the load module.

=== LIFO <ext-array-lifo>

#idx("LIFO")
```
LIFO('CREATE' [, name])
LIFO('PUSH', list, string)
LIFO('PULL', list)
```
Uses a linked list as a stack. #cmd("CREATE") is #cmd("LLCREATE"),
#cmd("PUSH") is #cmd("LLADD"), and #cmd("PULL") is
#cmd("LLGET(")#var("list")#cmd(",'LIFO')"): it returns the entry pushed
last and removes it, or #cmd("$$EMPTY$$"). Any other request ends in
error 40. Written in REXX and carried in the load module.

```
q = lifo('CREATE')
CALL lifo 'PUSH', q, 'a'
CALL lifo 'PUSH', q, 'b'
SAY lifo('PULL', q)          /* b */
```

=== FIFO <ext-array-fifo>

#idx("FIFO")
```
FIFO('CREATE' [, name])
FIFO('PUSH', list, string)
FIFO('PULL', list)
```
Uses a linked list as a queue, like #cmd("LIFO"), but #cmd("PULL")
returns the entry pushed first. Written in REXX and carried in the load
module.

```
q = fifo('CREATE')
CALL fifo 'PUSH', q, 'a'
CALL fifo 'PUSH', q, 'b'
SAY fifo('PULL', q)          /* a */
```

== Conversions <ext-array-conv>

#idx("stem")
These functions copy between stems, string arrays, linked lists and the
numeric arrays. The source does not change. A stem name is given with its
period, as in #cmd("'MYSTEM.'"); #var("stem")#cmd("0") holds the number of
entries.

=== STEM2S <ext-array-stem2s>

#idx("STEM2S")
```
STEM2S(stem)
```
Copies #var("stem")#cmd("1") to #var("stem")#var("n"), #var("n") being
#var("stem")#cmd("0"), into a new string array and returns its number.
#var("stem")#cmd("0") must be at least 1. Empty and blank entries are left
out. Written in REXX and carried in the
load module.

```
fred.1 = 'a'; fred.2 = 'b'; fred.0 = 2
s1 = stem2s('fred.')
SAY sarray(s1)               /* 2 */
```

=== S2STEM <ext-array-s2stem>

#idx("S2STEM")
```
S2STEM(array, stem)
```
Copies all entries of #var("array") into #var("stem")#cmd("1") and
following, sets #var("stem")#cmd("0"), and returns the count. Written in
REXX and carried in the load module.

```
CALL s2stem s1, 'rec.'
SAY rec.0
```

=== STEM2LL <ext-array-stem2ll>

#idx("STEM2LL")
```
STEM2LL(stem)
```
Copies #var("stem")#cmd("1") to #var("stem")#var("n") into a new linked
list and returns its number. Written in REXX and carried in the load
module.

=== LL2STEM <ext-array-ll2stem>

#idx("LL2STEM")
```
LL2STEM(list, stem)
```
Copies all entries of #var("list") into #var("stem")#cmd("1") and
following and sets #var("stem")#cmd("0"). Read the count from
#var("stem")#cmd("0"). Written in REXX and carried in the load module.

#note[*A defect* (brexx370 issue 386): the value returned is the
string #cmd("__#STEM0"), not the count. *To be confirmed:* the result for an empty list.]

```
CALL ll2stem ll1, 'mystem.'
SAY mystem.0                 /* 3 */
```

=== S2LL <ext-array-s2ll>

#idx("S2LL")
```
S2LL(array [, [from] [, [to] [, [list] [, name]]]])
```
Copies entries #var("from") (default 1) to #var("to") (default the count)
of a string array to a new linked list, or appends them to #var("list"),
and returns the number of the list. #var("name") names the list. A new
list without #var("name") is named after the number of #var("array").

```
ll2 = s2ll(s1, , , , 'LL Songs')
```

=== LL2S <ext-array-ll2s>

#idx("LL2S")
```
LL2S(list [, [from] [, [to] [, array]]])
```
Copies the entries of a linked list to a new string array, or appends them
to #var("array"), and returns the number of the string array.

#note[*A defect* (brexx370 issue 386): #var("from") and #var("to") are
compared with the index in the string array, not with the position in the list, and a
#var("from") greater than the count of that array copies nothing. Copy the
whole list.]

```
s1 = ll2s(ll1)
```

=== S2IARRAY <ext-array-s2iarray>

#idx("S2IARRAY")
```
S2IARRAY(array)
```
Creates an integer array with the whole number at the start of each entry,
or 0 where an entry does not start with one, and returns its number, or
#cmd("-8") if 64 integer arrays are in use.

=== S2FARRAY <ext-array-s2farray>

#idx("S2FARRAY")
```
S2FARRAY(array)
```
Creates a float array with the entries of a string array as numbers and
returns its number. Written in REXX and carried in the load module.

=== I2S <ext-array-i2s>

#idx("I2S")
```
I2S(array)
```
Creates a string array with the items of an integer array, up to its
count, and returns its number.

```
i1 = icreate(3, 'DESCENT')
s1 = i2s(i1)
SAY sget(s1, 1)              /* 3 */
```

=== S2HASH <ext-array-s2hash>

#idx("S2HASH")
```
S2HASH(array)
```
Creates an integer array with a 32-bit hash value (FNV-1a) of each entry,
leading and trailing blanks removed, and returns its number, or #cmd("-8")
if 64 integer arrays are in use. Equal entries get equal values, so
integer comparisons can replace string comparisons; different entries may
also get equal values.

```
i1 = s2hash(s1)
```

=== SSPLIT <ext-array-ssplit>

#idx("SSPLIT")
```
SSPLIT(string [, delimiters])
```
Splits #var("string") into parts at each of the characters in
#var("delimiters") (default a blank) and returns a new string array with
the parts. Delimiters that follow each other separate nothing, and blank
parts are left out. Written in REXX and carried in the load module.

```
s1 = ssplit('a;b;;c', ';')
SAY sarray(s1)               /* 3 */
buf = 'line 1' || '15'x || 'line 2'
s2 = ssplit(buf, '15'x)      /* 2 entries */
```

=== STEMLIST <ext-array-stemlist>

#idx("STEMLIST")
```
STEMLIST(stem [, [from] [, [to] [, heading]]])
```
Prints #var("stem")#var("from") (default 1) to #var("stem")#var("to")
(default #var("stem")#cmd("0")) under a heading, as #cmd("SLIST") prints
an array. The period may be left out. Written in REXX and carried in the
load module.

```
CALL stemlist 'rec.', 1, 10
```
