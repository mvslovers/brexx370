/* ---------------------------------------------------------------------
 * TCP Server Example
 *     Server handling is done in TCPSF (generic)
 *     Only Events are defined here as call-back routines
 * ---------------------------------------------------------------------
 */
 port=3205     /* listening port       */
 timeout=60    /* time out 60 seconds  */
/* *********************************************************************
 * This is the call to the genereic TCPSF module
 * *********************************************************************
 */
  call TCPSF port,timeout
exit 0
/* *********************************************************************
 * Here follow the Events, called by TCPSF as call-back
 * *********************************************************************
 */
/* ---------------------------------------------------------------------
 * Receive Data from Client, arg(1) original data, arg(2) data
 *         arg(1) original data,
 *         arg(2) ebcdic data translated from ascii
 * ---------------------------------------------------------------------
 */
TCPData:
  parse arg #fd,omsg,emsg
  say time('l')' Received data 'omsg
  say          ' Received a2E  'emsg
return 0     /* proceed normally  */
return 4     /* close  connection */
return 8     /* stop Server       */
/* ---------------------------------------------------------------------
 * Connect to socket was requested
 *         arg(1): socket number
 * This is just an informal call. All TCP related activites are done.
 * you can for example maintain a list of users, etc.
 * ---------------------------------------------------------------------
 */
TCPconnect: say time('l')' Connect Request for 'arg(1)
return 0     /* proceed normally  */
return 4     /* reject connection */
return 8     /* stop Server       */
/* ---------------------------------------------------------------------
 * Time out occurred, here you can perform non TCP related work.
 * ---------------------------------------------------------------------
 */
TCPtimeout: say time('l')" TIMEOUT EVENT"
return 0     /* proceed normally  */
return 8     /* stop Server       */
/* ---------------------------------------------------------------------
 * Close one client socket
 *         arg(1): socket number
 * This is just an informal call. The close has already be peformed
 * you can for example update your list of users, etc.
 * ---------------------------------------------------------------------
 */
TCPcloseS: say time('l')' Close Event 'arg(1)
return 0     /* proceed normally  */
return 8     /* stop Server       */
/* ---------------------------------------------------------------------
 * Shut Down, application cleanup. TCP cleanup is done internally
 * This is just an informal call. The TCP shutdown has been peformed
 * you can do a final cleanup, etc.
 * ---------------------------------------------------------------------
 */
TCPshutDown: say time('l')' SHUT DOWN  Event'
return
