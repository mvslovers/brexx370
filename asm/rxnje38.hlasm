* --------------------------------------------------------------------- 00000133
* NJE38DIR is mainly based on coding of the NJE38 product suite         00000234
*   by Bob Polmanter <wably@sbcglobal.net>                              00000333
* Various parts have been extracted and combined here.                  00000433
* It is called by BREXX and returns information via IRXEXCOM            00000533
* --------------------------------------------------------------------- 00000633
         COPY  REGS                                                     00000700
         GBLA  &WTOMSG      ADDITIONAL WTO TRACING WANTED               00000800
         GBLA  &NJETRC      ADDITIONAL TRACE FOR NJE38 FUNCTIONS        00000931
&WTOMSG  SETA  1            0=NO, 1=YES                                 00001037
&NJETRC  SETA  0            0=NO, 1=YES                                 00001137
* ===================================================================== 00001200
*   DECIDE IF ADDITIONAL REXX VARIABLES SHOULD BE SET FOR TESTING       00001300
* ===================================================================== 00001400
NJE38DIR PPROC TITLE='NJE38 NETSPOOL INTERFACE',PGMREG=(RC,RA)          00001518
* .... INIT PROGRAM ................................................... 00001602
         XC    NCB1,NCB1           Init NCB                             00001702
         LA    R8,NCB1             -> NCB area                          00001802
         RXPUT VAR=NJE38MSG_000000,VALUE='0',VALLEN=6                   00001907
         BLANK MTEXT                                                    00002004
         USING NCB,R8                                                   00002102
* .... GET MODE ....................................................... 00002202
         RXGET VAR=NJEMODE,INTO=NJEMODE,FEX=EXIT                        00002302
         RXPUT VAR=NJE38TEMP,VALFLD=NJEMODE,VALLEN=6                    00002402
         CLC   =CL3'DIR',NJEMODE                                        00002502
         BE    NJEDIR                                                   00002602
         CLC   =CL3'CAN',NJEMODE                                        00002705
         BE    NJECAN                                                   00002807
         CLC   =CL3'INF',NJEMODE                                        00002912
         BE    NJEINF                                                   00003012
         CLC   =CL4'ECHO',NJEMODE                                       00003132
         BE    NJEECHO                                                  00003232
         B     NOPARM                                                   00003303
* --------------------------------------------------------------------- 00003402
* .... MAIN PROGRAM NJE38DIR DISPLAY DIRECTORY ........................ 00003502
* --------------------------------------------------------------------- 00003602
NJEDIR   DS    0H                                                       00003702
         BAL   RE,NJEOPEN                                               00003802
         ST    RF,RXRETURN                                              00003909
         B     *+4(RF)                                                  00004000
         B     RCONT                                                    00004100
         B     EXIT                                                     00004200
RCONT    BAL   RE,NJECONT                                               00004300
         ST    RF,RXRETURN                                              00004409
         B     *+4(RF)                                                  00004500
         B     EXIT      rf=0                                           00004600
         B     EXIT      rf=4                                           00004700
         B     EXIT      rf=8                                           00004800
* --------------------------------------------------------------------- 00004907
* .... MAIN PROGRAM RXNJE38 Purge Entry ............................... 00005007
* --------------------------------------------------------------------- 00005107
NJECAN   DS    0H                                                       00005207
         RXGET VAR=NJEFILE,INTO=FILENO,FEX=NOFILE                       00005308
         BAL   RE,NJEPURGE                                              00005407
         ST    RF,RXRETURN                                              00005509
         B     *+4(RF)                                                  00005607
         B     EXIT      rf=0                                           00005707
         B     EXIT      rf=4                                           00005807
         B     EXIT      rf=8                                           00005907
