say '----------------------------------------'
say 'File vsamtok.rexx'
/* VSAMIO copied the VAR name into vname[19] and the KEY into          */
/* VSAMKEY[255] with strcpy(), and took the word after KEY or VAR      */
/* even when there was none (#386). The command is checked before any  */
/* VSAM call, so no data set is needed: each case must end in error    */
/* 40, and a VAR name of 250 characters is a name like any other.      */
err = 0
long = copies('V', 300)
key  = copies('K', 300)
call e40 'READ VAR 300',      'READ NODD KEY K1 VAR' long
call e40 'READ KEY 300',      'READ NODD KEY' key
call e40 'READ KEY missing',  'READ NODD KEY'
call e40 'READ VAR missing',  'READ NODD NEXT VAR'
call e40 'WRITE VAR 300',     'WRITE NODD KEY K1 VAR' long
call e40 'INSERT VAR 300',    'INSERT NODD KEY K1 VAR' long
call e40 'LOCATE KEY 300',    'LOCATE NODD KEY' key
call e40 'DELETE KEY 300',    'DELETE NODD KEY' key
call nerr 'READ VAR 250',     'READ NODD KEY K1 VAR' copies('V', 250)
say 'Done vsamtok.rexx'
exit err

e40: procedure expose err
parse arg what, cmd
signal on syntax name e40x
address mvs 'VSAMIO' cmd
say left('VSAMTOK',8) '-' left(what,18) '.. *FAIL* no error, rc' rc
err = err + 1
return
e40x:
if rc = 40 then say left('VSAMTOK',8) '-' left(what,18) '.. PASS'
else do
   say left('VSAMTOK',8) '-' left(what,18) '.. *FAIL* rc' rc
   err = err + 1
end
return

/* a valid command: no syntax error; the VSAM call fails (no DD)       */
nerr: procedure expose err
parse arg what, cmd
signal on syntax name nerrx
address mvs 'VSAMIO' cmd
say left('VSAMTOK',8) '-' left(what,18) '.. PASS rc' rc
return
nerrx:
say left('VSAMTOK',8) '-' left(what,18) '.. *FAIL* error' rc
err = err + 1
return
