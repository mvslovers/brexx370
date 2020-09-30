say '----------------------------------------'
say 'File lineout.rexx'
/* LINEOUT */

rc = 0

say "Look for LINEOUT OK"
file="TEST FILE A"
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

if linein(file)!="Line 1" then do
  say 'failed in test 2'
  rc = 8 
end

if linein(file)!="Line 2" then do
  say 'failed in test 3'
  rc = 8 
end

if linein(file)!="Line 3" then do
  say 'failed in test 4'
  rc = 8 
end

if linein(file)!="Line 4" then do
  say 'failed in test 5'
  rc = 8 
end

if linein(file)!="Line 5" then do
  say 'failed in test 6'
  rc = 8 
end

if linein(file)!="" then do
  say 'failed in test 7'
  rc = 8 
end

call lineout file
call lineout file, "Done 3", 3
call lineout file

if lines(file)!=5 then do
  say 'failed in test 8'
  rc = 8 
end

if linein(file)!="Line 1" then do
  say 'failed in test 9'
  rc = 8 
end

if linein(file)!="Line 2" then do
  say 'failed in test 10'
  rc = 8 
end

if linein(file)!="Done 3" then do
  say 'failed in test 11'
  rc = 8 
end

if linein(file)!="Line 4" then do
  say 'failed in test 12'
  rc = 8 
end

if linein(file)!="Line 5" then do
  say 'failed in test 13'
  rc = 8 
end

if linein(file)!="" then do
  say 'failed in test 14'
  rc = 8 
end

call lineout file
"erase" file
call lineout file "f 80", "Line 1"
call lineout file, "Line 2"
call lineout file, "Line 3"
call lineout file, "Line 4"
call lineout file, "Line 5"
call lineout file

if lines(file)!=5 then do
  say 'failed in test 15'
  rc = 8 
end

if linein(file)!="Line 1" then do
  say 'failed in test 16'
  rc = 8 
end

if linein(file)!="Line 2" then do
  say 'failed in test 17'
  rc = 8 
end

if linein(file)!="Line 3" then do
  say 'failed in test 18'
  rc = 8 
end

if linein(file)!="Line 4" then do
  say 'failed in test 19'
  rc = 8 
end

if linein(file)!="Line 5" then do
  say 'failed in test 20'
  rc = 8 
end

if linein(file)!="" then do
  say 'failed in test 21'
  rc = 8 
end

call lineout file
call lineout file, "Done 3 Long", 3
call lineout file

if lines(file)!=5 then do
  say 'failed in test 22'
  rc = 8 
end

if linein(file)!="Line 1" then do
  say 'failed in test 23'
  rc = 8 
end

if linein(file)!="Line 2" then do
  say 'failed in test 24'
  rc = 8 
end

if linein(file)!="Done 3 Long" then do
  say 'failed in test 25'
  rc = 8 
end

if linein(file)!="Line 4" then do
  say 'failed in test 26'
  rc = 8 
end

if linein(file)!="Line 5" then do
  say 'failed in test 27'
  rc = 8 
end

if linein(file)!="" then do
  say 'failed in test 28'
  rc = 8 
end

call lineout file
"erase" file
say "LINEOUT OK"

exit rc
