**********************************************************************
*                                                                    *
*        IKJEGSIO IS A SET OF STRUCTURED MACROS THAT BUILD THE       *
*        ASSEMBLER INSTRUCTIONS TO PREPARE A PERSONALIZED PARM       *
*        LIST AND THE BRANCH TO IKJEGIO FOR I/O SERVICES.  THE       *
*        SET OF MACROS ARE INCLUDED; HOWEVER, THE MACRO SOURCE       *
*        IS SUPPRESSED.                                              *
*                                                                    *
*        STATUS -- VERSION NO. 01 - OS/VS2 RELEASE NO. 02            *
*        CHANGE LEVEL -- 01 - DATE 2-2-73                            *
*                                                                    *
**********************************************************************
         PRINT OFF
         MACRO
&LABEL   IKJEGSIO                                                      *
               &TYPEREQ,               TYPE SERVICE REQUESTED          *
               &FIRST=,                FIRST MESSAGE TO BE ISSUED      *
               &INST11=,               FIRST INSERT OF THE 1ST MSG     *
               &INST12=,               SECOND INSERT OF THE 1ST MSG    *
               &INST13=,               THIRD INSERT OF THE 1ST MSG     *
               &INST14=,               FOURTH INSERT OF THE 1ST MSG    *
               &INST15=,               FIFTH INSERT OF THE 1ST MSG     *
               &INST16=,               SIXTH INSERT OF THE 1ST MSG     *
               &SECOND=,               FIRST MESSAGE TO BE ISSUED      *
               &INST21=,               FIRST INSERT OF THE 2ND MSG     *
               &INST22=,               SECOND INSERT OF THE 2ND MSG    *
               &INST23=,               THIRD INSERT OF THE 2ND MSG     *
               &INST24=,               FOURTH INSERT OF THE 2ND MSG    *
               &INST25=,               FIFTH INSERT OF THE 2ND MSG     *
               &INST26=,               SIXTH INSERT OF THE 2ND MSG     *
               &ID=,                   MODULE CALLING ID NUMBER        *
               &MF=,                   TYPE MACRO TO EXPAND            *
               &DATAPTR=,              ADDRESS OF DATA LINE            *
               &DSNAME=,               ADDRESS OF OPEN DCB             *
               &SVC=,                  SVC NUMBER                      *
               &ABENDRG=,              REGISTER CONTAINING ABEND NUM   *
               &RC=,                   REGISTER CONTAINING ABEND CODE  *
               &VCONBR=            BRANCH TO VCON NOT TO TSTIO @ZA04126
.*********************************************************************
.**                                                                  *
.**                HEADER                                            */
.**DRIVER:
.**                E  MAIN DRIVER                                    */
.**                                                                  *
.*********************************************************************
         GBLB  &LISTSW                 SWITCH TO INDICATE LIST FORM
         GBLB  &STORESW                SW TO INDICATE PARM STRIPPING
         LCLC  &ADDRESS                VARIABLE TO CONTAIN THE STORE AD
         LCLC  &NUMID                  VARIABLE TO STRIP ID NUMBER
         LCLA  &IDCON                  VARIABLE TO CONTAIN THE ID NUM
         LCLA  &LENGTH                 VARIABLE TO COUNT CHARS IN PARM
&LISTSW  SETB  0                       INITIALIZE LIST SWITCH OFF
&STORESW SETB  0                       INITIALIZE STORE SWITCH OFF
&NUMID   SETC  '&ID'(4,2)              STRIP OFF THE LETTERS FROM ID NO
&IDCON   SETA  &NUMID                  TRANSFER VALUE FOR LATER USE
.*********************************************************************
.**                                                                  *
.**                D  (NO,,YES,%CONT1)
.**                   HAS THE 'MF' PARAMETER BEEN CODED PROPERLY ?   */
.**                                                                  *
.*********************************************************************
         AIF   ('&MF(1)' EQ '').ERRORMF
         AIF   ('&MF(1)' EQ 'E').MFE
         AIF   ('&MF(1)' EQ 'L').MFL
.*********************************************************************
.**                                                                  *
.**                P  ISSUE AN ERROR MESSAGE                         */
.**                P  (,END)
.**                   SET CONDITION CODE = 12                        */
.**                                                                  */
.**                                                                  *
.*********************************************************************
         MNOTE 12,'SYNTAX ERROR ENCOUNTERED IN MF= PARM'
         AGO   .NOLINK
.ERRORMF MNOTE 12,'MF= PARAMETER OMITTED, BUT IS REQUIRED'
         AGO   .NOLINK
.ERORMFE MNOTE 12,'THE ADDRESS PORTION IS REQUIRED WITH THE EXECUTABLE *
               FORM'
         AGO   .NOLINK
.ERORMFA MNOTE 4,'THE ADDRESS PORTION IS INVALID WITH THE LIST FORM AND*
                IS IGNORNED'
         AGO   .IDROUT
.*********************************************************************
.**                                                                  *
.**%CONT1:
.**                P  SET THE MF TYPE SWITCHES ON                    */
.**                                                                  *
.*********************************************************************
.MFE     AIF   ('&MF(2)' EQ '').ERORMFE GO TO ERROR EXIT WITH MSG
&ADDRESS SETC  '&MF(2)'                PREPARE TO PROCESS ADDRESS
         AIF   ('&ADDRESS'(1,1) EQ '(').MFADREG TEST FOR REG NOT.
&LABEL   LA    1,&ADDRESS              ESTABLISH ADDRESSABILITY TO PARM
         AGO   .IDROUT                 CONTINUE PROCESSING NEXT OPERAND
