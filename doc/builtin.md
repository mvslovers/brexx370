# Built-in Functions

> The following are the built-in REXX functions. Which are divided into the following categories:
- Rexx
- String
- Word
- Math
- Data Convert
- File Functions

## Rexx Functions

### ADDR(symbol[,[option][,pool]])

returns the physical address of symbol contents. Option can be
‘Data’ (default) variables data ‘Lstring’ lstring structure pointer
‘Variable’ variable structure.

If pool exist, the specific rexx pool is searched for the symbol.
Valid pools are numbers from 0 up to current procedure nesting.
(The result is normalized for MSDOS, ie seg:ofs = seg\*16+ofs)

```rexx
 i = 5
 SAY addr('i')           /* something like 432009 decimal */
 SAY addr('i','L')       /* something like 433000 */
 SAY addr('i','V')       /* something like 403004 */
 SAY addr('i','V',0)     /* something like 403004 */
 SAY addr('j')           /* -1, is J variable doesn't exist */
```

### ADDRESS()

return the current environment for commands.

```rexx
 SAY address() /* would display: SYSTEM */
```

### ARG()

- ARG() returns the number of arguments
- ARG(n) return then nth argument
- ARG(n,option) option may be **Exist** or **Omitted** (only the
  first letter is significant) test whether the nth argument
  Exists or is Omitted.

Returns “0” or “1”

```rexx
 call myproc 'a',,2
 ...
 myproc:
 SAY arg()               /* 3 */
 SAY arg(1)              /* 'a' */
 SAY arg(2,'O')          /* 1 */
 SAY arg(2,'E')          /* 0 */
```

### DATATYPE(string)

DATATYPE(string) - returns “NUM” is string is a valid REXX number,
otherwise returns “CHAR”. DATATYPE(string,type) - returns “0” or “1”
if string is of the specific type:

- Alphanumeric:     characters A-Z, a-z and 0-9
- Binary:   a valid BINARY number
- Lowercase:        characters a-z
- Mixed:    characters A-Z, a-z
- Number:   is a valid REXX number
- Symbol:           characters A-Z, a-z, 0-9, @%_.!#
- Uppercase:        characters A-Z
- Whole-number:     a valid REXX whole number
- X (heXadecimal):  a valid HEX number

(only the first letter of type is required)

The special type ‘Type’ returns the either INT, REAL, or STRING the
way the variable is hold into memory. Usefull when you combine that
with INTR function.

```rexx
 SAY datatype('123')             /* NUM */
 SAY datatype('21a')             /* CHAR */
 SAY datatype(01001,'B')         /* 1 */
 SAY datatype(i,'T')             /* maybe STRING */
```

### DATE()

return current date in the format: dd Mmm yyyy

```rexx
 SAY date() /* 14 Feb 1993 */
```

or formats the output according to option

- Days              returns number of days since 1-Jan as an integer
- European          returns date in format dd/mm/yy
- Month             returns the name of current month, ie. March
- Normal            returns the date in the default format dd Mmm yyyy
- Ordered           returns the date in the format yy/mm/dd
- (useful for sorting)
- Sorted            returns the date in the format yyyymmdd
- (suitable for sorting)
- USA               returns the date in the format mm/dd/yy
- Weekday           returns the name of current day of week ie. Monday

### DESBUF()

destroys the all system stacks, and returns the number of lines in
system stacks.

```rexx
 PUSH 'hello'            /* now stack has one item */
 CALL desbuf             /* stack is empty, and RESULT=1 */
```

### DROPBUF()

destroys num top stacks, and returns the number of lines destroyed.

```rexx
 PUSH 'in stack1'                /* first stack has one item */
 CALL makebuf            /* create a new buffer */
 PUSH 'in stack2'                /* new stack has one item */
 CALL dropbuf            /* one stack remains */
```

### DIGITS()

returns the current setting of NUMERIC DIGITS.

