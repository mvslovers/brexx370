         MACRO                                                          $ENTER
&NAME    $ENTER &BASE=R3,&CSECT=YES,&SAVE=,&RENT=,&SP=1,&SPM=YES,      +$ENTER
               &CHAIN=YES                                               $ENTER
         MNOTE *,'       $ENTER    VERSION 003 05/07/75  04/29/76  GPW' $ENTER
.********************************************************************** $ENTER
.*                                                                    * $ENTER
.* $ENTER                                                             * $ENTER
.*                                                                    * $ENTER
.* FUNCTION       PROVIDE ENTRY CODING TO ESTABLISH BASE REGISTERS,   * $ENTER
.*                ALLOCATE AND CHAIN SAVE AREAS, SET PROGRAM MASK,    * $ENTER
.*                AND OBTAIN WORK AREA FOR RE-ENTRANT PROGRAMS.       * $ENTER
.*                                                                    * $ENTER
.* DESCRIPTION    THE MACRO WILL GENERATE CODE TO ESTABLISH ONE OR    * $ENTER
.*                MORE BASE REGISTERS.  IT IS ASSUMED THAT STANDARD   * $ENTER
.*                IBM LINKAGE CONVENTIONS HAVE BEEN FOLLOWED AND THAT * $ENTER
.*                REGISTER 15 CONTAINS THE ADDRESS OF THE ENTRY       * $ENTER
.*                POINT.  USER SPECIFIED OR DEFAULT BASE REGISTERS    * $ENTER
.*                ARE INITIALIZED.  THE FIRST BASE REGISTER CONTAINS  * $ENTER
.*                THE ADDRESS OF THE ENTRY POINT, AND SUCCESSIVE BASE * $ENTER
.*                REGISTER ADDRESSES ARE INCREMENTED BY 4096.  THE    * $ENTER
.*                DEFAULT BASE REGISTER IS REGISTER 3.  IF REGISTER 2 * $ENTER
.*                IS SPECIFIED AS A BASE REGISTER, IT WILL BE         * $ENTER
.*                ALLOWED, BUT A WARNING MESSAGE WILL BE DISPLAYED.   * $ENTER
.*                REGISTERS 0, 1, 13, 14, AND 15 MAY NOT BE           * $ENTER
.*                SPECIFIED AS BASE REGISTERS.  ALL REGISTER          * $ENTER
.*                SPECIFICATIONS MUST BE MADE AS MNEMONICS (EG,       * $ENTER
.*                REGISTER 3 IS R3).                                  * $ENTER
.*                                                                    * $ENTER
.*                IDENTIFICATION CONSTANTS SPECIFYING THE DATE AND    * $ENTER
.*                TIME OF ASSEMBLY ARE CONSTRUCTED IN THE ENTRY       * $ENTER
.*                CODING.  THESE VALUES ARE DISPLAYED IN DUMPS AND    * $ENTER
.*                MAY BE USED TO VERIFY THAT THE PROPER VERSION OF    * $ENTER
.*                THE ROUTINE HAS BEEN USED.                          * $ENTER
.*                                                                    * $ENTER
.*                ALL BITS OF THE PROGRAM MASK ARE SET.  IBM          * $ENTER
.*                TRANSFERS CONTROL TO THE USER PROGRAM WITH ALL      * $ENTER
.*                PROGRAM MASK BITS OFF.  IF SPM=NO IS SPECIFIED,     * $ENTER
.*                THE PROGRAM MASK WILL BE UNALTERED.                 * $ENTER
.*                                                                    * $ENTER
.*                THE USER MAY SPECIFY THE NAME OF A WORK AREA OF 18  * $ENTER
.*                FULLWORDS TO BE USED AS A SAVE AREA.  IF A USER     * $ENTER
.*                AREA IS NOT SUPPLIED, AN 18 FULLWORD AREA IS        * $ENTER
.*                ALLOCATED AND INITIALIZED TO ZERO.  THE ADDRESS OF  * $ENTER
.*                THE SAVE AREA IS LOADED INTO REGISTER 13 AND IT IS  * $ENTER
.*                CHAINED TO THE SAVE AREA OF THE CALLING PROGRAM.    * $ENTER
.*                                                                    * $ENTER
.*                THE USER MAY SPECIFY THAT THE MACRO IS NOT TO       * $ENTER
.*                OBTAIN A SAVE AREA OR CHAIN SAVE AREAS BY           * $ENTER
.*                SPECIFYING CHAIN=NO.  THE USER IS THEN              * $ENTER
.*                RESPONSIBLE FOR SAVE AREA CHAINING.                 * $ENTER
.*                                                                    * $ENTER
.*                REGISTER EQUIVALENCES (R0  EQU  0, ETC.) ARE        * $ENTER
.*                GENERATED FOR THE FIRST USAGE OF THE MACRO.         * $ENTER
.*                                                                    * $ENTER
.*                A CSECT DEFINITION WILL BE GENERATED UNLESS         * $ENTER
.*                CSECT=NO IS SPECIFIED.  IF CSECT=NO IS SPECIFIED,   * $ENTER
.*                AN ENTRY STATEMENT WILL BE GENERATED.               * $ENTER
.*                                                                    * $ENTER
.*                RE-ENTRANT CODING IS SUPPORTED.  FOR RE-ENTRANT     * $ENTER
.*                CODING, THE USER MUST SPECIFY THE LENGTH OF A       * $ENTER
.*                WORK AREA.  THE WORK AREA IS OBTAINED FROM SUBPOOL  * $ENTER
.*                1 UNLESS OTHERWISE SPECIFIED.  THE FIRST 18 WORDS   * $ENTER
.*                OF THE WORK AREA ARE USED FOR THE SAVE AREA.        * $ENTER
.*                                                                    * $ENTER
.* SYNTAX         NAME     $ENTER    BASE=(REG1,...,REGN)             * $ENTER
.*                                   CSECT=NO                         * $ENTER
.*                                   SAVE=SYM                         * $ENTER
.*                                   RENT=LEN                         * $ENTER
.*                                   SP=NUMBER                        * $ENTER
.*                                   SPM=NO                           * $ENTER
.*                                   CHAIN=NO                         * $ENTER
.*                                                                    * $ENTER
.*                NAME   - A SYMBOLIC TAG ASSIGNED TO THE FIRST       * $ENTER
.*                         INSTRUCTION GENERATED.                     * $ENTER
.*                                                                    * $ENTER
.*                BASE   - THE REGISTERS TO BE USED AS BASE           * $ENTER
.*                         REGISTERS.  THE DEFAULT IS R3.  THE FIRST  * $ENTER
.*                         REGISTER SPECIFIED WILL CONTAIN THE        * $ENTER
.*                         ADDRESS OF THE ENTRY POINT, AND SUCCEEDING * $ENTER
.*                         BASE VALUES WILL BE INCREMENTED BY 4096.   * $ENTER
.*                         REGISTERS 0, 1, 13, 14, AND 15 MAY NOT BE  * $ENTER
.*                         SPECIFIED AS BASE REGISTERS.  REGISTERS    * $ENTER
.*                         MUST BE SPECIFIED IN MNEMONIC FORM (EG,    * $ENTER
.*                         R3 FOR REGISTER 3).                        * $ENTER
.*                                                                    * $ENTER
.*                CSECT  - CSECT=NO SPECIFIES THAT CODING FOR AN      * $ENTER
.*                         ENTRY POINT RATHER THAN A CSECT IS TO BE   * $ENTER
.*                         GENERATED.                                 * $ENTER
.*                                                                    * $ENTER
.*                SAVE   - SPECIFIES THE NAME OF A USER DEFINED 18    * $ENTER
.*                         WORD SAVE AREA TO BE USED INSTEAD OF       * $ENTER
.*                         GENERATING AN IN-LINE SAVE AREA.  IF RENT  * $ENTER
.*                         IS SPECIFIED, SAVE MUST SPECIFY THE NAME   * $ENTER
.*                         ASSIGNED TO THE FIRST 18 WORDS IN THE      * $ENTER
.*                         WORK AREA.                                 * $ENTER
.*                                                                    * $ENTER
.*                RENT   - SPECIFIES THAT RE-ENTRANT CODE IS TO BE    * $ENTER
.*                         GENERATED.  LEN IS THE LENGTH OF A WORK    * $ENTER
.*                         AREA TO BE OBTAINED BY A GETMAIN.          * $ENTER
.*                                                                    * $ENTER
.*                SP     - SPECIFIES THE SUBPOOL FROM WHICH THE WORK  * $ENTER
.*                         AREA FOR RE-ENTRANT CODING IS TO BE        * $ENTER
.*                         OBTAINED.  DEFAULT IS SUBPOOL 1.           * $ENTER
.*                                                                    * $ENTER
.*                SPM    - SPM=NO SPECIFIES THAT THE PROGRAM MASK IS  * $ENTER
.*                         NO TO BE ALTERED.                          * $ENTER
.*                                                                    * $ENTER
.*                CHAIN  - CHAIN=NO SPECIFIES THAT SAVE AREA ARE NOT  * $ENTER
.*                         TO BE CHAINED.  THIS OPTION IS INTENDED    * $ENTER
.*                         FOR USE ONLY BY HIGH ACTIVITY RE-ENTRANT   * $ENTER
.*                         MODULES WHERE THE OVERHEAD OF              * $ENTER
.*                         GETMAIN/FREEMAIN IS TO BE AVOIDED.         * $ENTER
.*                                                                    * $ENTER
.* ERRORS         THE NAME FIELD MUST BE SPECIFIED.  IF IT IS NOT, A  * $ENTER
.*                GENERATED NAME, $ENTNNNN WILL BE GENERATED AND A    * $ENTER
.*                SEVERITY 8 MNOTE IS GENERATED.  IF NO CODE WERE     * $ENTER
.*                GENERATED AND NO BASE REGISTER DEFINED, THE ERROR   * $ENTER
.*                LISTING WOULD BE LARGE.  TO REDUCE THE SIZE OF THE  * $ENTER
.*                ERROR LISTING AND ALLOW OTHER ERRORS TO BE FOUND,   * $ENTER
.*                THE MACRO WILL EXPAND.                              * $ENTER
.*                                                                    * $ENTER
.*                                                                    * $ENTER
.* EXAMPLE        EX1      $ENTER                                     * $ENTER
.*                                                                    * $ENTER
.*                EX2      $ENTER CSECT=NO                            * $ENTER
.*                                                                    * $ENTER
.*                EX3      $ENTER BASE=(R3,R4,R5)                     * $ENTER
.*                                                                    * $ENTER
.*                EX4      $ENTER BASE=R12,RENT=DSECTLEN,SAVE=SAVEAREA* $ENTER
.*                                                                    * $ENTER
.* GLOBAL SYMBOLS                                                     * $ENTER
.*                                                                    * $ENTER
.*                NAME     TYPE  USE                                  * $ENTER
.*                                                                    * $ENTER
.*                &ENCOUNT   A   SET TO 1 AFTER REGISTER EQUIVALENCES * $ENTER
.*                               GENERATED TO PREVENT EQUIVALENCES    * $ENTER
.*                               FROM BEING GENERATED FOR LATER USES. * $ENTER
.*                                                                    * $ENTER
.* MACROS USED                                                        * $ENTER
.*                                                                    * $ENTER
.*                GETMAIN                                             * $ENTER
.*                                                                    * $ENTER
.* UPDATE SUMMARY                                                     * $ENTER
.*                                                                    * $ENTER
.*      VERSION   DATE     CHANGE                                     * $ENTER
.*                                                                    * $ENTER
.*        003   04/29/76   CHAIN KEYWORD ADDED                        * $ENTER
.*                                                                    * $ENTER
.*                                                                    * $ENTER
.********************************************************************** $ENTER
.*                                                                      $ENTER
         GBLA  &ENCOUNT                                                 $ENTER