.MFADREG ANOP                          LABEL FOR REG NOTATION OF ADDR
&LABEL   LR    1,&ADDRESS              ESTABLISH ADDRESSABILITY TO PARM
         AGO   .IDROUT                 CONTINUE PROCESSING NEXT OPERAND
.MFL     ANOP                          ROUTINE BRANCHED TO IF LIST FORM
&LISTSW  SETB  1                       TURN ON THE LIST FORM SWITCH
         DS    0H                      ALIGN TO HALFWORD BOUNDRY
         B     *+88                    BRANCH AROUND PARM LIST
         AIF   ('&MF(2)' NE '').ERORMFA  TEST FOR ADDR WITH L FORM
.*********************************************************************
.**                                                                  *
.**                D  (NO,,YES,%CONT2)
.**                   IS THE USER'S ID NUMBER CODED CORRECTLY ?      */
.**                                                                  *
.*********************************************************************
.IDROUT  ANOP                          LABEL FOR 'ID=' OPERAND PROC
         AIF   ('&ID' EQ '').ERRORID   TEST FOR NULL PARM
&LENGTH  SETA  K'&ID                   COUNT LENGTH OF I.D. PARM
         AIF   (&LENGTH NE 5).ERRIDSZ  PUT OUT ERROR MESSAGE
         AIF   (&LISTSW EQ 1).IDLIST TEST IF THIS SHOULD BE DC OR MVI
         AGO   .IDE                    BRANCH TO MOVE ID INTO P.L. ROUT
.*********************************************************************
.**                                                                  *
.**                P  ISSUE A WARNING MESSAGE                        */
.**                P  (,%CONT3)
.**                   SET CONDITION CODE = 4 IF LIST FORM            */
.**                                                                  *
.*********************************************************************
.ERRIDSZ ANOP                          BRANCH HERE IF ID PARM HAS ERROR
         MNOTE 12,'THERE IS A SYNTAX ERROR IN THE ID= PARM'
         AGO   .NOLINK                 BRANCH TO RETURN TO THE USER
.ERRORID ANOP                          ROUTINE IF ID INCORRECT
         AIF   (&LISTSW EQ 1).ID4    IF THIS IS A LIST FORM SET CC=4
         MNOTE 4,'THE ID= PARM IS MISSING OR INCORRECT'
         AGO   .SELECT                 BRANCH TO CONTINUE PROCESSING
.ID4     MNOTE 0,'THE ID= PARM IS MISSING OR INCORRECT'
         AGO   .SELECT                 BRANCH TO CONTINUE PROCESSING
.*********************************************************************
.**                                                                  *
.**%CONT2:
.**                P  GENERATE THE INSTRUCTIONS NECESSARY TO
.**                   STORE THE USERS ID# IN THE P.L.                */
.**                                                                  *
.*********************************************************************
.IDE     ANOP                          ROUTINE TO MOVE ID # IN P.L.
         MVI   1(1),&IDCON             SET UP MOVE INSTRUCTION
         AGO   .SELECT                 CONTINUE PROCESSING
.IDLIST  ANOP                          ROUTINE TO CREATE 'DC'S FOR ID
&LABEL   DC    AL1(0)                  FILLER
         DC    AL1(&IDCON)             DC FOR CALLER'S ID # IN P.L.
.*********************************************************************
.**                                                                  *
.**%CONT3:
.**                D  (YES,,NO,%CONT4)
.**                   IS THIS REQUEST FOR DATA ?                     */
.**                                                                  *
.*********************************************************************
.SELECT  ANOP                          DETERMINE WHICH SERVICE REQ'D
         AIF   ('&TYPEREQ' NE 'DATA').SELECT2 TEST IF DATA REQUEST
.*********************************************************************
.**                                                                  *
.**                S  (,END)
.**                   CALL DATA: GENERATE INSTRUCIONS FOR DATA       */
.**                                                                  *
.*********************************************************************
         DATA  &DATAPTR,&DSNAME        CALL DATA REQ'T ROUTINE
         AGO   .END                    EXIT
.*********************************************************************
.**                                                                  *
.**%CONT4:
.**                D  (YES,,NO,%CONT5)
.**                   IS THIS REQUEST FOR AN SVC ERROR MESSAGE ?     */
.**                                                                  *
.*********************************************************************
.SELECT2 ANOP                          TEST FOR SVCERR REQUEST ROUT
         AIF   ('&TYPEREQ' NE 'SVCERR').SELECT3 CONTINUE IF NOT SVCERR
.*********************************************************************
.**                                                                  *
.**                S  (,END)
.**                   CALL SVCMSG: GENERATE INSTRUCTIONS FOR SVC MSG */
.**                                                                  *
.*********************************************************************
         SVCERR &SVC,&ABENDRG,&RC,&INST11 CALL SVCERR REQ'T ROUTINE
         AGO   .END                    EXIT
.*********************************************************************
.**                                                                  *
.**%CONT5:
.**                D  (YES,,NO,%CONT6)
.**                   IS THIS REQUEST FOR A MESSAGE ?                */
.**                                                                  *
.*********************************************************************
.SELECT3 ANOP                          TEST FOR MSG REQUEST ROUTINE
         AIF   ('&TYPEREQ' NE 'MSG').SELECT4 CONTINUE IF NOT MSG
.*********************************************************************
.**                                                                  *
.**                S  (,END)
.**                   CALL MSG: GENERATE INSTRUCTIONS FOR MSG        */
.**                                                                  *
.*********************************************************************
         MSG   &FIRST,&SECOND,&INST11,&INST12,&INST13,&INST14,&INST15, *
               &INST16,&INST21,&INST22,&INST23,&INST24,&INST25,&INST26
         AGO   .END                    EXIT
