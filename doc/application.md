# Application Guide

The BREXX Application Guide describes some of the applications available with.
They may not be fully developed, or tested, or foolproof, but they demonstrate
the capabilities of BREXX and might be valuable to you.

## Installation

After the installation of BREXX will find them in the RXLIB library and can be
invoked directly from your scripts.

## RXDIFT

RXDIFT compares two datasets and shows their differences.

### RXDIFT(new-dsn, old-dsn)

* **Parameters:**
  * **new-dsn** – This dataset is considered new how it evolved from old-dsn
  * **old-dsn** – dsn which is the source for the compare
  * **option1** – Either ALL  (show all changed/deleted/unchanged lines) or CHANGES (show just changed/deleted lines). Default CHANGES.
  * **option2** – Either DETAILS (show progress) or SUMMARY (show only summary). Default SUMMARY.

We have 2 scripts which slightly are different, with the following REXX we compare them and display the changes with FMTLIST

Example 1:

```rexx
file1='PEJ.EXEC(dbdoc1)'
file2='PEJ.EXEC(dbdoc2)'

rarray=RXDIFF(file1,file2,'ALL','DETAILS')
  buffer.0='ARRAY 'rarray
  hdr1='New    Old     'file1'<-'file2
  hdr2='Lino   Lino    Lines'
 call FMTLIST ,,hdr1,hdr2
```

Results:

```default
New    Old     PEJ.EXEC(DBDOC1)<-PEJ.EXEC(DBDOC2)
Lino   Lino    Lines
08:23:47.288   0.000  Compare PEJ.EXEC(DBDOC1) with PEJ.EXEC(DBDOC2)
08:23:47.329   0.040  Dataset PEJ.EXEC(DBDOC1) read
08:23:47.370   0.039  Dataset PEJ.EXEC(DBDOC2) read
08:23:47.376   0.005  Datasets Hashes created
08:23:47.389   0.011  Temporary Arrays created
08:23:47.390   0.000  Start Compare process
08:23:47.393   0.003  Large overlap found 11 lines
08:23:47.395   0.005  Compare process ended, differences determined
08:23:47.399   0.003  Sequences analysed
Differences of PEJ.EXEC(DBDOC1)(new) with PEJ.EXEC(DBDOC2)(old)
00001  00001   call import KeyValue
00002  00002   call dbmsglv 'N'
00003  00003   say "OPEN  "DBOPEN()           /* Open Key/Value Database */
00004  00004   say "ROOM  "DBROOM('WORLD')       /* switch to WORLD  */
00005  00005   call dbremove('QUA',"Continent")  /* Remove records with
00006  00006   call dbremove('ANY',"Mu")         /* Remove records
00007  00007   call dbremove('CONTAINS',"265")
00008  00008   call dbremove('ONLY',"Wa")        /* Remove records with a
00009  00009   call dbremove('ALL')              /* Remove all records of
00010  00010   call dblist('ANY',"Mu")
00011  00011   call dblist('QUA',"Continent")
**del  00012   call dblist('ONLY',"Wa")
**del  00013   call dblist('CONTAINS',"265")
**del  00014   say "CLOSE "DBCLOSE()
00012  **ins   say "CLOSE "DBCLOSE()
deleted  lines 3
inserted lines 1
moved    lines 0
08:23:47.403   0.004  Summary produced
08:23:47.405   0.001  Cleanup completed
08:23:47.406   0.117  Compare completed PEJ.EXEC(DBDOC1) with PEJ.EXEC(DBDOC2)
```

Example 2:

```rexx
file1='PEJ.EXEC(dbdoc1)'
file2='PEJ.EXEC(dbdoc2)'

rarray=RXDIFF(file1,file2)
  buffer.0='ARRAY 'rarray
  hdr1='New    Old     'file1'<-'file2
  hdr2='Lino   Lino    Lines'
 call FMTLIST ,,hdr1,hdr2
```

Results:

