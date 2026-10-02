/* REXX - storage freed while PRIVILEGE('ON') is set (#191, P4)        */
/* LISTVOLS abended S378 in the FREEMAIN path while privileged, not at */
/* its end. Large strings, built and dropped, make libc370 free whole  */
/* blocks. If PRIVILEGE('ON') is refused, RC 3 (FAIL).                 */
say '----------------------------------------'
say 'File privfree.rexx'
p = privilege('ON')
say 'PRIVFREE - privilege(ON) rc' p
if p \= 0 then exit 3
do i = 1 to 20
   x = copies('A', 100000 * i)
   drop x
end
call privilege 'OFF'
say 'PRIVFREE - freed while privileged .. PASS'
say 'Done privfree.rexx'
exit 0
