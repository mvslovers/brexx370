say '----------------------------------------'
say 'File numeric.rexx'
/* from RossPatterson/CMS-370-BREXX tests/numeric_.exec (#189) */
/* NUMERIC */
parse source system .
say 'Testing NUMERIC statement ...'
fail_count=0

/* Valid instructions */
signal on syntax name t1a
numeric digits
numeric digits 3
numeric form
numeric form engineering
numeric form scientific
/* #220: NUMERIC FORM VALUE is error 25
numeric form value 'engineering'
t1v='scientific'; numeric form value t1v
numeric form value 'engin' || 'eering'
numeric form value 'scientific'
numeric form value 'enormous'
numeric form value 'Stupen' || 'dous'
t1v='s'; numeric form value t1v
numeric form value 'e'
numeric form value 's'   */
numeric fuzz
numeric fuzz 0
if fuzz() \== '0' then call test_failed '1b'
numeric fuzz 2
signal t1z
t1a:
call test_failed '1 at line' sigl':' sourceline(sigl)
t1z:

/* Invalid instructions */
say 'skipping tests 2-3 because bREXX cannot compile them'
/*
signal on syntax name t2z
numeric form enormous
call test_failed 2
t2z:
signal on syntax name t3z
numeric form Stupendous
call test_failed 3
t3z:
*/
/* #220: NUMERIC FORM VALUE
signal on syntax name t4z
numeric form value 'Banana'
call test_failed 4
t5z:
signal on syntax name t5z
numeric form value ''
call test_failed 5
*/
t4z:

say 'Testing NUMERIC function ...'
/* Valid functions */
numeric digits 4
if digits() \== '4' then call test_failed 6
numeric form engineering
if form() \== 'ENGINEERING' then call test_failed 7
numeric fuzz 3
if fuzz() \== '3' then call test_failed 8

say 'Done numeric.rexx'
exit fail_count

test_failed:
say 'failed in test' arg(1)
fail_count=fail_count+1
return
