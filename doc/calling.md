# Calling external REXX Scripts or Functions

Due to the extended calling functionality in the new version, importing
of required REXX scripts is no longer necessary. You can now call any
external REXX script directly.

## Primary REXX Script location via fully qualified DSN

If you call a REXX script using a fully qualified partitioned dataset
(PDS) member name, it must be present in the specified PDS. You can also
use a fully qualified sequential dataset name that holds your script. If
it is not available, an error message terminates the call. In TSO you
can invoke your script using the REXX or RX commands. Example:

1. RX ‘MY.EXEC(MYREX)’ if the script resides in a PDS, alternatively:
2. RX ‘MY.SAMPLE.REXX’ if it is a sequential dataset

## Location of the Main REXX script via PDS search (TSO environments)

In TSO environments the main script can be called with the RX or REXX
command. The search path for finding your script is SYSUEXEC, SYSUPROC,
SYSEXEC, SYSPROC. At least one of these need to be pre-allocated during
the TSO logon. It is not mandatory to have all of them allocated. It
depends on your planned REXX development environment. The allocations
may consist of concatenated datasets.

## Running scripts in batch

In batch, you can use the delivered RXTSO or RXBATCH JCL procedure and
specify the REXX script and its location to execute it. There is no
additional search path used to locate it.

## Calling external REXX scripts

It is now possible to call external REXX scripts, either by: CALL your-script parm1,parm2…
or by function call: value=your-script(parm1,parm2,…) The call might
take place from within your main REXX, or from a called subroutine. The
search of the called script is performed in the following sequence:

- Internal sub-procedure or label (contained in the running REXX script)
- current PDS (where the calling REXX is originated) 
- from the delivered BREXX.V2R5M3.RXLIB library, which then needs to be
  allocated with the DD-name RXLIB

## Variable Scope of external REXX scripts

If the called external REXX does not contain a procedure definition, all
variables of the calling REXX are accessible (read and update). If the
called REXX creates new variables, they are available in the calling
REXX after control is returned.
