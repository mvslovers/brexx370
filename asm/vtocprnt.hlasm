         TITLE 'VTOC COMMAND PRINT ROUTINE'
***********************************************************************
*         MODIFICATIONS
* NUMBER    DATE    PERSON    REASON
*  001G    072278   GATES     CHANGE MSG AND CLEAR MACROS TO VTCMSG AND
*                              VTCLEAR RESPECTIVELY TO AVOID CONFLICT
*                              WITH EXISTING MSG AND CLEAR MACROS.
*  002S    101878   SAVIT     CORRECTLY FORMAT LAST USE DATE AS SET
*                              BY MVS RELEASE 3.7/IPO 3.0/SU60.
*  003G    030179   GATES     ADD CHECK FOR CAT PARAMETER SO WE CAN
*                              SEE IF DATASETS ARE CATALOGED.
*  004G    030379   GATES     ADD LOGIC TO PRODUCE A JCL FILE TO CAUSE
*                              DELETION (AND UNCATALOGING, IF CAT
*                              SPECIFIED ON COMMAND) OF DATASETS ON
*                              PUBLIC AND STORAGE MOUNTED VOLUMES.
*                              IF DATASET IS CATALOGED AS BEING ON VOL
*                              WHERE IT WAS FOUND THE UNIT AND VOLSER
*                              WILL BE LEFT OFF THE JCL SO THAT IT WILL
*                              BE UNCATALOGED. OTHERWISE JCL WILL REFER
*                              TO SPECIFIC VOLUME SERIAL.
*  005G    030379   GATES     ADD REG 10 AS AN ADDITIONAL BASE.
*  006G    030478   GATES     ADD COMMENTS IN GENERATED JCL TO SHOW
*                              CATALOG BEING USED WHEN POSSIBLE. ALSO
*                              ALLOW ONLY JCL FOR NOT-CATALOGED DATA ON
*                              DISK PACKS BEGINNING WITH 'HSP0' TO
*                              AVOID MASSIVE DELETIONS OF PRODUCTION
*                              DATA. ALSO DON'T DELETE DATASET WITH
*                              SAME NAME AS PACK ON WHICH IT WAS FOUND.
*                              ALSO PUT SEQ # IN DD NAME.
*  007G    030679   GATES     CORRECT BUG IN VTOCOUT LISTING CREATED BY
*                              004G MOD CHANGING EXECUTED INSTRUCTION.
*  008G    031679   GATES     ALLOW WRONGLY CATALOGED DATASETS ON PACKS
*                              BEGINNING "HSP0" TO GENERATE JCL.
*  009G    NEEDED   GATES     ALLOW VOLSER AS ALIAS FOR VOLUME.
*  010G    120880   GATES     MAKE VSAM AND ISAM SHOW WHOLE DS USED.
*  011G    120880   GATES     PUT IN PRIVATE KEYWORD CHECK TO ALLOW
*                              GENERATION OF PURGE JCL FOR HSP0 PACKS
*  012G    110183   GATES     USE SAME RTN TO PRINT CDATE EXPDT LSTUS.
*  013G    110283   GATES     CLEAR OUT TOTALS IN PRNTOT RTN.
*  014G    111183   GATES     PUT IN LOGIC TO MAP VOLUMES.
*  015G    111783   GATES     CHANGE LOGIC TO ALWAYS GO THRU MAP
*                              RTNS AND CHECK FOR GAPS/OVERLAPS.
*                              THE MAP IS SHOWN ONLY WHEN USER SAYS
*                              MAP ON THE VTOC COMMAND.
*  016G    112283   GATES     FIX MESSAGES TO HARDCOPY.
*  017G    112383   GATES     UPDATE JCLOUT MESSAGES FOR PURGE.
*  018G    112383   GATES     DISPLAY VTOC SPACE INFO. ALSO CHECK DIRF
*                              BIT AND REPORT.
*  019G    043084   GATES     DONT SHOW ANY HEADINGS WHEN NOHEAD.
*  020G    043084   GATES     OPEN VTOCOUT EVEN WHEN NOPRINT SO WE
*                              GET TOTALS AND MAP TO VTOCOUT.
*  021G    043084   GATES     FIX BUG WHERE CAT KEYWORD ONLY WORKED
*                              UNDER TEST COMMAND.
*  022G    050284   GATES     EMBED VTCLEAR MACRO TO MAKE VTOC MORE
*                              TRANSPORTABLE.
*  023G    050284   GATES     RENAME VTFMT MACRO TO VTCFMT,
*                              RENAME VTLEAVE MACRO TO VTCLEAVE,
*                              RENAME VTOCOM MACRO TO VTCCOM,
*                              RENAME VTOCPARS MACRO TO VTCPARS,
*                              RENAME PDEDSNAM MACRO TO VTCPDEDS,
*                               RENAME ENTER TO VTCENTER,
*                              VTOC MORE TRANSPORTABLE.
*  024G    051084   GATES     FIX LOGIC TO PRINT UNIT NAME.
*  025G    051084   GATES     ADD LOGIC TO PRINT WHETHER A DSN HAS
*                              LAST BEEN OPENED FOR UPDATE.
*  026G    051684   GATES     FIX LOGIC TO USE SEPARATE RTNS TO PRINT
*                              DSN AND CCHH. CCHH IS NEVER PRINTED WE
*                              ISSUE A WARNING MESSAGE TO SAY USE THE
*                              MAP KEYWORD.
*  027G    110584   GATES     CHANGE INDEX VTOC MESSAGE TO INDICATE
*                              FREE SPACE NOT SHOWN.
*  028G    110584   GATES     FIX BUG WHERE TRACK LENGTH FOR 3380
*                              WAS INCORRECT, WENT NEGATIVE.
*  029G    110584   GATES     PUT VOLSER IN DIRF MESSAGE.
*  030G    111485   GATES     MAKE EXT FIELD 3 BYTES.
*  031G    111585   GATES     PUT RUN DATE IN HEADING LINE.
*  032G    103087   GATES     CHANGE MESSAGE PHONE NUMBER.
*  033G    123187   GATES     UPDATE JCLOUT JOB CARD FOR PURGE.
*  034G    010488   GATES     REMOVE LOGIC FOR HSP0 PACKS, AFFECTS
*                              006G 008G, AND 011G MODIFICATIONS.
*  035G    010488   GATES     ADD LOGIC FOR KEY LENGTH.
*  036G    041388   GATES     REMOVE LOGIC FOR PURGE JCL OPTION. THIS
*                              CAN BE ACCOMPLISHED BY DIRECTING THE
*                              OUTPUT TO VTOCOUT AND MANIPULATING IT
*                              TO PRODUCE THE RESULT YOU WANT. AFFECTS
*                              004G, 006G 008G, 011G AND 017G MODS.
*  037G    041888   GATES     CORRECT RUN DATE LOGIC.
*  038G    041690   GATES     CHANGE CONTACT PHONE NUMBER.
*  039G    051590   GATES     FIX BUG WHERE NUMBER TRACKS FOR 3380
*                              WAS INCORRECT, WENT NEGATIVE.
*  040G    072790   GATES     ADD LOGIC FOR OPTCD VALUE.
*  DHC2    091102   CARTWRIGHT ALLOW Y2K YEARS
*
*
* TITLE -      VTOC COMMAND PRINT ROUTINE                             *
*                                                                     *
* FUNCTION -   PRINT THE DATA PASSED TO IT.  IT WILL USE THE DDNAME   *
*              VTOCOUT IF IT IS ALLOCATED, AND WILL USE VTOCMSG       *
*                                                                     *
* OPERATION -  FOR UNSORTED DATA, GET THE CURRENT ENTRY, ADD TO THE   *
*              TOTALS, AND OUTPUT IT.  IF THE DATA IS SORTED, THE     *
*              ACTION IS MORE COMPLEX, BECAUSE ALL THE DATA SETS      *
*              ARE TO BE OUTPUT.  THE TOTALS AND BREAKS MAY BE        *
*              NEEDED AT ANY POINT.                                   *
*                                                                     *
* INPUT -      VTOC COMMON AREA ( VTOCOM )                            *
*              POINTED TO BY REGISTER 1                               *
*              USE PARSE DATA, CURRENT FORMATTED DSCB, SORTED LIST    *
*                                                                     *
* OUTPUT -     TO VTOCOUT, A LIST OF THE REQUESTED DATA SETS AND      *
*              THEIR ATTRIBUTES, WITH TOTALS AND BREAKS AS NEEDED.    *
*              IF VTOCOUT IS NOT ALLOCATED, VTOCMSG IS USED FOR       *
*              OUTPUT.                                                *
*                                                                     *
* ATTRIBUTES - REENTRANT, REUSEABLE, REFRESHABLE.                     *
*                                                                     *
*                                                                     *
*         PROGRAMMED BY R. L. MILLER  (415) 485-6241                  *
*                                                                     *
*                                                                     *
***********************************************************************
*
         MACRO
