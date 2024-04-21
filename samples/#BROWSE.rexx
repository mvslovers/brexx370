/* ---------------------------------------------------------------------
 * Display Allocted DSNs in a Formatted List Screen
 * ---------------------------------------------------------------------
 */
CALL LISTALC 'BUFFER'    /* write allocated DSNs into stem BUFFER.    */
call FMTLIST             /* Display stem BUFFER.                      */