### ERRORTEXT(n)

returns the error message for error number n.

```rexx
 SAY errortext(8)        /* "Unexpected THEN or ELSE" */
```

### FORM()

returns the current setting of NUMERIC FORM.

### FUZZ()

returns the current setting of NUMERIC FUZZ.

### GETENV(varname)

returns the environment variable varname

```rexx
 SAY getenv("PATH")
```

### HASHVALUE(string)

return an integer hashvalue of the string like Java
hash = s[0]\*31^(n-1) + s[1]\*31^(n-2) + … + s[n-1]

```rexx
 SAY hashvalue("monday")         /* -1068502768 */
```

### IMPORT(file)

import a shared library file using dynamic linking with rexx
routines. If it fails, then try to load a rexx file so it can be
used as a library. import first searches the current directory, if
not found it searches the directories pointed by the environment
variable RXLIB.

returns

- “-1” if already imported
- “0” on success
- “1” on error opening the file

```rexx
 CALL IMPORT FSSAPI
 call import "veclib"
```

### MAKEBUF()

create a new system stack, and returns the number of system stacks
created until now (plus the initial one).

```default
 PUSH 'hello'; SAY queued() queued(T)            /* display 1 1 */
 CALL makebuf            /* create a new buffer */
 PUSH 'aloha; SAY queued() queued(T)             /* display again 2 1 */
```

### QUEUED()

return the number of lines in the rexx stack (all stacks or the
topmost) or the number of stacks. Option can be (only first letter
is significant):

- All               lines in All stacks (default)
- Buffers           number of buffers created with MAKEBUF
- Topstack  lines in top most stack

```rexx
 PUSH 'hi'
 SAY queued(A) queued(B) queued(T)               /* 1 1 1 */
 CALL makebuf
 SAY queued(A) queued(B) queued(T)               /* 1 2 0 */
 PUSH 'hello'
 SAY queued(A) queued(B) queued(T)               /* 2 2 1 */
 CALL desbuf
 SAY queued(A) queued(B) queued(T)               /* 0 1 0 */
```

### SOUNDEX(word)

return a 4 character soundex code of word in the format “ANNN”
(used for phonetic comparison of words)

```rexx
 SAY soundex("monday")           /* M530 */
 SAY soundex("Mandei")           /* M530 */
```

### SOURCELINE()

return the number of lines in the program, or the nth line.

```rexx
 SAY sourceline()        /* maybe 100 */
 SAY sourceline(1)       /* maybe "/**/" */
```

### STORAGE([address[,[length][,data]]])

returns the current free memory size expressed as a decimal string
if no arguments are specified. Otherwise, returns length bytes from
the user’s memory starting at address. The length is in decimal; the
default value is 1 byte. The address is a decimal number (Normalized
address for MSDOS ie. seg:ofs = seg\*16+ofs) If data is specified,
after the “old” value has been retrieved, storage starting at
address is overwritten with data (the length argument has no effect
on this).

```rexx
 SAY storage()           /* maybe 31287 */
 SAY storage(1000,3)             /* maybe "MZa" */
 a = "Hello"
 SAY storage(addr('a'),5,'aaa')  /* "Hello" */
 SAY a           /* aaalo */
```

### SYMBOL(name)

return “BAD” if name is not a valid REXX variable name, “VAR” if name has been used as a variable, or “LIT” if it has not.

```rexx
 i = 5
 SAY symbol('i')         /* VAR */
 SAY symbol(i)           /* LIT */
 SAY symbol(':asd')              /* BAD */
```

### TIME()

return the local time in the format: hh:mm:ss if option is
specified time is formated as:

- Civil             returns time in format hh:mmxx ie. 10:32am
- Elapsed           returns elapsed time since rexx timer was reset
  or from begging of program in format ssssss.uuuuuu
