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


.. function:: SYSVAR(request-type)

    TSO-only function to retrieve certain TSO runtime information.
    Available request-types:

    +---------+-----------------------------------------------------------------------+
    | Type    | Description                                                           |
    +=========+=======================================================================+
    |SYSUID   | UserID                                                                |
    +---------+-----------------------------------------------------------------------+
    |SYSPREF  | system prefix of current TSO session (typically hlq of userid)        |
    +---------+-----------------------------------------------------------------------+
    |SYSENV   | FORE/BACK/BATCH forground/background TSO execution, or plain batch    |
    +---------+-----------------------------------------------------------------------+
    |SYSISPF  | ISPF active 1, not active 0                                           |
    +---------+-----------------------------------------------------------------------+ 
    |SYSTSO   | TSO active 1, not active 0                                            |
    +---------+-----------------------------------------------------------------------+
    |SYSAUTH  | script runs in authorised mode (1), 0 not authorised                  |
    +---------+-----------------------------------------------------------------------+
    |SYSCP    | returns the host-system which runs MVS38j. It is either MVS or VM/370 |
    +---------+-----------------------------------------------------------------------+
    |SYSCPLVL | shows the release of the host-system                                  |
    +---------+-----------------------------------------------------------------------+
    |SYSHEAP  | allocated heap storage                                                |
    +---------+-----------------------------------------------------------------------+
    |SYSSTACK | allocated stack storage                                               |
    +---------+-----------------------------------------------------------------------+
    |RXINSTRC | BREXX Instruction Counter                                             |
    +---------+-----------------------------------------------------------------------+

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