.*********************************************************************
.**                                                                  *
.**%CONT6:
.**                D  (YES,,NO,%CONT7)
.**                   IS THIS REQUEST FOR A PROMPTING MESSAGE ?      */
.**                                                                  *
.*********************************************************************
.SELECT4 ANOP                          TEST FOR PTGT REQUEST ROUTINE
         AIF   ('&TYPEREQ' NE 'PTGT').ERSLECT CONTINUE IF NOT MSG
.*********************************************************************
.**                                                                  *
.**                S  (,END)
.**                   CALL PTGT: GENERATE INSTRUCTIONS FOR PTGT MSG  */
.**                                                                  *
.*********************************************************************
         PTGT  &FIRST                  INVOKE THE INTERNAL SUBROUTINE
         AGO   .END                    EXIT
.*********************************************************************
.**                                                                  *
.**%CONT7:
.**                P  ISSUE AN ERROR MESSAGE                         */
.**                P  (,NOLINK)
.**                   SET CONDITION CODE TO 12                       */
.**                                                                  *
.*********************************************************************
.ERSLECT ANOP                          COME HERE IF SYNTAX IN &TYPEREQ
         MNOTE 12,'MISSING OR SYNTAX ERROR IN OPTION KEYWORD'
         AGO   .NOLINK                 BRANCH TO EXIT
.*********************************************************************
.**                                                                  *
.**END:
.**                D  (NO,,YES,NOLINK)
.**                   HAS THE LIST FORM BEEN REQUESTED ?             */
.**                                                                  *
.*********************************************************************
.END     ANOP                          ENDING ROUTINE FOR ENTIRE MACRO
         AIF   (&LISTSW EQ 1).NOLINK   BRANCH AROUND THE BRANCH & LINK
.*********************************************************************
.**                                                                  *
.**                P  GENERATE THE BRANCH & LINK INSTRUCTION TO I/O  */
.**                                                                  *
.*********************************************************************
         AIF   ('&VCONBR' NE 'YES').BALR
         L     15,@IOVCON               ADDR TO BR TO        @ZA04126
         BALR  14,15                    ENTER THE IO ROUTINE @ZA04126
         AGO      .NOLINK
.BALR    ANOP
         L     15,TSTIO                ESTABLISH THE ADDRESS TO IO
         BALR  14,15                   BRANCH TO I/O
.*********************************************************************
.**                                                                  *
.**NOLINK:
.**                R  RETURN CONTROL                                 */
.**                                                                  *
.*********************************************************************
.NOLINK  MEND                          RETURN CONTROL TO USER
         MACRO
         DATA  &DATAPTR,&DSNAME
.*********************************************************************
.**                                                                  *
.**DATA:
.**                E  DATA REQUEST ROUTINE                           */
.**                                                                  *
.*********************************************************************
         GBLB  &LISTSW
.*********************************************************************
.**                                                                  *
.**                P  SET UP INSTRUCTION NECESSARY TO STORE          */
.**                   DATA REQUEST # IN P.L.                         */
.**                                                                  *
.*********************************************************************
         AIF   (&LISTSW EQ 1).LISTTYP  FIND OUT WHICH FORM E OR L
         MVI   0(1),1                  STORE TYPE REQT IN P. L. (DATA)
         AGO   .NEXTSTP                BRANCH AND CONTINUE
.LISTTYP ANOP                          LABEL FOR DC TYPE INSTRUCTION
         DC    AL2(0)                  FILLER
.*********************************************************************
.**                                                                  *
.**                D  (YES,,NO,%CONT8)
.**                   IS THE 'DATAPTR' PARAMETER NULL                */
.**                                                                  *
.*********************************************************************
.NEXTSTP ANOP                          LABEL USED TO SKIP DC TYPE INST
         AIF   ('&DATAPTR' NE '').STOREDP  TEST FOR REQD PARM DATAPTR
.*********************************************************************
.**                                                                  *
.**                P  ISSUE WARNING MESSAGE                          */
.**                                                                  *
.*********************************************************************
         MNOTE 0,'THE DATAPTR KEYWORD IS REQUIRED, UNLESS A NULL LINE  *
               HAS BEEN REQUESTED'
.*********************************************************************
.**                                                                  *
.**%CONT8:
.**                S  CALL STORE: TO INSERT DATAPTR, DSNAME
.**                   AND FILLER INTO P.L.                           */
.**                                                                  *
.*********************************************************************
.STOREDP ANOP                          BRANCH HERE IF &DATAPTR CODED
         STORE 4,&DATAPTR,4            PREPARE INST TO INSERT INTO P.L.
         STORE 8,&DSNAME,4             PREPARE INST TO INSERT INTO P.L.
         STORE 12,,72                  IF LIST FORM PREPARE DC'S ZERO
.*********************************************************************
.**                                                                  *
.**%CONT9:
.**                R  RETURN TO THE DRIVER                           */
.**                                                                  *
.*********************************************************************
         MEND
         MACRO
         SVCERR &SVC,&ABENDRG,&RC,&INST11
.*********************************************************************
.**                                                                  *
.**SVC:
.**                E  SVC BUILD PARM ROUTINE                         */
.**                                                                  *
.*********************************************************************
         GBLB  &LISTSW                 SWITCH FOR LIST FORM OF MF
         GBLB  &STORE                  SW FOR STORE TO STRIP NUM DOWN
.*********************************************************************
.**                                                                  *
.**                P  SET UP INST NECESSARY TO STORE
.**                   SVC REQUEST # IN P.L.                          */
.**                                                                  *
.*********************************************************************
         AIF   (&LISTSW EQ 1).NEXTSTP  TEST FOR LIST FORM INST
         MVI   0(1),3                  STORE SVCERR REQUEST NUM IN P.L.
