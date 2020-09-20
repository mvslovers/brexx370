/* REXX - BY MOSHIX */
O = 0
SAY 'Currently active users:'
SAY '-----------------------'
 CVT=PTR(16)
 ASVT=PTR(CVT+556)+512                  /* GET ASVT                   */
 ASVTMAXU=PTR(ASVT+4)                   /* GET MAX ASVT ENTRIES       */
 DO A = 0 TO ASVTMAXU - 1
   ASCB=STG(ASVT+16+A*4,4)              /* GET PTR TO ASCB (SKIP
                                           MASTER)                    */
   IF BITAND(ASCB,'80000000'X) = '00000000'X THEN /* IF IN USE        */
     DO
       ASCB=C2D(ASCB)                   /* GET ASCB ADDRESS           */
       CSCB=PTR(ASCB+56)                /* GET CSCB ADDRESS           */
       CHTRKID=STG(CSCB+28,1)           /* CHECK ADDR SPACE TYPE      */
       IF CHTRKID='01'X THEN            /* IF TSO USER                */
         DO
           ASCBJBNS=PTR(ASCB+176)       /* GET ASCBJBNS               */
           ASCBSRBT=PTR(ASCB+200)       /* GET ASCBEATT               */
           O = O + 1
           SAY RIGHT(O,2,'0') ASCBSRBT,
               STG(ASCBJBNS,8)          /* WE IS SOME HAPPY CAMPER!   */
         END
     END
 END
 EXIT
 PTR:  RETURN C2D(STORAGE(D2X(ARG(1)),4))     /* RETURN A POINTER     */
 STG:  RETURN STORAGE(D2X(ARG(1)),ARG(2))     /* RETURN STORAGE       */
