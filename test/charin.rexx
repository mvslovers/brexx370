say '----------------------------------------'
say 'File charin.rexx'
/* LINEIN */
rc = 0
say "Look for CHARIN OK"
file="TEST FILE A"
cr = '0D'x
call lineout file, "Line 1"
call lineout file, "Line 2"
call lineout file, "Line 3"
call lineout file, "Line 4"
call lineout file, "Line 5"
call lineout file

if charin(file)!="L" then do
  say 'failed in test 1'
  rc = 8 
end

if charin(file,,6)!="ine 1"cr then do
  say 'failed in test 2'
  rc = 8 
end

if charin(file,,7)!="Line 2"cr then do
  say 'failed in test 3'
  rc = 8 
end

if charin(file,,7)!="Line 3"cr then do
  say 'failed in test 4'
  rc = 8 
end

if charin(file,,7)!="Line 4"cr then do
  say 'failed in test 5'
  rc = 8 
end

if charin(file,,7)!="Line 5"cr then do
  say 'failed in test 6'
  rc = 8 
end

if charin(file)!="" then do
  say 'failed in test 7'
  rc = 8 
end

call lineout file
"erase" file
say "CHARIN OK"
exit rc
