/* MVSTEST VSAM */
say '----------------------------------------'
say 'File vsamio.rexx'
/* VSAMIO against a real KSDS (IRXVSMIO, the VSAM subtask). The         */
/* harness (MVSTEST VSAM) defines a cluster with key length 8, record   */
/* sizes 100 to 200 and one record of 80 bytes, '00000000first record', */
/* and gives it as DD VSAMTST. The name after VAR may be written in any */
/* case; it names the variable in upper case.                           */
/* The phases do not mix random and sequential access on one open; what */
/* mixing does is not measured. What a phase wrote is checked after the */
/* data set has been closed and opened again.                           */
err = 0
FIRST = left('00000000first record', 80)

/* ---- read only ---- */
call vs 'OPEN VSAMTST (READ',                      0, '000-00000'
call vs 'OPEN VSAMTST (READ',                      8, '008-00004'
call vs 'READ VSAMTST (KEY 00000000 VAR REC',      0, '000-00000'
call eq 'read by key', REC, FIRST
call vs 'READ VSAMTST (KEY 0000 VAR REC',          0, '000-00000'
call eq 'generic key', REC, FIRST
call vs 'READ VSAMTST (KEY 00000001 VAR REC',      4
call vs 'READ VSAMTST (KEY 99999999 VAR REC',      4
call vs 'WRITE VSAMTST (KEY 00000000 VAR REC',     8, '008-00068'
call vs 'INSERT VSAMTST (KEY 00000010 VAR REC',    8, '008-00068'
call vs 'CLOSE VSAMTST',                           0, '000-00000'

/* ---- a file that is not open, and files that cannot be opened ---- */
call vs 'READ VSAMTST (KEY 00000000 VAR REC',      8, '255-65535'
call vs 'CLOSE VSAMTST',                           0, '255-65535'
call vs 'OPEN NODD (READ',                         8, '008-00128'
call vs 'OPEN VSAMTST (LOAD',                      8, '008-00232'
call vs 'OPEN VSAMTST (RESET',                     8, '008-00232'

/* ---- insert and write by key ---- */
call vs 'OPEN VSAMTST (UPDATE',                    0, '000-00000'
call vs 'OPEN NODD (UPDATE',                       8, '008-00128'
R10 = '00000010second record'
R30 = '00000030fourth record'
call vs 'INSERT VSAMTST (KEY 00000010 VAR R10',    0, '000-00000'
call vs 'INSERT VSAMTST (KEY 00000010 VAR R10',    8, '008-00008'
call vs 'INSERT VSAMTST (KEY 00000030 VAR R30',    0, '000-00000'
LONG = '00000090' || copies('x', 250)
call vs 'INSERT VSAMTST (KEY 00000090 VAR LONG',   8, '008-00108'
/* WRITE inserts a new key, and replaces a record that READ ... UPDATE
   has just read */
R20 = '00000020third record'
call vs 'WRITE VSAMTST (KEY 00000020 VAR R20',     0, '000-00000'
R10 = '00000010second record, replaced'
call vs 'READ VSAMTST (KEY 00000010 UPDATE VAR REC', 0, '000-00000'
call vs 'WRITE VSAMTST (KEY 00000010 VAR R10',     0, '000-00000'
call vs 'READ VSAMTST (KEY 00000010 VAR REC',      0, '000-00000'
call eq 'replaced', REC, R10
/* the data stack instead of a variable */
queue '00000040stacked record'
call vs 'INSERT VSAMTST (KEY 00000040',            0, '000-00000'
call eq 'stack consumed', queued(), 0
call vs 'READ VSAMTST (KEY 00000040',              0, '000-00000'
call eq 'stack filled', queued(), 1
parse pull REC
call eq 'stacked', REC, '00000040stacked record'
call vs 'CLOSE ALL',                               0, '000-00000'

/* ---- sequential read ---- */
call vs 'OPEN VSAMTST (READ',                      0, '000-00000'
call vs 'READ VSAMTST (NEXT VAR REC',              0, '000-00000'
call eq 'next 0', REC, FIRST
call vs 'READ VSAMTST (NEXT VAR REC',              0, '000-00000'
call eq 'next 10', REC, R10
call vs 'READ VSAMTST (NEXT VAR REC',              0, '000-00000'
call eq 'next 20', REC, R20
call vs 'READ VSAMTST (NEXT VAR REC',              0, '000-00000'
call eq 'next 30', REC, R30
call vs 'READ VSAMTST (NEXT VAR REC',              0, '000-00000'
call eq 'next 40', REC, '00000040stacked record'
call vs 'READ VSAMTST (NEXT VAR REC',              4
call vs 'LOCATE VSAMTST (KEY 00000020',            0, '000-00000'
call vs 'READ VSAMTST (NEXT VAR REC',              0, '000-00000'
call eq 'locate', REC, R20
call vs 'POINT VSAMTST (KEY 0000003',              0, '000-00000'
call vs 'READ VSAMTST (NEXT VAR REC',              0, '000-00000'
call eq 'point generic', REC, R30
call vs 'LOCATE VSAMTST (KEY 99999999',            4
call vs 'CLOSE ALL',                               0, '000-00000'

