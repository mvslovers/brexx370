say '----------------------------------------'
say 'File dynrexx.rexx'
/* ADDRESS DYNREXX appended ";" with strcat() behind a string that was */
/* not terminated, so the separator landed wherever a NUL was and a    */
/* byte of old storage stood in its place: a module of several lines   */
/* lost its AS clause and was not stored (#386).                       */
err = 0
address dynrexx "{return 'one'} as __DYN1"
call check 'one line rc',     rc, 0
address dynrexx "{return 'two'} as __DYN2"
address dynrexx "{"
address dynrexx "x = 'three'"
address dynrexx "return x} as __DYN3"
call check 'three lines rc',  rc, 0
address dynrexx "{"
address dynrexx "y = 'fo'"
address dynrexx "y = y'ur'"
address dynrexx "return y} as __DYN4"
call check 'calls',           t('__dyn1()') t('__dyn2()') t('__dyn3()'),
     t('__dyn4()'), 'one two three four'
address dynrexx "{return 5}"
call check 'no AS clause',    rc, 8
address dynrexx "{return 6} as __DYN6"
call check 'after a reject',  t('__dyn6()'), 6
say 'Done dynrexx.rexx'
exit err

t: procedure
signal on syntax name tx
interpret 'r =' arg(1)
return r
tx: return 'error' rc

check:
parse arg what, got, want
if got == want then say left('DYNREXX',8) '-' left(what,16) '.. PASS'
else do
   say left('DYNREXX',8) '-' left(what,16) '.. *FAIL* got' got 'want' want
   err = err + 1
end
return
