RXLIB functions
===============

BREXX can implement new functions or commands in REXX. They are 
transparent and are called in the same way as basic BREXX functions. 
They are stored in the library BREXX.RXLIB and are automatically 
allocated (via `DD RXLIB`) in RXBATCH and RXTSO (Batch). In this 
release, BREXX delivers the following functions.

.. function:: RXMSG(msg-number,'msg-level','message')
    
    Standard message module to display a message in a formatted way
    
    :param msg-number: message number to be displayed
    :param msg-level: One of: I, W, E, C


    message level can be:

    +----------------+-----------------------------+
    | Message Level  | Description                 |
    +================+=============================+
    | I              | for an information message  |
    +----------------+-----------------------------+
    | W              | for a warning message       |
    +----------------+-----------------------------+
    | E              | for an error message        |
    +----------------+-----------------------------+
    | C              | for a critical message      |
    +----------------+-----------------------------+


    Example:
    
    .. code-block:: rexx
       :linenos:
    
       rc=rxmsg( 10,'I','Program started')
       rc=rxmsg(200,'W','Value missing')
       rc=rxmsg(100,'E','Value not Numeric')
       rc=rxmsg(999,'C','Divisor is zero')
    
    Results::
    
        RX0010I    PROGRAM STARTED  
        RX0200W    VALUE MISSING    
        RX0100E    VALUE NOT NUMERIC
        RX0999C    DIVISOR IS ZERO  
    
    
    Additionally, the following REXX variables are maintained and can be 
    used in the calling REXX script.
    
    Return code from call **RXMSG**:
    
    +--------------+-------------------------------------+
    | Return Code  | Description                         |
    +==============+=====================================+
    | 0            | an information message was written  |
    +--------------+-------------------------------------+
    | 4            | a warning message was written       |
    +--------------+-------------------------------------+
    | 8            | an error message was written        |
    +--------------+-------------------------------------+
    | 12           | a critical message was written      |
    +--------------+-------------------------------------+
    
    **MSLV** contains the written message level
    
        +----------------+-----------------------------+
        | Message Level  | Description                 |
        +================+=============================+
        | I              | for an information message  |
        +----------------+-----------------------------+
        | W              | for a warning message       |
        +----------------+-----------------------------+
        | E              | for an error message        |
        +----------------+-----------------------------+
        | C              | for a critical message      |
        +----------------+-----------------------------+
    
    **MSTX** contains the written message text part

    **MSLN** includes the complete message with the message number, 
    message level and text

    **MAXRC** contains the highest return code so far; this can be used 
    to exit the top level REXX. If you used nested procedures, it is 
    required to expose MAXRC, to make it available in the calling
    procedures.

.. function:: DCL('field-name',[offset],length,[type])
    
    Defines a structure of fields which maps typically to an I/O record.
    The function returns the next available offset in the structure.

    Initialize the function with `DCL('$DEFINE','structure-name')` 
    where:

    - `$DEFINE` initialises the structure definition 
    - `structure-name` all following field definitions are associated 
      with the structure-name.

    :param field-name: name of the rexx variable containing/receiving 
        the field content of the record
    :param offset: offset of the field in the record. This definition is
        optional if left out the next offset from the previous 
        `DCL(field...)` definition is used, or 1 if there was none.
    :param length: length if the field in the record
    :param type: field-type either  **CHAR** no translation takes place, 
        CHAR is default or **PACKED** decimal Packed field. Translation 
        into/from Decimal packed into Numeric REXX value takes place

    `call SPLITRECORD 'structure_name,record-to-split` splits 
    record-to-split in the defined field-names (aka REXX variables). The 
    variable containing the record to split is typically read from a 
    dataset.

    `Record=SETRECORD('student')` combines the content of all defined 
    fields (aka REXX variables) at the defined position and the defined 
    length to a new record.

    Example:
    
    .. code-block:: rexx
       :linenos:
    
        n=DCL('$DEFINE','student')
        n=DCL('Name',1,32,'CHAR')
        n=DCL('FirstName',1,16,'CHAR')
        n=DCL('LastName',,16,'CHAR')
        n=DCL('Address',,32,'CHAR')
        recin='Fred            Flintstone      Bedrock'
        /*    '12345678901234567890123456789012345678901234567890 */
        call splitRecord 'student',recin
        say Name
        say FirstName
        say LastName
        say Address
        firstName='Barney'
        LastName='Rubble'
        address='Bedrock'
        say setRecord('student')

    Results::

        FRED            FLINTSTONE             
        FRED                                   
        FLINTSTONE                             
        BEDROCK                                
        BARNEY          RUBBLE          BEDROCK

