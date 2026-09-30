say '----------------------------------------'
say 'File interpr.rexx'
/* RETURN under INTERPRET returns from the routine that holds the
   INTERPRET, at the top level it ends the program (bREXX #14, the
   tests of RossPatterson/CMS-370-BREXX interpr_) */
err = 0
interpret 'call tc1a'
call check 'CALL', result, 11
call check 'RETURN n in function', tc4(), 4
call check 'RETURN f() in function', tc5(), 5
call check 'nested INTERPRET', tc6(), 6
x7 = 'set'
call tc7
call check 'RETURN in subroutine', x7, 'set'
call tc8
call check 'RESULT from PROCEDURE', result, 'local 8'
/* #221: NUMERIC set in an INTERPRET stays after it */
numeric form engineering
interpret 'numeric form scientific; numeric digits 12; numeric fuzz 1'
call check 'NUMERIC kept', form() digits() fuzz(), 'SCIENTIFIC 12 1'
numeric digits; numeric fuzz
say 'Done interpr.rexx'
/* the program ends here with the value of ZERO() as return code */
interpret 'return zero()'
say left('INTERPR',8) '- top-level RETURN   .. *FAIL* program went on'
exit 8

zero: return err
tc1a: return 11
tc4:  interpret 'return 4'
      return 0
tc5:  interpret 'return tc5a()'
      return 0
tc5a: return 5
tc6:  interpret "interpret 'return 6'"
      return 0
tc8:  procedure
      v = 'local 8'
      interpret 'return v'
      return 'not returned'
tc7:  interpret 'return'
      x7 = 'not returned'
      return

check:
parse arg what, got, want
if got == want then say left('INTERPR',8) '-' left(what,22) '.. PASS'
else do
   say left('INTERPR',8) '-' left(what,22) '.. *FAIL* got "'got'"',
       'want "'want'"'
   err = err + 1
end
return
