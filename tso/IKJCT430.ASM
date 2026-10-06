         TITLE 'IKJCT430 EXEC COMMAND PHASE 1 MAIN CONTROL             *00001000
                        '                                               00002000
IKJCT430 CSECT ,                                                   0001 00003000
@MAINENT DS    0H                                                  0001 00004000
         USING *,R15                                            DSKC190 00005000
         B     @PROLOG                                             0001 00006000
         DC    AL1(16)                                             0001 00007000
         DC    C'IKJCT430  87.344'                              DSKC190 00008000
         DROP  R15                                              DSKC190 00009000
@PROLOG  STM   R14,R12,12(R13)                                  DSKC190 00010000
         BALR  R12,0                                            DSKC190 00011000
@PSTART  LA    R10,4095(,R12)                                   DSKC190 00012000
         USING @PSTART,R12                                      DSKC190 00013000
         USING @PSTART+4095,R10                                 DSKC190 00014000
         L     R0,@SIZDATD                                      DSKC190 00015000
         GETMAIN  R,LV=(0)                                              00016000
         LR    R11,R1                                           DSKC190 00017000
         USING @DATD,R11                                        DSKC190 00018000
         ST    R13,@SA00001+4                                   DSKC190 00019000
         LM    R0,R1,20(R13)                                    DSKC190 00020000
         ST    R11,8(,R13)                                      DSKC190 00021000
         LR    R13,R11                                          DSKC190 00022000
         MVC   @PC00001(4),0(R1)                                DSKC190 00023000
*   CPPLPTR=R1;                     /* SAVE ADDR OF CPPL             */ 00024000
         ST    R1,CPPLPTR                                          0096 00025000
*   RFY                                                            0097 00026000
*     R1 UNRSTD;                                                   0097 00027000
*   ECDAINIT='';                    /* INITIALIZE THE COMMON DATA    */ 00028000
         XC    ECDAINIT(75),ECDAINIT                               0098 00029000
*   ECDAGCNT=CON1;                  /* GLOBAL COUNT TO ONE           */ 00030000
         MVC   ECDAGCNT(4),@CF00033                                0099 00031000
*   FLGCT430='';                    /* ZERO LOCAL FLAGS              */ 00032000
         MVI   FLGCT430,X'00'                                      0100 00033000
*   SERVPTR=ADDR(SERVBLK);          /* ADDR OF COMMON SERVICE ROUTINE   00034000
*                                      PARMS                         */ 00035000
         LA    R3,SERVBLK                                       DSKC190 00036000
         ST    R3,SERVPTR                                       DSKC190 00037000
*   PPLUPT=CPPLUPT;                 /* COMMON FIELDS IN              */ 00038000
         L     R4,PPLPTR                                        DSKC190 00039000
         L     R7,CPPLPTR                                       DSKC190 00040000
         L     R3,CPPLUPT(,R7)                                  DSKC190 00041000
         ST    R3,PPLUPT(,R4)                                   DSKC190 00042000
*   PPLECT=CPPLECT;                 /* SERVICE ROUTINE COMMON        */ 00043000
         L     R7,CPPLECT(,R7)                                  DSKC190 00044000
         ST    R7,PPLECT(,R4)                                   DSKC190 00045000
*   PPLECB=ADDR(ECB);               /* PARAMETER LIST                */ 00046000
         LA    R3,ECB                                           DSKC190 00047000
         ST    R3,PPLECB(,R4)                                   DSKC190 00048000
*   ECB=CON0;                       /* ECB FOR SERVICE RTNS          */ 00049000
         SLR   R4,R4                                            DSKC190 00050000
         ST    R4,ECB                                           DSKC190 00051000
*   RSRRET=CON0;                    /* INIT IKJCT432 RETURN CODE     */ 00052000
         SLR   R2,R2                                            DSKC190 00053000
*   ERRPTR=ADDR(ERRPARMS);          /* COMMON ERROR PARM AREA        */ 00054000
         LA    R4,ERRPARMS                                      DSKC190 00055000
         ST    R4,ERRPTR                                        DSKC190 00056000
*   CODEBASE=R12;                   /* INITIALIZE STAE ENTRY PARMS   */ 00057000
         ST    R12,CODEBASE                                        0108 00058000
*   DATABASE=R11;                                                  0109 00059000
         ST    R11,DATABASE                                        0109 00060000
*   SAVEBASE=R13;                                                  0110 00061000
*                                                                  0110 00062000
         ST    R13,SAVEBASE                                        0110 00063000
*   /*****************************************************************/ 00064000
*   /*                                                               */ 00065000
*   /* ESTABLISH THE STAE ROUTINE                                    */ 00066000
*   /*                                                               */ 00067000
*   /*****************************************************************/ 00068000
*                                                                  0111 00069000
*   STAEG(1:STAELEN)=STAEL(1:STAELEN);/* INITIALIZE STAE PARMBLK     */ 00070000
         L     R7,STAELEN                                       DSKC190 00071000
         BCTR  R7,0                                             DSKC190 00072000
         EX    R7,@SM01390                                      DSKC190 00073000
*   RFY                                                            0112 00074000
*    (R1,                                                          0112 00075000
*     R2,                                                          0112 00076000
*     R3) RSTD;                                                    0112 00077000
*   R2=ADDR(ABENTRY);               /* STAE ROUTINE ADDRESS          */ 00078000
         LA    R2,ABENTRY                                          0113 00079000
*   R3=ADDR(STAEPRMS);              /* STAE ROUTINE INPUT PARAMETERS */ 00080000
         LA    R3,STAEPRMS                                         0114 00081000
*   R1=ADDR(STAEG);                 /* STAE MACRO PARAMETERS         */ 00082000
         LA    R1,STAEG                                            0115 00083000
*   GEN;                                                           0116 00084000
  STAE (2),PARAM=(3),MF=(E,(1))        ESTABLISH STAE                   00085000
*   RFY                                                            0117 00086000
*    (R1,                                                          0117 00087000
*     R2,                                                          0117 00088000
*     R3) UNRSTD;                                                  0117 00089000
*   RFY                                                            0118 00090000
*     R15 RSTD;                                                    0118 00091000
*   SRETCDE=R15;                    /* SAVE STAE RETURN CODE         */ 00092000
         ST    R15,SRETCDE                                         0119 00093000
*   RFY                                                            0120 00094000
*     R15 UNRSTD;                                                  0120 00095000
*   IF SRETCDE^=CON0 THEN           /* IF STAE COULD NOT BE SET      */ 00096000
         L     R4,SRETCDE                                       DSKC190 00097000
         LTR   R4,R4                                            DSKC190 00098000
         BZ    @RF00121                                            0121 00099000
*     DO;                           /* UP THEN NOTIFY USER AND       */ 00100000
*       EXMSGID=A524;               /* RETURN TO CALLER              */ 00101000
         MVC   EXMSGID(4),@CC01146                                 0123 00102000
*       ERROR=YES;                  /* NO FURTHER PROCESSING OCCURS  */ 00103000
         OI    ERROR,B'10000000'                                   0124 00104000
*       MVAR(1)=ADDR(SRETCDE);      /* RETURN CODE WILL BE IN        */ 00105000
         LA    R7,SRETCDE                                       DSKC190 00106000
         ST    R7,MVAR                                          DSKC190 00107000
*       MVARLEN(1)=LENGTH(SRETCDE); /* MESSAGE                       */ 00108000
         MVI   MVARLEN,X'04'                                       0126 00109000
*       MVARHEX(1)=YES;             /* MESSAGE VARIABLE IS A NUMBER  */ 00110000
         OI    MVARHEX,B'10000000'                                 0127 00111000
*       CALL MSGRTN;                /* ISSUE MESSAGE                 */ 00112000
         BAL   R14,MSGRTN                                       DSKC190 00113000
*     END;                                                         0129 00114000
*   ELSE                            /* STAE SUCCESSFUL, CONTINUE     */ 00115000
*     DO;                           /* PROCESSING                    */ 00116000
         B     @RC00121                                            0130 00117000
@RF00121 DS    0H                                                  0131 00118000
*       PPLCBUF=CPPLCBUF;                                          0131 00119000
         L     R4,CPPLPTR                                       DSKC190 00120000
         L     R7,CPPLCBUF(,R4)                                 DSKC190 00121000
         L     R1,PPLPTR                                        DSKC190 00122000
         ST    R7,PPLCBUF(,R1)                                  DSKC190 00123000
*       PROCNAME='';                                               0132 00124000
         MVI   PROCNAME,C' '                                       0132 00125000
         MVC   PROCNAME+1(7),PROCNAME                              0132 00126000
*       IF INSEXEC=YES THEN         /* IF THIS IS A NESTED EXEC      */ 00127000
         L     R4,ECTPTR(,R4)                                   DSKC190 00128000
         L     R7,ECTIOWA(,R4)                                  DSKC190 00129000
         L     R4,IOSTELM(,R7)                                  DSKC190 00130000
         TM    INSEXEC(R4),B'00001000'                          DSKC190 00131000
         BNO   @RF00133                                            0133 00132000
*         DO;                       /* THEN SAVE GLOBAL EXECDATA     */ 00133000
*           NESTED=YES;             /* ADDRESS                       */ 00134000
         OI    NESTED,B'00000010'                                  0135 00135000
*           RFY                                                    0136 00136000
*             LSD BASED(INADLSD);   /* GET ADDRESS FROM TOP COMMAND  */ 00137000
*           ECDAGDAT=GEXECDAT;      /* PROCEDURE                     */ 00138000
         SLR   R7,R7                                            DSKC190 00139000
         ICM   R7,7,INADLSD(R4)                                 DSKC190 00140000
         L     R4,LSDEXEC(,R7)                                  DSKC190 00141000
         L     R4,GEXECDAT(,R4)                                 DSKC190 00142000
         ST    R4,ECDAGDAT                                      DSKC190 00143000
*           RFY                                                    0138 00144000
*             LSD BASED(LSDPTR);                                   0138 00145000
*         END;                                                     0139 00146000
*                                                                  0139 00147000
*       /*************************************************************/ 00148000
*       /*                                                           */ 00149000
*       /* IMPLICIT EXEC COMMAND USES COMMAND SCAN TO RETRIEVE MEMBER*/ 00150000
*       /* NAME                                                      */ 00151000
*       /*                                                           */ 00152000
*       /*************************************************************/ 00153000
*                                                                  0140 00154000
*       IF CBUFOFF=CON0 THEN        /* COMMAND BUFFER OFFSET         */ 00155000
@RF00133 SLR   R7,R7                                            DSKC190 00156000
         L     R4,CPPLPTR                                       DSKC190 00157000
         L     R4,CPPLCBUF(,R4)                                 DSKC190 00158000
         CH    R7,CBUFOFF(,R4)                                  DSKC190 00159000
         BNE   @RF00140                                            0140 00160000
*         DO;                       /* IS ZERO FOR IMPLICT EXEC      */ 00161000
*           IMPLICIT=YES;                                          0142 00162000
         OI    IMPLICIT,B'10000000'                                0142 00163000
*           CSPLFLG=ADDR(ECB);      /* FLG = 0 INDICATES TO SYNTAX 0143 00164000
*                                      CHECK COMMAND NAME            */ 00165000
         L     R4,CSPLPTR                                       DSKC190 00166000
         LA    R8,ECB                                           DSKC190 00167000
         ST    R8,CSPLFLG(,R4)                                  DSKC190 00168000
*           CSPLOA=ADDR(ALLOCPRM);  /* COMMAND SCAN ANSWER AREA      */ 00169000
         LA    R9,ALLOCPRM                                      DSKC190 00170000
         ST    R9,CSPLOA(,R4)                                   DSKC190 00171000
*           RFY                                                    0145 00172000
*             R1 RSTD;                                             0145 00173000
*           R1=SERVPTR;             /* ADDR OF INPUT PARM BLOCK      */ 00174000
         L     R1,SERVPTR                                          0146 00175000
*           DO;                     /* CALLTSSR EP(IKJSCAN)          */ 00176000
*             RESPECIFY                                            0148 00177000
*               GPR01P RSTD;                                       0148 00178000
*             IF CVTSCAN=0 THEN                                    0149 00179000
         L     R4,CVTPTR                                        DSKC190 00180000
         C     R7,CVTSCAN(,R4)                                  DSKC190 00181000
         BNE   @RF00149                                            0149 00182000
*               GEN(LINK EP=IKJSCAN);                              0150 00183000
         LINK EP=IKJSCAN                                                00184000
*             ELSE                                                 0151 00185000
*               CALL CVTSCAN;                                      0151 00186000
         B     A00019C                                          DSKC190 00187000
@RF00149 L     R7,CVTPTR                                        DSKC190 00188000
         L     R15,CVTSCAN(,R7)                                 DSKC190 00189000
         BALR  R14,R15                                          DSKC190 00190000
A00019C  L     R4,CSPLPTR                                       DSKC190 00190010
         L     R7,CSOAPTR(,R4)                                  DSKC190 00190020
         L     R4,0(,R7)                                        DSKC190 00190030
         LTR   R4,R4                                            DSKC190 00190040
         BE    @RC00121                                         DSKC190 00190050
*             RESPECIFY                                            0152 00191000
*               GPR01P UNRSTD;                                     0152 00192000
@RC00149 DS    0H                                                  0153 00193000
*           END;                    /* GET IMPLICIT NAME             */ 00194000
*           RFY                                                    0154 00195000
*             R1 UNRSTD;                                           0154 00196000
*           PROCNAME=CMDNME(1:CSOALNM);/* SAVE PROCEDURE NAME        */ 00197000
         MVI   PROCNAME+1,C' '                                     0155 00198000
         MVC   PROCNAME+2(6),PROCNAME+1                            0155 00199000
         LH    R7,CSOALNM(,R7)                                  DSKC190 00202000
         LR    R8,R7                                            DSKC190 00203000
         BCTR  R8,0                                             DSKC190 00204000
         EX    R8,@SM01394                                      DSKC190 00206000
*           ECDAINME=ADDR(PROCNAME);/* SAVE ADDR OF IMPLICIT NAME    */ 00207000
         LA    R4,PROCNAME                                      DSKC190 00208000
         ST    R4,ECDAINME                                      DSKC190 00209000
*           ECDAILNG=CSOALNM;       /* AND LENGTH                    */ 00210000
         STC   R7,ECDAILNG                                      DSKC190 00211000
