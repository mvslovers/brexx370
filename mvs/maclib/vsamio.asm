         MACRO
&LABEL   VSAMIO &DDNM,&FUNC=READ,&TYPE=,&AREA=,&IOREG=,&KEY=,&LENGTH=, X
               &INTENT=,&EOFNRF=,&ERROR=,&ECBLIST=,&DBUF=,&IBUF=,      X
               &KEYLEN=,&KEYVLEN=,&FTYPE=KSDS,&GETMAIN=NO,&RCODE=,     X
               &MODULE=VSIOMOD
.*********************************************************************
.*  YES, YES, LADIES AND GENTLEMEN, THIS IS THE MACRO YOU'VE ALL     *
.* BEEN WAITING FOR! IT'S A FLOOR WAX, A DESSERT TOPPING, IT CAN     *
.* EVEN BE USED TO PAPER TRAIN YOUR DOG! DONT WAIT, HURRY NOW!       *
.*   LIMITED TIME OFFER WHILE SUPPLIES LAST!                         *
.*********************************************************************
.*
          GBLB &VSIOEX         BINARY SWITCH INDICATES FIRST
          GBLB &TEST           BINARY SWITCH INDICATES FIRST
          GBLA &RTN            ROUTINE LABEL COUNTER
.*                             MACRO EXECUTION
.*
          LCLC &VSFUNC              FUNCTION BYTE
          LCLC &VSFFLG              FUNCTION FLAG
          LCLA &VSFIORP             IOREG SUBSTRING POINTER
          LCLA &TSTA                IOREG SUBSTRING POINTER
.*
          AIF   ('&FUNC' EQ 'PLIST').PGEN
          AIF   ('&FUNC' EQ 'CLOSEALL').VSFCK01
