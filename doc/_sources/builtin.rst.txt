Built-in Functions
==================

 The following are the built-in REXX functions. Which are divided into the following categories:

- Rexx
- String
- Word
- Math
- Data Convert
- File Functions


Rexx Functions
--------------

.. function:: ADDR(symbol[,[option][,pool]])

    returns the physical address of symbol contents. Option can be 
    'Data' (default) variables data 'Lstring' lstring structure pointer 
    'Variable' variable structure.

    If pool exist, the specific rexx pool is searched for the symbol. 
    Valid pools are numbers from 0 up to current procedure nesting. 
    (The result is normalized for MSDOS, ie `seg:ofs = seg*16+ofs`)

    .. code-block:: rexx
       :linenos:

        i = 5;	
        SAY addr('i')		/* something like 432009 decimal */
        SAY addr('i','L')	/* something like 433000 */
        SAY addr('i','V')	/* something like 403004 */
        SAY addr('i','V',0)	/* something like 403004 */
        SAY addr('j')		/* -1, is J variable doesn't exist */ 

.. function:: ADDRESS()

    return the current environment for commands.

    .. code-block:: rexx
       :linenos:

        SAY address() /* would display: SYSTEM */ 

.. function:: ARG([n[,option]])

    - ARG() returns the number of arguments
    - ARG(n) return then nth argument
    - ARG(n,option) option may be **Exist** or **Omitted** (only the
      first letter is significant) test whether the nth argument 
      Exists or is Omitted.

    Returns "0" or "1"

    .. code-block:: rexx
       :linenos:

        call myproc 'a',,2	
        ...		
        myproc:		
        SAY arg()		/* 3 */
        SAY arg(1)		/* 'a' */
        SAY arg(2,'O')		/* 1 */
        SAY arg(2,'E')		/* 0 */ 

.. function:: DATATYPE(string[,type])

    DATATYPE(string) - returns "NUM" is string is a valid REXX number, 
    otherwise returns "CHAR". DATATYPE(string,type) - returns "0" or "1"
    if string is of the specific type:

    - Alphanumeric: 	characters A-Z, a-z and 0-9
    - Binary: 	a valid BINARY number
    - Lowercase: 	characters a-z
    - Mixed: 	characters A-Z, a-z
    - Number: 	is a valid REXX number
    - Symbol:		characters A-Z, a-z, 0-9, @%_.!#
    - Uppercase: 	characters A-Z
    - Whole-number: 	a valid REXX whole number
    - X (heXadecimal): 	a valid HEX number 

    (only the first letter of type is required)

    The special type 'Type' returns the either INT, REAL, or STRING the 
    way the variable is hold into memory. Usefull when you combine that 
    with INTR function.

    .. code-block:: rexx
       :linenos:

        SAY datatype('123')		/* NUM */
        SAY datatype('21a')		/* CHAR */
        SAY datatype(01001,'B')		/* 1 */
        SAY datatype(i,'T')		/* maybe STRING */ 

.. function:: DATE([option])

    return current date in the format: dd Mmm yyyy

    .. code-block:: rexx
       :linenos:

        SAY date() /* 14 Feb 1993 */ 

    or formats the output according to option

    - Days		returns number of days since 1-Jan as an integer
    - European		returns date in format dd/mm/yy
    - Month		returns the name of current month, ie. March
    - Normal		returns the date in the default format dd Mmm yyyy
    - Ordered		returns the date in the format yy/mm/dd
    - 	(useful for sorting)
    - Sorted		returns the date in the format yyyymmdd
    - 	(suitable for sorting)
    - USA		returns the date in the format mm/dd/yy
    - Weekday		returns the name of current day of week ie. Monday 

.. function:: DESBUF()

    destroys the all system stacks, and returns the number of lines in 
    system stacks.

    .. code-block:: rexx
       :linenos:

        PUSH 'hello'		/* now stack has one item */
        CALL desbuf		/* stack is empty, and RESULT=1 */ 

.. function:: DROPBUF([num])

    destroys num top stacks, and returns the number of lines destroyed.

    .. code-block:: rexx
       :linenos:

        PUSH 'in stack1'		/* first stack has one item */
        CALL makebuf		/* create a new buffer */
        PUSH 'in stack2'		/* new stack has one item */
        CALL dropbuf		/* one stack remains */ 

