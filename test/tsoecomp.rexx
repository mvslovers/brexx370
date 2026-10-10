say '----------------------------------------'
say 'File tsoecomp.rexx'
/* TSO/E behaviour (#386): a CALL of a routine that returns no value  */
/* drops RESULT, it kept the value before; a SELECT whose WHEN are    */
/* all false and that has no OTHERWISE is error 7.3, it ran on.       */
err = 0
call f5
call check 'RESULT set',        result, 5
call f0
call check 'RESULT dropped',    symbol('RESULT'), 'LIT'
call f5
call p0
call check 'after PROCEDURE',   symbol('RESULT'), 'LIT'
call f5
x = f5()
call check 'function leaves',   result, 5
call check 'SELECT no WHEN',    sel(0), 'error 7'
call check 'SELECT a WHEN',     sel(1), 'ran'
call check 'SELECT OTHERWISE',  selo(0), 'other'
say 'Done tsoecomp.rexx'
exit err

f5: return 5
f0: return
p0: procedure
return

sel: procedure
signal on syntax name selx
select
   when arg(1) = 1 then nop
end
return 'ran'
selx: return 'error' rc

selo: procedure
select
   when arg(1) = 1 then return 'when'
   otherwise return 'other'
end

check:
parse arg what, got, want
if got == want then say left('TSOECOMP',8) '-' left(what,16) '.. PASS'
else do
   say left('TSOECOMP',8) '-' left(what,16) '.. *FAIL* got' got 'want' want
   err = err + 1
end
return
