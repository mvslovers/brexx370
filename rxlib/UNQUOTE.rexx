/* ---------------------------------------------------------------------
 * UNQUOTE String (remove delimeters from string)
 *   Unquote(string)
 *     if 1. char is " and last char is " they will be removed
 *     if 1. char is ' and last char is ' they will be removed
 *     if 1. char is ( and last char is ) they will be removed
 *     if 1. char is < and last char is > they will be removed
 * ...............................Created by PeterJ on 11. December 2018
 * ...............................Amended by PeterJ on 30. March    2019
 * ---------------------------------------------------------------------
 */
UNQuote: procedure
parse arg unq
_n=length(unq)
_f=substr(unq,1,1)
_l=substr(unq,_n,1)
if      _f='"' & _l='"' then _u=1
else if _f="'" & _l="'" then _u=1
else if _f='(' & _l=')' then _u=1
else if _f='<' & _l=">" then _u=1
else if _f='[' & _l="]" then _u=1
if _u=1 then return substr(unq,2,_n-2)
return unq
