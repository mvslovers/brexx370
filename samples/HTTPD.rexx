/* ---------------------------------------------------------------------
 * HTTP Server
 * ---------------------------------------------------------------------
 */
if httpinit()=8 then exit 8
/* ---------------------------------------------------------------------
 * Handle WEB Requests
 * ---------------------------------------------------------------------
 */
do forever
    event = tcpwait(2)
    _$server.eveni=_$server.eveni+1
    select
        when event = #receive then do
             _$server.evenr=_$server.evenr+1
             call httplog 'incoming receive request, count='_$server.evenr
             bytes = tcpreceive(_fd); /* received data are in _DATA */
             crc=checkdata()
             if crc=128 then leave
             if crc>0   then iterate
             html=handleRequest(_data,page)
             call tcpsend(_fd,tre2a(html))
             _$server.evens=_$server.evens+1
             call httplog page' Data were sent, count='_$server.evens
        end
        when event = #stop  then signal opStop
        when event = #error then signal tcpError
        otherwise _$server.eveno=_$server.eveno+1
    end
end
signal opStop
/* ---------------------------------------------------------------------
 * Handle Errors or STOP commands from Console
 * ---------------------------------------------------------------------
 */
opStop:
  call wto     "HTTPD will be stopped"
  call httplog "HTTPD will be stopped"
  exc=0
  signal svrClose
tcpError:
  call wto     "HTTPD got an error event"
  call httplog "HTTPD got an error event"
  exc=event
  signal svrClose
/* ---------------------------------------------------------------------
 * Shutdown HTTP Server
 * ---------------------------------------------------------------------
 */
svrClose:
  call wto 'HTTPD Receive Events '_$server.evenr
  say 'HTTPD Receive Events '_$server.evenr
  say 'HTTPD Send Requests   '_$server.evens
  say 'HTTPD Events ignored '_$server.eveno
  say 'HTTPD Events total    '_$server.eveni
  CALL TCPTerm()
  call wto 'HTTPD has been stopped, rc='exc
  say 'HTTPD has been stopped, rc='exc
exit exc
/* ---------------------------------------------------------------------
 * Check HTTP Request
 * ---------------------------------------------------------------------
 */
checkData:
  request=trA2E(substr(_data,1,32))
  parse upper value request with mode' /'request' 'remain
  firstc=substr(mode,1,1)
  if firstc='04'x then return 16
  if firstc='37'x then return 16
  if mode<>'GET'  then return 8
  parse value request with page'.'remain
  if page='' then page='httpmain'
  call wto('HTTPD Receive request from '_port' 'mode' 'page)
  if page='$CANCEL' then return 128
return 0
/* ---------------------------------------------------------------------
 * Create HTML Page
 * ---------------------------------------------------------------------
 */
handleRequest:
  call rxcgi arg(2)
  payload=''
  do i=1 to _$pshl.0
     payload=payload||_$pshl.i
  end
  len = length(payload)
/* create header */
  header = "http/1.1 200 ok"                  /* set status code */
  header = header"0d25"x                      /* newline after each header */
  header = header"content-type: text/html"
  header = header"0d25"x
  header = header"content-length: "len        /* set payload length */
  header = header"0d250d25"x
return header || payload
/* ---------------------------------------------------------------------
 * Log HTTP Requests
 * ---------------------------------------------------------------------
 */
httplog:
  httpi=httpi+1
  if httpi>500 then httpi=2   /* do not overwrite start entry */
  _$server.httplog.httpi=date()' 'time('l')' 'right(_port,6)' 'arg(1)
  _$server.httplog.0=httpi
  if arg(2)<>1 then return
  say date()' 'time('l')'  'arg(1)
return
tre2a: return translate(arg(1),e2atab)
tra2e: return translate(arg(1),a2etab)
/* ---------------------------------------------------------------------
 * Init HTTP Server
 * ---------------------------------------------------------------------
 */
httpinit:
  httpi=0
  _$server.eveni=0
  _$server.eveno=0
  _$server.evenr=0
  _$server.evens=0
  call tcpinit()
  _port=8080
  ret = tcpserve(_port)
  if ret=0 then do
     call httplog 'HTTPD Server started',1
     call wto     'HTTPD started '
  end
  else do
     call httplog 'HTTPD failed to start, rc='ret,1
     call wto     'HTTPD failed to start, rc='ret
  end
/* ---------------------------------------------------------------------
 * Load e2a and a2E table to improve performance
 * ---------------------------------------------------------------------
 */
  e2aTab='000102030009007F0000000B0C0D0E0F'x||,
         '1011121300000800181900001C1D1E1F'x||,
         '00000000000A171B0000000000050607'x||,
         '0000160000000004000000001415001A'x||,
         '20000000000000000000002E3C282B7C'x||,
         '2600000000000000000021242A293B7E'x||,
         '2D2F0000000000000000002C255F3E3F'x||,
         '005E00000000000000603A2340273D22'x||,
         '00616263646566676869007B00000000'x||,
         '006A6B6C6D6E6F707172007D00000000'x||,
         '007E737475767778797A0000005B0000'x||,
         '000000000000000000000000005D0000'x||,
         '7B414243444546474849000000000000'x||,
         '7D4A4B4C4D4E4F505152000000000000'x||,
         '5C00535455565758595A000000000000'x||,
         '30313233343536373839000000000000'x

  a2etab='00010203372D2E2F1605250B0C0D0E0F'x||,
         '101112133C3D322618193F271C1D1E1F'x||,
         '405A7F7B5B6C507D4D5D5C4E6B604B61'x||,
         'F0F1F2F3F4F5F6F7F8F97A5E4C7E6E6F'x||,
         '7CC1C2C3C4C5C6C7C8C9D1D2D3D4D5D6'x||,
         'D7D8D9E2E3E4E5E6E7E8E9ADE0BD716D'x||,
         '79818283848586878889919293949596'x||,
         '979899A2A3A4A5A6A7A8A9C04FD05F07'x||,
         '00010203372D2E2F1605250B0C0D0E0F'x||,
         '101112133C3D322618193F271C1D1E1F'x||,
         '405A7F7B5B6C507D4D5D5C4E6B604B61'x||,
         'F0F1F2F3F4F5F6F7F8F97A5E4C7E6E6F'x||,
         '7CC1C2C3C4C5C6C7C8C9D1D2D3D4D5D6'x||,
         'D7D8D9E2E3E4E5E6E7E8E9ADE0BD716D'x||,
         '79818283848586878889919293949596'x||,
         '979899A2A3A4A5A6A7A8A98B4F9B5F07'x
return 0
