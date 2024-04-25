         MACRO
&NAME    UPUT  &BFF,&SIZE,&EDIT,&WAIT,&HOLD,&BRKI,&INFOR,&HELP=,&CPPL=,*
               &IOPL=,&MF=I,&@ENTRY=UPUT                       RTS02A1
         LCLA  &OPT,&POPT                                      RTS02A1
         LCLA  &RET
         LCLB  &E,&W,&H,&B,&P
         LCLC  &PARM,&S,&L,&CPIOPL                             RTS02A1
&S       SETC  '&SYSNDX'                                       RTS02A1
&L       SETC  'L'''                                           RTS02A1
         AIF   ('&MF' EQ 'L').MFL                              RTS02A1
         AIF   ('&MF(1)' EQ 'E').MFE                           RTS02A1
         AIF   ('&MF(1)' EQ 'I' OR '&MF' EQ '').MFI            RTS02A1
         IHBERMAC 35,0,&MF                                     RTS02A1
         MEXIT                                                 RTS02A1
.MFI     ANOP                                                  RTS02A1
         AIF   ('&BFF' EQ '*' OR '&BFF' EQ '').ERROR1
         AIF   ('&BFF'(1,1) EQ '(' AND ('&SIZE' EQ '' OR '&SIZE' EQ '*'*
               )).ERROR1                                       RTS02A1
.MFE     AIF   ('&CPPL' EQ '' AND '&IOPL' EQ '' AND '&@ENTRY' EQ 'UPUT'*
               ).GETCPPL                    GET CPPL     WDPSC-8/26/86
         AIF   ('&CPPL' NE '' AND '&IOPL' NE '').ERROR2        RTS02A1
&CPIOPL  SETC  '&CPPL&IOPL'                                    RTS02A1
&PARM    SETC  '&EDIT'
.CKPARM  ANOP
&RET     SETA  &RET+1
         AIF   ('&PARM' EQ '').RET           NULL, TRY NEXT
         AIF   ('&PARM' EQ 'EDIT').EDI       SET EDIT
         AIF   ('&PARM' EQ 'ASIS').ASI       SET ASIS
         AIF   ('&PARM' EQ 'CONTROL').CON    SET CONTROL
         AIF   ('&PARM' EQ 'WAIT').WAI       SET WAIT
         AIF   ('&PARM' EQ 'NOWAIT').NOW     SET NOWAIT
         AIF   ('&PARM' EQ 'HOLD').HOL       SET HOLD
         AIF   ('&PARM' EQ 'NOHOLD').NOH     SET NOHOLD
         AIF   ('&PARM' EQ 'NOBREAK').NOB    SET NOBREAK
         AIF   ('&PARM' EQ 'BREAKIN').BRE    SET BREAKIN
         AIF   ('&@ENTRY' NE 'UPUT').ERROR3                    RTS02A1
         AIF   ('&PARM' EQ 'DATA').DATA                        RTS02A1
         AIF   ('&PARM' EQ 'INFOR').INFOR                      RTS02A1
         AGO   .ERROR3
.GETCPPL ANOP                                            WDPSC-8/26/86
         L     R15,4(R13)           GET OLD SAVE AREA    WDPSC-8/26/86
         L     R0,24(R15)           AND LOAD THE CPPL    WDPSC-8/26/86
&CPIOPL  SETC  '(0)'
&PARM    SETC  '&EDIT'
         AGO   .CKPARM
.*
.*  CHECK REGISTER NOTATION IS USED
.*
.CHKREG  SPACE 1
         AIF   ('&MF' EQ 'L').GENLIST                          RTS02A1
         AIF   ('&MF' NE 'I' AND '&MF' NE '').GENE             RTS02A1
.EXPAND  CNOP  0,4
         AIF   ('&@ENTRY' EQ 'UPUT').PUTNAME                   RTS02A1
&NAME    B     UPR&S              BRANCH AROUND PROMPT PARMS   RTS02A1
         AGO   .GENI                                           RTS02A1
.PUTNAME ANOP                                                  RTS02A1
         AIF   ('&NAME' EQ '').NONAME                          RTS02A1
&NAME    EQU   *                                               RTS02A1
.NONAME  AIF   ('&SIZE' EQ '' OR '&SIZE' EQ '*').NOSIZER       RTS02A1
         AIF   ('&SIZE'(1,1) NE '(').NOSIZER                   RTS02A1
         STH   &SIZE(1),UPT&S+2   STORE MESSAGE LENGTH         RTS02A1
