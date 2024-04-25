         MACRO                                                          #TSOMSG
&NAME    #TSOMSG &MSG,&OFFSET=0,&LENGTH=                                #TSOMSG
         MNOTE *,'       #TSOMSG   VERSION 001 09/22/75  09/22/75  GPW' #TSOMSG
.********************************************************************** #TSOMSG
.*                                                                    * #TSOMSG
.* #TSOMSG                                                            * #TSOMSG
.*                                                                    * #TSOMSG
.* FUNCTION        GENERATE A MESSAGE LINE IN PUTLINE FORMAT WITH     * #TSOMSG
.*                 LENGTH AND OFFSET HEADERS.                         * #TSOMSG
.*                                                                    * #TSOMSG
.* DESCRIPTION     THE USER SPECIFIES A MESSAGE TEST ENCLOSED IN      * #TSOMSG
.*                 SINGLE QUOTES.  AN OFFSET MAY ALSO BE SPECIFIED.   * #TSOMSG
.*                 A MESSAGE IN PUTLINE FORMAT (WITH HALFWORD HEADERS * #TSOMSG
.*                 CONTAINING THE TOTAL LENGTH OF HEADERS AND         * #TSOMSG
.*                 MESSAGE AND OFFSET) IS CREATED.  THE LENGTH OF     * #TSOMSG
.*                 THE MESSAGE IS ROUNDED UP TO THE NEXT FULLWORD     * #TSOMSG
.*                 MULTIPLE.  THE USER MAY OPTIONALLY SPECIFY THE     * #TSOMSG
.*                 LENGTH OF THE MESSAGE TEXT.                        * #TSOMSG
.*                                                                    * #TSOMSG
.* SYNTAX          NAME     #TSOMSG 'MESSAGE-TEXT'                    * #TSOMSG
.*                                  OFFSET=N                          * #TSOMSG
.*                                  LENGTH=N                          * #TSOMSG
.*                                                                    * #TSOMSG
.*                 MESSAGE-TEXT IS THE MESSAGE TO BE GENERATED.       * #TSOMSG
.*                                                                    * #TSOMSG
.*                 OFFSET       SPECIFIES THE VALUE OF THE OFFSET     * #TSOMSG
.*                              HEADER HALFWORD.  DEFAULT IS 0.       * #TSOMSG
.*                                                                    * #TSOMSG
.*                 LENGTH       SPECIFIES THE LENGTH IN BYTES OF      * #TSOMSG
.*                              THE MESSAGE TEXT.  THIS LENGTH DOES   * #TSOMSG
.*                              NOT INCLUDE THE HEADER LENGTHS.  IF   * #TSOMSG
.*                              LENGTH IS NOT SPECIFIED, THE LENGTH   * #TSOMSG
.*                              WILL BE THE LENGTH OF THE MESSAGE     * #TSOMSG
.*                              TEXT ROUNDED TO THE NEXT FULLWORD.    * #TSOMSG
.*                                                                    * #TSOMSG
.* ERRORS          NO ERROR MESSAGES ARE DISPLAYED.                   * #TSOMSG
.*                                                                    * #TSOMSG
.* EXAMPLE         GENERATE A TSO MESSAGE.  LENGTH IS NOT SPECIFIED,  * #TSOMSG
.*                 AND OFFSET IS 0.                                   * #TSOMSG
.*                                                                    * #TSOMSG
.*                 ERROR1   #TSOMSG 'NAME NOT FOUND'                  * #TSOMSG
.*                                                                    * #TSOMSG
.*                 GENERATE A DUMMY MESSAGE.  THE MESSAGE TEXT WILL   * #TSOMSG
.*                 BE FILLED IN BY THE PROGRAM.  THE LENGTH OF THE    * #TSOMSG
.*                 MESSAGE MAY BE UP TO 120 CHARACTERS.               * #TSOMSG
.*                                                                    * #TSOMSG
.*                 OUTLINE  #TSOMSG ' ',LENGTH=120                    * #TSOMSG
.*                                                                    * #TSOMSG
.* GLOBAL SYMBOLS                                                     * #TSOMSG
.*                                                                    * #TSOMSG
.*                 NONE                                               * #TSOMSG
.*                                                                    * #TSOMSG
.* MACROS CALLED                                                      * #TSOMSG
.*                                                                    * #TSOMSG
.*                 NONE                                               * #TSOMSG
.*                                                                    * #TSOMSG
.********************************************************************** #TSOMSG
.*                                                                      #TSOMSG
         LCLA  &LEN,&LEN2                                               #TSOMSG
.*                                                                      #TSOMSG
         AIF   ('&LENGTH' EQ '').CALCLEN                                #TSOMSG
&LEN     SETA  &LENGTH                                                  #TSOMSG
         AGO   .GETLEN2                                                 #TSOMSG
.CALCLEN ANOP                                                           #TSOMSG
&LEN     SETA  K'&MSG-2                                                 #TSOMSG
&LEN     SETA  ((&LEN-1)/4+1)*4                                         #TSOMSG
.GETLEN2 ANOP                                                           #TSOMSG
&LEN2    SETA  &LEN+4                                                   #TSOMSG
&NAME    DC    H'&LEN2,&OFFSET',CL&LEN.&MSG                             #TSOMSG
         MEND                                                           #TSOMSG
