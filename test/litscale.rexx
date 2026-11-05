say '----------------------------------------'
say 'File litscale.rexx'
/* #611: _Lisnum() scales a literal with a negative power of ten, 10**-e
   formed by squaring.  Squaring is what pow() did, and it is not the
   same as a loop of products: from 10**25 on the two round differently,
   so a loop moves the value of 1E-25 ... 1E-70 by up to about 60 units
   of the last place.  Each literal is shifted by powers of 16 (exact on the
   S/370 float) until its 14-digit fraction is an integer; the line has
   the shift and the fraction in hex.  The expected lines are what
   BREXX/370 3.0.0 produces. */
err = 0
call chk '1.5',                  1.5,                     '13 18000000000000'
call chk '0.1',                  0.1,                     '14 19999999999999'
call chk '0.01',                 0.01,                    '15 28F5C28F5C28F5'
call chk '123.456E-5',           123.456E-5,              '16 50E87AD32FE850'
call chk '0.000123',             0.000123,                '17 80F98FA376922D'
call chk '12345.678901234',      12345.678901234,         '10 3039ADCC78A53E'
call chk '1E-22',                1E-22,                   '32 78E480405D7B96'
call chk '1E-23',                1E-23,                   '33 C16D9A0095928E'
call chk '1E-24',                1E-24,                   '33 1357C299A88EA7'
call chk '1E-25',                1E-25,                   '34 1EF2D0F5DA7DD8'
call chk '1E-26',                1E-26,                   '35 318481895D9627'
call chk '1E-30',                1E-30,                   '38 14484BFEEBC29F'
call chk '1E-35',                1E-35,                   '43 D4AD2DBFC3D084'
call chk '1E-47',                1E-47,                   '53 E9D71B689DDE7C'
call chk '1E-53',                1E-53,                   '58 F53304714D9275'
call chk '1E-70',                1E-70,                   '72 B0AF48EC79ACF3'
call chk '1E-71',                1E-71,                   '72 11AB20E472914A'
call chk '1E-78',                1E-78,                   '78 1DA48CE468E7C6'
call chk '1.5E-77',              1.5E-77,                 '77 1BCA4416225949'
call chk '9.87654321E-40',       9.87654321E-40,          '46 56096D67422934'
call chk '3.14159265358979E-30', 3.14159265358979E-30,    '38 3FB814E810A197'
call chk '2.718281828459045E-50',2.718281828459045E-50,   '55 A2B98C3D3AFF32'
call chk '4.9E-60',              4.9E-60,                 '63 7DFBE3AAB4615A'
call chk '7.1E-78',              7.1E-78,                 '78 D276B522826D98'
say 'Done litscale.rexx'
exit err

chk:
parse arg what, x, want
n = 0
do while x >= 72057594037927936
   x = x / 16
   n = n - 1
end
do while x < 4503599627370496
   x = x * 16
   n = n + 1
end
q = trunc(x / 268435456)
lo = x - q * 268435456
got = n right(d2x(q),7,'0')right(d2x(lo),7,'0')
if got == want then say left('LITSCALE',8) '-' left(what,24) '.. PASS'
else do
   say left('LITSCALE',8) '-' left(what,24) '.. *FAIL* got "'got'"',
       'want "'want'"'
   err = err + 1
end
return
