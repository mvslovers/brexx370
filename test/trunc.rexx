say '----------------------------------------'
say 'File trunc.rexx'
r=0
/* From:
The REXX Language A Practical Approach to Programming
Second Edition, MICHAEL COWLISHAW, 1990
*/
r=r+rtest("trunc(12.3)","\== 12",1)
r=r+rtest("trunc(127.09782,3)","\== 127.097",2)
r=r+rtest("trunc(127.1,3)","\== 127.100",3)
r=r+rtest("trunc(127,2)","\== 127.00",4)
/* From: Mark Hessling */
r=r+rtest("trunc(1234.5678, 2)","\== '1234.56'",5)
r=r+rtest("trunc(-1234.5678)","\== '-1234'",6)
r=r+rtest("trunc(.5678)","\== '0'",7)
r=r+rtest("trunc(.00123)","\== '0'",8)
r=r+rtest("trunc(.00123,4)","\== '0.0012'",9)
r=r+rtest("trunc(.00127,4)","\== '0.0012'",10)
r=r+rtest("trunc(.1678)","\== '0'",11)
r=r+rtest("trunc(1234.5678)","\== '1234'",12)
r=r+rtest("trunc(4.5678, 7)","\== '4.5678000'",13)
r=r+rtest("trunc(10000005.0,2)","\== 10000005.00",14)
r=r+rtest("trunc(10000000.5,2)","\== 10000000.50",15)

