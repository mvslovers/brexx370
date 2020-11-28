say '----------------------------------------'
say 'File chars.rexx'
/* CHARS */
VER = UPPER(VERSION())
if index(VER,'(') > 0 then do
  VER = DELSTR(VER,INDEX(VER,'('),1)
  VER = DELSTR(VER,INDEX(VER,')'),1)
end
F = allocate('ofile',"'BREXX."||VER||".TESTS(LOTMP)'")
IF F >= 4 THEN return 8
file = OPEN('ofile',"W")

rc = 0
call lineout file "F 80", "Line 1"
call lineout file, "Line 2"
call lineout file
if chars(file)!=162 then do
  say 'failed in test 1'
  rc = 8 
end
Call charin file, 30
if chars(file)!=132 then do
  say 'failed in test 2'
  rc = 8 
end
call lineout file
'erase' file
say 'Done chars.rexx'
exit rc