.. function:: DIGITS()

    returns the current setting of NUMERIC DIGITS. 

.. function:: ERRORTEXT(n)

    returns the error message for error number n.

    .. code-block:: rexx
       :linenos:

        SAY errortext(8)	/* "Unexpected THEN or ELSE" */ 

.. function:: FORM()

    returns the current setting of NUMERIC FORM. 

.. function:: FUZZ()

    returns the current setting of NUMERIC FUZZ. 

.. function:: GETENV(varname)

    returns the environment variable varname

    .. code-block:: rexx
       :linenos:

        SAY getenv("PATH") 

.. function:: HASHVALUE(string)

    return an integer hashvalue of the string like Java
    `hash = s[0]*31^(n-1) + s[1]*31^(n-2) + ... + s[n-1]`

    .. code-block:: rexx
       :linenos:

        SAY hashvalue("monday")		/* -1068502768 */ 

.. function:: IMPORT( file )

    import a shared library file using dynamic linking with rexx 
    routines. If it fails, then try to load a rexx file so it can be 
    used as a library. import first searches the current directory, if 
    not found it searches the directories pointed by the environment 
    variable RXLIB.
    
    returns

    - "-1" if already imported
    - "0" on success
    - "1" on error opening the file
        
    .. code-block:: rexx
       :linenos:

        CALL IMPORT FSSAPI
        call import "veclib"

.. function:: MAKEBUF()

    create a new system stack, and returns the number of system stacks 
    created until now (plus the initial one).

    .. code-block:: rexx
       :linenos:

        PUSH 'hello'; SAY queued() queued(T)		/* display 1 1 */
        CALL makebuf		/* create a new buffer */
        PUSH 'aloha; SAY queued() queued(T)		/* display again 2 1 */ 

.. function:: QUEUED([option])

    return the number of lines in the rexx stack (all stacks or the 
    topmost) or the number of stacks. Option can be (only first letter 
    is significant):

    - All		lines in All stacks (default)
    - Buffers		number of buffers created with MAKEBUF
    - Topstack	lines in top most stack 

    .. code-block:: rexx
       :linenos:

        PUSH 'hi'		
        SAY queued(A) queued(B) queued(T)		/* 1 1 1 */
        CALL makebuf		
        SAY queued(A) queued(B) queued(T)		/* 1 2 0 */
        PUSH 'hello'		
        SAY queued(A) queued(B) queued(T)		/* 2 2 1 */
        CALL desbuf		
        SAY queued(A) queued(B) queued(T)		/* 0 1 0 */ 

.. function:: SOUNDEX(word)

    return a 4 character soundex code of word in the format "ANNN" 
    (used for phonetic comparison of words)

    .. code-block:: rexx
       :linenos:

        SAY soundex("monday")		/* M530 */
        SAY soundex("Mandei")		/* M530 */ 

.. function:: SOURCELINE([n])

    return the number of lines in the program, or the nth line.

    .. code-block:: rexx
       :linenos:

        SAY sourceline() 	/* maybe 100 */
        SAY sourceline(1) 	/* maybe "/**/" */ 

.. function:: STORAGE([address[,[length][,data]]])

    returns the current free memory size expressed as a decimal string 
    if no arguments are specified. Otherwise, returns length bytes from 
    the user's memory starting at address. The length is in decimal; the
    default value is 1 byte. The address is a decimal number (Normalized
    address for MSDOS ie. seg:ofs = seg*16+ofs) If data is specified, 
    after the "old" value has been retrieved, storage starting at
    address is overwritten with data (the length argument has no effect
    on this).

    .. code-block:: rexx
       :linenos:

        SAY storage()		/* maybe 31287 */
        SAY storage(1000,3)		/* maybe "MZa" */
        a = "Hello"
        SAY storage(addr('a'),5,'aaa') 	/* "Hello" */
        SAY a		/* aaalo */ 