NOFILE   MVC   MTEXT(L'CMSG16A),CMSG16A                                 00006007
         RXPUT VAR=NJE38MSG_000000,VALUE='1',VALLEN=6                   00006107
         BAL   RE,ISSUE000                                              00006207
         B     EXIT                                                     00006307
* --------------------------------------------------------------------- 00006402
* .... MAIN PROGRAM ECHO .............................................. 00006507
* --------------------------------------------------------------------- 00006602
NJEECHO  MVC   MTEXT(6),=C'ECHO: '                                      00006702
         RXGET VAR=NJETEXT,INTO=NJETEXT,FEX=EXIT                        00006802
         MVC   MTEXT+6(32),NJETEXT                                      00006902
         RXPUT VAR=NJE38MSG_000000,VALUE='1',VALLEN=6                   00007002
         BAL   RE,ISSUE000                                              00007102
         LA    RF,0                                                     00007209
         ST    RF,RXRETURN                                              00007309
         B     EXIT                                                     00007402
* --------------------------------------------------------------------- 00007512
* .... MAIN PROGRAM NJE38DIR DISPLAY File Info ........................ 00007612
* --------------------------------------------------------------------- 00007712
NJEINF   DS    0H                                                       00007814
         RXGET VAR=NJEFILE,INTO=FILENO,FEX=NOFILE                       00007915
         BAL   RE,NJEINFO                                               00008017
         ST    RF,RXRETURN                                              00008112
         B     *+4(RF)                                                  00008212
         B     EXIT      rf=0                                           00008312
         B     EXIT      rf=4                                           00008412
         B     EXIT      rf=8                                           00008512
* --------------------------------------------------------------------- 00008602
* .... NO PARM ERROR .................................................. 00008702
* --------------------------------------------------------------------- 00008802
NOPARM   MVC   MTEXT(29),=C'NO OR WRONG PARM IN NJEMODE: '              00008903
         MVC   MTEXT+29(8),NJEMODE                                      00009003
         RXPUT VAR=NJE38MSG_000000,VALUE='1',VALLEN=6                   00009102
         BAL   RE,ISSUE000                                              00009202
         LA    RF,8                                                     00009309
         ST    RF,RXRETURN                                              00009409
         B     EXIT                                                     00009502
* --------------------------------------------------------------------- 00009611
* ..... EXIT HANDLING ................................................. 00009711
* --------------------------------------------------------------------- 00009811
FMT000   LA    RF,12                                                    00009925
         ST    RF,RXRETURN                                              00010025
         B     EXIT                                                     00010125
U0039    LA    RF,16                                                    00010225
         ST    RF,RXRETURN                                              00010325
EXIT     DS    0H                                                       00010400
         BIN2CHR STRNUM,NJECNT                                          00010500
         RXPUT VAR=NJE38MSG_000000,VALFLD=STRNUM+10,VALLEN=6            00010600
         BIN2CHR STRNUM,RXRETURN                                        00010711
         RXPUT VAR=NJE38RC,VALFLD=STRNUM+12,VALLEN=4                    00010811
         SRETURN RC=(RF)                                                00010900
* --------------------------------------------------------------------- 00011000
*      Open NJE Spool Dataset                                           00011100
* --------------------------------------------------------------------- 00011200
NJEOPEN  DS    0H                                                       00011300
         ST    RE,SAVE02                                                00011408
         BLANK MTEXT                                                    00011500
         XC    NJECNT,NJECNT                                            00011600
         NSIO  TYPE=OPEN,          Open dataset                        x00011700
               NCB=(R8)                                                 00011800
         LTR   R15,R15             Any errors?                          00011900
         BZ    OPEN00              NO                                   00012000
         MVC   MTEXT(25),=CL25'NETSPOOL Open Error'                     00012100
         BAL   RE,ISSUE000        GO STACK THE MESSAGE                  00012200
         LA    RF,4                                                     00012300
         B     OPEN08              ABEND ON VSAM ERROR                  00012400
OPEN00   LA    RF,0                                                     00012500
OPEN08   L     RE,SAVE02                                                00012609
         BR    RE                                                       00012700
* --------------------------------------------------------------------- 00012800
*      Get Content (Close Dataset before preparing Output               00012900
* --------------------------------------------------------------------- 00013000
NJECONT  DS    0H                                                       00013100
         ST    RE,SAVE01                                                00013200
         XR    R5,R5                                                    00013300
*                                                                       00013400
CMD255   EQU   *                                                        00013500
         NSIO  TYPE=CONTENTS,      get directory contents              x00013600
               NCB=(R8)                                                 00013700
         LTR   R15,R15             Any errors?                          00013800
         BZ    CMD260                                                   00013900
         ICM   R5,3,NCBRTNCD       Save error codes for now             00014000
*                                                                       00014100
CMD260   EQU   *         ANALYSE CONTENT                                00014200
         NSIO  TYPE=CLOSE,         Close dataet                        x00014300
               NCB=(R8)                                                 00014400
*                                                                       00014500
         CLM   R5,3,=AL1(12,6)     Were no directory entries returned?  00014600
         BE    CMD280              Correct                              00014700
         CLM   R5,2,=AL1(0)        Were there any error codes?          00014800
         BZ    CMD265              No                                   00014900
         STCM  R5,3,NCBRTNCD       Restore codes for formatting    v110 00015000
         BAL   RE,ISSUE000        Go stack the message                  00015100
         LA    RF,8                                                     00015200
         B     CMD290                                                   00015300
*                                                                       00015400
CMD265   DS    0H                                                       00015500
         BAL   RE,HEADER           CREATE OUTPUT HEADER                 00015600
         L     R6,NCBAREA          -> returned directory entries        00015700
         USING NSDIR,R6                                                 00015800
         SR    R5,R5                                                    00015900
         ICM   R5,3,NCBRECCT       # of returned entries                00016000
*  ... LOOP THROUGH ALL ENTRIES                                         00016100
CMD270   DS    0H                                                       00016200
         BAL   RE,PREPARE                                               00016300
         AH    R6,NCBRECLN         -> next directory entry              00016400
         BCT   R5,CMD270           Loop through entries                 00016500
*  ... Loop End                                                         00016600
         DROP  R6                  NSDIR                                00016700
         LA    RF,0                                                     00016800
         B     CMD290                                                   00016900
*                                                                       00017000
CMD280   EQU   *                   No files queued                      00017100
         BAL   RE,NODIR                                                 00017200
         LA    RF,4                                                     00017300
CMD290   DS    0H                                                       00017400
         L     RE,SAVE01                                                00017500
         BR    RE                                                       00017600
* --------------------------------------------------------------------- 00017700
*      Purge File                                                       00017800
* --------------------------------------------------------------------- 00017900
NJEPURGE DS    0H                                                       00018000
         ST    RE,SAVE01                                                00018100
         MVC   MTEXT,BLANKS        Clear work area                      00018208
         L     R5,FILENO                                                00018308
         LR    R6,R5                                                    00018408
         AIF   ('&NJETRC' NE '1').NOP1                                  00018508
         CVD   R5,DBLE             CONVERT FILE #                       00018608
         UNPK  TWRK(4),DBLE        Add zones                            00018708
         OI    TWRK+3,X'F0'        Fix sign                             00018808
         MVC   MTEXT(19),=C'Purge request for: '                        00018908
         MVC   MTEXT+19(4),TWRK                                         00019008
         BAL   RE,ISSUE000                                              00019108
.NOP1    ANOP                                                           00019208
*   R5  contains starting job number                                    00019306
*   R6  contains ending job number                                      00019406
*                                                                       00019505
         MVC   MTEXT,BLANKS        Clear work area                      00019608
         XC    NCB1,NCB1           Init NCB                             00019705
         LA    R2,NCB1             -> NCB area                          00019805
         USING NCB,R2                                                   00019905
*                                                                       00020005
         NSIO  TYPE=OPEN,          Open dataset                        x00020105
               NCB=(R2)                                                 00020205
         LTR   R15,R15             Any errors?                          00020305
         BZ    CMD320              No                                   00020405
         BAL   R14,FMT000          Display error                        00020505
         B     U0039               Abend on VSAM error                  00020605
*                                                                       00020705
CMD320   EQU   *                                                        00020805
         AIF   ('&WTOMSG' NE '1').NOP2                                  00020908
         WTO   'Open Purge Successful'                                  00021007
.NOP2    ANOP                                                           00021108
         NSIO  TYPE=CONTENTS,      get directory contents              x00021205
               NCB=(R2)                                                 00021305
         LTR   R15,R15             Any errors?                          00021405
         BZ    CMD330              No                                   00021505
         CLC   NCBRTNCD(2),=AL1(12,6) No files in spool?           v110 00021605
         BE    CMD370              True                            v110 00021705
         BAL   R14,FMT000          Display error                        00021805
         B     U0039               Abend on VSAM error                  00021905
*                                                                       00022005
CMD330   EQU   *                                                        00022105
         L     R3,NCBAREA          -> returned directory entries        00022205
         USING NSDIR,R3                                                 00022305
         SR    R4,R4                                                    00022405
         ICM   R4,3,NCBRECCT       # of returned entries                00022505
*                                                                       00022605
CMD340   EQU   *                                                        00022705
         LH    R14,NSID            Get a file number                    00022805
         AIF   ('&WTOMSG' NE '1').NOP3                                  00022908
         WTO   'Fetch Directory Entry'                                  00023007
.NOP3    ANOP                                                           00023108
         CR    R14,R5              Is file number in cancel range?      00023205
         BL    CMD360              N, get next                          00023305
         CR    R14,R6              Is file number in cancel range?      00023405
         BH    CMD360              N, get next                          00023505
*                                                                       00023605
         AIF   ('&WTOMSG' NE '1').NOP4                                  00023708
         WTO   'Directory Entry Match'                                  00023807
.NOP4    ANOP                                                           00023908
         TM    NJFL1,NJF1AUTH      Is issuing user cmd authorized?      00024005
         BO    CMD348              Yes, continue                        00024105
*                                                                       00024205
*-- See if file originated from command issuing user. YES=ALLOW         00024305
*        CLC   CMDLINK,NSINLOC     Is file here on issuer's node?       00024407
*        BNE   CMD344              Nope cant cncl files on other nodes  00024507
*        CLC   CMDVMID,NSINVM      Does userid match issuer's ?         00024607
*        BE    CMD348              Yes, allow the cancel                00024707
*                                                                       00024805
*-- See if file was destined for command issuing user.  YES=ALLOW       00024905
CMD344   EQU   *                                                        00025005
*        CLC   CMDLINK,NSTOLOC     Was file dest = cmd issuer's node?   00025107
*        BNE   CMD360              Nope cant cncl files on other nodes  00025207
*        CLC   CMDVMID,NSTOVM      Does userid match issuer's ?         00025307
*        BNE   CMD360              No, disallow the cancel              00025407
*                                                                       00025505
CMD348   EQU   *                                                        00025605
         AIF   ('&WTOMSG' NE '1').NOP5                                  00025708
         WTO   'Prepare Purge'                                          00025807
.NOP5    ANOP                                                           00025908
         LA    R15,TDATA           -> tag data area                     00026005
         USING TAG,R15                                                  00026105
         STH   R14,TAGID           Save file id in tag data             00026205
         DROP  R15                 TAG                                  00026305
*                                                                       00026405
         NSIO  TYPE=PURGE,         Purge the file by file #            x00026505
               NCB=(R2),                                               x00026605
               TAG=(R15)                                                00026705
         LTR   R15,R15             Any errors?                          00026805
         BZ    CMD350              No                                   00026905
         AIF   ('&WTOMSG' NE '1').NOP6                                  00027008
         WTO   'Some Error(s) during Purge'                             00027107
.NOP6    ANOP                                                           00027208
         CLC   NCBRTNCD(2),=AL1(12,4) Was file # not found in NETSPOOL? 00027305
         BE    CMD360              True                                 00027405
         BAL   R14,FMT000          Display other error                  00027505
         B     U0039               Abend on VSAM error                  00027605
*                                                                       00027705
CMD350   EQU   *                                                        00027805
         AIF   ('&WTOMSG' NE '1').NOP7                                  00027908
         WTO   'Purge Successful'                                       00028007
.NOP7    ANOP                                                           00028108
         OI    NJFL1,NJF1CNCL      Indic at least one file purged       00028205
         LH    R1,NSID             Get the file number                  00028305
         CVD   R1,DBLE             Convert file #                       00028405
         UNPK  TWRK(4),DBLE        Add zones                            00028505
         OI    TWRK+3,X'F0'        Fix sign                             00028605
         MVC   MTEXT,BLANKS        Clear work area                      00028705
         MVC   MTEXT(L'CMSG14),CMSG14  Move msg                         00028805
         MVC   MTEXT+14(4),TWRK    Insert file number                   00028905
         LA    R1,L'CMSG14         Length of message                    00029005
         BAL   R14,ISSUE000        Go stack the message                 00029105
*                                                                       00029205
CMD360   EQU   *                                                        00029305
         LA    R3,NSDIRLN(,R3)     -> next dir entry                    00029405
         BCT   R4,CMD340           Keep scanning for files to purge     00029505
         DROP  R3                  NSDIR                                00029605
*                                                                       00029705
CMD370   EQU   *                                                        00029805
         NSIO  TYPE=CLOSE,         Done with dataset                   x00029905
               NCB=(R2)                                                 00030005
*                                                                       00030105
         LM    R0,R1,NCBAREAL      Get list length and address          00030205
         LTR   R1,R1               Was an area returned?           v110 00030305
         BZ    CMD380              No; avoid freemain              v110 00030405
         XC    NCBAREA,NCBAREA     Clear obsolete ptr                   00030505
         FREEMAIN RU,LV=(0),A=(1)                                       00030605
         DROP  R2                  NCB                                  00030705
*                                                                       00030805
         TM    NJFL1,NJF1CNCL      Were any files successfully purged?  00030905
         BO    XITCMG00            Yes, done with command               00031005
*                                                                       00031105
CMD380   EQU   *                   File was not found                   00031205
         MVC   MTEXT,BLANKS        Clear work area                      00031305
         MVC   MTEXT(L'CMSG15),CMSG15  Move msg                         00031405
         LA    R1,L'CMSG15         Length of message                    00031505
         BAL   R14,ISSUE000        Go stack the message                 00031605
         LA    RF,4                                                     00031709
         B     XITCMG08            Exit command function completed      00031809
*                                                                       00031905
CMD390   EQU   *                   Invalid file # specified             00032005
         MVC   MTEXT,BLANKS        Clear work area                      00032105
         MVC   MTEXT(L'CMSG16),CMSG16  Move msg                         00032205
         LA    R1,L'CMSG16         Length of message                    00032305
         BAL   R14,ISSUE000        Go stack the message                 00032405
         LA    RF,8                                                     00032509
         B     XITCMG08            Exit command function completed      00032609
*                                                                       00032705
XITCMG00 DS    0H                                                       00032806
         LA    RF,0                                                     00032909
XITCMG08 DS    0H                                                       00033009
         L     RE,SAVE01                                                00033100
         BR    RE                                                       00033200
*                                                                       00033332
* --------------------------------------------------------------------- 00033400
*      Pepare Output Line and output it                                 00033500
* --------------------------------------------------------------------- 00033600
PREPARE  DS    0H                                                       00033700
         ST    RE,SAVE02                                                00033800
         MVC   MTEXT,BLANKS        Clear work area                      00033900
         USING NSDIR,R6                                                 00034000
         LH    R1,NSID             Get file id number                   00034100
         CVD   R1,DBLE             Convert                              00034200
         UNPK  MTEXT(4),DBLE                                            00034300
         OI    MTEXT+3,X'F0'                                            00034400
         MVC   VNUM,MTEXT                                               00034500
         MVC   MTEXT+06(8),NSINLOC  Origin node                         00034600
         MVC   MTEXT+15(8),NSINVM   Origin userid                       00034700
         MVC   MTEXT+25(8),NSTOLOC  Destination node                    00034800
         MVC   MTEXT+34(8),NSTOVM   Destination userid                  00034900
         MVC   MTEXT+44(1),NSCLASS  Class                               00035000
*                                                                       00035100
         MVC   MTEXT+45(10),=X'40206B2020206B202120'                    00035200
         L     R1,NSRECNM          Get # of records in file             00035300
         CVD   R1,DBLE             Convert                              00035400
         ED    MTEXT+45(10),DBLE+4 Edit result                          00035500
         BAL   R14,ISSUE000        Go stack the message                 00035600
*                                                                       00035700
         DROP  R6                                                       00035800
         L     RE,SAVE02                                                00035900
         BR    RE                                                       00036000
* --------------------------------------------------------------------- 00036100
*      CREATE HEADER OF OUTPUT                                          00036200
* --------------------------------------------------------------------- 00036300
HEADER   DS    0H                                                       00036400
         ST    RE,SAVE02                                                00036500
*                                                                       00036600
         MVC   MTEXT,BLANKS        Clear work area                      00036700
         MVC   MTEXT(L'CMSG10),CMSG10 Move msg                          00036800
         LA    R1,L'CMSG10         Length of message                    00036900
         BAL   R14,ISSUE000        Go stack the message                 00037000
*                                                                       00037100
         MVC   MTEXT,BLANKS        Clear work area                      00037200
         MVC   MTEXT(L'CMSG11),CMSG11 Move msg                          00037300
         LA    R1,L'CMSG11         Length of message                    00037400
         BAL   R14,ISSUE000        Go stack the message                 00037500
*                                                                       00037600
         L     RE,SAVE02                                                00037700
         BR    RE                                                       00037800
* --------------------------------------------------------------------- 00037900
*      NO DIRECTORY FOUND GE                                            00038000
* --------------------------------------------------------------------- 00038100
NODIR    DS    0H                                                       00038200
         ST    RE,SAVE02                                                00038300
         MVC   MTEXT,BLANKS        Clear work area                      00038400
         MVC   MTEXT(L'CMSG9),CMSG9  Move msg                           00038500
         L     R6,ALINKS           -> first LINKTABL entry         v102 00038600
         LTR   R6,R6                                                    00038739
         BZ    NOLINK                                                   00038839
         USING LINKTABL,R6                                         v102 00038900
         MVC   MTEXT+L'CMSG9(8),LINKID  Plug local node name to msgv102 00039000
         DROP  R6                                                  v102 00039100
NOLINK   LA    R1,L'CMSG9+8        LENGTH OF MESSAGE               V102 00039239
         BAL   R14,ISSUE000        Go stack the message                 00039300
         MVC   MTEXT,BLANKS        Clear work area                      00039400
         MVC   MTEXT(L'CMSG13),CMSG13  Move msg                         00039500
         LA    R1,L'CMSG13         Length of message                    00039600
         BAL   R14,ISSUE000        Go stack the message                 00039700
         L     RE,SAVE02                                                00039800
         BR    RE                                                       00039900
* --------------------------------------------------------------------- 00040000
*      Stack Output Message in REXX Variable                            00040100
* --------------------------------------------------------------------- 00040200
ISSUE000 DS    0H                                                       00040300
         ST    RE,SAVE03                                                00040400
         L     R1,NJECNT                                                00040500
         LA    R1,1(R1)                                                 00040600
         ST    R1,NJECNT                                                00040700
         AIF   ('&WTOMSG' EQ '0').NOWTO                                 00040800
         MVC   WTOMSG,MTEXT                                             00040900
         MVC   WTOFILLR,=AL2(0)  CLEAR NEXT 2 BYTES                     00041000
         MVC   WTOMSGLN,=AL2(80)                                        00041100
         WTO   MF=(E,WTOCB)      SEND MESSAGE TO CONSOLE                00041200
.NOWTO   ANOP                                                           00041300
         RXPUT VAR=NJE38MSG_,INDEX=NJECNT,VALFLD=MTEXT,VALLEN=80        00041400
         L     RE,SAVE03                                                00041500
         BR    RE                                                       00041600
         EJECT                                                          00041700
* --------------------------------------------------------------------- 00041812
*-- Display filenum                                                     00041912
*     Entry:  R3 = file number                                          00042012
*   File is already opened                                              00042112
* --------------------------------------------------------------------- 00042212
NJEINFO  EQU   *                                                        00042314
         ST    RE,SAVE01                                                00042413
         XC    NCB1,NCB1           Init NCB                             00042517
         LA    R2,NCB1             -> NCB area                          00042617
         USING NCB,R2                                                   00042717
*                                                                       00042817
         NSIO  TYPE=OPEN,          Open dataset                        x00042917
               NCB=(R2)                                                 00043017
         LTR   R15,R15             Any errors?                          00043117
         BZ    DNUM020             No                                   00043217
         BAL   R14,FMT000          Display error                        00043317
         B     U0039               Abend on VSAM error                  00043417
*                                                                       00043517
DNUM020  EQU   *                                                        00043617
         L     R3,FILENO                                                00043715
         LA    R6,TDATA            -> tag data area                     00043812
         USING TAG,R6                                                   00043912
         STH   R3,TAGID            Set file # to find                   00044012
*                                                                       00044112
         NSIO  TYPE=FIND,          get directory entry                 x00044212
               NCB=(R2),                                               x00044312
               TAG=(R6)            Where to place tag data              00044412
         LTR   R15,R15             Any errors?                          00044512
         BZ    DNUM040                                                  00044612
         CLC   NCBRTNCD(2),=AL1(12,4) Was specified file id not found?  00044712
         BE    DNUM900             Yes                                  00044812
         BAL   R14,FMT000          Otherwise, display error             00044912
         B     U0039               Abend on VSAM error                  00045012
*                                                                       00045112
DNUM040  EQU   *                                                        00045212
*                                                                       00045312
*                                                                       00045412
DNUM050  EQU   *                                                        00045512
         MVC   MTEXT,BLANKS        Clear work area                      00045619
         LH    R1,TAGID            Get file id number                   00045719
         CVD   R1,DBLE             Convert                              00045819
         UNPK  MTEXT(4),DBLE                                            00045919
         OI    MTEXT+3,X'F0'                                            00046019
         MVC   MTEXT+06(8),TAGINLOC  Origin node                        00046119
         MVC   MTEXT+15(8),TAGINVM   Origin userid                      00046219
         MVC   MTEXT+25(8),TAGTOLOC  Destination node                   00046319
         MVC   MTEXT+34(8),TAGTOVM   Destination userid                 00046419
         MVC   MTEXT+44(1),TAGCLASS  Class                              00046519
*                                                                       00046619
         MVC   MTEXT+45(10),=X'40206B2020206B202120'                    00046719
         L     R1,TAGRECNM         Get # of records in file             00046819
         CVD   R1,DBLE             Convert                              00046919
         ED    MTEXT+45(10),DBLE+4 Edit result                          00047019
*                                                                       00047119
         LA    R1,L'N026C          Length of msg                        00047227
         LM    R14,R15,TAGINTOD  TOD CLOCK UNITS                        00047328
         SRDL  R14,12            MICROSECONDS SINCE JAN 1, 1900         00047428
* .... SUBTRACT date range 1.1.1900 - 1.1.1970 ,                        00047529
         SL    R15,D2EPOCH+4    - Right Half                            00047630
         BC    11,*+6             BRANCH ON NO BORROW                   00047730
         BCTR  R14,R0             -1 FOR BORROW                         00047829
         SL    R14,D2EPOCH      - LEFT HALF                             00047930
         D     R14,=F'1000000'    SECONDS SINCE JAN 1, 1970             00048028
         ST    R15,NJEDATE        Store result                          00048129
         BIN2CHR STRNUM,NJEDATE                                         00048228
         RXPUT VAR=NJE38DATE,VALFLD=STRNUM+6,VALLEN=10                  00048328
*                                  LENGTH OF MSG                        00048427
         BAL   R14,ISSUE000        Stack it                             00048519
*                                                                       00048619
         TM    TAGINDEV,TYPPRT     Is it PRINT data?                    00048719
         BO    DNUM060             Y, don't need to check for NETDATA   00048819
*                                                                       00048919
         L     R15,=A(NJECME)      NETDATA examination routine          00049019
         BALR  R14,R15             Go look for NETDATA                  00049119
         LTR   R15,R15             Check RC                             00049219
         BZ    DNUM070             All is well, we have NETDATA         00049319
*                                                                       00049419
DNUM060  EQU   *                                                        00049519
         OI    NJFL1,NJF1NYET      No NETDATA or PRINT file             00049619
*                                                                       00049719
DNUM070  EQU   *                                                        00049819
         MVC   MTEXT,BLANKS        Clear work area                      00049919
         MVC   MTEXT(L'N026D),N026D  Move model msg                     00050019
         LA    R1,MTEXT+L'N026D    -> end of model                      00050119
         MVC   0(12,R1),TAGNAME    Move file name                       00050219
*                                                                       00050319
         TRT   0(13,R1),BLANK      Look for end of file name            00050419
         LA    R1,1(,R1)           Skip blank                           00050519
         MVC   0(12,R1),TAGTYPE    Move file type                       00050619
*                                                                       00050719
         TRT   0(13,R1),BLANK      Look for end of file type            00050819
         LA    R1,3(,R1)           Skip 3 blanks                        00050919
         MVC   0(11,R1),=C'Type: PRINT'  Assume print data              00051019
         LA    R1,6(,R1)           -> where to put format type          00051119
         TM    TAGINDEV,TYPPRT     Was it actually PRINT type?          00051219
         BO    DNUM080             Yes, display PRINT attr              00051319
*                                                                       00051419
         MVC   0(5,R1),=C'PUNCH'   Assume PUNCH unless its NETDATA      00051519
         TM    NJFL1,NJF1NYET      Was it NETDATA or PRINT file         00051619
         BO    DNUM100             No, display PUNCH attr               00051719
         MVC   0(7,R1),=C'NETDATA' Yes                                  00051819
         B     DNUM200             Display NETDATA attr                 00051919
*                                                                       00052019
*-- Display for flat PRINT type file                                    00052119
*                                                                       00052219
DNUM080  EQU   *                                                        00052319
         LA    R1,7(,R1)           -> end of message                    00052419
         LA    R0,MTEXT            -> Start                             00052519
         SR    R1,R0               compute length of msg                00052619
         BAL   R14,ISSUE000        Stack msg N026D                      00052719
*                                                                       00052819
         MVC   MTEXT,BLANKS        Clear work area                      00052919
         MVC   MTEXT(L'N026E),N026E  Move model msg                     00053019
         LA    R1,MTEXT+L'N026E    -> end of model                      00053119
         MVC   0(8,R1),=C'132/F/PS' Display all we know                 00053219
         LA    R1,8(,R1)           Bump length                          00053319
         BAL   R14,ISSUE000        Stack msg N026E                      00053419
         B     DNUM990             Command function completed           00053519
*                                                                       00053619
*-- Display for flat PUNCH type file                                    00053719
*                                                                       00053819
DNUM100  EQU   *                                                        00053919
         LA    R1,7(,R1)           -> end of message                    00054019
         LA    R0,MTEXT            -> Start                             00054119
         SR    R1,R0               compute length of msg                00054219
         BAL   R14,ISSUE000        Stack msg N026D                      00054319
*                                                                       00054419
         MVC   MTEXT,BLANKS        Clear work area                      00054519
         MVC   MTEXT(L'N026E),N026E  Move model msg                     00054619
         LA    R1,MTEXT+L'N026E    -> end of model                      00054719
         MVC   0(7,R1),=C'80/F/PS' Display all we know                  00054819
         LA    R1,7(,R1)           Bump length                          00054919
         BAL   R14,ISSUE000        Stack msg N026E                      00055019
         B     DNUM990             Command function completed           00055119
*                                                                       00055219
*-- Display for NETDATA files                                           00055319
*                                                                       00055419
DNUM200  EQU   *                                                        00055519
         LA    R1,7(,R1)           -> end of message                    00055619
         LA    R0,MTEXT            -> Start                             00055719
         SR    R1,R0               compute length of msg                00055819
         BAL   R14,ISSUE000        Stack msg N026D                      00055919
*                                                                       00056019
         CLI   FFM,X'00'           Was a file mode present?             00056119
         BE    DNUM300             Its 0, so this is OS NETDATA         00056219
*                                                                       00056319
*-- Display for VM-based NETDATA files                                  00056419
*                                                                       00056519
DNUM210  EQU   *                                                        00056619
         MVC   MTEXT,BLANKS        Clear work area                      00056719
         MVC   MTEXT(L'N026E),N026E  Move model msg                     00056819
         LA    R1,MTEXT+L'N026E    -> end of model                      00056919
*                                                                       00057019
*-- Dont display BLKSIZE for VM files; it is meaningless                00057119
*        L     R4,BLKSIZE          Get the blocksize  value             00057219
*        CVD   R4,DBLE             Convert                              00057319
*        BAL   R14,DSPNUM          Make number displayable              00057419
*        MVI   0(R1),C'/'                                               00057519
*        LA    R1,1(,R1)                                                00057619
*                                                                       00057719
         L     R4,LRECL            Get the lrecl value                  00057819
         CVD   R4,DBLE             Convert                              00057919
         BAL   R14,DSPNUM          Make number displayable              00058019
         MVI   0(R1),C'/'                                               00058119
         LA    R1,1(,R1)                                                00058219
*                                                                       00058319
         BAL   R14,DSPRECFM        Format the RECFM value               00058419
         MVI   0(R1),C'/'                                               00058519
         LA    R1,1(,R1)                                                00058619
*                                                                       00058719
         BAL   R14,DSPORG          Format the DSORG value               00058819
*                                                                       00058919
         LA    R1,4(,R1)           Skip some space in msg               00059019
         MVC   0(5,R1),=C'Size:'                                        00059125
         LA    R1,6(,R1)                                                00059225
         LM    R4,R5,FILESIZE      Get approx file size                 00059319
         LA    R3,8                Max length of file size value        00059419
         LH    R0,FSIZELEN         Get length from NETDATA key          00059519
         SR    R3,R0               Compute # bytes of shift             00059619
         SLA   R3,3                Turn # bytes into # bits             00059719
         SRDL  R4,0(R3)            Right justify the filesize           00059819
         SRL   R5,10               divide by 1024 to get kilobytes      00059919
         LA    R5,1(,R5)           Always round up                      00060019
         CVD   R5,DBLE             Convert                              00060119
         BAL   R14,DSPNUM          Make number displayable              00060219
         MVC   1(2,R1),=C'KB'                                           00060319
         LA    R1,3(,R1)           -> end of msg                        00060419
*                                                                       00060519
         LA    R0,MTEXT            -> Start                             00060619
         SR    R1,R0               compute length of msg                00060719
         BAL   R14,ISSUE000        Stack msg N026E                      00060819
         B     DNUM990                                                  00060919
*                                                                       00061019
*-- Display for OS-based NETDATA files                                  00061119
*                                                                       00061219
DNUM300  EQU   *                                                        00061319
         MVC   MTEXT,BLANKS        Clear work area                      00061419
         MVC   MTEXT(L'N026E),N026E  Move model msg                     00061519
         LA    R1,MTEXT+L'N026E    -> end of model                      00061619
*                                                                       00061719
         L     R4,BLKSIZE          Get the blocksize  value             00061819
         CVD   R4,DBLE             Convert                              00061919
         BAL   R14,DSPNUM          Make number displayable              00062019
         MVI   0(R1),C'/'                                               00062119
         LA    R1,1(,R1)                                                00062219
*                                                                       00062319
         TM    RECFM,DCBRECU       Is this a RECFM=U dataset?           00062419
         BO    DNUM310             Y, don't format LRECL                00062519
*                                                                       00062619
         L     R4,LRECL            Get the lrecl value                  00062719
         CVD   R4,DBLE             Convert                              00062819
         BAL   R14,DSPNUM          Make number displayable              00062919
         MVI   0(R1),C'/'                                               00063019
         LA    R1,1(,R1)                                                00063119
*                                                                       00063219
DNUM310  EQU   *                                                        00063319
         BAL   R14,DSPRECFM        Format the RECFM value               00063419
         MVI   0(R1),C'/'                                               00063519
         LA    R1,1(,R1)                                                00063619
*                                                                       00063719
         BAL   R14,DSPORG          Format the DSORG value               00063819
*                                                                       00063919
         CLI   DSORG,X'02'         Is this DSORG=PO?                    00064019
         BNE   DNUM330             No, skip dir blks                    00064119
         LA    R1,3(,R1)           Skip some space in msg               00064219
         MVC   0(8,R1),=C'DIRBLKS:'                                     00064319
         LA    R1,9(,R1)                                                00064419
         LM    R4,R5,DIRBLKS       Get approx file size                 00064519
         LA    R3,8                Max length of value                  00064619
         LH    R0,DIRBLKLN         Get length from NETDATA key          00064719
         SR    R3,R0               Compute # bytes of shift             00064819
         SLA   R3,3                Turn # bytes into # bits             00064919
         SRDL  R4,0(R3)            Right justify the # dir blks         00065019
         CVD   R5,DBLE             Convert                              00065119
         BAL   R14,DSPNUM          Make number displayable              00065219
*                                                                       00065319
DNUM330  EQU   *                                                        00065419
         LA    R1,3(,R1)           Skip some space in msg               00065519
         MVC   0(5,R1),=C'Size:'                                        00065625
         LA    R1,6(,R1)                                                00065725
         LM    R4,R5,FILESIZE      Get approx file size                 00065819
         LA    R3,8                Max length of file size value        00065919
         LH    R0,FSIZELEN         Get length from NETDATA key          00066019
         SR    R3,R0               Compute # bytes of shift             00066119
         SLA   R3,3                Turn # bytes into # bits             00066219
         SRDL  R4,0(R3)            Right justify the filesize           00066319
         SRL   R5,10               divide by 1024 to get kilobytes      00066419
         LA    R5,1(,R5)           Always round up                      00066519
         CVD   R5,DBLE             Convert                              00066619
         BAL   R14,DSPNUM          Make number displayable              00066719
         MVC   1(2,R1),=C'KB'                                           00066819
         LA    R1,3(,R1)           -> end of msg                        00066919
*                                                                       00067019
         LA    R0,MTEXT            -> Start                             00067119
         SR    R1,R0               compute length of msg                00067219
         BAL   R14,ISSUE000        Stack msg N026E                      00067319
*                                                                       00067419
DNUM350  EQU   *                                                        00067519
         MVC   MTEXT,BLANKS        Clear work area                      00067619
         MVC   MTEXT(L'N026F),N026F  Move model msg                     00067719
         LA    R1,MTEXT+L'N026F    -> end of model                      00067819
         MVC   0(44,R1),DSNAME     Move DSNAME to msg                   00067919
         LA    R1,L'N026F+44       Length of MSG + DSNAME          V110 00068019
         BAL   R14,ISSUE000        Stack msg N026F                      00068119
         B     DNUM990                                                  00068219
*                                                                       00068319
*-- Format a number to remove leading blanks and insert into msg line   00068419
*   Entry:  R1 -> where to place result                                 00068519
*   Exit :  R1 -> next available byte after result                      00068619
*                                                                       00068719
DSPNUM   EQU   *                                                        00068819
         LR    R15,R1              Save msg line position               00068919
         MVC   TWRK(8),=X'4020202020202120'                             00069019
         LA    R1,TWRK+7           -> last digit area                   00069119
         LR    R3,R1               Save a copy                          00069219
         EDMK  TWRK(8),DBLE+4      Edit the number                      00069319
         SR    R3,R1               Compute number's length              00069419
         EX    R3,DSPMVC           Move number to msg line              00069519
         LA    R1,1(R3,R15)        Compute next msg line byte           00069619
         BR    R14                                                      00069719
DSPMVC   MVC   0(0,R15),0(R1)      executed instr                       00069819
*                                                                       00069919
*-- Format the RECFM value                                              00070019
*   Entry:  Field 'RECFM' contains the record format bits               00070119
*   Exit :  R1 -> next available byte after result                      00070219
*                                                                       00070319
DSPRECFM EQU   *                                                        00070419
         MVI   0(R1),C'?'        Assume unknown RECFM              v130 00070519
         TM    RECFM+1,X'03'     Using shortened variable formats? v130 00070619
         BNZ   DSPV              Yes, start with V                 v130 00070719
         TM    RECFM,DCBRECF     FIXED?                                 00070819
         BZ    *+8                                                      00070919
         MVI   0(R1),C'F'                                               00071019
         TM    RECFM,DCBRECV     VARIABLE?                              00071119
         BZ    *+8                                                      00071219
*                                                                       00071319
DSPV     EQU   *                                                   v130 00071419
         MVI   0(R1),C'V'                                               00071519
         TM    RECFM,DCBRECU     UNDEFINED?                             00071619
         BNO   *+8                                                      00071719
         MVI   0(R1),C'U'                                               00071819
         LA    R1,1(,R1)                                                00071919
*                                                                       00072019
         TM    RECFM,DCBRECBR    BLOCKED?                               00072119
         BZ    *+12                                                     00072219
         MVI   0(R1),C'B'                                               00072319
         LA    R1,1(,R1)                                                00072419
*                                                                       00072519
         TM    RECFM,DCBRECSB    SPANNED?                               00072619
         BZ    *+12                                                     00072719
         MVI   0(R1),C'S'                                               00072819
         LA    R1,1(,R1)                                                00072919
         TM    RECFM,DCBRECTO    TRACK OVERFLOW?                        00073019
         BZ    *+12                                                     00073119
         MVI   0(R1),C'T'                                               00073219
         LA    R1,1(,R1)                                                00073319
*                                                                       00073419
         TM    RECFM,DCBRECCA    ASA CONTROL CHAR?                      00073519
         BZ    *+12                                                     00073619
         MVI   0(R1),C'A'                                               00073719
         LA    R1,1(,R1)                                                00073819
         TM    RECFM,DCBRECCM    MACHINE CONTROL CHAR?                  00073919
         BZ    *+12                                                     00074019
         MVI   0(R1),C'M'                                               00074119
         LA    R1,1(,R1)                                                00074219
         BR    R14                                                      00074319
*                                                                       00074419
*-- Format the DSORG value                                              00074519
*   Entry:  Field 'DSORG' contains the organization bits                00074619
*   Exit :  R1 -> next available byte after result                      00074719
*                                                                       00074819
DSPORG   EQU   *                                                        00074919
         MVC   0(2,R1),=C'? '    Assume unknown DSORG                   00075019
         CLC   DSORG,=X'4000'    DSORG=PS?                              00075119
         BNE   *+10                                                     00075219
         MVC   0(2,R1),=C'PS'                                           00075319
         CLC   DSORG,=X'0200'    DSORG=PO?                              00075419
         BNE   *+10                                                     00075519
         MVC   0(2,R1),=C'PO'                                           00075619
         CLC   DSORG,=X'0008'    DSORG=VS?                              00075719
         BNE   *+10                                                     00075819
         MVC   0(2,R1),=C'VS'                                           00075919
         LA    R1,2(,R1)         -> next available byte                 00076019
         BR    R14                                                      00076119
*                                                                       00076219
DNUM900  EQU   *                ** Here if file not found               00076319
         LH    R1,TAGID            Get the file number                  00076419
         CVD   R1,DBLE             Convert file #                       00076519
         UNPK  TWRK(4),DBLE        Add zones                            00076619
         OI    TWRK+3,X'F0'        Fix sign                             00076719
         MVC   MTEXT,BLANKS        Clear work area                      00076819
         MVC   MTEXT(L'NJE027E),NJE027E Move msg                        00076919
         MVC   MTEXT+14(4),TWRK    Insert file number                   00077019
         LA    R1,L'NJE027E        Length of message                    00077119
         BAL   R14,ISSUE000        Go stack the message                 00077219
*                                                                       00077319
*                                                                       00077419
DNUM990  EQU   *                                                        00077512
         LA    R2,NCB1             -> NCB area                          00077612
         NSIO  TYPE=CLOSE,         Close spool dataset                 x00077712
               NCB=(R2)                                                 00077812
         DROP  R6                  TAG                                  00077912
         L     RE,SAVE01                                                00078013
         BR    RE                                                       00078113
* ===================================================================== 00078200
* SHVBLOCK:  LAYOUT OF SHARED-VARIABLE PLIST ELEMENT                    00078300
* ===================================================================== 00078400
         LTORG                                                          00078500
         DS    0F                                                       00078630
D2EPOCH  DC    FL8'2208902400000000'                                    00078730
BLANKS   DC    CL120' '                                                 00078800
NONBLANK DC    64X'FF',X'00',191X'FF'  TR Table to locate nonblank      00078900
BLANK    DC    64X'00',X'FF',191X'00'  TR Table to locate blanks        00079000
CMSG9  DC C'NJE014I  File status for node '                             00079100
CMSG10 DC C'File  Origin   Origin    Dest     Dest'                     00079200
CMSG11 DC C' ID   Node     Userid    Node     Userid    CL  Records'    00079300
CMSG13 DC C'No files queued'                                            00079400
*-- C #### RESPONSE MODELS:                                             00079506
CMSG14   DC    C'NJE015I  FILE(XXXX) PURGED'                            00079606
CMSG15   DC    C'NJE016E  NO ELIGIBLE FILE FOUND'                       00079710
CMSG16   DC    C'NJE017E  INVALID FILE NUMBER SPECIFIED'                00079806
CMSG16A  DC    C'NJE017E  NO FILE NUMBER SPECIFIED'                     00079907
*                                                                       00080014
NJE026I  DC    C'NJE026I  File status for node '                        00080114
N026A  DC C'File  Origin   Origin    Dest     Dest'                     00080214
N026B  DC C' ID   Node     Userid    Node     Userid    CL  Records'    00080314
N026C  DC C'xxxx  xxxxxxxx xxxxxxxx  xxxxxxxx xxxxxxxx  c x,xxx,xxx'    00080414
N026D  DC C'Tagged name: '                                              00080514
N026E  DC C'Attributes: '                                               00080614
N026F  DC C'Origin DSN='                                                00080714
NJE027E  DC    C'NJE027E  File(xxxx) does not exist'  used by E ### too 00080815
         EJECT                                                          00080921
*********************                                                   00081021
*  N J E C M E      *               NJECME determines if NETDATA        00081121
*                   *               exists in a spool file and          00081221
*  Examine NETDATA  *               examines the INMR02 control         00081321
*                   *               record for attributes.              00081421
*********************               Entire CSECT added             v110 00081521
*                                                                       00081621
NJECME   CSECT                                                          00081721
         B     28(,R15)               BRANCH AROUND EYECATCHERS         00081821
         DC    AL1(23)                LENGTH OF EYECATCHERS             00081921
         DC    CL9'NJECME'                                              00082021
         DC    CL9'&SYSDATE'                                            00082121
         DC    CL5'&SYSTIME'                                            00082221
*                                                                       00082321
         STM   R14,R12,12(R13)         Save Regs                        00082421
         LR    R12,R15                 Base                             00082521
         USING NJECME,R12                                               00082621
* !!!    USING NJEWK,R10                                                00082724
         ST    R13,CMESA+4             SAVE prv S.A. ADDR               00082821
         LA    R1,CMESA                -> my save area                  00082921
         ST    R1,8(,R13)              Plug it into prior SA            00083021
         LR    R13,R1                                                   00083121
*                                                                       00083221
*                                                                       00083321
         LA    R0,2                    # of bytes to get                00083421
         BAL   R14,GETBYTES            Get length and desc of segment   00083521
*                                                                       00083621
         TM    1(R1),X'20'             Is this a control record?        00083721
         BZ    XITCME04                No, its not NETDATA              00083821
*                                                                       00083921
         SR    R0,R0                                                    00084021
         IC    R0,0(,R1)               Get segment length byte          00084121
         S     R0,=F'2'                Less 2 we already retrieved      00084221
         BAL   R14,GETBYTES            Get control record               00084321
*                                                                       00084421
         CLC   0(6,R1),INMR01          NETDATA?                         00084521
         BNE   XITCME04                Not NETDATA                      00084621
*                                                                       00084721
         LA    R0,2                    # of bytes to get                00084821
         BAL   R14,GETBYTES            Get length and desc of segment   00084921
*                                                                       00085021
         TM    1(R1),X'20'             Is this a control record?        00085121
         BZ    XITCME04                No, its not NETDATA              00085221
*                                                                       00085321
         SR    R0,R0                                                    00085421
         IC    R0,0(,R1)               Get segment length byte          00085521
         S     R0,=F'2'                Less 2 we already retrieved      00085621
         LR    R3,R0                   Copy length of control record    00085721
         BAL   R14,GETBYTES            Get control record               00085821
*                                                                       00085921
         CLC   0(6,R1),INMR02          NETDATA?                         00086021
         BNE   XITCME04                Not NETDATA                      00086121
*                                                                       00086221
         LA    R15,10                  Len of "INMR02"+file number word 00086321
         AR    R1,R15                  Skip over those fields           00086421
*                                                                       00086521
CTL000   EQU   *                                                        00086621
         SR    R3,R15                  Reduce remaining length          00086721
         BNP   XITCME00                Done with control record         00086821
*                                                                       00086921
*-- Look for supported keys                                             00087021
*                                                                       00087121
         CLC   0(2,R1),INMUTILN        Utility name?                    00087221
         BE    UTL000                  Y                                00087321
         CLC   0(2,R1),INMSIZE         File size?                       00087421
         BE    FSZ000                  Y                                00087521
         CLC   0(2,R1),INMDSORG        DSORG?                           00087621
         BE    DSG000                  Y                                00087721
         CLC   0(2,R1),INMBLKSZ        BLKSIZE?                         00087821
         BE    BLK000                  Y                                00087921
         CLC   0(2,R1),INMLRECL        LRECL?                           00088021
         BE    LRL000                  Y                                00088121
         CLC   0(2,R1),INMRECFM        RECFM?                           00088221
         BE    RFM000                  Y                                00088321
         CLC   0(2,R1),INMFFM          File mode number?                00088421
         BE    FFM000                  Y                                00088521
         CLC   0(2,R1),INMDIR          # directory blocks?              00088621
         BE    DIR000                  Y                                00088721
         CLC   0(2,R1),INMDSNAM        DSNAME?                          00088821
         BE    DSN000                  Y                                00088921
*                                                                       00089021
*-- Skip over unsupported/unrecognized keys                             00089121
*                                                                       00089221
         LA    R1,2(,R1)               Skip over unrecognized key       00089321
         LA    R15,2                   Remaining length adjust          00089421
         SR    R0,R0                   Clear for IC                     00089521
         ICM   R0,3,0(R1)              Get # value                      00089621
         LA    R1,2(,R1)               Skip over # value                00089721
         LA    R15,2(,R15)             Remaining length adjust          00089821
         BZ    CTL000                  # was 0; no lengths              00089921
         SR    R14,R14                 Clear for ICM                    00090021
*                                                                       00090121
CTL020   EQU   *                                                        00090221
         ICM   R14,3,0(R1)             Get length field                 00090321
         LA    R1,2(R14,R1)            Skip over length and data        00090421
         LA    R15,2(R14,R15)          Remaining length adjust          00090521
         BCT   R0,CTL020               Do next len/data field pair      00090621
         B     CTL000                  Resume                           00090721
*                                                                       00090821
*-- Handle keys we support                                              00090921
*                                                                       00091021
*- Utility name                                                         00091121
UTL000   EQU   *                       Get utility name                 00091221
         MVC   UTLNAME,BLANKS          Init receiving field             00091321
         LA    R6,UTLNAME              -> receiving field               00091421
         B     KEY000                  Go handle the key                00091521
*                                                                       00091621
*- File size                                                            00091721
FSZ000   EQU   *                       File size                        00091821
         MVC   FSIZELEN,4(R1)          Save length of file size value   00091921
         LA    R6,FILESIZE             -> receiving field               00092021
         B     KEY000                  Go handle the key                00092121
*                                                                       00092221
*- DSORG                                                                00092321
DSG000   EQU   *                       DSORG                            00092421
         LA    R6,DSORG                -> receiving field               00092521
         B     KEY000                  Go handle the key                00092621
*- BLKSIZE                                                              00092721
BLK000   EQU   *                       BLKSIZE                          00092821
         LA    R6,BLKSIZE              -> receiving field               00092921
         B     KEY000                  Go handle the key                00093021
*                                                                       00093121
*- LRECL                                                                00093221
LRL000   EQU   *                       LRECL                            00093321
         LA    R6,LRECL                -> receiving field               00093421
         B     KEY000                  Go handle the key                00093521
*                                                                       00093621
*- RECFM                                                                00093721
RFM000   EQU   *                       RECFM                            00093821
         LA    R6,RECFM                -> receiving field               00093921
         B     KEY000                  Go handle the key                00094021
*                                                                       00094121
*- # directory blocks                                                   00094221
DIR000   EQU   *                       File size                        00094321
         MVC   DIRBLKLN,4(R1)          Save length of dirblk siz value  00094421
         LA    R6,DIRBLKS              -> receiving field               00094521
         B     KEY000                  Go handle the key                00094621
*                                                                       00094721
*- FFM                                                                  00094821
FFM000   EQU   *                       File mode number                 00094921
         LA    R6,FFM                  -> receiving field               00095021
         B     KEY000                  Go handle the key                00095121
*                                                                       00095221
*- DSNAME                                                               00095321
DSN000   EQU   *                       DSNAME                           00095421
         MVC   DSNAME,BLANKS           Init receiving field             00095521
         LA    R6,DSNAME               -> receiving field               00095621
         LA    R1,2(,R1)               Skip over key                    00095721
         LA    R15,2                   Remaining length adjust          00095821
         SR    R0,R0                   Clear for IC                     00095921
         ICM   R0,3,0(R1)              Get # value                      00096021
         LA    R1,2(,R1)               Skip over # value                00096121
         LA    R15,2(,R15)             Remaining length adjust          00096221
         BZ    CTL000                  # was 0; no lengths              00096321
         SR    R14,R14                 Clear for ICM                    00096421
*                                                                       00096521
DSN020   EQU   *                                                        00096621
         ICM   R14,3,0(R1)             Get length field                 00096721
         BCT   R14,DSN030              Adjust for execute               00096821
         MVC   0(0,R6),2(R1)           executed instr                   00096921
DSN030   EX    R14,*-6                 Move name to receiving field     00097021
         LA    R1,3(R14,R1)            Skip over length and data        00097121
         LA    R15,3(R14,R15)          Remaining length adjust          00097221
         LA    R6,1(R14,R6)            Bump to next qualifier area      00097321
         MVI   0(R6),C'.'              Add qualifier dot                00097421
         LA    R6,1(,R6)               -> next qualifier area           00097521
         BCT   R0,DSN020               Do next len/data field pair      00097621
         BCTR  R6,0                    -> last byte of DSNAME           00097721
         MVI   0(R6),C' '              Remove trailing dot              00097821
         BCTR  R6,0                    -> prior to trailing '.'         00097921
         LA    R0,DSNAME               -> start of DSNAME               00098021
         SR    R6,R0                   Compute DSN length               00098121
         STH   R6,DSNAMELN             Save it                          00098221
         B     CTL000                  get next key                     00098321
*                                                                       00098421
*-- Common routine to break part key/#/len/data elements that have #=1  00098521
*                                                                       00098621
KEY000   EQU   *                                                        00098721
         LA    R1,4(,R1)               Skip over key, #                 00098821
         LA    R15,4                   Remaining length accum           00098921
         SR    R5,R5                   Clear for IC                     00099021
         ICM   R5,3,0(R1)              Get length of name               00099121
         BCT   R5,KEY010               Adjust for execute               00099221
         MVC   0(0,R6),2(R1)           executed instr                   00099321
KEY010   EX    R5,*-6                  Move name to receiving field     00099421
         LA    R1,3(R5,R1)             -> next text unit key            00099521
         LA    R15,3(R5,R15)           Accum length adjustment          00099621
         B     CTL000                  Get next key                     00099721
*                                                                       00099821
*                                                                       00099921
*                                                                       00100021
GETBYTES EQU   *                                                        00100121
         ST    R14,SV14GB              Save return addr                 00100221
         L     R5,GBREM                Get # bytes remaining in rec buf 00100321
         LA    R1,BUFF                 Point to getbytes buffer         00100421
         ST    R1,GBPOS                Set starting position            00100521
         LR    R8,R0                   Requested amount to R8           00100621
*                                                                       00100721
*                                                                       00100821
GB010    EQU   *                                                        00100921
         LTR   R5,R5                   Any bytes left in phy record?    00101021
         BP    GB040                   Yes, use them first              00101121
*                                                                       00101221
         LA    R2,NCB1                 -> active NCB for spool file     00101321
         NSIO  TYPE=GET,               TAG data contains file #        x00101421
               NCB=(R2),               Get a spool file record         x00101521
               AREA=REC,               -> where to place record        x00101621
               EODAD=XITCME04          if EOF, then NETDATA isnt valid  00101721
         LTR   R15,R15                 Any errors?                      00101821
         BZ    GB020                   No                               00101921
*        BAL   R14,FMT000              Display error                    00102024
*        B     U0039                   And abend                        00102124
*                                                                       00102221
GB020    EQU   *                                                        00102321
         LA    R5,80                   Num bytes read                   00102421
         LA    R1,REC                  -> input buffer                  00102521
*                                                                       00102621
GB030    EQU   *                                                        00102721
         ST    R1,GBRPS                Reset start of record position   00102821
*                                                                       00102921
GB040    EQU   *                                                        00103021
         LR    R7,R8                   Assume requested amt avail       00103121
         LR    R15,R8                  Same                             00103221
*                                                                       00103321
         CR    R5,R8                   Have more than we need?          00103421
         BH    GB050                   Yes, just move requested         00103521
         LR    R7,R5                   Else move entire rec             00103621
         LR    R15,R5                  Same                             00103721
*                                                                       00103821
GB050    EQU   *                                                        00103921
         LR    R0,R7                   Save copy of length to move      00104021
         L     R14,GBPOS               -> GB buffer position            00104121
         L     R6,GBRPS                -> input record curr position    00104221
         MVCL  R14,R6                  Move                             00104321
*                                                                       00104421
         ST    R14,GBPOS               New GB position                  00104521
         ST    R6,GBRPS                New phys record curr position    00104621
*                                                                       00104721
         SR    R5,R0                   Reduce bytes left in phy record  00104821
         SR    R8,R0                   Reduce requested amt             00104921
         BP    GB010                   We need more, go get it          00105021
*                                                                       00105121
         ST    R5,GBREM                Remember whats left in phy rec   00105221
*                                                                       00105321
         LA    R1,BUFF                 Point to the requested bytes     00105421
         L     R14,SV14GB              Load  return addr                00105521
         BR    R14                     Return from getbytes             00105621
*                                                                       00105721
         LTORG                                                          00105821
*                                                                       00105921
INMR01   DC    C'INMR01'               Control record                   00106021
INMR02   DC    C'INMR02'               Control record                   00106121
*                                                                       00106221
*- Keys                                                                 00106321
INMUTILN DC    X'1028'                 Utility name                     00106421
INMSIZE  DC    X'102C'                 File size in bytes               00106521
INMDSORG DC    X'003C'                 DSORG                            00106621
INMLRECL DC    X'0042'                 LRECL                            00106721
INMBLKSZ DC    X'0030'                 BLKSIZE                          00106821
INMRECFM DC    X'0049'                 RECFM                            00106921
INMDSNAM DC    X'0002'                 DSNAME                           00107021
INMDIR   DC    X'000C'                 # directory blocks               00107121
INMFFM   DC    X'102D'                 File mode number                 00107221
*                                                                       00107321
*                                                                       00107421
*                                                                       00107521
*-- Exit NETDATA examination processing                                 00107621
*                                                                       00107721
*                                                                       00107821
XITCME00 EQU   *                                                        00107921
         SR    R15,R15             Set RC=0; NETDATA info filled        00108021
         B     XITCME                                                   00108121
*                                                                       00108221
XITCME04 EQU   *                                                        00108321
         LA    R15,4               Set RC=4; File contains no NETDATA   00108421
*                                                                       00108521
XITCME   EQU   *                                                        00108621
         L     R13,4(,R13)         -> prev s.a.                         00108721
         ST    R15,16(,R13)        Set RC                               00108821
         LM    R14,R12,12(R13)     Reload callers regs                  00108921
         BR    R14                 Return with RC                       00109021
*                                                                       00109121
         LTORG                                                          00109221
         SHVCB DSECT                                                    00109300
         WORKAREA                                                       00109400
RXRETURN DS    A                   Return Code before returning to REXX 00109509
FILENO   DS    A                   FILE NUMBER OF A REQUEST             00109609
STRDPCK  DS    0D                  STRPACK ON DOUBLE FOR BIN CONVERSION 00109707
STRPACK  DS    PL8                 MAXIMUM 999,999,999,999,999          00109800
STRNUM   DS    CL16                BIN2CHR DESTINATION FIELD            00109900
NJECNT   DS    A                   Index Count of Output                00110000
NJEMODE  DS    CL8                 REQUESTED MODE                       00110101
NJETEXT  DS    CL32                INPUT LINE                           00110202
IRXADDR  DS    A                                                        00110300
NCB1     DS    XL48                NCB                                  00110400
         DS    CL64                Filler                               00110500
MTEXT    DS    CL120               Message text work area               00110600
VARN     DS    0CL10                                                    00110700
VAR      DC    CL6'NJEMSG'                                              00110800
VNUM     DS    CL4                                                      00110900
DBLE     DS    D                   Work area                            00111000
TWRK     DS    2D                  WORK AREA                            00111106
ALINKS   DS    A  16                -> first LINKTABL entry             00111200
* .... Info Area                                                        00111314
FILESIZE DS    2F                     File size in bytes           v110 00111414
DIRBLKS  DS    2F                     #directory blocks            v110 00111514
BLKSIZE  DS    F                      BLKSIZE                      v110 00111614
LRECL    DS    F                      LRECL                        v110 00111714
RECFM    DS    XL2                    RECFM                        v110 00111814
DSORG    DS    XL2                    DSORG                        v110 00111914
FFM      DS    C                      File mode number             v110 00112014
         DS    X                      available                    v110 00112114
DIRBLKLN DS    H                      Length of dir blks value     v110 00112214
FSIZELEN DS    H                      Length of file size value    v110 00112314
DSNAMELN DS    H                      Length of DSNAME             v110 00112414
DSNAME   DS    CL44                   DSNAME                       v110 00112514
* .... WTO Area                                                         00112614
WTOCB    DS    0H                                                       00112700
WTOMSGLN DS    AL2                                                      00112800
WTOFILLR DS    CL2                                                      00112900
WTOMSG   DS    CL80                                                     00113000
WTOMSEND DS    0H                                                       00113100
* .... Time to Convert TOD Clock Time                                   00113227
NJEDATE  DS    F                                                        00113328
*                                                                       00113406
TDATA    DS    0XL108                                                   00113506
BLNKDASH DS    0CL256                                                   00113606
ASIDTAB  DS    24CL24                                                   00113706
TARGET   DS    X                   CODE FOR WHO GETS THE CMD RESPONSE   00113806
TGTUSER  EQU   0                    REMOTE USER                         00113906
TGTCONS  EQU   4                    MVS SYSTEM CONSOLE                  00114006
TYPPRT   EQU   X'40'                PRT dev                             00114120
*                                                                       00114206
NJFL1    DS    X                   FLAG BITS                            00114306
NJF1MULT EQU   X'80'   1... ....    MULTI-FILE CANCEL COMMAND           00114406
NJF1CNCL EQU   X'40'   .1.. ....    A FILE WAS DELETED BY COMMAND       00114506
NJF1DATH EQU   X'20'   ..1. ....    AT LEAST 1 AUTH USER DISPLAYED      00114606
NJF1NYET EQU   X'10'   ...1 ....    NO USABLE NETDATA FOUND IN FILEV110 00114706
NJF1VSER EQU   X'02'   .... ..1.    NETSPOOL VSAM ERROR OCCURRED        00114806
NJF1AUTH EQU   X'01'   .... ...1    CMD ISSUER IS CMD AUTHORIZED        00114906
*                                                                       00115006
SV14GB   DS    A                      R14 save area                v110 00115122
GBREM    DC    F'0'                   # bytes remaining in phys recv110 00115222
GBPOS    DS    A                      -> cur position in BUFF      v110 00115322
GBRPS    DS    A                      -> cur position in phys rec  v110 00115422
*                                                                  v110 00115522
UTLNAME  DS    CL8                    Utility name                 v110 00115622
*                                                                       00115722
REC      DS    CL80                   Physical record              v110 00115822
TRTAB    DS    0CL256                 Translate table              v120 00115922
BUFF     DS    CL256                  GB buffer containing key datav110 00116022
*                                                                       00116122
NJESA    DS    18F                     NJECMX OS save area              00116222
CMCSA    DS    18F                     NJECMC OS save area         v110 00116322
CMGSA    DS    18F                     NJECMG OS save area         v110 00116422
CMHSA    DS    18F                     NJECMH OS save area         v110 00116522
CMESA    DS    18F                     NJECME OS save area         v110 00116622
BALRSAVE DS    16F                     Local rtns register save         00116722
*                                                                       00116822
         DS    0D                      Force doubleword size            00116922
         SHVCB DEFINE                                                   00117000
*                                                                       00117106
         WORKEND                                                        00117200
         COPY  NETSPOOL                                                 00117300
         COPY  TAG                                                      00117406
         COPY  LINKTABL                                                 00117500
         DCBD  DSORG=PS,DEVD=DA                                         00117614
         END                                                            00117700
