# TCP Functions

TCP Functions are only usable in TK4- and MVS/CE, or an equivalent
MVS3.8j installation running on SDL Hyperion with activated TCP support.
For non TK4- or MVS/CE installation it might be necessary to start the
TCP functionality in the Hercules console before the IPL of MVS is
performed:

```default
facility enable HERC_TCPIP_EXTENSION
facility enable HERC_TCPIP_PROB_STATE
```

for details you look up the following document:
[https://github.com/SDL-Hercules-390/hyperion/blob/master/readme/README.TCPIP.md](https://github.com/SDL-Hercules-390/hyperion/blob/master/readme/README.TCPIP.md)

#### WARNING
If TCP support is not enabled, the TCP environment is in an
undefined state, and all subsequent TCP functions will end up with
indeterminate results or even cause an ABEND.

#### WARNING
In case of errors or ABENDs an automatic cleanup of open TCP sockets
takes place. If in rare cases the cleanup cannot resolve it a
reconnect will be rejected. You can then reset all sockets by the
TSO command RESET.

### TCPINIT()

TCPINIT initialises the TCP functionality. It is a mandatory call
before using any other TCP function.

### TCPSERVE(port-number)

TCPSERVE opens a TCP Server on the defined port-number for all its
assigned IP-addresses.

The function returns zero if it is performed successfully, else an
error occurred.

### TCPOPEN(host-ip, port-number)

Client function to open a connection to a server. Host-ip can be an
ip-address or a host-name, which translates into an ip-address.
Port-number is the port in which the server listens for incoming
requests. The timeout parameter defines how long the function will
wait for a confirmation of the open request; the default is 5
seconds.

If rc= 0 the open was successful if less than zero an error occurred
during the open process.

The BREXX variable \_FD contains the unique token for the connection.
It must be used in various TCP function calls to address the
appropriate socket.

### TCPWAIT()

TCPWAIT is a Server function; it waits for incoming requests from a
client. The optional timeout parameter defines an interval in
seconds after the control is returned to the server, to perform for
example some cleanup activities, before going again in a wait.
TCPWAIT returns several return codes which allow checking which
action has ended the wait:

| Return   | Description                                                            |
|----------|------------------------------------------------------------------------|
| #receive | an incoming message from a client has been received                    |
| #connect | a new client requests a connect                                        |
| #timeout | a time-out occurred                                                    |
| #close   | a close request from a client occurred                                 |
| #stop    | a socket returned stop; typically the socket connection has been lost. |
| #error   | an unknown error occurred in the socket processing                     |

Example of a server TCPWAIT and how it is processed:

Example:

```default
/* rexx */
do forever
  event = tcpwait(20)
  if event <= 0 then call eventerror event
  select
    when event = #receive then do
      rc=receive()
      if rc=0 then iterate /* proceed */
      if rc=4 then leave /* close client socket */
      if rc=8 then leave /* shut down server */
    end
    when event = #connect then call connect
    when event = #timeout then call timeout
    when event = #close then call close
    when event = #stop then call close /* is /F console cmd */
    when event = #error then call eventError
    otherwise call eventError
  end
end
```

### TCPSEND(clientToken, message)

Sends a message to a client. ClientToken specifies the unique socket
of the client. The optional timeout parameter allows the maximum
wait time in seconds to wait for confirmation from the client, that
it has received it. The default timeout is 5 seconds.

If sendLength is less than zero, an error occurred during the
sending process:

- >0 message has been sent and received by the client, number of bytes transferred
- -1 socket error
- -2 client is not ready to receive a message

Example: SendLength=TCPSEND(clientToken, message[,time-out-secs])

### TCPReceive(clientToken)

The message length is returned by the TCPRECEIVE Function, The
message itself is provided in the variable \_Data.

If messageLength is less than zero, an error occurred during the receiving process:

- >0 message has been received from, number of bytes received
- -1 client is not ready to receive a message
- -2 socket error

Example: MessageLength=TCPReceive(clientToken,[time-out-secs])

### TCPTERM()

Closes all client sockets and removes the TCP functionality

### TCPSF(port)

TCPSF is a generic TCP Server Facility. It opens a TCP server and
controls all events. Call-back labels in the calling rexx support
the event handling. Therefore the calling REXX-script must contain
the following labels:

| **Label**   | **Description**                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
|-------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| TCPCONNECT  | There was a client connect request. The connect will be performed by the TCPSF.<br/><br/><br/>If you want, you can do some logging of the incoming requests.<br/><br/><br/><br/><br/>ARG(1)) client token<br/><br/><br/><br/><br/>Return codes from user procedure control the continuation:<br/><br/><br/><br/><br/>return:<br/><br/><br/>- 0 proceed<br/><br/><br/>- 4 immediately close client<br/><br/><br/>- 8 shut down server<br/><br/>                                           |
| TCPTIMEOUT  | There was a time-out, no user requests occurred. Typically it is used to allow some<br/><br/><br/>maintenance. Doing nothing (plain return 0) is also possible. If the user procedure<br/><br/><br/>wants to set a new time-out value, it must be set in the rexx variable NEWTIMEOUT. It<br/><br/><br/>is set in seconds.<br/><br/><br/><br/><br/>There are no arguments passed.<br/><br/><br/><br/><br/>return:<br/><br/><br/>- 0 proceed<br/><br/><br/>- 8 shut down server<br/><br/> |
| TCPDATA     | client has sent a message<br/><br/><br/><br/><br/>ARG(1) client token<br/><br/><br/>ARG(2) contains the original message<br/><br/><br/>ARG(3) contains the message translated from ASCII to EBCDIC<br/><br/><br/><br/><br/>Return codes from user procedure control the continuation:<br/><br/><br/>- 0 proceed<br/><br/><br/>- 4 immediately close client<br/><br/>                                                                                                                     |
| TCPCLOSE    | client has closed the connection. TCPCLOSE can be used for housekeeping.<br/><br/><br/><br/><br/>ARG(1) client token<br/><br/><br/><br/><br/>Return codes from user procedure control the continuation:<br/><br/><br/>-0 proceed<br/><br/><br/>-8 shut down server<br/><br/>                                                                                                                                                                                                             |
| TCPSTOP     | client will be stopped.<br/><br/><br/><br/><br/>ARG(1) client token<br/><br/><br/><br/><br/>There is no special return code treatment<br/><br/>                                                                                                                                                                                                                                                                                                                                          |

The following commands sent from a client are processed from the TCP Server:

- /CANCEL shut down the TCP server
- /QUIT log off the client from the TCP Server

An example of a TCP Server is defined in BREXX.V2R5M3.SAMPLE($TCPSERV)