/* default NUMERIC DIGITS (30): no rounding before truncation */
r=r+rtest("trunc(10000000.05,2)","\== 10000000.05",16)
r=r+rtest("trunc(10000000.005,2)","\== 10000000.00",17)
r=r+rtest("trunc(10000005.5,2)","\== 10000005.50",18)
r=r+rtest("trunc(10000000.55,2)","\== 10000000.55",19)
r=r+rtest("trunc(10000000.055,2)","\== 10000000.05",20)
r=r+rtest("trunc(10000000.0055,2)","\== 10000000.00",21)
r=r+rtest("trunc(10000000.04,2)","\== 10000000.04",22)
r=r+rtest("trunc(10000000.045,2)","\== 10000000.04",23)
r=r+rtest("trunc(10000000.45,2)","\== 10000000.45",24)
r=r+rtest("trunc(99999999.,2)","\== 99999999.00",28)
r=r+rtest("trunc(99999999.9,2)","\== 99999999.90",29)
r=r+rtest("trunc(99999999.99,2)","\== 99999999.99",30)
r=r+rtest("trunc(1E2,0)","\== 100",31)
r=r+rtest("trunc(12E1,0)","\== 120",32)
r=r+rtest("trunc(123.,0)","\== 123",33)
r=r+rtest("trunc(123.1,0)","\== 123",34)
r=r+rtest("trunc(123.12,0)","\== 123",35)
r=r+rtest("trunc(123.123,0)","\== 123",36)
r=r+rtest("trunc(123.1234,0)","\== 123",37)
r=r+rtest("trunc(123.12345,0)","\== 123",38)
r=r+rtest("trunc(1E2,1)","\== 100.0",39)
r=r+rtest("trunc(12E1,1)","\== 120.0",40)
r=r+rtest("trunc(123.,1)","\== 123.0",41)
r=r+rtest("trunc(123.1,1)","\== 123.1",42)
r=r+rtest("trunc(123.12,1)","\== 123.1",43)
r=r+rtest("trunc(123.123,1)","\== 123.1",44)
r=r+rtest("trunc(123.1234,1)","\== 123.1",45)
r=r+rtest("trunc(123.12345,1)","\== 123.1",46)
r=r+rtest("trunc(1E2,2)","\== 100.00",47)
r=r+rtest("trunc(12E1,2)","\== 120.00",48)
r=r+rtest("trunc(123.,2)","\== 123.00",49)
r=r+rtest("trunc(123.1,2)","\== 123.10",50)
r=r+rtest("trunc(123.12,2)","\== 123.12",51)
r=r+rtest("trunc(123.123,2)","\== 123.12",52)
r=r+rtest("trunc(123.1234,2)","\== 123.12",53)
r=r+rtest("trunc(123.12345,2)","\== 123.12",54)
r=r+rtest("trunc(1E2,3)","\== 100.000",55)
r=r+rtest("trunc(12E1,3)","\== 120.000",56)
r=r+rtest("trunc(123.,3)","\== 123.000",57)
r=r+rtest("trunc(123.1,3)","\== 123.100",58)
r=r+rtest("trunc(123.12,3)","\== 123.120",59)
r=r+rtest("trunc(123.123,3)","\== 123.123",60)
r=r+rtest("trunc(123.1234,3)","\== 123.123",61)
r=r+rtest("trunc(123.12345,3)","\== 123.123",62)
r=r+rtest("trunc(1E2,4)","\== 100.0000",63)
r=r+rtest("trunc(12E1,4)","\== 120.0000",64)
r=r+rtest("trunc(123.,4)","\== 123.0000",65)
r=r+rtest("trunc(123.1,4)","\== 123.1000",66)
r=r+rtest("trunc(123.12,4)","\== 123.1200",67)
r=r+rtest("trunc(123.123,4)","\== 123.1230",68)
r=r+rtest("trunc(123.1234,4)","\== 123.1234",69)
r=r+rtest("trunc(123.12345,4)","\== 123.1234",70)
r=r+rtest("trunc(1E2,5)","\== 100.00000",71)
r=r+rtest("trunc(12E1,5)","\== '120.00000'",72)
r=r+rtest("trunc(123.,5)","\== '123.00000'",73)
r=r+rtest("trunc(123.1,5)","\== '123.10000'",74)
r=r+rtest("trunc(123.12,5)","\== '123.12000'",75)
r=r+rtest("trunc(123.123,5)","\== '123.12300'",76)
r=r+rtest("trunc(123.1234,5)","\== 123.12340",77)
r=r+rtest("trunc(123.12345,5)","\== 123.12345",78)
/* #72: truncation never rounds up, whatever the next digit */
r=r+rtest("trunc(127.96)","\== '127'",79)
r=r+rtest("trunc(1.9999,2)","\== '1.99'",80)
r=r+rtest("trunc(-1.9999,2)","\== '-1.99'",81)
r=r+rtest("trunc(0.999999,0)","\== '0'",82)
r=r+rtest("trunc(9.95,1)","\== '9.9'",83)
/* #72: digits a double cannot hold, and no negative zero */
r=r+rtest("trunc(1e50,2)","\== '1'copies('0',50)'.00'",84)
call strict trunc(1e-30,2),  '0.00', 85
call strict trunc(-0.001,2), '0.00', 86
call strict trunc(-0.5),     '0',    87
/* #72: computed (real) arguments */
r=r+rtest("trunc(0.1+0.2,3)","\== '0.300'",88)
r=r+rtest("trunc(1/3,5)","\== '0.33333'",89)
r=r+rtest("trunc(2/3,5)","\== '0.66666'",90)
r=r+rtest("trunc(5*3,2)","\== '15.00'",91)
/* #72: the argument is not changed */
y='1.10'; z=trunc(y,1)
call strict y, '1.10', 92
/* #72: NUMERIC DIGITS 9 rounds first (TSO/E REXX Reference, TRUNC) */
numeric digits 9
call strict trunc(10000000.05,2),  '10000000.10',  93
call strict trunc(10000000.55,2),  '10000000.60',  94
call strict trunc(10000000.055,2), '10000000.10',  95
call strict trunc(10000000.045,2), '10000000.00',  96
call strict trunc(10000000.45,2),  '10000000.50',  97
call strict trunc(99999999.99,2),  '100000000.00', 98
call strict trunc(123.12345,5),    '123.12345',    99
say 'Done trunc.rexx'
exit r
/* strict compare in the caller's NUMERIC DIGITS (rtest warns on near hits) */
strict:
  parse arg got, want, tno
  if got == want then say 'TRUNC    - test' right(tno,3) '.. PASS'
  else do
    say 'TRUNC    - test' right(tno,3) '.. *FAIL* - expected "'want'"',
        'actual "'got'"'
    r = max(r,8)
  end
  return
