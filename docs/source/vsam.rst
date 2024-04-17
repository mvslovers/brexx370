VSAM User's Guide
=================

The VSAM User's Guide contains the BREXX functions to access VSAM KSDS 
files.

The VSAM Interface is based on Steve Scott's VSAM API: 
https://sourceforge.net/projects/rxvsam/ .

We gratefully thank Steve for allowing us the integration in BREXX and 
his support to achieve it.

The underlying VSAM API allows full support for KSDS, RRDS and ESDS, but 
we focused just on the KSDS functionality, so there is no support for 
RRDS and ESDS. If this limitation is lifted in the future depends on 
user requests.

Integration of the VSAM Interface in BREXX
------------------------------------------

We decided to integrate the interface as host commands rather than BREXX 
functions. It is now similar to the EXECIO host command for sequential
datasets. The host command name is VSAMIO. Host commands are typically 
enclosed in quotes or double-quotes.

Example:

`"VSAMIO OPEN VSIN (UPDATE"`

Limitations/Restrictions
~~~~~~~~~~~~~~~~~~~~~~~~

The implementation has only tested with UNIQUE cluster definitions, not
with type SUBALLOCATION (which requires in MVS 3.8 a DEFINE SPACE and 
DEFINE VSAM catalogue definition). The UNIQUE specification does not 
allow the REUSE CLUSTER definition, which would be necessary for the 
initial loading of an empty KSDS dataset.

Initialising empty VSAM Files
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A program cannot directly process an empty VSAM file it must be 
initialised first. The procedure to achieve this is to use IDCAMS REPRO
to write a “null”-record into it. After this exercise, the VSAM file
can be updated by BREXX/370 with normal VSAM Write commands from BREXX.

Key of Records
~~~~~~~~~~~~~~

The key must be part of the record, and nevertheless, you must 
additionally specify the key in the following commands:

- `"VSAMIO READ ddname (KEY key ... “`
- `"VSAMIO LOCATE ddname (KEY key ... “`
- `"VSAMIO WRITE ddname (KEY key ... “`
- `"VSAMIO DELETE ddname (KEY key ... “`

The key of a record must consist of a sequence of contiguous non-space 
characters; this means blanks are not allowed being part of a key. This 
limitation might be lifted in one of the forthcoming releases.

You can easily convert spaces in a key with the TRANSLATE function:
`key=translate(key,'_',' ')`

Return Codes
~~~~~~~~~~~~

Each VSAMIO command call returns two return codes:

- **RC** the usual return code, containing:

  +--------------+--------------------------------------------------------------------------------------------+
  | Return Code  | Description                                                                                |
  +==============+============================================================================================+
  | 0            | call was successful                                                                        |
  +--------------+--------------------------------------------------------------------------------------------+
  | 4            | call was not successful and ended with warnings, typically in record-not-found Situations  |
  +--------------+--------------------------------------------------------------------------------------------+
  | 8            | call ended with errors                                                                     |
  +--------------+--------------------------------------------------------------------------------------------+

- **RCX** The extended VSAM Return code, and it consists of a 9 
  character field with the following format: `rrr-vvvvv` **rrr** is the 
  function return code, **vvvvv** is the VSAM return code

You can look up the details of the extended VSAM return code in IBM's MVS System Messages under
message IDC3351I.

System Abend A03
~~~~~~~~~~~~~~~~

The RXVSAM API runs as independent subtask within the address space. 
By the end of the REXX Script, an automatic shutdown of the subtask is 
performed. If the REXX script unexpectedly terminates, you possibly see 
a SYSTEM ABEND A03, which means the main task (BREXX) has been 
terminated and there is still a subtask in the background active. MVS 
forces the ABEND of the subtask with A03. There are no further actions
required; there is no impact on the system or the VSAM datasets.

Random and Sequential Access
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The used VSAM IO module distinguishes two access methods:

- Random Access always requires a key to read/write/delete a record
- Sequential Access allows to position to a particular record and 
  reads/write/delete records from there sequentially

Both methods can be used concurrently, but it is essential to understand 
that they do not mutual interfere. Having read a record with random 
access does not allow to read from this record sequentially the next 
records, as this is sequential access. But you can perform a LOCATE 
command with a key and continue the read from there sequentially.

VSAM Dataset reference
~~~~~~~~~~~~~~~~~~~~~~

Each VSAMIO command uses the DDNAME as a reference to the VSAM dataset. 
It must be pre-allocated via a JCL DD Statement or a TSO ALLOCATE 
command.

There are no plans to allow a dataset name (DSN) instead of the DDNAME!

REXX VSAM Debugging
~~~~~~~~~~~~~~~~~~~

By using BREXXDBG as the BREXX interpreter you can produce additional
log entries in the operator's console, as well as in the spool output of 
a batch job:

