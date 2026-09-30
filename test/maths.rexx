say '----------------------------------------'
say 'File maths.rexx'
/* from RossPatterson/CMS-370-BREXX tests/maths_.exec (#189) */
/* MATHS TEST */
say 'Testing MATHS ...'
fail_count=0
NUMERIC DIGITS 15
if 5 * 7 \= 35                             then call test_failed '1'
if 46340 * 46340 \= 2147395600             then call test_failed '2'
if 46341 * 46341 \= 2147488281             then call test_failed '3'
if 737787 * 86400 * 1000000 \= ,
                      63744796800000000    then call test_failed '4'
if 1.23 * 2 \= 2.46                        then call test_failed '5'

if 14 / 7 \= 2                             then call test_failed '6'
if 2147395600 / 46340 \= 46340             then call test_failed '7'
if 2147488281 / 46341 \= 46341             then call test_failed '8'
if 5 / 2 \= 2.5                            then call test_failed '9'
if 1 / 3 \= 0.333333333333333 then call test_failed '10'

if 100 + 50 \= 150                         then call test_failed '11'
if '100' + '50' \= 150                     then call test_failed '12'
if 100.5 + 50 \= 150.5                     then call test_failed '13'
if 100.5 + 50.5 \= 151                     then call test_failed '14'
if 100.5 + 50.6 \= 151.1                   then call test_failed '15'
if 2147480001 + 10000 \= 2147490001 then call test_failed '16'

if 100 - 50 \= 50                          then call test_failed '17'
if '100' - '50' \= 50                      then call test_failed '18'
if 100.5 - 50 \= 50.5                      then call test_failed '19'
if 100.5 - 50.5 \= 50                      then call test_failed '20'
if 100.5 - 50.6 \= 49.9 then call test_failed '21'
if -2147480001 - 10000 \= -2147490001 then call test_failed '22'

/* #254: % truncates, it does not round the quotient */
if 86399 % 60 \== 1439                     then call test_failed '23'
if -86399 % 60 \== -1439                   then call test_failed '24'
if 86399.0 % 60 \== 1439                   then call test_failed '25'
if 199 % 2 \== 99                          then call test_failed '26'
if 0.3 % 0.1 \== 3                         then call test_failed '27'
if 86399000000 % 1000000 \== 86399         then call test_failed '28'

say 'Done maths.rexx'
exit fail_count
test_failed:
say 'failed in test' arg(1)
fail_count=fail_count+1
return
