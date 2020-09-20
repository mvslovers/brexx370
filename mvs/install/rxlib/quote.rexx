/* ---------------------------------------------------------------------
 * QUOTE String (enclose string in delimeter)
   Quote(string,<delimeter>)
     delimeter defaults to '
     if delimeter is ' string will be enclosed in single quotes
     if delimeter is " string will be enclosed in double quotes
     if delimeter is ( string will be enclosed in (string)
     if delimeter is < string will be enclosed in <string>
 * ..................................Created by PeterJ on 30. March 2019
 * ---------------------------------------------------------------------
 */
Quote: procedure
parse arg ustr,qtype
if qtype=""  then return "'"ustr"'"
if qtype="'" then return "'"ustr"'"
if qtype='"' then return '"'ustr'"'
if qtype='(' then return '('ustr')'
if qtype='[' then return '['ustr']'
if qtype='<' then return '<'ustr'>'
return "'"ustr"'"