- Hours             returns number of hours since midnight
- Long              returns time and milliseconds hh:mm:ss.uu
- Minutes           returns number of minutes since midnight
- Normal            returns time in format hh:mm:ss
- Reset             returns elapsed time in format ssssss.uuuuuu (like
  Elapsed) and resets rexx internal timer.
- Seconds           returns number of seconds since midnight

### TRACE()

returns current tracing option. If option is specified then sets to new tracing option. Look up instruction TRACE.

```rexx
 SAY trace() /* normally 'N' */
```

### VALUE(name[,[newvalue][,pool]])

returns the value of the variable name. If newvalue is specified
then after the retrieval of the old value the newvalue will be set
to the variable. If pool is specified then the operation takes place
at the specific pool. Pool initially exist in this version of Rexx
are:

- 0 up to the current PROCEDURE nesting specifing the pool of each
  PROCEDURE
- Negative values from -1 to minus current PROCEDURE nesting, shows
  relative values from current procedure.
- SYSTEM is the system pool (like GETENV,PUTENV)
- User can create his own POOLs, Look Programing Rexx

```rexx
 i = 5
 j = "i"
 SAY value(j)            /* 5 */
 SAY value('j',10)               /* 'i' */
 SAY j           /* 10 */
 CALL Procedure
 ...
 Procedure: PROCEDURE
 i = "I-var"
 SAY value('i')          /* I-var */
 SAY value('i',,0)               /* 5 */
 SAY value('i',,1)               /* I-var */
 SAY value('i',,-1)              /* 5 */
 ...
```

### VARDUMP([symbol][,option])

returns the binary tree of the variables in the format

```rexx
 var = "value" \n
```

option can be “Depth” which prints out the binary tree in the format

```rexx
 depth var = "value" \n (used for balancing of variables )
```

symbol may be nothing for main bin-tree or a stem for an array bin-tree ie. “B.”

VARDUMP is an easy way to store the variables in a file or in stack and restores them later.

```rexx
 CALL write "vars.$$$", vardump() /* stores all variables */ /* in the file "vars.$$$" */
```

on a later run you can do

```rexx
 DO UNTIL eof("vars.$$$")                /* this will read all variables */
         INTERPRET read("vars.$$$")              /* from file, and restore them */
 END
```

#### WARNING
VARDUMP is not fully implemented and may not work when
variables have non-printable characters.

## String Functions

### ABBREV(information, info)

tests whether info is an abbreviation of information. returns “1”
on true, else returns “0”. If length is specified then searching
takes place only for the first length characters.

```rexx
 abbrev("billy","bill")          /* 1 */
 abbrev("billy","bila")          /* 0 */
 abbrev("billy","bila",3)        /* 1 */
```

### CENTRE(string, length)

returns string centered in a padded string of length length.

```rexx
 center("rexx",2)                /* 'ex' */
 center("rexx",8)                /* ' rexx ' */
 center("rexx",8,'-')            /* '--rexx--' */
```

### CHANGESTR(target, string, replace)

replaces all occurrences of the target in string, replacing them
with the replace.

```rexx
 changestr("aa","aabbccaabbccaa","--")   /* --bbcc--bbcc-- */
```

### COMPARE(string1, string2)

returns “0” if string1==string2, else it returns the index of the
first nonmatching character. Shorter string is padded with pad if
necessary

```rexx
 compare('bill','bill')          /* 0 */
 compare('bill','big')           /* 3 */
 compare('bi ','bi')             /* 0 */
 compare('bi--*','bi','-')       /* 5 */
```

### COUNTSTR(target, string)

counts all the appearances of target in string

```rexx
 countstr("aa","aabbccaabbccaa")         /* 3 */
```

### COPIES(string, n)

returns n concatenated copies of string.

```rexx
 copies('Vivi',3)        /* 'ViviViviVivi' */
```

### DELSTR(string, n)

delete substring of string starting at the nth character and of
length length.

```rexx
 delstr('bill',3)                /* 'bi' */
 delstr('bill',2,2)              /* 'bl' */
```

