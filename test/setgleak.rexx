say '----------------------------------------'
say 'File setgleak.rexx'
/* #93: replacing a global variable (SETG) or a DYNREXX module kept the
   old value allocated, so a loop that set the same name ran BREXX out
   of storage. 40000 x 1000 bytes is far beyond REGION=8M. */
err = 0
big = copies('A', 1000)
do i = 1 to 40000
   call setg 'SGLEAK', big || i
end
call check 'SETG last value',   getg('SGLEAK'),      big || 40000
call check 'SETG other name',   setg('SGLEAK2', 'b') getg('SGLEAK2'), 'b b'
code = "{x='" || copies('B', 900) || "'} as __SGLEAK"
do i = 1 to 20000
   address dynrexx code
   if rc \= 0 then leave
end
call check 'DYNREXX redefine',  rc i,                '0 20001'
address dynrexx "{return 'dyn' || 1+1} as __SGLDYN"
call check 'DYNREXX call',      __SGLDYN(),          'dyn2'
say 'Done setgleak.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('SETGLEAK',8) '-' left(what,20) '.. PASS'
else do
   say left('SETGLEAK',8) '-' left(what,20) '.. *FAIL* got "'got'"',
       'want "'want'"'
   err = err + 1
end
return
