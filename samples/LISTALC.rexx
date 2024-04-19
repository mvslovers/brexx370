/* ---------------------------------------------------------------------
 * LISTALC  find allocated ddnames and datasets
 * numfiles=LISTALC(<PRINT/NOPRINT>)
 *   numfiles    files found
 *   PRINT       display found allocation, and return in stem variables
 *   NOPRINT     return results in stem variables
 *   PRINT       is default
 * Results are returned in:
 *  listalcDDN.n  contains the allocated dd name
 *  listalcDSN.n  contains the allocated dsname (incl. member, if any)
 *  listalcDDN.0  contain the number of entries
 *  listalcDSN.0  contain the number of entries
 *  listalcDSN.n and listalcddn.n correspond
 * ---------------------------------------------------------------------
 */
LISTA:
call listalc 'PRINT'  /* Fetch all current allocations */
/* the LISTALC function out of RXLIB is used */
