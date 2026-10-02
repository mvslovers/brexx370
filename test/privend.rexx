/* REXX - ending with PRIVILEGE('ON') still set (#191, P5)             */
/* BREXX ended in supervisor state, key 0, and the cleanup after it    */
/* abended S30A. It must end with RC 0. If PRIVILEGE('ON') is refused  */
/* here, the test cannot measure anything and ends with RC 3 (FAIL).   */
say '----------------------------------------'
say 'File privend.rexx'
p = privilege('ON')
say 'PRIVEND  - privilege(ON) rc' p
if p \= 0 then exit 3
say 'PRIVEND  - ending without privilege(OFF)'
exit 0
