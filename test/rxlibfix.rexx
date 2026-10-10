/* REXX - RXLIB routines (#386)                                      */
/* MVSTEST RXLIB RXMSG RXMSGCUS STDATE READALL WRITEALL LISTALC MATIN */
/* MVSTEST RXLIB FMTBANNR PERFORM STEMCLEN DAYSBETW PDSDIR           */
/* MVSTEST RC=3                                                      */
/* STDATE between calendar formats returned nothing; READALL with a  */
/* maximum read max+1; WRITEALL never saw a bad range; LISTALC       */
/* dropped the caller's BUFFER.; MATIN never found $ENDDATA;         */
/* FMTBANNR with no text ended the caller (hence RC 3 on success);   */
/* PERFORM ignored DIR's rc; STEMCLEN left stem.0; RXMSGCUS had an   */
/* unterminated string; DAYSBETW called a label of RXDATE; PDSDIR    */
/* called RXDYNALC, which exists nowhere.                            */
say '----------------------------------------'
say 'File rxlibfix.rexx'
err = 0
/* FMTBANNR first: if it ends the exec, the step ends with RC 0 */
call fmtbannr ''
call check 'FMTBANNR empty',  'back', 'back'
/* STDATE */
call check 'STDATE XU to XE', t("stdate('XE','12/31/2025','XU')"),,
     '31/12/2025'
call check 'STDATE XU to I',  t("stdate('I','12/31/2025','XU')"),,
     '2025-12-31'
call check 'STDATE SDW',      t("stdate('SDW','12/31/2025','XU')"),,
     78997.26
/* READALL with a maximum */
mem = "'BREXX."||VER||".TESTS(RXLTMP)'"
call allocate 'rxldd', mem
w.0 = 5
do i = 1 to 5; w.i = 'line' i; end
"EXECIO * DISKW rxldd (STEM w."
call free 'rxldd'
n = readall(mem, , 'DSN', 3)
call check 'READALL max 3',   n readall.0 strip(readall.3), '3 3 line 3'
/* WRITEALL: a range that is not numeric */
s.0 = 2; s.1 = 'one'; s.2 = 'two'
call allocate 'wrtdd', mem
call check 'WRITEALL bad to', t("writeall('wrtdd', 's.', , 1, 'x')"), -8
call check 'WRITEALL after',  writeall('wrtdd', 's.'), 2
call free 'wrtdd'
call check 'WRITEALL wrote',  readall(mem, , 'DSN') strip(readall.2), '2 two'
/* LISTALC keeps the caller's BUFFER. unless asked */
buffer.0 = 7; buffer.1 = 'keep'
n = listalc('NOPRINT')
call check 'LISTALC NOPRINT', (n > 0) buffer.0 buffer.1, '1 7 keep'
/* MATIN with DELIM */
call allocate 'matdd', mem
d.0 = 6; d.1 = '$DATA'; d.2 = 'A B'; d.3 = '1 2'; d.4 = '3 4'
d.5 = '$ENDDATA'; d.6 = '9 9'
"EXECIO * DISKW matdd (STEM d."
call free 'matdd'
m = t("matin('"strip(mem, , "'")"', 'DELIM')")
if datatype(m, 'W') then do
   call mproperty m
   call check 'MATIN DELIM',  _rows.m%1 _cols.m%1 mget(m, 2, 1), '2 2 3'
end
else call check 'MATIN DELIM', m, 'a matrix'
/* PERFORM with a PDS that does not exist, DIRENTRY. from before */
direntry.0 = 0
call check 'PERFORM no PDS',  t("perform('NO.SUCH.PDS', 'X')"), -8
/* STEMCLEN sets stem.0 */
c.0 = 4; c.1 = 'a'; c.2 = ''; c.3 = 'c'; drop c.4
call check 'STEMCLEN',        stemclen('c.') c.0 c.2, '2 2 c'
/* RXMSGCUS */
call check 'RXMSGCUS',        tc('rxmsgcus'), 'ok'
/* DAYSBETW */
call check 'DAYSBETW',        t("daysbetw('01/01/2024','31/12/2024')"), 365
/* PDSDIR on the step's RXLIB, against DIR */
lib = strip("'BREXX.RXLIB'", , "'")'X'
call dir "'"lib"'"
call check 'PDSDIR',          t("pdsdir('"lib"')"), direntry.0
call check 'PDSDIR names',    pdslist.membername.1, direntry.1.name
say 'Done rxlibfix.rexx'
exit err + 3

t: procedure expose readall. direntry. pdslist. _rows. _cols.
signal on syntax name tx
interpret 'r =' arg(1)
return r
tx: return 'error' rc

tc: procedure
signal on syntax name tcx
interpret 'call' arg(1)
return 'ok'
tcx: return 'error' rc

check:
parse arg what, got, want
if got == want then say left('RXLIBFIX',8) '-' left(what,16) '.. PASS'
else do
   say left('RXLIBFIX',8) '-' left(what,16) '.. *FAIL* got' got 'want' want
   err = err + 1
end
return
