/* ---------------------------------------------------------------------
 *  D2P  Converts Decimal Number into Packed Decimal
 *  ............................ Created by PeterJ on 08. October 2018
 *  D2P(decimal-number,length-of-packed-number)
 * ---------------------------------------------------------------------
 */
d2p:
  parse arg _decimal , _pcklen
  if _pcklen='' then _pcklen=6
  _decimal=_decimal+0   /* drop + sign, if any */
  #sign='C'
  if _decimal<0 then do
     #sign= "D"
     _decimal = substr(_decimal,2)
  end
  _pcktm=right(_decimal,_pcklen*2-1,'0')''#sign
return x2c(_pcktm)
