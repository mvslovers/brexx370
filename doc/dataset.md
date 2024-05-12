# Dataset Functions

### CREATE(dataset-name, allocation-information)

The CREATE function creates and catalogues a new dataset (if the
user has the required authorisation level). If dataset-name is not
fully qualified, it will be prefixed by the user name.

Fully qualified DSN is: BREXX.TEST.SEQ

Not fully qualified: TEST.SEQ will be prefixed by user name (e.g.
HERC01) “HERC01.TEST.SQ”

* **Parameters:**
  **allocation-information** – can be: DSORG, RECFM, BLKSIZE, LRECL, PRI, SEC, DIRBLKS, UNIT (not all are mandatory):.

The space allocations for PRI (primary space) and SEC (secondary space) is the number of tracks.

* **Returns:**
  If the create is successful, the return code will be zero; else a negative value will be returned. The CREATE function does not open the dataset.

Return codes:

- 0 Create was successful
- -1 Dataset cannot be created (various reasons as, space limitations, authorisation, etc.)
- -2 Dataset is already catalogued

Example:

```rexx
CREATE('TEST','recfm=fb,lrecl=80,blksize=3120,unit=sysda,pri=5,DIRBLKS=5')
```

### DIR(partitioned-dataset-name)

The DIR command returns the directory of a partitioned dataset. If
the partitioned-dataset is not fully qualified, it will be prefixed
by the user name. The directory is provided in the stem variable DIRENTRY..

Table showing the structure of the returned stem. **n is the number of the member entry**.

| STEM Name        | Description                                     |
|------------------|-------------------------------------------------|
| DIRENTRY.0       | contains the number of directory members        |
| DIRENTRY.n.CDATE | creation date of the member, e.g. => “19-04-18” |
| DIRENTRY.n.INIT  | initial size of member                          |
| DIRENTRY.n.MOD   | mod level                                       |
| DIRENTRY.n NAME  | member name                                     |
| DIRENTRY.n.SIZE  | current size of member                          |
| DIRENTRY.n.TTR   | TTR of member                                   |
| DIRENTRY.n.UDATE | last update date, e.g. “ 20-06-09”              |
| DIRENTRY.n.UID   | last updated by user- id                        |
| DIRENTRY.n.UTIME | last updated time                               |
| DIRENTRY.n.CDATE | creation date                                   |

### EXISTS(dataset-name/partitioned-dataset(member))

The EXISTS function checks the existence of a dataset or the
presence of a member in a partitioned dataset. EXISTS returns 1 if
the dataset or the member in a partitioned dataset is available. It
returns 0 if it does not exist. If the dataset-name is not fully
qualified, it will be prefixed by the user name.

### REMOVE(dataset-name/partitioned-dataset(member))

The REMOVE function un-catalogues and removes the specified dataset
(if the user has the required authorisation level). If dataset-name
is not fully qualified, it will be prefixed by the user name.If the
removal is successful, the return code will be zero; else a negative
value will be returned. Return codes:

- 0 Create was successful
- -1 Dataset cannot be created (various reasons as, space limitations, authorisation, etc.)
- -2 Dataset is already catalogued

The REMOVE function on members of a partitioned dataset removes the
specified member (if the user has the required authorisation level).
If dataset-name is not fully qualified, it will be prefixed by the
user name. If the removal is successful, the return code will be zero;
else a negative value will be returned.

### RENAME(old-dataset-name, new-dataset-name)

The RENAME function renames the specified dataset. The user requires
the authorisation for the dataset to rename as well as the new
dataset. If dataset-name is not fully qualified, it will be prefixed
by the user name. If the rename is successful, the return code will
be zero; else a negative value will be returned.

The RENAME function on members renames the specified member into a
new one. The user requires the authorisation for the dataset. The
RENAME must be performed in the same partitioned dataset. If the
rename is successful, the return code will be zero; else a negative
value will be returned.

### ALLOCATE(ddname, dataset-name/partitioned-dataset(member-name))

The ALLOCATE function links an existing dataset or a member of a
partitioned dataset to a dd-name, which then can be used in services
requiring a dd-name. If dataset-name is not fully qualified, it will
be prefixed by the user name.

