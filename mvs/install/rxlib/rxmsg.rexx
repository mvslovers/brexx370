/* --------------------------------------------------------------------
 * PRINT standardised BREXX message
 * .................................... Created by PeterJ on 21.01.2019
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
parse upper arg msno,mslv,mstx
if datatype(RXmslv)<>'NUM' then do
   if RXmslv='RXMSLV' then RXmslv=4
   else RXmslv=translate(RXmslv,"1123450","CEWITAN")
   if datatype(RXmslv)<>'NUM' then RXmslv=4
end
RXmslv=min(5,abs(RXmslv))%1
if datatype(maxrc)<>'NUM' then maxrc=0
msrc =translate(mslv,"C84000","CEWITA")
maxrc=trunc(max(maxrc,x2d(msrc)))
mslv=translate(mslv,'I','A')
msln=left('RX'right(msno,4,0)mslv,10)' 'mstx
if RXMSLV=0   then return x2d(msrc) /* Suppress all Messages */
if translate(mslv,"112345","CEWITA")>RXmslv then return 0
say msln
return x2d(msrc)
