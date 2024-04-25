         MACRO
&LABEL   EXMVC &INTO,&FROM,&LEN=,&MAXLEN=,&STRIPLN=
         B     *+10                JUMP OVER EXMVC
M&SYSNDX MVC   0(1,R1),0(RE)       EXMVC
&LABEL   LA    RF,&LEN             LOAD  LENGTH
         LTR   RF,RF               TEST IT
         BNP   N&SYSNDX            LENGTH MUST BE AT LEAST 1
         AIF   ('&MAXLEN' EQ '').NOMAX
         LA    R1,&MAXLEN          LOAD MAXIMUM LENGTH
         CR    RF,R1               IS REQUESTED LEN > MAXLEN
         BH    N&SYSNDX            YES, SKIP EXMVC
.NOMAX   ANOP
         AIF   ('&STRIPLN' EQ '').NOSTRIP
         LA    R1,&STRIPLN        LOAD MAXIMUM LENGTH ALLOWED
         CR    RF,R1               IS REQUESTED LEN > STRIPLEN
         BH    *+4                 NO, GO ON
         LR    RF,R1               YES, USE STRIPLEN
.NOSTRIP ANOP
         BCTR  RF,0                -1, FOR EXMVC
         LA    R1,&INTO            LOAD SOURCE ADDRESS
         LA    RE,&FROM            LOAD TARGET ADDRESS
         EX    RF,M&SYSNDX         EXECUTE MVC
N&SYSNDX DS    0H
         MEND