Example:

.. code-block:: JCL
    :linenos:
        
    //BRXVSMKY JOB CLASS=A,MSGCLASS=H,REGION=8192K,
    //         NOTIFY=&SYSUID
    //*
    //* -----------------------------------------------------------------
    //* READ STUDENT VSAM FILE VIA KEY
    //* -----------------------------------------------------------------
    //*
    //BATCH EXEC RXTSO,BREXX='BREXXDBG',
    //         EXEC='$STUDENK',
    //         SLIB='BREXX.V2R5M1.SAMPLES'
    //SYSPRINT DD SYSOUT=*,
    //         DCB=(RECFM=FBA,LRECL=133,BLKSIZE=133)
    //SYSUDUMP DD SYSOUT=*
    //

Results::

    07.35.01 JOB 1466 $HASP373 PEJRXKEY STARTED - INIT 1 - CLASS A - SYS
    TK4-
    07.35.01 JOB 1466 IEF403I PEJRXKEY - STARTED - TIME=07.35.01
    07.35.02 JOB 1466 +VSAMIO - STUDENTM ACCESS TRACE, REQUEST = OPEN
    07.35.02 JOB 1466 +VSAMIO - KEY=NONE
    07.35.02 JOB 1466 +VSAMIO - STUDENTM ACCESS TRACE, REQUEST = READU
    07.35.02 JOB 1466 +VSAMIO - KEY=X"C1D5C4C5D9E2D6D55EC2C5D56D6D6D6D6D6D6D6D6D6D6
    07.35.02 JOB 1466 +VSAMIO - STUDENTM ACCESS TRACE, REQUEST = READU
    07.35.02 JOB 1466 +VSAMIO - KEY=X"C1D5C4C5D9E2D6D55EC7C1C2D9C9C5D36D6D6D6D6D6D6
    07.35.02 JOB 1466 +VSAMIO - STUDENTM ACCESS TRACE, REQUEST = READU
    07.35.02 JOB 1466 +VSAMIO - KEY=X"C2C1D3C4E6C9D55EC1D9D3C5D5C56D6D6D6D6D6D6D6D6
    07.35.02 JOB 1466 +VSAMIO - STUDENTM ACCESS TRACE, REQUEST = READU
    07.35.02 JOB 1466 +VSAMIO - KEY=X"E2E3C5D7C8C5D5E2D6D55ED7C1E3D9C9C3C9C16D6D6D6
    07.35.02 JOB 1466 +VSAMIO - STUDENTM ACCESS TRACE, REQUEST = CLOSE
    07.35.02 JOB 1466 +VSAMIO - KEY=NONE
    07.35.02 JOB 1466 IEFACTRT - Stepname Procstep Program  Retcode
    07.35.02 JOB 1466 PEJRXKEY   BATCH    EXEC     IKJEFT01 RC= 0000
    07.35.02 JOB 1466 IEF404I PEJRXKEY - ENDED - TIME=07.35.02
    07.35.02 JOB 1466 $HASP395 PEJRXKEY ENDED

VSAM Commands in BREXX
----------------------

OPEN VSAM Dataset
~~~~~~~~~~~~~~~~~

`"VSAMIO OPEN ddname ([READ/UPDATE] "`

Example::

    "VSAMIO OPEN VSIN1 (READ"
    "VSAMIO OPEN VSIN2 (UPDATE"

VSIN1 is opened in reading mode, VSIN2 in UPDATE mode.

READ with KEY
~~~~~~~~~~~~~

Access-Type: Random::

    "VSAMIO READ ddname (KEY key-to-read VAR rexx-variable"

If you want to update the record, you must prepare for it by adding the 
UPDATE keyword::

    "VSAMIO READ ddname (KEY key-to-read UPDATE VAR rexx-variable"

The UPDATE keyword requires a File OPEN with UPDATE

Example::

    "VSAMIO READ VSIN1 (KEY "key1" VAR record1"
    "VSAMIO READ VSIN2 (KEY "key2" UPDATE VAR record2"

Read a record with key1/key2 (contained in a rexx variable) into the 
rexx variable record1/record2

READ NEXT
~~~~~~~~~
Access-Type: Sequential

After positioning with LOCATE to a particular record, you can read the 
next records sequentially. If no LOCATE has been previously performed, 
the first record is read.::

    "VSAMIO READ ddname (NEXT VAR rexx-variable"

If you want to update the record, you must prepare for it by adding the
UPDATE keyword::

    "VSAMIO READ ddname (NEXT UPDATE VAR rexx-variable"

The UPDATE keyword requires a File OPEN with UPDATE

Example::

    "VSAMIO LOCATE VSIN (KEY "key
    Do until rc>0
        "VSAMIO READ VSIN (NEXT VAR record"
        Say record
    End