.NOSIZER AIF   ('&BFF'(1,1) NE '(').NOBFFR                     RTS02A1
         STCM  &BFF(1),7,UPT&S+5  STORE BUFFER ADDRESS         RTS02A1
.NOBFFR  ANOP                                                  RTS02A1
         AIF   (&POPT NE X'06' AND &POPT NE X'04').NOH2R       RTS02A1
         AIF   ('&HELP(1)'(1,1) NE '(').NOH1R                  RTS02A1
         ST    &HELP(1),UPT&S+12  STORE HELP ADDRESS           RTS02A1
.NOH1R   AIF   ('&HELP(2)' EQ '').NOH2R                        RTS02A1
         AIF   ('&HELP(2)'(1,1) NE '(').NOH2R                  RTS02A1
         ST    &HELP(2),UPT&S+8   STORE HELP LENGTH            RTS02A1
.NOH2R   AIF   ('&@ENTRY' NE 'UPUT').GEND                      RTS02A1
         BAL   1,UPU&S            BRANCH AROUND CONSTANTS      RTS02A1
UPT&S    EQU   *                                               RTS02A1
         AGO   .GENI                                           RTS02A1
.GENLIST AIF   ('&@ENTRY' EQ 'UPUT').PUTLIST                   RTS02A1
         DS    0A                 ALIGN TO FULLWORD            RTS02A1
&NAME    EQU   *-4                PROMPT LIST HAS ORIGIN 4     RTS02A1
         AGO   .GENI                                           RTS02A1
.PUTLIST ANOP                                                  RTS02A1
&NAME    DS    0A                                              RTS02A1
.GENI    DC    AL2(&POPT)               PUTLINE OPTIONS        RTS02A1
         AIF   ('&BFF' EQ '' OR '&BFF' EQ '*').DUMSIZE         RTS02A1
         AIF   ('&SIZE' NE '' AND '&SIZE' NE '*').GOTSIZE      RTS02A1
         DC    AL2(&L&BFF)        BUFFER LENGTH                RTS02A1
         AGO   .JSIZE                                          RTS02A1
.GOTSIZE AIF   ('&SIZE'(1,1) NE '(').OKSIZE                    RTS02A1
.DUMSIZE DC    AL2(0)             BUFFER SIZE                  RTS02A1
         AGO   .JSIZE                                          RTS02A1
.OKSIZE  ANOP                                                  RTS02A1
         DC    AL2(&SIZE)               BUFFER SIZE
.JSIZE   DC    AL1(&OPT)                OPTIONS
         AIF   ('&BFF' EQ '' OR '&BFF' EQ '*').DUMBFF          RTS02A1
         AIF   ('&BFF'(1,1) NE '(').OKBFF                      RTS02A1
.DUMBFF  DC    AL3(0)             BUFFER ADDR                  RTS02A1
         AGO   .JBFF                                           RTS02A1
.OKBFF   ANOP                                                  RTS02A1
         DC    AL3(&BFF)                BUFFER ADDR
.JBFF    AIF   ('&HELP' EQ '' AND ('&MF' EQ 'I' OR '&MF' EQ '')).SKPHEL*
               P                                               RTS02A1
         AIF   ('&HELP' EQ '').RHNOLEN                         RTS02A1
         AIF   ('&HELP(1)'(1,1) EQ '(').RHMSG                  RTS02A1
         AIF   ('&HELP(2)' EQ '').HGLEN                        RTS02A1
         AIF   ('&HELP(2)'(1,1) EQ '(').HNOLEN                 RTS02A1
         DC    AL4(&HELP(2))      LENGTH OF HELP MESSAGE       RTS02A1
         AGO   .JHLEN                                          RTS02A1
.HGLEN  DC    AL4(&L&HELP(1))    LENGTH OF HELP MESSAGE        RTS02A1
         AGO   .JHLEN                                          RTS02A1
.HNOLEN DC    AL4(0)             LENGTH OF HELP MESSAGE        RTS02A1
.JHLEN   DC    AL4(&HELP(1))      HELP MESSAGE ADDR            RTS02A1
         AGO   .SKPHELP                                        RTS02A1
