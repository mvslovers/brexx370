say '----------------------------------------'
say 'File conditi.rexx'
/* from RossPatterson/CMS-370-BREXX tests/conditi_.exec (#189) */
/* CONDITION() */
say 'Testing CONDITION ...'
fail_count=0
parse source system .
/* MVS batch: IEBGENER without its DDs ends with RC 12 (ERROR), an
   unknown command with RC -3 (FAILURE) */

/* condition without signal */
if condition('C') \== '' then call test_failed '1'
if condition('D') \== '' then call test_failed '2'
/* #233 */
if condition('I') \== '' then call test_failed '3'
/* #233 */
if condition('S') \== '' then call test_failed '4'
if condition() \== condition('I') then call test_failed '5'

/* novalue signaled */
signal on novalue name t6a
t6v
call test_failed '6'
signal t6z
t6a:
if condition('C') \== 'NOVALUE' then call test_failed '6'
if condition('D') \== 'T6V' then call test_failed '7'
if condition('I') \== 'SIGNAL' then call test_failed '8'
/* #173: the trap is OFF after it fired */
if condition('S') \== 'OFF' then call test_failed '9'
if condition() \== condition('I') then call test_failed '10'
t6z:
signal off novalue

/* syntax signaled */
signal on syntax name t11a
t11v = t11b()
call test_failed '11'
signal t11z
t11a:
if condition('C') \== 'SYNTAX' then call test_failed '12'
/* test 13 checks the CMS text of condition('D'): left out */
if condition('I') \== 'SIGNAL' then call test_failed '14'
/* #173: the trap is OFF after it fired */
if condition('S') \== 'OFF' then call test_failed '15'
if condition() \== condition('I') then call test_failed '16'
t11z:
signal off syntax

/* error signaled */
signal on error name t17a
address linkmvs 'IEBGENER'
call test_failed '17'
signal t17z
t17a:
if condition('C') \== 'ERROR' then call test_failed '18'
/* #234 */
if condition('D') \== 'IEBGENER' then call test_failed '19'
if condition('I') \== 'SIGNAL' then call test_failed '20'
/* #173: the trap is OFF after it fired */
if condition('S') \== 'OFF' then call test_failed '21'
if condition() \== condition('I') then call test_failed '22'
t17z:
signal off error

/* failure signaled (#238) */
t=trace('o') /* Prevent trace of cmd */
signal on failure name t23a
'NOCMDXYZ'
call test_failed '23'
signal t23z
t23a:
if condition('C') \== 'FAILURE' then call test_failed '24'
if condition('D') \== 'NOCMDXYZ' then call test_failed '25'
if condition('I') \== 'SIGNAL' then call test_failed '26'
if condition('S') \== 'OFF' then call test_failed '27'
if condition() \== condition('I') then call test_failed '28'
t23z:
signal off failure
call trace t

/* #238: a negative RC raises ERROR when FAILURE is not ON */
t=trace('o')
signal on error name t41a
'NOCMDXYZ'
call test_failed '41'
signal t41z
t41a:
if condition('C') \== 'ERROR' then call test_failed '41'
if rc >= 0 then call test_failed '41.1  RC =' rc
t41z:
signal off error
call trace t

/* #238: TRACE OFF does not switch the ERROR trap off */
t=trace('o')
signal on error name t42a
address linkmvs 'IEBGENER'
call test_failed '42'
t42a:
signal off error
call trace t

/* #238: a positive RC is ERROR even with FAILURE ON */
t=trace('o')
signal on failure name t43a
signal on error name t43a
address linkmvs 'IEBGENER'
call test_failed '43'
t43a:
if condition('C') \== 'ERROR' then call test_failed '43.1'
signal off failure
signal off error
call trace t

/* tests 29-40 (CALL ON) are in callon.rexx: they need its RC check */

say 'Done conditi.rexx'
exit fail_count
test_failed:
say 'failed in test' arg(1)
fail_count=fail_count+1
return