.*                                                                      $ENTER
         LCLA  &PARMNO,&REGNO                                           $ENTER
         LCLC  &REG,&CHAR,&LAST,&USING,&TEMP,&ID,&FIRST                 $ENTER
.*                                                                      $ENTER
&ID      SETC  '&NAME'                                                  $ENTER
         AIF   ('&NAME' NE '').CKCSECT                                  $ENTER
&ID      SETC  '$ENT&SYSNDX'                                            $ENTER
         MNOTE 8,'NAME OPERAND REQUIRED, NOT SPECIFIED. &ID WILL BE USE+$ENTER
               D.'                                                      $ENTER
.CKCSECT AIF   ('&CSECT' NE 'NO').CSECT                                 $ENTER
         AIF   ('&SYSECT' NE '').CKEQU                                  $ENTER
         MNOTE 8,'ENTRY POINT SPECIFIED, BUT NO CSECT DEFINED'          $ENTER
.CSECT   ANOP                                                           $ENTER
         SPACE                                                          $ENTER
&ID      CSECT                                                          $ENTER
.CKEQU   AIF   (&ENCOUNT EQ 1).SKIPEQU                                  $ENTER
         SPACE                                                          $ENTER
*********************************************************************** $ENTER
*                                                                     * $ENTER
*                      REGISTER EQUIVALENCES                          * $ENTER
*                                                                     * $ENTER
*********************************************************************** $ENTER
         SPACE                                                          $ENTER
