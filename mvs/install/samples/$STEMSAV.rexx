/* Create STEMs  */
do i=1 to 100
   def.i='def'i
   abc.i='abc'i
   xyz.i='xyz'i
end
/* ------------------------------------
 * Save STEMs, DSN must be re-allocated
 * ------------------------------------
 */
if stemput('herc01.temp','def.','abc.','xyz.')<0 then do
   say 'HERC01.TEMP not allocated, must be pre-defined'
   exit 8
end
say ExecTime' seconds Save Time '
drop def.
/* fetch STEMs   */
rc=stemget('herc01.temp')
say ExecTime' seconds Load Time '
do i=1 to 100
   say 'DEF.'i' is 'def.i
end