.*********************************************************************
.**                                                                  *
.**                D  (YES,,NO,%CONT10)
.**                   ARE THE PARAMETERS CODED CORRECTLY ?           */
.**                P  ISSUE WARNING MESSAGE IF INCORRECT             */
.**                                                                  *
.*********************************************************************
.NEXTSTP ANOP                          THIS PORTION CHECKS PARMS
         AIF   ('&ABENDRG' EQ '').CONT1  BRANCH TO CONTINUE IF NULL
         AIF   ('&ABENDRG'(1,1) EQ '(').CONT1  BRANCH TO CONTINUE IF OK
         MNOTE 12,'REGISTER NOTATION IS REQUIRED WITH THE ABENDRG PARM'
.CONT1   ANOP                          BRANCH HERE IF ABENDRG OK
         AIF   ('&RC' EQ '').CONT2     BRANCH TO CONTINUE IF NULL
         AIF   ('&RC'(1,1) EQ '(').CONT2  BRANCH TO CONTINUE IF OK
         MNOTE 12,'REGISTER NOTATION IS REQUIRED WITH THE RC PARM'
.CONT2   ANOP                          BRANCH HERE IF RC PARM OK
         AIF   ('&SVC' NE '').STORSVC  TEST FOR NULL PARM
         MNOTE 0,'THE SVC KEYWORD IS REQUIRED WITH THE SVCERR OPTION'
.*********************************************************************
.**                                                                  *
.**%CONT10:
.**                S  CALL STORE:  TO INSERT &ABENDRG, &SVC,
.**                   &RC AND FILLER INTO P.L.                       */
.**                                                                  *
.*********************************************************************
.STORSVC ANOP                          BRANCH HERE IF &SVC CODED
         STORE 2,,2                    PREPARE FILLER IF LIST FORM
         STORE 4,&ABENDRG,4            PREPARE INST TO INSERT INTO P.L.
         STORE 8,&RC,4                 PREPARE INST TO INSERT INTO P.L.
         STORE 12,,4                   PREPARE FILLER IF LIST FORM
         STORE 16,&SVC,4               PREPARE INST TO INSERT INTO P.L.
         STORE 20,,26                  PREPARE FILLER IF LIST FORM
.*********************************************************************
.**                                                                  *
.**                S  CALL INSTTYP: PROCESS TYPE INSERT              */
.**                                                                  *
.*********************************************************************
         TYPE 46,&INST11
.*********************************************************************
.**                                                                  *
.**                S  CALL STORE: PREPARE INST TO STORE
.**                   FILLER INTO P.L.                               */
.**                                                                  *
.*********************************************************************
         STORE 52,,8                   PREPARE FILLER IF LIST FORM
.*********************************************************************
.**                                                                  *
.**                S  CALL INSTWHR: PROCESS WHERE PORTION OF INSERT  */
.**                                                                  *
.*********************************************************************
         WHERE 60,&INST11
.*********************************************************************
.**                                                                  *
.**%CONT13:
.**                R  RETURN TO DRIVER                               */
.**                                                                  *
.*********************************************************************
         MEND                          END OF SVCERR ROUTINE
         MACRO
         MSG   &FIRST,&SECOND,&INST11,&INST12,&INST13,&INST14,&INST15, *
               &INST16,&INST21,&INST22,&INST23,&INST24,&INST25,&INST26
.*********************************************************************
.**                                                                  *
.**MSG:
.**                E  MSG ROUTINE                                    */
.**                                                                  *
.*********************************************************************
         GBLB  &LISTSW                 SWITCH IF LIST FORM USED
         GBLB  &STORESW                SW INDICATES TO STORE STRIP NUM
.*********************************************************************
.**                                                                  *
.**                P  SET UP INST NECESSARY TO
.**                   STORE MSG REQ # IN P.L.                        */
.**                                                                  *
.*********************************************************************
         AIF   (&LISTSW EQ 1).LISTTYP  TEST WHICH FORM MACRO L OR E
         MVI   0(1),2                  MOVE CODE FOR MSG INTO P.L.
.*********************************************************************
.**                                                                  *
.**                D  (YES,,NO,%CONT14)
.**                   IS THE 'FIRST' PARAMETER NULL ?                */
.**                                                                  *
.*********************************************************************
.LISTTYP ANOP                          LABEL USED BRANCH AROUND E INST
         AIF   ('&FIRST' NE '').NEXTSTP TEST IF USER CODED FIRST PARM
.*********************************************************************
.**                                                                  *
.**                P  ISSUE AN WARNING MSG                           */
.**                                                                  *
.*********************************************************************
         MNOTE 0,'THE FIRST PARM IS REQUIRED WITH THE MSG OPTION'
.*********************************************************************
.**                                                                  *
.**%CONT14:
.**                S  CALL INSTTYP: SET UP INST TO INSERT
.**                   TYPES INTO P. L.                               */
.**                                                                  *
.*********************************************************************
.NEXTSTP ANOP                          ROUTINE TO PLACE TYPES IN LIST
         INSTTYP 2,&INST11,&INST12,&INST13,&INST14,&INST15,&INST16
         STORE 8,,8                    PREPARE FILLER IF LIST FORM
.*********************************************************************
.**                                                                  *
.**%CONT17:
.**                S  CALL STORE: STORE &FIRST INTO PARM LIST        */
.**                                                                  *
.*********************************************************************
&STORESW SETB  1                       TURN ON STRIP SWITCH FOR STORE
         STORE 16,&FIRST,4             PREPARE INST TO STORE IN LIST
