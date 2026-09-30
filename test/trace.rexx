say '----------------------------------------'
say 'File trace.rexx'
/* from RossPatterson/CMS-370-BREXX tests/trace_.exec (#189) */
/* TRACE. MVS batch: NOCMDXYZ ends with RC -3, IEFBR14 with RC 0 and
   IEBGENER without its DDs with RC 12, in place of Ross's exitneg_,
   exitok_ and exitpos_ execs. Whether a trace line is written is not
   checked, only the RC and TRACE(). */
say 'Testing TRACE ...'
fail_count=0

/* These from TRL2. */
value = trace()
if value \== 'N' then call test_failed '1: trace()=' value
value = trace('O')
if value \== 'N' then call test_failed '2: trace()=' value
value = trace('A')
if value \== 'O' then call test_failed '3: trace()=' value
/* #247: TRACE F (Failure) */
value = trace('F')
if value \== 'A' then call test_failed '4: trace()=' value
value = trace()
if value \== 'F' then call test_failed '5: trace()=' value

trace O

trace N
value = trace()
if value \== 'N' then call test_failed '6: trace()=' value
say 'test 6 expecting a trace ...'
'NOCMDXYZ'
if RC >=0 then call test_failed '6'

trace N
value = trace()
if value \== 'N' then call test_failed '7: trace()=' value
say 'test 7 expecting no trace ...'
address linkmvs 'IEFBR14'
if RC <>0 then call test_failed '7'

trace N
value = trace()
if value \== 'N' then call test_failed '8: trace()=' value
say 'test 8 expecting no trace ...'
address linkmvs 'IEBGENER'
if RC <=0 then call test_failed '8'

/* #247: TRACE F (Failure) */
trace F
if trace() \== 'F' then call test_failed '9'
say 'test 9 expecting a trace ...'
'NOCMDXYZ'
if RC >=0 then call test_failed '9'

trace F
value = trace()
if value \== 'F' then call test_failed '10: trace()=' value
say 'test 10 expecting no trace ...'
address linkmvs 'IEFBR14'
if RC <>0 then call test_failed '10'

trace F
if trace() \== 'F' then call test_failed '11'
say 'test 11 expecting no trace ...'
address linkmvs 'IEBGENER'
if RC <=0 then call test_failed '11'

trace E
if trace() \== 'E' then call test_failed '12'
say 'test 12 expecting a trace ...'
'NOCMDXYZ'
if RC >=0 then call test_failed '12'

trace E
value = trace()
if value \== 'E' then call test_failed '13: trace()=' value
say 'test 13 expecting no trace ...'
address linkmvs 'IEFBR14'
if RC <>0 then call test_failed '13'

trace E
if trace() \== 'E' then call test_failed '14'
say 'test 14 expecting a trace ...'
address linkmvs 'IEBGENER'
if RC <=0 then call test_failed '14'

trace O
/* tests 15-17 use TRACE ? with a human at a CMS console: left out */

say 'Done trace.rexx'
exit fail_count
test_failed:
say 'failed in test' arg(1)
fail_count=fail_count+1
return