.. function:: SYMBOL(name)

    return "BAD" if name is not a valid REXX variable name, "VAR" if name has been used as a variable, or "LIT" if it has not.

    .. code-block:: rexx
       :linenos:

        i = 5		
        SAY symbol('i')		/* VAR */
        SAY symbol(i)		/* LIT */
        SAY symbol(':asd')		/* BAD */ 

.. function:: TIME([option])

    return the local time in the format: `hh:mm:ss` if option is 
    specified time is formated as:

    - Civil		returns time in format hh:mmxx ie. 10:32am
    - Elapsed		returns elapsed time since rexx timer was reset
      or from begging of program in format ssssss.uuuuuu
    - Hours		returns number of hours since midnight
    - Long		returns time and milliseconds hh:mm:ss.uu
    - Minutes		returns number of minutes since midnight
    - Normal		returns time in format hh:mm:ss
    - Reset		returns elapsed time in format ssssss.uuuuuu (like
      Elapsed) and resets rexx internal timer.
    - Seconds		returns number of seconds since midnight

.. function:: TRACE([option])

    returns current tracing option. If option is specified then sets to new tracing option. Look up instruction TRACE.

    .. code-block:: rexx
       :linenos:

        SAY trace() /* normally 'N' */ 

.. function:: VALUE(name[,[newvalue][,pool]])

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

    .. code-block:: rexx
       :linenos:

        i = 5; j = "i"		
        SAY value(j)		/* 5 */
        SAY value('j',10)		/* 'i' */
        SAY j		/* 10 */
        CALL Procedure		
        ...		
        Procedure: PROCEDURE		
        i = "I-var"		
        SAY value('i')		/* I-var */
        SAY value('i',,0)		/* 5 */
        SAY value('i',,1)		/* I-var */
        SAY value('i',,-1)		/* 5 */
        ... 

.. function:: VARDUMP([symbol][,option])

    returns the binary tree of the variables in the format

    .. code-block:: rexx
       :linenos:

        var = "value" \n 

    option can be "Depth" which prints out the binary tree in the format

    .. code-block:: rexx
       :linenos:

        depth var = "value" \n (used for balancing of variables ) 

    symbol may be nothing for main bin-tree or a stem for an array bin-tree ie. "B."

    VARDUMP is an easy way to store the variables in a file or in stack and restores them later.

    .. code-block:: rexx
       :linenos:

        CALL write "vars.$$$", vardump() /* stores all variables */ /* in the file "vars.$$$" */ 

    on a later run you can do

    .. code-block:: rexx
       :linenos:

        DO UNTIL eof("vars.$$$")		/* this will read all variables */
        	INTERPRET read("vars.$$$")		/* from file, and restore them */
        END 

    .. warning:: VARDUMP is not fully implemented and may not work when 
        variables have non-printable characters.  

String Functions
----------------

.. function:: ABBREV(information,info[,length])

    tests whether info is an abbreviation of information. returns "1" 
    on true, else returns "0". If length is specified then searching 
    takes place only for the first length characters.

    .. code-block:: rexx
       :linenos:

        abbrev("billy","bill")		/* 1 */
        abbrev("billy","bila")		/* 0 */
        abbrev("billy","bila",3) 	/* 1 */ 

.. function:: CENTRE(string,length[,pad])

    returns string centered in a padded string of length length.

    .. code-block:: rexx
       :linenos:

        center("rexx",2)		/* 'ex' */
        center("rexx",8)		/* ' rexx ' */
        center("rexx",8,'-')		/* '--rexx--' */ 

.. function:: CHANGESTR(target,string,replace)

    replaces all occurrences of the target in string, replacing them 
    with the replace.

    .. code-block:: rexx
       :linenos:

        changestr("aa","aabbccaabbccaa","--") 	/* --bbcc--bbcc-- */ 

.. function:: COMPARE(string1,string2[,pad])

    returns "0" if string1==string2, else it returns the index of the 
    first nonmatching character. Shorter string is padded with pad if 
    necessary

    .. code-block:: rexx
       :linenos:

        compare('bill','bill')		/* 0 */
        compare('bill','big')		/* 3 */
        compare('bi ','bi')		/* 0 */
        compare('bi--*','bi','-') 	/* 5 */ 

