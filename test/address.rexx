say '----------------------------------------'
say 'File address.rexx'
/* from RossPatterson/CMS-370-BREXX tests/address_.exec (#189) */
/* ADDRESS() and ADDRESS */
say 'Testing ADDRESS function ...'
fail_count=0
/* MVS batch: the default environment is MVS (TSO under IKJEFT01) */
default = 'MVS'
if address() \== default then call test_failed '1  address() =' address()
address 'aaa'
if address() \== 'aaa' then call test_failed '2'
address 'bbb'
if address() \== 'bbb' then call test_failed '3'
/* #246: ADDRESS without an operand does not swap back
address
if address() \== 'aaa' then call test_failed '4'
address
if address() \== 'bbb' then call test_failed '5'
*/
/* test 6 runs an empty CMS command: left out on MVS */
say 'Done address.rexx'
exit fail_count
test_failed:
say 'failed in test' arg(1)
fail_count=fail_count+1
return