.RHMSG   AIF   ('&HELP(2)'(1,1) EQ '(').RHNOLEN                RTS02A1
         DC    AL4(&HELP(2))      LENGTH OF HELP MESSAGE       RTS02A1
         AGO   .JRHLEN                                         RTS02A1
.RHNOLEN DC    AL4(0)             LENGTH OF HELP MESSAGE       RTS02A1
.JRHLEN  DC    AL4(0)             ADDRESS OF HELP MESSAGE      RTS02A1
.SKPHELP ANOP                                                  RTS02A1
         AIF   ('&MF' EQ 'L').GEND                             RTS02A1
         AIF   ('&@ENTRY' EQ 'UPUT').PUTCPPL                   RTS02A1
UPR&S    EQU   *                                               RTS02A1
         AGO   .NONAME                                         RTS02A1
.PUTCPPL ANOP                                                  RTS02A1
UPU&S    EQU   *                                               RTS02A1
.LDCPPL  AIF   ('&CPIOPL' EQ '(0)').CPPL0                      RTS02A1
         AIF   ('&CPIOPL'(1,1) EQ '(').CPPLR                   RTS02A1
         LA    0,&CPIOPL        LOAD CPPL ADDRESS              RTS02A1
         AGO   .CPPL0                                          RTS02A1
.CPPLR   LA    0,0&CPIOPL     LOAD CPPL ADDRESS                RTS02A1
         AIF   ('&IOPL' NE '').IOPLFF                          RTS02A1
         AGO   .CPPLO                                          RTS02A1
.CPPL0   AIF   ('&IOPL' NE '').IOPLFF                          RTS02A1
         ICM   0,8,=X'00'         INDICATE CPPL PASSED         RTS02A1
         AGO   .CPPLO                                          RTS02A1
.IOPLFF  ICM   0,8,=X'FF'         INDICATE IOPL PASSED         RTS02A1
.CPPLO   ANOP                                                  RTS02A1
         L     15,=V(UKJUPUT)                                  RTS02A1
         BALR  14,15              CALL UPUT ROUTINE            RTS02A1
.GEND    SPACE 1
         MEXIT
.EDI     ANOP
         AIF   (&E).ERROR2              DUP OPTION
&E       SETB  1                        EDIT OPTION SPECFIED
         AGO   .RET
.ASI     ANOP
         AIF   (&E).ERROR2              DUP OPTION
&E       SETB  1                        EDIT OPTION SPECFIED
&OPT     SETA  &OPT+1                   SET EDIT=ASIS
         AGO   .RET
.CON     ANOP
         AIF   (&E).ERROR2              DUP OPTION
&E       SETB  1                        EDIT OPTION SPECFIED
         MNOTE 0,'UPUT001 WARNING -- EFFECTS OF CONTROL OPTION ARE DEVI*
               CE DEPENDENT'
&OPT     SETA  &OPT+2                   SET EDIT=CONTROL
         AGO   .RET
.WAI     ANOP
         AIF   (&W).ERROR2              DUP OPTION
&W       SETB  1                        WAIT OPTION SPECIFIED
         AGO   .RET
.NOW     ANOP
         AIF   (&W).ERROR2              DUP OPTION
&W       SETB  1                        WAIT OPTION SPECIFIED
&OPT     SETA  &OPT+X'10'               SET WAIT=NOWAIT
         AGO   .RET
.HOL     ANOP
         AIF   (&H).ERROR2              DUP OPTION
&H       SETB  1                        HOLD OPTION SPECIFIED
&OPT     SETA  &OPT+X'08'               SET HOLD=HOLD
         AGO   .RET
.NOH     ANOP
         AIF   (&H).ERROR2              DUP OPTION
&H       SETB  1                        HOLD OPTION SPECIFIED
         AGO   .RET
.BRE     ANOP
         AIF   (&B).ERROR2              DUP OPTION
&B       SETB  1                        BREAK OPTION SPECIFIED
&OPT     SETA  &OPT+X'04'               SET BREAKIN
         AGO   .RET
.NOB     ANOP
         AIF   (&B).ERROR2              DUP OPTION
&B       SETB  1                        BREAK OPTION SPECIFIED
         AGO   .RET
.INFOR   ANOP                                                  RTS02A1
         AIF   (&P).ERROR2              DUP OPTION             RTS02A1