.*********************************************************************
.**                                                                  *
.**                S  CALL INSTWHR: PROCESS WHERE PORTION OF INSERTS */
.**                                                                  *
.*********************************************************************
         INSTWHR 20,&INST11,&INST12,&INST13,&INST14,&INST15,&INST16
         STORE 44,,2                   PREPARE FILLER IF LIST FORM
.*********************************************************************
.**                                                                  *
.**                S  CALL INSTTYP: PROCESS TYPE INSERT OF 2ND LEV   */
.**                                                                  *
.*********************************************************************
         INSTTYP 46,&INST21,&INST22,&INST23,&INST24,&INST25,&INST26
.*********************************************************************
.**                                                                  *
.**                S  CALL STORE: PREPARE INST TO STORE
.**                   &SECOND AND FILLER INTO P.L.                   */
.**                                                                  *
.*********************************************************************
         STORE 52,,4                   PREPARE FILLER IF LIST FORM
&STORESW SETB  1                       TURN ON STRIP SWITCH FOR STORE
         STORE 56,&SECOND,4            PREPARE INST TO STORE &SECOND
.*********************************************************************
.**                                                                  *
.**                S  CALL INSTWHR: PROCESS WHERE PORTION OF INSERTS */
.**                                                                  *
.*********************************************************************
         INSTWHR 60,&INST21,&INST22,&INST23,&INST24,&INST25,&INST26
.*********************************************************************
.**                                                                  *
.**%CONT18:
.**                R  RETURN TO DRIVER                               */
.**                                                                  *
.*********************************************************************
         MEND                          END OF MESSAGE PROCESSOR ROUTINE
         MACRO
         PTGT  &FIRST
.*********************************************************************
.**                                                                  *
.**                E  PTGT ROUTINE                                   */
.**                                                                  *
.*********************************************************************
         GBLB  &LISTSW                 SWITCH FOR LIST FORM
         GBLB  &STORESW                SWITCH FOR STORE TO STRIP NUM
.*********************************************************************
.**                                                                  *
.**                P  SET NECESSARY INST TO STORE
.**                   PTGT # INTO P.L.                               */
.**                                                                  *
.*********************************************************************
         AIF   (&LISTSW EQ 1).LISTTYP  TEST FOR LIST FORM
         MVI   0(1),4                  STORE CODE NUM FOR PTGT REQT
.*********************************************************************
.**                                                                  *
.**                D  (YES,,NO,%CONT19)
.**                   IS THE 'FIRST' PARAMETER NULL ?                */
.**                                                                  *
.*********************************************************************
.LISTTYP ANOP                          BRANCH TO IF LIST FORM
         AIF   ('&FIRST' NE '').STOR1ST TEST FOR NULL PARM
.*********************************************************************
.**                                                                  *
.**                P  ISSUE AN WARNING MESSAGE                       */
.**                                                                  *
.*********************************************************************
         MNOTE 0,'THE FIRST KEYWORD IS REQUIRED WITH THE PTGT OPTION'
.*********************************************************************
.**                                                                  *
.**%CONT19:
.**                S  CALL STORE: STORE PARMS AND FILLERS INTO P.L.  */
.**                                                                  *
.*********************************************************************
.STOR1ST ANOP                          ROUTINE TO PREPARE P.L.
         STORE 2,,14                   PREPARE FILLER IF LIST FORM
&STORESW SETB  1                       TURN ON STRIP SWITCH
         STORE 16,&FIRST,4             PREPARE INST TO STORE &FIRST
         STORE 20,,64                  PREPARE FILLER IF LIST FORM
.*********************************************************************
.**                                                                  *
.**%CONT20:
.**                R  RETURN TO DRIVER                               */
.**                                                                  *
.*********************************************************************
         MEND                          END OF PTGT PROCESSOR ROUTINE
         MACRO
         INSTTYP &START,&IN1,&IN2,&IN3,&IN4,&IN5,&IN6
.*********************************************************************
.**                                                                  *
.**INSTTYP:
.**                E  ROUTINE FOR INSERT TYPE PORTION                */
.**                                                                  *
.*********************************************************************
         LCLA  &DISP                   VARIABLE TO CONTAIN DISPLACEMENT
&DISP    SETA  &START                  INITIALIZE DISPLACEMENT COUNTER
.*********************************************************************
.**                                                                  *
.**                P  PREPARE EACH INSERT TO BE PROCESSED
.**                   BY TYPE PROCESSOR                              */
.**                                                                  *
.*********************************************************************
         TYPE  &DISP,&IN1              CALL TYPE ROUTINE TO STORE PARM
&DISP    SETA  &DISP+1                 INCREMENT DISPLACEMENT COUNTER
         TYPE  &DISP,&IN2              CALL TYPE ROUTINE TO STORE PARM
&DISP    SETA  &DISP+1                 INCREMENT DISPLACEMENT COUNTER
         TYPE  &DISP,&IN3              CALL TYPE ROUTINE TO STORE PARM
&DISP    SETA  &DISP+1                 INCREMENT DISPLACEMENT COUNTER
         TYPE  &DISP,&IN4              CALL TYPE ROUTINE TO STORE PARM
&DISP    SETA  &DISP+1                 INCREMENT DISPLACEMENT COUNTER
         TYPE  &DISP,&IN5              CALL TYPE ROUTINE TO STORE PARM
&DISP    SETA  &DISP+1                 INCREMENT DISPLACEMENT COUNTER
         TYPE  &DISP,&IN6              CALL TYPE ROUTINE TO STORE PARM
.*********************************************************************
.**                                                                  *
.**                R  RETURN TO CONTINUE PROCESSING                  */
.**                                                                  *
.*********************************************************************
         MEND                          END OR TYPE PROCESSOR OF INSERTS
         MACRO
         TYPE  &DISP,&IN               INTERNAL ROUTINE / TYPE PORTION