*REXX/370 -- is this implicit exec a REXX exec?                 RXPTF           
*        PROCNAME holds the member name and nothing has been    RXPTF           
*        allocated or opened yet -- hence the hook here.        RXPTF           
*        R1 is dead at the join: @RC00140 and @RF00200 both     RXPTF           
*        reload R1 and R4 before reading (verified 2026-09-24). RXPTF           
*        IKJCT430 issues no SPKA/IPK/MODESET, so no key bracket;RXPTF           
*        and EXEC is AC=0, so IKJCT437 must stay unauthorized.  RXPTF           
*        R1 -> RXPLIST: member, DD (blank: the load             RXPTF           
*        routine searches), address and length of the           RXPTF           
*        operands (#331): the command buffer after the name     RXPTF           
*        (IKJSCAN set the offset to the first operand),         RXPTF           
*        without its trailing blanks, as on z/OS (round 7).     RXPTF           
         MVC   RXPMEM,PROCNAME                                  RXPTF           
         MVI   RXPDD,C' '                                       RXPTF           
         MVC   RXPDD+1(7),RXPDD                                 RXPTF           
         L     1,CPPLPTR                                        RXPTF           
         L     1,CPPLCBUF(,1)     command buffer                RXPTF           
         LH    15,CBUFLNG(,1)     length incl. header           RXPTF           
         LH    14,CBUFOFF(,1)     first operand                 RXPTF           
         SR    15,14                                            RXPTF           
         SH    15,=H'4'           R15 = operand length          RXPTF           
         LA    1,4(14,1)          R1 -> first operand           RXPTF           
         ST    1,RXPARGA                                        RXPTF           
RXTRIM   LTR   15,15                                            RXPTF           
         BNP   RXTRIMZ                                          RXPTF           
         LA    14,0(15,1)                                       RXPTF           
         BCTR  14,0               last operand byte             RXPTF           
         CLI   0(14),C' '                                       RXPTF           
         BNE   RXTRIMX                                          RXPTF           
         BCTR  15,0                                             RXPTF           
         B     RXTRIM                                           RXPTF           
RXTRIMZ  SR    15,15                                            RXPTF           
RXTRIMX  ST    15,RXPARGL                                       RXPTF           
         L     0,CPPLPTR          R0 = CPPL, for the ECT        RXPTF           
         LA    1,RXPLIST                                        RXPTF           
         L     15,=V(IKJCT437)                                  RXPTF           
         BALR  14,15                                            RXPTF           
         LTR   15,15                                            RXPTF           
         BZ    RXCLIST            R15=0: not REXX, CLIST path   RXPTF           
*        R15=4: IKJCT437 ran the exec.  Leave the way an empty  RXPTF           
*        procedure leaves: nothing is allocated, opened or      RXPTF           
*        stacked yet, so no cleanup flag is set and @RC00450    RXPTF           
*        falls through to RETURN CODE(EXRETCDE) with R5=0.      RXPTF           
         SLR   R5,R5              EXRETCDE = 0                  RXPTF           
         B     @RC00450           common exit, no CLIST         RXPTF           
RXCLIST  DS    0H                                               RXPTF           
         CNOP  0,4                                              RXPTF           
*         END;                                                     0158 00212000
*                                                                  0159 00213000
*       /*************************************************************/ 00214000
*       /*                                                           */ 00215000
*       /* EXPLICIT EXEC COMMAND USES PARSE TO SYNTAX CHECK INPUT    */ 00216000
*       /* PARMS                                                     */ 00217000
*       /*                                                           */ 00218000
*       /*************************************************************/ 00219000
*                                                                  0159 00220000
*       ELSE                        /* EXPLICIT EXEC PROCESSING      */ 00221000
*         DO;                                                      0159 00222000
         B     @RC00140                                            0159 00223000
@RF00140 DS    0H                                                  0160 00224000
*REXX/370 -- keep the operands as typed: PARS uppercases        RXPTF           
*        the value list in the buffer and drops its leading     RXPTF           
*        blanks, and the REXX hook needs it as typed (#331).    RXPTF           
*        Too long for RXRAW: RXRAWL = -1, the PDE is used.      RXPTF           
         L     R1,CPPLPTR                                       RXPTF           
         L     R1,CPPLCBUF(,R1)   command buffer                RXPTF           
         LH    R15,CBUFLNG(,R1)   length incl. header           RXPTF           
         LH    R14,CBUFOFF(,R1)   first operand                 RXPTF           
         SR    R15,R14                                          RXPTF           
         SH    R15,=H'4'          operand length                RXPTF           
         BP    RXRAWC                                           RXPTF           
         SR    R15,R15                                          RXPTF           
RXRAWC   ST    R15,RXRAWL                                       RXPTF           
         C     R15,=A(L'RXRAW)                                  RXPTF           
         BNH   RXRAWM                                           RXPTF           
         MVC   RXRAWL,=F'-1'                                    RXPTF           
         B     RXRAWX                                           RXPTF           
RXRAWM   LA    R0,4(R14,R1)       source                        RXPTF           
         LR    R1,R15             source length                 RXPTF           
         LA    R14,RXRAW          target                        RXPTF           
         MVCL  R14,R0             (R15 = target length)         RXPTF           
RXRAWX   DS    0H                                               RXPTF           
*           PPLANS=ADDR(ECDAEANS);  /* PARSE ANSWER AREA             */ 00225000
         L     R7,PPLPTR                                        DSKC190 00226000
         LA    R4,ECDAEANS                                      DSKC190 00227000
         ST    R4,PPLANS(,R7)                                   DSKC190 00228000
*           PPLPCL=ADDR(PARS);      /* PARSE INPUT PCL               */ 00229000
         L     R4,@CV01313                                      DSKC190 00230000
         ST    R4,PPLPCL(,R7)                                   DSKC190 00231000
*           RFY                                                    0162 00232000
*             R1 RSTD;                                             0162 00233000
*           R1=SERVPTR;             /* ADDR OF INPUT PARM BLOCK      */ 00234000
         L     R1,SERVPTR                                          0163 00235000
*           DO;                     /* CALLTSSR EP(IKJPARS)          */ 00236000
*             RESPECIFY                                            0165 00237000
*               GPR01P RSTD;                                       0165 00238000
*             IF CVTPARS=0 THEN                                    0166 00239000
         L     R4,CVTPTR                                        DSKC190 00240000
         L     R7,CVTPARS(,R4)                                  DSKC190 00241000
         LTR   R7,R7                                            DSKC190 00242000
         BNZ   @RF00166                                            0166 00243000
*               GEN(LINK EP=IKJPARS);                              0167 00244000
         LINK EP=IKJPARS                                                00245000
*             ELSE                                                 0168 00246000
*               CALL CVTPARS;                                      0168 00247000
         B     @RC00166                                            0168 00248000
@RF00166 L     R4,CVTPTR                                        DSKC190 00249000
         L     R15,CVTPARS(,R4)                                 DSKC190 00250000
         BALR  R14,R15                                          DSKC190 00251000
*             RESPECIFY                                            0169 00252000
*               GPR01P UNRSTD;                                     0169 00253000
@RC00166 DS    0H                                                  0170 00254000
*           END;                    /* PARSE COMMAND BUFFER          */ 00255000
*           RFY                                                    0171 00256000
*             R1 UNRSTD;                                           0171 00257000
*           RFY                                                    0172 00258000
*             R15 RSTD;                                            0172 00259000
*           SRETCDE=R15;            /* SAVE RETURN CODE              */ 00260000
         ST    R15,SRETCDE                                         0173 00261000
*           RFY                                                    0174 00262000
*             R15 UNRSTD;                                          0174 00263000
*                                                                  0175 00264000
*           /*********************************************************/ 00265000
*           /*                                                       */ 00266000
*           /* CHECK PARSE RETURN CODE                               */ 00267000
*           /*                                                       */ 00268000
*           /*********************************************************/ 00269000
*                                                                  0175 00270000
*           IF SRETCDE^=CON0 THEN   /* ISSUE MESSAGE FOR NON ZERO    */ 00271000
         L     R4,SRETCDE                                       DSKC190 00272000
         SLR   R7,R7                                            DSKC190 00273000
         CR    R4,R7                                            DSKC190 00274000
         BE    @RF00175                                            0175 00275000
*             DO;                   /* RETURN CODES                  */ 00276000
*               GFPARMS=GFPARMS&&GFPARMS;/* USE GENERAL FAIL FOR   0177 00277000
*                                      ERRORS                        */ 00278000
         L     R8,ERRPTR                                        DSKC190 00279000
         XC    GFPARMS(44,R8),GFPARMS(R8)                       DSKC190 00280000
*               GFRCODE=SRETCDE;    /* PARSE RETURN CODE             */ 00281000
         ST    R4,GFRCODE(,R8)                                  DSKC190 00282000
*               GFCPPLP=CPPLPTR;    /* ADDRESS OF CPPL               */ 00283000
         L     R4,CPPLPTR                                       DSKC190 00284000
         ST    R4,GFCPPLP(,R8)                                  DSKC190 00285000
*               GFCALLID=GFPARSE;   /* INDICATES PARSE ERROR         */ 00286000
         MVC   GFCALLID(2,R8),@CH00102                          DSKC190 00287000
*               GF02PTR=CON0;       /* IKJEFF02 ADDRESS UNKNOWN      */ 00288000
         ST    R7,GF02PTR(,R8)                                  DSKC190 00289000
*               RFY                                                0182 00290000
*                 R1 RSTD;                                         0182 00291000
*               R1=ADDR(ERRPTR);    /* PARM LIST POINTER             */ 00292000
         LA    R1,ERRPTR                                           0183 00293000
*               RFY                                                0184 00294000
*                 R1 UNRSTD;                                       0184 00295000
*               DO;                 /* LINK EP(IKJEFF19)             */ 00296000
*                 I00601='00'X;     /* EP/DE FLAG                    */ 00297000
         MVI   I00601,X'00'                                        0186 00298000
*                 I00602=ADDR(IKJEFF19);/* ADDR OF EP/DE             */ 00299000
         LA    R4,@CC01160                                      DSKC190 00300000
         STCM  R4,7,I00602                                      DSKC190 00301000
*                 I00604=0;         /* DCB PTR                       */ 00302000
         STCM  R7,7,I00604                                      DSKC190 00303000
*                 I00603='00'X;     /* ERRET FLAG                    */ 00304000
         MVI   I00603,X'00'                                        0189 00305000
*                 RESPECIFY                                        0190 00306000
*                  (GPR15P) RESTRICTED;                            0190 00307000
*                 GPR15P=ADDR(I006);/* ADDR OF LINK LIST             */ 00308000
         LA    R15,I006                                         DSKC190 00309000
*                 SVC(6);           /* ISSUE LINK SVC                */ 00310000
         SVC   6                                                   0192 00311000
*                 RESPECIFY                                        0193 00312000
*                  (GPR15P) UNRESTRICTED;                          0193 00313000
*               END;                /* LINK EP(IKJEFF19) ANALIZE   0194 00314000
*                                      FAILURE                       */ 00315000
*               ERROR=YES;          /* IKJCT430 ERROR                */ 00316000
         OI    ERROR,B'10000000'                                   0195 00317000
*             END;                                                 0196 00318000
*           FREEPDL=YES;            /* INDICATE A PDL MUST BE FREED  */ 00319000
@RF00175 OI    FREEPDL,B'00010000'                                 0197 00320000
*         END;                                                     0198 00321000
*     END;                                                         0199 00322000
@RC00140 DS    0H                                                  0200 00323000
*                                                                  0200 00324000
*   /*****************************************************************/ 00325000
*   /*                                                               */ 00326000
*   /* PREPARE THE DAIR PARAMETER BLOCK                              */ 00327000
*   /*                                                               */ 00328000
*   /*****************************************************************/ 00329000
*                                                                  0200 00330000
*   IF ERROR=NO THEN                /* IF NO ERRORS HAVE OCCURRED    */ 00331000
@RC00121 TM    ERROR,B'10000000'                                   0200 00332000
         BNZ   @RF00200                                            0200 00333000
*     DO;                           /* THEN CONTINUE EXEC PROCESS    */ 00334000
*       DAPB0PTR=ADDR(ALLOCPRM);    /* ADDR OF DAPB                  */ 00335000
         LA    R4,ALLOCPRM                                      DSKC190 00336000
         ST    R4,DAPB0PTR                                      DSKC190 00337000
*       ALLOCINT=''B;               /* INIT THE DAIR BLOCK TO ZEROES */ 00338000
         XC    ALLOCINT(76,R4),ALLOCINT(R4)                     DSKC190 00339000
*       IF IMPLICIT=YES THEN        /* IMPLICIT USES THE DAPB00 TO   */ 00340000
         TM    IMPLICIT,B'10000000'                                0204 00341000
         BNO   @RF00204                                            0204 00342000
*         DA00DDN=SYSPROC;          /* CHECK FOR SYSPROC DATA SET    */ 00343000
         MVC   DA00DDN(8,R4),@CC01116                           DSKC190 00344000
*       ELSE                        /* EXPLICIT USES THE DAPB08      */ 00345000
*         DO;                       /* TO ALLOCATE THE               */ 00346000
         B     @RC00204                                            0206 00347000
@RF00204 DS    0H                                                  0207 00348000
*           DA08CD(2)=CONX08;       /* INPUT DATA SET                */ 00349000
         L     R7,DAPB0PTR                                      DSKC190 00350000
         MVI   DA08CD+1(R7),X'08'                               DSKC190 00351000
*           B1='';                  /* INITIALIZE CERTAIN AREAS      */ 00352000
         MVI   B1(R7),C' '                                      DSKC190 00353000
         MVC   B1+1(23,R7),B1(R7)                               DSKC190 00354000
*           B2='';                  /* TO BLANKS                     */ 00355000
         MVI   B2(R7),C' '                                      DSKC190 00356000
         MVC   B2+1(15,R7),B2(R7)                               DSKC190 00357000
*           DA08SHR=YES;            /* SHARED ALLOCATION REQUEST     */ 00358000
         OI    DA08SHR(R7),B'00001000'                          DSKC190 00359000
*           IF DSNLNG^=CON0 THEN    /* COPY DATA SET NAME IF ANY     */ 00360000
         L     R4,ECDAEANS                                      DSKC190 00361000
         LH    R7,DSNLNG(,R4)                                   DSKC190 00362000
         LTR   R7,R7                                            DSKC190 00363000
         BZ    @RF00211                                            0211 00364000
*             DATASETA=PARDSN(1:DSNLNG);/* GET THE DATASET NAME      */ 00365000
         MVI   DATASETA+1,C' '                                     0212 00366000
         MVC   DATASETA+2(42),DATASETA+1                           0212 00367000
         BCTR  R7,0                                             DSKC190 00368000
         L     R4,DSNPTR(,R4)                                   DSKC190 00369000
         EX    R7,@SM01398                                      DSKC190 00370000
*           DATASETL=DSNLNG;        /* SAVE DATA SET NAME LENGTH     */ 00371000
@RF00211 L     R7,ECDAEANS                                      DSKC190 00372000
         LH    R4,DSNLNG(,R7)                                   DSKC190 00373000
         STH   R4,DATASETL                                      DSKC190 00374000
*           DA08PDSN=ADDR(DATASET); /* ADDR OF DATA SET NAME         */ 00375000
         L     R8,DAPB0PTR                                      DSKC190 00376000
         LA    R9,DATASET                                       DSKC190 00377000
         ST    R9,DA08PDSN(,R8)                                 DSKC190 00378000
*           IF DSNQTE=NO THEN       /* CHECK UNQUOTED DATA SET       */ 00379000
         TM    DSNQTE(R7),B'01000000'                           DSKC190 00380000
         BNZ   @RF00215                                            0215 00381000
*             DO;                   /* NAMES FOR CLIST SUFFIX - ADD  */ 00382000
*               DA08UID=YES;        /* SUFFIX IF NOT PRESENT         */ 00383000
         OI    DA08UID(R8),B'00100000'                          DSKC190 00384000
*REXX/370 -- with the EXEC keyword an unqualified name gets     RXPTF           
*        .EXEC instead of .CLIST (measured on z/OS: exec hello  RXPTF           
*        exec -> userid.HELLO.EXEC).  R4 = DATASETL here.       RXPTF           
         L     R7,ECDAEANS        PDL                           RXPTF           
         CLC   OPER3-PAR1PDL(2,R7),=H'1'                        RXPTF           
         BNE   RXSUFCL            no EXEC keyword: IBM path     RXPTF           
         C     R4,=F'5'                                         RXPTF           
         BL    RXSUFAD                                          RXPTF           
         LA    R7,DATASETA-5(R4)                                RXPTF           
         CLC   0(5,R7),RXSUFEX    already ends in .EXEC?        RXPTF           
         BE    @RF00218                                         RXPTF           
RXSUFAD  C     R4,=F'39'          44 minus .EXEC                RXPTF           
         BNH   RXSUFOK                                          RXPTF           
         MVC   EXMSGID(4),@CC01138  name too long, as for CLIST RXPTF           
         LA    R7,DATASETA                                      RXPTF           
         ST    R7,MVAR                                          RXPTF           
         STC   R4,MVARLEN                                       RXPTF           
         OI    ERROR,B'10000000'                                RXPTF           
         BAL   R14,MSGRTN                                       RXPTF           
         B     @RF00218                                         RXPTF           
RXSUFOK  LA    R7,DATASETA(R4)                                  RXPTF           
         LTR   R4,R4              empty name: no period         RXPTF           
         BNZ   RXSUFP                                           RXPTF           
         MVC   0(4,R7),RXSUFEX+1                                RXPTF           
         LA    R4,4                                             RXPTF           
         B     RXSUFST                                          RXPTF           
RXSUFP   MVC   0(5,R7),RXSUFEX                                  RXPTF           
         LA    R4,5(,R4)                                        RXPTF           
RXSUFST  STH   R4,DATASETL                                      RXPTF           
         B     @RF00218                                         RXPTF           
RXSUFCL  DS    0H                                               RXPTF           
*               IF DATASETL<CON6×DATASETA(DATASETL-CON5:DATASETL)^=     00385000
*                   CLIST THEN      /* CHECK FOR CLIST SUFFIX        */ 00386000
         C     R4,@CF00098                                      DSKC190 00387000
         BL    @RT00218                                            0218 00388000
         LA    R7,DATASETA-6(R4)                                DSKC190 00389000
         CLC   0(6,R7),CLIST                                    DSKC190 00390000
         BE    @RF00218                                            0218 00391000
@RT00218 DS    0H                                                  0219 00392000
*                 DO;               /* SUFFIX CLIST TO DATA SET NAME */ 00393000
*                   IF DATASETL>CON37 THEN/* IF NAME ALREADY TOO LONG*/ 00394000
         LH    R4,DATASETL                                      DSKC190 00395000
         C     R4,@CF01097                                      DSKC190 00396000
         BNH   @RF00220                                            0220 00397000
*                     DO;           /* THEN NOTIFY USER              */ 00398000
*                       EXMSGID=M525;                              0222 00399000
         MVC   EXMSGID(4),@CC01138                                 0222 00400000
*                       MVAR(1)=ADDR(DATASETA);/* ADDR OF DSNAME     */ 00401000
         LA    R7,DATASETA                                      DSKC190 00402000
         ST    R7,MVAR                                          DSKC190 00403000
*                       MVARLEN(1)=DATASETL;/* DSNAME LENGTH         */ 00404000
         STC   R4,MVARLEN                                       DSKC190 00405000
*                       ERROR=YES;  /* IKJCT430 ERROR                */ 00406000
         OI    ERROR,B'10000000'                                   0225 00407000
*                       CALL MSGRTN;/* ISSUE MESSAGE                 */ 00408000
         BAL   R14,MSGRTN                                       DSKC190 00409000
*                     END;                                         0227 00410000
*                   ELSE            /* DSNAME IS NOT TOO LONG, SO    */ 00411000
*                     DO;           /* ADD CLIST                     */ 00412000
         B     @RC00220                                            0228 00413000
@RF00220 DS    0H                                                  0229 00414000
*                       IF DATASETL=CON0 THEN/* IF LENGTH IS ZERO    */ 00415000
         LH    R4,DATASETL                                      DSKC190 00416000
         LTR   R4,R4                                            DSKC190 00417000
         BNZ   @RF00229                                            0229 00418000
*                         ICTR=CON1;/* DONT ADD PERIOD               */ 00419000
         LA    R2,1                                             DSKC190 00420000
*                       ELSE        /* OTHERWISE MOVE PERIOD         */ 00421000
*                         ICTR=CON0;/* TO DATA SET NAME              */ 00422000
         B     @RC00229                                            0231 00423000
@RF00229 SLR   R2,R2                                            DSKC190 00424000
*                       DATASETA(DATASETL+CON1:DATASETL+CON1+LENGTH(    00425000
*                           CLIST)-ICTR)=CLIST(1+ICTR:LENGTH(CLIST));   00426000
@RC00229 LH    R3,DATASETL                                      DSKC190 00427000
         LA    R4,DATASETA(R3)                                  DSKC190 00428000
         LA    R7,7                                             DSKC190 00429000
         ALR   R7,R3                                            DSKC190 00430000
         SLR   R7,R2                                            DSKC190 00431000
         SLR   R7,R3                                            DSKC190 00432000
         BCTR  R7,0                                             DSKC190 00433000
         LA    R1,CLIST(R2)                                     DSKC190 00434000
         EX    R7,@SM01401                                      DSKC190 00435000
*                       DATASETL=LENGTH(CLIST)+DATASETL-ICTR;      0233 00436000
         AL    R3,@CF00098                                      DSKC190 00437000
         SLR   R3,R2                                            DSKC190 00438000
         STH   R3,DATASETL                                      DSKC190 00439000
*                     END;                                         0234 00440000
*                 END;                                             0235 00441000
@RC00220 DS    0H                                                  0236 00442000
*             END;                                                 0236 00443000
@RF00218 DS    0H                                                  0237 00444000
*           IF PSWD=YES THEN        /* PLACE PASSWORD IN DAPB IF     */ 00445000
@RF00215 L     R4,ECDAEANS                                      DSKC190 00446000
         TM    PSWD(R4),B'10000000'                             DSKC190 00447000
         BNO   @RF00237                                            0237 00448000
*             DA08PSWD=PARPSWD(1:PSWDLNG);/* PRESENT                 */ 00449000
         L     R7,DAPB0PTR                                      DSKC190 00450000
         MVI   DA08PSWD+1(R7),C' '                              DSKC190 00451000
         MVC   DA08PSWD+2(6,R7),DA08PSWD+1(R7)                  DSKC190 00452000
         LH    R8,PSWDLNG(,R4)                                  DSKC190 00453000
         BCTR  R8,0                                             DSKC190 00454000
         L     R4,PSWDPTR(,R4)                                  DSKC190 00455000
         EX    R8,@SM01403                                      DSKC190 00456000
*         END;                                                     0239 00457000
@RF00237 DS    0H                                                  0240 00458000
*     END;                                                         0240 00459000
@RC00204 DS    0H                                                  0241 00460000
*                                                                  0241 00461000
*   /*****************************************************************/ 00462000
*   /*                                                               */ 00463000
*   /* ALLOCATE THE INPUT DATA SET                                   */ 00464000
*   /*                                                               */ 00465000
*   /*****************************************************************/ 00466000
*                                                                  0241 00467000
*   IF ERROR=NO THEN                /* IF NO ERRORS HAVE OCCURRED    */ 00468000
@RF00200 TM    ERROR,B'10000000'                                   0241 00469000
         BNZ   @RF00241                                            0241 00470000
*     DO;                           /* THEN CONTINUE EXEC PROCESS    */ 00471000
*       DAPLPSCB=CPPLPSCB;          /* INITIALIZE REMAINING          */ 00472000
         L     R7,DAPLPTR                                       DSKC190 00473000
         L     R4,CPPLPTR                                       DSKC190 00474000
         L     R4,CPPLPSCB(,R4)                                 DSKC190 00475000
         ST    R4,DAPLPSCB(,R7)                                 DSKC190 00476000
*       DAPLDAPB=DAPB0PTR;          /* DAPL FIELDS                   */ 00477000
         L     R4,DAPB0PTR                                      DSKC190 00478000
         ST    R4,DAPLDAPB(,R7)                                 DSKC190 00479000
*       RFY                                                        0245 00480000
*         R1 RSTD;                                                 0245 00481000
*       R1=SERVPTR;                 /* ADDRESS OF PARMS              */ 00482000
         L     R1,SERVPTR                                          0246 00483000
*       RFY                                                        0247 00484000
*         R1 UNRSTD;                                               0247 00485000
*       RFY                                                        0248 00486000
*         R15 RSTD;                                                0248 00487000
*       DO;                         /* CALLTSSR EP(IKJDAIR)          */ 00488000
*         RESPECIFY                                                0250 00489000
*           GPR01P RSTD;                                           0250 00490000
*         IF CVTDAIR=0 THEN                                        0251 00491000
         L     R4,CVTPTR                                        DSKC190 00492000
         L     R7,CVTDAIR(,R4)                                  DSKC190 00493000
         LTR   R7,R7                                            DSKC190 00494000
         BNZ   @RF00251                                            0251 00495000
*           GEN(LINK EP=IKJDAIR);                                  0252 00496000
         LINK EP=IKJDAIR                                                00497000
*         ELSE                                                     0253 00498000
*           CALL CVTDAIR;                                          0253 00499000
         B     @RC00251                                            0253 00500000
@RF00251 L     R4,CVTPTR                                        DSKC190 00501000
         L     R15,CVTDAIR(,R4)                                 DSKC190 00502000
         BALR  R14,R15                                          DSKC190 00503000
*         RESPECIFY                                                0254 00504000
*           GPR01P UNRSTD;                                         0254 00505000
@RC00251 DS    0H                                                  0255 00506000
*       END;                        /* ALLOCATE THE INPUT DATA SET   */ 00507000
*       SRETCDE=R15;                /* SAVE DAIR RETURN CODE         */ 00508000
         ST    R15,SRETCDE                                         0256 00509000
*       RFY                                                        0257 00510000
*         R15 UNRSTD;                                              0257 00511000
*                                                                  0258 00512000
*       /*************************************************************/ 00513000
*       /*                                                           */ 00514000
*       /* CALL IKJEFF18 TO ANALIZE ANY ERROR FROM DAIR              */ 00515000
*       /*                                                           */ 00516000
*       /*************************************************************/ 00517000
*                                                                  0258 00518000
*       IF SRETCDE^=CON0 THEN       /* IF DAIR RETURN CODE NON ZERO  */ 00519000
         L     R4,SRETCDE                                       DSKC190 00520000
         LTR   R4,R4                                            DSKC190 00521000
         BZ    @RF00258                                            0258 00522000
*         DO;                       /* THEN USE IKJEFF18 TO ANALIZE  */ 00523000
*           CALL ALLOFAIL;          /* THE ERROR                     */ 00524000
         BAL   R14,ALLOFAIL                                     DSKC190 00525000
*           ERROR=YES;              /* IKJCT430 ERROR                */ 00526000
         OI    ERROR,B'10000000'                                   0261 00527000
*         END;                                                     0262 00528000
*       ELSE                        /* IF DAIR WAS SUCCESSFUL THEN   */ 00529000
*         DO;                       /* CONTINUE EXEC PROCESSING      */ 00530000
*                                                                  0263 00531000
         B     @RC00258                                            0263 00532000
@RF00258 DS    0H                                                  0264 00533000
*           /*********************************************************/ 00534000
*           /*                                                       */ 00535000
*           /* FOR IMPLICIT EXEC MAKE SURE THE FILE NAME SYSPROC WAS */ 00536000
*           /* FOUND ALLOCATED TO A PARTITIONED DATA SET             */ 00537000
*           /*                                                       */ 00538000
*           /*********************************************************/ 00539000
*                                                                  0264 00540000
*           IF IMPLICIT=YES THEN    /* FOR IMPLICIT DETERMINE IF     */ 00541000
         TM    IMPLICIT,B'10000000'                                0264 00542000
         BNO   @RF00264                                            0264 00543000
*             DO;                   /* SYSPROC WAS FOUND ALLOCATED   */ 00544000
*               IF PERMALLO=NO×DSNINDSE=NO THEN/* IF NOT FOUND THEN     00545000
*                                      NOTIFY USER                   */ 00546000
         L     R7,DAPB0PTR                                      DSKC190 00547000
         TM    PERMALLO(R7),B'00001010'                         DSKC190 00548000
         BO    @RF00266                                            0266 00549000
*                 DO;               /* (SUB)COMMAND NOT FOUND        */ 00550000
*                   IF ECTPCMD=EXECNME THEN/* IF PRIMARY COMMAND EXEC*/ 00551000
         L     R4,CPPLPTR                                       DSKC190 00552000
         L     R7,ECTPTR(,R4)                                   DSKC190 00553000
         CLC   ECTPCMD(8,R7),@CC01130                           DSKC190 00554000
         BNE   @RF00268                                            0268 00555000
*                     MVAR(1)=CON0; /* THEN USE 'COMMAND' IN MESSAGE */ 00556000
         SLR   R4,R4                                            DSKC190 00557000
         ST    R4,MVAR                                          DSKC190 00558000
*                   ELSE            /* OTHERWISE                     */ 00559000
*                     DO;           /* USE 'SUBCOMMAND' IN MESSAGE   */ 00560000
         B     @RC00268                                            0270 00561000
@RF00268 DS    0H                                                  0271 00562000
*                       MVAR(1)=ADDR(SUBC);/* ADDRESS OF 'SUB'       */ 00563000
         LA    R7,@CC01132                                      DSKC190 00564000
         ST    R7,MVAR                                          DSKC190 00565000
*                       MVARLEN(1)=LENGTH(SUBC);/* LENGTH OF 'SUB'   */ 00566000
         MVI   MVARLEN,X'03'                                       0272 00567000
*                     END;                                         0273 00568000
*                   MVAR(2)=ADDR(PROCNAME);/* ADDRESS OF IMPLICIT  0274 00569000
*                                      PROC NAME                     */ 00570000
@RC00268 LA    R4,PROCNAME                                      DSKC190 00571000
         ST    R4,MVAR+4                                        DSKC190 00572000
*                   MVARLEN(2)=LENGTH(PROCNAME);/* LENGTH OF PROC  0275 00573000
*                                      NAME                          */ 00574000
         MVI   MVARLEN+4,X'08'                                     0275 00575000
*                   EXMSGID=M500;   /* MESSAGE IDENTIFIER            */ 00576000
         MVC   EXMSGID(4),@CC01134                                 0276 00577000
*                   ERROR=YES;      /* IKJCT430 ERROR                */ 00578000
         OI    ERROR,B'10000000'                                   0277 00579000
*                   CALL MSGRTN;    /* ISSUE MESSAGE                 */ 00580000
         BAL   R14,MSGRTN                                       DSKC190 00581000
*                 END;                                             0279 00582000
*               ELSE                                               0280 00583000
*                 IF PART0^=YES THEN/* SYSPROC DATA SETS MUST BE     */ 00584000
         B     @RC00266                                            0280 00585000
@RF00266 L     R7,DAPB0PTR                                      DSKC190 00586000
         TM    PART0(R7),B'00000010'                            DSKC190 00587000
         BO    @RF00280                                            0280 00588000
*                   DO;             /* PARTITIONED - IF NOT NOTIFY   */ 00589000
*                     EXMSGID=A502; /* USER                          */ 00590000
         MVC   EXMSGID(4),@CC01142                                 0282 00591000
*                     MVAR(1)=ADDR(FILE);/* ADDRESS OF 'FILE'        */ 00592000
         LA    R4,@CC01126                                      DSKC190 00593000
         ST    R4,MVAR                                          DSKC190 00594000
*                     MVARLEN(1)=LENGTH(FILE);/* LENGTH OF 'FILE'    */ 00595000
         MVI   MVARLEN,X'04'                                       0284 00596000
*                     MVAR(2)=ADDR(SYSPROC);/* ADDR OF 'SYSPROC'     */ 00597000
         LA    R7,@CC01116                                      DSKC190 00598000
         ST    R7,MVAR+4                                        DSKC190 00599000
*                     MVARLEN(2)=LENGTH(SYSPROC);/* LEN OF 'SYSPROC' */ 00600000
         MVI   MVARLEN+4,X'08'                                     0286 00601000
*                     ERROR=YES;    /* IKJCT430 ERROR                */ 00602000
         OI    ERROR,B'10000000'                                   0287 00603000
*                     CALL MSGRTN;  /* ISSUE MESSAGE                 */ 00604000
         BAL   R14,MSGRTN                                       DSKC190 00605000
*                   END;                                           0289 00606000
*                 ELSE                                             0290 00607000
*                   INDDNAME=DA00DDN;/* SAVE DDNAME FOR DATA SET I/O */ 00608000
         B     @RC00280                                            0290 00609000
@RF00280 L     R4,DAPB0PTR                                      DSKC190 00610000
         MVC   INDDNAME(8),DA00DDN(R4)                          DSKC190 00611000
*             END;                                                 0291 00612000
*                                                                  0292 00613000
*           /*********************************************************/ 00614000
*           /*                                                       */ 00615000
*           /* FOR EXPLICIT EXEC THE INPUT DATA SET MUST BE          */ 00616000
*           /* PARTITIONED OR SEQUENTIAL                             */ 00617000
*           /*                                                       */ 00618000
*           /*********************************************************/ 00619000
*                                                                  0292 00620000
*           ELSE                    /* EXPLICIT COMMAND PROCESSING   */ 00621000
*             DO;                                                  0292 00622000
         B     @RC00264                                            0292 00623000
@RF00264 DS    0H                                                  0293 00624000
*               INDDNAME=DA08DDN;   /* SAVE DDNAME FROM DAIR         */ 00625000
         L     R7,DAPB0PTR                                      DSKC190 00626000
         MVC   INDDNAME(8),DA08DDN(R7)                          DSKC190 00627000
*               UNALLOC=YES;        /* FREE DATA SET WHEN DONE       */ 00628000
         OI    UNALLOC,B'00000010'                                 0294 00629000
*               IF PART8=YES THEN   /* IF INPUT PARTITIONED AND      */ 00630000
         TM    PART8(R7),B'00000010'                            DSKC190 00631000
         BNO   @RF00295                                            0295 00632000
*                 IF MEM=NO THEN    /* AND NO MEMBER NAME SPECIFIED  */ 00633000
         L     R4,ECDAEANS                                      DSKC190 00634000
         TM    MEM(R4),B'10000000'                              DSKC190 00635000
         BNZ   @RF00296                                            0296 00636000
*                   PROCNAME=TEMPNAME;/* THEN ASSUME TEMPNAME        */ 00637000
         MVC   PROCNAME(8),@CC01122                                0297 00638000
*                 ELSE              /* OTHERWISE                     */ 00639000
*                   PROCNAME=PARMEM(1:MEMLNG);/* SAVE MEMBER NAME    */ 00640000
         B     @RC00296                                            0298 00641000
@RF00296 MVI   PROCNAME+1,C' '                                     0298 00642000
         MVC   PROCNAME+2(6),PROCNAME+1                            0298 00643000
         L     R7,ECDAEANS                                      DSKC190 00644000
         LH    R4,MEMLNG(,R7)                                   DSKC190 00645000
         BCTR  R4,0                                             DSKC190 00646000
         L     R7,MEMPTR(,R7)                                   DSKC190 00647000
         EX    R4,@SM01405                                      DSKC190 00648000
*REXX/370 -- explicit EXEC of a PDS member: ask IKJCT437.       RXPTF           
*        INDDNAME is the DD DAIR just allocated and follows     RXPTF           
*        PROCNAME directly (8 bytes each, @DATD): R1 -> both.   RXPTF           
*        EXEC keyword: IKJCT43F runs it as REXX.  Without it    RXPTF           
*        IKJCT43C runs it only if line 1 is a REXX comment.     RXPTF           
*        The join at @RC00295 reloads R4 and R7.                RXPTF           
         L     R7,ECDAEANS        PDL                           RXPTF           
*        RXPLIST: member and DD, then address and length        RXPTF           
*        of the argument (#331).  PARS uppercased the value     RXPTF           
*        list in the buffer and dropped its leading blanks,     RXPTF           
*        but z/OS hands it over as typed, so it is read from    RXPTF           
*        RXRAW, the operands copied before PARS ran: skip the   RXPTF           
*        dsname, take the quoted string, halve ''; an           RXPTF           
*        unclosed string ends with the line, as in PARS.        RXPTF           
*        The PDE says whether there is one at all (null:        RXPTF           
*        length 0, no argument, as z/OS).  RXRAW too short,     RXPTF           
*        or a scan that disagrees with PARS: the PDE text.      RXPTF           
         MVC   RXPMEM(16),PROCNAME   member, INDDNAME           RXPTF           
         XC    RXPARGA(8),RXPARGA                               RXPTF           
         TM    VLSTFLG(R7),X'80'  value list present?           RXPTF           
         BZ    RXEXPA                                           RXPTF           
         L     R1,RXRAWL                                        RXPTF           
         LTR   R1,R1                                            RXPTF           
         BM    RXEXPDE            longer than RXRAW             RXPTF           
         STM   R2,R5,RXSAVE                                     RXPTF           
         LA    R2,RXRAW           read                          RXPTF           
         LA    R3,0(R1,R2)        end                           RXPTF           
RXS1     CR    R2,R3              separators before dsname      RXPTF           
         BNL   RXSBAD                                           RXPTF           
         CLI   0(R2),C' '                                       RXPTF           
         BE    RXS1N                                            RXPTF           
         CLI   0(R2),C','                                       RXPTF           
         BNE   RXS2                                             RXPTF           
RXS1N    LA    R2,1(,R2)                                        RXPTF           
         B     RXS1                                             RXPTF           
RXS2     CLI   0(R2),C''''        quoted dsname?                RXPTF           
         BNE   RXS3                                             RXPTF           
RXS2Q    LA    R2,1(,R2)                                        RXPTF           
         CR    R2,R3                                            RXPTF           
         BNL   RXSBAD                                           RXPTF           
         CLI   0(R2),C''''                                      RXPTF           
         BNE   RXS2Q                                            RXPTF           
         LA    R2,1(,R2)          past its closing quote        RXPTF           
         B     RXS4                                             RXPTF           
RXS3     CR    R2,R3              unquoted: to blank/comma      RXPTF           
         BNL   RXSBAD                                           RXPTF           
         CLI   0(R2),C' '                                       RXPTF           
         BE    RXS4                                             RXPTF           
         CLI   0(R2),C','                                       RXPTF           
         BE    RXS4                                             RXPTF           
         LA    R2,1(,R2)                                        RXPTF           
         B     RXS3                                             RXPTF           
RXS4     CR    R2,R3              separators before value       RXPTF           
         BNL   RXSBAD                                           RXPTF           
         CLI   0(R2),C' '                                       RXPTF           
         BE    RXS4N                                            RXPTF           
         CLI   0(R2),C','                                       RXPTF           
         BNE   RXS5                                             RXPTF           
RXS4N    LA    R2,1(,R2)                                        RXPTF           
         B     RXS4                                             RXPTF           
RXS5     CLI   0(R2),C''''        the value list's quote        RXPTF           
         BNE   RXSBAD                                           RXPTF           
         LA    R2,1(,R2)                                        RXPTF           
         LR    R4,R2              write: halved in place        RXPTF           
         ST    R2,RXPARGA                                       RXPTF           
RXS6     CR    R2,R3                                            RXPTF           
         BNL   RXSEND             unclosed: ends the line       RXPTF           
         CLI   0(R2),C''''                                      RXPTF           
         BNE   RXS6C                                            RXPTF           
         LA    R5,1(,R2)                                        RXPTF           
         CR    R5,R3                                            RXPTF           
         BNL   RXSEND             closing quote                 RXPTF           
         CLI   0(R5),C''''                                      RXPTF           
         BNE   RXSEND             closing quote                 RXPTF           
         LA    R2,1(,R2)          '' : keep one                 RXPTF           
RXS6C    MVC   0(1,R4),0(R2)                                    RXPTF           
         LA    R4,1(,R4)                                        RXPTF           
         LA    R2,1(,R2)                                        RXPTF           
         B     RXS6                                             RXPTF           
RXSEND   S     R4,RXPARGA                                       RXPTF           
         ST    R4,RXPARGL                                       RXPTF           
         LM    R2,R5,RXSAVE                                     RXPTF           
         B     RXEXPA                                           RXPTF           
RXSBAD   LM    R2,R5,RXSAVE                                     RXPTF           
RXEXPDE  L     R1,RXVLPTR(,R7)    the PDE text                  RXPTF           
         ST    R1,RXPARGA                                       RXPTF           
         LH    R1,RXVLLNG(,R7)                                  RXPTF           
         ST    R1,RXPARGL                                       RXPTF           
RXEXPA   DS    0H                                               RXPTF           
         L     R15,=V(IKJCT43C)                                 RXPTF           
         CLC   OPER3-PAR1PDL(2,R7),=H'1'                        RXPTF           
         BNE   RXEXPC                                           RXPTF           
         L     R15,=V(IKJCT43F)                                 RXPTF           
RXEXPC   L     R0,CPPLPTR                                       RXPTF           
         LA    R1,RXPLIST                                       RXPTF           
         BALR  R14,R15                                          RXPTF           
         LTR   R15,R15                                          RXPTF           
         BZ    RXEXPCL            not REXX: go on as CLIST      RXPTF           
         SLR   R5,R5              ran as REXX: EXRETCDE = 0     RXPTF           
         B     @RC00450           common exit frees PDL and DD  RXPTF           
RXEXPCL  DS    0H                                               RXPTF           
*               ELSE                /* CHECK FOR SEQUENTIAL INPUT    */ 00649000
*                 IF SEQ8^=YES THEN /* IF NOT SEQUENTIAL THEN NOTIFY */ 00650000
         B     @RC00295                                            0299 00651000
@RF00295 L     R4,DAPB0PTR                                      DSKC190 00652000
         TM    SEQ8(R4),B'01000000'                             DSKC190 00653000
         BO    @RF00299                                            0299 00654000
*                   DO;             /* THE USER                      */ 00655000
*                     EXMSGID=M502; /* MESSAGE IDENTIFIER            */ 00656000
         MVC   EXMSGID(4),@CC01140                                 0301 00657000
*                     MVAR(1)=ADDR(DATSET);/* ADDR OF 'DATASET'      */ 00658000
         LA    R7,@CC01128                                      DSKC190 00659000
         ST    R7,MVAR                                          DSKC190 00660000
*                     MVARLEN(1)=LENGTH(DATSET);/* LEN OF 'DATASET'  */ 00661000
         MVI   MVARLEN,X'08'                                       0303 00662000
*                     MVAR(2)=ADDR(DATASETA);/* ADDRESS OF DSNAME    */ 00663000
         LA    R4,DATASETA                                      DSKC190 00664000
         ST    R4,MVAR+4                                        DSKC190 00665000
*                     MVARLEN(2)=DATASETL;/* DSNAME LENGTH           */ 00666000
         LH    R4,DATASETL                                      DSKC190 00667000
         STC   R4,MVARLEN+4                                     DSKC190 00667010
*                     ERROR=YES;    /* IKJCT430 ERROR                */ 00668000
         OI    ERROR,B'10000000'                                   0306 00669000
*                     CALL MSGRTN;  /* ISSUE MESSAGE                 */ 00670000
         BAL   R14,MSGRTN                                       DSKC190 00671000
*                   END;                                           0308 00672000
*                 ELSE                                             0309 00673000
*                   DO;             /* SEQUENTIAL INPUT              */ 00674000
         B     @RC00299                                            0309 00675000
@RF00299 DS    0H                                                  0310 00676000
*                     IF MEM=YES THEN/* MEMBERNAME SPECIFIED FOR PS  */ 00677000
         L     R7,ECDAEANS                                      DSKC190 00678000
         TM    MEM(R7),B'10000000'                              DSKC190 00679000
         BNO   @RF00310                                            0310 00680000
*                       DO;                                        0311 00681000
*                         EXMSGID=M521;/* MUST BE A PARTITIONED DS   */ 00682000
         MVC   EXMSGID(4),@CC01152                                 0312 00683000
*                         MVAR(1)=MEMPTR;                          0313 00684000
         L     R4,MEMPTR(,R7)                                   DSKC190 00685000
         ST    R4,MVAR                                          DSKC190 00686000
*                         MVARLEN(1)=MEMLNG;                       0314 00687000
         LH    R7,MEMLNG(,R7)                                   DSKC190 00688000
         STC   R7,MVARLEN                                       DSKC190 00688010
*                         MVAR(2)=ADDR(DATASETA);                  0315 00689000
         LA    R4,DATASETA                                      DSKC190 00690000
         ST    R4,MVAR+4                                        DSKC190 00691000
*                         MVARLEN(2)=DATASETL;                     0316 00692000
         LH    R4,DATASETL                                      DSKC190 00693000
         STC   R4,MVARLEN+4                                     DSKC190 00693010
*                         ERROR=YES;                               0317 00694000
         OI    ERROR,B'10000000'                                   0317 00695000
*                         CALL MSGRTN;                             0318 00696000
         BAL   R14,MSGRTN                                       DSKC190 00697000
*                       END;                                       0319 00698000
*                     SEQ=YES;      /* INDICATE SEQUENTIAL INPUT     */ 00699000
@RF00310 OI    SEQ,B'00100000'                                     0320 00700000
*                   END;                                           0321 00701000
*             END;                                                 0322 00702000
@RC00299 DS    0H                                                  0322 00703000
@RC00295 DS    0H                                                  0323 00704000
*         END;                                                     0323 00705000
@RC00264 DS    0H                                                  0324 00706000
*     END;                                                         0324 00707000
@RC00258 DS    0H                                                  0325 00708000
*                                                                  0325 00709000
*   /*****************************************************************/ 00710000
*   /*                                                               */ 00711000
*   /* STACK DATA SET I/O ELEMENT FOR INPUT DATA SET                 */ 00712000
*   /*                                                               */ 00713000
*   /*****************************************************************/ 00714000
*                                                                  0325 00715000
*   IF ERROR=NO THEN                /* IF NO ERRORS HAVE OCCURRED    */ 00716000
@RF00241 TM    ERROR,B'10000000'                                   0325 00717000
         BNZ   @RF00325                                            0325 00718000
*     DO;                           /* THEN CONTINUE EXEC PROCESS    */ 00719000
*       STACKG(1:MACLEN)=STACKL(1:MACLEN);/* COPY LIST FORMS OF    0327 00720000
*                                      MACROS                        */ 00721000
         L     R7,MACLEN                                        DSKC190 00722000
         BCTR  R7,0                                             DSKC190 00723000
         EX    R7,@SM01407                                      DSKC190 00724000
*       IOPLIOPB=ADDR(STACKG);      /* GET ADDR OF THE LIST FORM     */ 00725000
         LA    R4,STACKG                                        DSKC190 00726000
         L     R7,IOPLPTR                                       DSKC190 00727000
         ST    R4,IOPLIOPB(,R7)                                 DSKC190 00728000
*       RFY                                                        0329 00729000
*         R15 RSTD;                                                0329 00730000
*       IF SEQ=YES THEN             /* INPUT SEQUENTIAL, NO MEMBER   */ 00731000
         TM    SEQ,B'00100000'                                     0330 00732000
         BNO   @RF00330                                            0330 00733000
*         GEN(STACK  DATASET=(INDD=INDDNAME,PROMPT),MF=(E,SERVBLK));    00734000
         STACK  DATASET=(INDD=INDDNAME,PROMPT),MF=(E,SERVBLK)           00735000
*       ELSE                        /* PARTITIONED REQUIRES MEMBER   */ 00736000
*         GEN;                                                     0332 00737000
         B     @RC00330                                            0332 00738000
@RF00330 DS    0H                                                  0332 00739000
    STACK DATASET=(INDD=INDDNAME,MEMBER=PROCNAME,PROMPT),MF=(E,SERVBLK) 00740000
*         SRETCDE=R15;              /* SAVE RETURN CODE              */ 00741000
@RC00330 ST    R15,SRETCDE                                         0333 00742000
*       RFY                                                        0334 00743000
*         R15 UNRSTD;                                              0334 00744000
*       IF SRETCDE^=CON0 THEN       /* IF RETURN CODE IS NON ZERO    */ 00745000
         L     R4,SRETCDE                                       DSKC190 00746000
         LTR   R4,R4                                            DSKC190 00747000
         BZ    @RF00335                                            0335 00748000
*         DO;                       /* THEN NOTIFY THE USER OF ERROR */ 00749000
*           IF SRETCDE=CON8 THEN    /* =8 CANNOT OPEN DATASET        */ 00750000
         C     R4,@CF00059                                      DSKC190 00751000
         BNE   @RF00337                                            0337 00752000
*             DO;                                                  0338 00753000
*               EXMSGID=M523;       /* IDENTIFY THE MESSAGE          */ 00754000
         MVC   EXMSGID(4),@CC01148                                 0339 00755000
*               IF IMPLICIT=YES THEN/* FOR IMPLICIT INCLUDE 'SYSPROC'*/ 00756000
         TM    IMPLICIT,B'10000000'                                0340 00757000
         BNO   @RF00340                                            0340 00758000
*                 DO;               /* IN MESSAGE                    */ 00759000
*                   MVAR(1)=ADDR(FILE);/* ADDR OF 'FILE'             */ 00760000
         LA    R7,@CC01126                                      DSKC190 00761000
         ST    R7,MVAR                                          DSKC190 00762000
*                   MVARLEN(1)=LENGTH(FILE);/* LENGTH OF 'FILE'      */ 00763000
         MVI   MVARLEN,X'04'                                       0343 00764000
*                   MVAR(2)=ADDR(SYSPROC);/* ADDR OF 'SYSPROC'       */ 00765000
         LA    R4,@CC01116                                      DSKC190 00766000
         ST    R4,MVAR+4                                        DSKC190 00767000
*                   MVARLEN(2)=LENGTH(SYSPROC);/* LEN OF 'SYSPROC'   */ 00768000
         MVI   MVARLEN+4,X'08'                                     0345 00769000
*                 END;                                             0346 00770000
*               ELSE                /* FOR EXPLICIT INCLUDE THE      */ 00771000
*                 DO;               /* DATA SET NAME IN MESSAGE      */ 00772000
         B     @RC00340                                            0347 00773000
@RF00340 DS    0H                                                  0348 00774000
*                   MVAR(1)=ADDR(DATSET);/* ADDR OF 'DATASET'        */ 00775000
         LA    R7,@CC01128                                      DSKC190 00776000
         ST    R7,MVAR                                          DSKC190 00777000
*                   MVARLEN(1)=LENGTH(DATSET);/* LEN OF 'DATASET'    */ 00778000
         MVI   MVARLEN,X'08'                                       0349 00779000
*                   MVAR(2)=ADDR(DATASETA);/* ADDRESS OF DSNAME      */ 00780000
         LA    R4,DATASETA                                      DSKC190 00781000
         ST    R4,MVAR+4                                        DSKC190 00782000
*                   MVARLEN(2)=DATASETL;/* DSNAME LENGTH             */ 00783000
         LH    R4,DATASETL                                      DSKC190 00784000
         STC   R4,MVARLEN+4                                     DSKC190 00784010
*                 END;                                             0352 00785000
*             END;                                                 0353 00786000
*           ELSE                    /* CHECK RETURN CODE FURTHER     */ 00787000
*             IF SRETCDE=CON16 THEN /* 16 = MEMBER NOT FOUND         */ 00788000
         B     @RC00337                                            0354 00789000
@RF00337 CLC   SRETCDE(4),@CF01090                                 0354 00790000
         BNE   @RF00354                                            0354 00791000
*               DO;                                                0355 00792000
*                 IF IMPLICIT=YES THEN/* USE COMMAND NOT FOUND       */ 00793000
         TM    IMPLICIT,B'10000000'                                0356 00794000
         BNO   @RF00356                                            0356 00795000
*                   DO;             /* MESSAGE FOR IMPLICIT CMDS     */ 00796000
*                     IF ECTPCMD=EXECNME THEN/* IF ECT PRIMARY CMD 0358 00797000
*                                      WAS                           */ 00798000
         L     R7,CPPLPTR                                       DSKC190 00799000
         L     R4,ECTPTR(,R7)                                   DSKC190 00800000
         CLC   ECTPCMD(8,R4),@CC01130                           DSKC190 00801000
         BNE   @RF00358                                            0358 00802000
*                       MVAR(1)=CON0;/* EXEC THEN USE 'COMMAND'      */ 00803000
         SLR   R7,R7                                            DSKC190 00804000
         ST    R7,MVAR                                          DSKC190 00805000
*                     ELSE          /* OTHERWISE USE                 */ 00806000
*                       DO;         /* 'SUBCOMMAND' IN MESSAGE       */ 00807000
         B     @RC00358                                            0360 00808000
@RF00358 DS    0H                                                  0361 00809000
*                         MVAR(1)=ADDR(SUBC);/* ADDR OF 'SUB'        */ 00810000
         LA    R4,@CC01132                                      DSKC190 00811000
         ST    R4,MVAR                                          DSKC190 00812000
*                         MVARLEN(1)=LENGTH(SUBC);/* LEN OF 'SUB'    */ 00813000
         MVI   MVARLEN,X'03'                                       0362 00814000
*                       END;                                       0363 00815000
*                     MVAR(2)=ADDR(PROCNAME);/* ADDR OF NAME         */ 00816000
@RC00358 LA    R7,PROCNAME                                      DSKC190 00817000
         ST    R7,MVAR+4                                        DSKC190 00818000
*                     MVARLEN(2)=LENGTH(PROCNAME);/* LEN OF NAME     */ 00819000
         MVI   MVARLEN+4,X'08'                                     0365 00820000
*                     EXMSGID=M500; /* IDENTIFY THE MESSAGE          */ 00821000
         MVC   EXMSGID(4),@CC01134                                 0366 00822000
*                   END;                                           0367 00823000
*                 ELSE              /* OTHERWISE USE MEMBER NOT      */ 00824000
*                   DO;             /* IN DATASET MESSAGE            */ 00825000
         B     @RC00356                                            0368 00826000
@RF00356 DS    0H                                                  0369 00827000
*                     EXMSGID=M520; /* IDENTIFY THE MESSAGE          */ 00828000
         MVC   EXMSGID(4),@CC01150                                 0369 00829000
*                     MVAR(1)=ADDR(PROCNAME);/* ADDR OF MEMBER NAME  */ 00830000
         LA    R4,PROCNAME                                      DSKC190 00831000
         ST    R4,MVAR                                          DSKC190 00832000
*                     MVARLEN(1)=LENGTH(PROCNAME);/* LEN OF MEM NAME */ 00833000
         MVI   MVARLEN,X'08'                                       0371 00834000
*                     MVAR(2)=ADDR(DATASETA);/* ADDR OF DSNAME       */ 00835000
         LA    R7,DATASETA                                      DSKC190 00836000
         ST    R7,MVAR+4                                        DSKC190 00837000
*                     MVARLEN(2)=DATASETL;/* DSNAME LENGTH           */ 00838000
         LH    R7,DATASETL                                      DSKC190 00839000
         STC   R7,MVARLEN+4                                     DSKC190 00839010
*                   END;                                           0374 00840000
*               END;                                               0375 00841000
*             ELSE                  /* OTHERWISE USE THE DEFAULT     */ 00842000
*               IF SRETCDE=CON20 THEN/* IF STACK RETURN CODE IS 20   */ 00843000
         B     @RC00354                                            0376 00844000
@RF00354 CLC   SRETCDE(4),@CF01114                                 0376 00845000
         BNE   @RF00376                                            0376 00846000
*                 EXMSGID=M511;     /* INSUFFICIENT STORAGE MESSAGE  */ 00847000
         MVC   EXMSGID(4),@CC01154                                 0377 00848000
*               ELSE                                               0378 00849000
*                 DO;               /* ERROR CODE MESSAGE            */ 00850000
         B     @RC00376                                            0378 00851000
@RF00376 DS    0H                                                  0379 00852000
*                   EXMSGID=M524;   /* IDENTIFY MESSAGE              */ 00853000
         MVC   EXMSGID(4),@CC01144                                 0379 00854000
*                   MVAR(1)=ADDR(STCK);/* ADDR OF 'STACK'            */ 00855000
         LA    R4,@CC01124                                      DSKC190 00856000
         ST    R4,MVAR                                          DSKC190 00857000
*                   MVARLEN(1)=LENGTH(STCK);/* LEN OF 'STACK'        */ 00858000
         MVI   MVARLEN,X'05'                                       0381 00859000
*                   MVAR(2)=ADDR(SRETCDE);/* ADDR OF ERROR CODE      */ 00860000
         LA    R7,SRETCDE                                       DSKC190 00861000
         ST    R7,MVAR+4                                        DSKC190 00862000
*                   MVARLEN(2)=LENGTH(SRETCDE);/* LEN OF ERROR CODE  */ 00863000
         MVI   MVARLEN+4,X'04'                                     0383 00864000
*                   MVARHEX(2)=YES; /* VARIABLE IS DECIMAL           */ 00865000
         OI    MVARHEX+4,B'10000000'                               0384 00866000
*                 END;                                             0385 00867000
*           ERROR=YES;              /* IKJCT430 ERROR                */ 00868000
@RC00376 DS    0H                                                  0386 00869000
@RC00354 DS    0H                                                  0386 00870000
@RC00337 OI    ERROR,B'10000000'                                   0386 00871000
*           CALL MSGRTN;            /* ISSUE MESSAGE                 */ 00872000
         BAL   R14,MSGRTN                                       DSKC190 00873000
*         END;                                                     0388 00874000
*     END;                                                         0389 00875000
@RF00335 DS    0H                                                  0390 00876000
*                                                                  0390 00877000
*   /*****************************************************************/ 00878000
*   /*                                                               */ 00879000
*   /* GET THE FIRST RECORD FROM THE INPUT DATA SET                  */ 00880000
*   /*                                                               */ 00881000
*   /*****************************************************************/ 00882000
*                                                                  0390 00883000
*   IF ERROR=NO THEN                /* IF NO ERRORS HAVE OCCURRED    */ 00884000
@RF00325 TM    ERROR,B'10000000'                                   0390 00885000
         BNZ   @RF00390                                            0390 00886000
*     DO;                           /* THEN CONTINUE EXEC PROCESS    */ 00887000
*       IOPLIOPB=ADDR(GETLINEG);    /* ADDRESS OF GETLINE PARMS      */ 00888000
         LA    R4,GETLINEG                                      DSKC190 00889000
         L     R7,IOPLPTR                                       DSKC190 00890000
         ST    R4,IOPLIOPB(,R7)                                 DSKC190 00891000
*       DO;                         /* LOAD EP(IKJGETL)              */ 00892000
*         RESPECIFY                                                0394 00893000
*          (GPR00P,                                                0394 00894000
*           GPR01P) RESTRICTED;                                    0394 00895000
*         GPR00P=ADDR(IKJGETL);     /* LOAD ENTRY POINT NAME ADDRESS */ 00896000
         LA    R0,@CC01162                                      DSKC190 00897000
*         GPR01P=0;                 /* JOBLIB OR LINKLIB DCB         */ 00898000
         SLR   R1,R1                                            DSKC190 00899000
*         SVC(8);                   /* ISSUE LOAD SVC                */ 00900000
         SVC   8                                                   0397 00901000
*         RESPECIFY                                                0398 00902000
*          (GPR00P,                                                0398 00903000
*           GPR01P) UNRESTRICTED;                                  0398 00904000
*       END;                        /* LOAD EP(IKJGETL) LOAD GETLINE    00905000
*                                      TO SAVE TIME                  */ 00906000
*       RFY                                                        0400 00907000
*         R0 RSTD;                                                 0400 00908000
*       ECDAGETL=R0;                /* SAVE ENTRY ADDRESS            */ 00909000
         ST    R0,ECDAGETL                                         0401 00910000
*       RFY                                                        0402 00911000
*         R0 UNRSTD;                                               0402 00912000
*       GETLLOAD=YES;               /* GETLINE IS LOADED             */ 00913000
         OI    GETLLOAD,B'00000100'                                0403 00914000
*       ECDASPTR=SERVPTR;           /* SAVE ADDRESS FOR IKJCT432     */ 00915000
         L     R7,SERVPTR                                       DSKC190 00916000
         ST    R7,ECDASPTR                                      DSKC190 00917000
*       CALL GETALINE;              /* GET THE FIRST RECORD          */ 00918000
         BAL   R14,GETALINE                                     DSKC190 00919000
*       IF SRETCDE>CON4 THEN        /* IF ERRORS OR END OF FILE NO 0406 00920000
*                                      MORE PROCESSING CAN OCCUR     */ 00921000
         L     R4,SRETCDE                                       DSKC190 00922000
         C     R4,@CF00095                                      DSKC190 00923000
         BNH   @RF00406                                            0406 00924000
*         IF SRETCDE=CON16 THEN     /* IF END OF FILE ON FIRST CALL  */ 00925000
         C     R4,@CF01090                                      DSKC190 00926000
         BNE   @RF00407                                            0407 00927000
*           DO;                     /* THEN NOTIFY THE USER          */ 00928000
*             EMPTY=YES;            /* DATA SET IS EMPTY             */ 00929000
         OI    EMPTY,B'00001000'                                   0409 00930000
*             EXMSGID=M501;         /* IDENTIFY THE MESSAGE          */ 00931000
         MVC   EXMSGID(4),@CC01136                                 0410 00932000
*             CALL MSGRTN;          /* ISSUE MESSAGE                 */ 00933000
         BAL   R14,MSGRTN                                       DSKC190 00934000
*           END;                                                   0412 00935000
*         ELSE                                                     0413 00936000
*           ;                       /* BYPASS FURTHER PROCESSING     */ 00937000
@RF00407 DS    0H                                                  0414 00938000
*                                                                  0414 00939000
*       /*************************************************************/ 00940000
*       /*                                                           */ 00941000
*       /* CALL SYMBOLIC PARAMETER DEFINITION TO INITIALIZE THE      */ 00942000
*       /* CONTROL VARIABLES AND PROC STATEMENT VARIABLES            */ 00943000
*       /*                                                           */ 00944000
*       /*************************************************************/ 00945000
*                                                                  0414 00946000
*       ELSE                        /* OTHERWISE PASS FIRST RECORD   */ 00947000
*         DO;                       /* TO IKJCT431                   */ 00948000
         B     @RC00406                                            0414 00949000
@RF00406 DS    0H                                                  0415 00950000
*           RFY                                                    0415 00951000
*            (R1,                                                  0415 00952000
*             R15) RSTD;                                           0415 00953000
*           R1=ADDR(ECDA);          /* ADDRESS OF ECDA PARMS CALL  0416 00954000
*                                      SYMBOLIC PARAMETER            */ 00955000
         LA    R1,ECDA                                             0416 00956000
*           CALL IKJCT431;          /* DEFINITION TO INITIALIZE    0417 00957000
*                                      SYMBOLIC PARAMETERS           */ 00958000
         L     R15,@CV01308                                     DSKC190 00959000
         BALR  R14,R15                                          DSKC190 00960000
*           IF R15<=CON4 THEN       /* RETURN CODE > 4 STARTS THE    */ 00961000
         LR    R2,R15                                           DSKC190 00962000
*             DO;                   /* TERMINATION PROCESS           */ 00965000
*                                                                  0419 00966000
*               /*****************************************************/ 00967000
*               /*                                                   */ 00968000
*               /* A RETURN CODE OF ZERO FROM IKJCT431 INDICATES THE */ 00969000
*               /* FIRST RECORD WAS NOT A PROC STATEMENT AND SHOULD  */ 00970000
*               /* BE PASSED ON TO IKJCT432. A RETURN CODE OF FOUR   */ 00971000
*               /* FROM IKJCT431 INDICATES THE FIRST RECORD WAS A    */ 00972000
*               /* PROC STATEMENT AND SHOULD NOT BE PASSED TO        */ 00973000
*               /* IKJCT432 - GET THE NEXT RECORD.                   */ 00974000
*               /*                                                   */ 00975000
*               /*****************************************************/ 00976000
*                                                                  0420 00977000
*               IF R15=CON4 THEN    /* IF RETURN CODE = FOUR THEN    */ 00978000
         C     R2,@CF00059                                      DSKC190 00979000
         BNE   A0007BC                                          DSKC190 00980000
*                 CALL GETALINE;    /* THEN GET NEXT INPUT RECORD    */ 00981000
         BAL   R14,GETALINE                                     DSKC190 00982000
A0007BC  L     R0,SRETCDE                                       DSKC190 00982010
         C     R0,@CF00095                                      DSKC190 00982020
         BH    A0007D0                                          DSKC190 00982030
         C     R2,@CF00059                                      DSKC190 00982040
         BE    @RF00406                                         DSKC190 00982050
A0007D0  LR    R15,R2                                           DSKC190 00982060
         SLR   R2,R2                                            DSKC190 00982070
         C     R15,@CF00059                                     DSKC190 00982080
         BH    @RF00436                                         DSKC190 00982090
         C     R15,@CF00095                                     DSKC190 00982100
         BNE   @RF00420                                         DSKC190 00982110
         BAL   R14,GETALINE                                     DSKC190 00982120
*               RFY                                                0422 00983000
*                (R1,                                              0422 00984000
*                 R15) UNRSTD;                                     0422 00985000
@RF00420 DS    0H                                                  0423 00986000
*                                                                  0423 00987000
*               /*****************************************************/ 00988000
*               /*                                                   */ 00989000
*               /* CALL RECORD SCAN ROUTINE TO INTERPRET THE         */ 00990000
*               /* STATEMENTS IN THE INPUT DATA SET AND BUILD THE    */ 00991000
*               /* COMMAND PROCEDURE                                 */ 00992000
*               /*                                                   */ 00993000
*               /*****************************************************/ 00994000
*                                                                  0423 00995000
*               ECDAAEND(1:LENGTH(ALTEND))=ALTEND;/* INITIALIZE THE  */ 00996000
         MVC   ECDAAEND(3),@CC01118                                0423 00997000
*               ECDAELNG=LENGTH(ALTEND);/* ALTERNATE END TO 'END'    */ 00998000
         MVC   ECDAELNG(2),@CH00093                                0424 00999000
*               CT432PRM=''B;       /* INITIALIZE THE IKJCT432 PARMS */ 01000000
         XC    CT432PRM(12),CT432PRM                               0425 01001000
*               CDAPTR=ADDR(ECDA);  /* NO FLAGS                      */ 01002000
         LA    R3,ECDA                                          DSKC190 01003000
         ST    R3,CDAPTR                                        DSKC190 01004000
*               DO WHILE SRETCDE=4& /* SRETCDE HAS RETURN CODE FROM  */ 01005000
*                     RSRRET=0;     /* LAST GETLINE - INITIALLY THAT */ 01006000
         B     @DE00427                                            0427 01007000
@DL00427 DS    0H                                                  0428 01008000
*                 RFY                                              0428 01009000
*                  (R1,                                            0428 01010000
*                   R15) RSTD;      /* FROM THE FIRST GETLINE IF   0428 01011000
*                                      FIRST RECORD NOT PROC STMT OR    01012000
*                                      THAT FROM SECOND GETLINE    0428 01013000
*                                      ISSUED ABOVE                  */ 01014000
*                 R1=ADDR(CT432PRM);/* ADDRESS OF IKJCT432 PARMS     */ 01015000
         LA    R1,CT432PRM                                         0429 01016000
*                 CALL IKJCT432;    /* SCAN INPUT RECORD             */ 01017000
         L     R15,@CV01310                                     DSKC190 01018000
         BALR  R14,R15                                          DSKC190 01019000
*                 RSRRET=R15;       /* SAVE RETURN CODE              */ 01020000
         LR    R2,R15                                           DSKC190 01021000
*                 RFY                                              0432 01022000
*                  (R1,                                            0432 01023000
*                   R15) UNRSTD;                                   0432 01024000
*                 IF RSRRET=CON0 THEN/* IF NO ERRORS THEN            */ 01025000
         LTR   R2,R2                                            DSKC190 01026000
         BNZ   @RF00433                                            0433 01027000
*                   CALL GETALINE;  /* GET NEXT RECORD               */ 01028000
         BAL   R14,GETALINE                                     DSKC190 01029000
*               END;                /* RETURN CODE>0 FROM RECORD SCAN   01030000
*                                      INDICATES NO FURTHER        0435 01031000
*                                      PROCESSING NECESSARY          */ 01032000
*                                                                  0435 01033000
@RF00433 DS    0H                                                  0435 01034000
@DE00427 CLC   SRETCDE(4),@CF00095                                 0435 01035000
         BNE   @DC00427                                            0435 01036000
         LTR   R2,R2                                            DSKC190 01037000
         BZ    @DL00427                                            0435 01038000
@DC00427 DS    0H                                                  0436 01039000
*               /*****************************************************/ 01040000
*               /*                                                   */ 01041000
*               /* IF RECORD SCAN ROUTINE (IKJCT432) ENDED NORMALLY  */ 01042000
*               /* THEN GENERATE AN INTERNAL GOTO AT END OF COMMAND  */ 01043000
*               /* PROCEDURE TO ALLOW RETURN CODE CHECKS ON THE LAST */ 01044000
*               /* COMMAND IN PROCEDURE                              */ 01045000
*               /*                                                   */ 01046000
*               /*****************************************************/ 01047000
*                                                                  0436 01048000
*               IF RSRRET^>CON4 THEN/* IF RECORD SCAN ENDED NORMALLY */ 01049000
         C     R2,@CF00095                                      DSKC190 01050000
         BH    @RF00436                                            0436 01051000
*                 DO;               /* THEN GENERATE AN INTERNAL GOTO*/ 01052000
*                   IGOTOLL=LENGTH(IGOTOMAP);/* SET LENGTH FIELD     */ 01053000
         L     R4,ECDACNXT                                      DSKC190 01054000
         LA    R7,11                                            DSKC190 01055000
         STCM  R7,3,IGOTOLL(R4)                                 DSKC190 01056000
*                   IGOTOOO=LENGTH(IGOTOMAP)-CON4;/* SET OFFSET      */ 01057000
         LA    R8,7                                             DSKC190 01058000
         STCM  R8,3,IGOTOOO(R4)                                 DSKC190 01059000
*                   IGOTOO2=IGOTOOO;/* SET SECONDARY OFFSET          */ 01060000
         STCM  R8,3,IGOTOO2(R4)                                 DSKC190 01061000
*                   IGOTOOP=GOTOOP; /* GOTO OP CODE                  */ 01062000
         MVI   IGOTOOP(R4),X'0F'                                DSKC190 01063000
*                   IGOTOADD=ECDACNXT+IGOTOLL;/* GOTO TARGET ADDRESS */ 01064000
         LR    R9,R4                                            DSKC190 01065000
         ALR   R9,R7                                            DSKC190 01066000
         STCM  R9,15,IGOTOADD(R4)                               DSKC190 01067000
*                   COMPRUSE=COMPRUSE+IGOTOLL;/* ADJUST AMT IN USE   */ 01068000
         L     R8,ECDACBLK                                      DSKC190 01069000
         AL    R7,COMPRUSE(,R8)                                 DSKC190 01070000
         ST    R7,COMPRUSE(,R8)                                 DSKC190 01071000
*                   ECDACPRE=ECDACNXT;/* ADDRESS OF PREVIOUS RECORD  */ 01072000
         ST    R4,ECDACPRE                                      DSKC190 01073000
*                   ECDACNXT=IGOTOADD;/* ADDRESS OF NEXT RECORD      */ 01074000
         ST    R9,ECDACNXT                                      DSKC190 01075000
*                 END;                                             0446 01076000
*             END;                                                 0447 01077000
@RF00436 DS    0H                                                  0448 01078000
*         END;                                                     0448 01079000
@RF00418 DS    0H                                                  0449 01080000
*     END;                                                         0449 01081000
@RC00406 DS    0H                                                  0450 01082000
*                                                                  0450 01083000
*   /*****************************************************************/ 01084000
*   /*                                                               */ 01085000
*   /* START OF THE TERMINATION PROCESS                              */ 01086000
*   /*                                                               */ 01087000
*   /*****************************************************************/ 01088000
*                                                                  0450 01089000
*EXIT:                                                             0450 01090000
*   IF ERROR=YES×EMPTY=YES THEN     /* IF THERE WERE ERRORS DURING   */ 01091000
@RF00390 DS    0H                                                  0450 01092000
EXIT     TM    ERROR,B'10001000'                                   0450 01093000
         BZ    @RF00450                                            0450 01094000
*     DO;                           /* IKJCT430 PROCESSING OR THE  0451 01095000
*                                      INPUT DATA SET WAS EMPTY THEN    01096000
*                                      BYAPSS FREEING OF CORE        */ 01097000
*       IF ERROR=YES THEN           /* ERRORS, RETURN CODE IS 12     */ 01098000
         TM    ERROR,B'10000000'                                   0452 01099000
         BNO   @RF00452                                            0452 01100000
*         EXRETCDE=CON12;                                          0453 01101000
         LA    R5,12                                            DSKC190 01102000
*       ELSE                        /* EMPTY, RETURN CODE IS 0       */ 01103000
*         EXRETCDE=CON0;                                           0454 01104000
         B     @RC00452                                            0454 01105000
@RF00452 SLR   R5,R5                                            DSKC190 01106000
*     END;                                                         0455 01107000
*   ELSE                            /* START CLEANUP PROCESS         */ 01108000
*     DO;                                                          0456 01109000
*                                                                  0456 01110000
         B     @RC00450                                            0456 01111000
@RF00450 DS    0H                                                  0457 01112000
*       /*************************************************************/ 01113000
*       /*                                                           */ 01114000
*       /* IF NO ERRORS HAVE OCCURRED THEN CLEANUP SP 78 STORAGE AND */ 01115000
*       /* PLACE THE COMMAND PROCEDURE ON THE INPUT STACK            */ 01116000
*       /*                                                           */ 01117000
*       /*************************************************************/ 01118000
*                                                                  0457 01119000
*                                   /* IF THE PROC IS EXECUTABLE     */ 01120000
*       IF NOTEXEC=NO THEN          /* THEN FREE UP UNUSED STORAGE   */ 01121000
         TM    NOTEXEC,B'01000000'                                 0457 01122000
         BNZ   @RF00457                                            0457 01123000
*         DO;                       /* IN LAST COMMAND PROCEDURE BLK */ 01124000
*           FREEADDR=(CPRECNXT+CON7)/CON8*CON8;                    0459 01125000
         LA    R8,7                                             DSKC190 01126000
         SLR   R7,R7                                            DSKC190 01127000
         ICM   R7,7,CPRECNXT                                    DSKC190 01128000
         ALR   R8,R7                                            DSKC190 01129000
         SRDA  R8,32                                            DSKC190 01130000
         D     R8,@CF00059                                      DSKC190 01131000
         SLA   R9,3                                             DSKC190 01132000
         ST    R9,FREEADDR                                      DSKC190 01133000
*           FREEAMT=CPBLKPTR+COMPRLNG-FREEADDR;                    0460 01134000
         L     R4,ECDACBLK                                      DSKC190 01135000
         SLR   R2,R2                                            DSKC190 01136000
         ICM   R2,7,CPBLKPTR                                    DSKC190 01137000
         AL    R2,COMPRLNG(,R4)                                 DSKC190 01138000
         SLR   R2,R9                                            DSKC190 01139000
*           COMPRLNG=COMPRUSE;      /* ADJUST LENGTH                 */ 01140000
         L     R7,COMPRUSE(,R4)                                 DSKC190 01141000
         ST    R7,COMPRLNG(,R4)                                 DSKC190 01142000
*           CALL FREESTG;           /* FREE THE STORAGE              */ 01143000
         BAL   R14,FREESTG                                      DSKC190 01144000
*                                                                  0463 01145000
*           /*********************************************************/ 01146000
*           /*                                                       */ 01147000
*           /* PLACE THE COMMAND PROCEDURE ON THE INPUT STACK        */ 01148000
*           /*                                                       */ 01149000
*           /*********************************************************/ 01150000
*                                                                  0463 01151000
*           LSDTOTLN=LSDADATA->COMPRLNG;/* SET TOTAL LENGTH OF FIRST    01152000
*                                      BLOCK                         */ 01153000
         L     R4,LSDPTR                                        DSKC190 01154000
         L     R7,LSDADATA(,R4)                                 DSKC190 01155000
         L     R7,COMPRLNG(,R7)                                 DSKC190 01156000
         STH   R7,LSDTOTLN(,R4)                                 DSKC190 01157000
*           ECDALNEL->SNTLAST=YES;  /* INDICATE END OF LAST SNTAB    */ 01158000
*                                                                  0464 01159000
         L     R7,ECDALNEL                                      DSKC190 01160000
         OI    SNTLAST(R7),B'00000001'                          DSKC190 01161000
*           /*********************************************************/ 01162000
*           /*                                                       */ 01163000
*           /* IF THIS IS THE FIRST LEVEL CLIST THEN ESTABLISH THE   */ 01164000
*           /* MAXIMUM THAT CAN BE REFERENCED BY LATER NESTED LEVELS */ 01165000
*           /*                                                       */ 01166000
*           /*********************************************************/ 01167000
*                                                                  0465 01168000
*           IF INSEXEC=NO THEN      /* CHECK FOR NESTED LEVEL        */ 01169000
         L     R7,CPPLPTR                                       DSKC190 01170000
         L     R7,ECTPTR(,R7)                                   DSKC190 01171000
         L     R7,ECTIOWA(,R7)                                  DSKC190 01172000
         L     R7,IOSTELM(,R7)                                  DSKC190 01173000
         TM    INSEXEC(R7),B'00001000'                          DSKC190 01174000
         BNZ   @RF00465                                            0465 01175000
*             GEXECCNT=ECDAGCNT-CON1;/* IF FIRST, SET MAX            */ 01176000
         L     R4,LSDEXEC(,R4)                                  DSKC190 01177000
         L     R7,ECDAGCNT                                      DSKC190 01178000
         BCTR  R7,0                                             DSKC190 01179000
         ST    R7,GEXECCNT(,R4)                                 DSKC190 01180000
*           STACKG(1:MACLEN)=STACKL(1:MACLEN);/* COPY LIST FORMS     */ 01181000
@RF00465 L     R4,MACLEN                                        DSKC190 01182000
         BCTR  R4,0                                             DSKC190 01183000
         EX    R4,@SM01407                                      DSKC190 01184000
*           IOPLIOPB=ADDR(STACKG);  /* ADDR OF STACK PARM BLOCK      */ 01185000
         LA    R7,STACKG                                        DSKC190 01186000
         L     R4,IOPLPTR                                       DSKC190 01187000
         ST    R7,IOPLIOPB(,R4)                                 DSKC190 01188000
*           RFY                                                    0469 01189000
*            (R1,                                                  0469 01190000
*             R2,                                                  0469 01191000
*             R15) RSTD;                                           0469 01192000
*           R1=SERVPTR;             /* INPUT PARMLIST                */ 01193000
         L     R1,SERVPTR                                          0470 01194000
*           R2=ADDR(LSD);           /* ADDR OF THE LSD               */ 01195000
         L     R2,LSDPTR                                        DSKC190 01196000
*           IF IMPLICIT=NO&PRMPPDE=CON1 THEN/* PROMPT OPTION       0472 01197000
*                                      SPECIFIED, THEN ISSUE STACK 0472 01198000
*                                      WITH CORRECT                  */ 01199000
         TM    IMPLICIT,B'10000000'                                0472 01200000
         BNZ   @RF00472                                            0472 01201000
         L     R3,ECDAEANS                                      DSKC190 01202000
         CLC   PRMPPDE(2,R3),@CH00033                           DSKC190 01203000
         BNE   @RF00472                                            0472 01204000
*             IF LISTPDE=CON2 THEN  /* LIST OPTION - LIST IS ASSUMED */ 01205000
         CLC   LISTPDE(2,R3),@CH00091                           DSKC190 01206000
         BNE   @RF00473                                            0473 01207000
*               GEN(STACK STORAGE=((2),PROCN,PROMPT),MF=(E,(1)));  0474 01208000
         STACK STORAGE=((2),PROCN,PROMPT),MF=(E,(1))                    01209000
*             ELSE                  /* UNLESS NOLIST SPECIFIED       */ 01210000
*               GEN(STACK STORAGE=((2),PROCL,PROMPT),MF=(E,(1)));  0475 01211000
         B     @RC00473                                            0475 01212000
@RF00473 DS    0H                                                  0475 01213000
         STACK STORAGE=((2),PROCL,PROMPT),MF=(E,(1))                    01214000
*           ELSE                    /* IF PROMPT NOT SPECIFIED THEN  */ 01215000
*             IF IMPLICIT=NO&LISTPDE=CON1 THEN/* ISSUE STACK WITH  0476 01216000
*                                      CORRECT LIST                  */ 01217000
         B     @RC00472                                            0476 01218000
@RF00472 TM    IMPLICIT,B'10000000'                                0476 01219000
         BNZ   @RF00476                                            0476 01220000
         L     R4,ECDAEANS                                      DSKC190 01221000
         CLC   LISTPDE(2,R4),@CH00033                           DSKC190 01222000
         BNE   @RF00476                                            0476 01223000
*               GEN(STACK STORAGE=((2),PROCL),MF=(E,(1)));/* OPTION  */ 01224000
         STACK STORAGE=((2),PROCL),MF=(E,(1))                           01225000
*             ELSE                                                 0478 01226000
*               GEN(STACK STORAGE=((2),PROCN),MF=(E,(1)));         0478 01227000
         B     @RC00476                                            0478 01228000
@RF00476 DS    0H                                                  0478 01229000
         STACK STORAGE=((2),PROCN),MF=(E,(1))                           01230000
*           SRETCDE=R15;            /* SAVE STACK RETURN CODE        */ 01231000
@RC00476 DS    0H                                                  0479 01232000
@RC00472 ST    R15,SRETCDE                                         0479 01233000
*           RFY                                                    0480 01234000
*            (R1,                                                  0480 01235000
*             R2,                                                  0480 01236000
*             R15) UNRSTD;                                         0480 01237000
*                                                                  0481 01238000
*           /*********************************************************/ 01239000
*           /*                                                       */ 01240000
*           /* DETERMINE IF STACK SUCCESSFUL                         */ 01241000
*           /*                                                       */ 01242000
*           /*********************************************************/ 01243000
*                                                                  0481 01244000
*           IF SRETCDE^=CON0 THEN   /* IF RETURN CODE NOT ZERO THEN  */ 01245000
         L     R7,SRETCDE                                       DSKC190 01246000
         LTR   R7,R7                                            DSKC190 01247000
         BZ    @RF00481                                            0481 01248000
*             DO;                   /* NOTIFY THE USER OF ERROR      */ 01249000
*               MVAR(1)=ADDR(STCK); /* ADDR OF 'STACK'               */ 01250000
         LA    R4,@CC01124                                      DSKC190 01251000
         ST    R4,MVAR                                          DSKC190 01252000
*               MVARLEN(1)=LENGTH(STCK);/* LENGTH OF 'STACK'         */ 01253000
         MVI   MVARLEN,X'05'                                       0484 01254000
*               MVAR(2)=ADDR(SRETCDE);/* ADDR OF RETURN CODE AREA    */ 01255000
         LA    R7,SRETCDE                                       DSKC190 01256000
         ST    R7,MVAR+4                                        DSKC190 01257000
*               MVARLEN(2)=LENGTH(SRETCDE);/* LEN OF RETURN CODE AREA*/ 01258000
         MVI   MVARLEN+4,X'04'                                     0486 01259000
*               MVARHEX(2)=YES;     /* RETURN CODE IS DECIMAL        */ 01260000
         OI    MVARHEX+4,B'10000000'                               0487 01261000
*               EXMSGID=M524;       /* IDENTIFY THE MESSAGE          */ 01262000
         MVC   EXMSGID(4),@CC01144                                 0488 01263000
*               CALL MSGRTN;        /* ISSUE THE MESSAGE             */ 01264000
         BAL   R14,MSGRTN                                       DSKC190 01265000
*               NOTEXEC=YES;        /* PROC IS NOT EXECUTABLE        */ 01266000
         OI    NOTEXEC,B'01000000'                                 0490 01267000
*             END;                                                 0491 01268000
*           ELSE                    /* OTHERWISE THE STACK WAS       */ 01269000
*             DO;                   /* SUCCESSFUL SO                 */ 01270000
         B     @RC00481                                            0492 01271000
@RF00481 DS    0H                                                  0493 01272000
*               INSEXEC=YES;        /* TURN ON THE EXEC STACK        */ 01273000
         L     R4,CPPLPTR                                       DSKC190 01274000
         L     R7,ECTPTR(,R4)                                   DSKC190 01275000
         L     R4,ECTIOWA(,R7)                                  DSKC190 01276000
         L     R7,IOSTELM(,R4)                                  DSKC190 01277000
         OI    INSEXEC(R7),B'00001000'                          DSKC190 01278000
*               EXRETCDE=CON0;      /* INDICATOR AND ZERO THE RETURN    01279000
*                                      CODE                          */ 01280000
         SLR   R5,R5                                            DSKC190 01281000
*             END;                                                 0495 01282000
*         END;                                                     0496 01283000
@RC00481 DS    0H                                                  0497 01284000
*                                                                  0497 01285000
*       /*************************************************************/ 01286000
*       /*                                                           */ 01287000
*       /* IF ERRORS HAVE OCCURRED DURING PHASE 1 PROCESSING OR WE   */ 01288000
*       /* HAD AN ERROR ATTEMPTING TO PLACE THE COMMAND PROCEDURE ON */ 01289000
*       /* THE INPUT STACK THEN FREE ALL SP78 TABLES AND FLUSH THE   */ 01290000
*       /* STACK                                                     */ 01291000
*       /*                                                           */ 01292000
*       /*************************************************************/ 01293000
*                                                                  0497 01294000
*       IF NOTEXEC=YES THEN         /* IF THE PROC CAN NOT BE        */ 01295000
@RF00457 TM    NOTEXEC,B'01000000'                                 0497 01296000
         BNO   @RF00497                                            0497 01297000
*         DO;                       /* EXECUTED THEN START CLEANUP   */ 01298000
*           EXRETCDE=CON12;         /* RETURN CODE IS 12             */ 01299000
         LA    R5,12                                            DSKC190 01300000
*           IF SP78CORE=YES THEN    /* IF WE HAVE CORE THEN IT MUST  */ 01301000
         TM    SP78CORE,B'00100000'                                0500 01302000
         BNO   @RF00500                                            0500 01303000
*             DO;                   /* BE FREED                      */ 01304000
*               IF SP78BLK=YES THEN /* IF WE WERE IN THE PROCESS OF  */ 01305000
         TM    SP78BLK,B'00000100'                                 0502 01306000
         BNO   @RF00502                                            0502 01307000
*                 DO;               /* CARVING UP THE INITIAL GETMAIN*/ 01308000
*                   FREEADDR=ECDAGADD;/* THEN MASS FREE THE TOTAL    */ 01309000
         L     R3,ECDAGADD                                      DSKC190 01310000
         ST    R3,FREEADDR                                      DSKC190 01311000
*                   FREEAMT=GETSIZE;/* BLOCK                         */ 01312000
         L     R2,@CF01101                                      DSKC190 01313000
*                   CALL FREESTG;   /* ISSUE FREEMAIN                */ 01314000
         BAL   R14,FREESTG                                      DSKC190 01315000
*                 END;                                             0507 01316000
*                                                                  0507 01317000
*               /*****************************************************/ 01318000
*               /*                                                   */ 01319000
*               /* IF WE HAVE BROKEN IT UP THEN WE MUST FREE ALL THE */ 01320000
*               /* PIECES                                            */ 01321000
*               /*                                                   */ 01322000
*               /*****************************************************/ 01323000
*                                                                  0508 01324000
*               ELSE                                               0508 01325000
*                 DO;                                              0508 01326000
         B     @RC00502                                            0508 01327000
@RF00502 DS    0H                                                  0509 01328000
*                   IF ECDALSD^=CON0 THEN/* IF TABLES HAVE NOT BEEN  */ 01329000
         L     R4,ECDALSD                                       DSKC190 01330000
         LTR   R4,R4                                            DSKC190 01331000
         BZ    @RF00509                                            0509 01332000
*                     DO;           /* FREED THEN FREE THE STORAGE   */ 01333000
*                                                                  0510 01334000
*                       /*********************************************/ 01335000
*                       /*                                           */ 01336000
*                       /* FREE THE SNTAB TABLE(S)                   */ 01337000
*                       /*                                           */ 01338000
*                       /*********************************************/ 01339000
*                                                                  0511 01340000
*                       DO WHILE SNTABFST^=CON0;/* ZERO FORWARD      */ 01341000
         B     @DE00511                                            0511 01342000
@DL00511 DS    0H                                                  0512 01343000
*                         FREEADDR=SNTABFST;/* ADDRESS INDICATES END */ 01344000
         L     R7,LSDPTR                                        DSKC190 01345000
         L     R3,LSDEXEC(,R7)                                  DSKC190 01346000
         L     R4,SNTABFST(,R3)                                 DSKC190 01347000
         ST    R4,FREEADDR                                      DSKC190 01348000
*                         FREEAMT=SNTABFST->SNTABLNG;              0513 01349000
         L     R2,SNTABLNG(,R4)                                 DSKC190 01350000
*                         SNTABFST=SNTABFST->SNTABNXT;             0514 01351000
         L     R4,SNTABNXT(,R4)                                 DSKC190 01352000
         ST    R4,SNTABFST(,R3)                                 DSKC190 01353000
*                         CALL FREESTG;/* ISSUE FREEMAIN             */ 01354000
         BAL   R14,FREESTG                                      DSKC190 01355000
*                       END;                                       0516 01356000
@DE00511 L     R7,LSDPTR                                        DSKC190 01357000
         L     R4,LSDEXEC(,R7)                                  DSKC190 01358000
         L     R7,SNTABFST(,R4)                                 DSKC190 01359000
         LTR   R7,R7                                            DSKC190 01360000
         BNZ   @DL00511                                            0516 01361000
*                                                                  0517 01362000
*                       /*********************************************/ 01363000
*                       /*                                           */ 01364000
*                       /* FREE THE SVTAB TABLE(S)                   */ 01365000
*                       /*                                           */ 01366000
*                       /*********************************************/ 01367000
*                                                                  0517 01368000
*                       DO WHILE SVTABFST^=CON0;/* ZERO FORWARD      */ 01369000
         B     @DE00517                                            0517 01370000
@DL00517 DS    0H                                                  0518 01371000
*                         FREEADDR=SVTABFST;/* POINTER INDICATES END */ 01372000
         L     R3,LSDPTR                                        DSKC190 01373000
         L     R4,LSDEXEC(,R3)                                  DSKC190 01374000
         L     R7,SVTABFST(,R4)                                 DSKC190 01375000
         ST    R7,FREEADDR                                      DSKC190 01376000
*                         FREEAMT=SVTABFST->SVTABLNG;              0519 01377000
         L     R2,SVTABLNG(,R7)                                 DSKC190 01378000
*                         SVTABFST=SVTABFST->SVTABNXT;             0520 01379000
         L     R3,SVTABNXT(,R7)                                 DSKC190 01380000
         ST    R3,SVTABFST(,R4)                                 DSKC190 01381000
*                         CALL FREESTG;/* ISSUE FREEMAIN             */ 01382000
         BAL   R14,FREESTG                                      DSKC190 01383000
*                       END;                                       0522 01384000
*                                                                  0522 01385000
@DE00517 SLR   R4,R4                                            DSKC190 01386000
         L     R7,LSDPTR                                        DSKC190 01387000
         L     R8,LSDEXEC(,R7)                                  DSKC190 01388000
         C     R4,SVTABFST(,R8)                                 DSKC190 01389000
         BNE   @DL00517                                            0522 01390000
*                       /*********************************************/ 01391000
*                       /*                                           */ 01392000
*                       /* FREE THE EXECDATA TABLE                   */ 01393000
*                       /*                                           */ 01394000
*                       /*********************************************/ 01395000
*                                                                  0523 01396000
*                       IF LSDEXEC^=CON0 THEN/* IF THE EXECDATA HAS  */ 01397000
         CR    R8,R4                                            DSKC190 01398000
         BE    @RF00523                                            0523 01399000
*                         DO;       /* NOT BEEN FREED THEN FREE IT   */ 01400000
*                           FREEADDR=LSDEXEC;/* ADDRESS OF EXECDATA  */ 01401000
         ST    R8,FREEADDR                                      DSKC190 01402000
*                           FREEAMT=LENGTH(EXECDATA);              0526 01403000
         LA    R2,64                                            DSKC190 01404000
*                           LSDEXEC=CON0;/* INDICATE HAS BEEN FREED  */ 01405000
         ST    R4,LSDEXEC(,R7)                                  DSKC190 01406000
*                           CALL FREESTG;/* ISSUE FREEMAIN           */ 01407000
         BAL   R14,FREESTG                                      DSKC190 01408000
*                         END;                                     0529 01409000
*                                                                  0529 01410000
*                       /*********************************************/ 01411000
*                       /*                                           */ 01412000
*                       /* FREE THE COMMAND PROCEDURE BLOCK(S)       */ 01413000
*                       /*                                           */ 01414000
*                       /*********************************************/ 01415000
*                                                                  0530 01416000
*                       DO WHILE LSDADATA^=CON0;/* ZERO FORWARD      */ 01417000
@RF00523 B     @DE00530                                            0530 01418000
@DL00530 DS    0H                                                  0531 01419000
*                         FREEADDR=LSDADATA;/* POINTER INDICATES LAST*/ 01420000
         L     R3,LSDPTR                                        DSKC190 01421000
         L     R4,LSDADATA(,R3)                                 DSKC190 01422000
         ST    R4,FREEADDR                                      DSKC190 01423000
*                         FREEAMT=LSDADATA->COMPRLNG;              0532 01424000
         L     R2,COMPRLNG(,R4)                                 DSKC190 01425000
*                         LSDADATA=LSDADATA->COMPRNXT;             0533 01426000
         SLR   R7,R7                                            DSKC190 01427000
         ICM   R7,7,COMPRNXT(R4)                                DSKC190 01428000
         ST    R7,LSDADATA(,R3)                                 DSKC190 01429000
*                         CALL FREESTG;/* ISSUE FREEMAIN             */ 01430000
         BAL   R14,FREESTG                                      DSKC190 01431000
*                       END;                                       0535 01432000
*                                                                  0535 01433000
@DE00530 SLR   R4,R4                                            DSKC190 01434000
         L     R7,LSDPTR                                        DSKC190 01435000
         C     R4,LSDADATA(,R7)                                 DSKC190 01436000
         BNE   @DL00530                                            0535 01437000
*                       /*********************************************/ 01438000
*                       /*                                           */ 01439000
*                       /* FREE THE LSD                              */ 01440000
*                       /*                                           */ 01441000
*                       /*********************************************/ 01442000
*                                                                  0536 01443000
*                       FREEADDR=ECDALSD;/* FREE THE LSD             */ 01444000
         L     R7,ECDALSD                                       DSKC190 01445000
         ST    R7,FREEADDR                                      DSKC190 01446000
*                       FREEAMT=LENGTH(LSD);                       0537 01447000
         LA    R2,16                                            DSKC190 01448000
*                       ECDALSD=CON0;/* INDICATE HAS BEEN FREED      */ 01449000
         ST    R4,ECDALSD                                       DSKC190 01450000
*                       CALL FREESTG;/* ISSUE FREEMAIN               */ 01451000
         BAL   R14,FREESTG                                      DSKC190 01452000
*                     END;                                         0540 01453000
*                 END;                                             0541 01454000
@RF00509 DS    0H                                                  0542 01455000
*             END;                                                 0542 01456000
@RC00502 DS    0H                                                  0543 01457000
*         END;                                                     0543 01458000
@RF00500 DS    0H                                                  0544 01459000
*     END;                                                         0544 01460000
@RF00497 DS    0H                                                  0545 01461000
*                                                                  0545 01462000
*   /*****************************************************************/ 01463000
*   /*                                                               */ 01464000
*   /* IF ERRORS HAVE OCCURRED THEN FLUSH THE STACK AND ANY INPUT    */ 01465000
*   /* TCAM BUFFERS                                                  */ 01466000
*   /*                                                               */ 01467000
*   /*****************************************************************/ 01468000
*                                                                  0545 01469000
*   IF ERROR=YES×NOTEXEC=YES THEN   /* IF ERRORS HAVE                */ 01470000
@RC00450 TM    ERROR,B'10000000'                                   0545 01471000
         BO    @RT00545                                            0545 01472000
         TM    NOTEXEC,B'01000000'                                 0545 01473000
         BNO   @RF00545                                            0545 01474000
@RT00545 DS    0H                                                  0546 01475000
*     DO;                           /* OCCURRED AND THE DATASET WAS  */ 01476000
*       STACKG(1:MACLEN)=STACKL(1:MACLEN);/* NOT EMPTY THEN FLUSH    */ 01477000
         L     R4,MACLEN                                        DSKC190 01478000
         BCTR  R4,0                                             DSKC190 01479000
         EX    R4,@SM01407                                      DSKC190 01480000
*       IOPLIOPB=ADDR(STACKG);      /* THE STACK                     */ 01481000
         LA    R7,STACKG                                        DSKC190 01482000
         L     R4,IOPLPTR                                       DSKC190 01483000
         ST    R7,IOPLIOPB(,R4)                                 DSKC190 01484000
*       GEN(STACK DELETE=ALL,MF=(E,SERVBLK));                      0549 01485000
         STACK DELETE=ALL,MF=(E,SERVBLK)                                01486000
*       GEN(TCLEARQ INPUT);         /* FLUSH INPUT QUEUE             */ 01487000
         TCLEARQ INPUT                                                  01488000
*     END;                                                         0551 01489000
*   IF FREEPDL=YES THEN             /* IF COMMAND WAS EXPLICIT THEN  */ 01490000
@RF00545 TM    FREEPDL,B'00010000'                                 0552 01491000
         BNO   @RF00552                                            0552 01492000
*     GEN(IKJRLSA ECDAEANS);        /* FREE PARSE INPUT PARMS PDL    */ 01493000
         IKJRLSA ECDAEANS                                               01494000
*   IF GETLLOAD=YES THEN            /* IF GETLINE WAS LOADED THEN    */ 01495000
@RF00552 TM    GETLLOAD,B'00000100'                                0554 01496000
         BNO   @RF00554                                            0554 01497000
*     DO;                           /* DELETE EP(IKJGETL)            */ 01498000
*       RESPECIFY                                                  0556 01499000
*        (GPR00P) RESTRICTED;                                      0556 01500000
*       GPR00P=ADDR(IKJGETL);       /* ->ENTRY NAME                  */ 01501000
         LA    R0,@CC01162                                      DSKC190 01502000
*       SVC(9);                     /* DELETE SVC                    */ 01503000
         SVC   9                                                   0558 01504000
*       RESPECIFY                                                  0559 01505000
*        (GPR00P) UNRESTRICTED;                                    0559 01506000
*     END;                          /* DELETE EP(IKJGETL) DELETE   0560 01507000
*                                      IKJGETL                       */ 01508000
*                                                                  0560 01509000
*   /*****************************************************************/ 01510000
*   /*                                                               */ 01511000
*   /* IF THIS IS AN EXPLICIT INVOCATION HAVE DAIR UNALLOCATE THE    */ 01512000
*   /* INPUT DATA SET IF IT IS NOT PERMANENTLY ALLOCATED             */ 01513000
*   /*                                                               */ 01514000
*   /*****************************************************************/ 01515000
*                                                                  0561 01516000
*   IF IMPLICIT=NO&UNALLOC=YES&ABEND=NO THEN/* UNALLOCATE THE        */ 01517000
@RF00554 TM    IMPLICIT,B'10000000'                                0561 01518000
         BNZ   @RF00561                                            0561 01519000
         TM    UNALLOC,B'00000010'                                 0561 01520000
         BNO   @RF00561                                            0561 01521000
         TM    ABEND,B'01000000'                                   0561 01522000
         BNZ   @RF00561                                            0561 01523000
*     DO;                           /* DATA SET FOR EXPLICIT EXEC    */ 01524000
*       ALLOCINT=''B;               /* ZERO OUT PARM AREA            */ 01525000
         L     R4,DAPB0PTR                                      DSKC190 01526000
         XC    ALLOCINT(76,R4),ALLOCINT(R4)                     DSKC190 01527000
*       B1A='';                     /* BLANK OUT CONTROL FIELDS      */ 01528000
         MVI   B1A(R4),C' '                                     DSKC190 01529000
         MVC   B1A+1(17,R4),B1A(R4)                             DSKC190 01530000
*       DA18CD(2)=CONX18;           /* DAIR FUNCTION CODE            */ 01531000
         L     R7,DAPB1PTR                                      DSKC190 01532000
         MVI   DA18CD+1(R7),X'18'                               DSKC190 01533000
*       DA18DDN=INDDNAME;           /* FREE BY DDNAME                */ 01534000
         MVC   DA18DDN(8,R7),INDDNAME                           DSKC190 01535000
*       DA18KEEP=YES;               /* DISP IS KEEP                  */ 01536000
         OI    DA18KEEP(R7),B'00001000'                         DSKC190 01537000
*       DAPLPSCB=CPPLPSCB;          /* COPY PSCB ADDRESS             */ 01538000
         L     R4,DAPLPTR                                       DSKC190 01539000
         L     R1,CPPLPTR                                       DSKC190 01540000
         L     R2,CPPLPSCB(,R1)                                 DSKC190 01541000
         ST    R2,DAPLPSCB(,R4)                                 DSKC190 01542000
*       DAPLDAPB=DAPB1PTR;          /* ADDRESS OF THE DAIR BLK       */ 01543000
         ST    R7,DAPLDAPB(,R4)                                 DSKC190 01544000
*       RFY                                                        0570 01545000
*        (R1,                                                      0570 01546000
*         R15) RSTD;                                               0570 01547000
*       R1=SERVPTR;                 /* ADDRESS OF THE DAPL           */ 01548000
         L     R1,SERVPTR                                          0571 01549000
*       DO;                         /* CALLTSSR EP(IKJDAIR)          */ 01550000
*         RESPECIFY                                                0573 01551000
*           GPR01P RSTD;                                           0573 01552000
*         IF CVTDAIR=0 THEN                                        0574 01553000
         L     R4,CVTPTR                                        DSKC190 01554000
         L     R7,CVTDAIR(,R4)                                  DSKC190 01555000
         LTR   R7,R7                                            DSKC190 01556000
         BNZ   @RF00574                                            0574 01557000
*           GEN(LINK EP=IKJDAIR);                                  0575 01558000
         LINK EP=IKJDAIR                                                01559000
*         ELSE                                                     0576 01560000
*           CALL CVTDAIR;                                          0576 01561000
         B     @RC00574                                            0576 01562000
@RF00574 L     R4,CVTPTR                                        DSKC190 01563000
         L     R15,CVTDAIR(,R4)                                 DSKC190 01564000
         BALR  R14,R15                                          DSKC190 01565000
*         RESPECIFY                                                0577 01566000
*           GPR01P UNRSTD;                                         0577 01567000
@RC00574 DS    0H                                                  0578 01568000
*       END;                        /* INVOKE DAIR                   */ 01569000
*       SRETCDE=R15;                /* SAVE THE RETURN CODE          */ 01570000
         ST    R15,SRETCDE                                         0579 01571000
*       RFY                                                        0580 01572000
*        (R1,                                                      0580 01573000
*         R15) UNRSTD;                                             0580 01574000
*       IF SRETCDE^=CON0 THEN       /* IF RETURN CODE NON ZERO       */ 01575000
         L     R4,SRETCDE                                       DSKC190 01576000
         LTR   R4,R4                                            DSKC190 01577000
         BZ    @RF00581                                            0581 01578000
*         CALL ALLOFAIL;            /* NOTIFY USER                   */ 01579000
         BAL   R14,ALLOFAIL                                     DSKC190 01580000
*     END;                                                         0583 01581000
@RF00581 DS    0H                                                  0584 01582000
*   IF ABEND=NO THEN                /* IF NOT ABENDING THEN          */ 01583000
@RF00561 TM    ABEND,B'01000000'                                   0584 01584000
         BNZ   @RF00584                                            0584 01585000
*     RETURN CODE(EXRETCDE);        /* RETURN NORMALLY TO CALLER     */ 01586000
         L     R13,4(,R13)                                      DSKC190 01587000
         L     R0,@SIZDATD                                      DSKC190 01588000
         LR    R1,R11                                           DSKC190 01589000
         FREEMAIN R,LV=(0),A=(1)                                        01590000
         LR    R15,R5                                           DSKC190 01591000
         L     R14,12(,R13)                                     DSKC190 01592000
         LM    R0,R12,20(R13)                                   DSKC190 01593000
         BR    R14                                              DSKC190 01594000
*   ELSE                            /* OTHERWISE RETURN TO ABEND     */ 01595000
*     DO;                           /* INDICATING NO RETRY           */ 01596000
@RF00584 DS    0H                                                  0587 01597000
*       RFY                                                        0587 01598000
*        (R14,                                                     0587 01599000
*         R15) RSTD;                                               0587 01600000
*       R15=CON0;                   /* INDICATE NO RETRY             */ 01601000
         SLR   R15,R15                                             0588 01602000
*       R14=RETADDR;                /* RETURN TO SUPERVISOR          */ 01603000
         LR    R14,R6                                           DSKC190 01604000
*       GOTO RETRY;                 /* RETURNS TO ADDRESS IN R14     */ 01605000
         BR    R14                                                 0590 01606000
*       RFY                                                        0591 01607000
*        (R14,                                                     0591 01608000
*         R15) UNRSTD;                                             0591 01609000
*     END;                                                         0592 01610000
*                                                                  0592 01611000
*   /*****************************************************************/ 01612000
*   /*                                                               */ 01613000
*   /* STAE ROUTINE - ABEND ENTRY POINT                              */ 01614000
*   /*                                                               */ 01615000
*   /*****************************************************************/ 01616000
*                                                                  0593 01617000
*ABENTRY:                                                          0593 01618000
*   RFY                                                            0593 01619000
*    (R1,                                                          0593 01620000
*     R14) RSTD;                                                   0593 01621000
ABENTRY  DS    0H                                                  0594 01622000
*   R12=CDEBASE;                    /* RESTORE CODE REG              */ 01623000
         L     R0,STAEWORK(,R1)                                 DSKC190 01624000
         LR    R4,R0                                            DSKC190 01624010
         L     R12,CDEBASE(,R4)                                 DSKC190 01625000
         LA    R10,4095                                         DSKC190 01625010
         ALR   R10,R12                                          DSKC190 01625020
         LR    R15,R0                                           DSKC190 01625030
*   R11=DATBASE;                    /* RESTORE DATA REG              */ 01626000
         L     R11,DATBASE(,R15)                                DSKC190 01627000
         LR    R15,R0                                           DSKC190 01627010
*   R13=SAVBASE;                    /* RESTORE SAVE REG              */ 01628000
         L     R13,SAVBASE(,R15)                                DSKC190 01629000
*   RETADDR=R14;                    /* SAVE THE STAE RETURN ADDRESS  */ 01630000
         LR    R6,R14                                           DSKC190 01631000
*   RFY                                                            0598 01632000
*    (R1,                                                          0598 01633000
*     R14) UNRSTD;                                                 0598 01634000
*   ABEND=YES;                      /* INDICATE ABEND HAS OCCURRED   */ 01635000
         OI    ABEND,B'01000000'                                   0599 01636000
*   NOTEXEC=YES;                    /* PROCEDURE CAN NOT BE EXECUTED */ 01637000
         OI    NOTEXEC,B'01000000'                                 0600 01638000
*   GOTO EXIT;                      /* PERFORM CLEANUP ACTIVITY      */ 01639000
         B     EXIT                                                0601 01640000
*                                                                  0602 01641000
*   /*****************************************************************/ 01642000
*   /*                                                               */ 01643000
*   /* FREE STORAGE ROUTINE - ISSUES A FREEMAIN FOR A PRESET ADDRESS */ 01644000
*   /* AND LENGTH                                                    */ 01645000
*   /*                                                               */ 01646000
*   /*****************************************************************/ 01647000
*                                                                  0602 01648000
*FREESTG:                                                          0602 01649000
*   PROC;                                                          0602 01650000
FREESTG  STM   R14,R12,12(R13)                                  DSKC190 01651000
*   DO;                             /* FREEMAIN (E) LV(FREEAMT)    0603 01652000
*                                      A(FREEADDR) SP(78)            */ 01653000
*     RESPECIFY                                                    0604 01654000
*      (GPR01P) RESTRICTED;                                        0604 01655000
*     I005=I005&&I005;              /* INIT LIST                     */ 01656000
         XC    I005(10),I005                                       0605 01657000
*     I00505='00'X;                 /* SET TYPE                      */ 01658000
         MVI   I00505,X'00'                                        0606 01659000
*     I00502=FREEAMT;               /* LENGTH                        */ 01660000
         STCM  R2,7,I00502                                      DSKC190 01661000
*     I00504=ADDR(FREEADDR);        /* ADDR OF ADDR LIST             */ 01662000
         LA    R0,FREEADDR                                      DSKC190 01663000
         STCM  R0,7,I00504                                      DSKC190 01664000
*     I00506=78;                    /* SUBPOOL VALUE                 */ 01665000
         MVI   I00506,X'4E'                                        0609 01666000
*     GPR01P=ADDR(I005);            /* REG1 POINTS TO LIST           */ 01667000
         LA    R1,I005                                          DSKC190 01668000
*     SVC(5);                       /* STANDARD-FORM OF GETMAIN      */ 01669000
         SVC   5                                                   0611 01670000
*     RESPECIFY                                                    0612 01671000
*      (GPR01P) UNRESTRICTED;                                      0612 01672000
*   END;                            /* FREEMAIN (E) LV(FREEAMT)    0613 01673000
*                                      A(FREEADDR) SP(78)            */ 01674000
*   END FREESTG;                                                   0614 01675000
@EL00002 DS    0H                                                  0614 01676000
@EF00002 DS    0H                                                  0614 01677000
@ER00002 LM    R14,R12,12(R13)                                  DSKC190 01678000
         BR    R14                                              DSKC190 01679000
*                                                                  0615 01680000
*   /*****************************************************************/ 01681000
*   /*                                                               */ 01682000
*   /* MSGRTN - THE MESSAGE ROUTINE BUILDS THE IKJEFF02 PARAMETER    */ 01683000
*   /* LIST AND THEN INVOKES IKJEFF02 TO ISSUE A MESSAGE             */ 01684000
*   /*                                                               */ 01685000
*   /*****************************************************************/ 01686000
*                                                                  0615 01687000
*MSGRTN:                                                           0615 01688000
*   PROC OPTIONS(SAVEAREA);                                        0615 01689000
MSGRTN   STM   R14,R12,12(R13)                                  DSKC190 01690000
         ST    R13,@SA00003+4                                   DSKC190 01691000
         LA    R14,@SA00003                                     DSKC190 01692000
         ST    R14,8(,R13)                                      DSKC190 01693000
         LR    R13,R14                                          DSKC190 01694000
*   MSGTABLE=MSGTABLE&&MSGTABLE;    /* INITIALIZE IKJEFF02 PARMLIST  */ 01695000
         L     R2,ERRPTR                                        DSKC190 01696000
         XC    MSGTABLE(52,R2),MSGTABLE(R2)                     DSKC190 01697000
*   LISTPTR=ADDR(MSGCSECT);         /* START OF MESSAGE PARMS        */ 01698000
         LA    R3,MSGCSECT(,R2)                                 DSKC190 01699000
         ST    R3,LISTPTR(,R2)                                  DSKC190 01700000
*   TMCTPTR=CPPLPTR;                /* ADDRESS OF THE CPPL           */ 01701000
         L     R3,CPPLPTR                                       DSKC190 01702000
         ST    R3,TMCTPTR(,R2)                                  DSKC190 01703000
*   ECBPTR=ADDR(ECB);               /* DUMMY ECB ADDRESS             */ 01704000
         LA    R3,ECB                                           DSKC190 01705000
         ST    R3,ECBPTR(,R2)                                   DSKC190 01706000
*   MSGCSECT=ADDR(IKJCT435);        /* IKJCT435 IS MESSAGE CSECT     */ 01707000
         L     R3,@CV01309                                      DSKC190 01708000
         ST    R3,MSGCSECT(,R2)                                 DSKC190 01709000
*   MTPUTLSW=YES;                   /* PUTLINE MESSAGE REUESTED      */ 01710000
         OI    MTPUTLSW(R2),B'01000000'                         DSKC190 01711000
*   MSGID=EXMSGID;                  /* ID OF THE MESSAGE TO BE ISSUED*/ 01712000
         MVC   MSGID(4,R2),EXMSGID                              DSKC190 01713000
*REXX/370 -- a command not found while a CLIST runs: TSO/E      RXPTF   
*        says IKJ56479I (REXX id missing), not IKJ56500I.       RXPTF   
*        IKJCT43N tests the stack, IKJCT43M holds the text.     RXPTF   
*        IKJCT43N saves regs in MSGRTN's area; R15 = answer.    RXPTF   
         CLC   MSGID(4,R2),@CC01134   M500: command not found   RXPTF   
         BNE   RXNOCL                                           RXPTF   
         L     R1,CPPLPTR                                       RXPTF   
         L     R15,=V(IKJCT43N)                                 RXPTF   
         BALR  R14,R15                                          RXPTF   
         LTR   R15,R15                                          RXPTF   
         BZ    RXNOCL             no CLIST/REXX: IKJ56500I      RXPTF   
         MVC   MSGID(4,R2),=C'M479'                             RXPTF   
         L     R3,=V(IKJCT43M)                                  RXPTF   
         ST    R3,MSGCSECT(,R2)                                 RXPTF   
RXNOCL   DS    0H                                               RXPTF   
*   DO ICTR=1 TO 2;                 /* INITIALIZE INSERTION VARIABLES*/ 01714000
         LA    R2,1                                             DSKC190 01715000
@DL00623 DS    0H                                                  0624 01716000
*     MTINSRT(ICTR)=MVAR(ICTR);     /* MVAR HAS BEEN PREVIOUSLY SET  */ 01717000
         LR    R3,R2                                            DSKC190 01718000
         SLA   R3,2                                             DSKC190 01719000
         L     R4,MVAR-4(R3)                                    DSKC190 01720000
         L     R5,ERRPTR                                        DSKC190 01721000
         ST    R4,MTINSRT-4(R3,R5)                              DSKC190 01722000
*   END;                                                           0625 01723000
         AL    R2,@CF00033                                      DSKC190 01724000
         C     R2,@CF00091                                      DSKC190 01725000
         BNH   @DL00623                                            0625 01726000
*   R1=ERRPTR;                      /* ADDRESS OF MSGTABLE           */ 01727000
         L     R1,ERRPTR                                           0626 01728000
*   DO;                             /* LINK EP(IKJEFF02)             */ 01729000
*     I00601='00'X;                 /* EP/DE FLAG                    */ 01730000
         MVI   I00601,X'00'                                        0628 01731000
*     I00602=ADDR(IKJEFF02);        /* ADDR OF EP/DE                 */ 01732000
         LA    R2,@CC01156                                      DSKC190 01733000
         STCM  R2,7,I00602                                      DSKC190 01734000
*     I00604=0;                     /* DCB PTR                       */ 01735000
         SLR   R3,R3                                            DSKC190 01736000
         STCM  R3,7,I00604                                      DSKC190 01737000
*     I00603='00'X;                 /* ERRET FLAG                    */ 01738000
         MVI   I00603,X'00'                                        0631 01739000
*     RESPECIFY                                                    0632 01740000
*      (GPR15P) RESTRICTED;                                        0632 01741000
*     GPR15P=ADDR(I006);            /* ADDR OF LINK LIST             */ 01742000
         LA    R15,I006                                         DSKC190 01743000
*     SVC(6);                       /* ISSUE LINK SVC                */ 01744000
         SVC   6                                                   0634 01745000
*     RESPECIFY                                                    0635 01746000
*      (GPR15P) UNRESTRICTED;                                      0635 01747000
*   END;                            /* LINK EP(IKJEFF02) USE IKJEFF02   01748000
*                                      TO ISSUE MESSAGE              */ 01749000
*   END MSGRTN;                     /* END OF MSGRTN                 */ 01750000
@EL00003 L     R13,4(,R13)                                      DSKC190 01751000
@EF00003 DS    0H                                                  0637 01752000
@ER00003 LM    R14,R12,12(R13)                                  DSKC190 01753000
         BR    R14                                              DSKC190 01754000
*                                                                  0638 01755000
*   /*****************************************************************/ 01756000
*   /*                                                               */ 01757000
*   /* GETALINE ROUTINE - THE GETALINE ROUTINE ISSUES DATA SET I/O   */ 01758000
*   /* GETLINES FOR THE CLIST RECORDS FROM THE INPUT DATA SET        */ 01759000
*   /*                                                               */ 01760000
*   /*****************************************************************/ 01761000
*                                                                  0638 01762000
*GETALINE:                                                         0638 01763000
*   PROC OPTIONS(SAVEAREA);                                        0638 01764000
GETALINE STM   R14,R12,12(R13)                                  DSKC190 01765000
         ST    R13,@SA00004+4                                   DSKC190 01766000
         LA    R14,@SA00004                                     DSKC190 01767000
         ST    R14,8(,R13)                                      DSKC190 01768000
         LR    R13,R14                                          DSKC190 01769000
*   IF ECDAIREC^=CON0 THEN          /* FREE THE PREVIOUS BUFFER IF   */ 01770000
         L     R0,ECDAIREC                                      DSKC190 01771000
         LTR   R0,R0                                            DSKC190 01772000
         BZ    @RF00639                                            0639 01773000
*     DO;                           /* FREEMAIN (E)                0640 01774000
*                                      LV(ECDAIREC->CBUFLNG)       0640 01775000
*                                      A(ECDAIREC) SP(1)             */ 01776000
*       RESPECIFY                                                  0641 01777000
*        (GPR01P) RESTRICTED;                                      0641 01778000
*       I005=I005&&I005;            /* INIT LIST                     */ 01779000
         XC    I005(10),I005                                       0642 01780000
*       I00505='00'X;               /* SET TYPE                      */ 01781000
         MVI   I00505,X'00'                                        0643 01782000
         LR    R2,R0                                            DSKC190 01782010
*       I00502=ECDAIREC->CBUFLNG;   /* LENGTH                        */ 01783000
         LH    R0,CBUFLNG(,R2)                                  DSKC190 01784000
         STCM  R0,7,I00502                                      DSKC190 01785000
*       I00504=ADDR(ECDAIREC);      /* ADDR OF ADDR LIST             */ 01786000
         LA    R0,ECDAIREC                                      DSKC190 01787000
         STCM  R0,7,I00504                                      DSKC190 01788000
*       I00506=1;                   /* SUBPOOL VALUE                 */ 01789000
         MVI   I00506,X'01'                                        0646 01790000
*       GPR01P=ADDR(I005);          /* REG1 POINTS TO LIST           */ 01791000
         LA    R1,I005                                          DSKC190 01792000
*       SVC(5);                     /* STANDARD-FORM OF GETMAIN      */ 01793000
         SVC   5                                                   0648 01794000
*       RESPECIFY                                                  0649 01795000
*        (GPR01P) UNRESTRICTED;                                    0649 01796000
*     END;                          /* FREEMAIN (E)                0650 01797000
*                                      LV(ECDAIREC->CBUFLNG)       0650 01798000
*                                      A(ECDAIREC) SP(1) NOT FIRST 0650 01799000
*                                      READ                          */ 01800000
*   RFY                                                            0651 01801000
*     R15 RSTD;                                                    0651 01802000
@RF00639 DS    0H                                                  0652 01803000
*   R15=ECDAGETL;                   /* GETLINE ENTRY POINT           */ 01804000
         L     R15,ECDAGETL                                        0652 01805000
*   GEN(GETLINE MF=(E,SERVBLK),ENTRY=(15));/* GET AN INPUT RECORD    */ 01806000
         GETLINE MF=(E,SERVBLK),ENTRY=(15)                              01807000
*   RFY                                                            0654 01808000
*     R15 UNRSTD;                                                  0654 01809000
*   RFY                                                            0655 01810000
*     R15 RSTD;                                                    0655 01811000
*   SRETCDE=R15;                    /* SAVE THE RETURN CODE          */ 01812000
         ST    R15,SRETCDE                                         0656 01813000
*   RFY                                                            0657 01814000
*     R15 UNRSTD;                                                  0657 01815000
*   IF SRETCDE^=CON4&               /* IF RETURN CODE ABNORMAL       */ 01816000
*       SRETCDE^=CON16 THEN         /* THEN NOTIFY USER              */ 01817000
         L     R0,SRETCDE                                       DSKC190 01818000
         C     R0,@CF00095                                      DSKC190 01819000
         BE    @RF00658                                            0658 01820000
         C     R0,@CF01090                                      DSKC190 01821000
         BE    @RF00658                                            0658 01822000
*     DO;                                                          0659 01823000
*       MVAR(1)=ADDR(GETLIN);       /* ADDR OF 'GETLINE'             */ 01824000
         LA    R1,@CC01164                                      DSKC190 01825000
         ST    R1,MVAR                                          DSKC190 01826000
*       MVARLEN(1)=LENGTH(GETLIN);  /* LENGTH OF 'GETLINE'           */ 01827000
         MVI   MVARLEN,X'07'                                       0661 01828000
*       MVAR(2)=ADDR(SRETCDE);      /* ADDR OF RETURN CODE AREA      */ 01829000
         LA    R2,SRETCDE                                       DSKC190 01830000
         ST    R2,MVAR+4                                        DSKC190 01831000
*       MVARLEN(2)=LENGTH(SRETCDE); /* LENGTH OF RETURN CODE AREA    */ 01832000
         MVI   MVARLEN+4,X'04'                                     0663 01833000
*       MVARHEX(2)=YES;             /* RETURN CODE IS DECIMAL        */ 01834000
         OI    MVARHEX+4,B'10000000'                               0664 01835000
*       EXMSGID=M524;               /* IDENTIFY THE MESSAGE          */ 01836000
         MVC   EXMSGID(4),@CC01144                                 0665 01837000
*       NOTEXEC=YES;                /* PROC IS NOT EXECUTABLE        */ 01838000
         OI    NOTEXEC,B'01000000'                                 0666 01839000
*       CALL MSGRTN;                /* ISSUE MESSAGE                 */ 01840000
         BAL   R14,MSGRTN                                       DSKC190 01841000
*     END;                                                         0668 01842000
*   IF SRETCDE=CON4 THEN            /* IF NOT END OF INPUT THEN      */ 01843000
@RF00658 CLC   SRETCDE(4),@CF00095                                 0669 01844000
         BNE   @RF00669                                            0669 01845000
*     ECDALCTR=CON1+ECDALCTR;       /* UP THE NUMBER OF RECORDS READ */ 01846000
         LA    R3,1                                             DSKC190 01847000
         AL    R3,ECDALCTR                                      DSKC190 01848000
         ST    R3,ECDALCTR                                      DSKC190 01849000
*   ECDAIREC=GTPBIBUF;              /* UPDATE TO NEW RECORD ADDRESS  */ 01850000
@RF00669 L     R1,IOPLPTR                                       DSKC190 01851000
         L     R1,GTPBPTR(,R1)                                  DSKC190 01852000
         L     R1,GTPBIBUF(,R1)                                 DSKC190 01853000
         ST    R1,ECDAIREC                                      DSKC190 01854000
*   END GETALINE;                                                  0672 01855000
@EL00004 L     R13,4(,R13)                                      DSKC190 01856000
@EF00004 DS    0H                                                  0672 01857000
@ER00004 LM    R14,R12,12(R13)                                  DSKC190 01858000
         BR    R14                                              DSKC190 01859000
*                                                                  0673 01860000
*   /*****************************************************************/ 01861000
*   /*                                                               */ 01862000
*   /* ALLOFAIL ROUTINE - THE ALLOCATION FAILURE ROUTINE GETS CONTROL*/ 01863000
*   /* AFTER AN ALLOCATION FAILURE. THIS ROUTINE BUILDS THE IKJEFF18 */ 01864000
*   /* PARAMETER LIST AND LINKS TO IKJEFF18 TO ANALIZE AND ISSUE A   */ 01865000
*   /* MESSAGE FOR THE FAILURE.                                      */ 01866000
*   /*                                                               */ 01867000
*   /*****************************************************************/ 01868000
*                                                                  0673 01869000
*ALLOFAIL:                                                         0673 01870000
*   PROC OPTIONS(SAVEAREA);                                        0673 01871000
ALLOFAIL STM   R14,R12,12(R13)                                  DSKC190 01872000
         ST    R13,@SA00005+4                                   DSKC190 01873000
         LA    R14,@SA00005                                     DSKC190 01874000
         ST    R14,8(,R13)                                      DSKC190 01875000
         LR    R13,R14                                          DSKC190 01876000
*   DFDAPLP=SERVPTR;                /* ADDRESS OF THE FAILING DAPL   */ 01877000
         L     R2,ERRPTR                                        DSKC190 01878000
         L     R3,SERVPTR                                       DSKC190 01879000
         ST    R3,DFDAPLP(,R2)                                  DSKC190 01880000
*   DFRCP=ADDR(SRETCDE);            /* ADDRESS OF THE RETURN CODE    */ 01881000
         LA    R3,SRETCDE                                       DSKC190 01882000
         ST    R3,DFRCP(,R2)                                    DSKC190 01883000
*   DFJEFF02=ADDR(MSGWTR);          /* ADDRESS OF THE MESSAGE WRITER */ 01884000
         LA    R3,MSGWTR                                        DSKC190 01885000
         ST    R3,DFJEFF02(,R2)                                 DSKC190 01886000
*   DFIDP=ADDR(CALLERID);           /* IDENTIFIER FOR DAIR ERROR     */ 01887000
         LA    R3,CALLERID                                      DSKC190 01888000
         ST    R3,DFIDP(,R2)                                    DSKC190 01889000
*   RFY                                                            0678 01890000
*     R1 RSTD;                                                     0678 01891000
*   R1=ADDR(ERRPARMS);              /* ADDRESS OF IKJEFF18 PARMS     */ 01892000
         LA    R1,ERRPARMS                                         0679 01893000
*   RFY                                                            0680 01894000
*     R1 UNRSTD;                                                   0680 01895000
*   DO;                             /* LINK EP(IKJEFF18)             */ 01896000
*     I00601='00'X;                 /* EP/DE FLAG                    */ 01897000
         MVI   I00601,X'00'                                        0682 01898000
*     I00602=ADDR(IKJEFF18);        /* ADDR OF EP/DE                 */ 01899000
         LA    R2,@CC01158                                      DSKC190 01900000
         STCM  R2,7,I00602                                      DSKC190 01901000
*     I00604=0;                     /* DCB PTR                       */ 01902000
         SLR   R3,R3                                            DSKC190 01903000
         STCM  R3,7,I00604                                      DSKC190 01904000
*     I00603='00'X;                 /* ERRET FLAG                    */ 01905000
         MVI   I00603,X'00'                                        0685 01906000
*     RESPECIFY                                                    0686 01907000
*      (GPR15P) RESTRICTED;                                        0686 01908000
*     GPR15P=ADDR(I006);            /* ADDR OF LINK LIST             */ 01909000
         LA    R15,I006                                         DSKC190 01910000
*     SVC(6);                       /* ISSUE LINK SVC                */ 01911000
         SVC   6                                                   0688 01912000
*     RESPECIFY                                                    0689 01913000
*      (GPR15P) UNRESTRICTED;                                      0689 01914000
*   END;                            /* LINK EP(IKJEFF18) ANALIZE THE    01915000
*                                      DAIR FAILURE                  */ 01916000
*   END ALLOFAIL;                                                  0691 01917000
@EL00005 L     R13,4(,R13)                                      DSKC190 01918000
@EF00005 DS    0H                                                  0691 01919000
@ER00005 LM    R14,R12,12(R13)                                  DSKC190 01920000
         BR    R14                                              DSKC190 01921000
*                                                                  0692 01922000
*   /*****************************************************************/ 01923000
*   /*                                                               */ 01924000
*   /* PATCH AREA                                                    */ 01925000
*   /*                                                               */ 01926000
*   /*****************************************************************/ 01927000
*                                                                  0692 01928000
*   DCL                                                            0692 01929000
*     FEPATCH FIXED(31) STATIC;                                    0692 01930000
*   GEN DATA DEFS(FEPATCH);                                        0693 01931000
*   DECLARE                         /* GENERAL PURPOSE REGISTERS     */ 01932000
*     GPR00P PTR(31) REG(0),                                       0694 01933000
*     GPR01P PTR(31) REG(1),                                       0694 01934000
*     GPR02P PTR(31) REG(2),                                       0694 01935000
*     GPR03P PTR(31) REG(3),                                       0694 01936000
*     GPR04P PTR(31) REG(4),                                       0694 01937000
*     GPR05P PTR(31) REG(5),                                       0694 01938000
*     GPR06P PTR(31) REG(6),                                       0694 01939000
*     GPR07P PTR(31) REG(7),                                       0694 01940000
*     GPR08P PTR(31) REG(8),                                       0694 01941000
*     GPR09P PTR(31) REG(9),                                       0694 01942000
*     GPR14P PTR(31) REG(14),                                      0694 01943000
*     GPR15P PTR(31) REG(15);                                      0694 01944000
*   DCL                                                            0695 01945000
*     1 I005 DEF(ILIST) BDY(WORD),  /* LIST FOR FREEMAIN             */ 01946000
*       3 I00501 PTR(8),            /* RESERVED                      */ 01947000
*       3 I00502 PTR(24),           /* LENGTH                        */ 01948000
*       3 I00503 PTR(8),            /* RESERVED                      */ 01949000
*       3 I00504 PTR(24),           /* ADDR OF ADDR LIST             */ 01950000
*       3 I00505 BIT(8),            /* TYPE OF FREEMAIN              */ 01951000
*       3 I00506 PTR(8);            /* SUBPOOL VALUE                 */ 01952000
*   DCL                                                            0696 01953000
*     1 I006 DEF(ILIST),            /* DEFINE LIST                   */ 01954000
*      2 I00601 CHAR(1),            /* EP/DE FLAG                    */ 01955000
*      2 I00602 PTR(24),            /* EP/DE PTR                     */ 01956000
*      2 I00603 CHAR(1),            /* ERRET FLAG                    */ 01957000
*      2 I00604 PTR(24),            /* DCB PTR                       */ 01958000
*      2 I00605 PTR(31);            /* ERRET PTR                     */ 01959000
*   DECLARE                                                        0697 01960000
*     ILIST CHAR(12) BDY(DWORD);    /* STANDARD LIST                 */ 01961000
*   DECLARE                         /* COMMON VARIABLES              */ 01962000
*     I256C CHAR(256) BASED,                                       0698 01963000
*     I031F FIXED(31) BASED,                                       0698 01964000
*     I031P PTR(31) BASED,                                         0698 01965000
*     I015F FIXED(15) BASED,                                       0698 01966000
*     I015P PTR(15) BASED,                                         0698 01967000
*     I008P PTR(8) BASED,                                          0698 01968000
*     I001C CHAR(1) BASED;                                         0698 01969000
*   END IKJCT430                                                   0699 01970000
*                                                                  0699 01971000
*/* THE FOLLOWING INCLUDE STATEMENTS WERE FOUND IN THIS PROGRAM.     */ 01972000
*/*%INCLUDE SYSLIB  (IKJDAPL )                                       */ 01973000
*/*%INCLUDE SYSLIB  (IKJEFFDF)                                       */ 01974000
*/*%INCLUDE SYSLIB  (IKJEFFGF)                                       */ 01975000
*/*%INCLUDE SYSLIB  (IKJDAP00)                                       */ 01976000
*/*%INCLUDE SYSLIB  (IKJDAP08)                                       */ 01977000
*/*%INCLUDE SYSLIB  (IKJDAP18)                                       */ 01978000
*/*%INCLUDE SYSLIB  (IKJCPPL )                                       */ 01979000
*/*%INCLUDE SYSLIB  (IKJECT  )                                       */ 01980000
*/*%INCLUDE SYSLIB  (IKJIOPL )                                       */ 01981000
*/*%INCLUDE SYSLIB  (IKJGTPB )                                       */ 01982000
*/*%INCLUDE SYSLIB  (IKJPPL  )                                       */ 01983000
*/*%INCLUDE SYSLIB  (IKJCSPL )                                       */ 01984000
*/*%INCLUDE SYSLIB  (IKJCSOA )                                       */ 01985000
*/*%INCLUDE SYSLIB  (IKJEFFMT)                                       */ 01986000
*/*%INCLUDE SYSLIB  (IKJLSD  )                                       */ 01987000
*/*%INCLUDE SYSLIB  (IKJEXEC )                                       */ 01988000
*/*%INCLUDE SYSLIB  (CVT     )                                       */ 01989000
*                                                                  0699 01990000
*       ;                                                          0699 01991000
@EL00001 L     R13,4(,R13)                                      DSKC190 01992000
@EF00001 L     R0,@SIZDATD                                      DSKC190 01993000
         LR    R1,R11                                           DSKC190 01994000
         FREEMAIN R,LV=(0),A=(1)                                        01995000
@ER00001 LM    R14,R12,12(R13)                                  DSKC190 01996000
         BR    R14                                              DSKC190 01997000
@DATA    DS    0H                                                       01998000
@CH00093 DC    H'3'                                                     01999000
@CH00102 DC    H'21'                                                    02000000
@SM01390 MVC   STAEG(0),STAEL                                           02001000
@SM01394 MVC   PROCNAME(0),CMDNME(R4)                           DSKC190 02002000
@SM01398 MVC   DATASETA(0),PARDSN(R4)                           DSKC190 02003000
@SM01401 MVC   0(0,R4),0(R1)                                    DSKC190 02004000
@SM01403 MVC   DA08PSWD(0,R7),PARPSWD(R4)                       DSKC190 02005000
@SM01405 MVC   PROCNAME(0),PARMEM(R7)                           DSKC190 02006000
@SM01407 MVC   STACKG(0),STACKL                                         02007000
@DATD    DSECT                                                          02008000
         DS    0F                                                       02009000
@SA00001 DS    18F                                                      02010000
@PC00001 DS    1F                                                       02011000
@SA00003 DS    18F                                                      02012000
@SA00004 DS    18F                                                      02013000
@SA00005 DS    18F                                                      02014000
IKJCT430 CSECT                                                          02015000
         DS    0F                                                       02016000
@CF00033 DC    F'1'                                                     02017000
@CH00033 EQU   @CF00033+2                                               02018000
@CF00091 DC    F'2'                                                     02019000
@CH00091 EQU   @CF00091+2                                               02020000
@CF00095 DC    F'4'                                                     02021000
@CF00098 DC    F'6'                                                     02022000
@CF00059 DC    F'8'                                                     02023000
@CF01090 DC    F'16'                                                    02024000
@CF01114 DC    F'20'                                                    02025000
@CF01097 DC    F'37'                                                    02026000
@CF01101 DC    F'4096'                                                  02027000
@DATD    DSECT                                                          02028000
         DS    0D                                                       02029000
ERRPTR   DS    A                                                        02030000
DAPB0PTR DS    A                                                        02031000
SNTABPTR DS    A                                                        02032000
SNTELPTR DS    A                                                        02033000
SVTABPTR DS    A                                                        02034000
SERVPTR  DS    A                                                        02035000
ECB      DS    F                                                        02036000
SRETCDE  DS    F                                                        02037000
FREEADDR DS    A                                                        02038000
ECDA     DS    CL76                                                     02039000
         ORG   ECDA                                                     02040000
ECDACPPL DS    AL4                                                      02041000
ECDAGADD DS    AL4                                                      02042000
ECDAEANS DS    AL4                                                      02043000
ECDALSD  DS    AL4                                                      02044000
ECDAIREC DS    AL4                                                      02045000
ECDACBLK DS    AL4                                                      02046000
ECDACPRE DS    AL4                                                      02047000
ECDACNXT DS    AL4                                                      02048000
ECDASPTR DS    AL4                                                      02049000
ECDALCTR DS    FL4                                                      02050000
ECDALNEL DS    AL4                                                      02051000
ECDAGCNT DS    FL4                                                      02052000
ECDANDO  DS    FL2                                                      02053000
ECDAELNG DS    FL2                                                      02054000
ECDAAEND DS    CL4                                                      02055000
ECDAFLAG DS    CL2                                                      02056000
         ORG   ECDAFLAG                                                 02057000
IMPLICIT DS    BL1                                                      02058000
NOTEXEC  EQU   ECDAFLAG+0                                               02059000
SP78CORE EQU   ECDAFLAG+0                                               02060000
@NM00067 EQU   ECDAFLAG+0                                               02061000
@NM00068 EQU   ECDAFLAG+0                                               02062000
SP78BLK  EQU   ECDAFLAG+0                                               02063000
NESTED   EQU   ECDAFLAG+0                                               02064000
         ORG   ECDA+58                                                  02065000
@NM00069 DS    CL2                                                      02066000
ECDAGETL DS    AL4                                                      02067000
ECDAGDAT DS    AL4                                                      02068000
ECDACPGM DS    AL4                                                      02069000
ECDAINME DS    AL4                                                      02070000
         ORG   ECDAINME                                                 02071000
ECDAILNG DS    AL1                                                      02072000
         ORG   ECDA+76                                                  02073000
STAEPRMS DS    CL12                                                     02074000
         ORG   STAEPRMS                                                 02075000
CODEBASE DS    AL4                                                      02076000
DATABASE DS    AL4                                                      02077000
SAVEBASE DS    AL4                                                      02078000
         ORG   STAEPRMS+12                                              02079000
CT432PRM DS    CL12                                                     02080000
         ORG   CT432PRM                                                 02081000
CDAPTR   DS    AL4                                                      02082000
CT432FLG DS    BL4                                                      02083000
@NM00076 DS    AL4                                                      02084000
         ORG   CT432PRM+12                                              02085000
ALLOCPRM DS    CL84                                                     02086000
SERVBLK  DS    CL28                                                     02087000
PROCNAME DS    CL8                                                      02088000
INDDNAME DS    CL8                                                      02089000
FLGCT430 DS    BL1                                                      02090000
         ORG   FLGCT430                                                 02091000
ERROR    DS    BL1                                                      02092000
ABEND    EQU   FLGCT430+0                                               02093000
SEQ      EQU   FLGCT430+0                                               02094000
FREEPDL  EQU   FLGCT430+0                                               02095000
EMPTY    EQU   FLGCT430+0                                               02096000
GETLLOAD EQU   FLGCT430+0                                               02097000
UNALLOC  EQU   FLGCT430+0                                               02098000
         ORG   FLGCT430+1                                               02099000
         DS    CL3                                                      02100000
DATASET  DS    CL46                                                     02101000
         ORG   DATASET                                                  02102000
DATASETL DS    FL2                                                      02103000
DATASETA DS    CL44                                                     02104000
         ORG   DATASET+46                                               02105000
ERRPARMS DS    CL52                                                     02106000
EXMSGID  DS    CL4                                                      02107000
         DS    CL6                                                      02108000
ILIST    DS    CL12                                                     02109000
MVAR     DS    AL4                                                      02110000
         ORG   MVAR+0                                                   02111000
MVARLEN  DS    FL1                                                      02112000
         ORG   MVARLEN+0                                                02113000
MVARHEX  DS    BL1                                                      02114000
         ORG   MVAR+8                                                   02115000
IKJCT430 CSECT                                                          02116000
         DS    0F                                                       02117000
@SIZDATD DC    AL1(1)                                                   02118000
         DC    AL3(@ENDDATD-@DATD)                                      02119000
@CV01308 DC    V(IKJCT431)                                              02120000
@CV01309 DC    V(IKJCT435)                                              02121000
@CV01310 DC    V(IKJCT432)                                              02122000
@CV01313 DC    V(PARS)                                                  02123000
         DS    0D                                                       02124000
MSGWTR   DC    A(0)                                                     02125000
CALLERID DC    H'1'                                                     02126000
@CC01116 DC    C'SYSPROC '                                              02127000
@CC01122 DC    C'TEMPNAME'                                              02128000
@CC01128 DC    C'DATA SET'                                              02129000
@CC01130 DC    C'EXEC    '                                              02130000
@CC01156 DC    C'IKJEFF02'                                              02131000
@CC01158 DC    C'IKJEFF18'                                              02132000
@CC01160 DC    C'IKJEFF19'                                              02133000
@CC01162 DC    C'IKJGETL '                                              02134000
@CC01164 DC    C'GETLINE'                                               02135000
@CC01124 DC    C'STACK'                                                 02136000
@CC01126 DC    C'FILE'                                                  02137000
@CC01134 DC    C'M500'                                                  02138000
@CC01136 DC    C'M501'                                                  02139000
@CC01138 DC    C'M525'                                                  02140000
@CC01140 DC    C'M502'                                                  02141000
@CC01142 DC    C'A502'                                                  02142000
@CC01144 DC    C'M524'                                                  02143000
@CC01146 DC    C'A524'                                                  02144000
@CC01148 DC    C'M523'                                                  02145000
@CC01150 DC    C'M520'                                                  02146000
@CC01152 DC    C'M521'                                                  02147000
@CC01154 DC    C'M511'                                                  02148000
@CC01118 DC    C'END'                                                   02149000
@CC01132 DC    C'SUB'                                                   02150000
CLIST    DC    CL6'.CLIST'                                              02151000
RXSUFEX  DC    C'.EXEC'            REXX/370 suffix              RXPTF           
IKJCT430 CSECT                                                          02152000
*                                /* GENERATED STATIC DATA AREAS      */ 02153000
PARS   IKJPARM  DSECT=PAR1PDL       EXPLICIT EXEC CMD PCL               02154000
INDSN   IKJPOSIT      DSNAME,PROMPT='DATA SET NAME',HELP=('THE NAME OF *02155000
               THE DATA SET WHICH CONTAINS THE COMMAND PROCEDURE TO BE *02156000
               EXECUTED')           INPUT DATA SET NAME                 02157000
PRMVAL IKJPOSIT QSTRING             VALUE LIST                          02158000
OPER1  IKJKEYWD                                                         02159000
       IKJNAME 'LIST'               LIST KEYWORD                        02160000
       IKJNAME 'NOLIST'             NOLIST KEYWORD                      02161000
OPER2  IKJKEYWD                                                         02162000
       IKJNAME 'PROMPT'             PROMPT KEYWORD                      02163000
       IKJNAME 'NOPROMPT'           NOPROMPT KEYWORD                    02164000
*REXX/370 -- EXEC keyword: run the data set as a REXX exec      RXPTF           
*        (SC28-1883-0 p. 7, "the exec keyword operand").  Any   RXPTF           
*        abbreviation down to E is accepted by IKJPARS.         RXPTF           
OPER3  IKJKEYWD                                                                 
       IKJNAME 'EXEC'             EXEC KEYWORD                  RXPTF           
       IKJENDP                                                          02165000
         DC    0F'0'                                            DSKC190 02165010
STACKL  STACK MF=L                  STACK MACRO LIST FORM               02166000
GETLINEL GETLINE MF=L               GETLINE MACRO LIST FORM             02167000
MACLEN   DC A(MACLEN-STACKL)        STACK AND GETLINE LIST LENGTH       02168000
@DATD    DSECT                                                          02169000
*                                /* GENERATED AUTO DATA AREAS */        02170000
STACKG STACK  MF=L                  STACK MACRO LIST FORM               02171000
GETLINEG GETLINE MF=L               GETLINE MACRO LIST FORM             02172000
IKJCT430 CSECT                                                          02173000
*                                /* GENERATED STATIC DATA AREAS      */ 02174000
STAEL  STAE MF=L                    STAE MACRO LIST FORM                02175000
STAELEN DC A(STAELEN-STAEL)         STAE LIST FORM LIST                 02176000
@DATD    DSECT                                                          02177000
*                                /* GENERATED AUTO DATA AREAS        */ 02178000
STAEG  STAE MF=L                    STAE MACRO LIST FORM                02179000
IKJCT430 CSECT                                                          02180000
         DS   0H                                                        02181000
FEPATCH DC ((@DATA-@PSTART)/20)X'00'                                    02182000
@DATD    DSECT                                                          02183000
RXPLIST  DS    0F                 IKJCT437 parms (#331)         RXPTF           
RXPMEM   DS    CL8                member                        RXPTF           
RXPDD    DS    CL8                DD, blank if implicit         RXPTF           
RXPARGA  DS    A                  operands                      RXPTF           
RXPARGL  DS    F                  their length, 0: none         RXPTF           
RXRAWL   DS    F                  operands kept, -1: too long   RXPTF           
RXSAVE   DS    4F                 R2-R5 around the scan         RXPTF           
RXRAW    DS    CL256              operands as typed             RXPTF           
         DS    0D                                               DSKC190 02183010
         ORG   *+1-(*-@DATD)/(*-@DATD) INSURE DSECT DATA                02184000
@ENDDATD EQU   *                                                        02185000
IKJCT430 CSECT                                                          02186000
         DC    0D'0'                                            DSKC190 02186010
R0       EQU   0                 EQUATES FOR REGISTERS 0-15     DSKC190 02187000
R1       EQU   1                                                DSKC190 02188000
R2       EQU   2                                                DSKC190 02189000
R3       EQU   3                                                DSKC190 02190000
R4       EQU   4                                                DSKC190 02191000
R5       EQU   5                                                DSKC190 02192000
R6       EQU   6                                                DSKC190 02193000
R7       EQU   7                                                DSKC190 02194000
R8       EQU   8                                                DSKC190 02195000
R9       EQU   9                                                DSKC190 02196000
R10      EQU   10                                               DSKC190 02197000
R11      EQU   11                                               DSKC190 02198000
R12      EQU   12                                               DSKC190 02199000
R13      EQU   13                                               DSKC190 02200000
R14      EQU   14                                               DSKC190 02201000
R15      EQU   15                                               DSKC190 02202000
FREEAMT  EQU   R2                                               DSKC190 02203000
EXRETCDE EQU   R6                                               DSKC190 02204000
RETADDR  EQU   R7                                               DSKC190 02205000
RSRRET   EQU   R5                                               DSKC190 02206000
ICTR     EQU   R2                                               DSKC190 02207000
CVTPTR   EQU   16                                                       02230000
DAPL     EQU   0                                                        02231000
DAPLPSCB EQU   DAPL+12                                                  02232000
DAPLDAPB EQU   DAPL+16                                                  02233000
DFPARMS  EQU   0                                                        02234000
DFS99RBP EQU   DFPARMS                                                  02235000
DFDAPLP  EQU   DFS99RBP                                                 02236000
DFRCP    EQU   DFPARMS+4                                                02237000
DFJEFF02 EQU   DFPARMS+8                                                02238000
DFIDP    EQU   DFPARMS+12                                               02239000
DFID     EQU   0                                                        02240000
@NM00001 EQU   DFID                                                     02241000
GFPARMS  EQU   0                                                        02242000
GFRCODE  EQU   GFPARMS+4                                                02243000
GF02PTR  EQU   GFPARMS+8                                                02244000
GFCALLID EQU   GFPARMS+12                                               02245000
GFBITS   EQU   GFPARMS+14                                               02246000
GFCPPLP  EQU   GFPARMS+16                                               02247000
DAPB00   EQU   0                                                        02248000
DA00FLG  EQU   DAPB00+2                                                 02249000
DA00DDN  EQU   DAPB00+8                                                 02250000
DA00CTL  EQU   DAPB00+16                                                02251000
DA00DSO  EQU   DAPB00+19                                                02252000
DAPB08   EQU   0                                                        02253000
DA08CD   EQU   DAPB08                                                   02254000
DA08FLG  EQU   DAPB08+2                                                 02255000
DA08PDSN EQU   DAPB08+8                                                 02256000
DA08DDN  EQU   DAPB08+12                                                02257000
DA08PSWD EQU   DAPB08+60                                                02258000
DA08DSP1 EQU   DAPB08+68                                                02259000
DA08SHR  EQU   DA08DSP1                                                 02260000
DA08DPS2 EQU   DAPB08+69                                                02261000
DA08DPS3 EQU   DAPB08+70                                                02262000
DA08CTL  EQU   DAPB08+71                                                02263000
DA08UID  EQU   DA08CTL                                                  02264000
DA08DSO  EQU   DAPB08+75                                                02265000
DAPB18   EQU   0                                                        02266000
DA18CD   EQU   DAPB18                                                   02267000
DA18FLG  EQU   DAPB18+2                                                 02268000
DA18DDN  EQU   DAPB18+12                                                02269000
DA18DPS2 EQU   DAPB18+30                                                02270000
DA18KEEP EQU   DA18DPS2                                                 02271000
DA18CTL  EQU   DAPB18+31                                                02272000
CPPL     EQU   0                                                        02273000
CPPLCBUF EQU   CPPL                                                     02274000
CPPLUPT  EQU   CPPL+4                                                   02275000
CPPLPSCB EQU   CPPL+8                                                   02276000
CPPLECT  EQU   CPPL+12                                                  02277000
ECT      EQU   0                                                        02278000
ECTIOWA  EQU   ECT+4                                                    02279000
ECTPCMD  EQU   ECT+12                                                   02280000
ECTSWS   EQU   ECT+28                                                   02281000
IOPL     EQU   0                                                        02282000
IOPLIOPB EQU   IOPL+12                                                  02283000
GTPB     EQU   0                                                        02284000
GTPBIBUF EQU   GTPB+4                                                   02285000
PPL      EQU   0                                                        02286000
PPLUPT   EQU   PPL                                                      02287000
PPLECT   EQU   PPL+4                                                    02288000
PPLECB   EQU   PPL+8                                                    02289000
PPLPCL   EQU   PPL+12                                                   02290000
PPLANS   EQU   PPL+16                                                   02291000
PPLCBUF  EQU   PPL+20                                                   02292000
CSPL     EQU   0                                                        02293000
CSPLFLG  EQU   CSPL+12                                                  02294000
CSPLOA   EQU   CSPL+16                                                  02295000
CSOA     EQU   0                                                        02296000
CSOACNM  EQU   CSOA                                                     02297000
CSOALNM  EQU   CSOA+4                                                   02298000
CSOAFLG  EQU   CSOA+6                                                   02299000
MSGTABLE EQU   0                                                        02300000
LISTPTR  EQU   MSGTABLE                                                 02301000
TMCTPTR  EQU   MSGTABLE+4                                               02302000
ECBPTR   EQU   MSGTABLE+8                                               02303000
@NM00062 EQU   MSGTABLE+12                                              02304000
MSGCSECT EQU   MSGTABLE+16                                              02305000
SW       EQU   MSGTABLE+20                                              02306000
MTPUTLSW EQU   SW                                                       02307000
RETMSG   EQU   MSGTABLE+21                                              02308000
SW2      EQU   MSGTABLE+24                                              02309000
MSGID    EQU   MSGTABLE+40                                              02310000
MTINSRTS EQU   MSGTABLE+44                                              02311000
MTINSRT  EQU   MTINSRTS                                                 02312000
MTLEN    EQU   MTINSRT                                                  02313000
RET      EQU   0                                                        02314000
LSD      EQU   0                                                        02315000
LSDADATA EQU   LSD                                                      02316000
LSDTOTLN EQU   LSD+6                                                    02317000
LSDEXEC  EQU   LSD+12                                                   02318000
EXECDATA EQU   0                                                        02319000
SNTABFST EQU   EXECDATA                                                 02320000
SVTABFST EQU   EXECDATA+4                                               02321000
GEXECDAT EQU   EXECDATA+8                                               02322000
@NM00070 EQU   EXECDATA+16                                              02323000
EXDATFLG EQU   EXECDATA+32                                              02324000
@NM00071 EQU   EXDATFLG                                                 02325000
GEXECCNT EQU   EXECDATA+36                                              02326000
COMPROC  EQU   0                                                        02327000
COMPRPTR EQU   COMPROC                                                  02328000
COMPRNXT EQU   COMPRPTR+1                                               02329000
COMPRLNG EQU   COMPROC+4                                                02330000
COMPRUSE EQU   COMPROC+8                                                02331000
SNTAB    EQU   0                                                        02332000
SNTABNXT EQU   SNTAB                                                    02333000
SNTABLNG EQU   SNTAB+4                                                  02334000
SNTELEM  EQU   0                                                        02335000
SNTVLPTR EQU   SNTELEM                                                  02336000
SNTFLAGS EQU   SNTELEM+4                                                02337000
SNTLAST  EQU   SNTFLAGS                                                 02338000
SVTAB    EQU   0                                                        02339000
SVTABNXT EQU   SVTAB                                                    02340000
SVTABLNG EQU   SVTAB+4                                                  02341000
SVTELEM  EQU   0                                                        02342000
CVTMAP   EQU   0                                                        02343000
CVTDAR   EQU   CVTMAP+72                                                02344000
CVTFLGS1 EQU   CVTDAR                                                   02345000
CVTDCB   EQU   CVTMAP+116                                               02346000
CVTIERLC EQU   CVTMAP+144                                               02347000
CVTOPTA  EQU   CVTMAP+182                                               02348000
CVTOPTB  EQU   CVTMAP+183                                               02349000
CVTGTF   EQU   CVTMAP+236                                               02350000
CVTGTFST EQU   CVTGTF                                                   02351000
CVTGTFS  EQU   CVTGTFST                                                 02352000
CVTSTATE EQU   CVTGTFST                                                 02353000
CVTTMODE EQU   CVTGTFST                                                 02354000
CVTFORM  EQU   CVTGTFST                                                 02355000
CVTAQAVT EQU   CVTMAP+240                                               02356000
CVTTCMFG EQU   CVTAQAVT                                                 02357000
CVTVOLM2 EQU   CVTMAP+244                                               02358000
CVTTATA  EQU   CVTVOLM2                                                 02359000
CVTTSKS  EQU   CVTTATA                                                  02360000
CVTVOLF2 EQU   CVTTSKS                                                  02361000
CVTTAT   EQU   CVTTATA+1                                                02362000
CVTATER  EQU   CVTMAP+248                                               02363000
CVTEXT1  EQU   CVTMAP+252                                               02364000
CVTPURG  EQU   CVTMAP+260                                               02365000
CVTQMSG  EQU   CVTMAP+268                                               02366000
CVTDMSR  EQU   CVTMAP+272                                               02367000
CVTERPV  EQU   CVTMAP+316                                               02368000
CVTINTLA EQU   CVTMAP+320                                               02369000
CVTAPF   EQU   CVTMAP+324                                               02370000
CVTEXT2  EQU   CVTMAP+328                                               02371000
CVTHJES  EQU   CVTMAP+332                                               02372000
CVTPGSIA EQU   CVTMAP+348                                               02373000
CVTA1F1  EQU   CVTMAP+356                                               02374000
CVTSYSK  EQU   CVTMAP+357                                               02375000
CVTVOLM1 EQU   CVTMAP+380                                               02376000
CVTVOLF1 EQU   CVTVOLM1                                                 02377000
CVTATMCT EQU   CVTMAP+388                                               02378000
CVTXTNT1 EQU   0                                                        02379000
CVTXTNT2 EQU   0                                                        02380000
CVTDSSV  EQU   CVTXTNT2                                                 02381000
CVTFLGBT EQU   CVTXTNT2+5                                               02382000
CVTQID   EQU   CVTXTNT2+24                                              02383000
CVTRV400 EQU   CVTXTNT2+52                                              02384000
CVTRV409 EQU   CVTXTNT2+53                                              02385000
CVTATCVT EQU   CVTXTNT2+64                                              02386000
CVTRV429 EQU   CVTXTNT2+84                                              02387000
CVTRV438 EQU   CVTXTNT2+85                                              02388000
CVTRV457 EQU   CVTXTNT2+112                                             02389000
CVTRV466 EQU   CVTXTNT2+113                                             02390000
CVTFIX   EQU   0                                                        02391000
CVTRELNO EQU   CVTFIX+252                                               02392000
ALLOCINT EQU   0                                                        02393000
ALLOCSET EQU   0                                                        02394000
B1       EQU   ALLOCSET+12                                              02395000
B1A      EQU   B1                                                       02396000
B2       EQU   ALLOCSET+52                                              02397000
EXPAROUT EQU   0                                                        02398000
*        IBM's VLSTPTR/VLSTLNG sit in the unreferenced block    RXPTF           
*        that AGO .@UNREFD skips; same offsets, our names.      RXPTF           
RXVLPTR  EQU   EXPAROUT+32        value list: address           RXPTF           
RXVLLNG  EQU   EXPAROUT+36        value list: length            RXPTF           
DSNPTR   EQU   EXPAROUT+8                                               02399000
DSNLNG   EQU   EXPAROUT+12                                              02400000
DSNFLG   EQU   EXPAROUT+14                                              02401000
DSNQTE   EQU   DSNFLG                                                   02402000
MEMPTR   EQU   EXPAROUT+16                                              02403000
MEMLNG   EQU   EXPAROUT+20                                              02404000
MEMFLG   EQU   EXPAROUT+22                                              02405000
MEM      EQU   MEMFLG                                                   02406000
PSWDPTR  EQU   EXPAROUT+24                                              02407000
PSWDLNG  EQU   EXPAROUT+28                                              02408000
PSWDFLG  EQU   EXPAROUT+30                                              02409000
PSWD     EQU   PSWDFLG                                                  02410000
VLSTFLG  EQU   EXPAROUT+38                                              02411000
LISTPDE  EQU   EXPAROUT+40                                              02412000
PRMPPDE  EQU   EXPAROUT+42                                              02413000
PARDSN   EQU   0                                                        02414000
PARMEM   EQU   0                                                        02415000
PARPSWD  EQU   0                                                        02416000
CMDNME   EQU   0                                                        02417000
CMDBUFF  EQU   0                                                        02418000
CBUFLNG  EQU   CMDBUFF                                                  02419000
CBUFOFF  EQU   CMDBUFF+2                                                02420000
IOSRL    EQU   0                                                        02421000
IOSTELM  EQU   IOSRL                                                    02422000
INSTACK  EQU   0                                                        02423000
INSCODE  EQU   INSTACK                                                  02424000
INSEXEC  EQU   INSCODE                                                  02425000
INADLSD  EQU   INSTACK+1                                                02426000
IGOTOMAP EQU   0                                                        02427000
IGOTOLL  EQU   IGOTOMAP                                                 02428000
IGOTOOO  EQU   IGOTOMAP+2                                               02429000
IGOTOO2  EQU   IGOTOMAP+4                                               02430000
IGOTOOP  EQU   IGOTOMAP+6                                               02431000
IGOTOADD EQU   IGOTOMAP+7                                               02432000
STAEWORK EQU   0                                                        02433000
STAPARMS EQU   0                                                        02434000
CDEBASE  EQU   STAPARMS                                                 02435000
DATBASE  EQU   STAPARMS+4                                               02436000
SAVBASE  EQU   STAPARMS+8                                               02437000
RETRY    EQU   0                                                        02438000
DFMSGWTP EQU   0                                                        02439000
DFRC     EQU   0                                                        02440000
I001C    EQU   0                                                        02441000
I008P    EQU   0                                                        02442000
I015F    EQU   0                                                        02443000
I015P    EQU   0                                                        02444000
I031F    EQU   0                                                        02445000
I031P    EQU   0                                                        02446000
I256C    EQU   0                                                        02447000
MSGECB   EQU   0                                                        02448000
MSGTMCT  EQU   0                                                        02449000
APARM    EQU   0                                                        02450000
DAPLPTR  EQU   SERVPTR                                                  02451000
DAPB1PTR EQU   DAPB0PTR                                                 02452000
CPPLPTR  EQU   ECDACPPL                                                 02453000
ECTPTR   EQU   CPPLECT                                                  02454000
IOPLPTR  EQU   SERVPTR                                                  02455000
GTPBPTR  EQU   IOPLIOPB                                                 02456000
PPLPTR   EQU   SERVPTR                                                  02457000
CSPLPTR  EQU   SERVPTR                                                  02458000
CSOAPTR  EQU   CSPLOA                                                   02459000
LSDPTR   EQU   ECDALSD                                                  02460000
CVTS01   EQU   CVTPGSIA                                                 02461000
CVTLPDIA EQU   CVTS01+12                                                02462000
CVTDIRST EQU   CVTLPDIA                                                 02463000
CVTSLIDA EQU   CVTS01+24                                                02464000
CVTCTLFG EQU   CVTS01+50                                                02465000
CVTSCAN  EQU   CVTS01+132                                               02466000
CVTPARS  EQU   CVTS01+176                                               02467000
CVTDAIR  EQU   CVTS01+384                                               02468000
CVTRV210 EQU   CVTS01+424                                               02469000
CVTRV219 EQU   CVTS01+425                                               02470000
CVTRV228 EQU   CVTS01+426                                               02471000
CVTRV237 EQU   CVTS01+427                                               02472000
CVTMFRTR EQU   CVTS01+452                                               02473000
CVTRV262 EQU   CVTS01+468                                               02474000
CVTRV271 EQU   CVTS01+469                                               02475000
CVTRV280 EQU   CVTS01+470                                               02476000
CVTRV289 EQU   CVTS01+471                                               02477000
CVTGSDA  EQU   CVTS01+600                                               02478000
DAIRFLGS EQU   DA00FLG                                                  02479000
PERMALLO EQU   DAIRFLGS                                                 02480000
DSNINDSE EQU   DAIRFLGS                                                 02481000
DSORG0   EQU   DA00DSO                                                  02482000
PART0    EQU   DSORG0                                                   02483000
DSORG8   EQU   DA08DSO                                                  02484000
SEQ8     EQU   DSORG8                                                   02485000
PART8    EQU   DSORG8                                                   02486000
CPRECNXT EQU   ECDACNXT+1                                               02487000
CPBLKPTR EQU   ECDACBLK+1                                               02488000
ECDAINIT EQU   ECDA+5                                                   02489000
I006     EQU   ILIST                                                    02490000
I00601   EQU   I006                                                     02491000
I00602   EQU   I006+1                                                   02492000
I00603   EQU   I006+4                                                   02493000
I00604   EQU   I006+5                                                   02494000
I005     EQU   ILIST                                                    02495000
I00502   EQU   I005+1                                                   02496000
I00504   EQU   I005+5                                                   02497000
I00505   EQU   I005+8                                                   02498000
I00506   EQU   I005+9                                                   02499000
         AGO   .@UNREFD                START UNREFERENCED COMPONENTS    02500000
I00503   EQU   I005+4                                                   02501000
I00501   EQU   I005                                                     02502000
I00605   EQU   I006+8                                                   02503000
@NM00089 EQU   DSORG8                                                   02504000
@NM00088 EQU   DSORG8                                                   02505000
@NM00087 EQU   DSORG0                                                   02506000
@NM00086 EQU   DAIRFLGS                                                 02507000
@NM00085 EQU   DAIRFLGS                                                 02508000
CVTRV628 EQU   CVTS01+728                                               02509000
CVTRV627 EQU   CVTS01+724                                               02510000
CVTRV626 EQU   CVTS01+720                                               02511000
CVTRV625 EQU   CVTS01+716                                               02512000
CVTRV624 EQU   CVTS01+712                                               02513000
CVTRV623 EQU   CVTS01+708                                               02514000
CVTRV622 EQU   CVTS01+704                                               02515000
CVTRV621 EQU   CVTS01+700                                               02516000
CVTRV620 EQU   CVTS01+696                                               02517000
CVTRV619 EQU   CVTS01+692                                               02518000
CVTRV618 EQU   CVTS01+688                                               02519000
CVTRV617 EQU   CVTS01+684                                               02520000
CVTRV616 EQU   CVTS01+680                                               02521000
CVTRV615 EQU   CVTS01+676                                               02522000
CVTRV614 EQU   CVTS01+672                                               02523000
CVTRV613 EQU   CVTS01+668                                               02524000
CVTRV612 EQU   CVTS01+664                                               02525000
CVTRV611 EQU   CVTS01+660                                               02526000
CVTRV610 EQU   CVTS01+656                                               02527000
CVTRV609 EQU   CVTS01+652                                               02528000
CVTRV608 EQU   CVTS01+648                                               02529000
CVTRV607 EQU   CVTS01+644                                               02530000
CVTRV606 EQU   CVTS01+640                                               02531000
CVTRV605 EQU   CVTS01+636                                               02532000
CVTRV604 EQU   CVTS01+632                                               02533000
CVTEFF02 EQU   CVTS01+628                                               02534000
CVTCBBR  EQU   CVTS01+624                                               02535000
CVTSSCR  EQU   CVTS01+620                                               02536000
CVTEVENT EQU   CVTS01+616                                               02537000
CVTCRCA  EQU   CVTS01+612                                               02538000
CVTTPIO  EQU   CVTS01+608                                               02539000
CVTADV   EQU   CVTS01+604                                               02540000
CVTGSDAB EQU   CVTGSDA                                                  02541000
CVTQV3   EQU   CVTS01+596                                               02542000
CVTQV2   EQU   CVTS01+592                                               02543000
CVTQV1   EQU   CVTS01+588                                               02544000
CVTRPT   EQU   CVTS01+584                                               02545000
CVTSSRB  EQU   CVTS01+580                                               02546000
CVTCSDRL EQU   CVTS01+576                                               02547000
CVTEXP1  EQU   CVTS01+572                                               02548000
CVTRMPMT EQU   CVTS01+568                                               02549000
CVTRMPTT EQU   CVTS01+564                                               02550000
CVTVPSA  EQU   CVTS01+560                                               02551000
CVTVSTOP EQU   CVTS01+556                                               02552000
CVTGTFR8 EQU   CVTS01+552                                               02553000
CVTQUIT  EQU   CVTS01+548                                               02554000
CVTVACR  EQU   CVTS01+544                                               02555000
CVTWTCB  EQU   CVTS01+540                                               02556000
CVTSTPRS EQU   CVTS01+536                                               02557000
CVT0PT02 EQU   CVTS01+532                                               02558000
CVTDARCM EQU   CVTS01+528                                               02559000
CVTIRECM EQU   CVTS01+524                                               02560000
CVTJRECM EQU   CVTS01+520                                               02561000
CVTVEMS0 EQU   CVTS01+516                                               02562000
CVTSPFRR EQU   CVTS01+512                                               02563000
CVTRLSTG EQU   CVTS01+508                                               02564000
CVT0TC0A EQU   CVTS01+504                                               02565000
CVTGMBR  EQU   CVTS01+500                                               02566000
CVTLFRM  EQU   CVTS01+496                                               02567000
CVTRMBR  EQU   CVTS01+492                                               02568000
CVTVIOP  EQU   CVTS01+488                                               02569000
CVTRV307 EQU   CVTS01+486                                               02570000
CVTRV306 EQU   CVTS01+484                                               02571000
CVTRV305 EQU   CVTS01+482                                               02572000
CVTRV304 EQU   CVTS01+480                                               02573000
CVTRV303 EQU   CVTS01+478                                               02574000
CVTRV302 EQU   CVTS01+476                                               02575000
CVTTRCA  EQU   CVTS01+472                                               02576000
CVTRV297 EQU   CVTRV289                                                 02577000
CVTRV296 EQU   CVTRV289                                                 02578000
CVTRV295 EQU   CVTRV289                                                 02579000
CVTRV294 EQU   CVTRV289                                                 02580000
CVTRV293 EQU   CVTRV289                                                 02581000
CVTRV292 EQU   CVTRV289                                                 02582000
CVTRV291 EQU   CVTRV289                                                 02583000
CVTRV290 EQU   CVTRV289                                                 02584000
CVTRV288 EQU   CVTRV280                                                 02585000
CVTRV287 EQU   CVTRV280                                                 02586000
CVTRV286 EQU   CVTRV280                                                 02587000
CVTRV285 EQU   CVTRV280                                                 02588000
CVTRV284 EQU   CVTRV280                                                 02589000
CVTRV283 EQU   CVTRV280                                                 02590000
CVTRV282 EQU   CVTRV280                                                 02591000
CVTRV281 EQU   CVTRV280                                                 02592000
CVTRV279 EQU   CVTRV271                                                 02593000
CVTRV278 EQU   CVTRV271                                                 02594000
CVTRV277 EQU   CVTRV271                                                 02595000
CVTRV276 EQU   CVTRV271                                                 02596000
CVTRV275 EQU   CVTRV271                                                 02597000
CVTRV274 EQU   CVTRV271                                                 02598000
CVTRV273 EQU   CVTRV271                                                 02599000
CVTRV272 EQU   CVTRV271                                                 02600000
CVTRV270 EQU   CVTRV262                                                 02601000
CVTRV269 EQU   CVTRV262                                                 02602000
CVTRV268 EQU   CVTRV262                                                 02603000
CVTRV267 EQU   CVTRV262                                                 02604000
CVTRV266 EQU   CVTRV262                                                 02605000
CVTRV265 EQU   CVTRV262                                                 02606000
CVTRV264 EQU   CVTRV262                                                 02607000
CVTRV263 EQU   CVTRV262                                                 02608000
CVTVFP   EQU   CVTS01+464                                               02609000
CVTVSI   EQU   CVTS01+460                                               02610000
CVTVPSIB EQU   CVTS01+456                                               02611000
CVTMFACT EQU   CVTMFRTR                                                 02612000
CVTMFCTL EQU   CVTS01+448                                               02613000
CVTPVBP  EQU   CVTS01+444                                               02614000
CVTPWI   EQU   CVTS01+440                                               02615000
CVTRV254 EQU   CVTS01+438                                               02616000
CVTRV253 EQU   CVTS01+436                                               02617000
CVTRV252 EQU   CVTS01+434                                               02618000
CVTRV251 EQU   CVTS01+433                                               02619000
CVTRV250 EQU   CVTS01+432                                               02620000
CVTRV249 EQU   CVTS01+431                                               02621000
CVTRV248 EQU   CVTS01+430                                               02622000
CVTRV247 EQU   CVTS01+429                                               02623000
CVTRV246 EQU   CVTS01+428                                               02624000
CVTRV245 EQU   CVTRV237                                                 02625000
CVTRV244 EQU   CVTRV237                                                 02626000
CVTRV243 EQU   CVTRV237                                                 02627000
CVTRV242 EQU   CVTRV237                                                 02628000
CVTRV241 EQU   CVTRV237                                                 02629000
CVTRV240 EQU   CVTRV237                                                 02630000
CVTRV239 EQU   CVTRV237                                                 02631000
CVTRV238 EQU   CVTRV237                                                 02632000
CVTRV236 EQU   CVTRV228                                                 02633000
CVTRV235 EQU   CVTRV228                                                 02634000
CVTRV234 EQU   CVTRV228                                                 02635000
CVTRV233 EQU   CVTRV228                                                 02636000
CVTRV232 EQU   CVTRV228                                                 02637000
CVTRV231 EQU   CVTRV228                                                 02638000
CVTRV230 EQU   CVTRV228                                                 02639000
CVTRV229 EQU   CVTRV228                                                 02640000
CVTRV227 EQU   CVTRV219                                                 02641000
CVTRV226 EQU   CVTRV219                                                 02642000
CVTRV225 EQU   CVTRV219                                                 02643000
CVTRV224 EQU   CVTRV219                                                 02644000
CVTRV223 EQU   CVTRV219                                                 02645000
CVTRV222 EQU   CVTRV219                                                 02646000
CVTRV221 EQU   CVTRV219                                                 02647000
CVTRV220 EQU   CVTRV219                                                 02648000
CVTRV218 EQU   CVTRV210                                                 02649000
CVTRV217 EQU   CVTRV210                                                 02650000
CVTRV216 EQU   CVTRV210                                                 02651000
CVTRV215 EQU   CVTRV210                                                 02652000
CVTRV214 EQU   CVTRV210                                                 02653000
CVTRV213 EQU   CVTRV210                                                 02654000
CVTRV212 EQU   CVTRV210                                                 02655000
CVTRV211 EQU   CVTRV210                                                 02656000
CVTLCCAT EQU   CVTS01+420                                               02657000
CVTPCCAT EQU   CVTS01+416                                               02658000
CVTIPCRP EQU   CVTS01+412                                               02659000
CVTIPCRI EQU   CVTS01+408                                               02660000
CVTIPCDS EQU   CVTS01+404                                               02661000
CVTAIDVT EQU   CVTS01+400                                               02662000
CVTSSAP  EQU   CVTS01+396                                               02663000
CVTEHCIR EQU   CVTS01+392                                               02664000
CVTEHDEF EQU   CVTS01+388                                               02665000
CVTPERFM EQU   CVTS01+380                                               02666000
CVT044R2 EQU   CVTS01+376                                               02667000
CVTFETCH EQU   CVTS01+372                                               02668000
CVTRSTWD EQU   CVTS01+368                                               02669000
CVTSPOST EQU   CVTS01+364                                               02670000
CVTIOBP  EQU   CVTS01+360                                               02671000
CVTASMVT EQU   CVTS01+356                                               02672000
CVTRECRQ EQU   CVTS01+352                                               02673000
CVTWSAC  EQU   CVTS01+348                                               02674000
CVTRV149 EQU   CVTS01+344                                               02675000
CVTWSAL  EQU   CVTS01+340                                               02676000
CVTSPSA  EQU   CVTS01+336                                               02677000
CVTGLMN  EQU   CVTS01+332                                               02678000
CVTVEAC0 EQU   CVTS01+328                                               02679000
CVT062R1 EQU   CVTS01+324                                               02680000
CVTRPOST EQU   CVTS01+320                                               02681000
CVTDQIQE EQU   CVTS01+316                                               02682000
CVTCSD   EQU   CVTS01+312                                               02683000
CVTLKRMA EQU   CVTS01+308                                               02684000
CVTRSPIE EQU   CVTS01+304                                               02685000
CVTRENQ  EQU   CVTS01+300                                               02686000
CVTLQCB  EQU   CVTS01+296                                               02687000
CVTFQCB  EQU   CVTS01+292                                               02688000
CVTQCS01 EQU   CVTS01+288                                               02689000
CVTAPFT  EQU   CVTS01+284                                               02690000
CVTPARRL EQU   CVTS01+280                                               02691000
CVTVWAIT EQU   CVTS01+276                                               02692000
CVTGSPL  EQU   CVTS01+272                                               02693000
CVTLSMQ  EQU   CVTS01+268                                               02694000
CVTGSMQ  EQU   CVTS01+264                                               02695000
CVTEXPRO EQU   CVTS01+260                                               02696000
CVTOPCTP EQU   CVTS01+256                                               02697000
CVTSIC   EQU   CVTS01+252                                               02698000
CVTTPIOS EQU   CVTS01+248                                               02699000
CVTRTMS  EQU   CVTS01+244                                               02700000
CVTSDBF  EQU   CVTS01+240                                               02701000
CVTSCBP  EQU   CVTS01+236                                               02702000
CVTSDMP  EQU   CVTS01+232                                               02703000
CVTSV60  EQU   CVTS01+228                                               02704000
CVTRTMCT EQU   CVTS01+224                                               02705000
CVTASCBL EQU   CVTS01+220                                               02706000
CVTASCBH EQU   CVTS01+216                                               02707000
CVTGDA   EQU   CVTS01+212                                               02708000
CVTASVT  EQU   CVTS01+208                                               02709000
CVTVVMDI EQU   CVTS01+204                                               02710000
CVTAQTOP EQU   CVTS01+200                                               02711000
CVTIOSCS EQU   CVTS01+196                                               02712000
CVTSDRM  EQU   CVTS01+192                                               02713000
CVTOPTE  EQU   CVTS01+188                                               02714000
CVTSTXU  EQU   CVTS01+184                                               02715000
CVTQUIS  EQU   CVTS01+180                                               02716000
CVTS1EE  EQU   CVTS01+172                                               02717000
CVTFRAS  EQU   CVTS01+168                                               02718000
CVTQSAS  EQU   CVTS01+164                                               02719000
CVTCRAS  EQU   CVTS01+160                                               02720000
CVTCRMN  EQU   CVTS01+156                                               02721000
CVTDELCP EQU   CVTS01+152                                               02722000
CVTFRECL EQU   CVTS01+148                                               02723000
CVTGETCL EQU   CVTS01+144                                               02724000
CVTBLDCP EQU   CVTS01+140                                               02725000
CVTAUTHL EQU   CVTS01+136                                               02726000
CVTRV144 EQU   CVTS01+130                                               02727000
CVTMAXMP EQU   CVTS01+128                                               02728000
CVTSTCK  EQU   CVTS01+124                                               02729000
CVTRV139 EQU   CVTS01+123                                               02730000
CVTDSSAC EQU   CVTS01+122                                               02731000
CVTRV513 EQU   CVTS01+121                                               02732000
CVTIOSPL EQU   CVTS01+120                                               02733000
CVTPTGT  EQU   CVTS01+116                                               02734000
CVTCSPIE EQU   CVTS01+112                                               02735000
CVTSMFEX EQU   CVTS01+108                                               02736000
CVTOLT0A EQU   CVTS01+104                                               02737000
CVTSRBRT EQU   CVTS01+100                                               02738000
CVTPUTL  EQU   CVTS01+96                                                02739000
CVTRV519 EQU   CVTS01+92                                                02740000
CVTRV327 EQU   CVTS01+88                                                02741000
CVTRV326 EQU   CVTS01+84                                                02742000
CVTRV325 EQU   CVTS01+80                                                02743000
CVTRV324 EQU   CVTS01+76                                                02744000
CVT0VL01 EQU   CVTS01+72                                                02745000
CVTSHRVM EQU   CVTS01+68                                                02746000
CVTRV332 EQU   CVTS01+64                                                02747000
CVTTAS   EQU   CVTS01+60                                                02748000
CVTRSCN  EQU   CVTS01+56                                                02749000
CVTTRAC2 EQU   CVTS01+54                                                02750000
CVTTRACE EQU   CVTS01+52                                                02751000
CVTAPG   EQU   CVTS01+51                                                02752000
CVTSDTRC EQU   CVTCTLFG                                                 02753000
CVTGTRCE EQU   CVTCTLFG                                                 02754000
CVTNOMP  EQU   CVTCTLFG                                                 02755000
CVTRSV79 EQU   CVTCTLFG                                                 02756000
CVTDSTAT EQU   CVTCTLFG                                                 02757000
CVTRSV78 EQU   CVTCTLFG                                                 02758000
CVTRV333 EQU   CVTCTLFG                                                 02759000
CVTRV323 EQU   CVTCTLFG                                                 02760000
CVTSPVLK EQU   CVTS01+49                                                02761000
CVTRSV77 EQU   CVTS01+48                                                02762000
CVTRV331 EQU   CVTS01+44                                                02763000
CVTRV330 EQU   CVTS01+40                                                02764000
CVTRV329 EQU   CVTS01+36                                                02765000
CVTRV328 EQU   CVTS01+32                                                02766000
CVTRV322 EQU   CVTS01+28                                                02767000
CVTSLID  EQU   CVTSLIDA+1                                               02768000
CVTSYLK  EQU   CVTSLIDA                                                 02769000
CVTRV321 EQU   CVTS01+20                                                02770000
CVTRV320 EQU   CVTS01+16                                                02771000
CVTLPDIR EQU   CVTLPDIA+1                                               02772000
CVTRSV69 EQU   CVTDIRST                                                 02773000
CVTRSV68 EQU   CVTDIRST                                                 02774000
CVTRSV67 EQU   CVTDIRST                                                 02775000
CVTRSV66 EQU   CVTDIRST                                                 02776000
CVTRSV65 EQU   CVTDIRST                                                 02777000
CVTRSV64 EQU   CVTDIRST                                                 02778000
CVTRSV63 EQU   CVTDIRST                                                 02779000
CVTDICOM EQU   CVTDIRST                                                 02780000
CVTPVTP  EQU   CVTS01+8                                                 02781000
CVTLPDSR EQU   CVTS01+4                                                 02782000
CVTGETL  EQU   CVTS01                                                   02783000
INSLIST  EQU   INSCODE                                                  02784000
INSPROC  EQU   INSCODE                                                  02785000
INSPROM  EQU   INSCODE                                                  02786000
INSOTDD  EQU   INSCODE                                                  02787000
INSINDD  EQU   INSCODE                                                  02788000
INSSTOR  EQU   INSCODE                                                  02789000
INSDATA  EQU   INSCODE                                                  02790000
@NM00090 EQU   IOSRL+12                                                 02791000
IOSNELM  EQU   IOSRL+10                                                 02792000
IOSTLEN  EQU   IOSRL+8                                                  02793000
IOSBELM  EQU   IOSRL+4                                                  02794000
CBUFTEXT EQU   CMDBUFF+4                                                02795000
@NM00084 EQU   EXPAROUT+39                                              02796000
VLST     EQU   VLSTFLG                                                  02797000
VLSTLNG  EQU   EXPAROUT+36                                              02798000
VLSTPTR  EQU   EXPAROUT+32                                              02799000
@NM00083 EQU   EXPAROUT+31                                              02800000
@NM00082 EQU   EXPAROUT+23                                              02801000
@NM00081 EQU   EXPAROUT+15                                              02802000
DSN      EQU   DSNFLG                                                   02803000
PDLLNG   EQU   EXPAROUT+6                                               02804000
PDLSPNO  EQU   EXPAROUT+4                                               02805000
PDLNXT   EQU   EXPAROUT                                                 02806000
@NM00080 EQU   ALLOCSET+71                                              02807000
@NM00079 EQU   ALLOCSET+68                                              02808000
@NM00078 EQU   ALLOCSET+36                                              02809000
@NM00077 EQU   ALLOCSET                                                 02810000
CVTLEVL  EQU   CVTRELNO+2                                               02811000
CVTNUMB  EQU   CVTRELNO                                                 02812000
CVTMDL   EQU   CVTFIX+250                                               02813000
@NM00075 EQU   CVTFIX+248                                               02814000
@NM00074 EQU   CVTFIX                                                   02815000
CVTRV482 EQU   CVTXTNT2+128                                             02816000
CVTRV481 EQU   CVTXTNT2+124                                             02817000
CVTRV480 EQU   CVTXTNT2+120                                             02818000
CVTRV479 EQU   CVTXTNT2+118                                             02819000
CVTRV478 EQU   CVTXTNT2+117                                             02820000
CVTRV477 EQU   CVTXTNT2+116                                             02821000
CVTRV476 EQU   CVTXTNT2+115                                             02822000
CVTRV475 EQU   CVTXTNT2+114                                             02823000
CVTRV474 EQU   CVTRV466                                                 02824000
CVTRV473 EQU   CVTRV466                                                 02825000
CVTRV472 EQU   CVTRV466                                                 02826000
CVTRV471 EQU   CVTRV466                                                 02827000
CVTRV470 EQU   CVTRV466                                                 02828000
CVTRV469 EQU   CVTRV466                                                 02829000
CVTRV468 EQU   CVTRV466                                                 02830000
CVTRV467 EQU   CVTRV466                                                 02831000
CVTRV465 EQU   CVTRV457                                                 02832000
CVTRV464 EQU   CVTRV457                                                 02833000
CVTRV463 EQU   CVTRV457                                                 02834000
CVTRV462 EQU   CVTRV457                                                 02835000
CVTRV461 EQU   CVTRV457                                                 02836000
CVTRV460 EQU   CVTRV457                                                 02837000
CVTRV459 EQU   CVTRV457                                                 02838000
CVTRV458 EQU   CVTRV457                                                 02839000
CVTRV456 EQU   CVTXTNT2+108                                             02840000
CVTRV455 EQU   CVTXTNT2+104                                             02841000
CVTRV454 EQU   CVTXTNT2+100                                             02842000
CVTRV453 EQU   CVTXTNT2+96                                              02843000
CVTRV452 EQU   CVTXTNT2+94                                              02844000
CVTRV451 EQU   CVTXTNT2+92                                              02845000
CVTRV450 EQU   CVTXTNT2+90                                              02846000
CVTRV449 EQU   CVTXTNT2+88                                              02847000
CVTRV448 EQU   CVTXTNT2+87                                              02848000
CVTRV447 EQU   CVTXTNT2+86                                              02849000
CVTRV446 EQU   CVTRV438                                                 02850000
CVTRV445 EQU   CVTRV438                                                 02851000
CVTRV444 EQU   CVTRV438                                                 02852000
CVTRV443 EQU   CVTRV438                                                 02853000
CVTRV442 EQU   CVTRV438                                                 02854000
CVTRV441 EQU   CVTRV438                                                 02855000
CVTRV440 EQU   CVTRV438                                                 02856000
CVTRV439 EQU   CVTRV438                                                 02857000
CVTRV437 EQU   CVTRV429                                                 02858000
CVTRV436 EQU   CVTRV429                                                 02859000
CVTRV435 EQU   CVTRV429                                                 02860000
CVTRV434 EQU   CVTRV429                                                 02861000
CVTRV433 EQU   CVTRV429                                                 02862000
CVTRV432 EQU   CVTRV429                                                 02863000
CVTRV431 EQU   CVTRV429                                                 02864000
CVTRV430 EQU   CVTRV429                                                 02865000
CVTRV428 EQU   CVTXTNT2+80                                              02866000
CVTRV427 EQU   CVTXTNT2+76                                              02867000
CVTRV426 EQU   CVTXTNT2+72                                              02868000
CVTRV425 EQU   CVTXTNT2+68                                              02869000
CVTATACT EQU   CVTATCVT                                                 02870000
CVTRV423 EQU   CVTXTNT2+62                                              02871000
CVTRV422 EQU   CVTXTNT2+60                                              02872000
CVTRV421 EQU   CVTXTNT2+58                                              02873000
CVTRV420 EQU   CVTXTNT2+56                                              02874000
CVTRV419 EQU   CVTXTNT2+55                                              02875000
CVTRV418 EQU   CVTXTNT2+54                                              02876000
CVTRV417 EQU   CVTRV409                                                 02877000
CVTRV416 EQU   CVTRV409                                                 02878000
CVTRV415 EQU   CVTRV409                                                 02879000
CVTRV414 EQU   CVTRV409                                                 02880000
CVTRV413 EQU   CVTRV409                                                 02881000
CVTRV412 EQU   CVTRV409                                                 02882000
CVTRV411 EQU   CVTRV409                                                 02883000
CVTRV410 EQU   CVTRV409                                                 02884000
CVTRV408 EQU   CVTRV400                                                 02885000
CVTRV407 EQU   CVTRV400                                                 02886000
CVTRV406 EQU   CVTRV400                                                 02887000
CVTRV405 EQU   CVTRV400                                                 02888000
CVTRV404 EQU   CVTRV400                                                 02889000
CVTRV403 EQU   CVTRV400                                                 02890000
CVTRV402 EQU   CVTRV400                                                 02891000
CVTRV401 EQU   CVTRV400                                                 02892000
CVTICB   EQU   CVTXTNT2+48                                              02893000
CVTSKTA  EQU   CVTXTNT2+44                                              02894000
CVTRSV99 EQU   CVTXTNT2+40                                              02895000
CVTRSV98 EQU   CVTXTNT2+36                                              02896000
CVTRSV97 EQU   CVTXTNT2+34                                              02897000
CVTRSV96 EQU   CVTXTNT2+32                                              02898000
CVTOLTEP EQU   CVTXTNT2+28                                              02899000
CVTQIDA  EQU   CVTQID+1                                                 02900000
CVTRSV95 EQU   CVTQID                                                   02901000
CVTRSV94 EQU   CVTXTNT2+20                                              02902000
CVTRSV93 EQU   CVTXTNT2+16                                              02903000
CVTRSV92 EQU   CVTXTNT2+12                                              02904000
CVTDEBVR EQU   CVTXTNT2+8                                               02905000
CVTRSV91 EQU   CVTXTNT2+6                                               02906000
CVTRSV9H EQU   CVTFLGBT                                                 02907000
CVTRSV9G EQU   CVTFLGBT                                                 02908000
CVTRSV9F EQU   CVTFLGBT                                                 02909000
CVTRSV9E EQU   CVTFLGBT                                                 02910000
CVTRSV9D EQU   CVTFLGBT                                                 02911000
CVTRSV9C EQU   CVTFLGBT                                                 02912000
CVTVME   EQU   CVTFLGBT                                                 02913000
CVTNPE   EQU   CVTFLGBT                                                 02914000
CVTNUCLS EQU   CVTXTNT2+4                                               02915000
CVTDSSVA EQU   CVTDSSV+1                                                02916000
CVTRSV89 EQU   CVTDSSV                                                  02917000
CVTRSV88 EQU   CVTXTNT1+8                                               02918000
CVTRSV87 EQU   CVTXTNT1+4                                               02919000
CVTFACHN EQU   CVTXTNT1                                                 02920000
CVTRV488 EQU   CVTMAP+412                                               02921000
CVTRV487 EQU   CVTMAP+408                                               02922000
CVTRV486 EQU   CVTMAP+404                                               02923000
CVTRV485 EQU   CVTMAP+400                                               02924000
CVTACTAP EQU   CVTMAP+396                                               02925000
CVTAUTH  EQU   CVTMAP+392                                               02926000
CVTATMCA EQU   CVTATMCT+1                                               02927000
CVTATMST EQU   CVTATMCT                                                 02928000
CVTRSV61 EQU   CVTMAP+384                                               02929000
CVTVOLT1 EQU   CVTVOLM1+1                                               02930000
CVTVOLI1 EQU   CVTVOLF1                                                 02931000
CVTSTOA  EQU   CVTMAP+376                                               02932000
CVTRSV58 EQU   CVTMAP+374                                               02933000
CVTRSV57 EQU   CVTMAP+372                                               02934000
CVTDDCE  EQU   CVTMAP+368                                               02935000
CVTPNWFR EQU   CVTMAP+364                                               02936000
CVTSMF   EQU   CVTMAP+360                                               02937000
CVTSULK  EQU   CVTMAP+358                                               02938000
CVTSLKO  EQU   CVTSYSK                                                  02939000
CVTSLKP  EQU   CVTSYSK                                                  02940000
CVTSLKQ  EQU   CVTSYSK                                                  02941000
CVTSLKR  EQU   CVTSYSK                                                  02942000
CVTRSV56 EQU   CVTSYSK                                                  02943000
CVTRSV55 EQU   CVTSYSK                                                  02944000
CVTRSV54 EQU   CVTSYSK                                                  02945000
CVTRSV53 EQU   CVTSYSK                                                  02946000
CVTRSV52 EQU   CVTA1F1                                                  02947000
CVTRSV51 EQU   CVTA1F1                                                  02948000
CVTRSV50 EQU   CVTA1F1                                                  02949000
CVTRSV49 EQU   CVTA1F1                                                  02950000
CVTRSV48 EQU   CVTA1F1                                                  02951000
CVTRSV47 EQU   CVTA1F1                                                  02952000
CVTSRSW  EQU   CVTA1F1                                                  02953000
CVTPFSW  EQU   CVTA1F1                                                  02954000
CVTPCVT  EQU   CVTMAP+352                                               02955000
CVTRSV46 EQU   CVTMAP+344                                               02956000
CVTRSV45 EQU   CVTMAP+340                                               02957000
CVTRSV44 EQU   CVTMAP+338                                               02958000
CVTRSV43 EQU   CVTMAP+336                                               02959000
CVTHJESA EQU   CVTHJES+1                                                02960000
CVTRSV42 EQU   CVTHJES                                                  02961000
CVTEXT2A EQU   CVTEXT2+1                                                02962000
CVTRSV41 EQU   CVTEXT2                                                  02963000
CVTAPFA  EQU   CVTAPF+1                                                 02964000
CVTRSV40 EQU   CVTAPF                                                   02965000
CVTRV518 EQU   CVTINTLA                                                 02966000
CVTRV517 EQU   CVTERPV                                                  02967000
CVTEORM  EQU   CVTMAP+312                                               02968000
CVTMCHPR EQU   CVTMAP+308                                               02969000
CVTTZ    EQU   CVTMAP+304                                               02970000
CVTJEPS  EQU   CVTMAP+300                                               02971000
CVTJESCT EQU   CVTMAP+296                                               02972000
CVTMODE  EQU   CVTMAP+292                                               02973000
CVTPTRV  EQU   CVTMAP+288                                               02974000
CVTREAL  EQU   CVTMAP+284                                               02975000
CVTRSV39 EQU   CVTMAP+280                                               02976000
CVTRSV38 EQU   CVTMAP+276                                               02977000
CVTDMSRA EQU   CVTDMSR+1                                                02978000
CVTRSV37 EQU   CVTDMSR                                                  02979000
CVTQMSGA EQU   CVTQMSG+1                                                02980000
CVTRSV36 EQU   CVTQMSG                                                  02981000
CVTAMFF  EQU   CVTMAP+264                                               02982000
CVTPURGA EQU   CVTPURG+1                                                02983000
CVTRSV35 EQU   CVTPURG                                                  02984000
CVTCBSP  EQU   CVTMAP+256                                               02985000
CVTATERA EQU   CVTATER+1                                                02986000
CVTSYST  EQU   CVTATER                                                  02987000
CVTVOLT2 EQU   CVTTAT                                                   02988000
CVTVOLI2 EQU   CVTVOLF2                                                 02989000
CVTAQAVB EQU   CVTAQAVT+1                                               02990000
CVTRSV34 EQU   CVTTCMFG                                                 02991000
CVTRSV33 EQU   CVTTCMFG                                                 02992000
CVTRSV32 EQU   CVTTCMFG                                                 02993000
CVTRSV31 EQU   CVTTCMFG                                                 02994000
CVTRSV30 EQU   CVTTCMFG                                                 02995000
CVTRSV29 EQU   CVTTCMFG                                                 02996000
CVTRSV28 EQU   CVTTCMFG                                                 02997000
CVTTCRDY EQU   CVTTCMFG                                                 02998000
CVTGTFA  EQU   CVTGTF+1                                                 02999000
CVTRSV27 EQU   CVTGTFST                                                 03000000
CVTRNIO  EQU   CVTGTFST                                                 03001000
CVTUSR   EQU   CVTGTFST                                                 03002000
CVTRV318 EQU   CVTFORM                                                  03003000
CVTRV317 EQU   CVTTMODE                                                 03004000
CVTRV316 EQU   CVTSTATE                                                 03005000
CVTRV315 EQU   CVTGTFS                                                  03006000
CVTGTFAV EQU   CVTGTFS                                                  03007000
CVT0SCR1 EQU   CVTMAP+232                                               03008000
CVTRV515 EQU   CVTMAP+228                                               03009000
CVTRMS   EQU   CVTMAP+224                                               03010000
CVTPATCH EQU   CVTMAP+220                                               03011000
CVTTSCE  EQU   CVTMAP+216                                               03012000
CVTLNKSC EQU   CVTMAP+214                                               03013000
CVTQABST EQU   CVTMAP+212                                               03014000
CVTMDLDS EQU   CVTMAP+208                                               03015000
CVTUSER  EQU   CVTMAP+204                                               03016000
CVTABEND EQU   CVTMAP+200                                               03017000
CVTSMCA  EQU   CVTMAP+196                                               03018000
CVTRSV18 EQU   CVTMAP+192                                               03019000
CVTQLPAQ EQU   CVTMAP+188                                               03020000
CVTQCDSR EQU   CVTMAP+184                                               03021000
CVTRSV17 EQU   CVTOPTB                                                  03022000
CVTRSV16 EQU   CVTOPTB                                                  03023000
CVTFP    EQU   CVTOPTB                                                  03024000
CVTAPTHR EQU   CVTOPTB                                                  03025000
CVTNLOG  EQU   CVTOPTB                                                  03026000
CVTTOD   EQU   CVTOPTB                                                  03027000
CVTCTIMS EQU   CVTOPTB                                                  03028000
CVTPROT  EQU   CVTOPTB                                                  03029000
CVTXPFP  EQU   CVTOPTA                                                  03030000
CVTASCII EQU   CVTOPTA                                                  03031000
CVTRSV13 EQU   CVTOPTA                                                  03032000
CVTRSV12 EQU   CVTOPTA                                                  03033000
CVTNIP   EQU   CVTOPTA                                                  03034000
CVTDDR   EQU   CVTOPTA                                                  03035000
CVTAPR   EQU   CVTOPTA                                                  03036000
CVTCCH   EQU   CVTOPTA                                                  03037000
CVTSNCTR EQU   CVTMAP+180                                               03038000
CVTQMWR  EQU   CVTMAP+176                                               03039000
CVTQOCR  EQU   CVTMAP+172                                               03040000
CVT1EF00 EQU   CVTMAP+168                                               03041000
CVTMZ00  EQU   CVTMAP+164                                               03042000
CVTHEAD  EQU   CVTMAP+160                                               03043000
CVTRSV11 EQU   CVTMAP+156                                               03044000
CVT0PT01 EQU   CVTMAP+152                                               03045000
CVTMSER  EQU   CVTMAP+148                                               03046000
CVTRV516 EQU   CVTIERLC                                                 03047000
CVTILCH  EQU   CVTMAP+140                                               03048000
CVT0DS   EQU   CVTMAP+136                                               03049000
CVTFBOSV EQU   CVTMAP+132                                               03050000
CVTNUCB  EQU   CVTMAP+128                                               03051000
CVTIXAVL EQU   CVTMAP+124                                               03052000
CVTIOQET EQU   CVTMAP+120                                               03053000
CVTDCBA  EQU   CVTMAP+117                                               03054000
CVTMVS2  EQU   CVTDCB                                                   03055000
CVT6DAT  EQU   CVTDCB                                                   03056000
CVT4MPS  EQU   CVTDCB                                                   03057000
CVTRSV09 EQU   CVTDCB                                                   03058000
CVT4MS1  EQU   CVTDCB                                                   03059000
CVT2SPS  EQU   CVTDCB                                                   03060000
CVT1SSS  EQU   CVTDCB                                                   03061000
CVTRSV08 EQU   CVTDCB                                                   03062000
CVTSTB   EQU   CVTMAP+112                                               03063000
CVTQTD00 EQU   CVTMAP+108                                               03064000
CVTQTE00 EQU   CVTMAP+104                                               03065000
CVTCUCB  EQU   CVTMAP+100                                               03066000
CVTSJQ   EQU   CVTMAP+96                                                03067000
CVTPBLDL EQU   CVTMAP+92                                                03068000
CVTTPC   EQU   CVTMAP+88                                                03069000
CVTSVDCB EQU   CVTMAP+84                                                03070000
CVTBRET  EQU   CVTMAP+82                                                03071000
CVTEXIT  EQU   CVTMAP+80                                                03072000
CVT0FN00 EQU   CVTMAP+76                                                03073000
CVTDARA  EQU   CVTDAR+1                                                 03074000
CVTRSV07 EQU   CVTFLGS1                                                 03075000
CVTRSV06 EQU   CVTFLGS1                                                 03076000
CVTRSV05 EQU   CVTFLGS1                                                 03077000
CVTRSV04 EQU   CVTFLGS1                                                 03078000
CVTRSV03 EQU   CVTFLGS1                                                 03079000
CVTRSV02 EQU   CVTFLGS1                                                 03080000
CVTRSV01 EQU   CVTFLGS1                                                 03081000
CVTDMPLK EQU   CVTFLGS1                                                 03082000
CVTXITP  EQU   CVTMAP+68                                                03083000
CVTZDTAB EQU   CVTMAP+64                                                03084000
CVTMSLT  EQU   CVTMAP+60                                                03085000
CVTDATE  EQU   CVTMAP+56                                                03086000
CVTBTERM EQU   CVTMAP+52                                                03087000
CVTSYSAD EQU   CVTMAP+48                                                03088000
CVTXTLER EQU   CVTMAP+44                                                03089000
CVTILK2  EQU   CVTMAP+40                                                03090000
CVTILK1  EQU   CVTMAP+36                                                03091000
CVTPRLTV EQU   CVTMAP+32                                                03092000
CVTPCNVT EQU   CVTMAP+28                                                03093000
CVT0VL00 EQU   CVTMAP+24                                                03094000
CVTXAPG  EQU   CVTMAP+20                                                03095000
CVTBUF   EQU   CVTMAP+16                                                03096000
CVTJOB   EQU   CVTMAP+12                                                03097000
CVTLINK  EQU   CVTMAP+8                                                 03098000
CVT0EF00 EQU   CVTMAP+4                                                 03099000
CVTTCBP  EQU   CVTMAP                                                   03100000
CVT      EQU   CVTMAP                                                   03101000
SVTDATA  EQU   SVTELEM+4                                                03102000
SVTORIG  EQU   SVTELEM+2                                                03103000
SVTLNG   EQU   SVTELEM                                                  03104000
SVTELFST EQU   SVTAB+16                                                 03105000
SVTABFRE EQU   SVTAB+12                                                 03106000
SVTABUSE EQU   SVTAB+8                                                  03107000
SNTDATA  EQU   SNTELEM+8                                                03108000
SNTLNG   EQU   SNTELEM+6                                                03109000
@NM00073 EQU   SNTFLAGS+1                                               03110000
SNTGLOB  EQU   SNTFLAGS+1                                               03111000
SNTEVAL  EQU   SNTFLAGS                                                 03112000
SNTNAUTH EQU   SNTFLAGS                                                 03113000
SNTNOSCN EQU   SNTFLAGS                                                 03114000
SNTLABEL EQU   SNTFLAGS                                                 03115000
SNTKEYW  EQU   SNTFLAGS                                                 03116000
SNTKEY   EQU   SNTFLAGS                                                 03117000
SNTPOSIT EQU   SNTFLAGS                                                 03118000
SNTGVAL  EQU   SNTVLPTR                                                 03119000
SNTELFST EQU   SNTAB+12                                                 03120000
SNTABUSE EQU   SNTAB+8                                                  03121000
COMRCDS  EQU   COMPROC+12                                               03122000
COMPRID  EQU   COMPRPTR                                                 03123000
@NM00072 EQU   EXECDATA+60                                              03124000
FILEDCBS EQU   EXECDATA+56                                              03125000
RETPTR2  EQU   EXECDATA+52                                              03126000
ATACTEND EQU   EXECDATA+48                                              03127000
ATACTSTR EQU   EXECDATA+44                                              03128000
EXDLMPTR EQU   EXECDATA+40                                              03129000
ATINCNTL EQU   @NM00071+1                                               03130000
ATTNCMD  EQU   @NM00071                                                 03131000
NOMSG    EQU   @NM00071                                                 03132000
CMAIN    EQU   @NM00071                                                 03133000
ERINCNTL EQU   @NM00071                                                 03134000
SYMLST   EQU   @NM00071                                                 03135000
NOFLUSH  EQU   @NM00071                                                 03136000
ERRCMD   EQU   @NM00071                                                 03137000
CONLST   EQU   @NM00071                                                 03138000
RETPTR   EQU   EXECDATA+28                                              03139000
ERACTEND EQU   EXECDATA+24                                              03140000
ERACTSTR EQU   EXECDATA+20                                              03141000
EXINSAVE EQU   @NM00070                                                 03142000
LASTTSO  EQU   EXECDATA+12                                              03143000
LSDANEXT EQU   LSD+8                                                    03144000
LSDRCLEN EQU   LSD+4                                                    03145000
RETCHAR  EQU   RET+2                                                    03146000
RETSIZE  EQU   RET                                                      03147000
MTADDR   EQU   MTINSRT+1                                                03148000
MTHIGHL  EQU   MTLEN                                                    03149000
@NM00066 EQU   MSGTABLE+36                                              03150000
@NM00065 EQU   MSGTABLE+32                                              03151000
MTOLDPTR EQU   MSGTABLE+28                                              03152000
@NM00064 EQU   MSGTABLE+25                                              03153000
@NM00063 EQU   SW2                                                      03154000
MTPGMSW  EQU   SW2                                                      03155000
MTNPLMSW EQU   SW2                                                      03156000
MTNOXQSW EQU   SW2                                                      03157000
MTDOMSW  EQU   SW2                                                      03158000
MT2OLDSW EQU   SW2                                                      03159000
MTNHEXSW EQU   SW                                                       03160000
MTWTPSW  EQU   SW                                                       03161000
MTJOBISW EQU   SW                                                       03162000
MTKEY1SW EQU   SW                                                       03163000
MTHEXSW  EQU   SW                                                       03164000
MTWTOSW  EQU   SW                                                       03165000
MTNOIDSW EQU   SW                                                       03166000
MTHIGH   EQU   @NM00062                                                 03167000
MTCPPL   EQU   TMCTPTR                                                  03168000
@NM00061 EQU   CSOA+7                                                   03169000
@NM00060 EQU   CSOAFLG                                                  03170000
@NM00059 EQU   CSOAFLG                                                  03171000
CSOAEXEC EQU   CSOAFLG                                                  03172000
CSOABAD  EQU   CSOAFLG                                                  03173000
CSOANOC  EQU   CSOAFLG                                                  03174000
CSOAQM   EQU   CSOAFLG                                                  03175000
CSOAVNP  EQU   CSOAFLG                                                  03176000
CSOAVWP  EQU   CSOAFLG                                                  03177000
CSPLCBUF EQU   CSPL+20                                                  03178000
CSPLECB  EQU   CSPL+8                                                   03179000
CSPLECT  EQU   CSPL+4                                                   03180000
CSPLUPT  EQU   CSPL                                                     03181000
PPLUWA   EQU   PPL+24                                                   03182000
@NM00058 EQU   GTPB                                                     03183000
IOPLECB  EQU   IOPL+8                                                   03184000
IOPLECT  EQU   IOPL+4                                                   03185000
IOPLUPT  EQU   IOPL                                                     03186000
ECTBKPB  EQU   ECT+36                                                   03187000
ECTUSER  EQU   ECT+32                                                   03188000
ECTDDNUM EQU   ECT+29                                                   03189000
ECTATTN  EQU   ECTSWS                                                   03190000
ECTBKGRD EQU   ECTSWS                                                   03191000
ECTNNOT  EQU   ECTSWS                                                   03192000
ECTNMAL  EQU   ECTSWS                                                   03193000
ECTLOGF  EQU   ECTSWS                                                   03194000
ECTATRM  EQU   ECTSWS                                                   03195000
@NM00057 EQU   ECTSWS                                                   03196000
ECTNOPD  EQU   ECTSWS                                                   03197000
ECTSCMD  EQU   ECT+20                                                   03198000
ECTSMSG  EQU   ECT+9                                                    03199000
ECTMSGF  EQU   ECT+8                                                    03200000
ECTRTCD  EQU   ECT+1                                                    03201000
ECTRCDF  EQU   ECT                                                      03202000
DA18JBNM EQU   DAPB18+32                                                03203000
@NM00056 EQU   DA18CTL                                                  03204000
@NM00055 EQU   DA18CTL                                                  03205000
@NM00054 EQU   DA18CTL                                                  03206000
@NM00053 EQU   DA18CTL                                                  03207000
DA18PERM EQU   DA18CTL                                                  03208000
DA18UID  EQU   DA18CTL                                                  03209000
@NM00052 EQU   DA18CTL                                                  03210000
@NM00051 EQU   DA18CTL                                                  03211000
DA18UCAT EQU   DA18DPS2                                                 03212000
DA18CAT  EQU   DA18DPS2                                                 03213000
DA18DEL  EQU   DA18DPS2                                                 03214000
@NM00050 EQU   DA18DPS2                                                 03215000
@NM00049 EQU   DA18DPS2                                                 03216000
@NM00048 EQU   DA18DPS2                                                 03217000
@NM00047 EQU   DA18DPS2                                                 03218000
DA18SCLS EQU   DAPB18+28                                                03219000
DA18MNM  EQU   DAPB18+20                                                03220000
DA18PDSN EQU   DAPB18+8                                                 03221000
DA18CTRC EQU   DAPB18+6                                                 03222000
DA18DARC EQU   DAPB18+4                                                 03223000
@NM00046 EQU   DA18FLG                                                  03224000
@NM00045 EQU   DA18FLG                                                  03225000
@NM00044 EQU   DA18FLG                                                  03226000
@NM00043 EQU   DA18FLG                                                  03227000
@NM00042 EQU   DA18FLG                                                  03228000
@NM00041 EQU   DA18FLG                                                  03229000
@NM00040 EQU   DA18FLG                                                  03230000
DA18FPE  EQU   DA18FLG                                                  03231000
DA08ALN  EQU   DAPB08+76                                                03232000
@NM00039 EQU   DAPB08+72                                                03233000
@NM00038 EQU   DA08CTL                                                  03234000
DA08ATRL EQU   DA08CTL                                                  03235000
DA08DMMY EQU   DA08CTL                                                  03236000
DA08PERM EQU   DA08CTL                                                  03237000
DA08RLSE EQU   DA08CTL                                                  03238000
DA08ABKL EQU   DA08CTL                                                  03239000
DA08TRKS EQU   DA08CTL                                                  03240000
DA08UNCT EQU   DA08DPS3                                                 03241000
DA08CATL EQU   DA08DPS3                                                 03242000
DA08DELE EQU   DA08DPS3                                                 03243000
DA08KEP  EQU   DA08DPS3                                                 03244000
@NM00037 EQU   DA08DPS3                                                 03245000
@NM00036 EQU   DA08DPS3                                                 03246000
@NM00035 EQU   DA08DPS3                                                 03247000
@NM00034 EQU   DA08DPS3                                                 03248000
DA08UCAT EQU   DA08DPS2                                                 03249000
DA08CAT  EQU   DA08DPS2                                                 03250000
DA08DEL  EQU   DA08DPS2                                                 03251000
DA08KEEP EQU   DA08DPS2                                                 03252000
@NM00033 EQU   DA08DPS2                                                 03253000
@NM00032 EQU   DA08DPS2                                                 03254000
@NM00031 EQU   DA08DPS2                                                 03255000
@NM00030 EQU   DA08DPS2                                                 03256000
DA08OLD  EQU   DA08DSP1                                                 03257000
DA08MOD  EQU   DA08DSP1                                                 03258000
DA08NEW  EQU   DA08DSP1                                                 03259000
@NM00029 EQU   DA08DSP1                                                 03260000
@NM00028 EQU   DA08DSP1                                                 03261000
@NM00027 EQU   DA08DSP1                                                 03262000
@NM00026 EQU   DA08DSP1                                                 03263000
DA08MNM  EQU   DAPB08+52                                                03264000
DA08DQTY EQU   DAPB08+48                                                03265000
DA08SQTY EQU   DAPB08+44                                                03266000
DA08PQTY EQU   DAPB08+40                                                03267000
DA08BLK  EQU   DAPB08+36                                                03268000
DA08SER  EQU   DAPB08+28                                                03269000
DA08UNIT EQU   DAPB08+20                                                03270000
DA08CTRC EQU   DAPB08+6                                                 03271000
DA08DARC EQU   DAPB08+4                                                 03272000
@NM00025 EQU   DA08FLG                                                  03273000
@NM00024 EQU   DA08FLG                                                  03274000
@NM00023 EQU   DA08FLG                                                  03275000
@NM00022 EQU   DA08FLG                                                  03276000
@NM00021 EQU   DA08FLG                                                  03277000
@NM00020 EQU   DA08FLG                                                  03278000
@NM00019 EQU   DA08FLG                                                  03279000
DA08FPE  EQU   DA08FLG                                                  03280000
@NM00018 EQU   DAPB00+17                                                03281000
@NM00017 EQU   DA00CTL                                                  03282000
@NM00016 EQU   DA00CTL                                                  03283000
@NM00015 EQU   DA00CTL                                                  03284000
@NM00014 EQU   DA00CTL                                                  03285000
@NM00013 EQU   DA00CTL                                                  03286000
DA00UID  EQU   DA00CTL                                                  03287000
@NM00012 EQU   DA00CTL                                                  03288000
@NM00011 EQU   DA00CTL                                                  03289000
DA00PDSN EQU   DAPB00+4                                                 03290000
DA00TERM EQU   DA00FLG                                                  03291000
DA00DSE  EQU   DA00FLG                                                  03292000
DA00DYNM EQU   DA00FLG                                                  03293000
DA00PERM EQU   DA00FLG                                                  03294000
@NM00010 EQU   DA00FLG                                                  03295000
@NM00009 EQU   DA00FLG                                                  03296000
@NM00008 EQU   DA00FLG                                                  03297000
@NM00007 EQU   DA00FLG                                                  03298000
DA00CD   EQU   DAPB00                                                   03299000
@NM00006 EQU   GFPARMS+40                                               03300000
@NM00005 EQU   GFPARMS+36                                               03301000
GFPGMNP  EQU   GFPARMS+32                                               03302000
GFDSNP   EQU   GFPARMS+28                                               03303000
GFPGMNL  EQU   GFPARMS+26                                               03304000
GFDSNLEN EQU   GFPARMS+24                                               03305000
GFECBP   EQU   GFPARMS+20                                               03306000
@NM00004 EQU   GFPARMS+15                                               03307000
@NM00003 EQU   GFBITS                                                   03308000
GFWTPSW  EQU   GFBITS                                                   03309000
GFSUBSYS EQU   GFBITS                                                   03310000
GFKEYN08 EQU   GFBITS                                                   03311000
GFCBPTR  EQU   GFPARMS                                                  03312000
IDNUM    EQU   DFID+1                                                   03313000
@NM00002 EQU   @NM00001                                                 03314000
DFWTP    EQU   @NM00001                                                 03315000
DFCPPLP  EQU   DFPARMS+16                                               03316000
DAPLECB  EQU   DAPL+8                                                   03317000
DAPLECT  EQU   DAPL+4                                                   03318000
DAPLUPT  EQU   DAPL                                                     03319000
.@UNREFD ANOP                          END UNREFERENCED COMPONENTS      03320000
@RC00280 EQU   @RC00264                                                 03321000
@RC00266 EQU   @RC00264                                                 03322000
@RC00296 EQU   @RC00295                                                 03323000
@RC00340 EQU   @RC00337                                                 03324000
@RC00356 EQU   @RC00354                                                 03325000
@RC00452 EQU   @RC00450                                                 03326000
@RC00473 EQU   @RC00472                                                 03327000
@ENDDATA EQU   *                                                        03328000
         END   IKJCT430                                         DSKC190 03329000
