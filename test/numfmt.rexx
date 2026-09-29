say '----------------------------------------'
say 'File numfmt.rexx'
/* #156: a real prints with at most 15 significant digits, placed by */
/* the REXX rules (TSO/E REXX Reference, Numbers and Arithmetic):     */
/* exponential form only past NUMERIC DIGITS integer places or twice  */
/* NUMERIC DIGITS decimal places.                                     */
r=0
call check 0.1+0.2,   '0.3',                  1
call check 1/3,       '0.333333333333333',    2
call check 2/3,       '0.666666666666667',    3
call check -1/3,      '-0.333333333333333',   4
call check 2.5*1.1,   '2.75',                 5
call check 1/4,       '0.25',                 6
call check 123.456*1, '123.456',              7
call check 1e20*1,    '100000000000000000000', 8
call check 1e-5*1,    '0.00001',              9
call check 2**60,     '1152921504606850000',  10
call check 0*1.5,     '0',                    11
call check 5000*2**0, '5000',                 12
f = 1
do i = 1 to 25; f = f * i; end
call check f,         '15511210043331000000000000', 13
y = 7.7 + 0
call check y,         '7.7',                  14
numeric digits 20
g = 1
do i = 1 to 20; g = g * i; end
call check g,         '2432902008176640000',  15
call check f*1,       '1.5511210043331E+25',  16
numeric digits 9
call check 0.1+0.2,   '0.3',                  17
call check 1/3,       '0.333333333',          18
call check 2**60,     '1.1529215E+18',        19
call check 1e9*1,     '1E+9',                 20
call check 1e-5*1,    '0.00001',              21
call check 123456.789*1000,  '123456789',     22
call check 123456.789*10000, '1.23456789E+9', 23
call check 0.5**20,   '0.000000953674316',    24
numeric digits 1
call check 2.5*0.1,   '0.3',                  25
/* a literal is a string: NUMERIC DIGITS does not change how it prints */
call check 2.5,       '2.5',                  26
numeric digits 9
call check 10000000.55, '10000000.55',        27
call check 3.14159265358979, '3.14159265358979', 28
call check 10000000.45 || '', '10000000.45',  29
/* blank concatenation: this showed 10000000.4 (mvsdev JOB00747); */
/* the abuttal with || in test 29 does not take the same path     */
call check 'a' 10000000.45, 'a 10000000.45',  30
x = 10000000.45
call check x,         '10000000.45',          31
say 'Done numfmt.rexx'
exit r
check:
  parse arg got, want, tno
  if got == want then say 'NUMFMT   - test' right(tno,3) '.. PASS'
  else do
    say 'NUMFMT   - test' right(tno,3) '.. *FAIL* - expected "'want'"',
        'actual "'got'"'
    r = max(r,8)
  end
  return
