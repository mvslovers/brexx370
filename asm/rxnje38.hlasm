* --------------------------------------------------------------------- 00000133
* NJE38DIR is based on coding of the NJE38 product suite                00000233
*   by Bob Polmanter <wably@sbcglobal.net>                              00000333
* Various parts have been extracted and combined here.                  00000433
* It is called by BREXX and returns information via IRXEXCOM            00000533
* --------------------------------------------------------------------- 00000633
         COPY  REGS                                                     00000700
         GBLA  &WTOMSG      ADDITIONAL WTO TRACING WANTED               00000800
         GBLA  &NJETRC      ADDITIONAL TRACE FOR NJE38 FUNCTIONS        00000931
&WTOMSG  SETA  0            0=NO, 1=YES                                 00001031
&NJETRC  SETA  0            0=NO, 1=YES                                 00001131
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
         USING LINKTABL,R6                                         v102 00038700
         MVC   MTEXT+L'CMSG9(8),LINKID  Plug local node name to msgv102 00038800
         DROP  R6                                                  v102 00038900
         LA    R1,L'CMSG9+8        Length of message               v102 00039000
         BAL   R14,ISSUE000        Go stack the message                 00039100
         MVC   MTEXT,BLANKS        Clear work area                      00039200
         MVC   MTEXT(L'CMSG13),CMSG13  Move msg                         00039300
         LA    R1,L'CMSG13         Length of message                    00039400
         BAL   R14,ISSUE000        Go stack the message                 00039500
         L     RE,SAVE02                                                00039600
         BR    RE                                                       00039700
* --------------------------------------------------------------------- 00039800
*      Stack Output Message in REXX Variable                            00039900
* --------------------------------------------------------------------- 00040000
ISSUE000 DS    0H                                                       00040100
         ST    RE,SAVE03                                                00040200
         L     R1,NJECNT                                                00040300
         LA    R1,1(R1)                                                 00040400
         ST    R1,NJECNT                                                00040500
         AIF   ('&WTOMSG' EQ '0').NOWTO                                 00040600
         MVC   WTOMSG,MTEXT                                             00040700
         MVC   WTOFILLR,=AL2(0)  CLEAR NEXT 2 BYTES                     00040800
         MVC   WTOMSGLN,=AL2(80)                                        00040900
         WTO   MF=(E,WTOCB)      SEND MESSAGE TO CONSOLE                00041000
.NOWTO   ANOP                                                           00041100
         RXPUT VAR=NJE38MSG_,INDEX=NJECNT,VALFLD=MTEXT,VALLEN=80        00041200
         L     RE,SAVE03                                                00041300
         BR    RE                                                       00041400
         EJECT                                                          00041500
* --------------------------------------------------------------------- 00041612
*-- Display filenum                                                     00041712
*     Entry:  R3 = file number                                          00041812
*   File is already opened                                              00041912
* --------------------------------------------------------------------- 00042012
NJEINFO  EQU   *                                                        00042114
         ST    RE,SAVE01                                                00042213
         XC    NCB1,NCB1           Init NCB                             00042317
         LA    R2,NCB1             -> NCB area                          00042417
         USING NCB,R2                                                   00042517
*                                                                       00042617
         NSIO  TYPE=OPEN,          Open dataset                        x00042717
               NCB=(R2)                                                 00042817
         LTR   R15,R15             Any errors?                          00042917
         BZ    DNUM020             No                                   00043017
         BAL   R14,FMT000          Display error                        00043117
         B     U0039               Abend on VSAM error                  00043217
*                                                                       00043317
DNUM020  EQU   *                                                        00043417
         L     R3,FILENO                                                00043515
         LA    R6,TDATA            -> tag data area                     00043612
         USING TAG,R6                                                   00043712
         STH   R3,TAGID            Set file # to find                   00043812
*                                                                       00043912
         NSIO  TYPE=FIND,          get directory entry                 x00044012
               NCB=(R2),                                               x00044112
               TAG=(R6)            Where to place tag data              00044212
         LTR   R15,R15             Any errors?                          00044312
         BZ    DNUM040                                                  00044412
         CLC   NCBRTNCD(2),=AL1(12,4) Was specified file id not found?  00044512
         BE    DNUM900             Yes                                  00044612
         BAL   R14,FMT000          Otherwise, display error             00044712
         B     U0039               Abend on VSAM error                  00044812
*                                                                       00044912
DNUM040  EQU   *                                                        00045012
*                                                                       00045112
*                                                                       00045212
DNUM050  EQU   *                                                        00045312
         MVC   MTEXT,BLANKS        Clear work area                      00045419
         LH    R1,TAGID            Get file id number                   00045519
         CVD   R1,DBLE             Convert                              00045619
         UNPK  MTEXT(4),DBLE                                            00045719
         OI    MTEXT+3,X'F0'                                            00045819
         MVC   MTEXT+06(8),TAGINLOC  Origin node                        00045919
         MVC   MTEXT+15(8),TAGINVM   Origin userid                      00046019
         MVC   MTEXT+25(8),TAGTOLOC  Destination node                   00046119
         MVC   MTEXT+34(8),TAGTOVM   Destination userid                 00046219
         MVC   MTEXT+44(1),TAGCLASS  Class                              00046319
*                                                                       00046419
         MVC   MTEXT+45(10),=X'40206B2020206B202120'                    00046519
         L     R1,TAGRECNM         Get # of records in file             00046619
         CVD   R1,DBLE             Convert                              00046719
         ED    MTEXT+45(10),DBLE+4 Edit result                          00046819
*                                                                       00046919
         LA    R1,L'N026C          Length of msg                        00047027
         LM    R14,R15,TAGINTOD  TOD CLOCK UNITS                        00047128
         SRDL  R14,12            MICROSECONDS SINCE JAN 1, 1900         00047228
* .... SUBTRACT date range 1.1.1900 - 1.1.1970 ,                        00047329
         SL    R15,D2EPOCH+4    - Right Half                            00047430
         BC    11,*+6             BRANCH ON NO BORROW                   00047530
         BCTR  R14,R0             -1 FOR BORROW                         00047629
         SL    R14,D2EPOCH      - LEFT HALF                             00047730
         D     R14,=F'1000000'    SECONDS SINCE JAN 1, 1970             00047828
         ST    R15,NJEDATE        Store result                          00047929
         BIN2CHR STRNUM,NJEDATE                                         00048028
         RXPUT VAR=NJE38DATE,VALFLD=STRNUM+6,VALLEN=10                  00048128
*                                  LENGTH OF MSG                        00048227
         BAL   R14,ISSUE000        Stack it                             00048319
*                                                                       00048419
         TM    TAGINDEV,TYPPRT     Is it PRINT data?                    00048519
         BO    DNUM060             Y, don't need to check for NETDATA   00048619
*                                                                       00048719
         L     R15,=A(NJECME)      NETDATA examination routine          00048819
         BALR  R14,R15             Go look for NETDATA                  00048919
         LTR   R15,R15             Check RC                             00049019
         BZ    DNUM070             All is well, we have NETDATA         00049119
*                                                                       00049219
DNUM060  EQU   *                                                        00049319
         OI    NJFL1,NJF1NYET      No NETDATA or PRINT file             00049419
*                                                                       00049519
DNUM070  EQU   *                                                        00049619
         MVC   MTEXT,BLANKS        Clear work area                      00049719
         MVC   MTEXT(L'N026D),N026D  Move model msg                     00049819
         LA    R1,MTEXT+L'N026D    -> end of model                      00049919
         MVC   0(12,R1),TAGNAME    Move file name                       00050019
*                                                                       00050119
         TRT   0(13,R1),BLANK      Look for end of file name            00050219
         LA    R1,1(,R1)           Skip blank                           00050319
         MVC   0(12,R1),TAGTYPE    Move file type                       00050419
*                                                                       00050519
         TRT   0(13,R1),BLANK      Look for end of file type            00050619
         LA    R1,3(,R1)           Skip 3 blanks                        00050719
         MVC   0(11,R1),=C'Type: PRINT'  Assume print data              00050819
         LA    R1,6(,R1)           -> where to put format type          00050919
         TM    TAGINDEV,TYPPRT     Was it actually PRINT type?          00051019
         BO    DNUM080             Yes, display PRINT attr              00051119
*                                                                       00051219
         MVC   0(5,R1),=C'PUNCH'   Assume PUNCH unless its NETDATA      00051319
         TM    NJFL1,NJF1NYET      Was it NETDATA or PRINT file         00051419
         BO    DNUM100             No, display PUNCH attr               00051519
         MVC   0(7,R1),=C'NETDATA' Yes                                  00051619
         B     DNUM200             Display NETDATA attr                 00051719
*                                                                       00051819
*-- Display for flat PRINT type file                                    00051919
*                                                                       00052019
DNUM080  EQU   *                                                        00052119
         LA    R1,7(,R1)           -> end of message                    00052219
         LA    R0,MTEXT            -> Start                             00052319
         SR    R1,R0               compute length of msg                00052419
         BAL   R14,ISSUE000        Stack msg N026D                      00052519
*                                                                       00052619
         MVC   MTEXT,BLANKS        Clear work area                      00052719
         MVC   MTEXT(L'N026E),N026E  Move model msg                     00052819
         LA    R1,MTEXT+L'N026E    -> end of model                      00052919
         MVC   0(8,R1),=C'132/F/PS' Display all we know                 00053019
         LA    R1,8(,R1)           Bump length                          00053119
         BAL   R14,ISSUE000        Stack msg N026E                      00053219
         B     DNUM990             Command function completed           00053319
*                                                                       00053419
*-- Display for flat PUNCH type file                                    00053519
*                                                                       00053619
DNUM100  EQU   *                                                        00053719
         LA    R1,7(,R1)           -> end of message                    00053819
         LA    R0,MTEXT            -> Start                             00053919
         SR    R1,R0               compute length of msg                00054019
         BAL   R14,ISSUE000        Stack msg N026D                      00054119
*                                                                       00054219
         MVC   MTEXT,BLANKS        Clear work area                      00054319
         MVC   MTEXT(L'N026E),N026E  Move model msg                     00054419
         LA    R1,MTEXT+L'N026E    -> end of model                      00054519
         MVC   0(7,R1),=C'80/F/PS' Display all we know                  00054619
         LA    R1,7(,R1)           Bump length                          00054719
         BAL   R14,ISSUE000        Stack msg N026E                      00054819
         B     DNUM990             Command function completed           00054919
*                                                                       00055019
*-- Display for NETDATA files                                           00055119
*                                                                       00055219
DNUM200  EQU   *                                                        00055319
         LA    R1,7(,R1)           -> end of message                    00055419
         LA    R0,MTEXT            -> Start                             00055519
         SR    R1,R0               compute length of msg                00055619
         BAL   R14,ISSUE000        Stack msg N026D                      00055719
*                                                                       00055819
         CLI   FFM,X'00'           Was a file mode present?             00055919
         BE    DNUM300             Its 0, so this is OS NETDATA         00056019
*                                                                       00056119
*-- Display for VM-based NETDATA files                                  00056219
*                                                                       00056319
DNUM210  EQU   *                                                        00056419
         MVC   MTEXT,BLANKS        Clear work area                      00056519
         MVC   MTEXT(L'N026E),N026E  Move model msg                     00056619
         LA    R1,MTEXT+L'N026E    -> end of model                      00056719
*                                                                       00056819
*-- Dont display BLKSIZE for VM files; it is meaningless                00056919
*        L     R4,BLKSIZE          Get the blocksize  value             00057019
*        CVD   R4,DBLE             Convert                              00057119
*        BAL   R14,DSPNUM          Make number displayable              00057219
*        MVI   0(R1),C'/'                                               00057319
*        LA    R1,1(,R1)                                                00057419
*                                                                       00057519
         L     R4,LRECL            Get the lrecl value                  00057619
         CVD   R4,DBLE             Convert                              00057719
         BAL   R14,DSPNUM          Make number displayable              00057819
         MVI   0(R1),C'/'                                               00057919
         LA    R1,1(,R1)                                                00058019
*                                                                       00058119
         BAL   R14,DSPRECFM        Format the RECFM value               00058219
         MVI   0(R1),C'/'                                               00058319
         LA    R1,1(,R1)                                                00058419
*                                                                       00058519
         BAL   R14,DSPORG          Format the DSORG value               00058619
*                                                                       00058719
         LA    R1,4(,R1)           Skip some space in msg               00058819
         MVC   0(5,R1),=C'Size:'                                        00058925
         LA    R1,6(,R1)                                                00059025
         LM    R4,R5,FILESIZE      Get approx file size                 00059119
         LA    R3,8                Max length of file size value        00059219
         LH    R0,FSIZELEN         Get length from NETDATA key          00059319
         SR    R3,R0               Compute # bytes of shift             00059419
         SLA   R3,3                Turn # bytes into # bits             00059519
         SRDL  R4,0(R3)            Right justify the filesize           00059619
         SRL   R5,10               divide by 1024 to get kilobytes      00059719
         LA    R5,1(,R5)           Always round up                      00059819
         CVD   R5,DBLE             Convert                              00059919
         BAL   R14,DSPNUM          Make number displayable              00060019
         MVC   1(2,R1),=C'KB'                                           00060119
         LA    R1,3(,R1)           -> end of msg                        00060219
*                                                                       00060319
         LA    R0,MTEXT            -> Start                             00060419
         SR    R1,R0               compute length of msg                00060519
         BAL   R14,ISSUE000        Stack msg N026E                      00060619
         B     DNUM990                                                  00060719
*                                                                       00060819
*-- Display for OS-based NETDATA files                                  00060919
*                                                                       00061019
DNUM300  EQU   *                                                        00061119
         MVC   MTEXT,BLANKS        Clear work area                      00061219
         MVC   MTEXT(L'N026E),N026E  Move model msg                     00061319
         LA    R1,MTEXT+L'N026E    -> end of model                      00061419
*                                                                       00061519
         L     R4,BLKSIZE          Get the blocksize  value             00061619
         CVD   R4,DBLE             Convert                              00061719
         BAL   R14,DSPNUM          Make number displayable              00061819
         MVI   0(R1),C'/'                                               00061919
         LA    R1,1(,R1)                                                00062019
*                                                                       00062119
         TM    RECFM,DCBRECU       Is this a RECFM=U dataset?           00062219
         BO    DNUM310             Y, don't format LRECL                00062319
*                                                                       00062419
         L     R4,LRECL            Get the lrecl value                  00062519
         CVD   R4,DBLE             Convert                              00062619
         BAL   R14,DSPNUM          Make number displayable              00062719
         MVI   0(R1),C'/'                                               00062819
         LA    R1,1(,R1)                                                00062919
*                                                                       00063019
DNUM310  EQU   *                                                        00063119
         BAL   R14,DSPRECFM        Format the RECFM value               00063219
         MVI   0(R1),C'/'                                               00063319
         LA    R1,1(,R1)                                                00063419
*                                                                       00063519
         BAL   R14,DSPORG          Format the DSORG value               00063619
*                                                                       00063719
         CLI   DSORG,X'02'         Is this DSORG=PO?                    00063819
         BNE   DNUM330             No, skip dir blks                    00063919
         LA    R1,3(,R1)           Skip some space in msg               00064019
         MVC   0(8,R1),=C'DIRBLKS:'                                     00064119
         LA    R1,9(,R1)                                                00064219
         LM    R4,R5,DIRBLKS       Get approx file size                 00064319
         LA    R3,8                Max length of value                  00064419
         LH    R0,DIRBLKLN         Get length from NETDATA key          00064519
         SR    R3,R0               Compute # bytes of shift             00064619
         SLA   R3,3                Turn # bytes into # bits             00064719
         SRDL  R4,0(R3)            Right justify the # dir blks         00064819
         CVD   R5,DBLE             Convert                              00064919
         BAL   R14,DSPNUM          Make number displayable              00065019
*                                                                       00065119
DNUM330  EQU   *                                                        00065219
         LA    R1,3(,R1)           Skip some space in msg               00065319
         MVC   0(5,R1),=C'Size:'                                        00065425
         LA    R1,6(,R1)                                                00065525
         LM    R4,R5,FILESIZE      Get approx file size                 00065619
         LA    R3,8                Max length of file size value        00065719
         LH    R0,FSIZELEN         Get length from NETDATA key          00065819
         SR    R3,R0               Compute # bytes of shift             00065919
         SLA   R3,3                Turn # bytes into # bits             00066019
         SRDL  R4,0(R3)            Right justify the filesize           00066119
         SRL   R5,10               divide by 1024 to get kilobytes      00066219
         LA    R5,1(,R5)           Always round up                      00066319
         CVD   R5,DBLE             Convert                              00066419
         BAL   R14,DSPNUM          Make number displayable              00066519
         MVC   1(2,R1),=C'KB'                                           00066619
         LA    R1,3(,R1)           -> end of msg                        00066719
*                                                                       00066819
         LA    R0,MTEXT            -> Start                             00066919
         SR    R1,R0               compute length of msg                00067019
         BAL   R14,ISSUE000        Stack msg N026E                      00067119
*                                                                       00067219
DNUM350  EQU   *                                                        00067319
         MVC   MTEXT,BLANKS        Clear work area                      00067419
         MVC   MTEXT(L'N026F),N026F  Move model msg                     00067519
         LA    R1,MTEXT+L'N026F    -> end of model                      00067619
         MVC   0(44,R1),DSNAME     Move DSNAME to msg                   00067719
         LA    R1,L'N026F+44       Length of MSG + DSNAME          V110 00067819
         BAL   R14,ISSUE000        Stack msg N026F                      00067919
         B     DNUM990                                                  00068019
*                                                                       00068119
*-- Format a number to remove leading blanks and insert into msg line   00068219
*   Entry:  R1 -> where to place result                                 00068319
*   Exit :  R1 -> next available byte after result                      00068419
*                                                                       00068519
DSPNUM   EQU   *                                                        00068619
         LR    R15,R1              Save msg line position               00068719
         MVC   TWRK(8),=X'4020202020202120'                             00068819
         LA    R1,TWRK+7           -> last digit area                   00068919
         LR    R3,R1               Save a copy                          00069019
         EDMK  TWRK(8),DBLE+4      Edit the number                      00069119
         SR    R3,R1               Compute number's length              00069219
         EX    R3,DSPMVC           Move number to msg line              00069319
         LA    R1,1(R3,R15)        Compute next msg line byte           00069419
         BR    R14                                                      00069519
DSPMVC   MVC   0(0,R15),0(R1)      executed instr                       00069619
*                                                                       00069719
*-- Format the RECFM value                                              00069819
*   Entry:  Field 'RECFM' contains the record format bits               00069919
*   Exit :  R1 -> next available byte after result                      00070019
*                                                                       00070119
DSPRECFM EQU   *                                                        00070219
         MVI   0(R1),C'?'        Assume unknown RECFM              v130 00070319
         TM    RECFM+1,X'03'     Using shortened variable formats? v130 00070419
         BNZ   DSPV              Yes, start with V                 v130 00070519
         TM    RECFM,DCBRECF     FIXED?                                 00070619
         BZ    *+8                                                      00070719
         MVI   0(R1),C'F'                                               00070819
         TM    RECFM,DCBRECV     VARIABLE?                              00070919
         BZ    *+8                                                      00071019
*                                                                       00071119
DSPV     EQU   *                                                   v130 00071219
         MVI   0(R1),C'V'                                               00071319
         TM    RECFM,DCBRECU     UNDEFINED?                             00071419
         BNO   *+8                                                      00071519
         MVI   0(R1),C'U'                                               00071619
         LA    R1,1(,R1)                                                00071719
*                                                                       00071819
         TM    RECFM,DCBRECBR    BLOCKED?                               00071919
         BZ    *+12                                                     00072019
         MVI   0(R1),C'B'                                               00072119
         LA    R1,1(,R1)                                                00072219
*                                                                       00072319
         TM    RECFM,DCBRECSB    SPANNED?                               00072419
         BZ    *+12                                                     00072519
         MVI   0(R1),C'S'                                               00072619
         LA    R1,1(,R1)                                                00072719
         TM    RECFM,DCBRECTO    TRACK OVERFLOW?                        00072819
         BZ    *+12                                                     00072919
         MVI   0(R1),C'T'                                               00073019
         LA    R1,1(,R1)                                                00073119
*                                                                       00073219
         TM    RECFM,DCBRECCA    ASA CONTROL CHAR?                      00073319
         BZ    *+12                                                     00073419
         MVI   0(R1),C'A'                                               00073519
         LA    R1,1(,R1)                                                00073619
         TM    RECFM,DCBRECCM    MACHINE CONTROL CHAR?                  00073719
         BZ    *+12                                                     00073819
         MVI   0(R1),C'M'                                               00073919
         LA    R1,1(,R1)                                                00074019
         BR    R14                                                      00074119
*                                                                       00074219
*-- Format the DSORG value                                              00074319
*   Entry:  Field 'DSORG' contains the organization bits                00074419
*   Exit :  R1 -> next available byte after result                      00074519
*                                                                       00074619
DSPORG   EQU   *                                                        00074719
         MVC   0(2,R1),=C'? '    Assume unknown DSORG                   00074819
         CLC   DSORG,=X'4000'    DSORG=PS?                              00074919
         BNE   *+10                                                     00075019
         MVC   0(2,R1),=C'PS'                                           00075119
         CLC   DSORG,=X'0200'    DSORG=PO?                              00075219
         BNE   *+10                                                     00075319
         MVC   0(2,R1),=C'PO'                                           00075419
         CLC   DSORG,=X'0008'    DSORG=VS?                              00075519
         BNE   *+10                                                     00075619
         MVC   0(2,R1),=C'VS'                                           00075719
         LA    R1,2(,R1)         -> next available byte                 00075819
         BR    R14                                                      00075919
*                                                                       00076019
DNUM900  EQU   *                ** Here if file not found               00076119
         LH    R1,TAGID            Get the file number                  00076219
         CVD   R1,DBLE             Convert file #                       00076319
         UNPK  TWRK(4),DBLE        Add zones                            00076419
         OI    TWRK+3,X'F0'        Fix sign                             00076519
         MVC   MTEXT,BLANKS        Clear work area                      00076619
         MVC   MTEXT(L'NJE027E),NJE027E Move msg                        00076719
         MVC   MTEXT+14(4),TWRK    Insert file number                   00076819
         LA    R1,L'NJE027E        Length of message                    00076919
         BAL   R14,ISSUE000        Go stack the message                 00077019
*                                                                       00077119
*                                                                       00077219
DNUM990  EQU   *                                                        00077312
         LA    R2,NCB1             -> NCB area                          00077412
         NSIO  TYPE=CLOSE,         Close spool dataset                 x00077512
               NCB=(R2)                                                 00077612
         DROP  R6                  TAG                                  00077712
         L     RE,SAVE01                                                00077813
         BR    RE                                                       00077913
* ===================================================================== 00078000
* SHVBLOCK:  LAYOUT OF SHARED-VARIABLE PLIST ELEMENT                    00078100
* ===================================================================== 00078200
         LTORG                                                          00078300
         DS    0F                                                       00078430
D2EPOCH  DC    FL8'2208902400000000'                                    00078530
BLANKS   DC    CL120' '                                                 00078600
NONBLANK DC    64X'FF',X'00',191X'FF'  TR Table to locate nonblank      00078700
BLANK    DC    64X'00',X'FF',191X'00'  TR Table to locate blanks        00078800
CMSG9  DC C'NJE014I  File status for node '                             00078900
CMSG10 DC C'File  Origin   Origin    Dest     Dest'                     00079000
CMSG11 DC C' ID   Node     Userid    Node     Userid    CL  Records'    00079100
CMSG13 DC C'No files queued'                                            00079200
*-- C #### RESPONSE MODELS:                                             00079306
CMSG14   DC    C'NJE015I  FILE(XXXX) PURGED'                            00079406
CMSG15   DC    C'NJE016E  NO ELIGIBLE FILE FOUND'                       00079510
CMSG16   DC    C'NJE017E  INVALID FILE NUMBER SPECIFIED'                00079606
CMSG16A  DC    C'NJE017E  NO FILE NUMBER SPECIFIED'                     00079707
*                                                                       00079814
NJE026I  DC    C'NJE026I  File status for node '                        00079914
N026A  DC C'File  Origin   Origin    Dest     Dest'                     00080014
N026B  DC C' ID   Node     Userid    Node     Userid    CL  Records'    00080114
N026C  DC C'xxxx  xxxxxxxx xxxxxxxx  xxxxxxxx xxxxxxxx  c x,xxx,xxx'    00080214
N026D  DC C'Tagged name: '                                              00080314
N026E  DC C'Attributes: '                                               00080414
N026F  DC C'Origin DSN='                                                00080514
NJE027E  DC    C'NJE027E  File(xxxx) does not exist'  used by E ### too 00080615
         EJECT                                                          00080721
*********************                                                   00080821
*  N J E C M E      *               NJECME determines if NETDATA        00080921
*                   *               exists in a spool file and          00081021
*  Examine NETDATA  *               examines the INMR02 control         00081121
*                   *               record for attributes.              00081221
*********************               Entire CSECT added             v110 00081321
*                                                                       00081421
NJECME   CSECT                                                          00081521
         B     28(,R15)               BRANCH AROUND EYECATCHERS         00081621
         DC    AL1(23)                LENGTH OF EYECATCHERS             00081721
         DC    CL9'NJECME'                                              00081821
         DC    CL9'&SYSDATE'                                            00081921
         DC    CL5'&SYSTIME'                                            00082021
*                                                                       00082121
         STM   R14,R12,12(R13)         Save Regs                        00082221
         LR    R12,R15                 Base                             00082321
         USING NJECME,R12                                               00082421
* !!!    USING NJEWK,R10                                                00082524
         ST    R13,CMESA+4             SAVE prv S.A. ADDR               00082621
         LA    R1,CMESA                -> my save area                  00082721
         ST    R1,8(,R13)              Plug it into prior SA            00082821
         LR    R13,R1                                                   00082921
*                                                                       00083021
*                                                                       00083121
         LA    R0,2                    # of bytes to get                00083221
         BAL   R14,GETBYTES            Get length and desc of segment   00083321
*                                                                       00083421
         TM    1(R1),X'20'             Is this a control record?        00083521
         BZ    XITCME04                No, its not NETDATA              00083621
*                                                                       00083721
         SR    R0,R0                                                    00083821
         IC    R0,0(,R1)               Get segment length byte          00083921
         S     R0,=F'2'                Less 2 we already retrieved      00084021
         BAL   R14,GETBYTES            Get control record               00084121
*                                                                       00084221
         CLC   0(6,R1),INMR01          NETDATA?                         00084321
         BNE   XITCME04                Not NETDATA                      00084421
*                                                                       00084521
         LA    R0,2                    # of bytes to get                00084621
         BAL   R14,GETBYTES            Get length and desc of segment   00084721
*                                                                       00084821
         TM    1(R1),X'20'             Is this a control record?        00084921
         BZ    XITCME04                No, its not NETDATA              00085021
*                                                                       00085121
         SR    R0,R0                                                    00085221
         IC    R0,0(,R1)               Get segment length byte          00085321
         S     R0,=F'2'                Less 2 we already retrieved      00085421
         LR    R3,R0                   Copy length of control record    00085521
         BAL   R14,GETBYTES            Get control record               00085621
*                                                                       00085721
         CLC   0(6,R1),INMR02          NETDATA?                         00085821
         BNE   XITCME04                Not NETDATA                      00085921
*                                                                       00086021
         LA    R15,10                  Len of "INMR02"+file number word 00086121
         AR    R1,R15                  Skip over those fields           00086221
*                                                                       00086321
CTL000   EQU   *                                                        00086421
         SR    R3,R15                  Reduce remaining length          00086521
         BNP   XITCME00                Done with control record         00086621
*                                                                       00086721
*-- Look for supported keys                                             00086821
*                                                                       00086921
         CLC   0(2,R1),INMUTILN        Utility name?                    00087021
         BE    UTL000                  Y                                00087121
         CLC   0(2,R1),INMSIZE         File size?                       00087221
         BE    FSZ000                  Y                                00087321
         CLC   0(2,R1),INMDSORG        DSORG?                           00087421
         BE    DSG000                  Y                                00087521
         CLC   0(2,R1),INMBLKSZ        BLKSIZE?                         00087621
         BE    BLK000                  Y                                00087721
         CLC   0(2,R1),INMLRECL        LRECL?                           00087821
         BE    LRL000                  Y                                00087921
         CLC   0(2,R1),INMRECFM        RECFM?                           00088021
         BE    RFM000                  Y                                00088121
         CLC   0(2,R1),INMFFM          File mode number?                00088221
         BE    FFM000                  Y                                00088321
         CLC   0(2,R1),INMDIR          # directory blocks?              00088421
         BE    DIR000                  Y                                00088521
         CLC   0(2,R1),INMDSNAM        DSNAME?                          00088621
         BE    DSN000                  Y                                00088721
*                                                                       00088821
*-- Skip over unsupported/unrecognized keys                             00088921
*                                                                       00089021
         LA    R1,2(,R1)               Skip over unrecognized key       00089121
         LA    R15,2                   Remaining length adjust          00089221
         SR    R0,R0                   Clear for IC                     00089321
         ICM   R0,3,0(R1)              Get # value                      00089421
         LA    R1,2(,R1)               Skip over # value                00089521
         LA    R15,2(,R15)             Remaining length adjust          00089621
         BZ    CTL000                  # was 0; no lengths              00089721
         SR    R14,R14                 Clear for ICM                    00089821
*                                                                       00089921
CTL020   EQU   *                                                        00090021
         ICM   R14,3,0(R1)             Get length field                 00090121
         LA    R1,2(R14,R1)            Skip over length and data        00090221
         LA    R15,2(R14,R15)          Remaining length adjust          00090321
         BCT   R0,CTL020               Do next len/data field pair      00090421
         B     CTL000                  Resume                           00090521
*                                                                       00090621
*-- Handle keys we support                                              00090721
*                                                                       00090821
*- Utility name                                                         00090921
UTL000   EQU   *                       Get utility name                 00091021
         MVC   UTLNAME,BLANKS          Init receiving field             00091121
         LA    R6,UTLNAME              -> receiving field               00091221
         B     KEY000                  Go handle the key                00091321
*                                                                       00091421
*- File size                                                            00091521
FSZ000   EQU   *                       File size                        00091621
         MVC   FSIZELEN,4(R1)          Save length of file size value   00091721
         LA    R6,FILESIZE             -> receiving field               00091821
         B     KEY000                  Go handle the key                00091921
*                                                                       00092021
*- DSORG                                                                00092121
DSG000   EQU   *                       DSORG                            00092221
         LA    R6,DSORG                -> receiving field               00092321
         B     KEY000                  Go handle the key                00092421
*- BLKSIZE                                                              00092521
BLK000   EQU   *                       BLKSIZE                          00092621
         LA    R6,BLKSIZE              -> receiving field               00092721
         B     KEY000                  Go handle the key                00092821
*                                                                       00092921
*- LRECL                                                                00093021
LRL000   EQU   *                       LRECL                            00093121
         LA    R6,LRECL                -> receiving field               00093221
         B     KEY000                  Go handle the key                00093321
*                                                                       00093421
*- RECFM                                                                00093521
RFM000   EQU   *                       RECFM                            00093621
         LA    R6,RECFM                -> receiving field               00093721
         B     KEY000                  Go handle the key                00093821
*                                                                       00093921
*- # directory blocks                                                   00094021
DIR000   EQU   *                       File size                        00094121
         MVC   DIRBLKLN,4(R1)          Save length of dirblk siz value  00094221
         LA    R6,DIRBLKS              -> receiving field               00094321
         B     KEY000                  Go handle the key                00094421
*                                                                       00094521
*- FFM                                                                  00094621
FFM000   EQU   *                       File mode number                 00094721
         LA    R6,FFM                  -> receiving field               00094821
         B     KEY000                  Go handle the key                00094921
*                                                                       00095021
*- DSNAME                                                               00095121
DSN000   EQU   *                       DSNAME                           00095221
         MVC   DSNAME,BLANKS           Init receiving field             00095321
         LA    R6,DSNAME               -> receiving field               00095421
         LA    R1,2(,R1)               Skip over key                    00095521
         LA    R15,2                   Remaining length adjust          00095621
         SR    R0,R0                   Clear for IC                     00095721
         ICM   R0,3,0(R1)              Get # value                      00095821
         LA    R1,2(,R1)               Skip over # value                00095921
         LA    R15,2(,R15)             Remaining length adjust          00096021
         BZ    CTL000                  # was 0; no lengths              00096121
         SR    R14,R14                 Clear for ICM                    00096221
*                                                                       00096321
DSN020   EQU   *                                                        00096421
         ICM   R14,3,0(R1)             Get length field                 00096521
         BCT   R14,DSN030              Adjust for execute               00096621
         MVC   0(0,R6),2(R1)           executed instr                   00096721
DSN030   EX    R14,*-6                 Move name to receiving field     00096821
         LA    R1,3(R14,R1)            Skip over length and data        00096921
         LA    R15,3(R14,R15)          Remaining length adjust          00097021
         LA    R6,1(R14,R6)            Bump to next qualifier area      00097121
         MVI   0(R6),C'.'              Add qualifier dot                00097221
         LA    R6,1(,R6)               -> next qualifier area           00097321
         BCT   R0,DSN020               Do next len/data field pair      00097421
         BCTR  R6,0                    -> last byte of DSNAME           00097521
         MVI   0(R6),C' '              Remove trailing dot              00097621
         BCTR  R6,0                    -> prior to trailing '.'         00097721
         LA    R0,DSNAME               -> start of DSNAME               00097821
         SR    R6,R0                   Compute DSN length               00097921
         STH   R6,DSNAMELN             Save it                          00098021
         B     CTL000                  get next key                     00098121
*                                                                       00098221
*-- Common routine to break part key/#/len/data elements that have #=1  00098321
*                                                                       00098421
KEY000   EQU   *                                                        00098521
         LA    R1,4(,R1)               Skip over key, #                 00098621
         LA    R15,4                   Remaining length accum           00098721
         SR    R5,R5                   Clear for IC                     00098821
         ICM   R5,3,0(R1)              Get length of name               00098921
         BCT   R5,KEY010               Adjust for execute               00099021
         MVC   0(0,R6),2(R1)           executed instr                   00099121
KEY010   EX    R5,*-6                  Move name to receiving field     00099221
         LA    R1,3(R5,R1)             -> next text unit key            00099321
         LA    R15,3(R5,R15)           Accum length adjustment          00099421
         B     CTL000                  Get next key                     00099521
*                                                                       00099621
*                                                                       00099721
*                                                                       00099821
GETBYTES EQU   *                                                        00099921
         ST    R14,SV14GB              Save return addr                 00100021
         L     R5,GBREM                Get # bytes remaining in rec buf 00100121
         LA    R1,BUFF                 Point to getbytes buffer         00100221
         ST    R1,GBPOS                Set starting position            00100321
         LR    R8,R0                   Requested amount to R8           00100421
*                                                                       00100521
*                                                                       00100621
GB010    EQU   *                                                        00100721
         LTR   R5,R5                   Any bytes left in phy record?    00100821
         BP    GB040                   Yes, use them first              00100921
*                                                                       00101021
         LA    R2,NCB1                 -> active NCB for spool file     00101121
         NSIO  TYPE=GET,               TAG data contains file #        x00101221
               NCB=(R2),               Get a spool file record         x00101321
               AREA=REC,               -> where to place record        x00101421
               EODAD=XITCME04          if EOF, then NETDATA isnt valid  00101521
         LTR   R15,R15                 Any errors?                      00101621
         BZ    GB020                   No                               00101721
*        BAL   R14,FMT000              Display error                    00101824
*        B     U0039                   And abend                        00101924
*                                                                       00102021
GB020    EQU   *                                                        00102121
         LA    R5,80                   Num bytes read                   00102221
         LA    R1,REC                  -> input buffer                  00102321
*                                                                       00102421
GB030    EQU   *                                                        00102521
         ST    R1,GBRPS                Reset start of record position   00102621
*                                                                       00102721
GB040    EQU   *                                                        00102821
         LR    R7,R8                   Assume requested amt avail       00102921
         LR    R15,R8                  Same                             00103021
*                                                                       00103121
         CR    R5,R8                   Have more than we need?          00103221
         BH    GB050                   Yes, just move requested         00103321
         LR    R7,R5                   Else move entire rec             00103421
         LR    R15,R5                  Same                             00103521
*                                                                       00103621
GB050    EQU   *                                                        00103721
         LR    R0,R7                   Save copy of length to move      00103821
         L     R14,GBPOS               -> GB buffer position            00103921
         L     R6,GBRPS                -> input record curr position    00104021
         MVCL  R14,R6                  Move                             00104121
*                                                                       00104221
         ST    R14,GBPOS               New GB position                  00104321
         ST    R6,GBRPS                New phys record curr position    00104421
*                                                                       00104521
         SR    R5,R0                   Reduce bytes left in phy record  00104621
         SR    R8,R0                   Reduce requested amt             00104721
         BP    GB010                   We need more, go get it          00104821
*                                                                       00104921
         ST    R5,GBREM                Remember whats left in phy rec   00105021
*                                                                       00105121
         LA    R1,BUFF                 Point to the requested bytes     00105221
         L     R14,SV14GB              Load  return addr                00105321
         BR    R14                     Return from getbytes             00105421
*                                                                       00105521
         LTORG                                                          00105621
*                                                                       00105721
INMR01   DC    C'INMR01'               Control record                   00105821
INMR02   DC    C'INMR02'               Control record                   00105921
*                                                                       00106021
*- Keys                                                                 00106121
INMUTILN DC    X'1028'                 Utility name                     00106221
INMSIZE  DC    X'102C'                 File size in bytes               00106321
INMDSORG DC    X'003C'                 DSORG                            00106421
INMLRECL DC    X'0042'                 LRECL                            00106521
INMBLKSZ DC    X'0030'                 BLKSIZE                          00106621
INMRECFM DC    X'0049'                 RECFM                            00106721
INMDSNAM DC    X'0002'                 DSNAME                           00106821
INMDIR   DC    X'000C'                 # directory blocks               00106921
INMFFM   DC    X'102D'                 File mode number                 00107021
*                                                                       00107121
*                                                                       00107221
*                                                                       00107321
*-- Exit NETDATA examination processing                                 00107421
*                                                                       00107521
*                                                                       00107621
XITCME00 EQU   *                                                        00107721
         SR    R15,R15             Set RC=0; NETDATA info filled        00107821
         B     XITCME                                                   00107921
*                                                                       00108021
XITCME04 EQU   *                                                        00108121
         LA    R15,4               Set RC=4; File contains no NETDATA   00108221
*                                                                       00108321
XITCME   EQU   *                                                        00108421
         L     R13,4(,R13)         -> prev s.a.                         00108521
         ST    R15,16(,R13)        Set RC                               00108621
         LM    R14,R12,12(R13)     Reload callers regs                  00108721
         BR    R14                 Return with RC                       00108821
*                                                                       00108921
         LTORG                                                          00109021
         SHVCB DSECT                                                    00109100
         WORKAREA                                                       00109200
RXRETURN DS    A                   Return Code before returning to REXX 00109309
FILENO   DS    A                   FILE NUMBER OF A REQUEST             00109409
STRDPCK  DS    0D                  STRPACK ON DOUBLE FOR BIN CONVERSION 00109507
STRPACK  DS    PL8                 MAXIMUM 999,999,999,999,999          00109600
STRNUM   DS    CL16                BIN2CHR DESTINATION FIELD            00109700
NJECNT   DS    A                   Index Count of Output                00109800
NJEMODE  DS    CL8                 REQUESTED MODE                       00109901
NJETEXT  DS    CL32                INPUT LINE                           00110002
IRXADDR  DS    A                                                        00110100
NCB1     DS    XL48                NCB                                  00110200
         DS    CL64                Filler                               00110300
MTEXT    DS    CL120               Message text work area               00110400
VARN     DS    0CL10                                                    00110500
VAR      DC    CL6'NJEMSG'                                              00110600
VNUM     DS    CL4                                                      00110700
DBLE     DS    D                   Work area                            00110800
TWRK     DS    2D                  WORK AREA                            00110906
ALINKS   DS    A  16                -> first LINKTABL entry             00111000
* .... Info Area                                                        00111114
FILESIZE DS    2F                     File size in bytes           v110 00111214
DIRBLKS  DS    2F                     #directory blocks            v110 00111314
BLKSIZE  DS    F                      BLKSIZE                      v110 00111414
LRECL    DS    F                      LRECL                        v110 00111514
RECFM    DS    XL2                    RECFM                        v110 00111614
DSORG    DS    XL2                    DSORG                        v110 00111714
FFM      DS    C                      File mode number             v110 00111814
         DS    X                      available                    v110 00111914
DIRBLKLN DS    H                      Length of dir blks value     v110 00112014
FSIZELEN DS    H                      Length of file size value    v110 00112114
DSNAMELN DS    H                      Length of DSNAME             v110 00112214
DSNAME   DS    CL44                   DSNAME                       v110 00112314
* .... WTO Area                                                         00112414
WTOCB    DS    0H                                                       00112500
WTOMSGLN DS    AL2                                                      00112600
WTOFILLR DS    CL2                                                      00112700
WTOMSG   DS    CL80                                                     00112800
WTOMSEND DS    0H                                                       00112900
* .... Time to Convert TOD Clock Time                                   00113027
NJEDATE  DS    F                                                        00113128
*                                                                       00113206
TDATA    DS    0XL108                                                   00113306
BLNKDASH DS    0CL256                                                   00113406
ASIDTAB  DS    24CL24                                                   00113506
TARGET   DS    X                   CODE FOR WHO GETS THE CMD RESPONSE   00113606
TGTUSER  EQU   0                    REMOTE USER                         00113706
TGTCONS  EQU   4                    MVS SYSTEM CONSOLE                  00113806
TYPPRT   EQU   X'40'                PRT dev                             00113920
*                                                                       00114006
NJFL1    DS    X                   FLAG BITS                            00114106
NJF1MULT EQU   X'80'   1... ....    MULTI-FILE CANCEL COMMAND           00114206
NJF1CNCL EQU   X'40'   .1.. ....    A FILE WAS DELETED BY COMMAND       00114306
NJF1DATH EQU   X'20'   ..1. ....    AT LEAST 1 AUTH USER DISPLAYED      00114406
NJF1NYET EQU   X'10'   ...1 ....    NO USABLE NETDATA FOUND IN FILEV110 00114506
NJF1VSER EQU   X'02'   .... ..1.    NETSPOOL VSAM ERROR OCCURRED        00114606
NJF1AUTH EQU   X'01'   .... ...1    CMD ISSUER IS CMD AUTHORIZED        00114706
*                                                                       00114806
SV14GB   DS    A                      R14 save area                v110 00114922
GBREM    DC    F'0'                   # bytes remaining in phys recv110 00115022
GBPOS    DS    A                      -> cur position in BUFF      v110 00115122
GBRPS    DS    A                      -> cur position in phys rec  v110 00115222
*                                                                  v110 00115322
UTLNAME  DS    CL8                    Utility name                 v110 00115422
*                                                                       00115522
REC      DS    CL80                   Physical record              v110 00115622
TRTAB    DS    0CL256                 Translate table              v120 00115722
BUFF     DS    CL256                  GB buffer containing key datav110 00115822
*                                                                       00115922
NJESA    DS    18F                     NJECMX OS save area              00116022
CMCSA    DS    18F                     NJECMC OS save area         v110 00116122
CMGSA    DS    18F                     NJECMG OS save area         v110 00116222
CMHSA    DS    18F                     NJECMH OS save area         v110 00116322
CMESA    DS    18F                     NJECME OS save area         v110 00116422
BALRSAVE DS    16F                     Local rtns register save         00116522
*                                                                       00116622
         DS    0D                      Force doubleword size            00116722
         SHVCB DEFINE                                                   00116800
*                                                                       00116906
         WORKEND                                                        00117000
         COPY  NETSPOOL                                                 00117100
         COPY  TAG                                                      00117206
         COPY  LINKTABL                                                 00117300
         DCBD  DSORG=PS,DEVD=DA                                         00117414
         END                                                            00117500
