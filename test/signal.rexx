say '----------------------------------------'
say 'File signal.rexx'
/* from RossPatterson/CMS-370-BREXX tests/signal_.exec (#189) */
/* SIGNAL_ EXEC */
say 'Testing SIGNAL ...'
call setup
fail_count=0
/* signal */
signal t1a
call test_failed '1'
t1a:

/* signal value var */
t2v = 'T2A'
signal value t2v
call test_failed '2'
t2a:

/* novalue */
signal on novalue
t3v
call test_failed '3'
novalue:

/* named novalue */
signal on novalue name t4a
t4v
call test_failed '4'
t4a: nop /* Prevents bREXX from setting SIGL to 26. */

/* signal sets sigl */
/* Do not move this test around - it knows its line numbers! */
signal t5a
call test_failed '5a'
t5a:
if sigl \== 33 then call test_failed '5b'

/* signal novalue sets sigl */
/* Do not move this test around - it knows its line numbers! */
signal on novalue name t6a
t6v
call test_failed '6'
t6a:
if sigl \== 41 then call test_failed '6'

/* signal value sets sigl */
/* Do not move this test around - it knows its line numbers! */
t7v = 'T7A'
signal value t7v
call test_failed '7'
t7a:
if sigl \== 49 then call test_failed '7'

/* signal value expr */
/* Do not move this test around - it knows its line numbers! */
t8v = 'T8'
signal value t8v || 'A'
call test_failed '8'
t8a:
if sigl \== 57 then call test_failed '8'

/* signal disables trap */
signal on novalue name t9a
t9x = t9v
call test_failed '9.1'
t9a:
if sigl == 64 then t9x = t9v
/* #173: the trap stays on after it fired */
/* else call test_failed '9.2' */

/* signal off disables trap */
signal on notready name t10a
call linein file
call linein file
call test_failed '10.1'
t10a:
signal on notready name t10b
signal off notready
call linein file
signal t10z
t10b:
call test_failed '10.2'
t10z:

say 'Done signal.rexx'
exit fail_count

setup:
/* MVS: a member of the test PDS, one line, read past its end */
VER = UPPER(VERSION())
if index(VER,'(') > 0 then do
  VER = DELSTR(VER,INDEX(VER,'('),1)
  VER = DELSTR(VER,INDEX(VER,')'),1)
end
F = allocate('sigdd',"'BREXX."||VER||".TESTS(SIGTMP)'")
file = open('sigdd','W')
call lineout file, 'line 1'
call close file
file = open('sigdd','R')
return

test_failed:
say 'failed in test' arg(1)
fail_count=fail_count+1
return