&P       SETB  1                   PUTLINE OPTION SPECIFIED    RTS02A1
         AGO   .RET
.DATA    ANOP                                                  RTS02A1
         AIF   (&P).ERROR2              DUP OPTION             RTS02A1
&P       SETB  1                  PUTLINE OPTION SPECIFIED     RTS02A1
&POPT    SETA  X'30'              SET SINGLE DATA LINE         RTS02A1
.RET     ANOP
&PARM    SETC  '&WAIT'
         AIF   ('&RET' EQ '1').CKPARM   CHECK WAIT
&PARM    SETC  '&HOLD'
         AIF   ('&RET' EQ '2').CKPARM   CHECK HOLD
&PARM    SETC  '&BRKI'
         AIF   ('&RET' EQ '3').CKPARM   CHECK BRKI
&PARM    SETC  '&INFOR'                                        RTS02A1
         AIF   ('&RET' EQ '4').CKPARM   CHECK INFOR/DATA       RTS02A1
         AIF   (&POPT NE 0).NOHELP                             RTS02A1
         AIF   ('&HELP' EQ '').ONELEV                          RTS02A1
&POPT    SETA  X'04'                                           RTS02A1
         AIF   ('&@ENTRY' NE 'UPUT').CHKREG                    RTS02A1
&POPT    SETA  &POPT+X'02'                                     RTS02A1
         AGO   .CHKREG                                         RTS02A1
.ONELEV  AIF   (NOT &P AND '&MF(1)' EQ 'E').NOHELP             RTS02A1
&POPT    SETA  X'10'                                           RTS02A1
         AIF   ('&@ENTRY' NE 'UPUT').CHKREG                    RTS02A1
&POPT    SETA  &POPT+X'20'      CHANGED DEFAULT FROM INFO      RTS02A1
         AGO   .CHKREG          (12) TO DATA (30)      8/28/86 **WDPSC
.NOHELP  AIF   ('&HELP' EQ '').CHKREG                          RTS02A1
         MNOTE 4,'HELP IGNORED WHEN DATA OPTION USED'          RTS02A1
         AGO   .CHKREG                  DONE WITH OPTIONS
.MFL     ANOP                                                  RTS02A1
         AIF   ('&BFF' EQ '').BFFOK                            RTS02A1
         AIF   ('&BFF'(1,1) EQ '(').LREG                       RTS02A1
.BFFOK   AIF   ('&SIZE' EQ '').SIZEOK                          RTS02A1
         AIF   ('&SIZE'(1,1) EQ '(').LREG                      RTS02A1
.SIZEOK  AIF   ('&HELP' EQ '').HELPOK                          RTS02A1
         AIF   ('&HELP(1)' EQ '').HELP1OK                      RTS02A1
         AIF   ('&HELP(1)'(1,1) EQ '(').LREG                   RTS02A1
.HELP1OK AIF   ('&HELP(2)' EQ '').HELPOK                       RTS02A1
         AIF   ('&HELP(2)'(1,1) NE '(').HELPOK                 RTS02A1
.LREG    IHBERMAC 69                                           RTS02A1
         MEXIT                                                 RTS02A1
.HELPOK  AIF   ('&CPPL' EQ '' AND '&IOPL' EQ '').NOCPPL        RTS02A1
         MNOTE 4,'UPUT002 CPPL/IOPL OPERAND IGNORED WHEN MF=L' RTS02A1
.NOCPPL  ANOP                                                  RTS02A1
&PARM    SETC  '&EDIT'                                         RTS02A1
         AGO   .CKPARM                                         RTS02A1
.GENE    ANOP                                                  RTS02A1
&NAME    DS    0H                                              RTS02A1
         AIF   ('&@ENTRY' EQ 'UPUT').PUTEX                     RTS02A1
         AIF   ('&MF(2)'(1,1) EQ '(').PRER                     RTS02A1
         LA    1,4+&MF(2)         ADDR PROMPT PARM LIST        RTS02A1
         AGO   .JEX                                            RTS02A1
.PRER    LA    1,4&MF(2)          ADDR PROMPT PARM LIST        RTS02A1
         AGO   .JEX                                            RTS02A1
.PUTEX   ANOP                                                  RTS02A1
         AIF   ('&BFF' NE '(1)').NER1                          RTS02A1
         LR    15,1               COPY MSG ADDR TO 15          RTS02A1
