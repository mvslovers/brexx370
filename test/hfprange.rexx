say '----------------------------------------'
say 'File hfprange.rexx'
/* #180, #87: a number outside the S/370 float range (about 5.4E-79 to
   7.2E+75) abended BREXX with S0CC while the program was compiled,
   because every literal, quoted or not, is checked by _Lisnum().
   A value too large is a string now, one too small is 0. */
err = 0
call check "'030E80'='FFFFFF'", '030E80' = 'FFFFFF',          0
call check "'1e76' N",          datatype('1e76','N'),          0
call check "'1E80' N",          datatype('1E80','N'),          0
call check "'1E75' N",          datatype('1E75','N'),          0
call check "'9E74' N",          datatype('9E74','N'),          1
call check "'0..01E74' N",      datatype('000000001E74','N'),  1
call check "'1E99999999999' N", datatype('1E99999999999','N'), 0
call check "'1e-79' N",         datatype('1e-79','N'),         1
call check "'1e-79'+0",         '1e-79' + 0,                   0
call check '1e-79+0',           1e-79 + 0,                     0
call check "'1e-78'>0",         '1e-78' > 0,                   1
call check "'1.5E-77'>0",       '1.5E-77' > 0,                 1
call check "'1E-9999999999'+0", '1E-9999999999' + 0,           0
call check "'0E999'+0",         '0E999' + 0,                   0
call check "'0E999' N",         datatype('0E999','N'),         1
call check "'1E3'+0",           '1E3' + 0,                     1000
call check "'12.5E-1'+0",       '12.5E-1' + 0,                 1.25
say 'Done hfprange.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('HFPRANGE',8) '-' left(what,20) '.. PASS'
else do
   say left('HFPRANGE',8) '-' left(what,20) '.. *FAIL* got "'got'"',
       'want "'want'"'
   err = err + 1
end
return