```default
New    Old     PEJ.EXEC(DBDOC1)<-PEJ.EXEC(DBDOC2)
Lino   Lino    Lines
Differences of PEJ.EXEC(DBDOC1)(new) with PEJ.EXEC(DBDOC2)(old)
**del  00012   call dblist('ONLY',"Wa")
**del  00013   call dblist('CONTAINS',"265")
**del  00014   say "CLOSE "DBCLOSE()
00012  **ins   say "CLOSE "DBCLOSE()
deleted  lines 3
inserted lines 1
moved    lines 0
```

## RXCOPY

RXCOPY is a speedy dataset copy service which handles the copy utilizing the original MVS tools (REPRO and IEBCOPY).

### RXCOPY(new-dsn, old-dsn)

* **Parameters:**
  * **new-dsn** – The dataset to be created
  * **old-dsn** – the dataset you’re copying
  * **volume** – The volume serial name that will receive the copied dataset. If omitted, MVS chooses the volume.
  * **option** – ‘REPLACE’/’REPRO’ REPLACE replaces any existing target dataset which is in the system catalogue. REPRO is used to duplicate sequential datasets. The DCB information from the source dsn is utilized to create the target dsn before the copy process.

```rexx
call rxcopy('pej.temp','PEJ1.TEMP',,'REPLACE')
```

Results:

```default
------------------------------------------------------------------------
RXCOPY PEJ.TEMP INTO PEJ1.TEMP REPLACE
------------------------------------------------------------------------
DSN PEJ.TEMP is sequential, invoke REPRO
Create 'PEJ1.TEMP' with DSORG=PS,RECFM=VBM,UNIT=SYSDA,LRECL=137,BLKSIZE=1692,PRI=1,SEC=1
'PEJ1.TEMP' successfully created
NUMBER OF RECORDS PROCESSED WAS 15
```

IEBCOPY copies partitioned datasets. The DCB information from the source dsn is
used to generate the target dsn before the copy procedure. IEBCOPY must be in
authorized mode, therefore if you run it within ISPF, it must be authorised.
Plain TSO is authorised, so you may run it there.

```rexx
call rxcopy('pej.temp80','PEJ1.TEMP',,'REPLACE')
```

Results:

```default
------------------------------------------------------------------------
RXCOPY PEJ.TEMP80 INTO PEJ1.TEMP80 REPLACE
------------------------------------------------------------------------
DSN PEJ.TEMP80 is partitioned, invoke IEBCOPY
Target Dataset 'PEJ1.TEMP80' has been removed, due to remove option
Create 'PEJ1.TEMP80' with DSORG=PO,RECFM=FB,UNIT=SYSDA,LRECL=80,BLKSIZE=6400,PRI=25,SEC=3,DIRBLKS=1
'PEJ1.TEMP80' successfully created
Prepare IEBCOPY
IEBCOPY completed, RC=0 0
1                                        IEBCOPY MESSAGES AND CONTROL STATEMENTS
-IEB167I  FOLLOWING MEMBER(S)  COPIED  FROM INPUT DATA SET REFERENCED BY SYSUT1   -
IEB154I  PEJ1     HAS BEEN SUCCESSFULLY  COPIED
IEB154I  PEJ2     HAS BEEN SUCCESSFULLY  COPIED
IEB144I  THERE ARE 0000024 UNUSED TRACKS IN OUTPUT DATA SET REFERENCED BY SYSUT2
IEB149I  THERE ARE 0000000  UNUSED DIRECTORY BLOCKS IN OUTPUT DIRECTORY
IEB147I  END OF JOB -00 WAS HIGHEST SEVERITY CODE
```

## JES2 Spool Viewer

The JES2 Spool Queue Viewer wants to add some more functionality to the ISPF3.8
function.

You can run the spool viewer with the following command:

```default
rx  'BREXX.V2R5M3.SAMPLES(JESQUEUE)'
```

Some examples of the tool:

Main Menu:

```default
---------------------- JES2 Primary Option  Menu    ----------------------
Option ===>

         Type an Option and press Enter"

         LOG        Display the System Log
         DA         Display Active Users of the System
         I          Display Jobs in the JES2 Input Queue
         A          Display Jobs Executing
         O          Display Jobs in the JES2 Output Queue
         H          Display Jobs in the JES2 Held Queue
         SYS        Display System Details
         DASD       Display Available Volumes
```

Display Jobs (option o):

