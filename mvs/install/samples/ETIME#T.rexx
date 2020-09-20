/* ---------------------------------------------------------------------
 * Example ETIME                                    PEJ 3. December 2018
 *   Etime() returns elapsed time since midnight in hundreds of a second
 * ---------------------------------------------------------------------
 */
RC=IMPORT(RXDATE)
SAY 'STARTED FROM BREXX.ISP.EXEC'
say 'Time Now     : 'time('L')
say 'Elapsed Time : 'etime()'  (since Midnight in hundreds of a second)'
