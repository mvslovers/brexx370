/* ------------------------------------------------------------------
 * Scan Master Trace Table for LOGON/LOGOFF actions
 * ------------------------------------------------------------------
 */
/* ------------------------------------------------------------------*/
/*            + ---  REGISTER requestesd action                      */
/*            |           + --- action keyword in trace table        */
/*            |           |          + --- associated call back proc */
/*            Y           Y          Y                               */
call mttscan 'REGISTER','$HASP373','hasp373'
call mttscan 'REGISTER','$HASP395','hasp395'

/*            + ---  Start scanning Trace Table                      */
/*            |     + --- scan frequency in millisedonds             */
/*            Y     Y          default is 5000                       */
call mttscan 'SCAN',2000
return
/* --------------------------------------------------------------------
 * Call Back to handle $HASP373 Entries of the Trace Table: user LOGON
 *    arg(1) contains the selected line of the Trace Table
 * --------------------------------------------------------------------
 */
hasp373:
  user=word(arg(1),6)
/* call console 'c u='user     You can for example cancel the user   */
  say user ' has logged on'
  say 'Trace Table entry: 'arg(1)
  say copies('-',72)
return
/* --------------------------------------------------------------------
 * Call Back to handle $HASP395 Entries of the Trace Table: user LOGOFF
 *   arg(1) contains the selected line of the Trace Table
 * --------------------------------------------------------------------
 */
hasp395:
  user=word(arg(1),6)
  say user ' has logged off'
  say 'Trace Table entry: 'arg(1)
  say copies('-',72)
return
