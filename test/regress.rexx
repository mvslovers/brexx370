say '----------------------------------------'
say 'File regress.rexx'
/* This can be a development test by taking it partially from the top. */
/* A minimum of SAY and EXIT is needed to get a runnable test. */
/* A dump of the pseudo-code should show two byte operand then one byte
operator "Say" for CRX pseudo-code. */
say 'Regression test with all sorts of pseudo-codes. Look for "Done OK"'
/* Simplest IF has a "Then" operator to compare operand with '0' and '1' */
if 0 then do
    say 'failed test 1'
    rc = 8
end
if 0 then do
    say 'failed test 2'
    rc = 8
end; else nop
/* Selects are much the same. */
select
when 0 then do
    say 'failed test 3'
    rc = 8
end
when 1 then nop
otherwise nop
end
/* SELECT has error raised if nothing satisfied. */
select
when 1 then nop
end
/* CRX has different assignment of constants than non-constants. */
abc=0
pqr=abc
if pqr then do
    say 'failed test 4'
    rc = 8
end
/* CRX compiles out 'stemming'. */
stema.3 = 0
stemb.abc.0 = stema.3
if stemb.0.abc then do
    say 'failed test 4'
    rc = 8
end
/* Unary operators */
abc=+1;if \abc then do
    say 'failed test 5'
    rc = 8
end
abc=\1;if abc then do
    say 'failed test 6'
    rc = 8
end
abc=-1;if \(-abc) then do
    say 'failed test 7'
    rc = 8
end
/* Binary operators */
if abc=abc then nop
if abc\=abc then do
    say 'failed test 8'
    rc = 8
end
if abc<abc then do
    say 'failed test 9'
    rc = 8
end
if abc<=abc then nop
if abc>=abc then nop
if abc>abc then do
    say 'failed test 10'
    rc = 8
end
if abc==abc then nop
if abc\==abc then do
    say 'failed test 11'
    rc = 8
end
if abc<<abc then do
    say 'failed test 12'
    rc = 8
end
if abc<<=abc then nop
if abc>>=abc then nop
if abc>>abc then do
    say 'failed test 13'
    rc = 8
end
if 5%2 \= 2 then do
    say 'failed test 14'
    rc = 8
end
if 2*2 \= 4 then do
    say 'failed test 15'
    rc = 8
end
if 2/2 \= 1 then do
    say 'failed test 16'
    rc = 8
end
if 5//2 \= 1 then do
    say 'failed test 17'
    rc = 8
end
if (1 && 1) \= 0 then do
    say 'failed test 18'
    rc = 8
end
if (1 | 0) \= 1 then do
    say 'failed test 19'
    rc = 8
end
if (1 & 1) \= 1 then do
    say 'failed test 20'
    rc = 8
end
if (2-1) \= 1 then do
    say 'failed test 21'
    rc = 8
end
if (2+1) \= 3 then do
    say 'failed test 22'
    rc = 8
end
if "a"||"b" \== "ab" then do
    say 'failed test 23'
    rc = 8
end
if "a" "b" \== "a b" then do
    say 'failed test 24'
    rc = 8
end
if 2**0 \== 1 then do
    say 'failed test 25'
    rc = 8
end
A = 1 > 2
if A then do
    say 'failed test 26'
    rc = 8
end
drop A
if A\=='A' then do
    say 'failed test 27'
    rc = 8
end
drop A.
if A.\=='A.' then do
    say 'failed test 28'
    rc = 8
end
if 0 then do
drop A.B
drop (A.)
end
/*
address
address DOS
address DOS "Dir"
address value "DOS"
address value "DOS" with output stem A.
address value "DOS" with output replace stem A.
address "DOS" with output append stream A. input stream B.
"DIR"
*/
if datatype("b",'L') then nop
if substr("abc",2,1) \== 'b' then do
    say 'failed test 29'
    rc = 8
end
j=2
if substr("abc",j,1) \== 'b' then do
    say 'failed test 30'
    rc = 8
end
if length('abc') \= 3 then do
    say 'failed test 31'
    rc = 8
end
if 0 then do
if countstr('c',"abcc") \= 2 then do
    say 'failed test 32'
    rc = 8
end
if max(2,1) \= 2 then do
    say 'failed test 33'
    rc = 8
end
if min(3,2,1) \= 1 then do
    say 'failed test 34'
    rc = 8
end
end
nop
numeric form Engineering
/* numeric form value('e') */
numeric fuzz 0
numeric digits
numeric fuzz
numeric form
numeric digits 9
call digits
if digits() <> 9 then do
    say 'failed test 35'
    rc = 8
end
parse version x;say x
parse source x;say x
parse value 2+2 with x
parse var x y
parse version a b
if 0 then do
/* parse testin x */
parse pull x
parse arg x
end
signal on error
signal off error
signal Trouble
say "Signal didn't work"
Trouble:
trace 'O'
call on notready name sub
options "gosh"
if 0 then do
interpret "nop"
push barrow
queue intest
end
call sub
x=ftn()
if x <> 99 then do
    say 'failed test 36'
    rc = 8
end
do 99
end
do 99 while 1
end
do forever
leave
end
do forever while 0
end
do n=1 by 5 for 3
iterate
end
do n=1 to 5 until 0
end
do n=1
leave
end
if 0 then do
do a.b.c=1 by 5 for 3
nop
end
do a.b.c=1 to 5 until 0
nop
end
end
interpret "nop;interpret 'say 99'"
rc = 0
if \abbrev('Print','Pri') then do
    say 'failed test 37'
    rc = 8
end
if left('abc def',7) \== 'abc de' then do
    say 'failed test 38'
    rc = 8
end
if overlay('123','abc',5,6,'+') \== 'abc+123+++' then do
    say 'failed test 39'
    rc = 8
end
if substr('abc',2,6,'.') \== 'bc....' then do
    say 'failed test 40'
    rc = 8
end
say
say "Done OK"
exit rc
sub:return
ftn:return 99
/* procedure expose A. A.B (A.) (A.B) */
address error with output normal error append stream A.
