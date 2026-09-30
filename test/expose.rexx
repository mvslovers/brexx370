say '----------------------------------------'
say 'File expose.rexx'
/* from RossPatterson/CMS-370-BREXX tests/expose_.exec (#189) */
/* rexx
 * this procedure tests the expose lists feature
 * which was a later addition, not yet available
 * in Rexx 3.40
 */
say 'Testing EXPOSE ...'
fail_count=0

aap = 'noot'
if testex1() \== 'noot' then call test_failed 1
if testex2() \== 'AAP'  then call test_failed 2
x= 'aap'
if testex3() \== 'noot' then call test_failed 3

say 'Done expose.rexx'
exit fail_count

test_failed:
say 'failed in test' arg(1)
fail_count=fail_count+1
return

testex1: procedure expose aap
return aap

testex2: procedure
return aap

testex3: procedure expose (x)
return aap