.*********************************************************************
.**                                                                  *
.**TYPE:           E  ROUTINE TO DETERMINE WHICH TYPE                */
.**                                                                  *
.*********************************************************************
         LCLA  &TYINST                 VARIABLE FOR CODE OF INSERT
.*********************************************************************
.**                                                                  *
.**                D  (NO,,YES,NULLTYP)
.**                   IS THIS INSERT NULL ?                          */
.**                                                                  *
.*********************************************************************
         AIF   ('&IN' EQ '').NULLTYP   BRANCH TO NULL PROCESSING
.*********************************************************************
.**                                                                  *
.**                P  DETERMINE WHICH TYPE REQ'T (PDE,NUM,ETC)       */
.**                                                                  *
.*********************************************************************
         AIF   ('&IN(1)' NE 'APDE').CONT1 TEST IF APDE TYPE INSERT
&TYINST  SETA  6                       SET CODE VARIABLE / INDICATE PDE
         AGO   .PROCESS                BRANCH TO STORE INTO LIST
.CONT1   ANOP                          BRANCHED TO IF NOT PDE
         AIF   ('&IN(1)' NE 'NUM').CONT2 TEST IF NUM TYPE INSERT
&TYINST  SETA  5                       SET CODE VARIABLE / INDICATE PDE
         AGO   .PROCESS                BRANCH TO STORE INTO LIST
.CONT2   ANOP                          BRANCHED TO IF NOT PDE
         AIF   ('&IN(1)' NE 'REG').CONT3 TEST IF REG TYPE INSERT
&TYINST  SETA  1                       SET CODE VARIABLE / INDICATE REG
         AIF   ('&IN(2)'(1,1) EQ '(').CONT21  TEST FOR REG NOTATION
         MNOTE 12,'WITH THE REG TYPE INSERT ONLY REG NOTATION ALLOWED'
.CONT21  ANOP                          BRANCH HERE IF SYNTAX OK
         AGO   .PROCESS                BRANCH TO STORE INTO LIST
.CONT3   ANOP                          BRANCH TO IF NOT REG TYPE
         AIF   ('&IN(1)' NE 'ADDR').CONT4 TEST IF ADDR TYPE INSERT
&TYINST  SETA  2                       SET CODE VAR / INDICATE ADDR
         AGO   .PROCESS                BRANCH TO STORE INTO LIST
.CONT4   ANOP                          BRANCH TO IF NOT ADDR TYPE
         AIF   ('&IN(1)' NE 'ADDRCONX').CONT5 TEST ADDRCONX TYPE INSERT
&TYINST  SETA  3                       SET CODE VAR / INDICATE ADDR
         AGO   .PROCESS                BRANCH TO STORE INTO LIST
.CONT5   ANOP                          BRANCH TO IF NOT ADDR TYPE
         AIF   ('&IN(1)' NE 'ADDRCOND').CONT6 TEST ADDRCOND TYPE INSERT
&TYINST  SETA  4                       SET CODE VAR / INDICATE ADDR
         AGO   .PROCESS                BRANCH TO STORE INTO LIST
.CONT6   ANOP                          BRANCH TO IF NOT ADDRCONX TYPE
         AIF   ('&IN(1)' NE 'VPDE').ERROR TEST VPDE TYPE INSERT
&TYINST  SETA  7                       SET CODE VAR / INDICATE ADDR
         AGO   .PROCESS                BRANCH TO STORE INTO LIST
.*********************************************************************
.**                                                                  *
.**                P  IF THERE IS A SYNTAX ERROR - ISSUE WARNING MSG */
.**                                                                  *
.*********************************************************************
.ERROR   ANOP                          COME HERE IF SYNTAX ERROR FOUND
         MNOTE 12,'THE TYPE PORTION OF AN INSERT HAS A SYNTAX ERROR'
&TYINST  SETA  0                       SET CODE TO NULL VALUE
.PROCESS ANOP                          THIS PORTION CALLS STORE
.*********************************************************************
.**                                                                  *
.**                S  (,ENDTYP)
.**                   CALL STORE: STORE CODE INTO P. L.              */
.**                                                                  *
.*********************************************************************
         STORE &DISP,&TYINST,1         CALL STORE TO PREPARE INST
         AGO   .ENDTYP                 BRANCH TO END TO RETURN
.*********************************************************************
.**                                                                  *
.**NULLTYP:
.**                S  CALL STORE: STORE FILLER ZEROS IF L FORM       */
.**                                                                  *
.*********************************************************************
.NULLTYP ANOP                          BRANCH HERE IF INSERT PARM NULL
         STORE &DISP,,1                CALL STORE FOR FILLER
.*********************************************************************
.**                                                                  *
.**ENDTYP:         R  RETURN TO INSTTYP                              */
.**                                                                  *
.*********************************************************************
.ENDTYP  ANOP                          BRANCH HERE TO EXIT ROUTINE
         MEND                          END OF TYPE ROUTINE
         MACRO
         INSTWHR &START,&IN1,&IN2,&IN3,&IN4,&IN5,&IN6
.*********************************************************************
.**                                                                  *
.**INSTWHR:
.**                E  ROUTINE FOR INSERT WHERE PORTION               */
.**                                                                  *
.*********************************************************************
         LCLA  &DISP                   VARIABLE TO CONTAIN DISPLACEMENT
&DISP    SETA  &START                  INITIALIZE DISPLACEMENT COUNTER
.*********************************************************************
.**                                                                  *
.**                P  PREPARE EACH INSERT TO BE PROCESSED
.**                   BY WHERE PROCESSOR                             */
.**                                                                  *
.*********************************************************************
         WHERE &DISP,&IN1              CALL TYPE ROUTINE TO STORE PARM
