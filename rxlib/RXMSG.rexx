/* --------------------------------------------------------------------
 * PRINT standardised BREXX message
 * ..................................... Created by PeterJ on 21.01.2019
 * .. Customising added ............... Modified by PeterJ on 22.03.2020
 * Customising optional
 *   rc=RXmsg('CUST','ms-prefix',ms-number-length,ms-text-length,case)
 *      ms-prefix         Message prefix
 *      ms-number-length  length of message number
 *      ms-text-length    length of message, 0 or omit, if unlimited
 *      case              1 for case sensitive, 0 or omit for upper case
 * Example:
 *   rc=RXmsg( 10,'I','Program has been started')
 *   rc=RXmsg(100,'E','Value is not Numeric')
 *   rc=RXmsg(200,'W','Value missing, default used')
 *   rc=RXmsg(999,'C','Division will fail as divisor is zero')
 * will return:
 *   RX0010I    PROGRAM HAS BEEN STARTED
 *   RX0100E    VALUE IS NOT NUMERIC
 *   RX0200W    VALUE MISSING, DEFAULT USED
 *   RX0999C    DIVISION WILL FAIL AS DIVISOR IS ZERO
 * Additional the internal variable MAXRC contains the highest
 * return code produced by all RXMSG calls, where
 *    I   produces 0       Information Message
 *    W   produces 4       Warning Message
 *    E   produces 8       Error Message
 *    C   produces 12      Critical Message
 * using EXIT MAXRC will return the value to MVS, which then can be
 * seen in the job output.
 * !! if RXMSG is used in PROCEDURES it must EXPOSE MAXRC, otherwise
 * !! it will not be seen in the callers routines
 * --------------------------------------------------------------------
 * by setting the variable RXMSLV, you can omit messages of a certain
 * level:
 *    RXMSLV='E'    prints only messages level C,E
 *    RXMSLV='W'    prints only messages level C,E,W
 *    RXMSLV='I'    prints only messages level C,E,W,I
 *    RXMSLV='N'    suppress any message
 *    RXMSLV='I'    is default
 * --------------------------------------------------------------------
 * Additionally the following Variables are exposed to the calling REXX:
 *    msrc  Return code create by Message
 *    maxrc Highest Return Code so far
 *    mslv  Message Level created by Message
 *    mstx  Message Text created by Message
 *    msln  Message Line created by Message
 * --------------------------------------------------------------------
 */
rxmsg:
/* ..... Check if in customising mode ................................*/
  if abbrev('CUSTOMISE',arg(1),3)=1 then do
     rc=rxmsginit(arg(2),arg(3),arg(4),arg(5))
     return 0
  end
  if symbol('$msgp1len')='LIT' then call rxmsginit
/* ..... Print Message ...............................................*/
  parse arg msno,mslv,mstx
  msno=msno%1    /* force integer */
  if datatype(RXmslv)<>'NUM' then call rxmsgini1
  RXmslv=min(5,abs(RXmslv))%1
  if datatype(maxrc)<>'NUM' then maxrc=0
  msrc =translate(mslv,"C84000","CEWITA")
  maxrc=trunc(max(maxrc,x2d(msrc)))%1  /* force integer */
  mslv =translate(mslv,'I','A')
  if $msgtlen>0 then mstx=left(mstx,$msgtlen)
  msln=left($msgpref''right(msno,$msgnlen,'0')mslv,$msgp1len)' 'mstx
  if $msgcase=0 then msln=translate(msln)
  if RXMSLV=0 then return x2d(msrc) /* Suppress all Messages */
  if translate(mslv,"112345","CEWITA")>RXmslv then return 0
  say msln
return x2d(msrc)
/* --------------------------------------------------------------------
 * Init RXMSG
 * --------------------------------------------------------------------
 */
rxmsgini1:
  if RXmslv='RXMSLV' then RXmslv=4
  else RXmslv=translate(RXmslv,"1123450","CEWITAN")
  if datatype(RXmslv)<>'NUM' then RXmslv=4
  if $msginit<>1 then call rxmsginit
return
/* --------------------------------------------------------------------
 * Customise RXMSG with user definitions
 * --------------------------------------------------------------------
 */
rxmsginit:
  parse arg $msgpref,$msgnlen,$msgtlen,$msgcase
  if $msgpref='' | symbol('$msgpref')  ='LIT' then $msgpref='RX'
  if $msgnlen='' | datatype($msgnlen) <>'NUM' then $msgnlen=4
  if $msgtlen='' | datatype($msgtlen) <>'NUM' then $msgtlen=0
  if $msgcase='' | datatype($msgcase) <>'NUM' then $msgcase=0
  $msgp1len=length($msgpref)+$msgnlen+4
  $msginit=1
return 0