Position to record key (contained in a rexx variable) and read all 
records from there into rexx variable record

LOCATE position to a certain record
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Access-Type: Sequential

Position the record pointer in front of the provided key or a key 
prefix::

    "VSAMIO LOCATE ddname (KEY [key-to-position/key-prefix]"

To subsequentially read the next records a READ NEXT is required. After 
a successful read, the position is shifted to the next record position.

Example refer to READ NEXT.

WRITE KEY
~~~~~~~~~

Access-Type: Random

To update a record, it must be priorly read with a READ KEY, regardless 
whether the record exists. If the record doesn't exist, it is inserted::
    
    "VSAMIO WRITE ddname (KEY key-to-write VAR rexx-variable"

Example::

    "VSAMIO READ VSIN (KEY "key" UPDATE VAR CURRENT"
    say 'READ 'rc' Extended RC 'rcx
    "VSAMIO WRITE VSIN (KEY "key" VAR RECORD"
    if rc<>0 then say key' Error during Insert'
    else say inkey' Record inserted'
    say 'WRITE 'rc' Extended RC 'rcx

To insert a new record; the READ is mandatory to verify if a record is
already defined.

WRITE NEXT
~~~~~~~~~~

Access-Type: Sequential
To update a record, it must be priorly read with a READ NEXT.::

    "VSAMIO WRITE ddname (NEXT VAR rexx-variable"

DELETE KEY
~~~~~~~~~~

Access-Type: Random

To delete an existing record.::

    "VSAMIO DELETE ddname (KEY key-to-delete "

Example::

    "VSAMIO OPEN VSERR (UPDATE"
    say 'OPEN 'rc' Extended RC 'rcx
    "VSAMIO DELETE VSERR (KEY 0000000"
    say 'Delete Dummy Record 'rc' Extended RC 'rcx

DELETE NEXT
~~~~~~~~~~~

Access-Type: Sequential

To delete an existing record, it must be priorly read with a READ 
NEXT.::
    
    "VSAMIO DELETE ddname (NEXT "

Example::

    "VSAMIO LOCATE VSIN (KEY "prefix
    say "LOCATE "rc
    say "Extended RC "rcx
    do forever
        "VSAMIO READ VSIN (NEXT UPDATE VAR INREC"
        if rc<>0 then leave
        say "record='"INREC"' RC "rc" Extended RC "rcx
        key=substr(inrec,1,8)
        "VSAMIO DELETE VSIN (NEXT "
        if rc=0 then reci=reci+1
        say 'DELETE RC 'rc' Extended RC 'rcx
    end

CLOSE
~~~~~

`"VSAMIO CLOSE ddname "`

To close all open VSAM datasets you can also use `"VSAMIO CLOSE ALL "`

Example::
    
    "VSAMIO CLOSE VSERR"

BREXX VSAM Example
------------------

The installation file contains in the dataset `BREXX.<version>.JCL` a 
working example of a student database using fictitious student entries, 
containing first name, family name, birth date, the field of study, 
address.

You can submit the REXX scripts in batch out of `BREXX.<version>.JCL`

+-----------+----------------------------------------------------+
| Member    | Description                                        |
+===========+====================================================+
| STUDENTC  | Creates the VSAM Cluster definition                |
+-----------+----------------------------------------------------+
| STUDENTI  | Inserts the student records into the VSAM dataset  |
+-----------+----------------------------------------------------+
| STUDENTK  | Read the VSAM dataset with KEYs                    |
+-----------+----------------------------------------------------+
| STUDENTN  | Read the VSAM dataset sequentially                 |
+-----------+----------------------------------------------------+

The REXX scripts are stored in `BREXX.<version>.SAMPLES`

+-----------+---------------------------------------------------+
| Member    | Description                                       |
+===========+===================================================+
| @STUDENI  | insert student records                            |
+-----------+---------------------------------------------------+
| @STUDENK  | read student records by key                       |
+-----------+---------------------------------------------------+
| @STUDENL  | Query student records by using formatted screens  |
+-----------+---------------------------------------------------+
| @STUDENN  | read student records sequentially                 |
+-----------+---------------------------------------------------+

The following example illustrates the definition and population of a 
VSAM dataset using BREXX.

1. Define a VSAM Cluster: Define a new VSAM Cluster and import a 
   “Null”-Record, submit the job `STUDENTC`
2. Sample BREXX Program to update the VSAM Dataset: run the script 
   `@STUDENI`
3. JCL Upate VSAM Dataset: The BREXX Program is updating the new VSAM 
   Dataset. Submit the job `STUDENTI`
4. Using a Formatted Screen Application to Query the Student File:
   `TSO RX "BREXX.<version>.SAMPLE(@SUTDENTL)"`