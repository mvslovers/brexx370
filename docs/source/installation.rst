Installation Guide
==================

Introduction
------------

This document covers the installation process of BREXX/370.


BREXX/370 is provided as-is, please test carefully in test systems only!

BREXX/370 is not the same as IBM's REXX; there are many similarities, 
but also differences, especially when using MVS-specific functions.

The next TK4- Update 9 release contains BREXX/370.

Prerequisites
-------------

MVS TK4- / MVS/CE
~~~~~~~~~~~~~~~~~

This version of BREXX/370 has been developed and tested within Jürgen 
Winkelmann's TK4- (https://wotho.ethz.ch/tk4-/). It also comes 
pre-installed in MVS/CE (https://github.com/MVS-sysgen/sysgen). It may 
work in other versions of MVS, such as https://www.jaymoseley.com/hercules/installMVS/iSYSGENv7.htm
but can't be guaranteed.


Non MVS TK4- Installation
~~~~~~~~~~~~~~~~~~~~~~~~~~
Users who run a non TK4- MVS installation should pay attention to the 
following differences:

XMIT RECEIVE STEPLIB DD Statement
+++++++++++++++++++++++++++++++++

It might be necessary to add a STEPLIB DD statement to locate the 
library containing the RECV370::
    
    //RECV370
    //STEPLIB
    EXEC PGM=RECV370
    DD
    DSN=library

Please add it to the Jobs where needed.

IN TK4- RECV370 is contained in a system library; therefore, a STEPLIB 
DD statement is not needed!

REGION SIZE
+++++++++++

For non-TK4- MVS versions it might be necessary to reduce the REGION 
size parameter to 4 MB or 6MB, as MVS may reject the REGION=8192K\
parameter with the message: "REGION UNAVAILABLE, ERROR CODE=20". TK4- 
supports 8MB regions size::
    
    //stepname EXEC PGM=xxxxx,REGION=6144K
    ISPF support (optional)

BREXX/370 also supports Wally McLaughlin's version of ISPF and its 
contained SPF panels.

Recommendations
~~~~~~~~~~~~~~~

We recommend testing BREXX/370 in an isolated test system to avoid any 
impact on your current system. To achieve this, you can easily copy the
entire Hercules/MVS directory to another location and install BREXX/370
there.

Preparation of your target MVS38J System
----------------------------------------

BREXX Catalogue
~~~~~~~~~~~~~~~

Make sure that your MVS system has a BREXX Alias pointing to a user 
catalogue defined in the master catalogue. To determine it, run the 
command::

    listcat entries('brexx') all

The result must look like this::

     ALIAS --------- BREXX                   
          IN-CAT --- SYS1.VSAM.MASTER.CATALOG
          HISTORY                            
            RELEASE----------------2         
          ASSOCIATIONS                       
            USERCAT--UCPUB001                
    
If the BREXX Alias is not defined, add it:

.. code-block:: jcl
   :linenos:

   //ADDBREXX EXEC PGM=IDCAMS
   //SYSPRINT DD SYSOUT=* 
   //SYSIN    DD *
     DEFINE ALIAS (NAME(BREXX) RELATE(your-user-catalog))

If the submitted job is not running, it might be necessary to enter the
password of the master-catalogue in the MVS console (in TK4- not 
needed).

If you omit this step, all BREXX data sets are catalogued in the Master
Catalog. In this case, it may require the use of the Master Catalog
password during the catalogue process. If you are running TK4- you do 
not see such requests as RAKF is providing the access authorisation of
the Master Catalog, which therefore is not password protected. In the
default TK4- configuration, only users HERC01 and HERC02 are authorised
to update the master catalogue.

.. important:: All JCLs in the installation and sample library contain 
    now a `NOTIFY=&SYSUID` parameter in the JOB card. If the patch, to
    resolve it during the Submit process by the current user-id, is not
    applied, you need to change &SYSUID to your userid, or remove it
    from the JOB card!

    The patch can be found on: http://prycroft6.com.au/vs2mods/index.html#zp60034

Make sure that dataset `BREXX.V2R5M1.INSTALL` is not already catalogued
from a previous run. It is the recommended dataset name and will be 
created during the receiving process of RECV370. 

.. important:: If a previous version of this dataset name is still
    catalogued, the new version ends up as not catalogued: with a 
    `NOT CATLG 2` message! The Job output does not reveal by a ccod. Any
    later job which is accessing `BREXX.V2R5M1.INSTALL` will use the old
    version of the dataset.

Installation
------------

Step 0 - Unzip BREXX/370 Installation File
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ZIP installation file consists of several files:

- BREXX370_Users_guide.pdf - This user guide
- BREXX370_V2R5M1.XMIT - XMIT File containing BREXX modules and 
  Installation JCL

Step 1 - Upload XMIT File
~~~~~~~~~~~~~~~~~~~~~~~~~

Use the appropriate upload facility of your terminal emulation. Such as
IND$FILE or using `rdrprep` and inline JCL.

The file created during upload must have `RECFM FB` and `LRECL 80`. If
the DCB does not match, the subsequent unpacking process fails.

Step 2 - Unpack XMIT File
~~~~~~~~~~~~~~~~~~~~~~~~~

Unpack the XMIT file with an appropriate JCL. If you don't have one you
can use the following sample, just cut and paste it in one of your
JCL libraries. 

.. code-block:: jcl
    :linenos:
    :emphasize-lines: 7,10,13,14

    //BRXXREC JOB 'XMIT RECEIVE',CLASS=A,MSGCLASS=H
    //* ------------------------------------------------------------
    //* RECEIVE XMIT FILE AND CREATE DSN OR PDS
    //* ------------------------------------------------------------
    //RECV370  EXEC PGM=RECV370,REGION=8192K
    //RECVLOG  DD SYSOUT=*
    //XMITIN   DD DSN=HERC01.BREXX.version.XMIT,DISP=SHR
    //SYSPRINT DD SYSOUT=*
    //SYSUT1   DD DSN=&&XMIT2,
    //         UNIT=3390,
    //         SPACE=(TRK,(300,60)),
    //         DISP=(NEW,DELETE,DELETE)
    //SYSUT2   DD DSN=BREXX.version.INSTALL,
    //         UNIT=3390,
    //         SPACE=(TRK,(300,60,20)),
    //         DISP=(NEW,CATLG,CATLG)
    //SYSIN DD DUMMY

- **HERC01.UPLOAD.XMIT** represents the uploaded XMIT File - please change
  it accordingly to the name you have chosen during the upload process.

- **BREXX.V2R5M1.INSTALL** is the name of the unpacked library (created 
  during the UNPACK process). It is recommendable to remain with this 
  DSN as it is used in later processes. **Make sure there is no previous
  version of this PDS catalogued.**

.. important:: If you use a different JCL to unpack the XMIT file, use 
  `UNIT=3390` in the JCL. The unit type 3390 was the only reliably UNIT
  that ran in all tested TK4- environments. Other units may sometimes
  lead to various errors during the unpacking process.

Once the submitted job has successfully unpacked the XMIT file into the
target PDS, you can proceed with STEP 3. The created library 
`BREXX.version.INSTALL` contains all JCL to pursue with unpacking and
installing.

The next steps make usage of the unpacked library (in this example
`BREXX.V2R5M1.INSTALL`)

Please run the JCL in the given order (refer to the **Step x** reference
in the table). Submit Step 3 as the first JCL of the installation 
sequence. Entries without a Step reference are used from the JCLs as
input datasets.

+-----------+----------------------------------------------------+---------------+
| Filename  | Description                                        | Used in Step  |
+===========+====================================================+===============+
| $CLEANUP  | Cleanup: Remove unnecessary installation files     | -> Step 6     |
+-----------+----------------------------------------------------+---------------+ 
| $INSTALL  | Install BREXX/370                                  | -> Step 4     |
+-----------+----------------------------------------------------+---------------+ 
| $README   | Read me file                                       |               |
+-----------+----------------------------------------------------+---------------+ 
| $TESTRX   | Test job to verify the BREXX/370 installation      | -> Step 5     |
+-----------+----------------------------------------------------+---------------+ 
| $UNPACK   | Unpack subsequent libraries                        | -> Step 3     |
+-----------+----------------------------------------------------+---------------+ 
| BUILD     | Contains BREXX/370 Version and date and XMIT date  |               |
+-----------+----------------------------------------------------+---------------+ 
| CMDLIB    | xmit packed command proc                           |               |
+-----------+----------------------------------------------------+---------------+ 
| SAMPLES   | xmit packed BREXX commands                         |               |
+-----------+----------------------------------------------------+---------------+ 
| JCL       | xmit packed example JCL                            |               |
+-----------+----------------------------------------------------+---------------+ 
| LINKLIB   | xmit packed BREXX Load library                     |               |
+-----------+----------------------------------------------------+---------------+ 
| PROCLIB   | xmit packed BREXX JCL procedures                   |               |
+-----------+----------------------------------------------------+---------------+ 
| RXINSTDL  | Internal CLIST used during Installation            |               |
+-----------+----------------------------------------------------+---------------+ 
| RXLIB     | xmit packed include library                        |               |
+-----------+----------------------------------------------------+---------------+ 

Activating the new BREXX V2R5M1 Release
+++++++++++++++++++++++++++++++++++++++

The next steps describe how to enable your new BREXX Release. In 
summary, you must run the following jobs out of the above library in 
the listed sequence:

- **$UNPACK** - mandatory
- **$INSTALL** - mandatory
- **$TESTRX** - optional, recommended
- **$CLEANUP** - optional

See details in the step descriptions below.

Step 3 - Submit $UNPACK JCL of the unpacked Library
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In the unpacking process, the contained installation files will be 
expanded into different partitioned datasets.


.. important:: Before submitting the `$UNPACK` JCL, the XMITLIB 
  parameter must match the dataset name used in the expand JCL of Step2.


If you followed the dataset naming recommendations it is: 
**BREXX.V2R5M1.INSTALL** and no change is required.

.. code-block:: jcl
    :linenos:
    :emphasize-lines: 16
    
    //BRXXUNP JOB 'XMIT UNPACK',CLASS=A,MSGCLASS=H,NOTIFY=&SYSUID         
    //*                                                                   
    //*RELEASE   SET 'V2R5M1'                                             
    //* ... BREXX          Version V2R5M1 Build Date 6. May 2022          
    //* ... INSTALLER DATE 06/05/2022 16:31:35                            
    //* ------------------------------------------------------------------
    //* UNPACK XMIT FILES INTO INSTALL LIBRARIES                          
    //*   *** CHANGE XMITLIB= TO THE EXPANDED XMIT LIBRARY OF INSTALLATION
    //* ------------------------------------------------------------------
    //*           ---->   CHANGE XMITLIB TO YOUR UNPACKED XMIT FILE  <----
    //*                          XXXXXXXXXXX                              
    //*                         X     X     X                             
    //*                        X      X      X                            
    //*                       X       X       X                           
    //*                      X        X        X                          
    //XMITLOAD PROC XMITLIB='BREXX.V2R5M1.INSTALL',                       
    //         HLQ='BREXX.V2R5M1',     <-- DO NOT CHANGE HLQ ----         
    //         MEMBER=                                                    

.. important:: If the job does not run and waits, check with option 3.8
  the status. It is most likely ”WAITING FOR DATASETS”. The simplest 
  method to resolve this is to LOGOFF and re-LOGON to your TSO session.

After completion of the `$UNPACK` JCL the following new Libraries are
available:

+--------------------------+----------------------------------------+
| Dataset                  | Description                            |
+==========================+========================================+
| **BREXX.V2R5M1.CMDLIB**  | REXX commands are directly executable  |
+--------------------------+----------------------------------------+
| **BREXX.V2R5M1.SAMPLE**  | REXX Samples scripts                   |
+--------------------------+----------------------------------------+
| **BREXX.V2R5M1.JCL**     | REXX Job Control                       |
+--------------------------+----------------------------------------+
| **BREXX.V2R5M1.LINKLIB** | BREXX Load Modules                     |
+--------------------------+----------------------------------------+
| **BREXX.V2R5M1.APFLLIB** | BREXX authorised Load Modules          |
+--------------------------+----------------------------------------+
| **BREXX.V2R5M1.PROCLIB** | BREXX JCL Procedures                   |
+--------------------------+----------------------------------------+
| **BREXX.V2R5M1.RXLIB**   | BREXX include Libraries                |
+--------------------------+----------------------------------------+

The unpacking process removes any old version of the above libraries, 
before the creation of the new version. If no old version of these
libraries is available, the delete steps end with `RC=4`, as well as the
job ends with `RC=4`. **Ignore these errors**, if the individual 
unpack steps return with `RC=0`. Therefore please carefully check the 
output of this job.

.. important:: Before you install BREXX, you must decide either on the 
  normal BREXX installation or the authorised BREXX installation.

With the authorised version you can call from BREXX utilities as 
IEBGENER, IEBCOPY, NJE38, etc. which run in authorised mode. This 
requires that the environment in which you start BREXX is authorised, 
meaning Wally Mclaughlin's ISPF, or RFE must be authorised. 
Plain TSO is already authorised.

Both installations are copied into the same partitioned datasets; 
they are, therefore, mutually exclusive!

If the standard installation is sufficient, continue with Step 4 If you
plan to use the authorised, continue with Step 4A. In this case, the
MVS authorisation table needs to be updated as well.

Step 4 - Submit $INSTALL JCL for the Standard Installation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The **$INSTALL** JCL copies all member from the following two 
partitioned datasets into the appropriate SYS2 datasets. 

- BREXX.LINKLIB -> SYS2.LINKLIB
- BREXX.PROCLIB -> SYS2.PROCLIB

All these members are BREXX/370 specific and do not conflict with 
existing members. Members of the system libraries remain untouched.

.. important:: Please log off and re-login to your TSO session before
  performing any online testing; this enforces the new loading of 
  modules used during the testing, else you might see an 0C4. In rare
  situations, the installation of the BREXX Linklib members may create
  a new dataset extent in SYS2.LINKLIB. In this case, you must also
  restart your TK4- MVS session.

**Continue with STEP 5**

Step 4A- Submit $INSTAPF JCL for the Authorised Installation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The `$INSTPAPF` JCL copies all member from the following two 
partitioned datasets into the appropriate SYS2 datasets. 

- BREXX.LINKLIB -> SYS2.LINKLIB
- BREXX.PROCLIB -> SYS2.PROCLIB

All these members are BREXX/370 specific and do not conflict with 
existing members. Members of the system libraries remain untouched.

To authorise the Modules to change the following Modules::
  
  SYS1.UMODSRC(IKJEFTE2)
  SYS1.UMODSRC(IKJEFTE8)

Add the BREXX modules to the sources:

.. code-block:: hlasm
    :linenos:

         DC    C'BREXX   '             BREXX/370
         DC    C'REXX    '             BREXX/370
         DC    C'RX      '             BREXX/370

To activate the changes submit the Jobs:

- SYS1.UMODCNTL(ZUM0001)
- SYS1.UMODCNTL(ZUM0014)

Aftewards you **must** restart your MVS:

- Shut down your MVS
- Re-IPL your job with the CLPA option
- Shut Down MVS again
- Perform normal IPL

.. important:: If you run Wally McLaughlin’s ISPF the ISPF libraries
  must be authorised, otherwise calling a rexx from within ISPF will
  abend (usually S306).

Step 5 - Submit $TESTRX JCL of the unpacked Library
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Submit `$TESTRX` start a test to verify the installation of BREXX/370.
All steps should return with RC=0

Step 6 - Submit $CLEANUP JCL of the unpacked Library
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The $CLEANUP job removes all unnecessary installation files they are no
longer needed, as they were merged into the appropriate SYS2.xxx 
library.

- BREXX.V2R5M1.LINKLIB
- BREXX.V2R5M1.PROCLIB

You may also wish to remove the uploaded XMIT File, which was used for
the first unpack process.

Step 7 - ADD BREXX Libraries into TSO Logon
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To run BREXX with its shortcut RX, REXX, BREXX you must allocate the
BREXX libraries into your Logon procedure. There are several ways to
achieve this. The easiest and recommended method for TK4 users is to 
add lines into `SYS1.CMDPROC(USRLOGON)`. Non TK4 installation may use 
different libraries. MVS/CE and Jay Moseley sysgen use 
`SYS1.CMDPROC(TSOLOGON)`.

.. code-block:: clist
    :linenos:
    
    /* ALLOCATE RXLIB IF PRESENT */
    IF &SYSDSN('BREXX.V2R5M1.RXLIB') EQ &STR(OK) THEN DO    
      FREE FILE(RXLIB)
      ALLOC FILE(RXLIB) +
        DSN('BREXX.V2R5M1.RXLIB') SHR

    /* ALLOCATE SYSEXEC TO SYS2 EXEC */
    IF &SYSDSN('SYS2.EXEC') EQ &STR(OK) THEN DO     
     FREE FILE(SYSEXEC)                             
     ALLOC FILE(SYSEXEC) DSN('SYS2.EXEC') SHR       
    END        

    /* ALLOCATE SYSUEXEC TO USER EXECS */           
    IF &SYSDSN('&SYSUID..EXEC') EQ &STR(OK) THEN DO 
     FREE FILE(SYSUEXEC)                            
     ALLOC FILE(SYSUEXEC) DSN('&SYSUID..EXEC') SHR  
    END                                 

insert the clist above before the line `%STDLOGON` in 
`SYS1.CMDPROC(USRLOGON)`.

**The update of the TSO Logon CLIST is an entirely manual process!** 
Please take a backup of `USRLOGON` CLIST first to allow a recovery in 
case of errors!

.. important::  Users who upgrade from a previous release of BREXX need
  to update the logon clist and replace the RXLIB allocation with the
  current dataset name: BREXX.V2R5M1.RXLIB.

Step 8 - Your Tests
~~~~~~~~~~~~~~~~~~~

It is advised to LOGOFF and LOGON again to your system to make sure that
the newly installed modules become active.

Now it's your turn to test BREXX/370! Please be advised BREXX/370 is
not z/OS REXX, so you might miss some functions but find also functions
not available in the "original".

Step 9 - Remove old BREXX Libraries (optional)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you had a previous BREXX/370 version installed and your tests ran
successfully, you can remove the libraries of the earlier BREXX version,
for example, V2R2M0.

+--------------------------+--------------------------+
| Dataset                  | Description              |
+==========================+==========================+
| **BREXX.V2R2M0.CMDLIB**  | REXX commands            |
+--------------------------+--------------------------+
| **BREXX.V2R2M0.SAMPLE**  | REXX Samples scripts     |
+--------------------------+--------------------------+
| **BREXX.V2R2M0.JCL**     | REXX Job Control         |
+--------------------------+--------------------------+
| **BREXX.V2R2M0.LINKLIB** | BREXX Load Modules       |
+--------------------------+--------------------------+
| **BREXX.V2R2M0.PROCLIB** | BREXX JCL Procedures     |
+--------------------------+--------------------------+
| **BREXX.V2R2M0.RXLIB**   | BREXX include Libraries  |
+--------------------------+--------------------------+

If you upgraded from the very first BREXX/370 version, you can remove 
the following libraries:

+-------------------+--------------------------+
| Dataset           | Description              |
+===================+==========================+
| **BREXX.CMDLIB**  | REXX commands            |
+-------------------+--------------------------+
| **BREXX.SAMPLE**  | REXX Samples scripts     |
+-------------------+--------------------------+
| **BREXX.JCL**     | REXX Job Control         |
+-------------------+--------------------------+
| **BREXX.LINKLIB** | BREXX Load Modules       |
+-------------------+--------------------------+
| **BREXX.PROCLIB** | BREXX JCL Procedures     |
+-------------------+--------------------------+
| **BREXX.RXLIB**   | BREXX include Libraries  |
+-------------------+--------------------------+

Additional Settings (optional)
------------------------------

If you want to communicate with the control program of the host system
(either Hercules or VM) you can do so, by running::

  ADDRESS COMMAND 'CP cp-parameter ...'

For VM you need to use a valid CP command. Example::

  ADDRESS COMMAND 'CP QUERY TIME'

If your system is running within Hercules your CP commands are routed 
to Hercules and need to be Hercules commands. Example::
  
  ADDRESS COMMAND 'CP DEVLIST'

To communicate with Hercules you need to enable the DIAG8 commands
`DIAG8CMD ENABLE` in the Hercules console. In TK4- systems it is
already enabled. If it is not enabled and you run an 
`ADDRESS COMMAND “CP command”` BREXX will abend typically with an 0C6.

BREXX Usage
===========

There are JCL Procedures delivered, which facilitate the test and 
execution of REXX scripts. The installation process merges them 
into `SYS2.PROCLIB`. 

The delivered RXLIB PDS contains several REXX functions, which are 
usable as if they were a BREXX internal function. 

The delivered JCL procedures allocate the RXLIB library, and it is 
recommended to add it also into the TSO Logon procedures (Step 8).

TSO online
----------

Executing rexx scripts in TSO uses either `RX` or `REXX`. You can either
call scripts from dataset libraries or fully qualified dataset names.

To call a script from a library::

  RX rexx-script-name
  REXX rexx-script-name

BREXX performs all necessary allocations. It is advised to add a 
user-specific REXX library, naming convention: `&SYSUID.EXEC` (RECFM=VB,
LRECL255). If available, the REXX-script searches path starts from 
there. The REXX library search sequence is:

1. SYSUEXEC - typically &SYSUID.EXEC
2. SYSUPROC - (optional)
3. SYSEXEC - (optional)
4. SYSPROC - (optional)

At least one of these libraries needs to be pre-allocated during the 
TSO logon process. It is not mandatory to have all of them allocated.
It depends on your planned REXX development environment. The 
allocations may consist of concatenated datasets. If you followed the 
instructions above then SYSEXEC is assigned to `SYS2.EXEC` and SYSUEXEC
is assigned to `&SYSUID.EXEC`.


Alternatively, you can specify a fully qualified dataset-name and
member name (if the dataset is a PDS)::
  
  RX 'dataset-name(rexx-script-name)'
  REXX 'dataset(rexx-script-name)'

TSO Batch (start REXX JCL Procedure)
------------------------------------

There is a JCL Procedure defined that allows you to run REXX Scripts in
a TSO Batch environment. The Procedure performs all necessary BREXX and
TSO allocations.

Some ADDRESS TSO commands as ALLOC/FREE are supported.

.. code-block:: jcl
    :linenos:
    :emphasize-lines: 6
    
    //DATETEST JOB CLASS=A,MSGCLASS=H,REGION=8192K,NOTIFY=&SYSUID
    //*
    //* ------------------------------------------------------------------*
    //* TEST REXX DATE AS TSO BATCH
    //* ------------------------------------------------------------------*
    //REXX EXEC RXTSO,EXEC='DATE#T',SLIB='BREXX.SAMPLES'

- **EXEC=** defines the rexx script to run
- **SLIB=** defines the library/partitioned dataset containing the 
  rexx script defined in **EXEC**

Additionally, you can add a `P='input-parameters'` JCL Parameter field,
if your rexx receives input parameters.

Plain Batch (start REXX JCL Procedure)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

There is a JCL Procedure defined that allows you to run REXX Scripts in
a plain Batch environment. The Procedure performs all necessary BREXX allocations

.. warning:: **ADDRESS TSO** commands are not supported here!

.. code-block:: jcl
    :linenos:
    :emphasize-lines: 6
    
    //DATETEST JOB CLASS=A,MSGCLASS=H,REGION=8192K,NOTIFY=&SYSUID
    //*
    //* ------------------------------------------------------------------*
    //* TEST REXX DATE AS TSO BATCH
    //* ------------------------------------------------------------------*
    //REXX EXEC RXBATCH,EXEC='ETIME#T',SLIB='BREXX.SAMPLES'

- **EXEC=** defines the rexx script to run
- **SLIB=** defines the library/partitioned dataset containing the 
  rexx script defined in **EXEC**

Additionally, you can add a `P='input-parameters'` JCL Parameter field,
if your rexx receives input parameters.

BREXX/370 Sample Library
~~~~~~~~~~~~~~~~~~~~~~~~

The Library `BREXX.version.SAMPLES` contains a variety of REXX scripts
that cover the following areas:

- Basic functionality in Members starting with '$'
- FSS samples, starting with '#'
- VSAM samples beginning with '@'
- All other scripts are original samples delivered with Vasilis 
  Vlachoudis BREXX installation.

BREXX/370 Hints
~~~~~~~~~~~~~~~

Please make sure that your REXX files do not contain line numbering!
They are not wiped out by BREXX/370 and therefore treated as the content
of the script. This lead to errors during interpretation, sometimes even
system abends! Use UNNUM as a primary command in the RFE editor to
switch line numbering off and remove existing numbers.

If the BREXX/370 call leads to an S106 Abend, the most likely reason is
the creation of a new extent in `SYS2.LINKLIB` during the installation
process. Its size and number of extents are loaded during IPL and kept
while MVS is up and running. The creation of new extents will therefore
not be discovered. 

You can either re-IPL your system or better REORG SYS2.LINKLIB with 
IEBCOPY.