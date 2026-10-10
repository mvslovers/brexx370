#import "../bookmaster/bookmaster.typ": *

= TCP/IP <ext-tcpip>

#idx("TCP/IP")
With the TCP functions, an exec can be a TCP server that accepts
clients, or a client that connects to a server. They use the TCP/IP
extension of the Hercules emulator (the instruction #cmd("X'75'")),
which TK4- and MVS/CE provide; MVS 3.8j itself has no TCP/IP.

#note[*To be confirmed:* on a Hercules installation that does not
enable it, the extension is switched on in the Hercules configuration,
before the IPL, with
#cmd("FACILITY ENABLE HERC_TCPIP_EXTENSION") and
#cmd("FACILITY ENABLE HERC_TCPIP_PROB_STATE") (see _README.TCPIP_ of SDL
Hyperion).]

== Using the TCP Functions <ext-tcpip-use>

Call #cmd("TCPINIT") first. If the Hercules extension is missing, it
ends in error 63 (_Missing TCPIP support in Hercules_); every other TCP
function called before #cmd("TCPINIT") ends in error 64 (_TCPIP
subsystem not initialized_). A wrong number of arguments ends in
error 40.

A connection is identified by its socket number, the #var("token") of
the functions below. #cmd("TCPOPEN") and #cmd("TCPWAIT") return it in
the variable #cmd("_FD").

The data are sent and received as they are, without translation. A
partner on an ASCII system sends and expects ASCII; translate with
#cmd("A2E") and #cmd("E2A").

When BREXX/370 ends, normally or after an abend, it closes the server
socket and every client socket that is still open.

#note[*To be confirmed:* the old _User's Guide_ said that if this
cleanup fails, a later connect is refused until the sockets are reset
with the TSO command #cmd("RESET").]

