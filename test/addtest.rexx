say '----------------------------------------'
say 'File addtest.rexx'
/* from RossPatterson/CMS-370-BREXX tests/add_test.exec (#189) */
/* REXX */
/* Test case based on code generated from add_test.in */
say 'Testing ADD_TEST ...'

parse source system .
Signal On Syntax
fail_count=0

/* #249: Call ver 1000000000-1              ,  1.00000000E+9 ,  1 */
/* #249: Call ver 100000000e1-1             ,  1.00000000E+9 ,  2 */
/* #249: Call ver 1.000000000e9-1           ,  1.00000000E+9 ,  3 */
/* #249: Call ver 1.0000000000e9-1          ,  1.00000000E+9 ,  4 */
/* #249: Call ver 1.00000000000e9-1         ,  1.00000000E+9 ,  5 */
/* #249: Call ver 1e9-1                     ,  1.00000000E+9 ,  6 */
Call ver 1000000000-10             ,  999999990     ,  8
Call ver 100000000e1-10            ,  999999990     ,  9
Call ver 1.000000000e9-10          ,  999999990     , 10
Call ver 1.0000000000e9-10         ,  999999990     , 11
Call ver 1.00000000000e9-10        ,  999999990     , 12
Call ver 1e9-10                    ,  999999990     , 13
if system = 'CMS' then do
    say 'skipped tests 15-20 due to numeric precision in bREXX'
    signal t20z
end
/* #249: Call ver 1000000000-999999999      ,  0             , 15 */
/* #248 #249: Call ver 100000000e1-999999999     ,  0             , 16 */
/* #249: Call ver 1.000000000e9-999999999   ,  0             , 17 */
/* #249: Call ver 1.0000000000e9-999999999  ,  0             , 18 */
/* #249: Call ver 1.00000000000e9-999999999 ,  0             , 19 */
/* #249: Call ver 1e9-999999999             ,  0             , 20 */
t20z: nop
Call ver 1000000000-999999990      ,  10            , 21
/* #248: Call ver 100000000e1-999999990     ,  10            , 22 */
Call ver 1.000000000e9-999999990   ,  10            , 23
Call ver 1.0000000000e9-999999990  ,  10            , 24
Call ver 1.00000000000e9-999999990 ,  10            , 25
Call ver 1e9-999999990             ,  10            , 26
if system = 'CMS' then do
    say 'skipped tests 27-30 due to numeric precision in bREXX'
    signal t30z
end
/* #249: Call ver 1e9-5                     ,  1.00000000E+9 , 27 */
/* #249: Call ver 1e9-6                     ,  999999990     , 28 */
/* #249: Call ver 1e9-15                    ,  999999990     , 29 */
/* #249: Call ver 1e9-16                    ,  999999980     , 30 */
t30z: nop

id=31
1e9+aaa
Call err "SYNTAX" ID
R31:
id=''

Call over
/* notreached */

over:
Parse Arg how
say 'Done addtest.rexx'
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