.. function:: COUNTSTR(target,string)

    counts all the appearances of target in string

    .. code-block:: rexx
       :linenos:

        countstr("aa","aabbccaabbccaa") 	/* 3 */ 

.. function:: COPIES(string,n)

    returns n concatenated copies of string.

    .. code-block:: rexx
       :linenos:

        copies('Vivi',3) 	/* 'ViviViviVivi' */ 

.. function:: DELSTR(string,n[,length])

    delete substring of string starting at the nth character and of 
    length length.

    .. code-block:: rexx
       :linenos:

        delstr('bill',3)		/* 'bi' */
        delstr('bill',2,2)		/* 'bl' */ 

.. function:: INDEX(haystack,needle[,start])

    return the position of needle in haystack, beginning at start.

    .. code-block:: rexx
       :linenos:

        index('bilil','il')		/* 2 */
        index('bilil','il',3)		/* 4 */ 

.. function:: INSERT(new,target[,[n][,[length][,pad]]])

    insert the string new of length length into the string target, after
    the nth character (n can be 0)

    .. code-block:: rexx
       :linenos:

        insert('.','BNV',2)		/* 'BN.V' */
        insert('.','BNV',2,2)		/* 'BN. V' */
        insert('','BNV',2,2,'.')	/* 'BN..V' */ 

.. function:: LASTPOS(needle,haystack[,start])

    return the position of the last occurrence of needle in haystack, beginning at start.

    .. code-block:: rexx
       :linenos:

        lastpos('il','bilil')		/* 4 */
        lastpos('il','bilil',4)		/* 2 */ 

