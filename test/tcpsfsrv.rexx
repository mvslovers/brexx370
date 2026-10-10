/* REXX - TCPSF, the TCP server facility of RXLIB (#386)             */
/* MVSTEST RXLIB TCPSF                                               */
/* TCPWAIT(1) never timed out (a wait under 2 s had no wake-up      */
/* count), so TCPSF with a time-out of 1 waited for ever. The time-  */
/* out exit drives it: a client connects and sends, then closes,     */
/* then the server stops. MAXRC 1: only INFO messages.               */
say '----------------------------------------'
say 'File tcpsfsrv.rexx'
err = 0
port = 38416
ticks = 0; got = ''; closes = 0; stopped = 0
rc = tcpsf(port, 1, 'TSFTEST')
call check 'TCPSF rc',        rc, 0
call check 'data received',   got, 'hello'
call check 'close seen',      closes, 1
call check 'shut down',       stopped, 1
call check 'MAXRC',           maxrc, 1
say 'Done tcpsfsrv.rexx'
exit err

/* the call-backs of TCPSF */
TCPtimeout:
ticks = ticks + 1
if ticks = 1 then do
   if tcpopen('127.0.0.1', port, 5) = 0 then do
      cfd = _fd
      call tcpsend cfd, 'hello'
   end
   return 0
end
if ticks = 2 then do
   call tcpclose cfd
   return 0
end
return 8
TCPconnect: return 0
TCPData:
got = got || arg(2)
return 0
TCPcloseS:
closes = closes + 1
return 0
TCPshutdown:
stopped = 1
return 0

check:
parse arg what, gotv, want
if gotv == want then say left('TCPSF',8) '-' left(what,16) '.. PASS'
else do
   say left('TCPSF',8) '-' left(what,16) '.. *FAIL* got' gotv 'want' want
   err = err + 1
end
return
