say '----------------------------------------'
say 'File datatyp.rexx'
/* DATATYPE */

rc = 0

say "Look for DATATYPE OK"

/* These from the Rexx book. */

if datatype(' 12 ') \== 'NUM' then do
  say 'failed in test 1 '
  rc = 8 
end

if datatype('') \== 'CHAR' then do
  say 'failed in test 2 '
  rc = 8 
end

if datatype('123*') \== 'CHAR' then do
  say 'failed in test 3 '
  rc = 8 
end

if datatype('12.3','N') \= 1 then do
  say 'failed in test 4 '
  rc = 8 
end

if datatype('12.3','W') \= 0 then do
  say 'failed in test 5 '
  rc = 8 
end

if datatype('Fred','M') \= 1 then do
  say 'failed in test 6 '
  rc = 8 
end

if datatype('','M') \= 0 then do
  say 'failed in test 7 '
  rc = 8 
end

if datatype('Minx','L') \= 0 then do
  say 'failed in test 8 '
  rc = 8 
end

/* This one depends on which characters are "extra letters" */

if datatype('3d?','s') \= 1 then do
  say 'failed in test 9 '
  rc = 8 
end

if datatype('BCd3','X') \= 1 then do
  say 'failed in test 10 '
  rc = 8 
end

if datatype('BC d3','X') \= 1 then do
  say 'failed in test 11 '
  rc = 8 
end

/* These from Mark Hessling. */

if datatype("foobar") \== "CHAR" then do
  say 'failed in test 12 '
  rc = 8 
end

if datatype("foo bar") \== "CHAR" then do
  say 'failed in test 13 '
  rc = 8 
end

if datatype("123.456.789") \== "CHAR" then do
  say 'failed in test 14 '
  rc = 8 
end

if datatype("123.456") \== "NUM" then do
  say 'failed in test 15 '
  rc = 8 
end

if datatype("") \== "CHAR" then do
  say 'failed in test 16 '
  rc = 8 
end

if datatype("DeadBeef" , 'A') \== "1" then do
  say 'failed in test 17 '
  rc = 8 
end

if datatype("Dead Beef",'A') \== "0" then do
  say 'failed in test 18 '
  rc = 8 
end

if datatype("1234ABCD",'A') \== '1' then do
  say 'failed in test 19 '
  rc = 8 
end

if datatype("",'A') \== "0" then do
  say 'failed in test 20 '
  rc = 8 
end

if datatype("foobar",'B') \== "0" then do
  say 'failed in test 21 '
  rc = 8 
end

if datatype("01001101",'B') \== "1" then do
  say 'failed in test 22 '
  rc = 8 
end

if datatype("0110 1101",'B') \== "1" then do
  say 'failed in test 23 '
  rc = 8 
end

if datatype("",'B') \== "1" then do
  say 'failed in test 24 '
  rc = 8 
end

if datatype("foobar",'L') \== "1" then do
  say 'failed in test 25 '
  rc = 8 
end

if datatype("FooBar",'L') \== "0" then do
  say 'failed in test 26 '
  rc = 8 
end

if datatype("foo bar",'L') \== "0" then do
  say 'failed in test 27 '
  rc = 8 
end

if datatype("",'L') \== "0" then do
  say 'failed in test 28 '
  rc = 8 
end

if datatype("foobar",'M') \== "1" then do
  say 'failed in test 29 '
  rc = 8 
end

if datatype("FooBar",'M') \== "1" then do
  say 'failed in test 30 '
  rc = 8 
end

if datatype("foo bar",'M') \== "0" then do
  say 'failed in test 31 '
  rc = 8 
end

if datatype("FOOBAR",'M') \== "1" then do
  say 'failed in test 32 '
  rc = 8 
end

if datatype("",'M') \== "0" then do
  say 'failed in test 33 '
  rc = 8 
end

if datatype("foo bar",'N') \== "0" then do
  say 'failed in test 34 '
  rc = 8 
end

if datatype("1324.1234",'N') \== "1" then do
  say 'failed in test 35 '
  rc = 8 
end

if datatype("123.456.789",'N') \== "0" then do
  say 'failed in test 36 '
  rc = 8 
end

if datatype("",'N') \== "0" then do
  say 'failed in test 37 '
  rc = 8 
end

if datatype("foo bar",'S') \== "0" then do
  say 'failed in test 38 '
  rc = 8 
end

/* if datatype("??@##_Foo$Bar!!!",'S') \== "1" then say 'failed in test */

