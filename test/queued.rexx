say '----------------------------------------'
say 'File queued.rexx'
/* from RossPatterson/CMS-370-BREXX tests/queued_.exec (#189) */
/* QUEUED */
say 'Testing QUEUED ...'
fail_count=0
if queued() \= 0 then call test_failed '1'
push 'xyz'
q = queued()
pull .
if q \= 1 then call test_failed '2'
say 'Done queued.rexx'
exit fail_count
test_failed:
say 'failed in test' arg(1)
fail_count=fail_count+1
return