R0       EQU   0                                                        $ENTER
R1       EQU   1                                                        $ENTER
R2       EQU   2                                                        $ENTER
R3       EQU   3                                                        $ENTER
R4       EQU   4                                                        $ENTER
R5       EQU   5                                                        $ENTER
R6       EQU   6                                                        $ENTER
R7       EQU   7                                                        $ENTER
R8       EQU   8                                                        $ENTER
R9       EQU   9                                                        $ENTER
R10      EQU   10                                                       $ENTER
R11      EQU   11                                                       $ENTER
R12      EQU   12                                                       $ENTER
R13      EQU   13                                                       $ENTER
R14      EQU   14                                                       $ENTER
R15      EQU   15                                                       $ENTER
.*                                                                      $ENTER
&ENCOUNT SETA  1                                                        $ENTER
         SPACE                                                          $ENTER
.SKIPEQU AIF   ('&CSECT' NE 'NO').CSECT2                                $ENTER
         AIF   ('&SYSECT' EQ '').CSECT2                                 $ENTER
.*-------ENTRY POINT                                                    $ENTER
         ENTRY &ID                                                      $ENTER
         USING &ID,R15                  DEFINE BASE REGISTER            $ENTER
&ID      B     14(R15)                  BRANCH AROUND ID                $ENTER
         DC    AL1(8)                   IDENTIFIER LENGTH               $ENTER
         DC    CL8'&ID'                 ENTRY POINT NAME                $ENTER
         DC    CL1' '                   SPACER                          $ENTER
         AGO   .STREGS                                                  $ENTER
