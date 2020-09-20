/* ---------------------------------------------------------------------
 * Return Addresses of some MVS Control Blocks
 * .............................. Created by PeterJ on 25. February 2019
 * MVSCBs must be imported before it can be used
 * e.g.
 *   rc=IMPORT(MVSCBS)
 *   say tcb()
 *   say cvt()
 *   say tiot()
 *    ...
 * ---------------------------------------------------------------------
 */
mvscbs: return 0
cvt:  return _ptr(16)
tcb:  return _ptr(540)
ascb: return _ptr(548)
Tiot: return _ptr(tcb()+12)
jscb: return _ptr(tcb()+180)
rmct: return _ptr(cvt()+604)
asxb: return _ptr(ascb()+108)
acee: return _ptr(asxb()+200)
ecvt: return _ptr(cvt()+328)
smca: return _ptr(cvt()+196)
/* ---------------------------------------------------------------------
 * return storage as a POINTER (decimal)
 * ---------------------------------------------------------------------
 */
_ptr:
 return c2d(storage(d2x(arg(1)),4))    /* return pointer (decimal)   */