.. function:: DAYSBETW(date1,date-2[,[format-date1],[format-date2]])
    
    Return days between 2 dates of a given format.
    
    :param format-date1: date format of date1 defaults to European
    :param format-date2: date format of date2 defaults to European
    
    the format-dates reflect the Input-Format of DATE and can be found
    in details there.

.. function:: DUMP(string, [hdr])
    
    Displays string as a Hex value, useful to check if a received a 
    string contains unprintable characters. One can specify hdr as an 
    optional title.

    Example:
    
    .. code-block:: rexx
       :linenos:

       CALL DUMP 'THIS IS THE NEW VERSION OF BREXX/370 V2R1M0','DUMP LINE'

    Results::

        DUMP LINE                                            
        0000(0000)  THIS  IS  THE  NEW    VERS ION  OF B REXX
        0000(0000)  ECCE 4CE4 ECC4 DCE4   ECDE CDD4 DC4C DCEE
        0000(0000)  3892 0920 3850 5560   5592 9650 6602 9577
                                                             
        0032(0020)  /370  V2R 1M0                            
        0032(0020)  6FFF 4EFD FDF                            
        0032(0020)  1370 0529 140                            

.. function:: LISTALC()
    
    Lists all allocated Datasets in this session or region.

    Example:
    
    .. code-block:: rexx
       :linenos:

       CALL LISTALC

    Results::

        STDOUT    *terminal          
        STDIN     *terminal          
        SYSPROC   SYS1.CMDPROC       
        SYSHELP   SYS1.HELP          
                  SYS2.HELP          
        SYS00002  UCPUB001           
        RXLIB     BREXX.V2R5M0.RXLIB 
        SYSEXEC   SYS2.EXEC          
        SYS00005  UCPUB000           
        ISPPROF   IBMUSER.ISP.PROF   
        ISPMLIB   SYSGEN.ISPF.MLIB   
        STDERR    *terminal          
        ISPSLIB   SYSGEN.ISPF.SLIB   
        ISPCLIB   SYSGEN.ISPF.CLIB   
                  SYSGEN.REVIEW.CLIST
        ISPLLIB   SYSGEN.ISPF.LLIB   
                  SYSGEN.REVIEW.LOAD 
        ISPTABL   SYSGEN.ISPF.TLIB   
        ISPPLIB   SYSGEN.ISPF.PLIB   
                  SYSGEN.ISPF.RFEPLIB
        ISPTLIB   SYSGEN.ISPF.TLIB   
        REVPROF   IBMUSER.ISP.PROF   
        SYS00012  SYSGEN.ISPF.LLIB   
        SYS00013  IBMUSER.CLIST      


.. function:: LISTCAT([list-cat-parameter])
    
    Returns listcat output in the stem LISTCAT.

.. function:: MVSCBS()
    
    Allows addressing of some MVS control blocks. There are several 
    dependent control blocks combined. To use them, MVSCBS must be 
    imported first. After that, they can be used.

    Currently integrated control blocks are:
    - CVT()
    - TCB()
    - ASCB()
    - TIOT()
    - JSCB()
    - RMCT()
    - ASXB()
    - ACEE()
    - ECT()
    - SMCA()

    The definition and the content of the MVS control blocks can be 
    found in the appropriate IBM manuals: MVS Data Areas, Volume 1 to 5.

    IMPORT command is described in Vassilis N. Vlachoudis BREXX 
    documentation: http://home.cern.ch/~bnv

