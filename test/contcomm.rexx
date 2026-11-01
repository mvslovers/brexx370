say '----------------------------------------'
say 'File contcomm.rexx'
/* A comma at the end of a line is a continuation and is replaced by a    */
/* blank, it is no argument separator (#513, #487). The RXLIB and SAMPLES */
/* members that were split after an argument comma passed two arguments   */
/* as one. The cure is a comma that starts the next line, or two commas   */
/* at the end of the line (scripts/rexxcont.py checks the members).       */
say 'Testing a comma at the end of a line ...'
fail_count=0

/* the failure: the continuation joins the last two arguments */
call keep 'x','y',
          'z'
if lastn \== 2 then call test_failed '1 count' lastn
if lastv \== 'x y z' then call test_failed '1 value' lastv

/* the cures */
call keep 'x','y',
          ,'z'
if lastn \== 3 then call test_failed '2 count' lastn
if lastv \== 'x y z' then call test_failed '2 value' lastv
call keep 'x','y',,
          'z'
if lastn \== 3 then call test_failed '3 count' lastn
if lastv \== 'x y z' then call test_failed '3 value' lastv

/* in a function call, and after THEN */
r=keep('x','y',
       'z')
if lastn \== 2 then call test_failed '4 count' lastn
r=keep('x','y',
       ,'z')
if lastn \== 3 then call test_failed '5 count' lastn
if 1=1 then call keep 'x',
                      ,'y'
if lastn \== 2 then call test_failed '6 count' lastn

/* an operand before the comma and nothing after it: nothing joins */
r=keep('x','y',
       )
if lastn \== 2 then call test_failed '7 count' lastn

/* after an operator the continuation is what was meant */
s='ROWS '||,
  'abc'
if s \== 'ROWS abc' then call test_failed '8' s

say 'Done contcomm.rexx'
exit fail_count

keep:
lastn=arg()
lastv=arg(1) arg(2) arg(3)
lastv=strip(lastv)
return lastn

test_failed:
say 'failed in test' arg(1)
fail_count=fail_count+1
return
