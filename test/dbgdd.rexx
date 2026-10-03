say '----------------------------------------'
say 'File dbgdd.rexx (diagnostic, temporary)'
VER = UPPER(VERSION())
if index(VER,'(') > 0 then do
  VER = DELSTR(VER,INDEX(VER,'('),1)
  VER = DELSTR(VER,INDEX(VER,')'),1)
end
tlib  = "'BREXX."||VER||".TESTS'"
tlibm = "'BREXX."||VER||".TESTS(LISTDSI)'"
seq = "'BREXX."||VER||".TESTSEQ'"
say 'DBGDD dd1' listdsi('RXLIB FILE')
say 'DBGDD dd2' listdsi('RXLIB FILE')
say 'DBGDD missing' listdsi("'BREXX.NO.SUCH.DSN'") listdsi('RXLIB FILE')
say 'DBGDD half' listdsi("'BREXX.HALF") listdsi('RXLIB FILE')
say 'DBGDD noprefix' listdsi(strip(tlib,,"'")) listdsi('RXLIB FILE')
say 'DBGDD n300' listdsi("'"copies('A',300)"'") listdsi('RXLIB FILE')
say 'DBGDD pds' listdsi(tlib) listdsi('RXLIB FILE')
say 'DBGDD ps' listdsi(seq) listdsi('RXLIB FILE')
say 'DBGDD member' listdsi(tlibm) listdsi('RXLIB FILE')
say 'DBGDD outdd' listdsi('OUTDD FILE') listdsi('RXRUN FILE') listdsi('STEPLIB FILE')
exit 0
