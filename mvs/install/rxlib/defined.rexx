/* ---------------------------------------------------------------------
 *  DEFINED returns Variable Status
 *  ................................ Created by PeterJ on 11. March 2019
 *  returns 1:   specified string is a String Variable
 *          2:   specified string is a Numeric Variable
 *          0:   specified string is a Literal (not a Variable)
 *         -1:   specified string would be invalid Variable name
 * ---------------------------------------------------------------------
 */
Defined:
_defnd=symbol(arg(1))
if _defnd=='VAR' then do
   if datatype(_defnd)=='NUM' then return 2
   return 1
end
if _defnd=='LIT' then return 0
return -1
