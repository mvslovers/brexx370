/*
 * Print all characters supported by BREXX.R(BANNER)
 */
ADDRESS MVS
call banner "ABCDEFGH"
call banner "IJKLMNOPQ"
call banner "RSTUVWXYZ"
call banner "abcdefgh"
call banner "ijklmnopq"
call banner "rstuvwxyz"
call banner "0123456789"
call banner "^£²·©Õ¶´½¾"
call banner "±¿Ð]¯×ôöÔÖ"
call banner "€®+-Æ*¬=¥%"
call banner "¢$@§&.,;:?"
call banner "(|)<>Ý¨{}!"
call banner "'ðÞ/\_#" || '"'
say "ABCDEFGH"
say "IJKLMNOPQ"
say "RSTUVWXYZ"
say "abcdefgh"
say "ijklmnopq"
say "rstuvwxyz"
say "0123456789"
say "^£²·©Õ¶´½¾"
say "±¿Ð]¯×ôöÔÖ"
say "€®+-Æ*¬=¥%"
say "¢$@§&.,;:?"
say "(|)<>Ý¨{}!"
say "'ðÞ/\_#" || '"'