.NER1    IHBINNRA &MF(2)                                       RTS02A1
.JEX     AIF   (&POPT EQ 0).ENOPOPT                            RTS02A1
         MVI   1(1),&POPT         STORE PUTLINE OPTIONS        RTS02A1
.ENOPOPT AIF   ('&SIZE' EQ '').ENOSIZ                          RTS02A1
         AIF   ('&SIZE' EQ '*').STARSIZ                        RTS02A1
         AIF   ('&SIZE'(1,1) EQ '(').RSIZ                      RTS02A1
         LA    14,&SIZE                                        RTS02A1
         STH   14,2(1)           STORE MSG LENGTH IN PARM LIST RTS02A1
         AGO   .ENOSIZ                                         RTS02A1
.RSIZ    STH   &SIZE(1),2(1)     STORE MSG LENGTH IN PARM LIST RTS02A1
         AGO   .ENOSIZ                                         RTS02A1
.STARSIZ AIF   ('&BFF' EQ '*' OR '&BFF' EQ '').ENOSIZ          RTS02A1
         AIF   ('&BFF'(1,1) EQ '(').ENOSIZ                     RTS02A1
         LA    14,&L&BFF          GET LENGTH OF MESSAGE        RTS02A1
         STH   14,2(1)            STORE IN PARM LIST           RTS02A1
.ENOSIZ  AIF   (NOT (&E OR &W OR &H OR &B)).ENOPT              RTS02A1
         MVI   4(1),&OPT          STORE TPUT OPTIONS           RTS02A1
.ENOPT   AIF   ('&BFF' EQ '' OR '&BFF' EQ '*').ENOBFF          RTS02A1
         AIF   ('&BFF'(1,1) EQ '(').ERBFF                      RTS02A1
         LA    14,&BFF                                         RTS02A1
         STCM  14,7,5(1)        STORE BUFFER ADDR IN PARM LIST RTS02A1
         AGO   .ENOBFF                                         RTS02A1
.ERBFF   AIF   ('&BFF' NE '(1)').ERN1                          RTS02A1
         STCM  15,7,5(1)        STORE MSG ADDRESS IN PARM LIST RTS02A1
         AGO   .ENOBFF                                         RTS02A1
.ERN1    STCM  &BFF(1),7,5(1)   STORE MSG ADDRESS IN PARM LIST RTS02A1
.ENOBFF  AIF   ('&HELP' EQ '').ENOHELP                         RTS02A1
         AIF   ('&HELP(1)' EQ '').EGHELP                       RTS02A1
         AIF   ('&HELP(1)'(1,1) EQ '(').ERH1                   RTS02A1
         LA    14,&HELP(1)                                     RTS02A1
.EGHELP  ST    14,12(1)           STORE HELP MSG ADDR          RTS02A1
         AGO   .EHELP2                                         RTS02A1
.ERH1    ST    &HELP(1),12(1)     STORE HELP MSG ADDR          RTS02A1
.EHELP2  AIF   ('&HELP(2)' EQ '').EDH2                         RTS02A1
         AIF   ('&HELP(2)'(1,1) EQ '(').ERH2                   RTS02A1
         LA    14,&HELP(2)                                     RTS02A1
         ST    14,8(1)            STORE HELP MSG LENGTH        RTS02A1
         AGO   .ENOHELP                                        RTS02A1
.ERH2    ST    &HELP(2),8(1)      STORE HELP MSG LENGTH        RTS02A1
         AGO   .ENOHELP                                        RTS02A1
.EDH2    AIF   ('&HELP(1)' EQ '').ENOHELP                      RTS02A1
         AIF   ('&HELP(1)'(1,1) EQ '(').ENOHELP                RTS02A1
         LA    14,&L&HELP(1)                                   RTS02A1
         ST    14,8(1)            STORE HELP MSG LENGTH        RTS02A1
.ENOHELP AIF   ('&@ENTRY' NE 'UPUT').GEND                      RTS02A1
         AGO   .LDCPPL                                         RTS02A1
.RERR    IHBERMAC 192
         MEXIT
.ERROR1  IHBERMAC 24
         MEXIT
.ERROR2  IHBERMAC 54,,,
         MEXIT
.ERROR3  IHBERMAC 49,,&PARM
         MEND