.*-------CSECT                                                          $ENTER
.CSECT2  USING &ID,R15                  DEFINE BASE REGISTER            $ENTER
         B     28(0,R15)                BRANCH AROUND ID                $ENTER
         DC    AL1(23)                  IDENTIFIER LENGTH               $ENTER
         DC    CL8'&ID'                 CSECT NAME                      $ENTER
         DC    CL1' '                   SPACER                          $ENTER
         DC    CL8'&SYSDATE'            DATE OF ASSEMBLY                $ENTER
         DC    CL1' '                   SPACER                          $ENTER
         DC    CL5'&SYSTIME'            TIME OF ASSEMBLY                $ENTER
.STREGS  STM   R14,R12,12(R13)          SAVE REGISTERS                  $ENTER
&PARMNO  SETA  1                        INITIALIZE COUNTER              $ENTER
.CKBASE  ANOP                                                           $ENTER
&REG     SETC  '&BASE(&PARMNO)'(1,3)                                    $ENTER
         AIF   ('&REG'(1,1) NE 'R').SKIPBAS                             $ENTER
&TEMP    SETC  '&REG'(2,2)                                              $ENTER
&REGNO   SETA  &TEMP                                                    $ENTER
         AIF   (&REGNO LT 2).BADBASE                                    $ENTER
         AIF   (&REGNO GT 12).BADBASE                                   $ENTER
         AIF   (&REGNO NE 2).SETBASE                                    $ENTER
         MNOTE 0,'*** WARNING - R2 IS A BASE REGISTER. TRANSLATE AND TE+$ENTER
               ST INSTRUCTION WILL DESTROY CONTENTS.'                   $ENTER
