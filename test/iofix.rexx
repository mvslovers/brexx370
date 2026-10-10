say '----------------------------------------'
say 'File iofix.rexx'
/* EXECIO and TCP defects (#386): EXECIO n FIFOR stored n+1 records;   */
/* SKIP with FIFOR and with DISKW from the stack left the last n       */
/* entries out instead of the first n; TCPOPEN kept the socket of a    */
/* failed connect; TCPSEND resent from the start after a partial send. */
err = 0
/* EXECIO n FIFOR */
call qclear
queue 'a'; queue 'b'; queue 'c'
'EXECIO 2 FIFOR (STEM s.'
call check 'FIFOR 2',         s.0 s.1 s.2 queued(), '2 a b 1'
call qclear
queue 'a'; queue 'b'; queue 'c'
'EXECIO * FIFOR (STEM t. SKIP 1'
call check 'FIFOR SKIP 1',    t.0 t.1 t.2 queued(), '2 b c 0'
/* EXECIO DISKW from the stack with SKIP */
VER = UPPER(VERSION())
if index(VER,'(') > 0 then do
  VER = DELSTR(VER,INDEX(VER,'('),1)
  VER = DELSTR(VER,INDEX(VER,')'),1)
end
F = allocate('iofdd',"'BREXX."||VER||".TESTS(IOFTMP)'")
if F >= 4 then do
  say 'IOFIX    - allocate failed' F '.. *FAIL*'
  exit 8
end
call qclear
queue 'a'; queue 'b'; queue 'c'
'EXECIO * DISKW iofdd (SKIP 1'
'EXECIO * DISKR iofdd (STEM r.'
call check 'DISKW SKIP 1',    r.0 strip(r.1) strip(r.2) queued(), '2 b c 0'
call free 'iofdd'
call qclear
/* TCPOPEN closes the socket of a failed connect */
port = 38396
call tcpinit
call check 'TCPSERVE',        tcpserve(port), 0
call check 'TCPOPEN',         tcpopen('127.0.0.1', port, 5), 0
fd1 = _fd
c = tcpwait(5)
call tcpclose fd1
do 20
   x = tcpopen('127.0.0.1', port + 1, 1)
end
call check 'TCPOPEN refused', x < 0, 1
call check 'TCPOPEN again',   tcpopen('127.0.0.1', port, 5), 0
cfd = _fd
call check 'no socket kept',  cfd, fd1
/* TCPSEND of a full buffer arrives whole */
d = copies('0123456789ABCDEF', 512)
rcv = ''
sent = 'no connect'
do 40 while length(rcv) < length(d)
   e = tcpwait(5)
   if e = #connect & sent = 'no connect' then sent = tcpsend(cfd, d)
   else if e = #receive then do
      call tcpreceive _fd, 5
      rcv = rcv || _data
   end
   else if e \= #close & e \= #connect then leave
end
call check 'TCPSEND',         sent, 0
call check 'TCPSEND arrives', length(rcv) (rcv == d), length(d) 1
call tcpterm
say 'Done iofix.rexx'
exit err

qclear: procedure
do queued(); pull .; end
return

check:
parse arg what, got, want
if got == want then say left('IOFIX',8) '-' left(what,16) '.. PASS'
else do
   say left('IOFIX',8) '-' left(what,16) '.. *FAIL* got' got 'want' want
   err = err + 1
end
return