.. function:: LEFT(string,length[,pad])

    return a string of length length with string left justified in it.

    .. code-block:: rexx
       :linenos:

        left('Hello',2)		/* 'He' */
        left('Hello,10,'.')		/* 'Hello.....' */ 

.. function:: LENGTH(string)

    return the length of string

    .. code-block:: rexx
       :linenos:

        length('Hello')		/* 5 */ 

.. function:: OVERLAY(new,target[,[n][,[length][,pad]]])

    overlay the string new of length length onto string target, 
    beginning at the nth character.

    .. code-block:: rexx
       :linenos:

        overlay('.','abcd',2)		/* 'a.cd' */
        overlay('.','abcd')		/* '.bcd' */
        overlay('.','abcd',6,3,'+')		/* 'abcd+.++' */ 

.. function:: POS(needle,haystack[,start])

    return the position of needle in haystack, beginning at start.

    .. code-block:: rexx
       :linenos:

        pos('ll','Bill')		/* 3 */ 

.. function:: REVERSE(string)

    swap string, end-to-end.

    .. code-block:: rexx
       :linenos:

        reverse('Bill')		/* 'lliB' */ 

.. function:: RIGHT(string,length[,pad])

    returns length righmost characters of string.

    .. code-block:: rexx
       :linenos:

        right('abcde',2)		/* 'de' */ 

.. function:: SUBSTR(string,n[,[length][,pad]])

    return the substring of string that begins at the nth character 
    and is of length length. Default pad is space.

    .. code-block:: rexx
       :linenos:

        substr('abcde',2,2)		/* 'bc' */
        substr('abcde',2)		/* 'bcde' */
        substr('abcde',4,3,'-')		/* 'de-' */ 

.. function:: STRIP(string[,[<"L"|"T"|"B">][,char]])

    .. code-block:: rexx
       :linenos:

    returns string stripped of Leading, Trailing, or Both sets of 
    blanks or other chars. Default is "B".

    .. code-block:: rexx
       :linenos:

        strip(' abc ')		/* 'abc' */
        strip(' abc ','t')		/* ' abc' */
        strip('-abc--',,'-')		/* 'abc' */ 

.. function:: TRANSLATE(string[,[tableo][,[tablei][,pad]]])

    translate characters in tablei to associated characters in tableo. 
    If neither table is specified, convert to uppercase.

    .. code-block:: rexx
       :linenos:

        translate('abc')		/* 'ABC' */
        translate('aabc','-','a')		/* '--bc' */
        translate('aabc','-+','ab')		/* '--+c' */ 

.. function:: VERIFY(string,reference[,[option][,start]])

    return the index of the first character in string that is not also 
    in reference. if "Match" is given, then return the result index of 
    the first character in string that is in reference.

    .. code-block:: rexx
       :linenos:

        verify('abc','abcdef')		/* 0 */
        verify('a0c','abcdef')		/* 2 */
        verify('12a','abcdef','m')		/* 3 */ 

.. function:: XRANGE([start][,end])

    return all characters in the range start through end.

    .. code-block:: rexx
       :linenos:

        xrange('a','e')		/* 'abcde' */
        xrange('fe'x,'02'x)		/* 'feff000102'x */ 

Word Functions
--------------

.. function:: DELWORD(string,n[,length])

    delete substring of string starting at the nth word and of length 
    length words.

    .. code-block:: rexx
       :linenos:

        delword('one day in the year',3)		/* 'one day' */
        delword('one day in the year',3,2)		/* 'one day year' */ 

.. function:: FIND(string,phrase[,start])

    returns the word number of the first word of phrase in string. 
    Returns "0" if phrase is not found. if start exists then search start from start word.

    .. code-block:: rexx
       :linenos:

        find('one day in the year','in the') 	/* 3 */ 

.. function:: JUSTIFY(string,length[,pad])

    justify string to both margins (the width of margins equals length), 
    by adding pads between words.

    .. code-block:: rexx
       :linenos:

        justify('one day in the year',22) 	/*'one day in the year' 

.. function:: SUBWORD(string,n[,length])

    return the substring of string that begins at the nth word and 
    is of length length words.

    .. code-block:: rexx
       :linenos:

        subword('one day in the year',2,2) 	/* 'day in' */ 

.. function:: SPACE(string[,[n][,pad]])

    formats the blank-delimited words in string with n pad characters 
    between each word.

    .. code-block:: rexx
       :linenos:

        space('one day in the year',2) 	/*'one day in the year' */ 

.. function:: WORDS(string)

    return the number of words in string

    .. code-block:: rexx
       :linenos:

        words('One day in the year')		/* 5 */ 

.. function:: WORD(string,n)

    return the nth word in string

    .. code-block:: rexx
       :linenos:

        word('one day in the year',2)		/* 'day' */ 

.. function:: WORDINDEX(string,n)

    return the position of the nth word in string

    .. code-block:: rexx
       :linenos:

        wordindex('one day in the year',2) 	/* 5 */ 

.. function:: WORDLENGTH(string,i)

    return the length of the nth word in string

    .. code-block:: rexx
       :linenos:

        wordlength('one day in the year',2) 	/* 3 */ 

.. function:: WORDPOS(phrase,string[,start])

    returns the word number of the first word of phrase in string. 
    Returns "0" if phrase is not found

    .. code-block:: rexx
       :linenos:

        wordpos('day in','one day in the year') 	/* 2 */ 

Math Functions
--------------

.. function:: ABS(number)

    return absolute value of number

    .. code-block:: rexx
       :linenos:

        abs(-2.3) /* 2.3 */ 

.. function:: FORMAT(number[,[before][,[after][,[expp][,expt]]]])

    rounds and formats number with before integer digits and after 
    decimal places. expp accepts the values 1 or 2 (WARNING Totally 
    differen't from the Ansi-REXX spec) where 1 means to use the "G" 
    (General) format of C, and 2 the "E" exponential format of C. 
    Where the place of the totalwidth specifier in C is replaced by 
    before+after+1. ( expt is ignored! )

    .. code-block:: rexx
       :linenos:

        format(2.66)		/* 3 */
        format(2.66,1,1)		/* 2.7 */
        format(26.6,1,1,1)		/* 3.E+01 */
        format(26.6,1,1,2)		/* 2.7E+01 */ 

.. function:: IAND(n,m)

    return bitwise AND of the integers n and m

    .. code-block:: rexx
       :linenos:

        iand(2,3) /* 2 */ 

.. function:: INOT(n)

    return bitwise complement of integers n

    .. code-block:: rexx
       :linenos:

        inot(2) /* -3 */ 

.. function:: IOR(n,m)

    return bitwise OR of the integers n and m

    .. code-block:: rexx
       :linenos:

        ior(2,3) /* 3 */ 

.. function:: IXOR(n,m)

    return bitwise XOR of the integers n and m

    .. code-block:: rexx
       :linenos:

        ixor(2,3) /* 1 */ 

.. function:: MAX(number[,number]..])

    returns the largest of given numbers.

    .. code-block:: rexx
       :linenos:

        max(2,3,1,5) /* 5 */ 

.. function:: MIN(number[,number]..])

    returns the smallest of given numbers.

    .. code-block:: rexx
       :linenos:

        min(2,3,1,5) /* 1 */ 

