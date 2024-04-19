/* ---------------------------------------------------------------------
 *  Today's Date  Today(<output-format>) or for a date in the past
 *    TODAY(<output_date_format<,date<,input_date_format>>)
 * .............................. Created by PeterJ on 22. February 2019
 * ................................ Modified by PeterJ on 22. March 2020
 * ---------------------------------------------------------------------
 */
today: Procedure
return RXDATE(arg(1),arg(2),arg(3))