/* ---- sequential update and delete ---- */
R20 = '00000020third record, replaced by NEXT'
call vs 'OPEN VSAMTST (UPDATE',                    0, '000-00000'
call vs 'LOCATE VSAMTST (KEY 00000010',            0, '000-00000'
call vs 'READ VSAMTST (NEXT UPDATE VAR REC',       0, '000-00000'
call eq 'update next 10', REC, R10
call vs 'DELETE VSAMTST (NEXT',                    0, '000-00000'
call vs 'READ VSAMTST (NEXT UPDATE VAR REC',       0, '000-00000'
call eq 'update next 20', left(REC, 8), '00000020'
call vs 'WRITE VSAMTST (NEXT VAR R20',             0, '000-00000'
call vs 'CLOSE ALL',                               0, '000-00000'

/* ---- delete by key ---- */
/* a key that is not there must not erase the next higher record */
call vs 'OPEN VSAMTST (UPDATE',                    0, '000-00000'
call vs 'DELETE VSAMTST (KEY 00000025',            8, '004-00004'
call vs 'DELETE VSAMTST (KEY 99999999',            8, '004-00004'
call vs 'DELETE VSAMTST (KEY 0000',                8
call vs 'DELETE VSAMTST (KEY 00000030',            0, '000-00000'
call vs 'READ VSAMTST (KEY 00000030 VAR REC',      4
call vs 'DELETE VSAMTST (KEY 00000030',            8, '004-00004'
/* DELETE names the record to erase, not the one READ ... UPDATE holds */
call vs 'READ VSAMTST (KEY 00000020 UPDATE VAR REC', 0, '000-00000'
call vs 'DELETE VSAMTST (KEY 00000040',            0, '000-00000'
call vs 'READ VSAMTST (KEY 00000040 VAR REC',      4
call vs 'READ VSAMTST (KEY 00000020 VAR REC',      0, '000-00000'
call eq 'held record kept', REC, R20
call vs 'READ VSAMTST (KEY 00000020 UPDATE VAR REC', 0, '000-00000'
call vs 'DELETE VSAMTST (KEY 99999999',            8, '004-00004'
call vs 'READ VSAMTST (KEY 00000020 VAR REC',      0, '000-00000'
call eq 'kept after missing key', REC, R20
/* the held record is the named one */
R40 = '00000040fifth record'
call vs 'INSERT VSAMTST (KEY 00000040 VAR R40',    0, '000-00000'
call vs 'READ VSAMTST (KEY 00000040 UPDATE VAR REC', 0, '000-00000'
call vs 'DELETE VSAMTST (KEY 00000040',            0, '000-00000'
call vs 'READ VSAMTST (KEY 00000040 VAR REC',      4
call vs 'CLOSE ALL',                               0, '000-00000'

/* ---- what is left ---- */
call vs 'OPEN VSAMTST (READ',                      0, '000-00000'
call vs 'READ VSAMTST (NEXT VAR REC',              0, '000-00000'
call eq 'left 0', REC, FIRST
call vs 'READ VSAMTST (NEXT VAR REC',              0, '000-00000'
call eq 'left 20', REC, R20
call vs 'READ VSAMTST (NEXT VAR REC',              4
call vs 'CLOSE ALL',                               0, '000-00000'
call vs 'READ VSAMTST (KEY 00000000 VAR REC',      8, '255-65535'

/* ---- IRXVSMTR, the traced subtask: DD name prefix #%, on OPEN ---- */
call vs 'OPEN #%VSAMTS (READ',                     0, '000-00000'
call vs 'READ VSAMTS (KEY 00000000 VAR REC',       0, '000-00000'
call eq 'traced read', REC, FIRST
call vs 'READ VSAMTS (NEXT VAR REC',               0, '000-00000'
call eq 'traced next', REC, FIRST
call vs 'READ VSAMTS (KEY 00000001 VAR REC',       4
call vs 'CLOSE ALL',                               0, '000-00000'
call vs 'OPEN #%NODD (READ',                       8, '008-00128'
call vs 'OPEN VSAMTST (READ',                      0, '000-00000'
call vs 'CLOSE ALL',                               0, '000-00000'

say 'Done vsamio.rexx'
exit err

/* run VSAMIO cmd; check RC, and RCX when one is given */
vs: procedure expose err rc rcx REC R10 R20 R30 R40 LONG
parse arg cmd, erc, ercx
address mvs 'VSAMIO' cmd
if rc = erc & (ercx = '' | rcx = ercx) then
   say left('VSAMIO',8) '-' left(cmd,44) '.. PASS'
else do
   say left('VSAMIO',8) '-' left(cmd,44) '.. *FAIL* rc' rc 'rcx' rcx,
       'expected' erc ercx
   err = err + 1
end
return

eq: procedure expose err
parse arg what, got, want
if got == want then say left('VSAMIO',8) '-' left(what,44) '.. PASS'
else do
   say left('VSAMIO',8) '-' left(what,44) '.. *FAIL* got' got 'want' want
   err = err + 1
end
return
