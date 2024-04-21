/* -----------------------------------------------------------
 *  NJE38 Sample: Show available files in NJE38 inbox
 *    pass command to NJE38CMD and retrieve output
 * -----------------------------------------------------------
 */
rc=nje38CMD('NJE38 D fILes')
if rc>0 then do
   say 'Unable to pickup NJE38 results'
   return 8
end
say copies('-',72)
say center('NJE38 Spool Queue',72)
say copies('-',72)
do i=1 to nje38.0
   say nje38.i
end
