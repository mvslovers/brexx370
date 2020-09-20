/* ---------------------------------------------------------------------
 * Generate an Input Screen for 9 input fields distributed to 4 columns
 *   by calling FMTCOLUMN the passed text/fields are
 *   separated as follows:
 *    1. input ==>_  2. input ==>_  3. input ==>_  4. input ==>_
 *    5. input ==>_  6. input ==>_  7. input ==>_  8. input ==>_
 *    9. input ==>_
 *
 *   Once user has entered input and pressed the enter key the
 *   input data are provided in the stem variable _screen.input.n
 *
 *   All Text and Field definitions and its Attributes are generated
 *
 *   In this extended version you can define a Call-Back entry to
 *   validate user's data and reject invalid or empty data
 * ---------------------------------------------------------------------
 */
_screen.preset='_'            /* Define the default field entries     */
_screen.CallBack='checkInput' /* set a Call-Back entry to check Input */
 /*          + ------------------- screen with 4 columns
  *          !
  *          !    + -------------- Title line of screen
  *          !    !     */
frc=FMTCOLUM(4,'Four Columned Formatted Screen',
     ,'1. Input ===>',
     ,'2. Input ===>',
     ,'3. Input ===>',
     ,'4. Input ===>',
     ,'5. Input ===>',
     ,'6. Input ===>',
     ,'7. Input ===>',
     ,'8. Input ===>',
     ,'9. Input ===>',
     )
 
do i=1 to _screen.input.0
   say "User's Input "i'. Input Field: '_screen.input.i
end
return
/* --------------------------------------------------------------------
 * Call Back Routine from FMTCOLUMN to check provided Input
 * --------------------------------------------------------------------
 */
checkInput:
 if strip(_screen.input.1,,'_')='' then do
    zerrsm = 'Field 1 ist mandatory'
    return 1
 end
 if strip(_screen.input.5,,'_')='' then do
    zerrsm = 'Field 5 ist mandatory'
    return 5
 end
 if strip(_screen.input.9,,'_')='' then do
    zerrsm = 'Field 9 ist mandatory'
    return 9
 end
return 0
