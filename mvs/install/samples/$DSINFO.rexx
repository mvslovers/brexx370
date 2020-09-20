/* ---------------------------------------------------------------------
 * Report Information from Datasets or DDN Allocations
 * ---------------------------------------------------------------------
 */
ADDRESS SYSTEM
SAY RXDSINFO('SYSPROC','REPORT','DDN')
SAY RXDSINFO('BREXX.RXLIB','REPORT','DSN')
SAY RXDSINFO('SYS2.LINKLIB','REPORT','DSN')
/* Report */
say '------ Single Values ----------'
SAY RXDSINFO('SYSPROC','LRECL','DDN')
SAY RXDSINFO('SYS2.LINKLIB','BLKSIZE','DSN')
SAY RXDSINFO('BREXX.RXLIB','VOLSER','DSN')
