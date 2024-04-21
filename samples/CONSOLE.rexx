/* -----------------------------------------------------------
 *  RXCONSOL Sample: Show output of a Console command
 * -----------------------------------------------------------
 */
call rxconsol('D A,L')
say copies('-',72)
say center('Console Output of D A,L',72)
say copies('-',72)
do i=1 to console.0
   say console.i
end
