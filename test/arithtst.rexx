say '----------------------------------------'
say 'File arithtst.rexx'
/* from RossPatterson/CMS-370-BREXX tests/arithtst.exec (#189) */
/* REXX */
/* Test case generated from arithmetic_test.in */
say 'Testing ARITHTST ...'

fail_count=0
Signal On Syntax

Call ver 12 + 8  , 20                           ,  1
Call ver 12 - 8  , 4                            ,  2
Call ver 12 * 8  , 96                           ,  3
Call ver 12 // 8 , 4                            ,  4
Call ver 12 % 8  , 1                            ,  5
Call ver 12 ** 8 , 429981696                    ,  6
Call ver 20 + 4  , 24                           ,  7
Call ver 20 - 4  , 16                           ,  8
Call ver 20 * 4  , 80                           ,  9
Call ver 20 // 4 , 0                            ,  0
Call ver 20 % 4  , 5                            , 11
Call ver 20 ** 4 , 160000                       , 12
Call ver 4  +   -17  ,  -13                     , 13
Call ver 4  -   -17  ,  21                      , 14
Call ver 4  *   -17  ,  -68                     , 15
Call ver 4  %   -17  ,  0                       , 16
/* #223 */
/* Call ver 4 / -17 , -0.23529411764705882353 , 17 */
Call ver 4  //  -17  ,  4                       , 18
/* #223, and it assumes NUMERIC DIGITS 9 */
/* Call ver 4 ** -17 , 5.82076609E-11 , 19 */
Call ver -17  +   4  ,  -13                     , 20
Call ver -17  -   4  ,  -21                     , 21
Call ver -17  *   4  ,  -68                     , 22
Call ver -17  %   4  ,  -4                      , 23
Call ver -17  /   4  ,  -4.25                   , 24
Call ver -17  //  4  ,  -1                      , 25
Call ver -17  **  4  ,  83521                   , 26

id=27
x=9 / 0
Call err "SYNTAX" ID
R27:
id=''

id=28
x=9 // 0
Call err "SYNTAX" ID
R28:
id=''

id=29
x=9 % 0
Call err "SYNTAX" ID
R29:
id=''

Call ver 0**0 , 1               , 30
Call ver 3*/* comment */*3 , 27 , 31

id = 32
x=0**-1
Call err "SYNTAX" ID
R32:
id=''

Call over

over:
Parse Arg how
say 'Done arithtst.rexx'
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
