TSO REXX Functions
==================

TSO REXX functions are only available in TSO environments (online or 
batch) not in plain batch.

.. function:: SYSDSN(dataset-name[(member-name)])

    Returns a message indicating whether a dataset exists or not.
    
    A fully qualified dataset-name must be enclosed in apostrophes 
    (single quotes) they must be delivered to the MVS function, it is, 
    therefore, necessary to put double quotes around the dataset-name. 
    If the dataset-name does not contain an apostrophe, it is completed 
    by the user-name as the prefix.

    +-------------------+------------------------------------+
    | Return message    | Description                        |
    +===================+====================================+
    | OK                | dataset or member is available     |
    +-------------------+------------------------------------+ 
    | DATASET NOT FOUND | dataset or member is not available |
    +-------------------+------------------------------------+
    | INVALID DATASET   | NAME dataset name is not valid     |
    +-------------------+------------------------------------+
    | MISSING DATASET   | NAME no dataset name given         |
    +-------------------+------------------------------------+

    Example:
    
    .. code-block:: rexx
       :linenos:
    
       x=SYSDSN("'HERC01.TEST.DATA'")
       IF x = 'OK' THEN
         do something
       ELSE
         do something other


.. function:: SYSALC(['DSN'/'DDN',dataset-name/dd-name)

    A function which determines allocation information.  

    - `DSN` and a dataset-name return all allocations in which the DSN occurs 
    - `DDN` and a dd-name return the dataset-names which are allocated for it. If there is more than one Dataset, then the dd-name has an allocation with concatenated datasets.  

    The result is returned in the stem variable _RESULT.i, _RESULT.0 contains the number of entries. 

    Examples:

    .. code-block:: rexx
       :linenos:
    
       call sysalc('DSN','Brexx.r')       
       call stemlist '_result.'  

    Results::

             Entries of STEM: _RESULT.                     
        Entry   Data                                       
        -------------------------------------------------- 
        00001   SYSUEXEC                                   
        00002   SYS00033                                   
        2 Entries                                          

    .. code-block:: rexx
       :linenos:
    
       call sysalc('DSN','Brexy.r')       /* DSN does not exist */ 
       call stemlist '_result.'           

    Results::

            Entries of STEM: _RESULT.                     
        Entry   Data                                       
        -------------------------------------------------- 
        0 Entries                                          

    .. code-block:: rexx
       :linenos:
    
       call sysalc('DDN','SYSuexec')      
       call stemlist '_result.'                    

    Results::

             Entries of STEM: _RESULT.                     
        Entry   Data                                       
        -------------------------------------------------- 
        00001   PEJ.EXEC                                   
        00002   BREXX.R                                    
        2 Entries                                          


.. function:: SYSVAR(request-type)

    TSO-only function to retrieve certain TSO runtime information.
    Available request-types:

    +-----------+-----------------------------------------------------------------------+
    | Type      | Description                                                           |
    +===========+=======================================================================+
    | SYSUID    | UserID                                                                |
    +-----------+-----------------------------------------------------------------------+
    | SYSPREF   | system prefix of current TSO session (typically hlq of userid)        |
    +-----------+-----------------------------------------------------------------------+
    | SYSENV    | FORE/BACK/BATCH forground/background TSO execution, or plain batch    |
    +-----------+-----------------------------------------------------------------------+
    | SYSISPF   | ISPF active 1, not active 0                                           |
    +-----------+-----------------------------------------------------------------------+
    | SYSTSO    | TSO active 1, not active 0                                            |
    +-----------+-----------------------------------------------------------------------+
    | SYSAUTH   | script runs in authorised mode (1), 0 not authorised                  |
    +-----------+-----------------------------------------------------------------------+
    | SYSCP     | returns the host-system which runs MVS38j. It is either MVS or VM/370 |
    +-----------+-----------------------------------------------------------------------+
    | SYSCPLVL  | shows the release of the host-system                                  |
    +-----------+-----------------------------------------------------------------------+
    | SYSHEAP   | allocated heap storage                                                |
    +-----------+-----------------------------------------------------------------------+
    | SYSSTACK  | allocated stack storage                                               |
    +-----------+-----------------------------------------------------------------------+
    | RXINSTRC  | BREXX Instruction Counter                                             |
    +-----------+-----------------------------------------------------------------------+

Example:

.. code-block:: rexx
   :linenos:
   
   say sysvar('SYSISPF')
   say sysvar('SYSUID')
   say sysvar('SYSPREF')
   say sysvar('SYSENV')
   say sysvar('SYSAUTH')
   say sysvar('SYSCP')
   say sysvar('SYSCPLVL')
   say sysvar('RXINSTRC')

Result::

     NOT ACTIVE                                
     IBMUSER                                   
     IBMUSER                                   
     FORE                                      
     1                                         
     Hercules                                  
     Hercules version 4.4.1.10647-SDL-gd0ccfbc9
     16                                        

.. function:: MVSVAR(request-type)
    
    Return certain MVS information.

    +------------+-----------------------------------------------------------+
    | Type       | Description                                               |
    +============+===========================================================+
    | SYSNAME    | system name                                               |
    +------------+-----------------------------------------------------------+
    | SYSOPSYS   | MVS release                                               |
    +------------+-----------------------------------------------------------+
    | CPUS       | number of CPUs                                            |
    +------------+-----------------------------------------------------------+
    | CPU        | CPU type                                                  |
    +------------+-----------------------------------------------------------+
    | NJE        | 1 = NJE38 is running, 0 = NJE38 is not running/installed  |
    +------------+-----------------------------------------------------------+
    | NJEDSN     | Dataset name of the NJE38 spool queue                     |
    +------------+-----------------------------------------------------------+
    | SYSNETID   | Netid of MVS (if any)                                     |
    +------------+-----------------------------------------------------------+
    | SYSNJVER   | Version of NJE38                                          |
    +------------+-----------------------------------------------------------+
    | JOBNUMBER  | current job number                                        |
    +------------+-----------------------------------------------------------+

   Example:
   
    .. code-block:: rexx
      :linenos:
      
      Say MVSVAR('SYSNAME')
      SAY MVSVAR('SYSOPSYS')
      SAY MVSVAR('CPU')
      SAY MVSVAR('CPUS')
      SAY MVSVAR('NJE')
      SAY MVSVAR('NJEDSN')
      SAY MVSVAR(SYSNETID)
      SAY MVSVAR(SYSNJVER)
      SAY MVSVAR('MVSUP')
      SAY sec2time(MVSVAR('MVSUP'),'DAYS')

    Results::
    
        MVSC               
        MVS 03.8           
        148                
        0002               
        1                  
        NJE38.NETSPOOL                   
        DRNBRX3A
        V2.2.0 01/14/21 07.11     
        1339432            
        15 day(s) 12:03:52 

.. function:: LISTDSI(dataset)
    
    Returns information of non-VSAM datasets in REXX variables.

    :param dataset: Either `"'”dataset-name”'”` or `'dd-name FILE'`

    A fully qualified dataset-name must be enclosed in apostrophes 
    (single quotes) they must be delivered to the MVS function, it is, 
    therefore, necessary to put double-quotes around the dataset-name. 
    If the dataset-name does not contain an apostrophe, it is prefixed 
    by the user-name

    +-------------+-------------------------------------------------+
    | Variable    | Description                                     |
    +=============+=================================================+
    | SYSDSNAME   | Dataset name                                    |
    +-------------+-------------------------------------------------+
    | SYSVOLUME   | Volume location                                 |
    +-------------+-------------------------------------------------+
    | SYSDSORG    | PS for sequential, PO for partitioned datasets  |
    +-------------+-------------------------------------------------+
    | SYSRECFM    | record format, F,FB,V,VB, ...                   |
    +-------------+-------------------------------------------------+
    | SYSLRECL    | record length                                   |
    +-------------+-------------------------------------------------+
    | SYSBLKSIZE  | block size                                      |
    +-------------+-------------------------------------------------+
    | SYSSIZE     | file size, For partitioned it is 0              |
    +-------------+-------------------------------------------------+

.. function:: LISTDSIX(dataset)
   
    :param dataset: Either `"'”dataset-name”'”` or `'dd-name FILE'`
    
    LISTDSIX is an extended version LISTDSI, which contains some additional 
    dataset attributes. Due to performance reasons, it has not been integrated
    into the standard LISTDSI. All LISTDSI variables are contained plus these 
    additional ones, some are redundant and are suffixed with an X:  

    +-------------+-------------------------------------------------+
    | Variable    | Description                                     |
    +=============+=================================================+
    | SYSBLKSIZEX | block size (returned from extra analysis)       |
    +-------------+-------------------------------------------------+
    | SYSCREATE   | creation date in Julian date format             |
    +-------------+-------------------------------------------------+
    | SYSDSORGX   | PS for sequential, PO for partitioned datasets  |
    +-------------+-------------------------------------------------+
    | SYSEXTENTS  | number of extents                               |
    +-------------+-------------------------------------------------+
    | SYSLRECLX   | record length                                   |
    +-------------+-------------------------------------------------+
    | SYSNTRACKS  | "116"                                           |
    +-------------+-------------------------------------------------+ 
    | SYSRECFMX   | record format, F,FB,V,VB, …	                    |
    +-------------+-------------------------------------------------+
    | SYSREFDATE  | last referenced date in Julian date format      |
    +-------------+-------------------------------------------------+
    | SYSSEQALC   | secondary allocation in SYSUNITS                |
    +-------------+-------------------------------------------------+
    | SYSTRACKS   | allocated tracks                                |
    +-------------+-------------------------------------------------+
    | SYSUNITS    | allocation unit: CYLINDERS, TRACKS or BLOCKS    |
    +-------------+-------------------------------------------------+

    .. note:: 
        A fully qualified dataset-name must be enclosed in apostrophes (single 
        quotes) they must be delivered to the MVS function, it is, therefore, 
        necessary to put double quotes around the dataset-name. If the 
        dataset-name does not contain an apostrophe, it is prefixed by the 
        user-name.

.. function:: LISTVOL(volume)

    Returns detailed information about the volume:

    +-------------+-------------------------------------------------+
    | Variable    | Description                                     |
    +=============+=================================================+
    | VOLVOLUME   | Volume name                                     |
    +-------------+-------------------------------------------------+
    | VOLTYPE     | Volume type 3350,3360, 3390, etc.               |
    +-------------+-------------------------------------------------+ 
    | VOLCYLS     | physical cylinders                              |
    +-------------+-------------------------------------------------+
    | VOLTRKSCYL  | tracks per Cylinders                            |
    +-------------+-------------------------------------------------+
    | VOLTRACKS   | volume total tracks                             |
    +-------------+-------------------------------------------------+
    | VOLTRKALC   | total tracks allocated                          |
    +-------------+-------------------------------------------------+
    | VOLTRKLEN   | track length                                    |
    +-------------+-------------------------------------------------+
    | VOLDIRTRK   | maximum directory blocks of track               |
    +-------------+-------------------------------------------------+
    | VOLDSNS     | number of datasets residing  on Volume          |
    +-------------+-------------------------------------------------+ 
    | VOLTRKUSED  | number of used tracks                           |
    +-------------+-------------------------------------------------+
    | VOLDEVICE   | device number of volume, e.g. 241               |
    +-------------+-------------------------------------------------+
    | VOLDSCBS    | maximum number of DSCB                          |
    +-------------+-------------------------------------------------+
    | VOLDSCBTRK  | maximum number of DSCBs in a track              |
    +-------------+-------------------------------------------------+
    | VOLALTTRK   | number of alternate tracks                      |
    +-------------+-------------------------------------------------+

.. function:: LISTVOLS(option)

    Returns a list of attached DISK Volumes. This function requests the 
    information directly from the Hercules system and requires system 
    administrator rights. It works only if the host system is MVS3.8.

    :param option: One of `FMTLIST`, `LIST`, or `STEM`

    If `FMTLIST` is specified the output is presented in an FMTLIST screen. `LIST`
    provides the result in the normal output device. `STEM` returns it in the 
    stem `VOLUMES.x`.      

.. function:: VTOC(volume[,LIST/FMT/])

    Produces a list of entries residing on the volume. If LIST is specified 
    it is printed, FMT produces an FMTLIST screen displaying the content of 
    the volume. If no option is defined the output is returned in the stem 
    VTOC.

.. function:: PRINT(parameter)	

    Manages printing into a SYSOUT class. The page size is 60 lines, line 
    size is 132. If a new line exceeds the page size a page break occurs and
    the title line is printed. 

    If a label `$PRINT_header:` is defined in your calling REXX script, it is 
    called a call-back. Additional lines can be output there (using the PRINT 
    command) as heading lines (appearing after each page break)     

    - `PRINT $ONTO,sysout-class` Define and open PRINT stream              
    - `PRINT <action,>line-to-print` print line (according to print action)    
    - `PRINT $TITLE,title-line` define title line, printed on a new page    
    - `PRINT $PAGE` skip to the next page, print page headers     
    - `PRINT $BANNER,text` PRINT a banner page                         
    - `PRINT $CLOSE` close print stream                        

    where `action` is one of:
    
    - `$SKIP` add an empty line and print                  
    - `$NOSKIP` print on the same line (no line feed)         
    - `$BOLD` print bold line (print it twice)          
