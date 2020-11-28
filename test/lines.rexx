say '----------------------------------------'
say 'File lines.rexx'
/* LINES */
VER = UPPER(VERSION())
if index(VER,'(') > 0 then do
  VER = DELSTR(VER,INDEX(VER,'('),1)
  VER = DELSTR(VER,INDEX(VER,')'),1)
end
F = allocate('ofile',"'BREXX."||VER||".TESTS(LSTMP)'")
IF F >= 4 THEN return 8
file = OPEN('ofile',"W")
rc = 0

call lineout file, "Line 1"
call lineout file, "Line 2"
call lineout file, "Line 3"
call lineout file, "Line 4"
call lineout file, "Line 5"
call lineout file

if lines(file)!=5 then do
  say 'failed in test 1'
  rc = 8 
end

Call linein file

if lines(file)!=4 then do
  say 'failed in test 2'
  rc = 8 
end

Call linein file

if lines(file)!=3 then do
  say 'failed in test 3'
  rc = 8 
end

Call linein file

if lines(file)!=2 then do
  say 'failed in test 4'
  rc = 8 
end

Call linein file

if lines(file)!=1 then do
  say 'failed in test 5'
  rc = 8 
end

Call linein file

if lines(file)!=0 then do
  say 'failed in test 6'
  rc = 8 
end

Call linein file

if lines(file)!=0 then do
  say 'failed in test 7'
  rc = 8 
end

call lineout file

say 'LINES    - all tests.. PASS'

exit rc
