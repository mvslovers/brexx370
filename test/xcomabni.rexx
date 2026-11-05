/* REXX - the inner exec of xcomabnd.rexx (#609)                       */
/* Argument: the address of a block from TSTXCOM ALOC (hex). Puts it   */
/* on top of this exec's ENVBLOCK as a fake block and abends S0C1.     */
/* RC 8 or 9 if it comes to anything else. In a batch step without an */
/* ECT there is nothing to look at: RC 0.                              */
parse arg fkh .
ascb = peeka(548)
asxb = peeka(ascb + 108)
lwa  = peeka(asxb + 20)
if lwa = 0 then exit 0
mmode = 'MID '
fk = x2c(fkh)
address LINKMVS 'TSTXCOM MMODE FK'
if rc \= 0 then exit 8
a1 = 'ABND'; a2 = ''
address LINKMVS 'TSTABND A1 A2'
exit 9
