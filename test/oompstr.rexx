/* REXX - a string that doubles under PRIVILEGE('ON') ends with RC 61 (#566) */
/* MVSTEST RC=61                                                        */
/* MVSTEST OWNJOB                                                       */
/* The memory ends in a single large request, not in many small ones. A */
/* string grows by realloc, so the step ends with RC 61 and the error   */
/* message, as it does without PRIVILEGE('ON'). If PRIVILEGE('ON') is  */
/* refused, the test measures nothing and ends with RC 3 (FAIL).       */
/* Reaching the EXIT below would give RC 0.                            */
say '----------------------------------------'
say 'File oompstr.rexx'
p = privilege('ON')
say 'OOMPSTR  - privilege(ON) rc' p
if p \= 0 then exit 3
s = copies('x', 1000)
do i = 1 to 40
   s = s || s
end
say 'OOMPSTR  - string of' length(s) 'bytes .. *FAIL*'
exit 0