&NAME    VTCEDIT &NAME1,&REG,&EDIT
&NAME    CVD   &REG,DOUBLE                  MOVE VALUE TO PRINT    014G
         MVC   &NAME1.(L'&EDIT.),&EDIT       AND                   014G
         ED    &NAME1.(L'&EDIT.),DOUBLE+5    ZERO SUPPRESS.        014G
         MEND
         MACRO
&NAME  VTCLEAR &FIELD,&CHAR,&LENGTH                               001S
.*     MODIFICATIONS
.*   IDENTIFIER   DATE   PERSON   REASON
.*      001S     101678  SAVIT    MAKE MACRO NAME UNIQUE BY ADDING VT.
.*      002G     050284  GATES    EMBEDDED MACRO WITHIN VTOCPRNT WHICH
.*                                 IS THE ONLY PLACE IT'S USED.
.*
         LCLC  &FILL,&L
&L       SETC  'L'''
&FILL    SETC  '&CHAR'
         AIF   ('&CHAR' NE '').CHSPEC
&FILL    SETC  '40'
.CHSPEC  ANOP
&NAME    MVI   &FIELD,X'&FILL'   SET THE FIRST POSITION
         AIF   ('&LENGTH' EQ '').NOLSPEC
         MVC   &FIELD+1(&LENGTH),&FIELD  FILL THE ENTIRE FIELD
         MEXIT
.NOLSPEC ANOP
         MVC   &FIELD+1(&L&FIELD-1),&FIELD  FILL THE ENTIRE FIELD
         MEND
         MACRO
&LABEL   CONV  &TO,&FROM,&LEN,&EDMASK,&SCOMP
         LCLC  &L,&FIRSTFR,&EDM,&COMP
         LCLA  &COUNT
&L       SETC  'L'''
         AIF   ('&LABEL' EQ '').NOLABEL  SKIP LABEL IF NOT PRESENT
&LABEL   DS    0H             SET THE LABEL
.NOLABEL ANOP
&EDM     SETC  'EDMASK'      DEFAULT EDIT MASK
         AIF   ('&EDMASK' EQ '').DEFMASK  IF NOT ENTERED USE DEFAULT
&EDM     SETC  '&EDMASK'     USE THE ENTERED VALUE
.DEFMASK ANOP
&COMP    SETC  'BLANKS'      DEFAULT COMPARISON CHARS
         AIF   ('&SCOMP' EQ '').DEFCOMP  NOT ENTERED, USE THE DEFAULT
&COMP    SETC  '&SCOMP'      GET WHAT THE GUY WANTS
.DEFCOMP ANOP
&FIRSTFR SETC  '&FROM'(1,1)   GET FIRST CHAR OF &FROM
         AIF   ('&FIRSTFR' EQ '(').REGISTR
         L     R1,&FROM       GET THE DATA TO CONVERT
         CVD   R1,DOUBLE      CONVERT TO PACKED DECIMAL
         AGO   .INDEC
.REGISTR ANOP
&COUNT   SETA  K'&FROM-2
&FIRSTFR SETC  '&FROM'(2,&COUNT)  STRIP THE PERRONS
         CVD   &FIRSTFR,DOUBLE   CONVERT TO PACKED DECIMAL
.INDEC   ANOP
         MVC   CHARS,&EDM     PUT IN THE EDIT MASK
         ED    CHARS,DOUBLE   CONVERT TO CHARACTERS
         AIF   ('&LEN' NE '').LENSET
         MVC   &TO,CHARS+16-&L&TO  MOVE IN THE NUMBER
         CLC   CHARS(16-&L&TO),&COMP   WAS THERE AN OVERFLOW?
         BE    *+10           NO, EVERYTHING WAS OK
         MVC   &TO,STARS      BAD NEWS, NOTE IT
         MEXIT
.LENSET  ANOP
         MVC   &TO.(&LEN),CHARS+16-&LEN MOVE IN THE NUMBER
         CLC   CHARS(16-&LEN),&COMP   WAS THERE AN OVERFLOW?
         BE    *+10           NO, EVERYTHING WAS OK
         MVC   &TO.(&LEN),STARS   BAD NEWS, NOTE IT
         MEND
*        MACRO FOR DEFINING FAKE PDE FOR A DEFAULT LIST
*
         EJECT
VTOCPRNT VTCENTER (12,10),20       DO THE HOUSEKEEPING         005G023G
         LR    R11,R1         SAVE ADDR OF VTOCOM
         USING VTOCOM,R11     SET ITS ADDRESSABILITY
         L     R9,ADDRANSR    POINT TO THE PARSE ANSWER
         USING PDL,R9         SET ITS ADDRESSABILITY
         USING PRNTWORK,R13   SET ADDRESSABILITY FOR LOCAL WORK AREA
         SPACE 3
*
*        CHECK FOR THE MAP PRINT REQUEST
*
         TM    VTCPFUNC,X'01' IS IT TIME                       015G018G
         BO    MAPVTOC        YES, GO DO IT                        015G
*
*        CHECK FOR THE PRINT CLEAN - CLOSE AND FREEMAIN
*
         TM    VTCPFUNC,X'08' IS IT TIME                       014G018G
         BO    PRNTCLEN       YES, GO DO IT                        014G
*
*        CHECK FOR THE FIRST TIME THROUGH
*        IF SO, SET UP THE DCB'S AND OPEN THEM
*
         CLI   FIRSTIM,0      IS THIS THE FIRST TIME?
         BNE   CHKSORT        NO, KEEP ON TRUCKIN'
         B     PRTINIT    INITIALIZE FOR PRINTING
*
*        CHECK TO SEE IF THE DATA IS SORTED
*
CHKSORT  CLI   SORTK+1,2      IS THIS NOSORT?
         BNE   SORTED         NO, THE ENTRIES ARE SORTED
*
*        NOSORT WAS SPECIFIED.  ONLY THE CURRENT ENTRY IS AVAILABLE
*
         L     R3,FORMATAD    POINT TO THE ENTRY
         USING VTFMT,R3       FORMATTED DSCB ADDRESSABILITY
         LTR   R3,R3          IS IT THERE?
         BZ    CHEKTOT        NO, SEE IF A TOTAL HAS BEEN OUTPUT
         XC    FORMATAD,FORMATAD  CLEAR THE ADDRESS FOR LATER
*
*        ADD TO THE TOTALS
*
         BAL   R8,ADDTOT      GO DO IT
*                                                                  036G
*        SEE IF THE JCL OUTPUT DATA SET IS WANTED              004G036G
*                                                                  036G
*        TM    JCLDCB+48,X'10'  IS THE DCB OPEN?               004G036G
*        BNO   NOOUTPT        NO, SKIP ALONG                       036G
*        BAL   R8,OUTPUT      YES, GO DO IT                        036G
*
*        SEE IF THERE'S PRINTING TO DO
*
NOOUTPT  CLI   PRINTK+1,2     WAS NOPRINT SPECIFIED?
         BE    VTRET          YES, WE'RE DONE FOR NOW
         BAL   R8,PRINT       NO, PRINT OUT THE ENTRY
*
*        RETURN FROM WHENCE WE CAME
*
VTRET    VTCLEAVE EQ,RC=0      EXEUNT                              023G
*
*        NOSORT, CHECK FOR OUTPUTTING THE TOTALS
*
CHEKTOT  TM    ENDTOTAL,ENTOTOUT  WAS THE TOTAL OUTPUT BEFORE?
         BO    VTRET          YES, JUST RETURN
         BAL   R8,PRNTOT      NO, OUTPUT THE TOTAL
         OI    ENDTOTAL,ENTOTOUT  REMEMBER THE TOTAL IS OUT
         B     VTRET          THEN RETURN
         EJECT
*
*        THE DATA IS SORTED, SO THE LISTS MUST BE EMPTIED.
*        CHECK EACH ITEM FOR A TOTAL AND FOR A BREAK
*        OUTPUT TO PRINT AND/OR THE OUTPUT DATA SET
*
*
*        FIRST GET THE TOTAL AND BREAK COUNTS FOR COMPARES
*
SORTED   LA    R1,TOTALN      POINT TO THE TOTAL PDL
         BAL   R8,PDLNUM      CONVERT IT TO A NUMBER
         LTR   R15,R15        IS IT ZERO?
         BNZ   SETTNUM        NO, IT'S GOOD
         OI    ENDTOTAL,ENDTONLY  YES, TOTALS AT THE END ONLY
SETTNUM  BCTR  R15,0          CUT IT DOWN ONE
         STH   R15,NUMTOTAL   SET THE TOTAL COUNT
         LA    R1,BREAK       POINT TO THE BREAK PDL
         BAL   R8,PDLNUM      CONVERT IT TO A NUMBER
         LTR   R15,R15        IS IT ZERO?
         BNZ   SETBNUM        NO, IT'S GOOD
         OI    ENDTOTAL,NOBREAK   YES, BREAK  AT THE END ONLY
SETBNUM  BCTR  R15,0          CUT IT DOWN ONE
         STH   R15,NUMBREAK   SET THE BREAK COUNT
*
*        START GOING THROUGH THE LISTS, PROCESS THE ENTRIES
*
         LA    R4,VTCSORTH    POINT TO THE LISTS
         LA    R5,VTCSORTE    POINT TO THE END OF THE LISTS
         ST    R5,ADDREND     SAVE THE ADDRESS
NEWLIST  L     R3,0(R4)       GET THE FIRST ENTRY FROM THIS LIST
         LTR   R3,R3          ANYTHING ON THIS LIST?
         BZ    NEXTLIST       NO, GET ANOTHER LIST
*
*        THIS IS AN ENTRY, DO THE TOTALS, PRINT, AND OUTPUT
*        CHECK FOR TOTALS AND BREAKS FIRST
*
GOTENTRY DS    0H
         CLI   PRINTK+1,2     WAS NOPRINT SET?
*        BE    CHKOUTPT       YES, SKIP INTERIM TOTALS             036G
         BE    GOTOT          YES, SKIP INTERIM TOTALS             036G
         MVI   TOTLAST,0      SET UP FLAG FOR TOTAL AS LAST ACTION
*        NOTE - EXTENSION - OUTPUT INTERIM TOTALS WITH THE KEY
         TM    ENDTOTAL,ENDTONLY  END TOTAL ONLY?
         BO    CHKBREAK       YES, SEE ABOUT BREAKS
         LH    R2,NUMTOTAL    GET THE LENGTH TO COMPARE
         L     R1,LASTKEY     GET THE LAST ENTRY
         EX    R2,COMPKEY     SEE IF THIS IS THE SAME
         BE    CHKBREAK       YES, KEEP COUNTING
*
*        THIS ONE IS DIFFERENT, PRINT THE TOTALS FIRST
*
         BAL   R8,PRNTOT      PRINT THE TOTALS
*
*        CHECK FOR A BREAK
*
CHKBREAK TM    ENDTOTAL,NOBREAK   NO BREAKS THIS TIME?
         BO    SKPBREAK       YES, SKIP PAST BREAKS
         LH    R2,NUMBREAK    GET THE LENGTH TO COMPARE
         L     R1,LASTKEY     GET THE LAST ENTRY
         EX    R2,COMPKEY     SEE IF THIS IS THE SAME
         BE    SKPBREAK       YES, KEEP COUNTING
*
*        THIS ONE IS DIFFERENT, GET A NEW PAGE
*
         MVC   LINECT,LINEMAX BE SURE THE NEXT ITEM GETS A NEW PAGE
         MVI   TOTLAST,0      DON'T SKIP A LINE AFTER TOTAL
         LA    R1,VTFDSN     POINT TO THE DSNAME
         ST    R1,LASTKEY    SAVE THE ADDRESS FOR BREAK COMPARES
*
*        PRINT THE ITEM
*
SKPBREAK CLI   TOTLAST,0      WAS A TOTAL NOT FOLLOWED BY A BREAK?
         BE    SKPBREA2       NO, CONTINUE NORMALLY
         MVC   MSGBL,MSGBLC   YES, SET UP A BLANK MESSAGE
         LA    R1,MSGBL       POINT TO IT
         BAL   R8,PRNTLINE    THEN PUTPUT IT
SKPBREA2 BAL   R8,PRINT       FINAL FORMAT AND PRINT
*                                                                  036G
*        CHECK FOR JCL DATA SET OUTPUT                         004G036G
*                                                                  036G
*CHKOUTPT TM    JCLDCB+48,X'10'     IS IT OPEN AND READY       004G036G
*         BNO   GOTOT          NO, GO DO THE TOTALS                036G
*         BAL   R8,OUTPUT      YES, PUT OUT THE DATA SET ENTRY     036G
*
*        ADD UP THE TOTALS
*
GOTOT    BAL   R8,ADDTOT      SUM THEM
*
*        GET THE NEXT ENTRY
*
         ICM   R3,B'1111',VTFNEXT  FOLLOW THE CHAIN
         BNZ   GOTENTRY       SOMETHING'S THERE, USE IT
*
*        END OF THIS LIST, TRY THE NEXT LIST
*
NEXTLIST LA    R4,4(R4)       MOVE OVER ONE
         C     R4,ADDREND     WAS THAT THE LAST LIST?
         BL    NEWLIST        NO, KEEP TRYING
*
*        END OF THE LISTS, OUTPUT THE FINAL TOTAL AND RETURN
*
         BAL   R8,PRNTOT      LIST THE TOTAL
*
*        CLEAR OUT THE PRINT LISTS
*
         XC    VTCSORTH+000(256),VTCSORTH  CLEAR 64 ENTRIES
         XC    VTCSORTH+256(256),VTCSORTH+256 CLEAR 64 ENTRIES
         XC    VTCSORTH+512(256),VTCSORTH+512 CLEAR 64 ENTRIES
         XC    VTCSORTH+768(256),VTCSORTH+768 CLEAR 64 ENTRIES
         B     VTRET             THEN GET OUT OF HERE.
         EJECT
*
*        PRINT CLEANUP ROUTINE - CLOSE DCB'S FIRST
*
PRNTCLEN TM    SYSOUT+48,X'10'  IS SYSOUT OPEN?
*        BNO   PRNTCLO        NO, CHECK THE JCLDCB             004G036G
         BNO   PRNTFREE       NO, SKIP DOWN TO THE FREEMAINS.  004G036G
         CLOSE (SYSOUT),MF=(E,OPENLIST)  DO THE CLOSE
*PRNTCLO  TM    JCLDCB+48,X'10'  IS JCLDCB OPEN?               004G036G
*        BNO   PRNTFREE       NO, SKIP DOWN TO THE FREEMAINS       036G
*        CLOSE (JCLDCB),MF=(E,OPENLIST)  DO THE CLOSE          004G036G
*
*        FREE UP THE STORAGE
*
PRNTFREE LA    R2,VTCGETMN    POINT TO THE TABLE
         LA    R5,VTCGETMX    GET THE NUMBER OF ENTRIES IN THE TABLE
PRNTFRL  ICM   R3,B'1111',0(R2)  GET THE STORAGE ADDRESS
         BZ    VTRET          IF ZERO, WE'RE DONE
         FREEMAIN R,LV=VTCGETMS,A=(R3)  FREE IT
         XC    0(4,R2),0(R2)  CLEAR THE ADDRESS
         LA    R2,4(R2)       GET THE NEXT BLOCK ADDRESS
         BCT   R5,PRNTFRL     AND LOOP UNTIL DONE
         B     VTRET          THEN RETURN
*
         EJECT
**********************
* PRINT THE VTOC MAP *
**********************
         SPACE
MAPVTOC  EQU   *
         MVC   LINECT,LINEMAX          MAKE SURE TO DO HEADINGS.   014G
         CLI   MAPK+1,2            WAS A MAP REQUESTED?       014G 015G
         BE    NOMAPPRT            NO, SKIP PRINT MESSAGES.   014G 015G
         MVI   MAPHEADH+4,C' '              CLEAR LINE.            016G
         MVC   MAPHEADH+5(250),MAPHEADH+4                          016G
         MVC   MAPHEADH(MAPHEADL),MAPHEADC  INIT THE HEAD MESSAGE. 016G
         MVC   MAPHEADH+22(6),VOLID   MOVE VOLSER.                 014G
         MVC   MAPHEADH+38(3),ADDR    MOVE DRIVE ADDR.             014G
         MVC   MAPHEADH+47(6),UNITYP  MOVE UNIT TYPE .             014G
         MVI   MAPTITLH+4,C' '              CLEAR LINE.            016G
         MVC   MAPTITLH+5(250),MAPTITLH+4                          016G
         MVC   MAPTITLH(MAPTITLL),MAPTITLC  INIT THE TITL MESSAGE. 016G
         OI    VTCPFUNC,X'02'               INDICATE NO TITLES.    018G
         LA    R1,MAPHEADH                  GET A(PRINT LINE).     018G
         BAL   R8,PRNTLINE                  PRINT IT.              018G
         MVI   MSGWORK+4,C' '               CLEAR LINE.            018G
         MVC   MSGWORK+5(250),MSGWORK+4                            018G
         MVC   MSGWORK(MAPVTC1L),MAPVTC1C   MOVE MESSAGE.          018G
         LA    R1,MSGWORK                   GET A(PRINT LINE).     018G
         BAL   R8,PRNTLINE                  PRINT IT.              018G
         MVI   MSGWORK+4,C' '               CLEAR LINE.            018G
         MVC   MSGWORK+5(250),MSGWORK+4                            018G
         MVC   MSGWORK(MAPVTC2L),MAPVTC2C   MOVE MESSAGE.          018G
         SR    R8,R8                                               018G
*        LH    R8,DS4DEVSZ             DEVICE SIZE IN CYLINDERS018G039G
         SR    R8,R8                   CLEAR REG.                  039G
         ICM   R8,3,DS4DEVSZ           DEVICE SIZE IN CYLINDERS.   039G
         VTCEDIT MSGWORK+23,R8,EDIT6                               018G
         LH    R8,DS4DSREC             NMBR AVAIL FMT 0 DSCBS LEFT 018G
         VTCEDIT MSGWORK+51,R8,EDIT6                               018G
         LA    R1,MSGWORK                   GET A(PRINT LINE).     018G
         BAL   R8,PRNTLINE                  PRINT IT.              018G
         MVI   MSGWORK+4,C' '               CLEAR LINE.            018G
         MVC   MSGWORK+5(250),MSGWORK+4                            018G
         MVC   MSGWORK(MAPVTC3L),MAPVTC3C   MOVE MESSAGE.          018G
*        LH    R8,DS4DEVSZ+2           NUMBER TRACKS PER CYLIN 018G039G
         SR    R8,R8                   CLEAR REG.                  039G
         ICM   R8,3,DS4DEVSZ+2         NUMBER TRACKS PER CYLINDER  039G
         VTCEDIT MSGWORK+23,R8,EDIT6                               018G
*        LH    R8,DS4DEVTK             DEVICE TRACK LENGTH     018G028G
         SR    R8,R8                   CLEAR REG.                  028G
         ICM   R8,3,DS4DEVTK           DEVICE TRACK LENGTH.        028G
         VTCEDIT MSGWORK+51,R8,EDIT6                               018G
         LA    R1,MSGWORK                   GET A(PRINT LINE).     018G
         BAL   R8,PRNTLINE                  PRINT IT.              018G
         MVI   MSGWORK+4,C' '               CLEAR LINE.            018G
         MVC   MSGWORK+5(250),MSGWORK+4                            018G
         MVC   MSGWORK(MAPVTC4L),MAPVTC4C   MOVE MESSAGE.          018G
         SR    R8,R8                                               018G
         IC    R8,DS4DEVDT             NUMBER FULL DSCBS ON A TRACK018G
         VTCEDIT MSGWORK+23,R8,EDIT6                               018G
         IC    R8,DS4DEVDB             NMBR PDS DIR. BLKS PER TRACK018G
         VTCEDIT MSGWORK+51,R8,EDIT6                               018G
         LA    R1,MSGWORK                   GET A(PRINT LINE).     018G
         BAL   R8,PRNTLINE                  PRINT IT.              018G
         MVI   MSGWORK+4,C' '               CLEAR LINE.            018G
         MVC   MSGWORK+5(250),MSGWORK+4                            018G
         MVC   MSGWORK(MAPVTC5L),MAPVTC5C   MOVE MESSAGE.          018G
         LH    R8,DS4NOATK             NMBR ALTERNATE TRACKS REMAIN018G
         VTCEDIT MSGWORK+23,R8,EDIT6                               018G
*        LH    R8,DS4HCCHH+2           HH OF NEXT ALT TRK AVAIL018G039G
         SR    R8,R8                   CLEAR REG.                  039G
         ICM   R8,3,DS4HCCHH+2         HH OF NEXT ALT TRK AVAIL    039G
GOTALT2  CVD   R8,DOUBLE                                           018G
         MVC   MSGWORK+53(L'EDIT4),EDIT4                           018G
         ED    MSGWORK+53(L'EDIT4),DOUBLE+6                        018G
*        LH    R8,DS4HCCHH             CC OF NEXT ALT TRK AVAIL018G039G
         SR    R8,R8                   CLEAR REG.                  039G
         ICM   R8,3,DS4HCCHH           CC OF NEXT ALT TRK AVAIL    039G
GOTALT1  CVD   R8,DOUBLE                                           018G
         MVC   MSGWORK+47(L'EDIT4),EDIT4                           018G
         ED    MSGWORK+47(L'EDIT4),DOUBLE+6                        018G
         LA    R1,MSGWORK                   GET A(PRINT LINE).     018G
         BAL   R8,PRNTLINE                  PRINT IT.              018G
         TM    DS4VTOCI,DS4IVTOC      IS THERE AN INDEXED VTOC?    014G
         BNO   NOIXVTOC               NO, SKIP MESSAGE.            014G
         MVI   MSGWORK+4,C' '               CLEAR LINE.            016G
         MVC   MSGWORK+5(250),MSGWORK+4                            016G
         MVC   MSGWORK(MIXVTOCL),MIXVTOC MOVE MESSAGE.             016G
         LA    R1,MSGWORK                   GET A(PRINT LINE).     016G
         BAL   R8,PRNTLINE                  PRINT IT.              014G
NOIXVTOC NI    VTCPFUNC,X'FD'               INDICATE TITLES NOW.   018G
         MVC   LINECT,LINEMAX          MAKE SURE TO DO HEADINGS.   018G
NOMAPPRT CLI   LIMITK+1,0          WAS LIMIT SPECIFIED?            018G
         BNE   NOGAPCK             YES, THEN I CANT CHECK GAPS.    015G
         CLI   LEVKEY+1,0          WAS LEVEL SPECIFIED?            015G
         BNE   NOGAPCK             YES, THEN I CANT CHECK GAPS.    015G
         CLI   NLEVKEY+1,0         WAS NOTLEVEL SPECIFIED?         015G
         BNE   NOGAPCK             YES, THEN I CANT CHECK GAPS.    015G
         CLI   CONTAINK+1,0        WAS CONTAINING SPECIFIED?       015G
         BNE   NOGAPCK             YES, THEN I CANT CHECK GAPS.    015G
         CLI   NCONKEY+1,0         WAS NOTCONTAINING SPECIFIED?    015G
         BNE   NOGAPCK             YES, THEN I CANT CHECK GAPS.    015G
         CLI   ENDKEY+1,0          WAS END SPECIFIED?              015G
         BNE   NOGAPCK             YES, THEN I CANT CHECK GAPS.    015G
         CLI   NENDKEY+1,0         WAS NOTEND SPECIFIED?           015G
         BNE   NOGAPCK             YES, THEN I CANT CHECK GAPS.    015G
         B     VTOCCK
NOGAPCK  MVI   MSGWORK+4,C' '      YES, THEN I CANT CHECK GAPS.    016G
         MVC   MSGWORK+5(250),MSGWORK+4     CLEAR LINE.            016G
         MVC   MSGWORK(MRESTRL),MRESTRC     MOVE MESSAGE.          016G
         CLI   HEADK+1,2           NOHEADING REQUEST?              019G
         BE    VTOCCK              YES, SKIP TELLING THEM.         019G
         LA    R1,MSGWORK                   GET A(PRINT LINE).     016G
         BAL   R8,PRNTLINE                  PRINT IT.              014G
VTOCCK   TM    DS4VTOCI,DS4DIRF    IS DIRF BIT ON?                 018G
         BNO   GAPCK                                               018G
         MVI   MSGWORK+4,C' '               CLEAR LINE.            018G
         MVC   MSGWORK+5(250),MSGWORK+4                            018G
         MVC   MSGWORK(MDIRFL),MDIRFC   VTOC DAMAGE POSSIBLE.      018G
         MVC   MSGWORK+MDIRFL-6(6),VOLID  MOVE VOLSER.             029G
         LA    R1,MSGWORK              GO PRINT LINE.              018G
         BAL   R8,PRNTLINE             GO PRINT LINE.              018G
         MVC   MSGWORK+5(250),MSGWORK+4 C                          018G
         MVC   MSGWORK(MAPSTML),MAPSTMC   MOVE CALL STOR. MGMT.    018G
         LA    R1,MSGWORK              GO PRINT LINE.              018G
         BAL   R8,PRNTLINE             GO PRINT LINE.              018G
GAPCK    L     R4,VTCMPMEM         GET A(BEGINNING OF MAP MEM).    014G
         USING EXTDSEC,R4          TELL ASSEMBLER.                 014G
MAPNEXT  CLI   0(R4),X'FF'         ALL ENTRIES BEEN PROCESSED?     014G
         BE    ENDMAP              YES, QUIT.                      014G
         L     R5,EXTADSN              GET A(ASSOCIATED DSN).      014G
         CLI   MAPK+1,2            WAS A MAP REQUESTED?            015G
         BE    MAPEXTCK            NO, DONT PRINT MESSAGES.        015G
         MVI   WORKLINE+4,C' '              CLEAR LINE.            014G
         MVC   WORKLINE+5(250),WORKLINE+4                          014G
         MVC   WORKLINE+38(16),MVTOC   PREMOVE MESSAGE.            014G
         CLI   0(R5),X'04'             CHECK IF VTOC AREA.         014G
         BE    MAPEXT#                 YES, GOT TYPE AREA.         014G
         MVC   WORKLINE+38(16),MFREE   PREMOVE MESSAGE.            014G
         CLI   0(R5),X'05'             CHECK IF FREE AREA.         014G
         BE    MAPEXT#                 YES, GOT TYPE AREA.         014G
         MVC   WORKLINE+38(16),MSPLIT  PREMOVE MESSAGE.            014G
         CLI   0(R5),X'06'             CHECK IF SPLIT AREA.        014G
         BE    MAPEXT#                 YES, GOT TYPE AREA.         014G
         MVC   WORKLINE+38(16),MADDL   PREMOVE MESSAGE.            014G
         MVC   WORKLINE+54(44),0(R5)   YES, MOVE DSNAME.           014G
         CLI   EXTNUM,0                IS IT 1ST EXTENT?           014G
         BNE   MAPEXT#                 NO, IT IS ADDL EXTENT.      014G
         MVI   WORKLINE+38,C' '        CLEAR WORKLINE.             014G
         MVC   WORKLINE+39(59),WORKLINE+36                         014G
         MVC   WORKLINE+38(44),0(R5)   YES, MOVE DSNAME.           014G
MAPEXT#  SR    R7,R7                   CLEAR REG.                  014G
         IC    R7,EXTNUM               NUMBER OF EXTENT            014G
         CVD   R7,DOUBLE               CONVERT TO DECIMAL          014G
         MVC   WORKLINE+6(4),=X'40202120'      AND                 014G
         ED    WORKLINE+6(4),DOUBLE+6    PUT ON PRINT LINE.        014G
         CLI   SUBMAP+1,2              WAS REQUEST FOR ABS TRACK?  014G
         BNE   MAPHEX                  NO, SHOW IT IN HEX.         014G
*        LH    R7,EXTSTRT              STARTING TRACK OF EXTENT014G039G
         SR    R7,R7                   CLEAR REG.                  039G
         ICM   R7,3,EXTSTRT            STARTING TRACK OF EXTENT.   039G
         VTCEDIT WORKLINE+13,R7,EDIT6                              014G
*        LH    R7,EXTEND               ENDING TRACK OF EXTENT. 014G039G
         SR    R7,R7                   CLEAR REG.                  039G
         ICM   R7,3,EXTEND             ENDING TRACK OF EXTENT.     039G
         VTCEDIT WORKLINE+22,R7,EDIT6                              014G
         B     MAPHEXND                CONTINUE, REST OF INFO.     014G
MAPHEX   DS    0H                                                  039G
*APHEX   LH    R7,EXTSTRT              STARTING TRACK OF EXTENT014G039G
         SR    R7,R7                   CLEAR REG.                  039G
         ICM   R7,3,EXTSTRT            STARTING TRACK OF EXTENT.   039G
         LA    R1,WORKLINE+13                                      014G
         BAL   R8,HEXCNVT                                          014G
*        LH    R7,EXTEND               ENDING TRACK OF EXTENT  014G039G
         SR    R7,R7                   CLEAR REG.                  039G
         ICM   R7,3,EXTEND             ENDING TRACK OF EXTENT.     039G
         LA    R1,WORKLINE+22                                      014G
         BAL   R8,HEXCNVT                                          014G
MAPHEXND DS    0H                                                  039G
*APHEXND LH    R7,EXTLEN               LENGTH IN TRACKS OF EXT.014G039G
         SR    R7,R7                   CLEAR REG.                  039G
         ICM   R7,3,EXTLEN             LENGTH IN TRACKS OF EXT.    039G
         VTCEDIT WORKLINE+31,R7,EDIT6                              014G
         LA    R1,WORKLINE             GO PRINT LINE.              014G
         BAL   R8,PRNTLINE             GO PRINT LINE.              014G
MAPEXTCK CLI   EXTL(R4),X'FF'      AM I ON LAST ENTRY?             014G
         BE    MAPOKEXT            YES, SKIP OVERLAP GAP CHECK.    014G
         MVI   WORKLINE+4,C' '              CLEAR LINE.            014G
         MVC   WORKLINE+5(250),WORKLINE+4                          014G
*        LH    R0,EXTSTRT+EXTL     GET START TR OF NEXT EXT.   014G039G
         SR    R0,R0                   CLEAR REG.                  039G
         ICM   R0,3,EXTSTRT+EXTL   GET START TR OF NEXT EXT.       039G
*        LH    R5,EXTEND           GET END TR OF CURRENT EXT.  014G039G
         SR    R5,R5                   CLEAR REG.                  039G
         ICM   R5,3,EXTEND         GET END TR OF CURRENT EXT.      039G
         LA    R5,1(R5)            SHOULD ONLY BE ONE TRACK        014G
*                                   DIFFERENCE IN EXTENTS IF OK.   014G
         CR    R0,R5               COMPARE EXTENT ADDRESSES.       014G
         BE    MAPOKEXT             EQUAL- NO GAPS OR OVERLAP.     014G
         BP    MAPGPEXT             HIGH- WE HAVE AN GAP.          014G
*                                   LOW- WE HAVE OVERLAP.          014G
         SR    R5,R0               FIND LENGTH OF OVERLAP.         014G
         LR    R7,R0               SET START TRACK NUMB.           014G
         MVC   WORKLINE+29(17),=C' TRKS,START CCHH='               015G
         LA    R1,WORKLINE+46       WHERE TO PUT HEX VALUE.        015G
         BAL   R8,HEXCNVT           GO CONVERT VALUES TO HEX.      014G
         MVC   WORKLINE+5(10),=C'---OVERLAP'                       014G
         B     MAPNGEXT                                            014G
MAPGPEXT EQU   *                    R5=START NEXT EXTENT+1         014G
         TM    DS4VTOCI,DS4IVTOC    IS THERE AN INDEXED VTOC?      014G
         BO    MAPOKEXT             YES, SKIP MESSAGE.             014G
         CLI   LIMITK+1,0          WAS LIMIT SPECIFIED?            015G
         BNE   MAPOKEXT            YES, CANT CHECK GAPS.           015G
         CLI   LEVKEY+1,0          WAS LEVEL SPECIFIED?            015G
         BNE   MAPOKEXT            YES, THEN I CANT CHECK GAPS.    015G
         CLI   NLEVKEY+1,0         WAS NOTLEVEL SPECIFIED?         015G
         BNE   MAPOKEXT            YES, THEN I CANT CHECK GAPS.    015G
         CLI   CONTAINK+1,0        WAS CONTAINING SPECIFIED?       015G
         BNE   MAPOKEXT            YES, THEN I CANT CHECK GAPS.    015G
         CLI   NCONKEY+1,0         WAS NOTCONTAINING SPECIFIED?    015G
         BNE   MAPOKEXT            YES, THEN I CANT CHECK GAPS.    015G
         CLI   ENDKEY+1,0          WAS END SPECIFIED?              015G
         BNE   MAPOKEXT            YES, THEN I CANT CHECK GAPS.    015G
         CLI   NENDKEY+1,0         WAS NOTEND SPECIFIED?           015G
         BNE   MAPOKEXT            YES, THEN I CANT CHECK GAPS.    015G
         MVC   WORKLINE+5(10),=C'---GAP    '  NO, CHECK GAPS.      015G
         LR    R7,R0                UPPER GAP TRACK NUMB.          014G
         BCTR  R7,0                 GET ENDING TRACK OF GAP.       014G
         MVC   WORKLINE+56(9),=C'END CCHH='                        015G
         LA    R1,WORKLINE+65       WHERE TO PUT HEX VALUE.        015G
         BAL   R8,HEXCNVT           GO CONVERT VALUES TO HEX.      014G
         LR    R7,R5                LOWER GAP TRACK NUMB.          014G
         MVC   WORKLINE+29(17),=C' TRKS,START CCHH='               015G
         LA    R1,WORKLINE+46       WHERE TO PUT HEX VALUE.        015G
         BAL   R8,HEXCNVT           GO CONVERT VALUES TO HEX.      014G
         SR    R0,R5                FIND LENGTH OF GAP.            014G
         LPR   R5,R0                FIND LENGTH OF GAP.            014G
MAPNGEXT VTCEDIT WORKLINE+23,R5,EDIT6  LENGTH OF GAP/OVERLAP.      015G
         MVC   WORKLINE+16(6),VOLID   MOVE VOLSER.                 015G
         LA    R1,WORKLINE             GO PRINT LINE.              014G
         BAL   R8,PRNTLINE             GO PRINT LINE.              014G
         MVI   MSGWORK+4,C' '               CLEAR LINE.            016G
         MVC   MSGWORK+5(250),MSGWORK+4 C                          016G
         MVC   MSGWORK(MAPSTML),MAPSTMC   MOVE CALL STOR. MGMT.    016G
         LA    R1,MSGWORK              GO PRINT LINE.              016G
         BAL   R8,PRNTLINE             GO PRINT LINE.              015G
         MVI   WORKLINE+4,C' '              CLEAR LINE.            015G
         MVC   WORKLINE+5(250),WORKLINE+4                          015G
MAPOKEXT LA    R4,EXTL(R4)             BUMP TO NEXT EXTENT ENTRY.  014G
         B     MAPNEXT                 GO GET NEXT EXTENT TO MAP.  014G
ENDMAP   MVC   LINECT,LINEMAX          MAKE SURE TO DO HEADINGS.   014G
         B     VTRET                   THEN GET OUT OF HERE.       014G
***************************************
* ROUTINE TO CONVERT TO PRINTABLE HEX *
***************************************
*   INPUT IS IN R7,RETURN TO R8 ADDR  *
*   WORK REG IS R6                    *
***************************************
HEXCNVT  SR    R6,R6                    GET READY FOR DIVISION     014G
         STH   R6,DOUBLE                ZERO FIRST 2 BYTES         014G
         MVC   DOUBLE+2(2),DS4DEVSZ+2   MOVE TRACKS/CYL            014G
         D     R6,DOUBLE                TRK#=R6 CYL#=R7            014G
         SLL   R7,16                    GET READY FOR CCHH         014G
         OR    R7,R6                    CCHH NOW IN R7             014G
         ST    R7,DOUBLE                GET READY FOR CONVERSION   014G
         UNPK  0(9,R1),DOUBLE(5)        MAKE EBCDIC                014G
         TR    0(8,R1),HEXTABEL-240     CONVERT FA-->FF TO CHAR    014G
         MVI   9(R1),C' '               FIX BAD CHAR               014G
         BR    R8                       RETURN                     014G
         EJECT
*
*        ROUTINES USED ABOVE
*              ADDTOT - ADD TO THE CURRENT TOTALS
*              PRNTOT - PRINT OUT THE TOTALS AND CLEAR THEM
*              PRINT  - PRINT OUT AN ENTRY
*              OUTPUT - OUTPUT THE DATA SET ENTRY
*              PDLNUM - GET A NUMBER FROM A PDL ENTRY
*              PRNTLINE - INTERNAL ROUTINE TO COUNT LINES, OUTPUT HEAD
*
ADDTOT   L     R1,TOTDS       NUMBER OF DATA SETS
         LA    R1,1(R1)       ADD ONE
         ST    R1,TOTDS       STORE IT BACK
         L     R1,TOTALLOC    TOTAL ALLOCATION
         A     R1,VTFALLOC    ADD IN THIS DATA SET
         ST    R1,TOTALLOC    STORE IT BACK
         L     R1,TOTUSED     TOTAL USED SPACE
         A     R1,VTFUSED     ADD IN THIS DATA SET
         ST    R1,TOTUSED     STORE IT BACK
         BR    R8             RETURN
*
         EJECT
*
*        PRINT THE TOTALS
*              FIRST FORMAT THEM, THEN PUT THE LINE OUT TO SYSOUT
*              OR USE VTOCMSG TO LIST IT
*
PRNTOT   ST    R8,PRNTTOT8   SAVE THE RETURN ADDRESS
         MVC   MSGWORK(MSGTOTL),MSGTOTC  INIT THE MSG
         CONV  MSGWORK+4+11,TOTDS,5  CONVERT NO OF DATA SETS
         CONV  MSGWORK+4+28,TOTALLOC,8  CONVERT ALLOCATION
         CONV  MSGWORK+4+51,TOTUSED,8   CONVERT USED SPACE
         MVC   MSGWORK+4+37(6),SPACTYPE MOVE IN THE UNITS
         MVC   MSGWORK+4+60(6),SPACTYPE MOVE IN THE UNITS
*
*        NOW OUTPUT THE MESSAGE
*
         CLI   MAPK+1,2       WAS A MAP REQUESTED?                 018G
         BE    PRNTOTOK       NO, PRINT TOTALS.                    018G
         CLI   PRINTK+1,2     IS THIS NOPRINT IN ADDITION?         018G
         BE    PRNTOTSK       YES, SKIP THE TOTALS.                018G
PRNTOTOK MVI   MSGWORK+4,C'0' ADD A CARRIAGE CONTROL
         LA    R1,MSGWORK     POINT TO THE TOTAL LINE
         BAL   R8,PRNTLINE    PUT OUT THE TOTAL LINE
PRNTOTSK MVI   TOTLAST,1      NOTE THAT A TOTAL WAS THE LAST ITEM
         SR    R1,R1          ZERO FOR CLEARING TOTALS.            013G
         ST    R1,TOTDS       STORE IT BACK.                       013G
         ST    R1,TOTALLOC    STORE IT BACK.                       013G
         ST    R1,TOTUSED     STORE IT BACK.                       013G
         BAL   R8,PRNGEOM
         L     R8,PRNTTOT8    GET THE RETURN ADDRESS
         BR    R8             THEN RETURN
         EJECT
*
*        PRINT DISK GEOMETRY
*
PRNGEOM  DS    0H
         ST    R8,PRNGEOM8    SAVE THE RETURN ADDRESS
**                    1         2         3         4         5
**               567890123456789012345678901234567890123456789012345678
**       VTCMSG ' >>BREXX VOLUME DRV UNIT   CYLS DSCB TCYL TRKLN TDSCB
**               6     '
**              9012345'
**              PTRK ALT'
         OI    VTCPFUNC,X'02'               INDICATE NO TITLES.    018G
         MVC   MSGWORK(MSGBREXL),MSGBREXC   MOVE MESSAGE.          018G
         MVI   MSGWORK+4,C' '               CLEAR LINE.            016G
         MVC   MSGWORK+14(6),VOLID    MOVE VOLSER.                 014G
         MVC   MSGWORK+21(3),ADDR     MOVE DRIVE ADDR.             014G
         MVC   MSGWORK+25(6),UNITYP   MOVE UNIT TYPE .             014G
         SR    R8,R8                                               018G
         ICM   R8,3,DS4DEVSZ           DEVICE SIZE IN CYLINDERS.   039G
         VTCEDIT MSGWORK+32,R8,EDIT6                               018G
         LH    R8,DS4DSREC             NMBR AVAIL FMT 0 DSCBS LEFT 018G
         VTCEDIT MSGWORK+39,R8,EDIT6                               018G
         SR    R8,R8                   CLEAR REG.                  039G
         ICM   R8,3,DS4DEVSZ+2         NUMBER TRACKS PER CYLINDER  039G
         VTCEDIT MSGWORK+46,R8,EDIT6                               018G
         SR    R8,R8                   CLEAR REG.                  028G
         ICM   R8,3,DS4DEVTK           DEVICE TRACK LENGTH.        028G
         VTCEDIT MSGWORK+53,R8,EDIT6                               018G
         SR    R8,R8                                               018G
         IC    R8,DS4DEVDT             NUMBER FULL DSCBS ON A TRACK018G
         VTCEDIT MSGWORK+60,R8,EDIT6                               018G
         IC    R8,DS4DEVDB             NMBR PDS DIR. BLKS PER TRACK018G
         VTCEDIT MSGWORK+67,R8,EDIT6                               018G
         LH    R8,DS4NOATK             NMBR ALTERNATE TRACKS REMAIN018G
         VTCEDIT MSGWORK+74,R8,EDIT6                               018G
         SR    R8,R8                   CLEAR REG.                  039G
         ICM   R8,3,DS4HCCHH+2         HH OF NEXT ALT TRK AVAIL    039G
         CVD   R8,DOUBLE                                           018G
         MVC   MSGWORK+81(L'EDIT4),EDIT4                           018G
         ED    MSGWORK+81(L'EDIT4),DOUBLE+6                        018G
         SR    R8,R8                   CLEAR REG.                  039G
         ICM   R8,3,DS4HCCHH           CC OF NEXT ALT TRK AVAIL    039G
         CVD   R8,DOUBLE                                           018G
         MVC   MSGWORK+88(L'EDIT4),EDIT4                           018G
         ED    MSGWORK+88(L'EDIT4),DOUBLE+6                        018G
         LA    R1,MSGWORK                   GET A(PRINT LINE).     018G
         BAL   R8,PRNTLINE                  PRINT IT.              018G
         L     R8,PRNGEOM8    SAVE THE RETURN ADDRESS
         BR    R8             THEN RETURN
         EJECT
*
*        PRINT OUT THE FORMATTED DSCB
*              FIRST FORMAT IT
*
PRINT    ST    R8,PRINTR8     SAVE REGISTER 8 FOR RETURNING
         MVI   WORKLINE+4,C' ' BLANK OUT THE LINE
         MVC   WORKLINE+5(250),WORKLINE+4 SO INDIVIUAL FIELDS DON'T
         L     R2,VTPRNTLS   GET THE PRINT ITEM LIST
         LA    R1,WORKLINE+4  POINT TO THE WORK  LINE
PRTLOOP  SR    R6,R6          GET THE RESERVED WORD NUMBER
         IC    R6,0(R2)       FROM THE TOP BYTE
         MH    R6,H12         MULTIPLY BY 12 FOR THE TABLE ENTRIES
         LA    R6,TABTITL(R6) THEN RELOCATE THE MESS
         SR    R7,R7          CLEAR A REGISTER
         IC    R7,0(R6)       GET THE EXECUTE LENGTH
         LA    R5,1(R1)       SAVE A PLACE TO MOVE FIELD INTO
         LA    R1,1(R1,R7)    MOVE THE POINTER OVER
         LA    R0,WORKLINE+4  POINT TO THE BEGINNING AGAIN
         SR    R1,R0          AND FIND THE CURRENT LENGTH
         CH    R1,LINELEN     IS IT TOO LONG?
         BNL   PRTEND         YES, WE'RE DONE
         AR    R1,R0          NO, KEEP GOING
*
*        MOVE IN OR CONVERT THIS ITEM
*
         SR    R14,R14       CLEAR A REG FOR LENGTH OF RTN NO
         IC    R14,1(R6)     GET THE LENGTH OR ROUTINE
         N     R14,F127      CLEAR THE TOP BIT
         SR    R15,R15       CLEAR A REG FOR VTFMT
         IC    R15,2(R6)       DISPLACEMENT
         AR    R15,R3        RELOCATE IT
*
*        DECIDE WHERE TO PUT IT
*
         TM    1(R6),X'80'   IS IT IN CHARS
         BNO   PRTRTN        NO, USE THE SPECIAL ROUTINE
         SR    R7,R14        GET THE DIFFERENCE IN LENGTHS
         SRL   R7,1          GET HALF THE DIFFERENCE
         AR    R5,R7         PUT THE DATA HERE
         EX    R14,PRTMOVE   MOVE IN THE CHARACTERS
PRTINC   LA    R2,1(R2)            GET THE NEXT CHAIN POINTER
         CLI   0(R2),0       ARE WE DONE?
         BNE   PRTLOOP        GO GET MORE ITEMS
PRTEND   LA    R1,WORKLINE   POINT TO THIS LINE
         BAL   R8,PRNTLINE   THEN GO PRINT IT
         L     R8,PRINTR8     GET THE RETURN ADDRESS
         BR    R8             RETURN
PRTMOVE  MVC   0(0,R5),0(R15)  EXECUTED MOVE
*
*        VARIOUS ROUTINES TO FORMAT BEFORE MOVING IN THE DATA
*
PRTRTN   LTR   R14,R14       BE SURE THE OFFSET IS OK
         BP    PRTRTN1        IT SEEMS ALL RIGHT
         ABEND 701,DUMP       CRASH AND BURN
PRTRTN1  B     *(R14)        GO DO YOUR THING
         B     PRDATES        4  CDATE, EXPDT, LSTUS         002S 012G
         B     PRCCHH         8  CCHH                        012G 026G
         B     PRALLOC       12  ALLOC, USED
         B     PRUNUSED      16  ALLOC - USED
         B     PRPCT         20  100 * USED / ALLOC
         B     PREXT         24  EXT
         B     PRBLREC       28  BLKSZ LRECL
         B     PRDSN         32  DSNAME
         B     PRKEY         36  KEY LENGTH.                       035G
*
*
*        CDATE AND EXPDT *** AND LAST USE DATE: MVS SU60***       002S
*
PRDATES  SR    R14,R14       CLEAR REG FOR YEAR
         IC    R14,0(R15)    GET THE YEAR
         USING DUMMD,R5      ALLOW CONV TO USE SYMBOL
         CONV  DUMMA,(R14),2 CONVERT YEAR
         CLC   DUMMA(2),STARS DID WE OVERFLOW?                     DHC2
         BNE   *+4+6         NO, CONTINUE                          DHC2
         MVC   DUMMA(2),CHARS+16-2 YES, BUT REPLACE YEAR VALUE     DHC2
         ICM   R14,B'0011',1(R15)  GET THE DAY
         CONV  DUMMA+2,(R14),3,EDMASK0,COMP0  CONVERT THE DAY
         B     PRTINC        GO GET MORE PRINT ITEMS
*
*
*        CCHH NOT ALLOWED ON PRINT LINE ISSUE ERROR MESSAGE        026G
*
PRCCHH   DS    0H                                                  026G
         MVI   MSGWORK+4,C' '               CLEAR LINE.            026G
         MVC   MSGWORK+5(250),MSGWORK+4                            026G
         MVC   MSGWORK(MNCCHHCL),MNCCHHC MOVE MESSAGE.             026G
         LA    R1,MSGWORK                   GET A(PRINT LINE).     026G
         BAL   R8,PRNTLINE                  PRINT IT.              026G
         B     PRTINC        GO GET MORE PRINT ITEMS               026G
*
*        LAST USE DATE *** FORMERLY USED THIS CODE: SEE MOD 002S   002S
*                                                                  002S
*PRLSTUS MVC   CHARS,EDMASK   SET UP THE EDIT MASK                 002S
*        ED    CHARS(6),0(R15)  CONVERT TO CHARACTERS              002S
*        MVC   0(5,R5),CHARS+1  THEN MOVE THEM IN                  002S
*        B     PRTINC        GO GET MORE PRINT ITEMS               002S
*                                                                  002S
*        ALLOCATION AND USED
*
PRALLOC  ICM   R14,B'1111',0(R15)  GET THE AMOUNT
         BM    PRUNKN6       IF NEGATIVE, IT'S NOT KNOWN
         CONV  DUMMA,(R14),6 CONVERT THE NUMBER
         B     PRTINC        GO GET MORE PRINT ITEMS
PRUNKN6  MVC   0(6,R5),BLANKS  UNKNOWN AMOUNT, LEAVE IT BLANK
         B     PRTINC        GO GET MORE PRINT ITEMS
*
*        UNUSED SPACE
*
PRUNUSED ICM   R14,B'1111',VTFUSED  GET THE   USED SPACE
         BM    PRUNKN6       IF NOT KNOWN, SKIP ALONG
         CLC   VTFDSORG(2),=C'VS'   IF VSAM SHOW UNKNOWN           010G
         BE    PRUNKN6                                             010G
         CLC   VTFDSORG(2),=C'IS'   IF ISAM SHOW UNKNOWN           010G
         BE    PRUNKN6                                             010G
         L     R14,VTFALLOC  GET THE ALLOCATED SPACE
         S     R14,VTFUSED   MINUS THE USED SPACE GIVES UNUSED
         BZ    PRTINC        IF NO UNUSED SPACE, LEAVE BLANK
         CONV  DUMMA,(R14),6 CONVERT FOR PRINTING
         B     PRTINC        GO GET MORE PRINT ITEMS
*
*        PCT - PERCENTAGE USED
*
PRPCT    SR    R6,R6         CLEAR THE TOP PART OF THE NUMBER
         ICM   R7,B'1111',VTFUSED   GET THE AMOUNT OF USED SPACE
         BM    PRUNKN3       IF NOT KNOWN, LEAVE BLANK
         CLC   VTFALLOC,ZERO IS THE ALLOCATION ZERO?
         BNE   PRPCTM        NO, DO THE STANDARD STUFF
         CLC   VTFUSED,ZERO  IS THE USED SPACE ZERO?
         BE    PRUNKN3       YES, JUST USE BLANKS
PRPCTERR MVC   0(3,R5),=C'ERR'  NO, IT'S AN ERROR
         B     PRTINC        THEN GO TRY FOR MORE
PRPCTM   M     R6,F100       MULTIPLY BY 100 FOR PERCENT
         D     R6,VTFALLOC   DIVIDE BY ALLOC TO GET THE PERCENT
         LTR   R7,R7         IS IT LESS THAN ZERO?
         BM    PRPCTERR      YES, FLAG THE ERROR
         C     R7,F100       ALSO CHECK FOR OVER 100 PERCENT
         BH    PRPCTERR      THAT'S ALSO AN ERROR
         CONV  DUMMA,(R7),3  CONVERT FOR PRINTING
         B     PRTINC        GO GET MORE PRINT ITEMS
PRUNKN3  MVC   0(3,R5),BLANKS BLANK THE UNKNOWN
         B     PRTINC        GO GET MORE PRINT ITEMS
*
*        EXTENTS
*
PREXT    SR    R14,R14       CLEAR REG FOR EXTENTS
         IC    R14,0(R15)    GET THE EXTENTS
*        CONV  DUMMA,(R14),2 CONVERT THE EXTENTS
         CONV  DUMMA,(R14),3 CONVERT THE EXTENTS                  030G
         B     PRTINC        GO GET MORE PRINT ITEMS
*
*        LRECL AND BLKSZ
*
PRBLREC  LH    R14,0(R15)    GET THE DATA ( HALFWORD )
         CONV  DUMMA,(R14),5  CONVERT THE DATA
         B     PRTINC        GO GET MORE PRINT ITEMS
*                                                                  035G
*        KEY LENGTH                                                035G
*                                                                  035G
PRKEY    SR    R14,R14       CLEAR REG FOR KEY LENGTH.             035G
         IC    R14,0(R15)    GET THE KEY LENGTH.                   035G
         CONV  DUMMA,(R14),3 CONVERT THE KEY LENGTH.               035G
         B     PRTINC        GO GET MORE PRINT ITEMS.              035G
*
*        DATA SET NAME
*
PRDSN    LH    R14,VTFDSNL   GET THE DSNAME LENGTH
         CH    R14,DSNLENGT  CHACK FOR MAX LENGTH
         BL    PRDMOVE       THIS DSN IS SHORT ENOUGH
         LH    R14,DSNLENGT  CUT IT DOWN
PRDMOVE  BCTR  R14,0         COUNT DOWN ONE FOR THE EX
         EX    R14,PRTMOVE   MOVE IN THE DSNAME
         AH    R1,DSNLENOF   CORRECT THE LINE POINTER
         B     PRTINC        GO GET MORE PRINT ITEMS
*                                                                  033G
*        EFF - EFFICIENCY OF SPACE USAGE                           033G
*                                                                  033G
*        MAJOR FORMULAS USED ARE ADJUSTED FOR EACH VOLUME TYPE     033G
*                                                                  033G
*                     (TOTAL TRACKS USED) * (TRACK EFF)            033G
*        TOTAL EFF =  ----------------------------------------     033G
*                               (TRACKS ALLOCATED)                 033G
*                                                                  033G
*                     (BLOCK LENGTH) * (# OF BLOCKS PER TRACK)     033G
*        TRACK EFF =  ----------------------------------------     033G
*                               (TRACK LENGTH)                     033G
*                                                                  033G
*        3380 FORMULA                                              033G
*        ------------                                              033G
*                                                                  033G
*                   1499      G=7         KEYLEN+E     DATALEN+E   033G
*        BLK/TRK=  -------    E=12   K= G+--------  D= ---------   033G
*                   C+K+D     C=15           32            32      033G
*                                                                  033G
*        3375 FORMULA                                              033G
*        ------------                                              033G
*                                                                  033G
*                   1125                KEYLEN     DATALEN         033G
*        BLK/TRK=  -------  C=12     K= ------  D= -------         033G
*                   C+K+D                 32         32            033G
*                                                                  033G
*        3350 FORMULA                                              033G
*        ------------                                              033G
*                                                                  033G
*                   19254    C=185 IF KEYLEN=0                     033G
*        BLK/TRK=  -------   C=267 IF KEYLEN¬= 0                   033G
*                   C+K+D    K=KEYLEN                              033G
*                            D=DATALEN                             033G
*                                                                  033G
*        3330 FORMULA                                              033G
*        ------------                                              033G
*                                                                  033G
*                   13165    C=135 IF KEYLEN=0                     033G
*        BLK/TRK=  -------   C=191 IF KEYLEN¬=0                    033G
*                   C+K+D    K=KEYLEN                              033G
*                            D=DATALEN                             033G
*                                                                  033G
         EJECT
*
*        OUTPUT THE JCL TO DELETE THE DATASET                  004G036G
*                                                                  036G
*OUTPUT   ST    R8,OUTPUTR8     SAVE RETURN ADDRESS.           006G036G
*         VTCLEAR OUTWORK       CLEAR THE OUTPUT REC           006G036G
*        CLC   VTFVOLUM(4),=C'HSP0' IS IT A PRODUCTION PACK?   006G034G
*        BNE   NOTHSP0              NO.                        006G034G
*        CLI   PRIVATEK+1,2         SHOULD I ALLOW SCRATCH OF  011G034G
*        BE    NOTHSP0               PRODUCTION PACKS.         011G034G
*        CLI   VTFCATLG,C'N'        FOR PROD PACKS DATA TO BE  006G034G
*        BE    NOTHSP0              SCRTCH MUST NOT BE CATLGD. 006G034G
*        CLI   PRIVATEK+1,2         SHOULD I ALLOW SCRATCH OF  011G034G
*        BE    NOTHSP0               PRODUCTION PACKS.         011G034G
*        CLI   VTFCATLG,C'W'        OR WRONGLY CATALOGED       008G034G
*        BNE   OUTRET                                          008G034G
*NOTHSP0  LH    R2,VTFDSNL          GET DSNAME LENGTH.         004G036G
*        CH    R2,H6               CAN I COMPARE SPECIAL DSNS? 006G036G
*        BL    NOTSPDSN            NO, DON'T CHECK SPECIAL DSN 006G036G
*        CLC   VTFDSN(5),CSYS1     DON'T SCRATCH "SYS1." PREFIX006G036G
*        BE    OUTRET                                          004G036G
*        CLC   VTFDSN(6),CSYSCTL   DON'T SCRATCH "SYSCTLG".    006G036G
*        BE    OUTRET                                          006G036G
*        CLC   VTFDSN(6),VTFVOLUM  DON'T SCRATCH DSN = VOLSER. 006G036G
*        BE    OUTRET                                          006G036G
NOTSPDSN CLC   VTFDSORG(2),=C'VS'  DON'T SCRATCH VSAM.         006G036G
*        BE    OUTRET                                          006G036G
*        LH    R2,VTFDSNL     GET THE LENGTH OF THE DSNAME     004G036G
*        LA    R2,VTFMTL-1(R2)  GET THE FULL LENGTH MINUS ONE  004G036G
*        EX    R2,OUTMOVE    MOVE IN THE ACTUAL RECORD         004G036G
*        MVC   OUTWORK(72),JCLDD     MOVE IN BEGIN OF JCL STMT.004G036G
*        LH    R2,VTFDSNL            GET L(DSNAME).            004G036G
*        BCTR  R2,0                  DECREMENT FOR EX.         004G036G
*        EX    R2,OUTMOVE1           MOVE DSNAME.              007G036G
*        LA    R2,OUTWORK+20(R2)     GET A(BYTE JUST PAST DSN).004G036G
*        MVI   0(R2),C','            INDICATE JCL CONTINUATION.004G036G
*        L     R2,JCLSEQ#            GET CURRENT JCL SEQ#.     006G036G
*        AH    R2,H10                ADD 10.                   006G036G
*        ST    R2,JCLSEQ#              SAVE IT.                006G036G
*        CONV  OUTWORK+4,(R2),6,EDMASK0,COMP0  DO DD #         006G036G
*        CONV  OUTWORK+72,(R2),8,EDMASK0,COMP0 DO SEQ #        006G036G
*        PUT   JCLDCB,OUTWORK        OUTPUT THE RECORD.        006G036G
*        MVC   OUTWORK(72),JCLDISP   MOVE DISP JCL.            004G036G
*        CLI   VTFCATLG,C'C'         IS DSN PROPERLY CATALOGED?004G036G
*        BE    OUTJCLCT              YES, PUT OUT WITHOUT VOLSE004G036G
*        MVC   OUTWORK+32(23),JCLVOL    MOVE VOLSER JCL.       004G036G
*        MVC   OUTWORK+55(6),VTFVOLUM   MOVE VOLUME SERIAL NUMB004G036G
*OUTJCLCT L     R2,JCLSEQ#            GET CURRENT JCL SEQ#.    006G036G
*        AH    R2,H10                ADD 10.                   006G036G
*        ST    R2,JCLSEQ#              SAVE IT.                006G036G
*        CONV  OUTWORK+72,(R2),8,EDMASK0,COMP0 DO SEQ #        006G036G
*        PUT   JCLDCB,OUTWORK        OUTPUT THE RECORD.        006G036G
*        CLI   VTFCATLG,C'E'         WAS THERE A CATALOG ERROR?004G036G
*        BNE   OUTRET                NO RETURN.                004G036G
*        MVC   OUTWORK(72),JCLERROR  MOVE JCL ERROR INDICATION.004G036G
*        L     R2,JCLSEQ#            GET CURRENT JCL SEQ#.     006G036G
*        AH    R2,H10                ADD 10.                   006G036G
*        ST    R2,JCLSEQ#              SAVE IT.                006G036G
*        CONV  OUTWORK+72,(R2),8,EDMASK0,COMP0 DO SEQ #        006G036G
*        PUT   JCLDCB,OUTWORK        OUTPUT THE RECORD.        006G036G
*OUTRET   L     R8,OUTPUTR8       RESTORE RETURN ADDR.         006G036G
*        BR    R8                RETURN.                       006G036G
*OUTMOVE1 MVC   OUTWORK+19(0),VTFDSN  EXECUTED MOVE OF DSNAME. 007G036G
         EJECT
*
*        PDLNUM - CONVERT FROM CHARACTERS ( EBCDIC ) TO AN INTEGER
*              BINARY FORM, PASSED BACK VIA REGISTER 15
*              A PARSE PDE IS THE INPUT AS SHOWN IN THE SAMPLE BELOW
*                       LA    R1,PDL     POINT TO THE PARSE DECRIPTION
*                       BAL   R8,PDLNUM  GO CONVERT TO NUMERICS
*              THE ROUTINE WILL TERMINATE IF IT FINDS NON-NUMERICS
*                 ANY CHARACTERS OTHER THEN 0-9, +, -
*              REGISTERS 1, 2, 5, 6, AND 7 ARE USED
*
PDLNUM   STM   R1,R8,PDLNSAVE SAVE THE REGISTERS
         LH    R2,4(R1)       GET THE STRING ADDRESS
         L     R1,0(R1)       GET THE STRING ADDRESS
         MVI   PDLMINUS,0     CLEAR THE NEGATIVE NUMBER FLAG
         SR    R5,R5          CLEAR THE CHARACTER COUNTER
         SR    R15,R15        CLEAR THE ANSWER
PDLLOOP  LA    R6,0(R5,R1)    POINT TO THIS DIGIT
         LA    R5,1(R5)       GET TO THE NEXT DIGIT
         CR    R5,R2          IS THIS THE END OF THE STRING?
         BH    PDLFINI        YES, EXIT
         SR    R7,R7          CLEAR A WORK REGISTER
         IC    R7,0(R6)       GET THE CHARACTER
         SH    R7,PDLH240     SUBTRACT THE CHARACTER C'0'
         BM    PDLSP          IF NEGATIVE, CHECK SPECIAL CHARACTERS
         MH    R15,PDLH10     IT'S A DIGIT, MULTIPLY PRIOR NUM BY TEN
         AR    R15,R7         ADD ON THE NEW DIGIT
         B     PDLLOOP        AND LOOP FOR MORE
*
*        CHECK FOR SPECIAL CHARACTERS
*
PDLSP    CLI   0(R6),C' '     IS IT A BLANK?
         BE    PDLLOOP        THEN IT'S OK
         CLI   0(R6),C'+'     IS IT A PLUS?
         BE    PDLLOOP        THAT'S ALSO OK
         CLI   0(R6),C'-'     IS IT A MINUS?
         BNE   PDLFINI        NO, JUST QUIT
         MVI   PDLMINUS,1     YES, NOTE IT
         B     PDLLOOP        AND LOOK FOR MORE
*
*        QUIT, AFTER SETTING R15 TO NEGATIVE IF NEEDED
*
PDLFINI  CLI   PDLMINUS,1     WAS A MINUS SIGN FOUND?
         BNE   PDLLEAVE       NO, EXIT
         LNR   R15,R15        YES, MAKE IT NEGATIVE
PDLLEAVE LM    R1,R8,PDLNSAVE RESTORE THE REGISTERS
         BR    R8             RETURN
PDLH10   DC    H'10'
PDLH240  DC    H'240'
         EJECT
*
*        PRNTLINE - GET EACH LINE FOR SYSOUT, THEN COUNT THE LINES
*              OUTPUT HEADERS AND TITLE LINES AS NECESSARY
*
PRNTLINE STM   R1,R8,PRTLSAVE SAVE THE REGISTERS
         TM    SYSOUT+48,X'10' IS SYSOUT OPEN FOR BUSINESS?
         BNO   PRNTTERM       NO, IT'S NOT OPEN, USE VTOCMSG
         CLI   HEADK+1,2     NOHEADING REQUEST?
         BE    PRNTLIN       YES, JUST OUTPUT THE DATA LINE
*
*        DO THE LINE COUNTING
*
         LH    R2,LINECT      GET THE LINE COUNT
         CLI   4(R1),C'1'     IS IT REQUESTING A NEW PAGE?
         BE    PRNTPAGE       YES, DO IT
         CLI   0(R1),C'-'     SKIP 3 LINES
         BE    PRNTSKP3       YES, TRY IT
         CLI   0(R1),C'0'     SKIP 2 LINES?
         BE    PRNTSKP2       YES, DO IT
         B     PRNTSKP1       JUST SKIP ONE
PRNTSKP3 LA    R2,1(R2)       ADD ONE TO THE LINE COUNT
PRNTSKP2 LA    R2,1(R2)       ADD ONE TO THE LINE COUNT
PRNTSKP1 LA    R2,1(R2)       ADD ONE TO THE LINE COUNT
         STH   R2,LINECT      SAVE THE LINE COUNT
         CH    R2,LINEMAX     DOES THIS OVERFLOW  HE PAGE?
         BL    PRNTLIN        NO, JUST PUT OUT THIS LINE
*
*        PRINT OUT THE PAGE HEADER AND ITEM TITLES
*
PRNTPAGE LH    R6,PAGECT      GET THE PAGE COUNT
         LA    R6,1(R6)       ADD ONE TO IT
         STH   R6,PAGECT      THEN STORE IT BACK
         L     R7,PAGEADDR    GET THE PLACE TO PUT THE PAGE
         USING DUMMD,R7       DUMMY DSECT
         CONV  DUMMA,(R6),5   GET THE CHARACTERS
         DROP  R7
         ST    R1,PRNTLSAV    SAVE THE INPUT REG1
         MVI   PRNTHD1H+4,C' '              CLEAR LINE.            016G
         MVC   PRNTHD1H+5(250),PRNTHD1H+4                          016G
         MVC   PRNTHD1H(PRNTHD1L),PRNTHD1C  INIT THE HEAD MESSAGE. 016G
         MVC   PRNTHD1H+24(6),VOLID   MOVE VOLSER.                 016G
         MVC   PRNTHD1H+40(3),ADDR    MOVE DRIVE ADDR.             016G
         TM    VTCPFUNC,X'02'       SUPPOSED TO BE A NO HEADING?   018G
         BO    DIDPHEAD             YES, SKIP HEADINGS.            018G
         TM    VTCPFUNC,X'01'       SUPPOSED TO BE A MAP HEAD? 014G018G
         BNO   PRNTPVOL         NO, PRINT VOL+ADDR+ITEM HEADINGS.  016G
         PUT   SYSOUT,MAPHEADD      NO,PRINT MAP VOL INFO.         014G
         PUT   SYSOUT,MAPTITLD      NO,PRINT MAP TITLE INFO.       014G
         B     DIDPHEAD                                            014G
PRNTPVOL PUT   SYSOUT,PRNTHD2D  OUTPUT THE COMMAND HEADER.         016G
         CLI   SUBSORT+1,2      ARE WE SORTING BY VOLUME?          016G
         BNE   PRNTPITM         NO, SKIP VOL+ADDR HEADER.          016G
         PUT   SYSOUT,PRNTHD1D  OUTPUT THE VOL INFO.               014G
PRNTPITM PUT   SYSOUT,PRNTTITL  OUTPUT THE ITEM TITLES.            016G
DIDPHEAD L     R1,PRNTLSAV    GET THE ORIGINAL LINE                014G
         MVI   4(R1),C'0'     ALWAYS SKIP THE FIRST LINE AFTER NEW PAGE
         LA    R7,5           SET THE LINE COUNT
         STH   R7,LINECT      SAVE IT FOR LATER
PRNTLIN  VTCLEAR OUTWORK       CLEAR A PRINT RECORD                001G
         LH    R6,0(R1)      GET THE RECORD LENGTH
         SH    R6,H5         MINUS 4 FOR PREFIX, 1 FOR EX
         LA    R3,4(R1)      POINT TO THE TEXT
         EX    R6,OUTMOVE2   THEN MOVE IN THE LINE                 007G
         PUT   SYSOUT,OUTWORK      AND FINALLY PRINT IT
         B     PRNTLRET       THEN RETURN
OUTMOVE2 MVC   OUTWORK(0),0(R3)  MOVE LINE TO PRINT.               007G
*
*        SIMPLER CHECKING FOR VTOCMSG OUTPUT
*
PRNTTERM LH    R2,LINECT      GET THE LINE COUNT
         LA    R2,1(R2)       IGNORE CARRIAGE CONTROL
         STH   R2,LINECT      SAVE IT BACK
         LR    R6,R1          SAVE THE ORIGINAL REG 1
         MVI   4(R1),C' '    BLANK THE CARRIAGE CONTROL
         CLI   HEADK+1,2     NOHEADING REQUEST?
         BE    PRNTTLIN       YES, JUST OUTPUT THE DATA LINE
         CH    R2,LINEMAX     NEED A NEW TITLE?
         BL    PRNTTLIN       NO, KEEP GOING
         TM    VTCPFUNC,X'02'   SUPPOSED TO SKIP HEADINGS?         018G
         BO    DIDTHEAD         YES, SKIP TITLES.                  018G
         TM    VTCPFUNC,X'01'   SUPPOSED TO BE A MAP HEAD?     014G018G
         BNO   PRNTTVOL         NO, OUTPUT VTOC HEADING.           014G
         VTOCMSG MAPHEADH       NO,  OUTPUT MAP TITLES.            014G
         VTOCMSG MAPTITLH       NO,  OUTPUT MAP TITLES.            014G
         B     DIDTHEAD                                            014G
PRNTTVOL CLI   SUBSORT+1,2      IS THIS A VOLUME SORT?             014G
         BNE   PRNTTITM         NO, SKIP VOL+ADDR MESSAGE.         014G
         VTOCMSG PRNTHD1H     PUT OUT THE VOL INFO.                016G
PRNTTITM VTOCMSG PRNTTITH     PUT OUT ITEM TITLES.                 016G
DIDTHEAD MVC   LINECT,H2      RESET THE LINE COUNT
PRNTTLIN VTOCMSG 0(R6)        OUTPUT THE PASSED LINE
PRNTLRET LM    R1,R8,PRTLSAVE RESTORE THE REGISTERS
         BR    R8             THEN RETURN
         EJECT
PRTINIT  MVI   FIRSTIM,10    FLAG THE INITIALIZATION AS DONE
         LA    R1,TABTITL    POINT TO THE BUG TABLE
         ST    R1,ATABTITL   LET CHECK KNOW WHERE IT IS
*
*        SET UP THE CHARACTERS FOR TYPE OF SPACE ALLOC.
*
         LH    R2,SPACEK      GET THE SPACE TYPE KEYWORD
         SLA   R2,3           MULTIPLY BY 8
         LA    R2,TABSPACE(R2)  RELOCATE IT
         MVC   SPACTYPE,0(R2) SAVE THE CHARACTERS
*        CLI   PRINTK+1,2     IS THIS NOPRINT?                     020G
*        BE    NOOPEN         YES, SKIP THE OPEN.                  020G
         MVC   SYSOUT(SYSOUTL),SYSOUTC  INITIALIZE THE DCB
         MVI   OPENLIST,X'80' TERMINATE THE LIST
         LA    R1,JFCB       POINT TO THE JFCB
         ST    R1,DCBEXIT    AND PUT THE ADDR IN THE DCB EXIT
         MVI   DCBEXIT,X'87' NOTE IT AS A JFCB EXIT
         LA    R1,DCBEXIT    POINT TO THE EXIT LIST
         LA    R2,SYSOUT     AND TO THE DCB FOR ADDRESSABILITY
         USING IHADCB,R2     TELL THE ASSEMBLER ABOUT IT
         STCM  R1,B'0111',DCBEXLSA  STUFF IT INTO THE DCB
         TM    CHARSPL+6,X'80'  CHARS PER LINE ENTERED?
         BZ    RDJFCB        NO, CONTINUE ALONG
         LA    R1,CHARSPL    YES, POINT TO THE PDL
         BAL   R8,PDLNUM     CONVERT TO A NUMBER
         STH   R15,DCBLRECL  SAVE THE NEW LRECL
         STH   R15,LINELEN   ALSO THE LINE LENGTH
         TM    BLKSZSET+6,X'80'  BLOCKSIZE ENTERED?
         BZ    BLKEQREC      NO, BLOCKSIZE EQUALS LRECL
         LA    R1,BLKSZSET      POINT TO THE PDL
         BAL   R8,PDLNUM     GET THE NUMBER
BLKEQREC STH   R15,DCBPRECL  STUFF IT AWAY
         DROP  R2            FINISHED WITH THE DCB
RDJFCB   RDJFCB ((R2)),MF=(E,OPENLIST)  SEE IF IT'S THERE
         LTR   R15,R15       WAS IT THERE?
         BNZ   NOOPEN        NO, SKIP ALONG
         OPEN  ((R2),OUTPUT),MF=(E,OPENLIST)  OPEN THE PRINT DCB
*
*        INITIALIZE PRINT VARIABLES
*
*        SET LINES/PAGE AND LINESIZE
*
NOOPEN   MVC   LINEMAX,DEFLMAX  SET THE DEFAULT NUMBER OF LINES/PAGE
         TM    LINESPP+6,X'80'     LINES PER PAGE ENTERED?
         BZ    DEFLINPP     NO, SKIP ON
         LA    R1,LINESPP    YES, POINT TO THE PDL
         BAL   R8,PDLNUM     CONVERT TO A NUMBER
         STH   R15,LINEMAX   AND SAVE IT
DEFLINPP MVC   LINECT,LINEMAX SET UP TO PAGE ON THE FIRST WRITE
         TM    CHARSPL+6,X'80'     CHARS PER LINE ENTERED?
         BO    LENSET        YES, USE IT
         MVC   LINELEN,DEFLEN SET UP A DEFAULT LENGTH
         TM    SYSOUT+48,X'10' DO WE USE SYSOUT?
         BO    LENSET         YES, USE WHAT WE'VE GOT
*        GET THE TERMINAL LINE SIZE TO SEE IF IT MAKES SENSE
         GTSIZE
         LTR   R1,R1          SEE IF IT'S GOOD
         BZ    LENSET         NO, JUST A ZERO, KEEP THE DEFAULTS
         BCTR  R1,0           CUT IT DOWN ONE TO AVOID A MESS
         STH   R1,LINELEN     SAVE THIS LENGTH
         LTR   R0,R0          FOR DISPLAYS, IT'S SCREEN SIZE
         BZ    LENSET         KEEP WHAT WE'VE GOT
         TM    LINESPP+6,X'80'  WAS LINES PER PAGE ENTERED?
         BO    LENSET           YES, DON'T OVERRIDE IT
         STH   R0,LINEMAX     AND SAVE THE NEW PAGE LOCATION
LENSET   DS    0H
*
*        SET UP THE PAGE COUNTER
*
PAGEAD   LH    R1,LINELEN     GET THE LENGTH OF THE LINE
*        SH    R1,H10         MINUS TEN CHARACTERS                 031G
*        SH    R1,H22         MINUS 22 CHARACTERS                  037G
         SH    R1,H40         MINUS 40 CHARACTERS                  037G
         LA    R1,PRNTHD2D(R1) THEN RELOCATE IT                    016G
         VTCLEAR PRNTHD2D       CLEAR THE LINE FIRST           001G016G
         VTCLEAR PRNTHD1D       CLEAR THE LINE FIRST               016G
*        MVC   0(4,R1),CPAGE  MOVE IN THE CHARACTERS PAGE          031G
         MVC   0(16,R1),CDATPAG  MOVE IN THE CHARACTERS DATE+PAGE  031G
         L     R14,CVTPTR      GET A(CVT).                         031G
         USING CVTMAP,R14      TELL ASSEMBLER.                     031G
         MVC   5(6,R1),EDMASK1    MOVE EDIT PATTERN.               031G
         ED    5(6,R1),CVTDATE+1  MOVE CURRENT DATE.               031G
         DROP  R14             UNTELL ASSEMBLER.                   031G
*        LA    R1,5(R1)       MOVE OVER 5 MORE                     031G
         LA    R1,17(R1)       MOVE OVER 17 MORE TO ACTUAL PAGE #. 031G
         ST    R1,PAGEADDR    THIS IS THE PLACE
*
*        BUILD THE PRINT HEADER LINE
*
         TM    HEADING+6,X'80' IS A USER HEADING PRESENT
         BO    USERHEAD       YES, USE IT
         MVC   PRNTHD2D(L'DEFHEAD),DEFHEAD  NO, GET A DEFAULT      016G
*
*        ADD THE COMMAND BUFFER TO THE HEADING
*
         LH    R1,LINELEN    GET THE LINE LENGTHE
         SH    R1,H32        MINUS SPACES FOR PAGE, START OF HDR
         BNP   OUTOPEN       IF IT'S SHORT, SKIP ON
         L     R14,ADDRCBUF  POINT TO THE COMMAND BUFFER
         CH    R1,0(R14)     COMPARE LENGTHS
         BL    CBUFBIG       THE COMMAND BUFFER TOO BIG
         LH    R1,0(R14)     GET THE COMMAND BUFFER SIZE
CBUFBIG  SH    R1,H5         MINUS 1 FOR EX, 4 FOR CBUF PREFIX
         EX    R1,MOVEHED    MOVE THE CBUF TO THE DEFAULT HEADER
         B     OUTOPEN        GO SET UP THE PAGE COUNTER
USERHEAD LH    R1,HEADING+4   GET THE LENGTH
         BCTR  R1,0           MINUS ONE FOR THE EX
         L     R2,HEADING     POINT TO THE USER HEAD
         EX    R1,MOVEHEAD    THEN MOVE IT IN
OUTOPEN  DS    0H
*
*        SET UP THE WORK LINE
*
         LH    R1,LINELEN    GET THE LINE LENGTH
         LA    R1,4(R1)      ADD FOUR FOR THE PREFIX
         STH   R1,WORKLINE   OUTPUT TEXT
         STH   R1,PRNTTITH    ITEM TITLES
*
*        SET UP THE MAH HEADING LINE
*
*
*        GET THE PRINT SPECIFICATION
*
         LA    R1,DEFPRNT
         ST    R1,VTPRNTLS   SAVE THE PRINT ITEM LIST ADDRESS
         TM    SUBPRTKY+6,X'80'  WERE ANY ITEMS SET UP
         BE    PRTITSET      NO, THE DEFAULT LIST IS OK
*
*        GET THE ADD, REPLACE, DELETE, AND NEW ITEMS
*        AND BUILD THE NEW LIST
*
*        FIRST CONVERT THE ENTERED TEXT INTO NUMERIC KEYS
*
         LA    R4,SUBPRTIT   POINT TO THE ITEMS
         LA    R5,VTPRNTEN   POINT TO THE OUTPUT KEYS
         LA    R0,VTPRNTEX   POINT TO THE END OF THE LIST
ENTKEY   BAL   R8,GETKEY     GET A KEY
         STC   R15,0(R5)     SAVE IT
         CLI   0(R5),X'0F'   WAS THE CAT KEYWORD SPECIFIED?        021G
         BNE   ENTNCAT       NO.                                   021G
         MVI   LOCAT,1       INDICATE CAT KEYWORD FOUND.           021G
ENTNCAT  DS    0H                                                  021G
         LA    R5,1(R5)      GET TO THE NEXT ONE
         CR    R0,R5         CHECK FOR THE END
         BNH   ENTKEND       IF THAT'S ALL
         ICM   R4,7,9(R4)    GET THE CHAIN POINTER
         BNZ   ENTKEY        AND KEEP GOING IF THERE'S MORE
ENTKEND  DS    0H            THE KEYS ARE ENTERED INTO THE LIST
*
*        MERGE THE ENTERED ITEMS AND THE DEFAULT LIST INTO A NEW LIST
*
         LA    R6,VTPRNTL    POINT TO THE NEW LIST
         ST    R6,VTPRNTLS   SAVE IT'S ADDRESS
         LA    R4,VTPRNTEN   POINT TO THE ENTERED ITEMS
         LA    R2,DEFPRNT    POINT TO THE DEFAULT LIST
         LR    R3,R2         POINT TO THE BEGINNING - NO DEFAULT IF NEW
         L     R1,SUBPRTKY   POINT TO THE KEYWORD
         CLI   0(R1),C'N'    IS THIS A NEW LIST?
         BE    PRTINEW       YES, SKIP PAST DEFAULT COPY
         LA    R3,DEFPRNTE   POINT TO THE END OF THE DEFAULT LIST
*
*        ADD, REPLACE, DELETE - COPY THE DEFAULT LIST
*
PRTICOPY CR    R2,R3         IS THIS THE END OF THE DEFAULT LIST?
         BNL   PRTITSET      YES, END OF PROCESSING FOR PRINT ITEMS
*
*        CHECK FOR ENTERED ITEMS THAT ARE ALSO
*              IN THE DEFAULT LIST.
*
PRTICDLP CLC   0(1,R2),0(R4) IS THIS THE SAME ITEM
         BE    PRTIFND       YES, SEE WHAT TO DO
         LA    R4,1(R4)      NO, GET TO THE NEXT ITEM
         CLI   0(R4),0       WAS THIS THE LAST ENTERED ITEM?
         BNE   PRTICDLP      NO, KEEP LOOKING
         LA    R4,VTPRNTEN   POINT BACK TO THE TOP OF THE LIST
*
*        ADD THIS ITEM TO THE NEW LIST
*
PRTICSKP MVC   0(1,R6),0(R2) MOVE IN THE NEW KEY
         LA    R6,1(R6)      POINT PAST IT
PRTICDEL LA    R2,1(R2)      GO DOWN THE DEFAULT LIST
         B     PRTICOPY      THEN KEEP ON CHECKING
*
*        AN ITEM WAS ENTERED AND WAS IN THE DEFAULT LIST
*        FOR DELETE, JUST DELETE ITEMS
*        FOR ADD AND REPLACE, DELETE ALL BUT THE FIRST ITEM
*              TO AVOID DUPLICATES
*              IF IT IS THE FIRST ITEM, INSERT THE ENTERED LIST
*
PRTIFND  LA    R0,VTPRNTEN   POINT TO THE FIRST ITEM
         CR    R0,R4         COMPARE WITH THE ITEM FOUND
         BH    PRTICDEL      NOT THE FIRST ITEM, DELETE IT
         CLI   0(R1),C'D'    IS THIS DELETE TIME?
         BE    PRTICDEL      THEN JUST DELETE IT
         CLI   0(R1),C'R'    IS THIS A REPLACE?
         BE    PRTIREPA      YES, IGNORE THIS DEFAULT ITEM
*
*        ADD THE DEFAULT ITEM FIRST
*
PRTIASKP MVC   0(1,R6),0(R2) MOVE IN THE NEW KEY
         LA    R6,1(R6)      POINT PAST IT
*
*        MOVE THE ITEMS IN FROM THE ADD OR REPLACE LIST
*
PRTIREPA LA    R2,1(R2)      GET PAST THE DEFAULT LIST ITEM
PRTIREP  LA    R4,1(R4)      GET PAST THE FIRST ENTRY
PRTINEXT CLI   0(R4),0       IS THIS THE LAST ITEM?
         BE    PRTICOPY      YES, SEE ABOUT MORE DEFAULTS
*
*        ADD AN ENTERED ITEM TO THE LIST
*
PRTINSKP MVC   0(1,R6),0(R4) MOVE IN THE NEW KEY
         LA    R6,1(R6)      POINT PAST IT
         B     PRTIREP       GO GET MORE ENTERED ITEMS
*
*        NEW LIST, JUST USE IT AS ENTERED
*
PRTINEW  LA    R1,VTPRNTEN   POINT TO THE ENTERED LIST
         ST    R1,VTPRNTLS   THEN SAVE ITS ADDRESS FOR LATER
PRTITSET DS    0H
*
*        BUILD THE TITLE LINE FOR THE DSNAME FIELDS
*
         VTCLEAR PRNTTITL        BLANK OUT THE TITLE LINE          001G
         MVC   PRNTTITL+1(139),PRNTTITL  SO THE WHOLE THING IS GOOD
         L     R2,VTPRNTLS   GET THE PRINT ITEM LIST
         LA    R1,PRNTTITL    POINT TO THE TITLE LINE
TITLOOP  SR    R6,R6          GET THE RESERVED WORD NUMBER
         IC    R6,0(R2)       FROM THE TOP BYTE
         MH    R6,H12         MULTIPLY BY 12 FOR THE TABLE ENTRIES
         LA    R6,TABTITL(R6) THEN RELOCATE THE MESS
         SR    R7,R7          CLEAR A REGISTER
         IC    R7,0(R6)       GET THE EXECUTE LENGTH
         EX    R7,MOVETIT     MOVE IN THE TITLE
         LA    R1,1(R1,R7)    MOVE THE POINTER OVER
         CLI   0(R2),DSNAME  IS THIS THE DSNAME KEY
         BE    TITDSN        YES, SPECIAL PROCESSING
         LA    R0,PRNTTITL    POINT TO THE BEGINNING AGAIN
         SR    R1,R0          AND FIND THE CURRENT LENGTH
         CH    R1,LINELEN     IS IT TOO LONG?
         BNL   TITOVER        YES, PULL BACK
         AR    R1,R0          NO, KEEP GOING
TITINC   LA    R2,1(R2)            GET THE NEXT CHAIN POINTER
         CLI   0(R2),0       ARE WE DONE?
         BNE   TITLOOP        GO GET MORE TITLES
         B     TITEND         ALL DONE
TITDSN   LR    R6,R1         SAVE THE ADDRESS POINTER
         LA    R1,DSNPLN     POINT TO THE PDL FOR DSN LENGTH
         BAL   R8,PDLNUM     GO TRANSLATE IT
         LTR   R15,R15       WAS IT THERE?
         BP    TITDSN2       YES, USE IT
         LA    R15,44        NO, SET THE DEFAULT
TITDSN2  STH   R15,DSNLENGT  SAVE THE LENGTH
         SH    R15,H9        SUBTRACT THE 9 CHARS MOVED ALREADY
*              MINUS ONE FOR EX, PLUS ONE FOR SPACE
         MVI   0(R6),C' '    GET AN INITIAL BLANK
         EX    R15,DSNBLMOV  MOVE IN THE BLANKS
         LA    R1,1(R15,R6)  RESET THE POINTER ( INCLUDE A SPACE )
         LA    R15,1(R15)    ADD ON THE SPACE CHARACTER
         STH   R15,DSNLENOF  SAVE THE OFFSET
         B     TITINC        ALLOW DSNAME TO OVERFLOW THE LINE
*
*        TITLE RAN OFF THE END, CUT IT OFF
*
TITOVER  SR    R1,R7          SUBTRACT PAST THIS FIELD
         AR    R1,R0          RELOCATE IT
         BCTR  R1,0           THEN GET THE LAST CHARACTER
         MVC   0(9,R1),BLANKS THEN BLANK IT OUT
TITEND   TM    SYSOUT+48,X'10' IS THE DCB OPEN
*        BNO   CKOUTPT       NO, TERMINAL OUTPUT, NO CC            036G
         BNO   VTRET         NO, TERMINAL OUTPUT, NO CC            036G
         MVI   PRNTTITL,C'0'  ALWAYS SKIP A LINE FOR IT
         B     VTRET          RETURN.                              036G
*CKOUTPT  CLI   PURGEK+1,2    JCL OUTPUT THIS RUN?             004G036G
*        BNE   VTRET          YES, SKIP THE OPEN, JUST RETURN      036G
*        MVC   JCLDCB(JCLDCBL),JCLDCBC  INITIALIZE THE DCB     004G036G
*        MVI   OPENLIST,X'80' TERMINATE THE LIST                   036G
*        OPEN  (JCLDCB,OUTPUT),MF=(E,OPENLIST)  OPEN THE DCB   004G036G
*        SR    R2,R2          CLEAR JCLSEQ#.                   006G036G
*        ST    R2,JCLSEQ#                                      006G036G
*        LA    R6,JCLEXECL    INDICATE NUMBER OF JCL STATEMENTS006G036G
*        LA    R7,JCLEXEC     GET A JCL TO DO IEFBR14.         006G036G
*        BAL   R8,PUTEXEC     OUTPUT EXEC AND COMMENT STATEMENT006G036G
*        B     VTRET          RETURN, INITIALIZATION IS DONE       036G
*PUTEXEC  L     R2,JCLSEQ#            GET CURRENT JCL SEQ#.    006G036G
*        AH    R2,H10                ADD 10.                   006G036G
*        ST    R2,JCLSEQ#            SAVE IT.                  006G036G
*        CONV  OUTWORK+72,(R2),8,EDMASK0,COMP0 DO SEQ #        006G036G
*        MVC   OUTWORK(72),0(R7)     MOVE IN STATEMENT.        006G036G
*        PUT   JCLDCB,OUTWORK        OUTPUT STATEMENT.         006G036G
*        LA    R7,72(R7)             GO TO NEXT JCL STATEMENT. 006G036G
*        BCT   R6,PUTEXEC            DO ALL JCL.               006G036G
*        BR    R8                                              006G036G
         EJECT
*
*        ROUTINE TO CONVERT A TEXT DSCB ITEM
*        INTO ITS KEY NUMBER
*        INPUT IS REG 4 - IKJIDENT PTR
*        OUTPUT IS REG 15 - KEY NUMBER
*        ENTRY VIA BAL   R8,GETKEY
*
GETKEY   L     R1,ATABTITL     POINT TO THE TABLE
         LA    R1,12(R1)     POINT TO THE FIRST ENTRY
         LA    R15,1           SET UP THE KEY NUMBER COUNTER
         L     R6,0(R4)      POINT TO THE ENTERED TEXT
         ICM   R3,3,4(R4)    GET THE LENGTH OF THE ENTERED TEXT
         BNP   GETKNOTF      NOT FOUND IF ZERO
         BCTR  R3,0          MINUS ONE FOR THE EX
GETKLOOP LA    R2,4(R1)      POINT TO THE COMPARISON TEXT
         CLI   0(R2),C' '    IS IT HERE?
         BNE   GETKSTD       YES, THIS IS IT
         LA    R2,1(R2)      NO, MOVE OVER ONE MORE
         CLI   0(R2),C' '    IS IT HERE?
         BNE   GETKSTD       YES, THIS IS IT
         LA    R2,1(R2)      NO, MOVE OVER ONE MORE
GETKSTD  EX    R3,GETKCOMP   COMPARE THE KEY TEXT
*        BE    GETKCAT       I FOUND IT                        003G021G
         BE    GETKFND       I FOUND IT                            021G
         LA    R1,12(R1)     GET TO THE NEXT KEY
         LA    R15,1(R15)    INCREMENT THE KEY COUNTER
*        CH    R15,H27       CHECK FOR THE END OF THE TABLE    025G035G
*        CH    R15,H28       CHECK FOR THE END OF THE TABLE    035G040G
         CH    R15,H29       CHECK FOR THE END OF THE TABLE        040G
         BNH   GETKLOOP      NOT YET, KEEP LOOKING
*
*        KEY WAS NOT FOUND, SEND BACK A ZERO
*
GETKNOTF SR    R15,R15       SET UP THE ZERO AND RETURN
         B     GETKFND                                             003G
*GETKCAT C     R3,=F'2'      IS KEYWORD LENGTH OF CAT KEYWORD? 003G021G
*        BNE   GETKFND                                         003G021G
*        CLC   0(3,R6),=C'CAT'  IS THE CAT KEYWORD SPECIFIED?  003G021G
*        BNE   GETKFND                                         003G021G
*        MVI   LOCAT,1       INDICATE CAT KEYWORD FOUND.       003G021G
GETKFND  BR    R8            JUST RETURN
GETKCOMP CLC   0(0,R6),0(R2) EXECUTED TEXT COMPARE
*H27      DC    H'27'                                          025G035G
*H28      DC    H'28'                                          035G040G
H29      DC    H'29'                                               040G
         EJECT
*
*        PROGRAM CONSTANTS
*
ZERO     DC    F'0'
F100     DC    F'100'
F127     DC    F'127'
DEFLMAX  DC    H'60'          DEFAULT LINES PER PAGE
DEFLEN   DC    H'150'         DEFAULT CHARS PER LINE
H2       DC    H'2'
H5       DC    H'5'
*H6       DC    H'6'                                           006G036G
H9       DC    H'9'
*H10      DC    H'10'                                              036G
H12      DC    H'12'
H18      DC    H'18'
*H22      DC    H'22'                                              037G
H40      DC    H'40'                                               037G
H32      DC    H'32'
*F20      DC    F'20'                                          004G036G
CSYS1    DC    C'SYS1.'
CSYSCTL  DC    C'SYSCTL'
MOVETIT  MVC   0(0,R1),3(R6)  MOVE IN THE TITLE
COMPKEY  CLC   0(0,R1),VTFDSN  EXECUTED COMPARE
MOVEHEAD MVC   PRNTHD2D(0),0(R2)                                   016G
MOVEHED  MVC   PRNTHD2D+21(0),4(R14)  MOVE CMD BUF TO DEFAULT HEADER
DSNBLMOV MVC   1(0,R6),0(R6)  BLANK OUT THE DSN SPACE IN THE TITLE
*CPAGE    DC    C'PAGE'                                            031G
CDATPAG  DC    C'DATE YY.DDD PAGE'                                 031G
EDMASK   DC    XL16'40202020202020202020202020202120'
EDMASK0  DC    XL16'F0202020202020202020202020202120'
EDMASK1  DC    XL6'21204B202020'                                   031G
SKIP     DC    C'0'
COMP0    DC    CL16'0000000000000000'
BLANKS   DC    CL16'                '
STARS    DC    CL16'****************'
TABSPACE DC    CL8'KBYTES  '
         DC    CL8'KBYTES'
         DC    CL8'MBYTES'
         DC    CL8'TRKS'
         DC    CL8'CYLS'
*   ALL THE JCL BELOW WAS COMMENTED OUT FOR 036G.                  036G
*JCLEXEC  DC    CL72'//XXXMG   JOB (''XXXX,XXXXXXX,XXXX0000''),'   033G
*        DC    CL72'//     ''TSVTOC - CIS1'','                     033G
*        DC    CL72'//     CLASS=G,MSGCLASS=X,MSGLEVEL=(1,1)'  017G033G
*        DC    CL72'/*MAIN SYSTEM=SYS#'                        033G017G
*        DC    CL72'//VTOCPURG EXEC PGM=IEFBR14'                   004G
*        DC    CL72'//* DELETION JCL WILL BE GENERATED AS FOLLOWS:'
*        DC    CL72'//*   1. SYS1. DATASETS CANNOT BE DELETED.'    006G
*        DC    CL72'//*   2. SYSCTLG DATASETS CANNOT BE DELETED.'  006G
*        DC    CL72'//*   3. DSN = VOLSER CANNOT BE DELETED.'      006G
*        DC    CL72'//*   4. VSAM DATASETS CANNOT BE DELETED.'     006G
*        DC    CL72'//*   5. THE DATASETS MUST MEET CRITERIA ON THE VTOX
               C STATEMENT.'                                       006G
*        DC    CL72'//*      (VTOC LE(TESTX) END(DATA) WOULD ALLOW ONLYX
                DATASETS'                                          006G
*        DC    CL72'//*      PREFIXED "TESTX" AND SUFFIXED "DATA" TO APX
               PEAR ON THE'                                        006G
*        DC    CL72'//*      DELETE JCL.'                          006G
*        DC    CL72'//* IF THE CAT PARAMETER WAS SPECIFIED ON THE VTOC X
               COMMAND THE JCL'                                    006G
*        DC    CL72'//* WILL BE GENERATED AS FOLLOWS:'             006G
*        DC    CL72'//*   1. CAT = C (CATALOGED PROPERLY) DSN AND DISP X
               ONLY.'                                              006G
*        DC    CL72'//*   2. CAT = N (NOT CATALOGED) DSN, DISP, UNIT ANX
               D VOLSER.'                                          006G
*        DC    CL72'//*   3. CAT = W (WRONG - CATALOG POINTS TO ANOTHERX
                VOLSER)'                                           006G
*        DC    CL72'//*              SAME AS CAT = N.'             006G
*        DC    CL72'//*   4. CAT = E (ERROR READING CATALOG ENTRY) SAMEX
                AS CAT = N.'                                       006G
*        DC    CL72'//* IF THE CAT PARAMETER WAS **NOT** SPECIFIED ON TX
               HE VTOC COMMAND'                                    006G
*        DC    CL72'//* THE JCL WILL BE GENERATED AS FOLLOWS:'     006G
*        DC    CL72'//*   1. DSN, DISP, UNIT, AND VOLSER IN ALL JCL'
*        DC    CL72'//*'                                           006G
*JCLEXECL EQU   (*-JCLEXEC)/72                                     006G
*JCLERROR DC    C'//****ERROR** ACCESSING CATALOG PREVIOUS '       004G
*        DC    C' DATASET, VOLSER USED INSTEAD.  '                 004G
*JCLDD    DC    CL72'//DD000000 DD  DSN='                          004G
*JCLDISP  DC    CL72'//             DISP=(OLD,DELETE)'             004G
*JCLVOL   DC    CL23',UNIT=SYSALLDA,VOL=SER='                      004G
*                                                                  004G
*                                                                  004G
*                                                                  004G
*
         PRINT NOGEN
SYSOUTC  DCB   DSORG=PS,DDNAME=VTOCOUT,MACRF=PM,                       X
               RECFM=FBA,LRECL=150,BLKSIZE=1500
*JCLDCBC  DCB   DSORG=PS,DDNAME=JCLOUT,MACRF=PM,                       X
               RECFM=FB,LRECL=80,BLKSIZE=800                       004G
         PRINT GEN
         DS    0H
MADDL    DC    C' ----ADD''L EXT.-'                                014G
MVTOC    DC    C' $$$-VTOC SPACE-'                                 014G
MFREE    DC    C' ----FREE SPACE-'                                 014G
MSPLIT   DC    C' ----SPLIT CYL--'                                 014G
HEXTABEL DC    C'0123456789ABCDEF'      HEX TRANSLATE TABLE.       014G
EDIT6    DC    X'402020202120'          TO EDIT MAP DATA.          014G
EDIT4    DC    X'40202120'              TO EDIT MAP DATA.          018G
         LTORG
*
*        PROGRAM MESSAGES
*
         SPACE 2
MSGTOTC VTCMSG '  TOTALS -  NNNN DATA SETS, MMMMMMMM UUUUUU ALLOC, LLLLX
               LLLL UUUUUU USED '                                  001G
MSGTOTL  EQU   *-MSGTOTC
*DIRFC   VTCMSG ' ----POSSIBLE VTOC DAMAGE DIRF BIT ON'            018G
MDIRFC   VTCMSG ' ----POSSIBLE VTOC DAMAGE DIRF BIT ON VOL XXXXXX' 029G
MDIRFL   EQU   *-MDIRFC                                            018G
*  ADDED FOR BREXX
MSGBREXC VTCMSG '  >>BREXX                                             X
                                              '
MSGBREXL EQU   *-MSGBREXC                                          018G
*  ******
*MIXVTOC  VTCMSG '  ---INDEXED VTOC GAPS NOT CHECKED'         016G 027G
MIXVTOC  VTCMSG '  ---INDEXED VTOC GAPS NOT CHECKED, FREE SPACE NOT SHOX
               WN'                                                 027G
MIXVTOCL EQU   *-MIXVTOC                                           016G
MRESTRC  VTCMSG '  ---LIMIT, LEVEL, ETC. SPECIFIED GAPS NOT CHECKED'
MRESTRL  EQU   *-MRESTRC                                           016G
PRNTHD1C VTCMSG '     VTOC OF VOLUME VVVVVV ON DRIVE XXX'          016G
PRNTHD1L EQU   *-PRNTHD1C                                          016G
MAPSTMC  VTCMSG '---CALL TECH. SERVICES AT 609-695-8283 '  018G031G038G
MAPSTML  EQU   *-MAPSTMC                                           015G
MAPHEADC VTCMSG '    MAP OF VOLUME XXXXXX ON DRIVE XXX UNIT UUUUUU'
MAPHEADL EQU   *-MAPHEADC                                          016G
MAPTITLC VTCMSG '    EXT    FIRST    LAST   LENGTH     DSNAME '    016G
MAPTITLL EQU   *-MAPTITLC                                          016G
MNCCHHC  VTCMSG '  ---CCHH NOT ALLOWED IN PRT KEYWORD USE MAP KEYWORD'
MNCCHHCL EQU   *-MNCCHHC                                           026G
*        ALL MAPVTC MESSAGES BELOW COURTESY OF 018G                018G
MAPVTC1C VTCMSG '    $$$-VTOC SPACE DESCRIPTION'
MAPVTC1L EQU   *-MAPVTC1C
MAPVTC2C VTCMSG '     NUMBR OF CYL -         AVAIL FMT 0 DSCBS -XXXXXX'
MAPVTC2L EQU   *-MAPVTC2C
MAPVTC3C VTCMSG '     TRKS PER CYL -         TRACK LENGTH -     XXXXXX'
MAPVTC3L EQU   *-MAPVTC3C
MAPVTC4C VTCMSG '     DSCB PER TRK -         PDS DIR BLKS/TRK-  XXXXXX'
MAPVTC4L EQU   *-MAPVTC4C
MAPVTC5C VTCMSG '     AVL ALT TRKS -         NEXT ALT CC HH-          '
MAPVTC5L EQU   *-MAPVTC5C
MSGBLC   VTCMSG   '                '                               001G
*
DEFHEAD  DC    CL20'1 VTOC COMMAND V 02 '
*
*        DEFAULT PRINT LIST
*
DEFPRNT  DC    AL1(ALLOC)
         DC    AL1(UNUSED)
         DC    AL1(PCT)
         DC    AL1(EXT)
         DC    AL1(DSORG)
         DC    AL1(RECFM)
         DC    AL1(BLKSZ)
         DC    AL1(LRECL)
         DC    AL1(CDATE)
         DC    AL1(LSTUS)
         DC    AL1(DSNAME)
         DC    AL1(VOLUME)
         DC    AL1(SECQ)
         DC    AL1(SECT)
         DC    AL1(ROUND)
         DC    AL1(PASS)
         DC    AL1(ACTION)
         DC    AL1(TYPE)
         DC    AL1(0)        END OF THE LIST
DEFPRNTE EQU   *
DEFPRNTL EQU   *-DEFPRNT
*
*        TABLE OF PRINT ITEM LENGTHS AND TITLES
*
*        ENTRIES IN THE TABLE FOR EACH FORMATTED ITEM -
*        FIRST BYTE IS FIELD LENGTH FOR OUTPUT ( MINUS ONE FOR EX )
*        SECOND BYTE - X'80' BIT INDICATES A CHARACTER FIELD
*                            THEN BITS 0-7 GIVE VTFMT LENGTH
*                      OTHERWISE IT'S A KEY TO WHICH ROUTINE TO USE
*        THIRD BYTE - OFFSET IN FORMATTED DSCB, VTFMT
*        4-12 TH BYTES, THE TITLE FOR THE FIELD
*
*
TABTITL  DC    XL12'00'  DUMMY ENTRY FOR 0 ADDRESSING
         DC    AL1(8),AL1(128+7),AL1(VTFACTON-VTFMT),CL9' ACTION  '  1
         DC    AL1(6),AL1(128+5),AL1(VTFVOLUM-VTFMT),CL9' VOLUME  '  2
         DC    AL1(5),AL1(000+4),AL1(VTFCREDT-VTFMT),CL9' CDATE   '  3
         DC    AL1(5),AL1(000+4),AL1(VTFLSTAC-VTFMT),CL9' LSTUS   '  4
*   DC    AL1(5),AL1(000+8),AL1(VTFLSTAC-VTFMT),CL9' LSTUS   '  4  012G
         DC    AL1(5),AL1(000+4),AL1(VTFEXPDT-VTFMT),CL9' EXPDT   '  5
         DC    AL1(6),AL1(00+12),AL1(VTFALLOC-VTFMT),CL9'  ALLOC  '  6
         DC    AL1(6),AL1(00+16),AL1(VTFALLOC-VTFMT),CL9' UNUSED  '  7
         DC    AL1(3),AL1(00+20),AL1(VTFALLOC-VTFMT),CL9' PCT     '  8
         DC    AL1(3),AL1(00+24),AL1(VTFNOEPV-VTFMT),CL9' EXT     '  9
         DC    AL1(5),AL1(128+2),AL1(VTFDSORG-VTFMT),CL9' DSORG   ' 10
         DC    AL1(5),AL1(128+4),AL1(VTFRECFM-VTFMT),CL9' RECFM   ' 11
         DC    AL1(5),AL1(00+28),AL1(VTFBLKSZ-VTFMT),CL9' BLKSZ   ' 12
         DC    AL1(5),AL1(00+28),AL1(VTFLRECL-VTFMT),CL9' LRECL   ' 13
         DC    AL1(4),AL1(128+0),AL01(VTFPROT-VTFMT),CL9' PASS    ' 14
         DC    AL1(3),AL1(128+0),AL1(VTFCATLG-VTFMT),CL9' CAT     ' 15
         DC    AL1(4),AL1(128+0),AL1(VTFSECAL-VTFMT),CL9' SECT    ' 16
         DC    AL1(5),AL1(00+28),AL1(VTFSECAM-VTFMT),CL9'  SECQ   ' 17
         DC    AL1(6),AL1(128+5),AL01(VTFUNIT-VTFMT),CL9' UNIT    ' 18
*   DC    AL1(4),AL1(00+36),AL1(VTFVOLUM-VTFMT),CL9' UNIT    ' 18  024G
         DC    AL1(5),AL1(128+0),AL1(VTFROUND-VTFMT),CL9' ROUND   ' 19
         DC    AL1(4),AL1(128+0),AL1(VTFDSTYP-VTFMT),CL9' TYPE    ' 20
         DC    AL1(6),AL1(00+12),AL01(VTFUSED-VTFMT),CL9'   USED  ' 21
*   DC    AL1(8),AL1(00+32),AL1(VTFVOLUM-VTFMT),CL9'   CCHH  ' 22  026G
         DC    AL1(8),AL1(00+08),AL1(VTFVOLUM-VTFMT),CL9'   CCHH  ' 22
         DC    AL1(6),AL1(128+0),AL1(VTFVOLUM-VTFMT),CL9' DUMMY3  ' 23
         DC    AL1(6),AL1(128+0),AL1(VTFVOLUM-VTFMT),CL9' DUMMY4  ' 24
         DC    AL1(6),AL1(128+0),AL1(VTFVOLUM-VTFMT),CL9' DUMMY5  ' 25
         DC    AL1(8),AL1(00+32),AL001(VTFDSN-VTFMT),CL9' DSNAME  ' 26
         DC    AL1(3),AL1(128+0),AL1(VTFUPDAT-VTFMT),CL9' UPDT    ' 27
* THE NEXT LINE WAS ADDED FOR KEY LENGTH.                          035G
         DC    AL1(3),AL1(00+36),AL1(VTFKEYLE-VTFMT),CL9' KEYLE   ' 28
* THE NEXT LINE WAS ADDED FOR OPTCD VALUE.                         040G
         DC    AL1(7),AL1(128+0),AL1(VTFOPTCD-VTFMT),CL9' OPTCD   ' 29
         EJECT
*
*
*        P A R S E   C O N T R O L   L I S T
*
*
         COPY  VTCPARS                                             023G
*
*        DYNAMIC WORK AREA
*
         SPACE 3
PRNTWORK DSECT
         DS    18A            PRINT ROUTINE SAVE AREA
TOTDS    DS    F              TOTAL COUNTER
TOTALLOC DS    F              TOTAL ALLOCATION
TOTUSED  DS    F              TOTAL USED
FTOTDS   DS    F              FINAL TOTAL DATA SETS
FTOTALLC DS    F              FINAL TOTAL ALLOC
FTOTUSED DS    F              FINAL TOTAL USED
PRNTLSAV DS    A
PRINTR8  DS    A
PRNTTOT8 DS    A
PRNGEOM8 DS    A
*OUTPUTR8 DS    A              SAVE RETURN ADDR WHILE IN OUTPUT006G036G
ADDREND  DS    A
PAGEADDR DS    A
OPENLIST DS    2A             PARM LIST FOR OPEN
PDLNSAVE DS    8A             REGISTER SAVE AREA FOR PDLNUM RTN
PRTLSAVE DS    8A             REGISTER SAVE AREA FOR PRNTLINE RTN
LASTKEY  DS    A              ADDRESS OF LAST KEY FOR SUBTOTALS, BREAKS
NUMBREAK DS    H              CHARACTERS TO COMPARE FOR BREAK
NUMTOTAL DS    H              CHARACTERS TO COMPARE FOR SUBTOTALS
GEOMETRY DS    A
         PRINT NOGEN
SYSOUT   DCB   DSORG=PS,DDNAME=VTOCOUT,MACRF=PM,                       X
               RECFM=FBA,LRECL=150,BLKSIZE=1500
SYSOUTL  EQU   *-SYSOUT
*JCLDCB   DCB   DSORG=PS,DDNAME=JCLOUT,MACRF=PM,                       X
               RECFM=FB,LRECL=100,BLKSIZE=6000                 004G036G
*JCLDCBL  EQU   *-JCLDCB                                       004G036G
ENDTOTAL DS    X              PROGRAM SWITCHES
ENTOTOUT EQU   X'80'          THE FINAL TOTALS HAVE BEEN OUTPUT
ENDTONLY EQU   X'10'          NO SUBTOTALS, END TOTALS ONLY
NOBREAK  EQU   X'08'          NO BREAKS
FIRSTIM  DS    X              INITIALIZATION FOR THIS ROUTINE
PDLMINUS DC    X'00'
TOTLAST  DS    X
SPACTYPE DS    CL6          CHARACTERS FOR SPACE UNITS
DSNLENGT DS    H
DSNLENOF DS    H
CHARS    DS    CL16           CONVERSION TO CHARACTERS
MSGWORK  DS    CL256          AREA FOR BUILDING MESSAGES
WORKLINE DS    CL256          AREA FOR DATA SET
PRNTHD2H DS    F
PRNTHD2D DS    CL256          AREA FOR COMMAND VERSION+COMMAND INPUT
PRNTHD1H DS    F
PRNTHD1D DS    CL256          AREA FOR HEADER
PRNTTITH DS    F
PRNTTITL DS    CL256          AREA FOR ITEM TITLES
MAPHEADH DS    F
MAPHEADD DS    CL256          AREA FOR HEADER                      016G
MAPTITLH DS    F                                                   016G
MAPTITLD DS    CL256          AREA FOR HEADER                      016G
MSGBL    DS    CL20           AREA FOR BLANK LINE
OUTWORK  DS    CL256          WORKING AREA FOR OUTPUT
DCBEXIT  DS    F
JFCB     DS    XL176
         SPACE
VTPRNTLS DS    A             PRINT ITEM LIST ADDRESS
VTPRNTL  DS    40C           PRINT ITEM LIST ( IF MODIFIED )
VTPRNTEN DS    40C
VTPRNTEX DS    C
*JCLSEQ#  DS    F                                              004G036G
         SPACE
         DS    0D
LENWORK  EQU   *-PRNTWORK
*
*        VTOC COMMAND COMMON AREA
*
         VTCCOM                                                   023G
         SPACE 3
*
*        FORMATTED DSCB
*
         VTCFMT                                                   023G
         SPACE 3
         VTCPDEDS                                                 023G
         SPACE 3
         DS    0F                                                 014G
EXTDSEC  DSECT                DSECT FOR MAP EXTENTS ENTRY.        014G
EXTADSN  DS    AL4            A(ASSOCIATED DSNAME).               014G
         DS    X                                                  014G
EXTNUM   DS    X              NUMBER OF EXTENT.                   014G
EXTSTRT  DS    H              BEGINNING OF EXTENT.                014G
EXTEND   DS    H              END OF EXTENT.                      014G
EXTLEN   DS    H              L(THIS EXTENT IN TRKS).             014G
EXTL     EQU   *-EXTDSEC      L(EXT ENTRY).                       014G
DUMMD    DSECT
DUMMA    DS    C              DUMMY ENTRY TO USE FOR CONV
         PRINT NOGEN
         DCBD  DSORG=PS,DEVD=DA
         CVT   DSECT=YES                                           031G
         END
