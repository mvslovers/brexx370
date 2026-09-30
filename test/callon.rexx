say '----------------------------------------'
say 'File callon.rexx'
/* CALL ON (#239). Tests 29-40 are conditi_ from RossPatterson/
   CMS-370-BREXX (#189), the rest are BREXX's own. MVS batch: IEBGENER
   without its DDs ends with RC 12 (ERROR), an unknown command with
   RC -3 (FAILURE).
   The program ends with RC 7 when every test passed. With SIGNAL
   semantics the RETURN of a trap routine at the top level ends the
   program with RC 0, which would read as passed.   MVSTEST RC=7 */
say 'Testing CALL ON ...'
fail_count=0

/* error called */
call on error name t29a
t29v = 0
address linkmvs 'IEBGENER'
if t29v = 0 then call test_failed '29'
signal t29z
t29a:
t29v = 1
if condition('C') \== 'ERROR' then call test_failed '30'
if condition('D') \== 'IEBGENER' then call test_failed '31'
if condition('I') \== 'CALL' then call test_failed '32'
if condition('S') \== 'DELAY' then call test_failed '33'
if condition() \== condition('I') then call test_failed '34'
return
t29z:
call off error

/* failure called */
t=trace('o') /* Prevent trace of cmd */
call on failure name t35a
t35v = 0
'NOCMDXYZ'
if t35v = 0 then call test_failed '35'
signal t35z
t35a:
t35v = 1
if condition('C') \== 'FAILURE' then call test_failed '36'
if condition('D') \== 'NOCMDXYZ' then call test_failed '37'
if condition('I') \== 'CALL' then call test_failed '38'
if condition('S') \== 'DELAY' then call test_failed '39'
if condition() \== condition('I') then call test_failed '40'
return
t35z:
call off failure
call trace t

/* SIGL is the line of the clause that raised the condition */
/* Do not move this test around - it knows its line numbers! */
call on error name t50a
address linkmvs 'IEBGENER'
signal t50z
t50a:
if sigl \== 52 then call test_failed '50  SIGL =' sigl
return
t50z:
call off error

/* the trap routine does not change RESULT, its RETURN value is ignored */
call t51r
call on error name t51a
address linkmvs 'IEBGENER'
if result \== 'KEEP' then call test_failed '51  RESULT =' result
signal t51z
t51r: return 'KEEP'
t51a: return 'LOST'
t51z:
call off error

/* in DELAY a second ERROR is ignored; after the RETURN the trap is ON */
t52n = 0
call on error name t52a
address linkmvs 'IEBGENER'
if t52n \== 1 then call test_failed '52  calls =' t52n
if condition('S') \== 'ON' then call test_failed '53'
address linkmvs 'IEBGENER'
if t52n \== 2 then call test_failed '53.1  calls =' t52n
signal t52z
t52a:
t52n = t52n + 1
address linkmvs 'IEBGENER'       /* ignored: the trap is in DELAY */
return
t52z:
call off error

/* CALL ON FAILURE with SIGNAL ON ERROR: only FAILURE is raised */
t=trace('o')
call on failure name t54a
signal on error name t54b
t54v = 0
'NOCMDXYZ'
if t54v \== 1 then call test_failed '54'
signal t54z
t54a:
t54v = 1
return
t54b:
call test_failed '54.1'
t54z:
call off failure
signal off error
call trace t

/* CALL ON SYNTAX and CALL ON NOVALUE are error 25 */
signal on syntax name t55a
interpret 'call on syntax'
call test_failed '55'
t55a:
if rc \== 25 then call test_failed '55.1  RC =' rc
signal on syntax name t55b
interpret 'call on novalue'
call test_failed '55.2'
t55b:
if rc \== 25 then call test_failed '55.3  RC =' rc
signal off syntax

/* a PROCEDURE EXPOSE trap routine */
t56n = 0
call on error name t56a
address linkmvs 'IEBGENER'
if t56n \== 1 then call test_failed '56'
signal t56z
t56a: procedure expose t56n
t56n = t56n + 1
return
t56z:
call off error

/* a DO loop is resumed where it was: its control values survive */
t57n = 0
call on error name t57a
do t57i = 1 to 3
  address linkmvs 'IEBGENER'
end
if t57n \== 3 then call test_failed '57  calls =' t57n
if t57i \== 4 then call test_failed '57.1  i =' t57i
signal t57z
t57a:
t57n = t57n + 1
return
t57z:
call off error

say 'Done callon.rexx'
exit 7 + fail_count

test_failed:
say 'failed in test' arg(1)
fail_count=fail_count+1
return
