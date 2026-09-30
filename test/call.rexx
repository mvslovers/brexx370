say '----------------------------------------'
say 'File call.rexx'
/* from RossPatterson/CMS-370-BREXX tests/call_.exec (#189) */
/* CALL_ EXEC */
parse source system calltype .
if calltype = 'FUNCTION' | calltype = 'SUBROUTINE' then do
    parse arg testcase .
    if testcase = '6' then signal tc6a
    retun 'unknown call:' calltype arg(1)
end
say 'Testing CALL ...'
fail_count=0
if tc1() \== 1 then call test_failed '1'
if tc2() \== 1 then call test_failed '2'
if tc3() \== 1 then call test_failed '3'
if tc4() \== 1 then call test_failed '4'   /* #235 */
signal tc5

/* argument check */
tc1:
call tc1a 'a', 'B', c, 1, 2.3
return result
tc1a: ;
if arg(1) \== 'a' then return 0
if arg(2) \== 'B' then return 0
if arg(3) \== 'C' then return 0
if arg(4) \== '1' then return 0
if arg(5) \== '2.3' then return 0
return 1


/* call sets sigl */
/* Do not move this test around - it knows its line numbers! */
tc2:
call tc2a
return (result == 35)
tc2a: procedure expose sigl
return sigl

/* call sets sigl deep calls */
/* Do not move this test around - it knows its line numbers! */
tc3: ;
call tc3a
return (result \== 0)
tc3a: procedure expose sigl
if sigl \== 43 then return 0
call tc3b
if result \== 0 then return result
return (sigl == 43)
tc3b: procedure expose sigl
return (sigl == 47)

/* call passing sigl as arg */
/* Do not move this test around - it knows its line numbers! */
tc4:
call tc4a
return result
tc4a: procedure expose sigl
call tc4b sigl
return result
tc4b: procedure
return (arg(1) == 56)

/* bREXX issue 90 */
tc5:
signal on syntax name tc5b
call nolbl
call test_failed '5A'
signal tc5c
tc5b:
/* #236: error 43, not 51 */
if rc \== 43 then call test_failed '5B.  RC =' rc
tc5c:
signal on syntax name tc5d
call nosuchlabel
call test_failed '5C'
signal tc5d
tc5d:
/* #236: error 43, not 51 */
if rc \== 43 then call test_failed '5D.  RC =' rc
tc5e:

/* bREXX issue 105 */
/* test 6 calls this program as an external routine: left out on MVS,
   where the test runs from a PDS member outside the external search */
signal tc6e
tc6a:
parse arg . rest
return rest
tc6e:

/* bREXX Issue 104 */
/* Changed to TSO/E: the source string "is fixed (does not change) while
   the program is running", so an internal routine sees the call type
   of the program (Ross's version expected SUBROUTINE/FUNCTION and said
   itself that this is wrong) */
parse source . t7main .
call tc7a
/* #237 */
if result \==1 then call test_failed '7A'
/* #237 */
if tc7b() \==1 then call test_failed '7B'
signal tc7e
tc7a:
parse source . calltype .
return calltype == t7main
tc7b:
parse source . calltype .
return calltype == t7main
tc7e:

/* bREXX Issue 119 */
call tc8a
if result \== 1 then call test_failed '8'
signal tc8z
tc8a: procedure
tc8v = 'XXX'
call tc8b tc8v
return result == 'XXX'
tc8b:
tc8v = 'YYY'
return arg(1)
tc8z:

/* #255: a function or CALL name in quotes skips the internal labels */
if 'LENGTH'('abc') \== 3 then call test_failed '9A'
if length('abc') \== 'internal' then call test_failed '9B'
call 'LENGTH' 'abcd'
if result \== 4 then call test_failed '9C'

say 'Done call.rexx'
exit fail_count

test_failed:
say 'failed in test' arg(1)
fail_count=fail_count+1
return

length: return 'internal'   /* #255: hides LENGTH only when unquoted */
