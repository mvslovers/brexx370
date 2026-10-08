say '----------------------------------------'
say 'File tcpwait.rexx'
/* TCPWAIT without a server waited on socket 0 (server_socket was an  */
/* unset global, i.e. 0) instead of answering -1; TCPTERM left the    */
/* server's number in place, so a second TCPSERVE was error 40 and a  */
/* TCPWAIT afterwards used the closed socket (#386).                  */
err = 0
port = 38386
call tcpinit
call check 'TCPWAIT no server',  tcpwait(1), -1
call check 'TCPSERVE',           tcpserve(port), 0
rc = tcpopen('127.0.0.1', port, 5)
call check 'TCPOPEN',            rc, 0
call check 'TCPWAIT connect',    tcpwait(5), #connect
call tcpterm
call check 'TCPWAIT after TERM', tcpwait(1), -1
/* another port: right after TCPTERM, MVS/CE refuses to bind the     */
/* closed one again (-1); the point is that it is no error 40 any more */
call check 'TCPSERVE again',     t('tcpserve(' port + 1 ')'), 0
call tcpterm
say 'Done tcpwait.rexx'
exit err

t: procedure
signal on syntax name tx
interpret 'r =' arg(1)
return r
tx: return 'error' rc

check:
parse arg what, got, want
if got == want then say left('TCPWAIT',8) '-' left(what,20) '.. PASS'
else do
   say left('TCPWAIT',8) '-' left(what,20) '.. *FAIL* got' got 'want' want
   err = err + 1
end
return