### INDEX(haystack, needle)

return the position of needle in haystack, beginning at start.

```rexx
 index('bilil','il')             /* 2 */
 index('bilil','il',3)           /* 4 */
```

### INSERT(new,target[,[n][,[length][,pad]]])

insert the string new of length length into the string target, after
the nth character (n can be 0)

```rexx
 insert('.','BNV',2)             /* 'BN.V' */
 insert('.','BNV',2,2)           /* 'BN. V' */
 insert('','BNV',2,2,'.')        /* 'BN..V' */
```

### LASTPOS(needle, haystack)

return the position of the last occurrence of needle in haystack, beginning at start.

```rexx
 lastpos('il','bilil')           /* 4 */
 lastpos('il','bilil',4)         /* 2 */
```

### LEFT(string, length)

return a string of length length with string left justified in it.

```rexx
 left('Hello',2)         /* 'He' */
 left('Hello,10,'.')             /* 'Hello.....' */
```

### LENGTH(string)

return the length of string

```rexx
 length('Hello')         /* 5 */
```

### OVERLAY(new,target[,[n][,[length][,pad]]])

overlay the string new of length length onto string target,
beginning at the nth character.

```rexx
 overlay('.','abcd',2)           /* 'a.cd' */
 overlay('.','abcd')             /* '.bcd' */
 overlay('.','abcd',6,3,'+')             /* 'abcd+.++' */
```

### POS(needle, haystack)

return the position of needle in haystack, beginning at start.

```rexx
 pos('ll','Bill')                /* 3 */
```

### REVERSE(string)

swap string, end-to-end.

```rexx
 reverse('Bill')         /* 'lliB' */
```

### RIGHT(string, length)

returns length righmost characters of string.

```rexx
 right('abcde',2)                /* 'de' */
```

### SUBSTR(string,n[,[length][,pad]])

return the substring of string that begins at the nth character
and is of length length. Default pad is space.

```rexx
 substr('abcde',2,2)             /* 'bc' */
 substr('abcde',2)               /* 'bcde' */
 substr('abcde',4,3,'-')         /* 'de-' */
```

### STRIP(string[,[<"L"|"T"|"B">][,char]])

```rexx
```

returns string stripped of Leading, Trailing, or Both sets of
blanks or other chars. Default is “B”.

```rexx
 strip(' abc ')          /* 'abc' */
 strip(' abc ','t')              /* ' abc' */
 strip('-abc--',,'-')            /* 'abc' */
```

### TRANSLATE(string[,[tableo][,[tablei][,pad]]])

translate characters in tablei to associated characters in tableo.
If neither table is specified, convert to uppercase.

```rexx
 translate('abc')                /* 'ABC' */
 translate('aabc','-','a')               /* '--bc' */
 translate('aabc','-+','ab')             /* '--+c' */
```

### VERIFY(string,reference[,[option][,start]])

return the index of the first character in string that is not also
in reference. if “Match” is given, then return the result index of
the first character in string that is in reference.

```rexx
 verify('abc','abcdef')          /* 0 */
 verify('a0c','abcdef')          /* 2 */
 verify('12a','abcdef','m')              /* 3 */
```

### XRANGE([start][,end])

return all characters in the range start through end.

```rexx
 xrange('a','e')         /* 'abcde' */
 xrange('fe'x,'02'x)             /* 'feff000102'x */
```

## Word Functions

### DELWORD(string, n)

delete substring of string starting at the nth word and of length
length words.

```rexx
 delword('one day in the year',3)                /* 'one day' */
 delword('one day in the year',3,2)              /* 'one day year' */
```

### FIND(string, phrase)

returns the word number of the first word of phrase in string.
Returns “0” if phrase is not found. if start exists then search start from start word.

```rexx
 find('one day in the year','in the')    /* 3 */
```

### JUSTIFY(string, length)

