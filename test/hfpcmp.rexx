say '----------------------------------------'
say 'File hfpcmp.rexx'
/* #456: the numeric comparison formed big*100 and ra-rb on the S/370
   float, which overflow above 7.2E+73 and for operands of opposite sign
   above 3.6E+75. That is a program check (S0CC) that no mask
   suppresses. A comparison answers now, for every value a number can
   hold. A literal from 1E75 on is not a number (_Lisnum), so the values
   between 1E75 and 7.2E75 are computed here. */
err = 0
call chk "9E74 > 8E74",              1
call chk "8E74 > 9E74",              0
call chk "8E74 < 9E74",              1
call chk "9E74 = 9E74",              1
call chk "9E74 = 8E74",              0
call chk "9E74 \= 8E74",             1
call chk "9E74 >= 8E74",             1
call chk "-9E74 < -8E74",            1
call chk "-9E74 > -8E74",            0
call chk "(7E74*10) > (6E74*10)",              1
call chk "(7E74*10) = (7E74*10)",              1
call chk "9E74 = 9.000000000000001E74", 1
call chk "10**75 > 0",               1
call chk "0 < 10**75",               1
call chk "10**75 = 0",               0
call chk "-(10**75) < 0",            1
call chk "0 > -(10**75)",            1
call chk "(4E74*10) > -(4E74*10)",             1
call chk "-(4E74*10) < (4E74*10)",             1
call chk "-(4E74*10) > (4E74*10)",             0
call chk "(4E74*10) = -(4E74*10)",             0
call chk "(7E74*10) > -(7E74*10)",             1
call chk "-(7E74*10) < (7E74*10)",             1
call chk "(1E74*10) > -(1E74*10)",             1
call chk "1E-70 < -1E-70",           0
call chk "1E-70 > -1E-70",           1
call chk "1E-70 = 1.000000000000001E-70", 1
call chk "1E70 = 1.000000001E70",    0
call chk "100.5-50.6 = 49.9",        1
call chk "5 > 3",                    1
call chk "-5 < 3",                   1
/* the same through strings that are numbers */
call chk "'9E74' > '8E74'",          1
call chk "'4E74' > '-4E74'",         1
say 'Done hfpcmp.rexx'
exit err

chk:
parse arg clause, want
signal on syntax name bad
interpret 'x = (' clause ')'
signal off syntax
if x == want then say left('HFPCMP',8) '-' left(clause,34) '.. PASS'
else do
   say left('HFPCMP',8) '-' left(clause,34) '.. *FAIL* got' x 'want' want
   err = err + 1
end
return
bad:
say left('HFPCMP',8) '-' left(clause,34) '.. *FAIL* error' rc
err = err + 1
return