.SETBASE ANOP                                                           $ENTER
         AIF   ('&FIRST' NE '').SETBAS2                                 $ENTER
         LR    &REG,R15                 LOAD BASE ADDRESS               $ENTER
&FIRST   SETC  '&REG'                   SAVE REGISTER                   $ENTER
         AGO   .SETLAST                                                 $ENTER
.SETBAS2 LA    &REG,4095(&LAST)         ADD 4095 TO LAST BASE           $ENTER
         LA    &REG,1(&REG)             ADD 1 MORE                      $ENTER
.SETLAST ANOP                                                           $ENTER
&LAST    SETC  '&REG'                                                   $ENTER
&USING   SETC  '&USING.,&REG'                                           $ENTER
         AGO   .NEXTBAS                                                 $ENTER
.SKIPBAS MNOTE 8,'*&REG* IS AN INVALID REGISTER FORM, IGNORED'          $ENTER
         AGO   .NEXTBAS                                                 $ENTER
.BADBASE MNOTE 8,'*&REG* IS AN INVALID BASE REGISTER, IGNORED'          $ENTER
.NEXTBAS ANOP                                                           $ENTER
&PARMNO  SETA  &PARMNO+1                                                $ENTER
         AIF   (&PARMNO LE N'&BASE).CKBASE                              $ENTER
         DROP  R15                      DISCONTINUE R15 BASE            $ENTER
         USING &ID.&USING               DEFINE BASE REGISTERS           $ENTER
.*-------SEE IF PROGRAM MASK IS TO BE SET                               $ENTER
         AIF   ('&SPM' EQ 'NO').NOSPM                                   $ENTER
         LA    R15,15                   LOAD PGM MASK SETTING           $ENTER
         SLA   R15,24                   SHIFT TO BITS 4-7               $ENTER
         SPM   R15                      SET PGM MASK AND COND           $ENTER
.NOSPM   AIF   ('&CHAIN' EQ 'NO').DONE                                  $ENTER
         AIF   ('&RENT' NE '').GETMAIN                                  $ENTER
         LR    R15,R13                  SAVE OLD SAVEAREA ADDR          $ENTER
         AIF   ('&SAVE' NE '').LOADSAV                                  $ENTER
         CNOP  0,4                      FULL WORD ALIGNMENT             $ENTER
         BAL   R13,*+76                 LOAD SAVEAREA ADDR              $ENTER
         DC    18F'0'                   SAVE AREA                       $ENTER
         AGO   .CHAIN                                                   $ENTER
.LOADSAV LA    R13,&SAVE                LOAD NEW SAVEAREA ADDR          $ENTER
         AGO   .CHAIN                                                   $ENTER
.GETMAIN MNOTE *,' GETMAIN R,LV=&RENT,SP=&SP'                           $ENTER
         GETMAIN R,LV=&RENT,SP=&SP      GET STORAGE                     $ENTER
* END OF GETMAIN - $ENTER                                               $ENTER
         LR    R15,R13                  SAVE OLD SAVEAREA ADDR          $ENTER
         LR    R13,R1                   LOAD STORAGE ADDRESS            $ENTER
         USING &SAVE,R13                DEFINE BASE REGISTER            $ENTER
         L     R1,24(R15)               RESTORE REG 1 CONTENTS          $ENTER
.CHAIN   ST    R15,4(R13)               CHAIN SAVE AREAS                $ENTER
         ST    R13,8(R15)                                               $ENTER
.DONE    ANOP                                                           $ENTER
         MEND                                                           $ENTER