.. function:: RANDOM([min][,[max][,seed]])

    returns a pseudorandom nonnegative whole number in the range min to max inclusive. 

.. function:: SIGN(number)

    return the sign of number ("-1","0" or "1").

    .. code-block:: rexx
       :linenos:

        sign(-5.2)		/* -1 */
        sign( 0.0)		/* 0 */
        sign( 5.2)		/* 1 */ 

.. function:: TRUNC(number[,n])

    returns the integer part of number, and n decimal places. The default n is zero.

    .. code-block:: rexx
       :linenos:

        trunc(2.6) /* 2 */ 

.. function:: ACOS( num ) 
    
    Arc-cosine

.. function:: ASIN( num ) 
    
    Arc-sine

.. function:: ATAN( num ) 
    
    Arc-tangent

.. function:: COS( num ) 	
    
    Cosine

.. function:: COSH( num ) 
    
    Hyperbolic cosine

.. function:: EXP( num ) 	
    
    Exponiate

.. function:: LOG( num ) 	
    
    Natural logarithm

.. function:: LOG10( num )
    
    Logarithm of base 10

.. function:: POW10( num )
    
    Power with base 10

.. function:: SIN( num ) 	
    
    Sine function

.. function:: SINH( num ) 
    
    Hyperbolic sine

.. function:: SQRT( num ) 
    
    Square root

.. function:: TAN( num ) 	
    
    Tangent

.. function:: TANH( num ) 
    
    Hyperbolic tangent

.. function:: POW( a,b ) 	
    
    Raises a to power b

Data Convert Functions
----------------------

.. function:: B2X(string)

    Binary to Hexadecimal

    .. code-block:: rexx
       :linenos:

        b2x('01100001')		/* 'a' */ 

.. function:: BITAND(string1[,[string2][,pad]])

    logically AND the strings, bit by bit

    .. code-block:: rexx
       :linenos:

        bitand('61'x,'52'x)		/* '40'x */
        bitand('6162'x,'5253'x)		/* '4042'x */
        bitand('6162'x,,'FE'x)		/* '6062'x */ 

.. function:: BITOR(string1[,[string2][,pad]])

    logically OR the strings, bit by bit 

.. function:: BITXOR(string1[,[string2][,pad]])

    logically XOR the strings, bit by bit 

.. function:: C2D(string[,n])

    Character to Decimal. The binary representation of string is 
    converted to a number (unsigned unless the length n is specified).

    .. code-block:: rexx
       :linenos:

        c2d('09'x)		/* 9 */
        c2d('ff40')		/* 65344 */
        c2d('81'x,1)		/* -127 */
        c2d('81'x,2)		/* 129 */ 

.. function:: C2X(string)

    Character to Hexadecimal

    .. code-block:: rexx
       :linenos:

        c2x('abc')		/* '616263' */
        c2x('0506'x)		/* '0506' */ 

.. function:: D2C(wholenumber[,n])

    Decimal to Character. Return a string of length n, which is the 
    binary representation of the number.

    .. code-block:: rexx
       :linenos:

        d2c(5)		/* '5'x */
        d2c(97)		/* 'a' */ 

.. function:: D2X(wholenumber[,n])

    Decimal to Hexadecimal. Return a string of length n, which is the 
    hexadecimal representation of the number.

    .. code-block:: rexx
       :linenos:

        d2x(5)		/* '05' */
        d2x(97)		/* '61' */ 

