/* ---------------------------------------------------------------------
 * LISTALC  find allocated ddnames and datasets
 * ................... Converted to BREXX By PeterJ on 20. November 2018
 * Author: unknown
 * numfiles=_LISTALC(<PRINT/NOPRINT>)
 *   numfiles    files found
 *   PRINT       display found allocations, and return in stem variables
 *   NOPRINT     return results in stem variables
 *   BUFFER      return results in STEM BUFFER.
 *   PRINT       is default
 * Results are returned in:
 *  listalcDDN.n  contains the allocated dd name
 *  listalcDSN.n  contains the allocated dsname (incl. member, if any)
 *  listalcDDN.0  contain the number of entries
 *  listalcDSN.0  contain the number of entries
 *  listalcDSN.n and listalcddn.n correspond
 * ---------------------------------------------------------------------
 */
listALC: procedure expose listalcDDN. listalcDSN. buffer.
  parse upper arg noprint
  noprint=abbrev("NOPRINT",noprint,1)
  buffer=abbrev("BUFFER",arg(1),1)
  alcount=0
  drop listalcDDN. listalcDSN. buffer.
  tiot_ddn=24+TIOT()                        /* get ddname array      */
  tioelngh=_dmemory(tiot_ddn,1)             /* length of 1st entry   */
  do until tioelngh=0                       /* scan all dd allocations*/
     tioeddnm=_dxstorage(tiot_ddn+4,8)      /* get ddname from tiot  */
    /* if unalloc occured in Task, TIOEDDNAME is (partly) zeroed  out*/
     if c2d(substr(tioeddnm,1,1))<>0 then do
        alcount=alcount+1
        listalcDDN.alcount=tioeddnm
        listalcDSN.alcount=getdsndetail()
        if noprint=1 then nop
        else if buffer=1 then do
           buffer.alcount=left(listalcddn.alcount,10)listalcdsn.alcount
        end
        else say left(listalcddn.alcount,10)listalcdsn.alcount
     end
     tiot_ddn=tiot_ddn+tioelngh             /* get next entry         */
     tioelngh=_dmemory(tiot_ddn,1)          /* get entry length       */
  end
  buffer.0=alcount
  listalcDDN.0=alcount
  listalcDSN.0=alcount
return alcount                            /* return result caller   */
/* ---------------------------------------------------------------------
 * GETDSNDETAIL retrieve details of allocated ddname
 * ---------------------------------------------------------------------
 */
GetDsnDetail:
  tioelngh=_dmemory(tiot_ddn,1)           /* length of next entry   */
  tioejfcb=_dxstorage(tiot_ddn+12,3)
  tioelink=_dxstorage(tiot_ddn+3,1)
  if bitand(tioelink,'20'x)='20'x then return '*terminal'
  if bitand(tioelink,'02'x)='02'x then return '*sysout'
  jfcb=c2d(tioejfcb)+16
  dsname=strip(_dxstorage(jfcb,44))       /*dsname jfcbdsnm         */
  member=strip(_dxstorage(jfcb+44,8))     /* member or rel. gdgnum  */
  if member='' then return dsname
return dsname''"("member")"
/* ---------------------------------------------------------------------
 * Address some MVS Control Blocks
 * ---------------------------------------------------------------------
 */
tcb: return _adr(540)           /* TCB address at 540 = '21C'X of PSA */
Tiot: return _adr(tcb()+12)      /* TIOT address at TCB + 12   */
jscb: return _adr(tcb()+180)
/* ---------------------------------------------------------------------
 * return STORAGE as a POINTER (decimal)
 * ---------------------------------------------------------------------
 */
_adr: return c2d(_dxstorage(arg(1),4))    /* return pointer (decimal) */
_dmemory: return c2d(_dxstorage(arg(1),arg(2))) /* return dec memory val */
_dxstorage: return storage(d2x(arg(1)),arg(2))
