say '----------------------------------------'
say 'File lineread.rexx'
/* Line reads go through fgets(), not one fgetc() per byte: libc370's  */
/* fgetc() takes an ENQ and a DEQ per byte. Checked here: LINEIN at a */
/* line number, LINES before and after it, and FB records' length.    */
/* An X'00' inside a record cannot be checked: it is lost when the    */
/* record is written (CHAROUT and LINEOUT alike, libc370).            */
err = 0
VER = UPPER(VERSION())
if index(VER,'(') > 0 then do
  VER = DELSTR(VER,INDEX(VER,'('),1)
  VER = DELSTR(VER,INDEX(VER,')'),1)
end
F = allocate('lrfile',"'BREXX."||VER||".TESTS(LRDTMP)'")
IF F >= 4 THEN return 8
file = OPEN('lrfile',"W")
do n = 1 to 6
  call lineout file, "Line" n
end
call close file
file = OPEN('lrfile',"R")
call check 'lines() 6',        lines(file), 6
l1 = linein(file)
call check 'line 1',           strip(l1, 'T'), 'Line 1'
call check 'FB length',        length(l1), 80
l3 = linein(file, 3)
call check 'line 3',           strip(l3, 'T'), 'Line 3'
call check 'line 3 length',    length(l3), 80
call check 'lines() after 3',  lines(file), 3
l5 = linein(file, 5)
call check 'line 5',           strip(l5, 'T'), 'Line 5'
call check 'lines() after 5',  lines(file), 1
call close file
say 'Done lineread.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('LINEREAD',8) '-' left(what,16) '.. PASS'
else do
   say left('LINEREAD',8) '-' left(what,16) '.. *FAIL* got' got 'want' want
   err = 8
end
return
