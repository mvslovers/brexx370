***************************************************************
*                                                             *
* MODULE NAME = HAL                                           *
*                                                             *
* DESCRIPTIVE NAME = STRUCTURED ASSEMBLER MACROS              *
*                                                             *
* COPYRIGHT = NONE                                            *
*                                                             *
* VERSION = OS/VS/VM ASSEMBLERS                               *
*                                                             *
* STATUS = RELEASE 2 LEVEL 0                                  *
*                                                             *
* NOTES =                                                     *
*                                                             *
*     THESE MACROS ARE INTENDED TO BE COPIED INTO THE         *
*     BEGINNING OF ASSEMBLIES WHERE THEY ARE TO BE            *
*     USED. THIS AVOIDS NAMING CONFLICTS WITH OTHER           *
*     MACROS IN THE SYSTEM LIBRARIES.                         *
*                                                             *
***************************************************************
         SPACE 5
*        ******************************************************
*        *     BEND                                           *
*        ******************************************************
         MACRO
         BEND  &BLKNM,&EPILOG=NO
         GBLA  &YCCLVL,&YCCBLK#(30),&YCCTYPE(30),&YCCEN#(30)
         GBLC  &YCCBLKN(30)
         GBLB  &YCCEPLG(30)
         LCLC  &YCCL
         AIF   (&YCCLVL GT 0).OKLVL
         MNOTE 8,'BEND OR EPILOG STATEMENT OUTSIDE OF BLOCK'
         SPACE 1
         MEXIT