If the allocation is successful, the return code will be zero;
else a negative value will be returned.

### FREE(ddname)

The FREE function de-allocates an existing allocation of a dd-name.
If the de-allocation is successful, the return code will be zero;
else a negative value will be returned.

### OPEN(dataset-name, open-option, allocation-information)

The OPEN function has now a third parameter, which allows creating
new datasets with appropriate DCB and system definitions. If the
dataset already exists, the existing definition is used, the DCB is
not updated. If the dataset-name is not fully qualified, it will be
prefixed by the user name. The dataset-name may contain a member
name, which must be enclosed within parenthesis. e.g. OPEN(“’”myPDS(mymember)”’”)

If the open is performed with the read-option, the member name must
be present, else the open fails. If the write-option is used, you
can refer to a member-name that does not yet exist and will be
created by following write commands. If the member name exists, the
current content will be overwritten. The open-options have not
changed, please refer to the official BREXX documentation.

* **Parameters:**
  **allocation-information** – can be: DSORG, RECFM, BLKSIZE, LRECL, PRI, SEC, DIRBLKS, UNIT (not all are mandatory).

The space allocations for PRI (primary space) and SEC (secondary
space) is the number of tracks.

If the open is successful, a file handle (greater zero) will be
returned; it will be less or equal zero if the open is not successful.

#### WARNING
Important notice: opening a member of a partitioned dataset in write
mode requires full control of the entire dataset (not just the member),
if you edit or browse the member concurrently the open will fail.

### 'EXECIO'

The EXECIO is a **host** command; therefore, it is enclosed in apostrophes.

EXECIO performs data set I/O operations either on the stack or stem
variables, it supports only dataset containing text records. For
records containing binary data you can use There is just a subset of
the known EXECIO functions implemented: Full read/write from a
dd-name. The ddname must be allocated either by TSO ALLOC command,
or DD statement in the JCL. Specifying a Dataset-Name (DSN) is not supported!

Syntax: EXECIO <lines-to-read/\*> <DISKR/DISKW/LIFOR/LIFOW/FIFOR/FIFOW> (<STEM stem-variable-name/LIFO/FIFO> [SKIP skip-lines] [START first-stem-entry] [KEEP keep-string] [DROP dropstring] [SUBSTR(offset,length)]

| EXECIO Param     | Description                                                                                |
|------------------|--------------------------------------------------------------------------------------------|
| Lines-to         | read is the number of records which shall be read from the file, \* means read all records |
| DISKR            | read from dataset                                                                          |
| DISKW            | write into dataset                                                                         |
| LIFOR/FIFOR      | read from stack, stack structure can’t be changed, it is fixed by the ways it was created  |
| LIFOW/FIFOW      | write to stack inLIFO or FIFO way                                                          |
| STEM             | read into a stem/write from a stem variable                                                |
| first-stem-entry | start adding entries at given stem.number, only available on DISKR with STEM parameter     |
| LIFO             | read from / write into a lifo stack                                                        |
| FIFO             | read from / write into a fifo stack                                                        |
| skip-lines       | skip number of lines before processing dataset/stack                                       |
| keep-string      | process just records containing the string                                                 |
| drop-string      | process just records which do not contain the string                                       |
| SUBSTR           | process a substring of the given record                                                    |

Example:

```rexx
/* Read entire File into Stem-Variable*/
"EXECIO * DISKR dd-name (STEM stem-name."

/* Write Stem-Variable into File */
"EXECIO * DISKW dd-name (STEM stem-name."

/* Append File by Stem-Variable */
"EXECIO * DISKA dd-name (STEM stem-name."

/* ---- Read into REXX FIFO Stack ------- */
"EXECIO * DISKR dd-name (FIFO "
do i=1 to queued()
  parse pull line
  say line
end

/* ---- Read into REXX LIFO Stack ------- */
"EXECIO * DISKR dd-name (LIFO "
do i=1 to queued()
parse pull line
say line
end
```

After completing the Read stem-name.0 contains the number of records read
The number of lines to become written to the file is defined in stem-variable.0
