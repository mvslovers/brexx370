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
cvt:  return PEEKA(16)
tcb:  return PEEKA(540)
ascb: return PEEKA(548)
Tiot: return PEEKA(tcb()+12)
jscb: return PEEKA(tcb()+180)
cscb: return peeka(ascb()+56)
tsb:  return peeka(cscb()+60)
cib:  return peeka(cscb()+44)
rmct: return PEEKA(cvt()+604)
asxb: return PEEKA(ascb()+108)
acee: return PEEKA(asxb()+200)
ecvt: return PEEKA(cvt()+328)
smca: return PEEKA(cvt()+196)
dsab: return 12+PEEKA(320+PEEKA(180+PEEKA(PEEKA(PEEKA(16)))))
cpu:  return d2x(c2d(storage(d2x(cvt()-6),2)))