.. function:: QUOTE(string,qtype) 
    
    Enclose string in quotes, double quotes, or parenthesis,
    
    :param qtype: can be: 

    - `'` single quote (default),
    - `“` double quote
    - `(` bracket, the closing character is ')'
    - `[` square bracket, the closing character is ']'

    Example:
    
    .. code-block:: rexx
       :linenos:

        Mystring='string to be quoted'
        Say QUOTE(mystring,'”')
        Say QUOTE(mystring,”'”)
        Say QUOTE(mystring,'(')
        Say QUOTE(mystring,'[')
    
    Results::

        'STRING TO BE QUOTED'
        'STRING TO BE QUOTED'
        (STRING TO BE QUOTED)
        [STRING TO BE QUOTED]

.. function:: PDSRESET(pds-name)
    
    Removes all members of a PDS and runs a compress. After execution, 
    the PDS is empty.

.. function:: READALL(file,variable[,'DSN'/'DDN'])
    
    Reads the entire file into a stem variable. The file can be either a 
    dd-name or a ds-name. After successful completion, the stem 
    `variable.0` contains the number of lines read into the stem. The 
    file name can either represent an allocated dd name or a fully 
    qualified DSN. The third parameter defines the file type and is 
    either DSN or DDN. If it is missing DDN is the default.

.. function:: PERFORM(pds-name,process-member-rexx)
    
    Reads member list of a PDS and runs the process-member-rexx against 
    each member. The REXX to be called receives the parameters:

    - Pds-name
    - Member-name

.. function:: RXSORT(sort-type[,ASCENDING/DESCENDING])
    
    Sorts the stem variable SORTIN. SORTIN.0 must contain the number of 
    entries of SORTIN. The sort algorithms supported are: QUICKSORT, 
    SHELLSORT, HEAPSORT, BUBBLESORT. After Completion of RXSORT the 
    stem variable SORTIN. is sorted. If you requested ASCENDING (also 
    default) it is in ascending order, for DESCENDING in descending 
    order.

    Sorting with REXX is only recommended for a small number of stem 
    entries. Up to 1000 entries, RXSORT works in a reasonable time.
    
    If the stem you want to sort is not in SORTIN, you can use the 
    SORTCOPY function to copy it over to SORTIN.

.. function:: SEC2TIME(seconds[,'DAYS'])
    
    Converts a number of seconds into the format hh:mm:ss, or days 
    hh:mm:ss if the 'DAYS' parameter is specified.

    Example:
    
    .. code-block:: rexx
       :linenos:

       say sec2Time(345000)
       say sec2Time(345000,'DAYS')

    Results::
        
        95:50:00         
        3 day(s) 23:50:00

.. function:: SORTCOPY(stem-variable)
    
    Copies any stem variable into the stem `SORTIN.`, which then can be 
    used by RXSORT. `Stem-variable.0` must contain the number of entries 
    of the stem.

.. function:: STEMCOPY(source-stem-variable,target-stem-variable)
    
    Copies any stem variable into another stem variable. 
    `source-stem-variable.0` must contain the number of entries of the 
    stem. Stem-variables must end with a trailing '.', e.g. `mystem.`

.. function:: STEMCLEN(stem-variable)
    
    Cleansing of a stem variable, it removes empty and unset stem items 
    and adjusts the stem numbering. `Stem-variable.0` must contain the 
    number of entries of the stem and will after the cleansing the 
    modified number of entries. Stem-variables must end with a 
    trailing '.', e.g. `mystem.`

.. function:: STEMGET(dataset-name)
    
    Reads the saved content of one or more stem variables and re-apply 
    the stem. Stem names are save in the dataset.

.. function:: STEMINS(stem-to-insert,insert-into-stem,position)
    
    Inserts stem-to-insert into insert-into-stem beginning at position. 
    The content of the original stem at the position is shifted down n 
    positions, whereby n is the size of the stem to be inserted. 
    `Stem-variable(s).0` must contain the number of entries of the stem.
    Stem-variables must end with a trailing '.', e.g. `mystem.`

.. function:: STEMPUT(dataset-name,stem1[,stem2{,stem3]...)

    Saves the content of one or more stems in a fully qualified 
    dataset-name Stem-variable.0 must contain the number of entries of 
    the stem. Stem-variables must end with a trailing '.', e.g. 
    `mystem.`

.. function:: STEMREOR(stem-variable)
    
    reorders stem variable from top to bottom. 
    
    1. element becomes last, 
    2. next to last, etc.

    Stem-variable.0 must contain the number of entries of the stem. 
    Stem-variables must end with a trailing '.', e.g. `mystem.`

.. function:: TODAY([output_date_format[,date[,input_date_format]]) [date-format])
    
    Returns today's date based on the requested format. You can also use
    a date which is in the past or the future. Details of date-formats 
    can be found in the DATE output-format description.

.. function:: UNQUOTE(string)
    
    Remove from string leading and trailing quotes, double quotes, 
    parenthesis and '<' and '>' signs.

    Example:
    
    .. code-block:: rexx
       :linenos:

        Say UNQUOTE(“ 'quoted-string' “)
        Say UNQUOTE(“<entry 1>“)
        Say UNQUOTE(“(entry 2)“)
        Say UNQUOTE(“[entry 3]“)
    
    Results::
        
        'QUOTED-STRING'
        ENTRY 1         
        ENTRY 2         
        ENTRY 3         

.. function:: WRITEALL(file,variable[,'DSN'/'DDN'])
    
    Writes a stem variable into a file. The file can be either a dd-name
    or a ds-name. The stem variable.0 must contain the number of entries
    of the stem. The file name can either represent an allocated dd name
    or a fully qualified DSN. The third parameter defines the file type
    and is either DSN or DDN. If it is missing DDN is the default.