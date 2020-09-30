say '----------------------------------------'
say 'File chars.rexx'
/* CHARS */
rc = 0
say "Look for CHARS OK"
file="TEST FILE A"
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
say "CHARS OK"
exit rc
