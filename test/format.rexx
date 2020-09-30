say '----------------------------------------'
say 'File format.rexx'
/* FORMAT */
rc = 0
  say 'Look for FORMAT OK'
/* These from the Rexx book. */
 if format('3',4) \== '   3'              then do
    rc = 8
    say 'failed in test 1 '
  end
 if format('1.73',4,0) \== '   2'         then do
    rc = 8
    say 'failed in test 2 '
  end
 if format('1.73',4,3) \== '   1.730'     then do
    rc = 8
    say 'failed in test 3 '
  end
 if format('-.76',4,1) \== '  -0.8'       then do
    rc = 8
    say 'failed in test 4 '
  end
 if format('3.03',4) \== '   3.03'        then do
    rc = 8
    say 'failed in test 5 '
  end
 if format(' - 12.73',,4) \== '-12.7300'  then do
    rc = 8
    say 'failed in test 6 '
  end
 if format(' - 12.73') \== '-12.73'       then do
    rc = 8
    say 'failed in test 7 '
  end
 if format('0.000') \== '0'               then do
    rc = 8
    say 'failed in test 8 '
  end
 if format('12345.73',,,2,2) \== '1.234573E+04'  then do
    rc = 8
    say 'failed in test 9 '
  end
 if format('12345.73',,3,,0) \== '1.235E+4'  then do
    rc = 8
    say 'failed in test 10 '
  end
 if format('1.234573',,3,,0) \== '1.235'  then do
    rc = 8
    say 'failed in test 11 '
  end
 if format('123.45',,3,2,0) \== '1.235E+02'  then do
    rc = 8
    say 'failed in test 12 '
  end
 if format('1.2345',,3,2,0) \== '1.235    '  then do
    rc = 8
    say 'failed in test 13 '
  end
 if format('12345.73',,,3,6) \== '12345.73'  then do
    rc = 8
    say 'failed in test 14 '
  end
 if format('1234567e5',,3,0) \== '123456700000.000'  then do
    rc = 8
    say 'failed in test 15 '
 end
 if format(12.34) \== '12.34'  then do
    rc = 8
    say 'failed in test 16 '
 end
 if format(12.34,4) \== '  12.34'  then do
    rc = 8
    say 'failed in test 17 '
 end
 if format(12.34,4,4) \== '  12.3400'  then do
    rc = 8
    say 'failed in test 18 '
 end
 if format(12.34,4,1) \== '  12.3'  then do
    rc = 8
    say 'failed in test 19 '
 end
 if format(12.35,4,1) \== '  12.4'  then do
    rc = 8
    say 'failed in test 20 '
 end
 if format(12.34,,4) \== '12.3400'  then do
    rc = 8
    say 'failed in test 21 '
 end
 if format(12.34,4,0) \== '  12'  then do
    rc = 8
    say 'failed in test 22 '
 end
 if format(99.995,3,2) \== '100.00'  then do
    rc = 8
    say 'failed in test 23 '
 end
 if format(0.111,,4) \== '0.1110'  then do
    rc = 8
    say 'failed in test 24 '
 end
 if format(0.0111,,4) \== '0.0111'  then do
    rc = 8
    say 'failed in test 25 '
 end
 if format(0.00111,,4) \== '0.0011'  then do
    rc = 8
    say 'failed in test 26 '
 end
 if format(0.000111,,4) \== '0.0001'  then do
    rc = 8
    say 'failed in test 27 '
 end
 if format(0.0000111,,4) \== '0.0000'  then do
    rc = 8
    say 'failed in test 28 '
 end
 if format(0.00000111,,4) \== '0.0000'  then do
    rc = 8
    say 'failed in test 29 '
 end
 if format(0.555,,4) \== '0.5550'  then do
    rc = 8
    say 'failed in test 30 '
 end
 if format(0.0555,,4) \== '0.0555'  then do
    rc = 8
    say 'failed in test 31 '
 end
 if format(0.00555,,4) \== '0.0056'  then do
    rc = 8
    say 'failed in test 32 '
 end
 if format(0.000555,,4) \== '0.0006'  then do
    rc = 8
    say 'failed in test 33 '
 end
 if format(0.0000555,,4) \== '0.0001'  then do
    rc = 8
    say 'failed in test 34 '
 end
 if format(0.00000555,,4) \== '0.0000'  then do
    rc = 8
    say 'failed in test 35 '
 end
 if format(0.999,,4) \== '0.9990'  then do
    rc = 8
    say 'failed in test 36 '
 end
 if format(0.0999,,4) \== '0.0999'  then do
    rc = 8
    say 'failed in test 37 '
 end
 if format(0.00999,,4) \== '0.0100'  then do
    rc = 8
    say 'failed in test 38 '
 end
 if format(0.000999,,4) \== '0.0010'  then do
    rc = 8
    say 'failed in test 39 '
 end
 if format(0.0000999,,4) \== '0.0001'  then do
    rc = 8
    say 'failed in test 40 '
 end
 if format(0.00000999,,4) \== '0.0000'  then do
    rc = 8
    say 'failed in test 41 '
 end
 if format(0.455,,4) \== '0.4550'  then do
    rc = 8
    say 'failed in test 42 '
 end
 if format(0.0455,,4) \== '0.0455'  then do
    rc = 8
    say 'failed in test 43 '
 end
 if format(0.00455,,4) \== '0.0046'  then do
    rc = 8
    say 'failed in test 44 '
 end
 if format(0.000455,,4) \== '0.0005'  then do
    rc = 8
    say 'failed in test 45 '
 end
 if format(0.0000455,,4) \== '0.0000'  then do
    rc = 8
    say 'failed in test 46 '
 end
 if format(0.00000455,,4) \== '0.0000'  then do
    rc = 8
    say 'failed in test 47 '
 end
 if format(1.00000045,,6) \== '1.000000'  then do
    rc = 8
    say 'failed in test 48 '
 end
 if format(1.000000045,,7) \== '1.0000001'  then do
    rc = 8
    say 'failed in test 49 '
 end
 if format(1.0000000045,,8) \== '1.00000000'  then do
    rc = 8
    say 'failed in test 50 '
 end
 if format(12.34,,,,0) \== '1.234E+1'  then do
    rc = 8
    say 'failed in test 51 '
 end
 if format(12.34,,,3,0) \== '1.234E+001'  then do
    rc = 8
    say 'failed in test 52 '
 end
 if format(12.34,,,3,) \== '12.34'  then do
    rc = 8
    say 'failed in test 53 '
 end
 if format(1.234,,,3,0) \== '1.234     '  then do
    rc = 8
    say 'failed in test 54 '
 end
 if format(12.34,3,,,0) \== '  1.234E+1'  then do
    rc = 8
    say 'failed in test 55 '
 end
 if format(12.34,,2,,0) \== '1.23E+1'  then do
    rc = 8
    say 'failed in test 56 '
 end
 if format(12.34,,3,,0) \== '1.234E+1'  then do
    rc = 8
    say 'failed in test 57 '
 end
 if format(12.34,,4,,0) \== '1.2340E+1'  then do
    rc = 8
    say 'failed in test 58 '
 end
 if format(12.345,,3,,0) \== '1.235E+1'  then do
    rc = 8
    say 'failed in test 59 '
 end
 if format(99.999,,,,) \== '99.999'  then do
    rc = 8
    say 'failed in test 60 '
 end
 if format(99.999,,2,,) \== '100.00'  then do
    rc = 8
    say 'failed in test 61 '
 end
 if format(99.999,,2,,2) \== '1.00E+2'  then do
    rc = 8
    say 'failed in test 62 '
 end
 if format(.999999,,4,2,2) \== '1.0000'  then do
    rc = 8
    say 'failed in test 63 '
 end
 if format(.999999,,5,2,2) \== '1.00000'  then do
    rc = 8
    say 'failed in test 64 '
 end
 if format(.9999999,,5,2,2) \== '1.00000'  then do
    rc = 8
    say 'failed in test 65 '
 end
 if format(.999999,,6,2,2) \== '0.999999'  then do
    rc = 8
    say 'failed in test 66 '
 end
 if format(90.999,,0) \== '91'  then do
    rc = 8
    say 'failed in test 67 '
 end
 if format(0099.999,5,3,,) \== '   99.999'  then do
    rc = 8
    say 'failed in test 68 '
 end
 if format(0.0000000000000000001,4) \== '   1E-19'  then do
    rc = 8
    say 'failed in test 69 '
 end
 if format(0.0000000000000000001,4,4) \== '   1.0000E-19'  then do
    rc = 8
    say 'failed in test 70 '
 end
 if format(0.0000001,4,,,3) \== '   1E-7'  then do
    rc = 8
    say 'failed in test 71 '
 end
 if format(0.0000001,4,4,,3) \== '   1.0000E-7'  then do
    rc = 8
    say 'failed in test 72 '
 end
 if format(0.000001,4,4,,3) \== '   0.0000'  then do
    rc = 8
    say 'failed in test 73 '
 end
 if format(0.0000001,4,5,,2) \== '   1.00000E-7'  then do
    rc = 8
    say 'failed in test 74 '
 end
 if format(0.0000001,4,4,4,3) \== '   1.0000E-0007'  then do
    rc = 8
    say 'failed in test 75 '
 end
 if format(1000,4,4,,3) \== '   1.0000E+3'  then do
    rc = 8
    say 'failed in test 76 '
 end
 if format(0.0000000000000000000001) \== '1E-22'  then do
    rc = 8
    say 'failed in test 77 '
 end
 if format(0.0000000000000000000001,,,0,) \==,
  '0.0000000000000000000001'  then do
    rc = 8
    say 'failed in test 78 '
 end
 if format(0.0000001,,,0,3) \== '0.0000001'  then do
    rc = 8
    say 'failed in test 79 '
 end
 if format('.00001',,,2,9) \== '0.00001'  then do
    rc = 8
    say 'failed in test 80 '
 end
 if format('.000001',,,2,9) \== '0.000001'  then do
    rc = 8
    say 'failed in test 81 '
 end
 if format('.0000001',,,2,9) \== '1E-07'  then do
    rc = 8
    say 'failed in test 82 '
 end
 if format('.00000001',,,2,9) \== '1E-08'  then do
    rc = 8
    say 'failed in test 83 '
