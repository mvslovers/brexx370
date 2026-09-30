say '----------------------------------------'
say 'File arg2.rexx'
/* from RossPatterson/CMS-370-BREXX tests/arg_.exec (#189) */
/* ARG() and ARG */
say 'Testing ARG function ...'
fail_count=0
/* These from TRL2. */
call name
call namex 1,,2
/* These from Mark Hessling. */
call testarg2 1,,2
call testarg1
say 'Testing ARG statement ...'
fail_count=0
call testinst1 1,2
call testinst2 1,,3
say 'Done arg2.rexx'
exit fail_count
test_failed:
say 'failed in test' arg(1)
fail_count=fail_count+1
return
name:
if arg() \= 0 then call test_failed '1'
if arg(1) \== '' then call test_failed '2'
if arg(2) \== '' then call test_failed '3'
if arg(1,'e') then call test_failed '4'
if arg(1,'O') \= 1 then call test_failed '5'
return

namex:
if arg() \= 3 then call test_failed '6'
if arg(1) \== 1 then call test_failed '7'
if arg(2) \== '' then call test_failed '8'
if arg(3) \= 2 then call test_failed '9'
/* #222 */
/* if arg(999) \== '' then call test_failed '10' */
if arg(1,'e') \= 1 then call test_failed '11'
if arg(2,'E') \= 0 then call test_failed '12'
if arg(2,'O') \= 1 then call test_failed '13'
if arg(3,'o') \= 0 then call test_failed '14'
if arg(4,'o') \= 1 then call test_failed '15'
return

testarg1:
if arg() \== '0' then call test_failed '16'
if arg(1) \== '' then call test_failed '17'
if arg(2) \== '' then call test_failed '18'
if arg(1,'e') \== '0' then call test_failed '19'
if arg(1,'O') \== '1' then call test_failed '20'
return

testarg2:
if arg() \== '3' then call test_failed '21'
if arg(1) \== '1' then call test_failed '22'
if arg(2) \== '' then call test_failed '23'
if arg(3) \== '2' then call test_failed '24'
if arg(4) \== '' then call test_failed '25'
if arg(1,'e') \== '1' then call test_failed '26'
if arg(2,'E') \== '0' then call test_failed '27'
if arg(2,'O') \== '1' then call test_failed '28'
if arg(3,'o') \== '0' then call test_failed '29'
if arg(4,'o') \== '1' then call test_failed '30'
return

testinst1:
arg a b c, d e f, g h i
if a \= 1 then call test_failed '31'
if b \== '' then call test_failed '32'
if c \== '' then call test_failed '33'
if d \== 2 then call test_failed '34'
if e \== '' then call test_failed '35'
if f \== '' then call test_failed '36'
if g \== '' then call test_failed '37'
if h \== '' then call test_failed '38'
if i \== '' then call test_failed '39'
return

testinst2:
arg a b c, d e f, g h i
if a \= 1 then call test_failed '40'
if b \== '' then call test_failed '41'
if c \== '' then call test_failed '42'
if d \== '' then call test_failed '43'
if e \== '' then call test_failed '44'
if f \== '' then call test_failed '45'
if g \== 3 then call test_failed '46'
if h \== '' then call test_failed '47'
if i \== '' then call test_failed '48'
return
