say '----------------------------------------'
say 'File tmult.rexx'
/* from RossPatterson/CMS-370-BREXX tests/t_mult.exec (#189) */
/* REXX */
/* Test case generated from t_mult.in */
say 'Testing T_MULT ...'

parse source system .
fail_count=0
numeric digits 9

Signal On Syntax

if system = 'CMS' then do
    say 'skipped tests 1-3 due to numeric precision in bREXX'
    signal t3z
end
/* #249: Call ver  123456789 * 0.00005 * 3333.333 * 21.43 , 440946453 ,  1 */
/* #249: Call ver  123456789 * 0.00005 * 21.43 * 3333.333 , 440946453 ,  2 */
/* #249: Call ver  123456789 * 3333.333 * 0.00005 * 21.43 , 440946455 ,  3 */
t3z: nop
Call ver  123456789 * 3333.333 * 21.43 * 0.00005 , 440946454 ,  4
if system = 'CMS' then do
    say 'skipped test 5 due to numeric precision in bREXX'
    signal t5z
end
/* #249: Call ver  123456789 * 21.43 * 0.00005 * 3333.333 , 440946456 ,  5 */
t5z: nop
Call ver  123456789 * 21.43 * 3333.333 * 0.00005 , 440946454 ,  6
if system = 'CMS' then do
    say 'skipped tests 7-9 due to numeric precision in bREXX'
    signal t9z
end
/* #249: Call ver  0.00005 * 123456789 * 3333.333 * 21.43 , 440946453 ,  7 */
/* #249: Call ver  0.00005 * 123456789 * 21.43 * 3333.333 , 440946453 ,  8 */
/* #249: Call ver  0.00005 * 3333.333 * 123456789 * 21.43 , 440946453 ,  9 */
t9z: nop
Call ver  0.00005 * 3333.333 * 21.43 * 123456789 , 440946454 , 10
if system = 'CMS' then do
    say 'skipped test 11 due to numeric precision in bREXX'
    signal t11z
end
/* #249: Call ver  0.00005 * 21.43 * 123456789 * 3333.333 , 440946453 , 11 */
t11z: nop
Call ver  0.00005 * 21.43 * 3333.333 * 123456789 , 440946454 , 12
if system = 'CMS' then do
    say 'skipped test 13 due to numeric precision in bREXX'
    signal t13z
end
/* #249: Call ver  3333.333 * 123456789 * 0.00005 * 21.43 , 440946455 , 13 */
t13z: nop
Call ver  3333.333 * 123456789 * 21.43 * 0.00005 , 440946454 , 14
if system = 'CMS' then do
    say 'skipped test 15 due to numeric precision in bREXX'
    signal t15z
end
/* #249: Call ver  3333.333 * 0.00005 * 123456789 * 21.43 , 440946453 , 15 */
t15z: nop
Call ver  3333.333 * 0.00005 * 21.43 * 123456789 , 440946454 , 16
Call ver  3333.333 * 21.43 * 123456789 * 0.00005 , 440946454 , 17
Call ver  3333.333 * 21.43 * 0.00005 * 123456789 , 440946454 , 18
if system = 'CMS' then do
    say 'skipped test 19 due to numeric precision in bREXX'
    signal t19z
end
/* #249: Call ver  21.43 * 123456789 * 0.00005 * 3333.333 , 440946456 , 19 */
t19z: nop
Call ver  21.43 * 123456789 * 3333.333 * 0.00005 , 440946454 , 20
if system = 'CMS' then do
    say 'skipped test 21 due to numeric precision in bREXX'
    signal t21z
end
/* #249: call ver  21.43 * 0.00005 * 123456789 * 3333.333 , 440946453 , 21 */
t21z: nop
Call ver  21.43 * 0.00005 * 3333.333 * 123456789 , 440946454 , 22
Call ver  21.43 * 3333.333 * 123456789 * 0.00005 , 440946454 , 23
Call ver  21.43 * 3333.333 * 0.00005 * 123456789 , 440946454 , 24

Call over

over:
Parse Arg how
say 'Done tmult.rexx'
If how<>'' Then Do
  Say how
  Exit 12
  End
Exit fail_count

syntax:
If id<>'' Then Do
  Signal On Syntax
  Interpret 'Signal R'id
  End
Else Do
  say 'Unexpected syntax error in line' sigl
  fail_count=fail_count+1
  Call over 'premature end'
  End

ver:
If arg(1)=arg(2) Then Return
say 'failed in test' arg(3)':' sourceline(sigl)
say 'expected:' arg(2)
say '   found:' arg(1)
fail_count=fail_count+1
Return

err:
  Parse Arg w
  Say 'Expected' w 'condition not raised id='id
  fail_count=fail_count+1
  Return
