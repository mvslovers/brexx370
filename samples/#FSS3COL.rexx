/* ---------------------------------------------------------------------
 * Generate an Input Screen for 9 input fields distributed to 3 columns
 *   by calling FMTCOLUMN the passed text/fields are
 *   separated as follows:
 *    1. input ==>_  2. input ==>_  3. input ==>_
 *    4. input ==>_  5. input ==>_  6. input ==>_
 *    7. input ==>_  8. input ==>_  9. input ==>_
 *
 *   Once user has entered input and pressed the enter key the
 *   input data are provided in the stem variable _screen.input.n
 *
 *   All Text and Field definitions and its Attributes are generated
 *
 * ---------------------------------------------------------------------
 */

 /*          + ------------------- screen with 3 columns
  *          !
  *          !    + -------------- Title line of screen
  *          !    !     */
frc=FMTCOLUM(3,'Three Columned Formatted Screen',
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