.*********************************************************************
.*            VALIDATE DDNAME PARAMETER                              *
.*********************************************************************
          AIF   (T'&DDNM EQ 'O').VSNODD
          AIF   ('&DDNM'(1,1) NE '''').VSCKDDL
          AIF   ('&DDNM'(1,1) EQ '''' AND '&DDNM'(K'&DDNM,1) EQ ''''   X
                AND K'&DDNM GT 10).VSINVDD
          AGO   .DDNMOK
.VSCKDDL  ANOP ,
          AIF   (K'&DDNM EQ 0 OR K'&DDNM GT 8).VSINVDD
.DDNMOK   ANOP ,
.*
.*********************************************************************
.*            SETUP FUNCTION AND FLAG LABEL                          *
.*********************************************************************
&VSFUNC   SETC  'VS$#OPEN'
&VSFFLG   SETC  '0'
          AIF   ('&FUNC' NE 'OPEN').VSFCK01
&VSFFLG   SETC  'VS$#OUPD'
          AIF   ('&INTENT' EQ 'UPDATE').VSGOTOP
&VSFFLG   SETC  'VS$#OLOD'
          AIF   ('&INTENT' EQ 'LOAD').VSGOTOP
&VSFFLG   SETC  'VS$#ORSU'
          AIF   ('&INTENT' EQ 'RESUPD').VSGOTOP
&VSFFLG   SETC  'VS$#ORDO'
          AIF   ('&INTENT' EQ 'READ').VSGOTOP
          AIF   (K'&INTENT GT 0).VSITERR
          MNOTE 1,'ACCESS INTENT OMMITTED. READ ONLY ASSUMED.'
          AGO   .VSGOTOP
.VSFCK01  ANOP  ,
&VSFUNC   SETC  'VS$#CLOS'
          AIF   ('&FUNC'(1,5) NE 'CLOSE').VSFCK02
&VSFFLG   SETC  'VS$#CLSA'
          AIF   ('&FUNC' EQ 'CLOSEALL').VSGOTOP
&VSFFLG   SETC  '0'
          AGO   .VSGOTOP
.VSFCK02  ANOP  ,
&VSFUNC   SETC  'VS$#READ'
          AIF   ('&FUNC' EQ 'READ').VSGOTOP
          AIF   (T'&FUNC EQ 'O').VSGOTOP
          AIF   ('&FUNC' NE 'READU').VSFCK03
&VSFFLG   SETC  'VS$#RUPD'
          AGO   .VSGOTOP
.VSFCK03  ANOP  ,
&VSFFLG   SETC  '0'
&VSFUNC   SETC  'VS$#WRIT'
          AIF   ('&FUNC' EQ 'WRITE').VSGOTOP
&VSFUNC   SETC  'VS$#DELT'
          AIF   ('&FUNC' EQ 'DELETE').VSGOTOP
&VSFUNC   SETC  'VS$#PONT'
          AIF   ('&FUNC' EQ 'POINT' AND T'&KEY EQ 'O').VSNOKEY
          AIF   ('&FUNC' EQ 'POINT').VSGOTOP
&VSFUNC   SETC  'VS$#ENRQ'
          AIF   ('&FUNC' NE 'ENDREQ').VSFERR
.*********************************************************************
.*        AT THIS POINT THE OPERATION AND FLAG HAVE BEEN SET.        *
.*         NOW VERIFY PARAMETERS ARE CORRECT                         *
.*********************************************************************
.VSGOTOP  ANOP  ,
          AIF   (T'&AREA EQ 'O' AND T'&IOREG EQ 'O' AND ('&FUNC' EQ    X
                'READ' OR '&FUNC' EQ 'READU'                           X
                OR '&FUNC' EQ 'WRITE')).VSARERR
.*
.*     BEGIN GENERATING CODE
          AIF   (T'&LABEL EQ 'O').VSGEN01
&LABEL    DS    0H
*
.VSGEN01  ANOP  ,
          AIF   (T'&ECBLIST EQ 'O').VSKPST
          L     R1,&ECBLIST
          ST    R1,VS$#@LST
          USING VS$#@IOD,R1                                     RMW
          AGO   .VSGEN02
.VSKPST   ANOP  ,
          USING VS$#@IOD,R1
          ICM   R1,15,VS$#@LST      CHECK PARAMETER LIST ADDRESS
          AIF   ('&GETMAIN' EQ 'NO').NOGETM
          BNZ   VS$#@&RTN           BYPASS GETMAIN IF PRESENT
* -- BEG  GETMAIN R,LV=VS$#@LEN,SP=0
          GETMAIN R,LV=VS$#@LEN,SP=0
* -- END  GETMAIN R,LV=VS$#@LEN,SP=0
          ST    R1,VS$#@LST         SAVE PARM LIST ADDR
          XC    0(VS$#@LEN,R1),0(R1)
*
.VSGEN02  ANOP  ,
VS$#@&RTN  DS   0H
&RTN      SETA  &RTN+1
*
.NOGETM   ANOP
          AIF   ('&KEYLEN' NE 'PRESET').VSKCL1
          IC    R0,VS$#@KYL SAVE KEY LENGTH
.VSKCL1   ANOP  ,
          XC    VS$#@CLA,VS$#@CLA
          AGO  .DROPOLD
*         XC    VS$#@OPT,VS$#@OPT CLEAR OPTION BYTES
*         XC    VS$#@FIL,VS$#@FIL CLEAR DDNAME
*         XC    VS$#@ARE,VS$#@ARE CLEAR RECORD ADDRESS
*         XC    VS$#@KEY,VS$#@KEY CLEAR KEY
*         XC    VS$#@RLN,VS$#@RLN CLEAR RECORD LENGTH
*         XC    VS$#@RCD,VS$#@RCD CLEAR RETURN CODE
.DROPOLD  ANOP
          AIF   ('&KEYLEN' NE 'PRESET').VSKCLR
          STC   R0,VS$#@KYL SAVE KEY LENGTH
*         XC    VS$#@KYL,VS$#@KYL CLEAR KEY LENGTH
.VSKCLR   ANOP  ,
*
          AIF   ('&TYPE' EQ '').NOTYPE
          MVC   VS$#@FNC,&TYPE           OPERATION IS SET IN A VARIABLE
          AGO   .WTYPE
.NOTYPE   ANOP
          MVI   VS$#@FNC,&VSFUNC+&VSFFLG SET OPERATION
.WTYPE    ANOP
          AIF   ('&FUNC' EQ 'CLOSEALL').VSKPDD                   RMW
          AIF   (T'&DDNM EQ 'O').VSKPDD
          AIF   ('&DDNM'(1,1) EQ '''').VSLIT
          MVC   VS$#@FIL,&DDNM           SET DDNAME
         AGO   .VSKPDD
.VSLIT    ANOP  ,
          AIF   ('&DDNM'(K'&DDNM,1) NE '''').VSQTERR
          MVC   VS$#@FIL,=CL8&DDNM
.*
.VSKPDD   ANOP  ,
         AIF   ('&FUNC' NE 'OPEN').VSNOBUF
         AIF  ('&FTYPE' NE 'ESDS').VSCKKSD
         MVC   VS$#@FTY,=CL4'&FTYPE'
         AGO  .VSCKBUF
.VSCKKSD  ANOP  ,
         AIF  ('&FTYPE' NE 'KSDS').VSCKRSD
         MVC   VS$#@FTY,=CL4'&FTYPE'
         AGO  .VSCKBUF
.VSCKRSD  ANOP  ,
         AIF  ('&FTYPE' NE 'RRDS').VSFTYER
         MVC   VS$#@FTY,=CL4'&FTYPE'
         AGO  .VSCKBUF
.VSFTYER ANOP ,
         MVC   VS$#@FTY,=CL4'KSDS'
         MNOTE 4,'FILE TYPE NOT ESDS, KSDS, OR RRDS. KSDS ASSUMED.'
.VSCKBUF  ANOP  ,
         AIF   (T'&DBUF EQ 'O').VSIBUF
         MVC   VS$#@DBF,=H'&DBUF'
.VSIBUF  ANOP  ,
         AIF   (T'&IBUF EQ 'O').VSNOBUF
         MVC   VS$#@IBF,=H'&IBUF'
.VSNOBUF  ANOP  ,
          AIF   (('&FUNC' EQ 'OPEN' AND '&INTENT' NE 'RESUPD') OR      X
                '&FUNC' EQ 'CLOSE').VSFCALL
.*
          AIF   ('&FUNC' EQ 'ENDREQ').VSNOLEN
          AIF   ('&FUNC' EQ 'POINT').VSNOAR
          AIF   ('&FUNC' EQ 'OPEN' AND '&INTENT' EQ 'RESUPD').VSNOAR
.*
          AIF   (T'&AREA EQ  'O').VSNOAR
          AIF   ('&AREA'(1,1) NE '(').VSLODA
          ST    &AREA(1),VS$#@ARE   STORE AREA ADDRESS
          AGO   .VSNOAR
.VSLODA   ANOP  ,
*
          LA    R15,&AREA           GET AREA ADDRESS
          ST    R15,VS$#@ARE        STORE IN PARM LIST
*
.VSNOAR   ANOP  ,
          AIF  ('&FUNC' EQ 'OPEN' AND '&INTENT' EQ 'RESUPD').VSCKOL
         AGO   .VSNOMNO
.VSCKOL  ANOP  ,
          AIF   (T'&LENGTH NE 'O').VSNOMNO
         MNOTE 1,'LENGTH OMMITTED FOR DUMMY RECORD ON RESET/UPDATE'
         MNOTE 1,'DUMMY OF MAXRECL WILL BE CREATED'
.VSNOMNO ANOP  ,
          AIF   (T'&LENGTH EQ 'O').VSNOLEN
          AIF   ('&LENGTH'(1,1) NE '(').VSMOVL
          STH   &LENGTH(1),VS$#@RLN STORE RECORD LENGTH
          AGO   .VSNOLEN
.VSMOVL   ANOP  ,
          MVC   VS$#@RLN,&LENGTH    MOVE LENGTH FIELD IN
*
.VSNOLEN  ANOP  ,
          AIF   (T'&KEY EQ 'O').VSFCALL
          LA    R15,&KEY            LOAD THE ADDRESS
          ST    R15,VS$#@KEY                  AND STORE
          AIF   ('&KEYVLEN' EQ '').NOVKEYL
          MVC   VS$#@KYL,&KEYVLEN
          AGO   .VSFCALL
.NOVKEYL  ANOP
          AIF   (T'&KEYLEN EQ 'O').VSNOKL
          AIF   ('&KEYLEN' EQ 'PRESET').VSFCALL
          MVI   VS$#@KYL,&KEYLEN
          AGO   .VSFCALL
.VSNOKL   ANOP  ,
          MVI   VS$#@KYL,L'&KEY     GET KEY LENGTH
.*
.VSFCALL  ANOP  ,
          AIF   (&VSIOEX).VSSKPL
          B     VS$#@LST+L'VS$#@LST   BRANCH AROUND LIST ADDR
VS$#@LST  DC    A(0)
.VSSKPL   ANOP  ,
          CLI   VS$#@IND,VS$#@ACT  TASK ACTIVE?
          BE    VS$#@&RTN          YES--> DO NOT ATTACH
*
         AIF   ('&FUNC' EQ 'OPEN').VSDOATT
         MVC   VS$#@RCD,=3X'FF'       SET ERROR
&TSTA    SETA  &RTN+2
         B     VS$#@&TSTA
         AGO   .VSNOATT
.VSDOATT ANOP   ,
         XC    VS$#@E01,VS$#@E01   CLEAR ECB'S
         XC    VS$#@E02,VS$#@E02
* -- BEG  ATTACH EP=VSIOMOD,PARAM=VS$#@LST,SZERO=YES,SHSPV=0
         AIF   ('&MODULE'(1,1) NE '(').REGNOT
         LR    R3,&MODULE(1)
         AGO   .ATTCHNW
.REGNOT  ANOP
         LA   R3,&MODULE
.ATTCHNW ANOP
          ATTACH EPLOC=(R3),PARAM=VS$#@LST,SZERO=YES,SHSPV=0
* -- END  ATTACH EP=VSIOMOD,PARAM=VS$#@LST,SZERO=YES,SHSPV=0
         LR    R15,R1              PUT TCB ADDR IN R15
         L     R1,VS$#@LST
         ST    R15,VS$#@TCB           SAVE THE TCB ADDRESS
* -- BEG CHAP  1,VS$#@TCB          BUMP THE PRIORITY UP
         CHAP  1,VS$#@TCB          BUMP THE PRIORITY UP
* -- END CHAP  1,VS$#@TCB          BUMP THE PRIORITY UP
         L     R1,VS$#@LST
*
&TSTA    SETA  &RTN+1
         B     VS$#@&TSTA            DONT POST, JUST WAIT
.VSNOATT ANOP   ,
VS$#@&RTN  DS   0H
&RTN      SETA  &RTN+1
*
         L     R1,VS$#@LST         RESTORE LIST
          LA    R1,VS$#@E01        GET ADDR OF ECB VSIOMOD WAITING ON
* -- BEG  POST  (1)                POST IT
          POST  (1)                POST IT
* -- END  POST  (1)                POST IT
VS$#@&RTN  DS   0H
&RTN      SETA  &RTN+1
          L     R1,VS$#@LST        GET PLIST ADDR
         TM    VS$#@E02,X'40'      POSTED?
         BO    VS$#@&RTN
          LA    R1,VS$#@E02        ADDR OF ECB WERE GOING TO WAIT ON
* -- BEG  WAIT  ECB=(1)            AND WAIT FOR COMPLETION
          WAIT  ECB=(1)            AND WAIT FOR COMPLETION
* -- END  WAIT  ECB=(1)            AND WAIT FOR COMPLETION
VS$#@&RTN  DS   0H
&RTN      SETA  &RTN+1
*
          L     R1,VS$#@LST        RESTORE LIST ADDR
          XC    VS$#@E02,VS$#@E02   CLEAR THE ECB
          AIF   ('&FUNC'(1,5) NE 'CLOSE').VSCKEF
          CLI   VS$#@IND,VS$#@ACT  TASK STILL ACTIVE?
&TSTA    SETA  &RTN+1
          BE    VS$#@&TSTA          YES--> DO NOT DETACH
          CLC   VS$#@TCB,=F'0'      ATTACHED?
          BNE   VS$#@&RTN           YES--> DETACH
         MVC   VS$#@RCD,=3X'FF'    NO--> MAJOR ERROR
         B     VS$#@&TSTA          GO TO ERROR PROCESS
*
VS$#@&RTN DS    0H
&RTN     SETA  &RTN+1
* -- BEG CHAP  -1,VS$#@TCB          BUMP THE PRIORITY DOWN
         CHAP  -1,VS$#@TCB          BUMP THE PRIORITY DOWN
* -- END CHAP  -1,VS$#@TCB          BUMP THE PRIORITY DOWN
          L     R1,VS$#@LST        RESTORE LIST ADDR
* -- BEG DETACH VS$#@TCB      KILL IT
         DETACH VS$#@TCB      KILL IT
* -- END DETACH VS$#@TCB      KILL IT
          L     R1,VS$#@LST        RESTORE LIST ADDR
          XC    VS$#@TCB,VS$#@TCB   CLEAR TCB ADDRESS
VS$#@&RTN DS    0H
&RTN     SETA  &RTN+1
.VSCKEF  ANOP  ,
          AIF   ('&RCODE' EQ '').NOSAVER
          MVC   &RCODE.(3),VS$#@RCD  SAVE RCODE
.NOSAVER  ANOP
          AIF   (T'&EOFNRF EQ 'O').VSANOP1
          AIF   ('&FUNC'(1,5) EQ 'CLOSE' OR '&FUNC' EQ 'OPEN').VSANOP1
          CLC   VS$#@RCD,=X'040004' EOF/NRF?
          BE    &EOFNRF             RETURNS HERE ON NO RECORD FOUND
.VSANOP1  ANOP  ,
          AIF   (T'&ERROR EQ 'O').VSANOP2
          AIF   ('&FUNC' NE 'OPEN').VSRC0
          CLI   VS$#@RCD,4         WAS R15 HIGHER THAN 4(CRITICAL ERR)
          BH    &ERROR
         AGO   .VSANOP2
.VSRC0   ANOP  ,
          L     R1,VS$#@LST        RESTORE LIST ADDR              RMW
          CLI   VS$#@RCD,0         WAS R15 NON-ZERO?
          BNE   &ERROR
.VSANOP2  ANOP  ,
          AIF   ('&FUNC'(1,4) NE 'READ').VSNORG
          AIF   (T'&IOREG EQ 'O').VSNORG
          L     &IOREG(1),VS$#@ARE     GET RECORD ADDRESS
.VSNORG   ANOP  ,
          LH    15,VS$#@RLN            GET RECORD LENGTH
.*
          AIF   (&VSIOEX).VS001   PARMS ALREADY GENNED
.PGEN     ANOP  ,
VS$#@IOD  DSECT ,
*
VS$#@E01  DS    F                  POSTED BY US, WAITED ON BY VSIOMOD
VS$#@E02  DS    F                  POSTED BY VSIOMOD, WAITED ON BY US
VS$#@IND  DS    XL1                ATTACH INDICATOR
VS$#@ACT   EQU   X'FF'             TASK IS ATTACHED AND ACTIVE
          DS    XL3                ALIGN IT
VS$#@OPT  DS    0H                  OPTION BYTES
*
VS$#@FNC  DS    XL1                 FUNCTION TYPE
VS$#OPEN   EQU   X'01'               OPEN FILE
VS$#OUPD    EQU   X'10'                  UPDATE INTENDED
VS$#OLOD    EQU   X'20'                  RESET FILE FOR LOAD
VS$#ORDO    EQU   X'40'                  READ ONLY
VS$#ORSU    EQU   X'80'                  RESET FILE W/DUMMY-OPEN UPDATE
.*
VS$#CLOS   EQU   X'02'               CLOSE FILE
VS$#CLSA    EQU   X'10'                  CLOSE ALL FILES
.*
VS$#READ   EQU   X'03'               READ FILE (NON-UPDATE)
VS$#RUPD    EQU   X'10'                  UPDATE INTENDED
.*
VS$#WRIT   EQU   X'04'               WRITE RECORD (INSERT/UPDATE)
VS$#WINS    EQU   X'10'                  ENFORCE INSERT
VS$#DELT   EQU   X'05'               DELETE RECORD
VS$#PONT   EQU   X'06'               POINT TO SPECIFIED KEY
VS$#ENRQ   EQU   X'07'               ENDREQ FILE
          DS    XL1                 EXPANSION BYTE
*
VS$#@KYD  DS    0H                  KEY DISPLACEMENT (JUST IN OPEN)
VS$#@RLN  DS    H                   RECORD LENGTH
*
VS$#@FIL  DS    CL8                 FILE DDNAME
VS$#@ARE  DS    AL4                 RECORD ADDRESS
         ORG   VS$#@ARE            ORG BACK
VS$#@DBF  DS    XL2                 NUMBER OF DATA BUFFERS
VS$#@IBF  DS    XL2                 NUMBER OF INDEX BUFFERS
         ORG   ,
VS$#@KEY  DS    AL4                 ADDRESS OF KEY FIELD
         ORG   VS$#@KEY            ORG BACK
VS$#@FTY  DS    CL4                 FILE TYPE, ONLY USED ON OPEN
         ORG ,
VS$#@KYL  DS    XL1                 LENGTH OF KEY
VS$#@RCD  DS    XL3                 ERROR RETURN CODE - FORMAT:
VS$#@CLR  EQU   *-VS$#@OPT          LENGTH OF AREA TO BE CLEARED
          ORG   VS$#@OPT            SET TO BEGIN OF AREA TO BE CLEARED
VS$#@CLA  DS    CL(VS$#@CLR)        RE-DEFINE CLEAR AREA
         ORG ,
*                                   X'RRCCCC' WHERE 'RR' IS THE
*                                   CONTENTS OF REGISTER 15 AND
*                                   'CCCC' IS THE VSAM RETURN CODE
VS$#@TCB  DS    AL4                 ADDRESS OF VSIOMOD TCB
VS$#@LEN  EQU   *-VS$#@IOD          LENGTH OF PARM LIST
*
&SYSECT   CSECT ,
*
.VS001    ANOP  ,
&VSIOEX   SETB  1
          AIF   ('&FUNC' EQ 'PLIST').VSEXIT
          DROP  R1
.VSEXIT   ANOP  ,
          MEXIT
.VSQTERR  ANOP  ,
          MNOTE 8,'INVALID QUOTES ON DDNAME'
         AGO   .VSERRMS
.VSNODD   ANOP  ,
          MNOTE 8,'DDNAME OMMITTED'
         AGO   .VSERRMS
.VSINVDD  ANOP  ,
          MNOTE 8,'DDNAME INVALID'
         AGO   .VSERRMS
.VSITERR  ANOP  ,
          MNOTE 8,'OPEN INTENT SUPPLIED IS INVALID'
         AGO   .VSERRMS
.VSARERR  ANOP  ,
          MNOTE 8,'AREA OR IOREG PARAMETER REQUIRED'
         AGO   .VSERRMS
.VSIOERRT ANOP  ,
.VSFERR   ANOP  ,
.VSNOKEY  ANOP  ,
          MNOTE 8,'KEY OMMITTED FOR POINT REQUEST'
         AGO   .VSERRMS
.VSERRMS  ANOP  ,
         MNOTE 8,'MACRO GENERATION TERMINATED DUE TO ERRORS.'
          MEND
 