```default
               JES2 Spool Queue of MVSC
SPOOL ==>                                                                                                     ROWS 00001/00067 COL 001 B01
        Job Name   Number    QUEUE   STATUS   LINES
***** . ******************************************************* Top of      Data    ******************************************************
00001 . IBMUSER    TSU00001  PRTPUN  ANY
00002 . INIT       STC00004  PRTPUN  ANY
00003 . INIT       STC00005  PRTPUN  ANY
00004 . INIT       STC00006  PRTPUN  ANY
00005 . INIT       STC00019  PRTPUN  ANY
00006 . INIT       STC00020  PRTPUN  ANY
00007 . INIT       STC00021  PRTPUN  ANY
00008 . INIT       STC00025  PRTPUN  ANY
00009 . INIT       STC00026  PRTPUN  ANY
00010 . INIT       STC00027  PRTPUN  ANY
00011 . INIT       STC00031  PRTPUN  ANY
00012 . INIT       STC00032  PRTPUN  ANY
00013 . INIT       STC00033  PRTPUN  ANY
00014 . INIT       STC00037  PRTPUN  ANY
00015 . INIT       STC00038  PRTPUN  ANY
00016 . INIT       STC00039  PRTPUN  ANY
00017 . INIT       STC00043  PRTPUN  ANY
00018 . INIT       STC00044  PRTPUN  ANY
00019 . INIT       STC00045  PRTPUN  ANY
00020 . INIT       STC00049  PRTPUN  ANY
00021 . INIT       STC00050  PRTPUN  ANY

Linecmd S view, SJ create JCL, P purge, O send to class, XDC export to      dsn
```

Display DASD (option dasd):

```default
FSSAPI ==>                                                                                            ROWS 00001/00011 COL 001 B01
      MVS DASDs
***** ******************************************************* Top of Data ********************************************************
00001 Active DASDs
00002 -----------------------------------------------------------------------
00003 UNIT TYPE STATUS  VOLSER VOLSTATE   UNIT TYPE STATUS  VOLSER VOLSTATE
00004 150  3350 S       MVSRES PRIV/RSDNT 151  3350 A       MVS000 PRIV/RSDNT
00005 152  3350 A       PAGE00 PRIV/RSDNT 153  3350 A       SPOOL1 PRIV/RSDNT
00006 180  3380 A       PUB000 PRIV/RSERV 190  3390 A       PUB001 PRIV/RSERV
00007 220  2314 O       SORTW1  PUB/RSERV 221  2314 O       SORTW2  PUB/RSERV
00008 222  2314 O       SORTW3  PUB/RSERV 223  2314 O       SORTW4  PUB/RSERV
00009 224  2314 O       SORTW5  PUB/RSERV 225  2314 O       SORTW6  PUB/RSERV
00010 250  3350 O       SMP000 PRIV/RSDNT 251  3350 A       WORK00 STRG/RSDNT
00011 252  3350 A       WORK01 STRG/RSDNT 253  3350 A       SYSCPK PRIV/RSDNT
***** ******************************************************* End of Data ********************************************************
```

## Data Exchange between different MVS Environments

There is an easy way to exchange data between MVS systems.

Starting the Stargate Server:

```rexx
rc=stargate('RECEIVE',,3205)
say 'Stargate ended with RC='rc
return
```

13:14:54.884085 ..BASIC 3205      Stargate TCP Server start at Port: 3205

Launch the Stargate Client, which transmits and requests services and datasets:

Here are some screenshots, just an overview:

### Tailoring the list of target MVSes

Edit BREXX.V2R5M3.SAMPLE(SGTCPLST):

```default
;; -----------------------------------------------------------------
;; Tailor the TCP Address you usually use to access Stargate Servers
;;    the format is
;;      IP-ADDRESS port-number comment
;;      comment is optional
;; -----------------------------------------------------------------
   xxxx1.yyyyyyy.dddd           3205   my system 1
   xxxx2.yyyyyyy.dddd           3205   my system 2
   xxxx3.yyyyyyy.dddd           3205   my system 3
   xxxx4.yyyyyyy.dddd           3205   my system 4
   xxxx5.yyyyyyy.dddd           3205   my system 5
```
