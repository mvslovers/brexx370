/* ---------------------------------------------------------------------
 * Report Information from Datasets or DDN Allocations
 * ---------------------------------------------------------------------
 */
SAY ISDSN("EXEC")
SAY ISDSN("'BREXX.RXLIB'")
SAY ISDSN("'SYS2.LINKLIB'")
SAY ISDSN('SYSPROC')
SAY ISDSN("'SYS2.LINKLIB'")
SAY ISDSN("'BREXX.RXLIB'")
isdsn:
 rc=LISTDSI(arg(1))
 say 'Dataset Name 'SYSDSNAME
 say 'Volume       'SYSVOLUME
 say 'DSORG        'SYSDSORG
 say 'RECFM        'SYSRECFM
 say 'LRECL        'SYSLRECL
 say 'BLKSIZE      'SYSBLKSIZE
 return rc