justify string to both margins (the width of margins equals length),
by adding pads between words.

```rexx
 justify('one day in the year',22)       /*'one day in the year'
```

### SUBWORD(string, n)

return the substring of string that begins at the nth word and
is of length length words.

```rexx
 subword('one day in the year',2,2)      /* 'day in' */
```

### SPACE(string[,[n][,pad]])

formats the blank-delimited words in string with n pad characters
between each word.

```rexx
 space('one day in the year',2)  /*'one day in the year' */
```

### WORDS(string)

return the number of words in string

```rexx
 words('One day in the year')            /* 5 */
```

### WORD(string, n)

return the nth word in string

```rexx
 word('one day in the year',2)           /* 'day' */
```

### WORDINDEX(string, n)

return the position of the nth word in string

```rexx
 wordindex('one day in the year',2)      /* 5 */
```

### WORDLENGTH(string, i)

return the length of the nth word in string

```rexx
 wordlength('one day in the year',2)     /* 3 */
```

### WORDPOS(phrase, string)

returns the word number of the first word of phrase in string.
Returns “0” if phrase is not found

```rexx
 wordpos('day in','one day in the year')         /* 2 */
```

## Math Functions

### ABS(number)

return absolute value of number

```rexx
 abs(-2.3) /* 2.3 */
```

### FORMAT(number[,[before][,[after][,[expp][,expt]]]])

rounds and formats number with before integer digits and after
decimal places. expp accepts the values 1 or 2 (WARNING Totally
differen’t from the Ansi-REXX spec) where 1 means to use the “G”
(General) format of C, and 2 the “E” exponential format of C.
Where the place of the totalwidth specifier in C is replaced by
before+after+1. ( expt is ignored! )

```rexx
 format(2.66)            /* 3 */
 format(2.66,1,1)                /* 2.7 */
 format(26.6,1,1,1)              /* 3.E+01 */
 format(26.6,1,1,2)              /* 2.7E+01 */
```

### IAND(n, m)

return bitwise AND of the integers n and m

```rexx
 iand(2,3) /* 2 */
```

### INOT(n)

return bitwise complement of integers n

```rexx
 inot(2) /* -3 */
```

### IOR(n, m)

return bitwise OR of the integers n and m

```rexx
 ior(2,3) /* 3 */
```

### IXOR(n, m)

return bitwise XOR of the integers n and m

```rexx
 ixor(2,3) /* 1 */
```

### MAX(number)

returns the largest of given numbers.

```rexx
 max(2,3,1,5) /* 5 */
```

### MIN(number)

returns the smallest of given numbers.

```rexx
 min(2,3,1,5) /* 1 */
```

### RANDOM([min][,[max][,seed]])

returns a pseudorandom nonnegative whole number in the range min to max inclusive.

### SIGN(number)

return the sign of number (“-1”,”0” or “1”).

```rexx
 sign(-5.2)              /* -1 */
 sign( 0.0)              /* 0 */
 sign( 5.2)              /* 1 */
```

### TRUNC(number)

returns the integer part of number, and n decimal places. The default n is zero.

```rexx
 trunc(2.6) /* 2 */
```

### ACOS(num)

Arc-cosine

### ASIN(num)

Arc-sine

### ATAN(num)

Arc-tangent

### COS(num)

Cosine

### COSH(num)

Hyperbolic cosine

### EXP(num)

Exponiate

### LOG(num)

Natural logarithm

### LOG10(num)

Logarithm of base 10

### POW10(num)

Power with base 10

### SIN(num)

Sine function

### SINH(num)

Hyperbolic sine

### SQRT(num)

Square root

### TAN(num)

Tangent

### TANH(num)

Hyperbolic tangent

### POW(a, b)

Raises a to power b

## Data Convert Functions

### B2X(string)

Binary to Hexadecimal

```rexx
 b2x('01100001')         /* 'a' */
```

### BITAND(string1[,[string2][,pad]])

