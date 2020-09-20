/* ---------------------------------------------------------------------
 * Return String in Lower Cases (only standard Alphabet)
 * .................................. Created by PeterJ on 9. March 2019
 * ---------------------------------------------------------------------
 */
lower:
return translate(arg(1),'abcdefghijklmnopqrstuvwxyz',
                       'ABCDEFGHIJKLMNOPQRSTUVWXYZ')
