say '----------------------------------------'
say 'File linein.rexx'
/* LINEIN */

rc = 0


file="TEST FILE A"

cr = '0D'x
call lineout file, "Line 1"
call lineout file, "Line 2"
call lineout file, "Line 3"
call lineout file, "Line 4"
call lineout file, "Line 5"
call lineout file

if linein(file)!="Line 1" then do
  say 'failed in test 1'
  rc = 8 
end

if linein(file)!="Line 2" then do
  say 'failed in test 2'
  rc = 8 
end

if linein(file)!="Line 3" then do
  say 'failed in test 3'
  rc = 8 
end

if linein(file)!="Line 4" then do
  say 'failed in test 4'
  rc = 8 
end

if linein(file)!="Line 5" then do
  say 'failed in test 5'
  rc = 8 
end

if linein(file)!="" then do
  say 'failed in test 6'
  rc = 8 
end

if linein(file,3)!="Line 3" then do
  say 'failed in test 7'
  rc = 8 
end

if linein(file,2,2)!="Line 2"cr"Line 3"cr then do
  say 'failed in test 8'
  rc = 8 
end

call lineout file
"erase" file
say 'Done linein.rexx'

exit rc