/* These from Kurt Maerker */
 end
 if format(99.999,,2,,2) \== '1.00E+2'  then do
    rc = 8
    say 'failed in test 84 '
 end
 if format(.999999,,4,2,2) \== '1.0000'  then do
    rc = 8
    say 'failed in test 85 '
 end
 if format(.9999999,,5,2,2) \== '1.00000'  then do
    rc = 8
    say 'failed in test 86 '
 end
 if format('.0000001',,,2,9) \== '1E-07'  then do
    rc = 8
    say 'failed in test 87 '
 end
 if format('.00000001',,,2,9) \== '1E-08'  then do
    rc = 8
    say 'failed in test 88 '
 end
 if format(9.9999999,1,10,1,1) \== '9.9999999000'  then do
    rc = 8
    say 'failed in test 89 '
 end
 if format(9.9999999,1,10,1,2) \== '9.9999999000'  then do
    rc = 8
    say 'failed in test 90 '
 end
 if format(9.9999999,1,10,2,1) \== '9.9999999000'  then do
    rc = 8
    say 'failed in test 91 '
 end
 if format(9.9999999,1,10,2,2) \== '9.9999999000'  then do
    rc = 8
    say 'failed in test 92 '
 end
 if format(9.9999999,1,10,2,3) \== '9.9999999000'  then do
    rc = 8
    say 'failed in test 93 '
 end
 if format(9.9999999,1,10,4,3) \== '9.9999999000'  then do
    rc = 8
    say 'failed in test 94 '
 end
 if format(9.9999999,1,8,1,1) \== '9.99999990'  then do
    rc = 8
    say 'failed in test 95 '
 end
 if format(9.9999999,1,8,1,2) \== '9.99999990'  then do
    rc = 8
    say 'failed in test 96 '
 end
 if format(9.99999999,1,10,1,1) \== '9.9999999900'  then do
    rc = 8
    say 'failed in test 97 '
 end
 if format(9.99999999,1,10,1,2) \== '9.9999999900'  then do
    rc = 8
    say 'failed in test 98 '
 end
 if format(9.99999999,1,10,1,3) \== '9.9999999900'  then do
    rc = 8
    say 'failed in test 99 '
 end
 if format(9.99999999,1,10,2,1) \== '9.9999999900'  then do
    rc = 8
    say 'failed in test 100 '
 end
 if format(9.99999999,1,10,2,2) \== '9.9999999900'  then do
    rc = 8
    say 'failed in test 101 '
 end
 if format(9.99999999,1,10,2,3) \== '9.9999999900'  then do
    rc = 8
    say 'failed in test 102 '
 end
 if format(9.99999999,1,10,3,1) \== '9.9999999900'  then do
    rc = 8
    say 'failed in test 103 '
 end
 if format(9.99999999,1,10,3,2) \== '9.9999999900'  then do
    rc = 8
    say 'failed in test 104 '
 end
 if format(9.99999999,1,10,3,3) \== '9.9999999900'  then do
    rc = 8
    say 'failed in test 105 '
 end
 if format(9.99999999,1,10,4,3) \== '9.9999999900'  then do
    rc = 8
    say 'failed in test 106 '
 end
 if format(9.99999999,1,10,5,3) \== '9.9999999900'  then do
    rc = 8
    say 'failed in test 107 '
 end
 if format(9.99999999,1,8,1,1) \== '9.99999999'  then do
    rc = 8
    say 'failed in test 108 '
 end
 if format(9.99999999,1,8,1,2) \== '9.99999999'  then do
    rc = 8
    say 'failed in test 109 '
 end
 if format(9.99999999,1,8,2,1) \== '9.99999999'  then do
    rc = 8
    say 'failed in test 110'
end
say 'FORMAT OK'
exit rc
