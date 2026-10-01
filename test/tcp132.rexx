/* REXX - TCPCLOSE of a socket from TCPOPEN (#132)                     */
/* closeSocket() only closed sockets in the server's client list: a    */
/* TCPOPEN socket stayed open and client 0 was dropped from the list   */
/* instead, so the server never saw the close.                         */
say '----------------------------------------'
say 'File tcp132.rexx'
err = 0
port = 38132
call tcpinit
rc = tcpserve(port)
call check 'TCPSERVE', rc, 0
rc = tcpopen('127.0.0.1', port, 5)
call check 'TCPOPEN', rc, 0
openfd = _fd
ev = tcpwait(5)
call check 'TCPWAIT connect', ev, #connect
call check 'TCPWAIT _IP', _ip, '127.0.0.1'
accfd = _fd
say left('TCP132',8) '- sockets: open' openfd 'accepted' accfd
rc = tcpclose(openfd)
call check 'TCPCLOSE open fd', rc, 0
ev = tcpwait(10)
call check 'TCPWAIT close', ev, #close
call tcpterm
say 'Done tcp132.rexx'
exit err

check:
parse arg what, got, want
if got == want then say left('TCP132',8) '-' left(what,20) '.. PASS'
else do
   say left('TCP132',8) '-' left(what,20) '.. *FAIL*'
   say '   got  "'got'"'
   say '   want "'want'"'
   err = err + 1
end
return