&DISP    SETA  &DISP+4                 INCREMENT DISPLACEMENT COUNTER
         WHERE &DISP,&IN2              CALL TYPE ROUTINE TO STORE PARM
&DISP    SETA  &DISP+4                 INCREMENT DISPLACEMENT COUNTER
         WHERE &DISP,&IN3              CALL TYPE ROUTINE TO STORE PARM
&DISP    SETA  &DISP+4                 INCREMENT DISPLACEMENT COUNTER
         WHERE &DISP,&IN4              CALL TYPE ROUTINE TO STORE PARM
&DISP    SETA  &DISP+4                 INCREMENT DISPLACEMENT COUNTER
         WHERE &DISP,&IN5              CALL TYPE ROUTINE TO STORE PARM
&DISP    SETA  &DISP+4                 INCREMENT DISPLACEMENT COUNTER
         WHERE &DISP,&IN6              CALL TYPE ROUTINE TO STORE PARM
.*********************************************************************
.**                                                                  *
.**                R  RETURN TO CONTINUE PROCESSING                  */
.**                                                                  *
.*********************************************************************
         MEND
         MACRO
         WHERE &DISP,&IN
.*********************************************************************
.**                                                                  *
.**WHERE:          E  ROUTINE PROCESS WHERE PORTION OF ONE INSERT    */
.**                                                                  *
.*********************************************************************
         GBLB  &STORESW                SWITCH - INDICATE STRIP NUM
         LCLC  &WHERE                  LABEL USED TO OBTAIN WHERE PARM
&WHERE   SETC  '&IN(2)'                STRIP OFF WHERE PORTION OF INST
.*********************************************************************
.**                                                                  *
.**                D  (NO,,YES,NULLWHR)
.**                   IS THIS INSERT NULL ?                          */
.**                                                                  *
.*********************************************************************
         AIF   ('&IN' EQ '').NULLWHR   BRANCH TO NULL PROCESSING
.*********************************************************************
.**                                                                  *
.**                P  ISSUE A WARNING MSG IF WHERE PORTION IS NULL   */
.**                                                                  *
.*********************************************************************
         AIF   ('&WHERE' NE '').CONT   TEST FOR NULL PORTION
         MNOTE 12,'AN INSERT WHERE PORTION IS MISSING OR MISSPELLED'
.*********************************************************************
.**                                                                  *
.**                P  TURN ON THE STRIP SW IF 'NUM' IS THE TYPE      */
.**                                                                  *
.*********************************************************************
.CONT    ANOP                          THIS PORTION PREPARE TO STORE
&STORESW SETB  ('&IN(1)' EQ 'NUM')     TURN ON STRIP SWITCH IF I/O NUM
.*********************************************************************
.**                                                                  *
.**                S  (,ENDWHR)
.**                   CALL STORE: HAVE WHERE PORTION PLACED IN P.L.  */
.**                                                                  *
.*********************************************************************
         STORE &DISP,&WHERE,4          CALL STORE - STORE WHERE PORTION
         AGO   .ENDWHR                 BRANCH TO END FOR RETURN
.*********************************************************************
.**                                                                  *
.**NULLWHR:
.**                S  CALL STORE: STORE FILLER ZEROS IF L FORM       */
.**                                                                  *
.*********************************************************************
.NULLWHR ANOP                          BRANCH HERE IF INSERT PARM NULL
         STORE &DISP,,4                CALL STORE FOR FILLER
.*********************************************************************
.**                                                                  *
.**ENDWHR:         R  RETURN TO PROCESSING                           */
.**                                                                  *
.*********************************************************************
.ENDWHR  ANOP                          BRANCH HERE TO EXIT
         MEND                          END OF INSTWHR ROUTINE
         MACRO
         STORE &DISP,&PARM,&LEN        ROUT. TO PREPARE INST FOR LIST
.*********************************************************************
.**                                                                  *
.**STORE:
.**                E  STORE DATA IN PARM LIST                        */
.**                                                                  *
.*********************************************************************
         GBLB  &STORESW                SW TO INDICATE STRIPPING
         GBLB  &LISTSW                 SW TO INDICATE USER USED L FORM
         LCLC  &PARMC                  VARIABLE TO STRIP PARM DOWN
         LCLA  &PARMN                  VARIABLE TO CHANGE ATTRIBUTES
         LCLA  &LENGTH                 VARIABLE TO COUNT CHARS IN PARM
.*********************************************************************
.**                                                                  *
.**                D  (NO,,YES,START)
.**                   IS THIS A LIST FORM ?                          */
.**                                                                  *
.*********************************************************************
         AIF   (&LISTSW EQ 1).START    AVOID NEXT TEST IF LIST FORM
.*********************************************************************
.**                                                                  *
.**                D  (NO,,YES,RETURN)
.**                   IS THIS A NULL PARM ?                          */
.**                                                                  *
.*********************************************************************
         AIF   ('&PARM' EQ '').RETURN  TEST FOR NULL PARM (ONLY E FORM)
.*********************************************************************
.**                                                                  *
.**START:          D  (YES,,NO,PROCESS)
.**                   IS STRIP SWITCH ON ?                           */
.**                                                                  *
.*********************************************************************
.START   ANOP                          BRANCH HERE IF LIST FORM
         AIF   (&STORESW NE 1).PROCESS SEE IF THERE IS NO NEED TO STRIP
         AIF   ('&PARM' EQ '').PROCESS IF NULL DO NOT PREPARE TO STRIP
