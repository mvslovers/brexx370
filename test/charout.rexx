say '----------------------------------------'
say 'File charout.rexx'
/* CHAROUT */
rc = 0
cr = '0D'x
file="TEST FILE A"
call charout file "F 6", "Line 1"cr
call charout file, "Line 2"cr
call charout file, "Line 3"cr
call charout file, "Line 4"cr
call charout file, "Line 5"cr
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
call charout file, "Done 3", 15
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
say "Done charout.rexx"
exit rc
