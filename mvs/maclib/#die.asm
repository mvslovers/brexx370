         MACRO
&NME     #DIE  &O,&A,&B,&C,&TYPE=MSG
.*
.*
.*
.* LAST CHANGE DATE - APRIL 21, 1981
.*                  - MACRO NAME CHANGED FROM $DIE TO #DIE.
.*
.* LAST CHANGE DATE - JAUNARY 27, 1981
.*                  - THE MACRO HAS BEEN REWRITTEN TO
.*                    GENERATE INLINE TRAPS WHENEVER
.*                    EXTENDED MNEMONICS FOR THE 'BC' AND
.*                    'BCR' INSTRUCTIONS ARE USED. THIS IS
.*                    ACCOMPLISHED BY USING THE INVERSE OF
.*                    OF THE GIVEN BRANCH CONDITION TO
.*                    SKIP AROUND THE INLINE TRAP.
.*                    IN THOSE CASES WHERE AN INLINE TRAP
.*                    IS NOT DESIRED (SUCH AS WITHIN A
.*                    BRANCH VECTOR TABLE), THE
.*                    NON-EXTENDED FORM OF THE 'BC'
.*                    INSTRUCTION CAN BE USED; E.G.:
.*                         #DIE C,8   INSTEAD OF   #DIE Z
.*                  - A UNIQUE NUMBER IS NOW APPENDED TO
.*                    GIVEN MESSAGES.
.*
.* LAST CHANGE DATE - FEBRUARY 12, 1980
.*                  - TYPE=CMD SUPPORT HAS BEEN ADDED. THIS PROVIDES A
.*                    MEANS OF COMMUNICATING COMMANDS TO THE "DEBUGGING
.*                    CONTROLLER" PROGRAM.
.*                  - IF NO BRANCH CONDITIONALS ARE GIVEN, THEN THE
.*                    "DEAD" CODE IS NOW GENERATED INLINE. BEFORE, AN
.*                    UNCONDITIONAL BRANCH TO A "DEAD" LITTERAL WAS
.*                    MADE.
.*
.* LAST CHANGE DATE - APRIL 24, 1978
.*                  - THE MACRO HAS BEEN REWRITTED TO GENERATE MESSAGE
.*                    STRINGS (INSTEAD OF JUST A SEQUENCE NUMBER) AT
.*                    THE BRANCH ADDRESS. SUCH MESSAGES COULD BE
.*                    REASONABLY DISPLAYED VIA AN ESTAE ROUTINE.
.*
.* LAST CHANGE DATE - DECEMBER 16, 1977
.*                  - 2ND AND 3RD OPERANDS HAVE BEEN ADDED TO THE
.*                    MACRO PROTOTYPE SO AS TO SUPPORT THE GENERATION
.*                    OF BRANCH INSTRUCTIONS OTHER THAN JUST
.*                    CONDITIONAL-BRANCH.
.*                  - WHEN NO OPERANDS ARE GIVEN, AN UNCONDITIONAL
.*                    BRANCH IS NOW GENERATED.
.*
.* LAST CHANGE DATE - FEBRUARY 2, 1977
.*                  - MAILING ADDRESS CHANGE
.*
.* LAST CHANGE DATE - SEPTEMBER 10, 1976
.*
.* THIS MACRO WAS WRITTEN BY DAVID B. COLE.  ANY QUESTIONS CONCERNING
.* IT MAY BE ADDRESSED TO:
.*       809 WHITNEY AVE.
.*       NEW HAVEN, CT. 06511
.*
.*
.*
         GBLA  &#DIECOD
         GBLC  &#EBCDIC(256)
         LCLA  &L,&M
         LCLC  &MSG,&LAB,&OP,&N,&#
         AIF   ('&TYPE' EQ 'MSG' OR '&TYPE' EQ 'CMD').TYPEOK
         MNOTE 8,'TYPE=&TYPE NOT RECOGNIZED. TYPE=CMD ASSUMED.'
.TYPEOK  ANOP
&N       SETC  '&NME'
&#DIECOD SETA  &#DIECOD+1
&#       SETC  '000&#DIECOD'
&#       SETC  '&#'(K'&#-3,4)
&M       SETA  N'&SYSLIST+1
.MLP     ANOP
&M       SETA  &M-1
         AIF   (&M EQ 0).NOMSG
         AIF   (K'&SYSLIST(&M) EQ 0).MLP
         AIF   ('&SYSLIST(&M)' EQ '''''').NOMSG
&L       SETA  K'&SYSLIST(&M)-2
         AIF   (&L LE 0).NOMSG2
         AIF   ('&SYSLIST(&M)'(1,1) NE '''').NOMSG2
&MSG     SETC  '&SYSLIST(&M)'(2,&L)
         AIF   ('&TYPE' NE 'MSG').MSGDONE
&MSG     SETC  '&#DIECOD &MSG'
&L       SETA  &L+1+K'&#DIECOD
         AGO   .COMN
.*
.NOMSG2  ANOP
&M       SETA  &M+1
.NOMSG   AIF   ('&TYPE' NE 'MSG').MSGDONE
&MSG     SETC  '&#DIECOD'
&L       SETA  K'&MSG
.*
.COMN    AIF   (&L/2*2 EQ &L).MSGDONE
&L       SETA  &L+1
&MSG     SETC  '&MSG '
.MSGDONE ANOP
.*
         AIF   (&M LE 1 OR '&O' EQ '').INLINE
         AIF   (&M EQ 2).INVERT
         AIF   (&M NE 3).GENLIT
         AIF   ('&O'(K'&O,1) NE 'R').GENLIT
.*
.INVERT  ANOP
&OP      SETC  'BN&O'
         AIF   ('&O'(1,1) NE 'N').NVRTDON
&OP      SETC  'B'.'&O'(2,K'&O-1)
.NVRTDON ANOP
.*
         AIF   (&M EQ 2).SETLAB
&N       &OP   &A                  BRANCH IF OK
&N       SETC  ''
         AGO   .INLINE
.SETLAB  ANOP
&LAB     SETC  'DIE&#.Z'
&N       &OP   &LAB                SKIP IF OK
&N       SETC  ''
.INLINE  ANOP
&N       DC    X'00DEAD'           TRAP CODE
         AIF   ('&TYPE' EQ 'MSG').INLMSG
         DC    X'0100'             DBC COMMAND SIGNAL
         DC    C'&MSG'
         DC    X'00'               DBC COMMAND TERMINATOR
         AGO   .TRAIL
.INLMSG  DC    AL1(&L)             MESSAGE LENGTH
         DC    C'&MSG'
.TRAIL   AIF   ('&LAB' EQ '').MEND
&LAB     DS    0H                  RECEIVE SKIP AROUND TRAP
         AGO   .MEND
.*
.GENLIT  AIF   ('&TYPE' EQ 'MSG').LITMSG
&MSG     SETC  '  [  &MSG '
         AGO   .GOTLIT
.LITMSG  #TEST GEN=EBCDIC
&MSG     SETC  '  [&#EBCDIC(&L+1)&MSG'
.GOTLIT  ANOP
.*
         AIF   (&M NE 3).OP4
&N       B&O   &A,=C'&MSG'
         AGO   .MEND
.OP4     ANOP
&N       B&O   &A,&B,=C'&MSG'
.MEND    MEND