.*********************************************************************
.**                                                                  *
.**                D  (NO,,YES,PROCESS)
.**                   TEST FOR REGISTER NOTATION                     */
.**                                                                  *
.*********************************************************************
         AIF   ('&PARM'(1,1) EQ '(').PROCESS TEST FOR REGISTER NOTATION
.*********************************************************************
.**                                                                  *
.**                P  ISSUE A WARNING MESSAGE IF
.**                   ERROR FOUND IN NUMBER TO BE STRIPPED           */
.**                                                                  *
.*********************************************************************
&LENGTH  SETA  K'&PARM                 COUNT PARM LENGTH FOR POSS ERROR
         AIF   (&LENGTH EQ 5).OK       TEST FOR SYNTAX ERROR BY USER
         MNOTE 12,'A SYNTAX ERROR FOUND IN A MESSAGE OR INSERT NUMBER'
.*********************************************************************
.**                                                                  *
.**OK:             P  STRIP OFF NUMBER PORTION OF PARM               */
.**                                                                  *
.*********************************************************************
.OK      ANOP                          BRANCH HERE IF NUM SEEMS CORRECT
&PARMC   SETC  '&PARM'(3,3)            STRIP OF NUM PORTION
&PARMN   SETA  &PARMC                  CHANGE ATTRIBUTE / CHAR TO ARTH
.*********************************************************************
.**                                                                  *
.**                D  (YES,,NO,BLDINST)
.**                   IS THIS THE LIST FORM WHICH REQS DC'S          */
.**                                                                  *
.*********************************************************************
         AIF   (&LISTSW NE 1).BLDINST  SEE IF PL IN DYNAMIC STORAGE
.*********************************************************************
.**                                                                  *
.**                P  (,RETURN)
.**                   BUILD DC FOR LIST FORM P.L.                    */
.**                                                                  *
.*********************************************************************
         DC    AL&LEN.(&PARMN)         PLACEMENT OF PARAMETER INTO LIST
         AGO   .RETURN                 BRANCH TO EXIT
.*********************************************************************
.**                                                                  *
.**BLDINST:        P  (,RETURN)
.**                   BUILD THE INSTURCTION NECESSARY TO STORE
.**                   INTO A DYNAMIC AREA                            */
.**                                                                  *
.*********************************************************************
.BLDINST ANOP                          BRANCH HERE FOR EXECUTABLE FORM
         AIF   (&LEN EQ 1).BLDMVI1     SEE IF ONE BYTE TYPE INST NEEDED
         LA    14,&PARMN               GET PARAMETER INTO WORK REGISTER
         ST    14,&DISP.(1)            STORE PARAMETER INTO PARM LIST
         AGO   .RETURN                 BRANCH TO EXIT
.BLDMVI1 ANOP                          BRANCH HERE IF ONE BYTE LENGTH
         MVI   &DISP.(1),&PARMN        MOVE PARM INTO PARAMETER LIST
         AGO   .RETURN                 BRANCH TO EXIT
.*********************************************************************
.**                                                                  *
.**PROCESS:        P  PREPARE DC OR INSTRUCTIONS TO BUILD P.L.       */
.**                                                                  *
.*********************************************************************
.PROCESS ANOP                          BRANCH HERE / STANDARD STORE REQ
         AIF   (&LISTSW NE 1).INSTBLD  TEST FOR EXECUTABLE FORM REQT
         AIF   ('&PARM' NE '').DCPARM  TEST FOR FILLER REQUEST
         DC    &LEN.AL1(0)             FILLER OF HEX ZEROS
         AGO   .RETURN                 BRANCH TO EXIT
.DCPARM  ANOP                          BRANCH HERE FOR PREPARATION DC'S
         AIF   ('&PARM'(1,1) NE '(').CONTDC ENSURE USER HAS NOT USED RG
         MNOTE 12,'REGISTER NOTATION IS NOT PERMITTED WITH THE LIST FOR*
               M (MF=L)'
.CONTDC  DC    AL&LEN.(&PARM)          PLACEMENT OF PARAMETER INTO LIST
         AGO   .RETURN                 BRANCH TO EXIT
.INSTBLD ANOP                          BRANCH HERE FOR DYNAMIC LIST
         AIF   (&LEN NE 1).CONTI2      TEST FOR ONE BYTE TYPE INST
         AIF   ('&PARM'(1,1) NE '(').CONTI1 TEST FOR REG NOTATION
         STC   &PARM,&LEN.(1)          STORE PARM INTO LIST
         AGO   .RETURN                 BRANCH TO EXIT
.CONTI1  ANOP                          BRANCH HERE FOR MVI TYPE INST
         MVI   &DISP.(1),&PARM         MOVE VALUE INTO LIST
         AGO   .RETURN                 BRANCH TO EXIT
.CONTI2  ANOP                          BRANCH HERE IF NOT ONE BYTE
         AIF   ('&PARM'(1,1) EQ '(').REGPARM  IF REG USE STORE INST
         LA    14,&PARM                GET PARM INTO WORK REGISTER
         ST    14,&DISP.(1)            STORE PARM INTO PARAMETER LIST
         AGO   .RETURN                 BRANCH TO EXIT
.REGPARM ANOP                          BRANCH HERE IF REG NOTATION
         ST    &PARM,&DISP.(1)         STORE PARM INTO PARAMETER LIST
.*********************************************************************
.**                                                                  *
.**RETURN:         R  RETURN TO CALLER AND CONTINUE PROCESSING       */
.**                                                                  *
.*********************************************************************
.RETURN  ANOP                          EXIT ROUTINE FOR STORE
&STORESW SETB  0                       TURN OFF STRIP SW FOR NEXT PARM
         MEND                          END OF STORE ROUTINE
         PRINT ON
