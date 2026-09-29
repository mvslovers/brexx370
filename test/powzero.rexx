say '----------------------------------------'
say 'File powzero.rexx'
/* 0 to a negative power is error 42 (vlachoudis/brexx PR 23), not a
   floating point divide exception (S0CF) */
signal on syntax
x = 0**-1
say left('POWZERO',8) '- 0**-1 .. *FAIL* no error, got' x
exit 8
syntax:
if rc == 42 then say left('POWZERO',8) '- 0**-1 .. PASS (error 42)'
else do
   say left('POWZERO',8) '- 0**-1 .. *FAIL* error' rc
   exit 8
end
say 'Done powzero.rexx'
exit 0
