/* REXX - MVSTEST PARM=DSN MVSTEST RC=3 */
say '----------------------------------------'
say 'File dsnmain.rexx'
/* The main exec named by its data set name, as RX 'DSN(MEMBER)' does */
/* in TSO (doc/calling.md). mvstest.py starts this step with          */
/* PARM='<testlib>(DSNMAIN)' and no RXRUN DD, so RxFileLoad() can     */
/* only find it through RxFileLoadDSN(), which takes a name with a    */
/* '.' as a DSN (src/rexx.c). It ends with RC 3, so a load that fails */
/* and ends with RC 0 or an error RC reads as FAIL.                    */
parse source src
say 'DSNMAIN  - parse source:' src
say 'Done dsnmain.rexx'
exit 3