.. function:: B2X(string)

    Hexadecimal to Binary

    .. code-block:: rexx
       :linenos:

        x2b('a')		/* '01100001' */ 

.. function:: X2C(string)

    Hexadecimal to Character

    .. code-block:: rexx
       :linenos:

        x2c('616263')		/* 'abc' */ 

.. function:: X2D(hex-string[,n])

    Hexadecimal to Decimal. hex-string is converted to a number 
    (unsigned unless the length n is specified)

    .. code-block:: rexx
       :linenos:

        x2d('61')		/* 97 */ 

File Functions
--------------

**General**

There are two sets of I/O functions, the REXX-STEAM functions and the BREXX I/O routines.

Files can be referenced as a string containing the name of the file ie 
"TEST.DAT" or the file handle that is returned from OPEN function. 
(Normally the second way if prefered when you want to open 2 or more 
files with the same name).

There are always 3 special files:

+----------+------------+------------------------------------+
| Handle   | FileName   | Description                        |
+==========+============+====================================+
| 0        | <STDIN>    | Standard input                     |
+----------+------------+------------------------------------+
| 1        | <STDOUT>   | Standard output                    |
+----------+------------+------------------------------------+
| 2        | <STDERR>   | Standard error                     |
+----------+------------+------------------------------------+

All open files are closed at the end of the program from REXX
interpreter except in the case of an error.

.. function:: CHARIN( [stream[,[start][,[length]]]] )

    reads length bytes (default=1) from stream (default="<STDIN>") 
    starting at position start

    .. code-block:: rexx
       :linenos:

        ch = charin("new.dat")		/* read one byte */
        ch = charin("new.dat",3,2) 	/* read two bytes from position in file 3 */ 

.. function:: CHAROUT( [stream[,[string][,[start]]]] )

    write string to stream (default="<STDOUT>") starting at 
    position start

    .. code-block:: rexx
       :linenos:

        CALL charout "new.dat","hello" 	/* writes "hello" to file */
        CALL charout "new.dat","hi",2) 	/* writes "hi" at position 2 */ 

.. function:: CHARS( [stream] )

    returns the number of characters remaining in stream.

    .. code-block:: rexx
       :linenos:

        CHARS("new.dat") 	/* maybe 100 */ 

.. function:: CLOSE( file )

    closes an opened file. file may be string or the handle number

    .. code-block:: rexx
       :linenos:

        CALL close 'new.dat' 	/* these two cmds are exactly the same */
        CALL close hnd 	/* where hnd=open('new.dat','w') */ 

.. function:: EOF( file )

    returns 1 at eof, -1 when file is not opened, 0 otherwise

    .. code-block:: rexx
       :linenos:

        DO 	UNTIL eof(hnd)=1	
        	SAY read(hnd) 	/* type file */
        END		

.. function:: FLUSH( file )

    flush file stream to disk

    .. code-block:: rexx
       :linenos:

        CALL flush 'new.dat' 

.. function:: LINEIN( [stream[,[start][,[lines]]]] )

    reads lines lines (default=1) from stream (default="<STDIN>") starting at line position start

    .. code-block:: rexx
       :linenos:

        line = linein("new.dat")		/* read one line */
        line = linein("new.dat",3,2) 	/* read two lines from new.dat starting at line 3 */ 

.. function:: LINEOUT( [stream[,[string][,[start]]]] )

    write string with newline appended at the end to stream 
    (default="<STDOUT>") starting at line position start

    .. code-block:: rexx
       :linenos:

        CALL lineout "new.dat","hello" 	/* writes line "hello" to file */
        CALL lineout "new.dat","hi",2) 	/* writes line "hi" at line position 2 */ 

.. function:: LINES( [stream] )

    returns the number of lines remaining in stream. start

    .. code-block:: rexx
       :linenos:

        LINES("new.dat") 	/* maybe 10 */ 