#tab(caption: [Variables set by the TCP functions])[
  #table(columns: (1.1in, 1fr),
    [Variable], [Contents],
    [#cmd("#CONNECT")], [1, the event of a new client.],
    [#cmd("#RECEIVE")], [2, the event of data from a client.],
    [#cmd("#TIMEOUT")], [3, the event of a timeout.],
    [#cmd("#CLOSE")], [4, the event of a client that closed its
      connection.],
    [#cmd("#ERROR")], [5, the event of an error.],
    [#cmd("#STOP")], [6, the event of an operator #cmd("STOP")
      command.],
    [#cmd("#EOT")], [-55.],
    [#cmd("_FD")], [The socket of the connection concerned.],
    [#cmd("_IP")], [The IP address of a new client.],
    [#cmd("_PORT")], [The port of a new client.],
    [#cmd("_AVAILABLE")], [The number of bytes that a client has
      sent.],
    [#cmd("_DATA")], [The data that #cmd("TCPRECEIVE") received.],
  )
] <ext-tcpip-vars>

The event constants are set by #cmd("TCPINIT"); the others by the
functions that name them below.

== TCP Functions <ext-tcpip-functions>

=== TCPINIT <ext-tcpip-tcpinit>

#idx("TCPINIT")
```
TCPINIT()
```
Initializes the TCP functions and sets the event constants
(@ext-tcpip-vars). It must be called before any other TCP function. It
returns no value; call it with #cmd("CALL").

```
CALL tcpinit
```

=== TCPSERVE <ext-tcpip-tcpserve>

#idx("TCPSERVE")
```
TCPSERVE(port)
```
Opens a server on #var("port"), on every IP address of the system, for
up to 256 clients. Returns #cmd("0") if the server is listening,
otherwise a negative value. After #cmd("TCPTERM"), or after a
#cmd("TCPSERVE") that failed, #cmd("TCPSERVE") can be called again.
The TCP/IP stack may refuse the same port for a while after it was
closed; #cmd("TCPSERVE") then returns a negative value.

```
IF tcpserve(3270) <> 0 THEN SAY 'server not started'
```

=== TCPWAIT <ext-tcpip-tcpwait>

#idx("TCPWAIT")
```
TCPWAIT([timeout])
```
The wait of a server: returns when something happens on the server
socket or on a client socket, with the number of the event:

#deflist(width: 1.2in,
  [#cmd("#CONNECT")], [A client has connected. It is accepted; its
    socket is in #cmd("_FD"), its address in #cmd("_IP") and
    #cmd("_PORT").],
  [#cmd("#RECEIVE")], [A client has sent data. Its socket is in
    #cmd("_FD"), the number of bytes in #cmd("_AVAILABLE"); read them
    with #cmd("TCPRECEIVE").],
  [#cmd("#CLOSE")], [A client has closed its connection. #cmd("TCPWAIT")
    has already closed the socket, which is in #cmd("_FD").],
  [#cmd("#TIMEOUT")], [#var("timeout") seconds have passed without an
    event.],
  [#cmd("#STOP")], [The operator has given the #cmd("STOP") command
    (#cmd("P")) for the job or started task.],
  [#cmd("#ERROR")], [The wait failed.],
  [#cmd("-1")], [There is no server socket: #cmd("TCPSERVE") was not
    called or could not create it, or #cmd("TCPTERM") has closed it.],
)

Each call reports one event\; when several are pending, such as a client
closing while another connects, the next calls report the others. The
sockets are checked every 2 seconds, so #var("timeout") counts in
steps of 2 seconds, rounded down: 4 and 5 both wait 4 seconds. The count of idle 2-second intervals
goes on across calls and starts again only after #cmd("#TIMEOUT") (and
at #cmd("TCPINIT")): an event does not reset it, so #cmd("#TIMEOUT")
can come sooner than #var("timeout") seconds after the last event.
Without #var("timeout"), or with a #var("timeout") of 1,
#cmd("TCPWAIT") waits without a time limit; a #var("timeout") of 0 ends
in error 40. A
#cmd("STOP") command is noticed only while no other event comes.

```
CALL tcpinit
IF tcpserve(3270) <> 0 THEN EXIT 8
DO FOREVER
   event = tcpwait(20)
   SELECT
      WHEN event = #connect THEN SAY 'client' _ip 'on socket' _fd
      WHEN event = #receive THEN DO
         len = tcpreceive(_fd)
         CALL tcpsend _fd, 'got' len 'bytes'
      END
      WHEN event = #close   THEN SAY 'client' _fd 'closed'
      WHEN event = #timeout THEN NOP
      OTHERWISE LEAVE        /* #stop, #error, -1 */
   END
END
CALL tcpterm
```

=== TCPOPEN <ext-tcpip-tcpopen>

#idx("TCPOPEN")
```
TCPOPEN(host, port [, timeout])
```
The connect of a client: opens a connection to the server at
#var("host") and #var("port"). #var("host") is an IP address or a host
name. #var("timeout") is the number of seconds to wait for the
connection; the default is 5. On success, the socket is in
#cmd("_FD"). The return value is:

#deflist(width: 1.2in,
  [#cmd("0")], [Connected.],
  [#cmd("-3")], [The connection was not made within #var("timeout").],
  [#cmd("-4")], [No socket could be created.],
  [#cmd("-5")], [The host name is not known.],
  [other], [The return code of the connect.],
)
When the connection is not made, the socket is closed again.

```
IF tcpopen('192.168.1.10', 8080, 10) = 0 THEN token = _fd
```

=== TCPSEND <ext-tcpip-tcpsend>

#idx("TCPSEND")
```
TCPSEND(token, data [, timeout])
```
Sends #var("data"), at most 8192 bytes, on the connection #var("token");
longer data end in error 40. #var("timeout") is the number of seconds to
wait until the connection can take data; the default is 5. The return
value is:

#deflist(width: 1.2in,
  [#cmd("0")], [All data were sent.],
  [#cmd("-1")], [Socket error.],
  [#cmd("-2")], [The connection did not take the data within
    #var("timeout").],
)

When the connection takes only part of the data, #cmd("TCPSEND") goes on
with the rest until all is sent or #var("timeout") has passed. Unlike the
old _User's Guide_ says, the function does not return the number of bytes
sent.

```
rc = tcpsend(token, e2a('HELLO'))
```

=== TCPRECEIVE <ext-tcpip-tcpreceive>

#idx("TCPRECEIVE")
```
TCPRECEIVE(token [, timeout])
```
Receives data on the connection #var("token") into the variable
#cmd("_DATA"), at most 8192 bytes at a time. #var("timeout") is the
number of seconds to wait for data; the default is 30. The return value
is:

#deflist(width: 1.2in,
  [#var("n") > 0], [The number of bytes received.],
  [#cmd("0")], [No data were there.],
  [#cmd("42")], [More than 8192 bytes were waiting: #cmd("_DATA") holds
    the first 8192, call #cmd("TCPRECEIVE") again for the rest.],
  [#cmd("-1")], [No data came within #var("timeout"); #cmd("_DATA") is
    empty.],
  [#cmd("-2")], [Socket error.],
)

```
len = tcpreceive(token, 10)
IF len > 0 THEN SAY a2e(_data)
```

=== TCPCLOSE <ext-tcpip-tcpclose>

#idx("TCPCLOSE")
```
TCPCLOSE(token)
```
Closes the connection #var("token"): a client socket of the server, or
a connection that #cmd("TCPOPEN") opened. Returns #cmd("0"), or the
return code of the close.

```
CALL tcpclose token
```

=== TCPTERM <ext-tcpip-tcpterm>

#idx("TCPTERM")
```
TCPTERM()
```
Closes the server socket and all client sockets. It returns no value;
call it with #cmd("CALL").

```
CALL tcpterm
```

== The TCP Server Facility <ext-tcpip-tcpsf>

=== TCPSF <ext-tcpip-tcpsf-fn>

#idx("TCPSF")
```
TCPSF(port [, timeout [, name [, level]]])
```
A complete server loop: #cmd("TCPSF") calls #cmd("TCPINIT") and
#cmd("TCPSERVE"), waits for events with #cmd("TCPWAIT") and calls back
labels in the calling exec for each of them. It is written in REXX and
is a member of RXLIB, not part of the load module, so RXLIB must be
allocated.

#deflist(width: 1.2in,
  [#var("port")], [The port of the server.],
  [#var("timeout")], [Seconds for #cmd("TCPWAIT"); default 60.],
  [#var("name")], [The name of the server in its messages.],
  [#var("level")], [Which messages are written: #cmd("INFO") (all, the
    default), #cmd("WARN"), #cmd("ERROR") or #cmd("NOMSG").],
)

It returns #cmd("0") when the server has ended, and #cmd("8") if the
port is not a number or the server could not be started. The calling
exec must contain these labels:

#deflist(width: 1.2in,
  [#cmd("TCPCONNECT")], [A client has connected; #cmd("ARG(1)") is its
    socket. Return #cmd("0") to go on, #cmd("4") to close the client,
    #cmd("8") to stop the server.],
  [#cmd("TCPDATA")], [A client has sent data. #cmd("ARG(1)") is its
    socket, #cmd("ARG(2)") the data as received, #cmd("ARG(3)") the
    data translated from ASCII to EBCDIC. Return #cmd("0"),
    #cmd("4") or #cmd("8") as above.],
  [#cmd("TCPTIMEOUT")], [The timeout has passed. Return #cmd("0") to go
    on, #cmd("8") to stop the server.],
  [#cmd("TCPCLOSES")], [A client has closed its connection;
    #cmd("ARG(1)") is its socket. Return #cmd("0") to go on, #cmd("8")
    to stop the server.],
  [#cmd("TCPSHUTDOWN")], [The server is stopping; for the cleanup of
    the exec.],
)

In #cmd("TCPTIMEOUT") and #cmd("TCPDATA"), setting the variable
#cmd("NEWTIMEOUT") to a positive number of seconds changes the timeout.
#cmd("TCPSF") itself handles two messages from a client: #cmd("/QUIT")
closes that client, and #cmd("/CANCEL") stops the server. The server
also stops on the operator #cmd("STOP") command. When the server
stops, #cmd("TCPSF") ends the TCP/IP services with #cmd("TCPTERM").
The old _User's Guide_ named the labels #cmd("TCPCLOSE") and
#cmd("TCPSTOP"); #cmd("TCPSF") of 3.0 calls #cmd("TCPCLOSES") and
#cmd("TCPSHUTDOWN"), because #cmd("TCPCLOSE") is the function above.

The sample #cmd("$TCPSERV") in the samples library is a complete
server.

```
rc = tcpsf(3270, 60, 'ECHO')
EXIT rc
tcpconnect: RETURN 0
tcpdata:
   CALL tcpsend arg(1), arg(2)        /* echo it back */
   RETURN 0
tcptimeout:  RETURN 0
tcpcloses:   RETURN 0
tcpshutdown: RETURN 0
```
#note[*Defects* (brexx370 issue 386): none of the operator messages of
#cmd("TCPSF") appear. After #cmd("#ERROR") the loop does not end, and on
#cmd("#CLOSE") it closes a socket that #cmd("TCPWAIT") has already
closed.]