logically AND the strings, bit by bit

```rexx
 bitand('61'x,'52'x)             /* '40'x */
 bitand('6162'x,'5253'x)         /* '4042'x */
 bitand('6162'x,,'FE'x)          /* '6062'x */
```

### BITOR(string1[,[string2][,pad]])

logically OR the strings, bit by bit

### BITXOR(string1[,[string2][,pad]])

logically XOR the strings, bit by bit

### C2D(string)

Character to Decimal. The binary representation of string is
converted to a number (unsigned unless the length n is specified).

```rexx
 c2d('09'x)              /* 9 */
 c2d('ff40')             /* 65344 */
 c2d('81'x,1)            /* -127 */
 c2d('81'x,2)            /* 129 */
```

### C2X(string)

Character to Hexadecimal

```rexx
 c2x('abc')              /* '616263' */
 c2x('0506'x)            /* '0506' */
```

### D2C(wholenumber)

Decimal to Character. Return a string of length n, which is the
binary representation of the number.

```rexx
 d2c(5)          /* '5'x */
 d2c(97)         /* 'a' */
```

### D2X(wholenumber)

Decimal to Hexadecimal. Return a string of length n, which is the
hexadecimal representation of the number.

```rexx
 d2x(5)          /* '05' */
 d2x(97)         /* '61' */
```

### B2X(string)

Hexadecimal to Binary

```rexx
 x2b('a')                /* '01100001' */
```

### X2C(string)

Hexadecimal to Character

```rexx
 x2c('616263')           /* 'abc' */
```

### X2D(hex-string)

Hexadecimal to Decimal. hex-string is converted to a number
(unsigned unless the length n is specified)

```rexx
 x2d('61')               /* 97 */
```

## File Functions

**General**

There are two sets of I/O functions, the REXX-STEAM functions and the BREXX I/O routines.

Files can be referenced as a string containing the name of the file ie
“TEST.DAT” or the file handle that is returned from OPEN function.
(Normally the second way if prefered when you want to open 2 or more
files with the same name).

There are always 3 special files:

|   Handle | FileName   | Description     |
|----------|------------|-----------------|
|        0 | <STDIN>    | Standard input  |
|        1 | <STDOUT>   | Standard output |
|        2 | <STDERR>   | Standard error  |

All open files are closed at the end of the program from REXX
interpreter except in the case of an error.

### CHARIN([stream[,[start][,[length]]]])

reads length bytes (default=1) from stream (default=”<STDIN>”)
starting at position start

```rexx
 ch = charin("new.dat")          /* read one byte */
 ch = charin("new.dat",3,2)      /* read two bytes from position in file 3 */
```

### CHAROUT([stream[,[string][,[start]]]])

write string to stream (default=”<STDOUT>”) starting at
position start

```rexx
 CALL charout "new.dat","hello"  /* writes "hello" to file */
 CALL charout "new.dat","hi",2)  /* writes "hi" at position 2 */
```

### CHARS()

returns the number of characters remaining in stream.

```rexx
 CHARS("new.dat")        /* maybe 100 */
```

### CLOSE(file)

closes an opened file. file may be string or the handle number

```rexx
 CALL close 'new.dat'    /* these two cmds are exactly the same */
 CALL close hnd  /* where hnd=open('new.dat','w') */
```

### EOF(file)

returns 1 at eof, -1 when file is not opened, 0 otherwise

```rexx
 DO      UNTIL eof(hnd)=1
         SAY read(hnd)   /* type file */
 END
```

### FLUSH(file)

flush file stream to disk

```rexx
 CALL flush 'new.dat'
```

### LINEIN([stream[,[start][,[lines]]]])

reads lines lines (default=1) from stream (default=”<STDIN>”) starting at line position start

```rexx
 line = linein("new.dat")                /* read one line */
 line = linein("new.dat",3,2)    /* read two lines from new.dat starting at line 3 */
```