.. function:: OPEN( file, mode )

    opens a file. mode follows C prototypes:

    +-----------+--------------+-------+-----------------+
    |     "r"   | for read     | "w"   | for write       |
    +-----------+--------------+-------+-----------------+
    |     "t"   | for text,    | "b"   | for binary      |
    +-----------+--------------+-------+-----------------+
    |     "a"   | for append   | "+"   | for read/write  |
    +-----------+--------------+-------+-----------------+

    and returns the handle number for that file. -1 if file is not 
    found!
    
    .. code-block:: rexx
       :linenos:

        hnd	= open('new.dat','w')
        IF	hnd = -1 THEN DO
        	SAY 'Error: opening file "new.dat".'
        	...
        END
        irda = open('com3:115200,8,N,1,128','rw') 

.. function:: READ( [file][,<length | "Char" | "Line" | "File">])

    reads one line from file. If the second argument exists and it is a 
    number it reads length bytes from file otherwise reads a Char, Line 
    or the entire File. If file is not opened, it will be opened 
    automatically in "r" mode. If file is ommited, it is assumed to 
    be <STDIN>

    .. code-block:: rexx
       :linenos:

        kbdin = READ() 	/* reads one line from stdin */
        keypressed = read(,1) 	/* -//- char -//- */
        linein = read('new.dat') 	/* reads one line from file */
        linein = read(hnd) 	/* -//- */
        ch = read('new.dat',"C") 	/* if file 'data' is not opened
        	then it will be opened in "r" mode */
        CALL write "new",read("old","F") 	/* copy file */ 

.. function:: SEEK( file [,offset [,<"TOF" | "CUR" | "EOF">]])

    move file pointer to offset relative from TOF Top Of File (default),
    CUR Current position, EOF End Of File and return new file pointer. 
    This is an easy way to determine the filesize, by seeking at the
    end,

    .. code-block:: rexx
       :linenos:

        filesize = seek(file,0,"EOF") 	/* return file size */
        CALL seek 'data',0,"TOF" 	/* sets the pointer to the start of the file */
        filepos = seek('data',-5,"CUR") 	/* moves pointer 5 bytes backwards */ 

.. function:: STREAM( stream[,[option][,command]] )

    STREAM returns a description of the state, or the result of an 
    operation upon the stream named by the first argument.

    option can be "Command", "Description", "Status"
    
    When option is "Command" the third argument must exist and can take 
    on of the following values:

    +--------------------+--------------------------------------------------+
    | Command            | Description                                      |
    +====================+==================================================+
    |     READ           | open in read-only mode ASCII                     |
    +--------------------+--------------------------------------------------+
    |     READBINARY     | open in read-only mode BINARY                    |
    +--------------------+--------------------------------------------------+
    |     WRITE          | open in write-only mode ASCII                    |
    +--------------------+--------------------------------------------------+
    |     WRITEBINARY    | open in write-only mode BINARY                   |
    +--------------------+--------------------------------------------------+
    |     APPEND         | open in read/write-append mode ASCII             |
    +--------------------+--------------------------------------------------+
    |     APPENDBINARY   | open in read/write-append mode BINARY            |
    +--------------------+--------------------------------------------------+
    |     UPDATE         | open in read/write mode (file must exist) ASCII  |
    +--------------------+--------------------------------------------------+
    |     UPDATEBINARY   | open in read/write mode BINARY                   |
    +--------------------+--------------------------------------------------+

    When option is "Status", STREAM returns the current status of the 
    stream can be on of the followings: "READY", "ERROR", "UNKNOWN"

    When option is "Description", STREAM returns a description of the 
    last error.

    .. code-block:: rexx
       :linenos:

        CALL stream "new.dat","C","WRITE"
        CALL stream "new.dat","C","CLOSE"
        CALL stream "new.dat","S" 

.. function:: WRITE( [file][, string[,newline]])

    writes the string to file. returns the number of bytes written. If 
    string doesn't exist WRITE will write a newline to file. If a third 
    argument exists a newline will be added at the end of the string. If
    file is not opened, it will be opened automatically with "w" mode. 
    If file is ommited, it is assumed to be <STDOUT>

    .. code-block:: rexx
       :linenos:

        CALL write 'data','First line',nl;	
        CALL write ,'a' 	/* writes 'a' to stdout */
        CALL write '','one line',nl 	/* write 'one line' to stdout */
        CALL write 'output.dat','blah blah' 	/* writes 'blah blah' to 'output.dat' file*/ 