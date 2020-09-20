/* ---------------------------------------------------------------------
 *  P2D  Converts Packed Decimal into Decimal Number
 *  ............................ Created by PeterJ on 08. October 2018
 *  D2P(decimal-number)
 * ---------------------------------------------------------------------
 */
p2d:
_unpck=c2x(arg(1))      /* convert full _decmber    */
_unpks=right(_unpck,1)  /* get right most character */
_decm =left(_unpck,length(_unpck)-1)+0 /* remove sign & leading 0 */
if _unpks='D' then return -_decm
if _unpks='B' then return -_decm
return _decm
