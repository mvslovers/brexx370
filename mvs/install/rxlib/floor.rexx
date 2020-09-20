/* ---------------------------------------------------------------------
 * Greatest Integer <= Decimal number
 *   integer=FLOOR(decimal-number)
 * ............................... Created by PeterJ on 15. October 2019
 * ---------------------------------------------------------------------
 */
floor:
  _#dec=arg(1)
  _#int=trunc(_#dec)
return _#int-(_#dec<0)*(_#int<>_#dec)
