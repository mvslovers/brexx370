         MACRO                                                          TSO05360
&LAB     KKSCAN  &CPPL=R11,&CSOA=ACSOA,&ECB=ECB,&CSPL=ACSPL,&CSFW=CSFW,XTSO05370
               &CVT='NO'                                                TSO05380
         MNOTE 'CPPL=&CPPL,CSOA=&CSOA,ECB=&ECB,CSPL=&CSPL,CSFW=&CSFW'   TSO05390
*                  DEFAULT OPERANDS :                                   TSO05400
*        KKSCAN CPPL=R11,ECB=ECB,CSFW=CSFW                              TSO05410
*                            CPPL IS THE REGISTER CONTAINING THE        TSO05420
*                                 POINTER TO THE COMMAND PROCESSOR      TSO05430
*                                 PARAMETER LIST.                       TSO05440
*                            CSOA IS A DBLWORD WHERE SCAN RETURNS       TSO05450
*                                 THE SCAN RESULTS                      TSO05460
*                            ECB  IS A FULLWORD.                        TSO05470
*                            CSFW IS A FULLWORD FLAGAREA PASSED TO SCAN TSO05480
*                            CSPL IS A 6 FULLWORD AREA USED FOR         TSO05490
*                                 THE SCAN PARAMETER LIST.              TSO05500
*                                                                       TSO05510
*        KKSCAN              USES REGS R14,R15,R1,R0                    TSO05520
*                                                                       TSO05530
         USING CPPL,&CPPL         POINTS TO CPPL (PARM LIST)            TSO05540
*                                                                       TSO05550
&LAB     LA    R1,&CSPL           R1->CSPL AREA                         TSO05560
         USING CSPL,R1                                                  TSO05570
*                                                                       TSO05580
*                         CONSTRUCT SCAN PARAMETER LIST                 TSO05590
*                                           FOR IKJSCAN :               TSO05600
*                                                                       TSO05610
         MVC   CSPLUPT,CPPLUPT    UPT                                   TSO05620
         MVC   CSPLECT,CPPLECT    ECT                                   TSO05630
         LA    R15,&ECB           ECB                                   TSO05640
         ST    R15,CSPLECB         "                                    TSO05650
         L     R15,&CSFW          CSFW                                  TSO05660
         ST    R15,CSPLFLG                                              TSO05670
         LA    R15,&CSOA          ANS                                   TSO05680
         ST    R15,CSPLOA                                               TSO05690
         MVC   CSPLCBUF,CPPLCBUF  CBUF                                  TSO05700
         XC    &CSFW,&CSFW                                              TSO05710
*                                                                       TSO05720
         DROP  R1                                                       TSO05730
         DROP  &CPPL                                                    TSO05740
         EJECT                                                          TSO05750
*        CALLTSSR EP=IKJSCAN      CALL SCAN:                            TSO05760
         CALLTSSR EP=IKJSCAN      CALL SCAN:                            TSO05770
         EJECT                                                          TSO05780
*                                                                       TSO05790
*                        DSECTS NEEDED BY SCAN:                         TSO05800
*                                                                       TSO05810
         IKJCSPL                                                        TSO05820
*                                                                       TSO05830
         IKJCSOA                                                        TSO05840
         AIF   ('&CVT' NE 'YES').SC                                     TSO05850
*                                                                       TSO05860
         IKJCVT                                                         TSO05870
.SC      ANOP                                                           TSO05880
*                                                                       TSO05890
&SYSECT  CSECT                                                          TSO05900
         MEND                                                           TSO05910
