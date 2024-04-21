/* --------------------------------------------------------------------
 * MTTSCAN Scan MVS Trace Table for registered requests
 * ................................ Created by PeterJ on 23. June 2021
 * --------------------------------------------------------------------
 */
/* --------------------------------------------------------------------
 *  STEP 1: Register MTT Message to be controlled
 * ....................................................................
 *               + ---  REGISTER requestesd action
 *               |          + --- action keyword in trace table
 *               |          |          + --- associated call back proc
 *               Y          Y          Y
 * call ttscan 'REGISTER','$HASP373','hasp373'
 * call ttscan 'REGISTER','$HASP395','hasp395'
 * ....................................................................
 *  STEP 2: Start MTTSCAN for surveillance of registered messages
 * ....................................................................
 *               + ---  Start scanning Trace Table
 *               |     + --- scan frequency in millisedonds
 *               Y     Y          default is 5000
 * call ttscan 'SCAN',2000
 * --------------------------------------------------------------------
 */
Mttscan: Procedure expose ttreg. TfromLine
  parse upper arg p0,p1,p2
  if datatype(ttreg.$key.0)<>'NUM' then call ttscaninit
  if p0='REGISTER'  then call ttregister p1,p2
  else if p0='SCAN' then call ttLoop
  else say 'invalid TTSCAN mode 'p0
return 0
/* --------------------------------------------------------------------
 * Scan every nnn millisconds Trace Table
 * --------------------------------------------------------------------
 */
ttLoop:
  if datatype(p1)<>'NUM' then p1=5000
  say 'Trace Table scan started'
  say 'Scan takes place every 'p1' milliseconds'
  say copies('-',72)
  say 'To abort the scan run RX MTTSTOP, from another userid'
  do forever
     if ttrun()=64 then leave
     call wait p1
  end
  call WTO 'MTTSCAN STOP RECEIVED'
  say 'Trace Table scan has been stopped'
return
/* --------------------------------------------------------------------
 * Single Scan of the Trace Table
 * --------------------------------------------------------------------
 */
ttrun:
  ttreg.$scan=ttreg.$scan+1
  call mtt()
  do i=1 to _line.0
     if _line.i=tfromline then leave
     if pos('TTSCAN STOP',_line.i)>0 then return 64
     do j=1 to ttreg.$key.0
        if pos(ttreg.$key.j,_line.i)>0 then interpret 'call 'ttreg.$callb.j '_line.i'
     end
  end
  tfromline=_line.1
return 0
/* --------------------------------------------------------------------
 * Registers requested Trace Table actions
 * --------------------------------------------------------------------
 */
ttregister:
  ttreg=ttreg.$key.0+1
  ttreg.$key.ttreg=arg(1)
  ttreg.$callb.ttreg=arg(2)
  ttreg.$key.0=ttreg
return
/* --------------------------------------------------------------------
 * Trace Table init
 * --------------------------------------------------------------------
 */
ttscaninit:
  ttreg.$scan=0
  ttreg.$key.0=0
  call mtt()
  do i=1 to _line.0
     wrd=word(_line.i,1)
     if length(wrd)<4  then iterate
     tfromline=_line.i
     leave
  end
  call WTO 'MTTSCAN AUTOMATION STARTED'
return 0