.OKLVL   AIF   ('&BLKNM' NE '&YCCBLKN(&YCCLVL)').ERR1
         AIF   (&YCCTYPE(&YCCLVL) EQ 0).DCRMT
         AIF   (&YCCTYPE(&YCCLVL) NE 1 OR NOT &YCCEPLG(&YCCLVL) OR '&EP*
               ILOG' NE 'NO').OK2
         MNOTE 8,'MISSING EPILOG FOR THIS BLOCK'
.OK2     ANOP
         AIF   (&YCCTYPE(&YCCLVL) NE 2 AND &YCCTYPE(&YCCLVL) NE 3).NLP
         B     TS&YCCLVL.@&YCCBLK#(&YCCLVL)
&YCCL    SETC  'EN&YCCLVL.@&YCCEN#(&YCCLVL)'
&YCCL    DS    0H
&YCCL    SETC  'EL&YCCLVL.@&YCCBLK#(&YCCLVL)'
&YCCL    DS    0H
         AGO   .DCRMT
.NLP     AIF   (&YCCTYPE(&YCCLVL) EQ 1 OR &YCCTYPE(&YCCLVL) EQ 5).NELS
&YCCL    SETC  'EL&YCCLVL.@&YCCBLK#(&YCCLVL)'
&YCCL    DS    0H
.NELS    ANOP
&YCCL    SETC  'EN&YCCLVL.@&YCCEN#(&YCCLVL)'
&YCCL    DS    0H
.DCRMT   ANOP
         AIF   ('&EPILOG' EQ 'YES').EXIT
&YCCLVL  SETA  &YCCLVL-1
.EXIT    MEXIT
.ERR1    MNOTE 8,'BLOCK NAME OMITTED OR DOES NOT MATCH CURRENT BLOCK'
         SPACE 1
         MEND ,
         SPACE 5
*        ******************************************************
*        *     BLOCK                                          *
*        ******************************************************
         MACRO
&LAB     BLOCK &DUMMY,&EPILOG=NO
         GBLA  &YCCLVL,&YCCBLK#(30),&YCCTYPE(30),&YCCEN#(30)
         GBLC  &YCCBLKN(30)
         GBLB  &YCCEPLG(30)
         LCLC  &YCCL
         YCCPUSH NAME=&LAB,TYPE=BLOCK
         AIF   ('&EPILOG' NE 'YES').EXITOK
&YCCEPLG(&YCCLVL) SETB (1)
.EXITOK  ANOP
&LAB     DS    0H
&YCCL    SETC  'ST&YCCLVL.@&YCCBLK#(&YCCLVL)'
&YCCL    DS    0H
         SPACE 1
         MEND ,
         SPACE 5
*        ******************************************************
*        *     DO                                             *
*        ******************************************************
         MACRO
&LAB     DO    &DUMMY
         GBLA  &YCCLVL,&YCCBLK#(30),&YCCTYPE(30),&YCCEN#(30)
         GBLC  &YCCBLKN(30)
         GBLB  &YCCEPLG(30)
         LCLC  &YCCL
         LCLA  &I
&I       SETA  2
         AIF   ('&DUMMY' NE 'WHILE' AND '&DUMMY' NE 'INF').TIL
         YCCPUSH NAME=&LAB,TYPE=DOWILE
         AIF   ('&LAB' EQ '').NOLAB
&LAB     DS    0H
.NOLAB   ANOP
         AGO   .TESTS
.TIL     AIF   ('&DUMMY' NE 'UNTIL').ERR1
         YCCPUSH NAME=&LAB,TYPE=DOTIL
         AIF   ('&LAB' EQ '').NOLAB2
&LAB     DS    0H
.NOLAB2  ANOP
         B     ST&YCCLVL.@&YCCBLK#(&YCCLVL)
         AGO   .TESTS
.ERR1    MNOTE 8,'DO MUST BE (UNTIL|WHILE|INF)'
.TESTS   ANOP
&YCCL    SETC  'TS&YCCLVL.@&YCCBLK#(&YCCLVL)'
&YCCL    DS    0H
.LP      AIF   ('&SYSLIST(&I)' EQ '').DONE
         YCCTEST &SYSLIST(&I),&SYSLIST(&I+1)
&I       SETA  &I+2
         AGO   .LP
.DONE    ANOP
&YCCL    SETC  'ST&YCCLVL.@&YCCBLK#(&YCCLVL)'
&YCCL    DS    0H
         SPACE 1
         MEND ,
         SPACE 5
*        ******************************************************
*        *     EPILOG                                         *
*        ******************************************************
         MACRO
&LAB     EPILOG &BLKNM
         GBLA  &YCCLVL,&YCCBLK#(30),&YCCTYPE(30),&YCCEN#(30)
         GBLC  &YCCBLKN(30)
         GBLB  &YCCEPLG(30)
         LCLC  &YCCL
&LAB     DS    0H
         AIF   (&YCCTYPE(&YCCLVL) NE 1).ERR1
         BEND  &BLKNM,EPILOG=YES
&YCCTYPE(&YCCLVL) SETA 0
&YCCEPLG(&YCCLVL) SETB (0)
         MEXIT
.ERR1    MNOTE 8,'EPILOG APPEARS OUT OF CONTEXT'
         MEND ,
         SPACE 5
*        ******************************************************
*        *     EXIT                                           *
*        ******************************************************
         MACRO
&LAB     EXIT  &LABNAM,&IF
         GBLA  &YCCLVL,&YCCBLK#(30),&YCCTYPE(30),&YCCEN#(30)
         GBLC  &YCCBLKN(30),&YCCGO
         GBLB  &YCCEPLG(30)
         LCLC  &YCCL,&O
         LCLA  &I
&O       SETC  'B'
         AIF   ('&LABNAM' EQ '').NOTFAR
         AIF   ('&LABNAM'(1,1) NE '(').NOTFAR
&O       SETC  'B'
.NOTFAR  ANOP
         AIF   ('&LABNAM' NE '' AND '&LABNAM' NE '()').IF
         AIF   (&YCCTYPE(&YCCLVL) EQ 1).BLKOK
         MNOTE 8,'EXIT CODE DEFINION SHOULD BE IN A "BLOCK"'
.BLKOK   ANOP
         &O    EN&YCCLVL.@&YCCEN#(&YCCLVL)
&LAB     DS    0H
         SPACE 1
         MEXIT
.IF      ANOP
&YCCGO   SETC  '&LABNAM(1)'
         AIF   ('&IF' EQ '').GOTO
         YCCPUSH NAME=&LAB,TYPE=IFLEAVE
&I       SETA  3
         AIF   ('&LAB' EQ '').NOLAB
&LAB     DS    0H
.NOLAB   ANOP
&YCCL    SETC  'ST&YCCLVL.@&YCCBLK#(&YCCLVL)'
.LP2     AIF   ('&SYSLIST(&I)' EQ '').DONE
         YCCTEST &SYSLIST(&I),&SYSLIST(&I+1),OP=&O
&I       SETA  &I+2
         AGO   .LP2
.DONE    ANOP
&YCCLVL  SETA  &YCCLVL-1
&YCCL    DS    0H
         SPACE 1
         MEXIT
.GOTO    ANOP
&LAB     &O    &YCCGO
         SPACE 1
.END     MEND ,
         SPACE 5
*        ******************************************************
*        *     IF                                             *
*        ******************************************************
         MACRO
&LAB     IF    &DUMMY
         GBLA  &YCCLVL,&YCCBLK#(30),&YCCTYPE(30),&YCCEN#(30)
         GBLC  &YCCBLKN(30)
         GBLB  &YCCEPLG(30)
         LCLC  &YCCL
         LCLA  &I
         YCCPUSH NAME=&LAB,TYPE=IF
&I       SETA  1
         AIF   ('&LAB' EQ '').NOLAB
&LAB     DS    0H
.NOLAB   ANOP
&YCCL    SETC  'ST&YCCLVL.@&YCCBLK#(&YCCLVL)'
.LP      AIF   ('&SYSLIST(&I)' EQ '').DONE
         YCCTEST &SYSLIST(&I),&SYSLIST(&I+1)
&I       SETA  &I+2
         AGO   .LP
.DONE    ANOP
&YCCL    DS    0H
         SPACE 1
         MEND ,
         SPACE 5
*        ******************************************************
*        *     LEAVE                                          *
*        ******************************************************
         MACRO
&LAB     LEAVE &BLKNM,&IF
         GBLA  &YCCLVL,&YCCBLK#(30),&YCCTYPE(30),&YCCEN#(30)
         GBLC  &YCCBLKN(30),&YCCGO
         GBLB  &YCCEPLG(30)
         LCLC  &YCCL,&O
         LCLA  &LVL,&I
&O       SETC  'B'
         AIF   ('&BLKNM' EQ '' OR '&BLKNM'(1,1) NE '(').NOTFAR
&O       SETC  'B'
.NOTFAR  ANOP
&LVL     SETA  &YCCLVL
         AIF   ('&YCCBLKN(&LVL)' EQ '&BLKNM(1)' AND &YCCTYPE(&LVL) EQ 0*
               ).ERR2
.LP      AIF   (&LVL EQ 0).ERR
         AIF   ('&BLKNM(1)' EQ '&YCCBLKN(&LVL)').OK
         AIF   (&YCCEPLG(&LVL)).ERREXIT
&LVL     SETA  &LVL-1
         AGO   .LP
.OK      ANOP
         AIF   ('&IF' EQ 'IF').IF
&LAB     &O    EN&LVL.@&YCCEN#(&LVL)
         SPACE 1
         MEXIT
.IF      ANOP
&YCCGO   SETC  'EN&LVL.@&YCCEN#(&LVL)'
         YCCPUSH NAME=&LAB,TYPE=IFLEAVE
&I       SETA  3
         AIF   ('&LAB' EQ '').NOLAB
&LAB     DS    0H
.NOLAB   ANOP
&YCCL    SETC  'ST&YCCLVL.@&YCCBLK#(&YCCLVL)'
.LP2     AIF   ('&SYSLIST(&I)' EQ '').DONE
         YCCTEST &SYSLIST(&I),&SYSLIST(&I+1),OP=&O
&I       SETA  &I+2
         AGO   .LP2
.DONE    ANOP
&YCCLVL  SETA  &YCCLVL-1
&YCCL    DS    0H
         SPACE 1
         MEXIT
.ERR     MNOTE 8,'ATTEMPT TO LEAVE UNRECOGNIZED BLOCK'
         SPACE 1
.ERREXIT MNOTE 8,'CANNOT EXIT BEYOND BLOCK &YCCBLKN(&LVL)'
         SPACE 1
         MEXIT
.ERR2    MNOTE 8,'YOU CANNOT LEAVE A BLOCK FROM ITS OWN EPILOG'
.END     MEND ,
         SPACE 5
*        ******************************************************
*        *     ELSE                                           *
*        ******************************************************
         MACRO
         ELSE  &DUMMY
         GBLA  &YCCLVL,&YCCBLK#(30),&YCCTYPE(30),&YCCEN#(30)
         GBLC  &YCCBLKN(30)
         GBLB  &YCCEPLG(30)
         LCLC  &YCCL
         B     EN&YCCLVL.@&YCCEN#(&YCCLVL)
         AIF   (&YCCTYPE(&YCCLVL) NE 4).ERR1
&YCCTYPE(&YCCLVL) SETA 5
&YCCL    SETC  'EL&YCCLVL.@&YCCBLK#(&YCCLVL)'
&YCCL    DS    0H
         SPACE 1
         MEXIT
.ERR1    MNOTE 8,'MISPLACED ELSE STATEMENT'
         SPACE 1
         MEND ,
         SPACE 5
*        ******************************************************
*        *     ELSEIF                                         *
*        ******************************************************
         MACRO
&LAB     ELSEIF &DUMMY
         GBLA  &YCCLVL,&YCCBLK#(30),&YCCTYPE(30),&YCCEN#(30)
         GBLC  &YCCBLKN(30)
         GBLB  &YCCEPLG(30)
         LCLC  &YCCL
         LCLA  &I
&I       SETA  1
         ELSE
&YCCTYPE(&YCCLVL) SETA  4         RESET TO "IF" TYPE
&YCCBLK#(&YCCLVL) SETA &YCCBLK#(&YCCLVL)+1
         AIF   ('&LAB' EQ '').NOLAB
&LAB     DS    0H
.NOLAB   ANOP
&YCCL    SETC  'ST&YCCLVL.@&YCCBLK#(&YCCLVL)'
.LP      AIF   ('&SYSLIST(&I)' EQ '').DONE
         YCCTEST &SYSLIST(&I),&SYSLIST(&I+1)
&I       SETA  &I+2
         AGO   .LP
.DONE    ANOP
&YCCL    DS    0H
         SPACE 1
         MEND ,
         SPACE 5
*        ******************************************************
*        *     INTERNAL MACROS YCCTEST AND YCCPUSH            *
*        ******************************************************
         MACRO
         YCCTEST &A,&B,&OP=B
         GBLA  &YCCLVL,&YCCBLK#(30),&YCCTYPE(30),&YCCEN#(30)
         GBLC  &YCCBLKN(30),&YCCGO
         GBLB  &YCCEPLG(30)
         LCLC  &YCCL
         LCLC  &N,&C,&GO,&O
         LCLB  &NEG,&LOGIC
         LCLA  &I
         AIF   ('&B' EQ 'AND' OR '&B' EQ 'OR' OR '&B' EQ '' OR '&B' EQ *
               'THEN').TCONJ
         MNOTE 8,'&B SHOULD BE (AND|OR|THEN)'
.TCONJ   ANOP
         AIF   (&YCCTYPE(&YCCLVL) NE 5).NOLEV
         AIF   ('&B' EQ 'AND').LVAND
&GO      SETC  '&YCCGO'
&NEG     SETB  (0)
         AGO   .OKCONJ
.LVAND   ANOP
&GO      SETC  'ST&YCCLVL.@&YCCBLK#(&YCCLVL)'
&NEG     SETB  (1)
         AGO   .OKCONJ
.NOLEV   AIF   (&YCCTYPE(&YCCLVL) EQ 2).TIL
         AIF   ('&B' NE 'OR').IFAND
&GO      SETC  'ST&YCCLVL.@&YCCBLK#(&YCCLVL)'
&NEG     SETB  (0)
         AGO   .OKCONJ
.IFAND   ANOP
&GO      SETC  'EL&YCCLVL.@&YCCBLK#(&YCCLVL)'
&NEG     SETB  (1)
         AGO   .OKCONJ
.TIL     AIF   ('&B' EQ 'AND').TILAND
&GO      SETC  'EL&YCCLVL.@&YCCBLK#(&YCCLVL)'
&NEG     SETB  (0)
         AGO   .OKCONJ
.TILAND  ANOP
&GO      SETC  'ST&YCCLVL.@&YCCBLK#(&YCCLVL)'
&NEG     SETB  (1)
.OKCONJ  ANOP
         AIF   (N'&A NE 1).COMPND1
&C       SETC  '&A'
         AGO   .CONDS1
.COMPND1 ANOP
&C       SETC  '&A(2)'
.CONDS1  ANOP
         AIF   ('&C' EQ 'N').CONDS2
         AIF   ('&C'(1,1) NE 'N').CONDS2
&NEG     SETB  (NOT &NEG)
&I       SETA  K'&C-1
&C       SETC  '&C'(2,&I)
.CONDS2  ANOP
         AIF   ('&C' NE 'EQ').NOTEQ
&C       SETC  'E'
.NOTEQ   ANOP
         AIF   ('&C' NE 'LT').NLT
&C       SETC  'L'
         AGO   .NOTNOT
.NLT     ANOP
         AIF   ('&C' NE 'GT').NGT
&C       SETC  'H'
         AGO   .NOTNOT
.NGT     ANOP
         AIF   ('&C' NE 'LE').NLE
&NEG     SETB  (NOT &NEG)
&C       SETC  'H'
.NLE     ANOP
         AIF   ('&C' NE 'GE').NGE
&NEG     SETB  (NOT &NEG)
&C       SETC  'L'
         AGO   .NOTNOT
.NGE     ANOP
         AIF   ('&C' NE 'ON').NON
&C       SETC  'O'
&LOGIC   SETB  (1)
         AGO   .NOTNOT
.NON     ANOP
         AIF   ('&C' NE 'OFF').NOFF
&C       SETC  'Z'
&LOGIC   SETB  (1)
         AGO   .NOTNOT
.NOFF    ANOP
         AIF   ('&C' NE 'MIX').NMIX
&C       SETC  'M'
&LOGIC   SETB  (1)
         AGO   .NOTNOT
.NMIX    ANOP
.NOTNOT  ANOP
&N       SETC  'N'
         AIF   (&NEG).NOTOK
&N       SETC  ''
.NOTOK   ANOP
&O       SETC  '&OP.&N.&C'
         AIF   (N'&A NE 1).COMPND2
         &O    &GO
         MEXIT
.COMPND2 ANOP
         AIF   ('&A(4)' EQ '').DFLT
         &A(4) &A(1),&A(3)
.NMZ     &O    &GO
         MEXIT
.DFLT    AIF   (&LOGIC).TM
         AIF   (T'&A(3) NE 'N').NCH
         AIF   ('&A(3)' NE '0').NLTR
         LTR   &A(1),&A(1)
         AGO   .TST
.NLTR    ANOP
         CH    &A(1),=H'&A(3)'
         AGO   .TST
.NCH     C     &A(1),&A(3)
.TST     ANOP
         &O    &GO
         MEXIT
.TM      TM    &A(1),&A(3)
         &O    &GO
         MEND ,
         SPACE 5
         MACRO
         YCCPUSH &NAME=,&TYPE=
         GBLA  &YCCLVL,&YCCBLK#(30),&YCCTYPE(30),&YCCEN#(30)
         GBLC  &YCCBLKN(30)
         GBLB  &YCCEPLG(30)
         LCLC  &YCCL
         AIF   (&YCCLVL EQ 30).OVFLOW
&YCCLVL  SETA  &YCCLVL+1
&YCCBLK#(&YCCLVL) SETA  &YCCBLK#(&YCCLVL)+1
&YCCEN#(&YCCLVL) SETA  &YCCBLK#(&YCCLVL)
&YCCBLKN(&YCCLVL) SETC  '&NAME'
&YCCEPLG(&YCCLVL) SETB (0)
         AIF   ('&TYPE' NE 'BLOCK').NBLK
&YCCTYPE(&YCCLVL) SETA 1
         MEXIT
.NBLK    AIF ('&TYPE' NE 'DOTIL').NDOTIL
&YCCTYPE(&YCCLVL) SETA 2
         MEXIT
.NDOTIL   AIF   ('&TYPE' NE 'DOWILE').NDOWILE
&YCCTYPE(&YCCLVL) SETA 3
         MEXIT
.NDOWILE AIF   ('&TYPE' NE 'IF').NOTIF
&YCCTYPE(&YCCLVL) SETA 4
         MEXIT
.NOTIF   AIF   ('&TYPE' NE 'IFLEAVE').NOTLEV
&YCCTYPE(&YCCLVL) SETA 5
         MEXIT
.NOTLEV  MNOTE 8,'UNRECOGNIZED BLOCK TYPE'
         MEXIT
.OVFLOW  MNOTE 16,'BLOCKS NESTED TOO DEEPLY FOR HAL MACROS'
         MEND