if datatype("",'S') \== "0" then do
  say 'failed in test 40 '
  rc = 8 
end

if datatype("foo bar",'U') \== "0" then do
  say 'failed in test 41 '
  rc = 8 
end

if datatype("Foo Bar",'U') \== "0" then do
  say 'failed in test 42 '
  rc = 8 
end

if datatype("FOOBAR",'U') \== "1" then do
  say 'failed in test 43 '
  rc = 8 
end

if datatype("",'U') \== "0" then do
  say 'failed in test 44 '
  rc = 8 
end

if datatype("Foobar",'W') \== "0" then do
  say 'failed in test 45 '
  rc = 8 
end

if datatype("123",'W') \== "1" then do
  say 'failed in test 46 '
  rc = 8 
end

if datatype("12.3",'W') \== "0" then do
  say 'failed in test 47 '
  rc = 8 
end

if datatype("",'W') \== "0" then do
  say 'failed in test 48 '
  rc = 8 
end

if datatype('123.123','W') \== '0' then do
  say 'failed in test 49 '
  rc = 8 
end

if datatype('123.123E3','W') \== '1' then do
  say 'failed in test 50 '
  rc = 8 
end

if datatype('123.0000003','W') \== '1' then do
  say 'failed in test 51 '
  rc = 8 
end

if datatype('123.0000004','W') \== '1' then do
  say 'failed in test 52 '
  rc = 8 
end

if datatype('123.0000005','W') \== '0' then do
  say 'failed in test 53 '
  rc = 8 
end

if datatype('123.0000006','W') \== '0' then do
  say 'failed in test 54 '
  rc = 8 
end

if datatype(' 23','W') \== '1' then do
  say 'failed in test 55 '
  rc = 8 
end

if datatype(' 23 ','W') \== '1' then do
  say 'failed in test 56 '
  rc = 8 
end

if datatype('23 ','W') \== '1' then do
  say 'failed in test 57 '
  rc = 8 
end

if datatype('123.00','W') \== '1' then do
  say 'failed in test 58 '
  rc = 8 
end

if datatype('123000E-2','W') \== '1' then do
  say 'failed in test 59 '
  rc = 8 
end

if datatype('123000E+2','W') \== '1' then do
  say 'failed in test 60 '
  rc = 8 
end

if datatype("Foobar",'X') \== "0" then do
  say 'failed in test 61 '
  rc = 8 
end

if datatype("DeadBeef",'X') \== "1" then do
  say 'failed in test 62 '
  rc = 8 
end

if datatype("A B C",'X') \== "0" then do
  say 'failed in test 63 '
  rc = 8 
end

if datatype("A BC DF",'X') \== "1" then do
  say 'failed in test 64 '
  rc = 8 
end

if datatype("123ABC",'X') \== "1" then do
  say 'failed in test 65 '
  rc = 8 
end

if datatype("123AHC",'X') \== "0" then do
  say 'failed in test 66 '
  rc = 8 
end

if datatype("",'X') \== "1" then do
  say 'failed in test 67 '
  rc = 8 
end

if datatype('0.000E-2','w') \== '1' then do
  say 'failed in test 68 '
  rc = 8 
end

if datatype('0.000E-1','w') \== '1' then do
  say 'failed in test 69 '
  rc = 8 
end

if datatype('0.000E0','w') \== '1' then do
  say 'failed in test 70 '
  rc = 8 
end

if datatype('0.000E1','w') \== '1' then do
  say 'failed in test 71 '
  rc = 8 
end

if datatype('0.000E2','w') \== '1' then do
  say 'failed in test 72 '
  rc = 8 
end

if datatype('0.000E3','w') \== '1' then do
  say 'failed in test 73 '
  rc = 8 
end

if datatype('0.000E4','w') \== '1' then do
  say 'failed in test 74 '
  rc = 8 
end

if datatype('0.000E5','w') \== '1' then do
  say 'failed in test 75 '
  rc = 8 
end

if datatype('0.000E6','w') \== '1' then do
  say 'failed in test 76 '
  rc = 8 
end

if datatype('0E-1','w') \== '1' then do
  say 'failed in test 77 '
  rc = 8 
end

if datatype('0E0','w') \== '1' then do
  say 'failed in test 78 '
  rc = 8 
end

if datatype('0E1','w') \== '1' then do
  say 'failed in test 79 '
  rc = 8 
end

if datatype('0E2','w') \== '1' then do
  say 'failed in test 80 '
  rc = 8 
end

say "DATATYPE OK"

exit rc
