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
/* #246: ADDRESS without an operand swaps with the previous one */
address
if address() \== 'aaa' then call test_failed '4'
address
if address() \== 'bbb' then call test_failed '5'
/* test 6 runs an empty CMS command: left out on MVS */

/* #246: an ADDRESS in a routine, also one in an INTERPRET there, and a
   swap there stay in the routine */
address 'ccc'
call t7r
if address() \== 'ccc' then call test_failed '7  address() =' address()
address
if address() \== 'bbb' then call test_failed '8  address() =' address()
say 'Done address.rexx'
exit fail_count
t7r: procedure expose fail_count
interpret "address 'ddd'"
if address() \== 'ddd' then call test_failed '7.1'
address
if address() \== 'ccc' then call test_failed '7.2  address() =' address()
return

test_failed:
say 'failed in test' arg(1)
fail_count=fail_count+1
return