### LINEOUT([stream[,[string][,[start]]]])

write string with newline appended at the end to stream
(default=”<STDOUT>”) starting at line position start

```rexx
 CALL lineout "new.dat","hello"  /* writes line "hello" to file */
 CALL lineout "new.dat","hi",2)  /* writes line "hi" at line position 2 */
```

### LINES()

returns the number of lines remaining in stream. start

```rexx
 LINES("new.dat")        /* maybe 10 */
```

### OPEN(file, mode)

opens a file. mode follows C prototypes:

| “r”   | for read   | “w”   | for write      |
|-------|------------|-------|----------------|
| “t”   | for text,  | “b”   | for binary     |
| “a”   | for append | “+”   | for read/write |

and returns the handle number for that file. -1 if file is not
found!

```rexx
 hnd     = open('new.dat','w')
 IF      hnd = -1 THEN DO
         SAY 'Error: opening file "new.dat".'
         ...
 END
 irda = open('com3:115200,8,N,1,128','rw')
```

### READ([file][,<length | "Char" | "Line" | "File">])

reads one line from file. If the second argument exists and it is a
number it reads length bytes from file otherwise reads a Char, Line
or the entire File. If file is not opened, it will be opened
automatically in “r” mode. If file is ommited, it is assumed to
be <STDIN>

```rexx
 kbdin = READ()  /* reads one line from stdin */
 keypressed = read(,1)   /* -//- char -//- */
 linein = read('new.dat')        /* reads one line from file */
 linein = read(hnd)      /* -//- */
 ch = read('new.dat',"C")        /* if file 'data' is not opened
         then it will be opened in "r" mode */
 CALL write "new",read("old","F")        /* copy file */
```

### SEEK(file)

move file pointer to offset relative from TOF Top Of File (default),
CUR Current position, EOF End Of File and return new file pointer.
This is an easy way to determine the filesize, by seeking at the
end,

```rexx
 filesize = seek(file,0,"EOF")   /* return file size */
 CALL seek 'data',0,"TOF"        /* sets the pointer to the start of the file */
 filepos = seek('data',-5,"CUR")         /* moves pointer 5 bytes backwards */
```

### STREAM(stream[,[option][,command]])

STREAM returns a description of the state, or the result of an
operation upon the stream named by the first argument.

option can be “Command”, “Description”, “Status”

When option is “Command” the third argument must exist and can take
on of the following values:

| Command      | Description                                     |
|--------------|-------------------------------------------------|
| READ         | open in read-only mode ASCII                    |
| READBINARY   | open in read-only mode BINARY                   |
| WRITE        | open in write-only mode ASCII                   |
| WRITEBINARY  | open in write-only mode BINARY                  |
| APPEND       | open in read/write-append mode ASCII            |
| APPENDBINARY | open in read/write-append mode BINARY           |
| UPDATE       | open in read/write mode (file must exist) ASCII |
| UPDATEBINARY | open in read/write mode BINARY                  |

When option is “Status”, STREAM returns the current status of the
stream can be on of the followings: “READY”, “ERROR”, “UNKNOWN”

When option is “Description”, STREAM returns a description of the
last error.

```rexx
 CALL stream "new.dat","C","WRITE"
 CALL stream "new.dat","C","CLOSE"
 CALL stream "new.dat","S"
```

### WRITE([file][, string[,newline]])

writes the string to file. returns the number of bytes written. If
string doesn’t exist WRITE will write a newline to file. If a third
argument exists a newline will be added at the end of the string. If
file is not opened, it will be opened automatically with “w” mode.
If file is ommited, it is assumed to be <STDOUT>

```rexx
 CALL write 'data','First line',nl
 CALL write ,'a'         /* writes 'a' to stdout */
 CALL write '','one line',nl     /* write 'one line' to stdout */
 CALL write 'output.dat','blah blah'     /* writes 'blah blah' to 'output.dat' file*/
```
