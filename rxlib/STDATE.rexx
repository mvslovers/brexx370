/*REXX */
/*********************************************************************/
/* THIS FUNCTION RESIDES IN THE RXLIB. SEE SECTIONS BELOW FOR INF    */
/* NOTE: THIS IS FOR RECREATIONAL PURPOSES ONLY.                     */
/*       FEEL FREE TO USE ANY PORTIONS OF CODE                       */
/* CREATED: 01/2024 -- RUSTY MOSER                                   */
/*********************************************************************/

stdate:
   PARSE UPPER ARG ARG1,ARG2,ARG3,ARG4,ARGJUNK

   IF ARG1 = 'SDNEW' THEN DO
      CALL SDNEW
      RETURN SRESULT
   END

   IF ARG1 = '' THEN ARG1 = 'SDW'
   IF ARG3 = '' THEN ARG3 = 'DFLT'
   IF ARG1 <> 'SDW' THEN DO
     IF ARG1 <> 'XU' THEN DO
      IF ARG1 <> 'XE' THEN DO
       IF ARG1 <> 'I' THEN DO
         SRESULT = 'INVALID OR MISSING DATE-TARGET-FORMAT PARM'
         RETURN SRESULT
       END
     END
    END
   END
   IF ARG3 <> 'SDW' THEN DO
    IF ARG3 <> 'DFLT' THEN DO
     IF ARG3 <> 'XU' THEN DO
      IF ARG3 <> 'XE' THEN DO
       IF ARG3 <> 'I' THEN DO
         SRESULT = 'INVALID OR MISSING DATE-INPUT-FORMAT PARM'
         RETURN SRESULT
       END
      END
     END
    END
   END


   /* SET DEFAULT TO CURRENT DATE TIME */
   CALL DEFCNFG

   IF ARG3 = 'XU' THEN DO
    CM = SUBSTR(ARG2,1,2)
    CD = SUBSTR(ARG2,4,2)
    CY  = SUBSTR(ARG2,7,4)
   END

   IF ARG3 = 'XE' THEN DO
    CD = SUBSTR(ARG2,1,2)
    CM = SUBSTR(ARG2,4,2)
    CY  = SUBSTR(ARG2,7,4)
   END

   IF ARG3 = 'I' THEN DO
    CY  = SUBSTR(ARG2,1,4)
    CM = SUBSTR(ARG2,6,2)
    CD = SUBSTR(ARG2,9,2)
   END

   IF ARG3 = 'SDW' THEN DO   /* CONVERT FROM SDW TO COMMON DATE */
      CALL SDW2G
      RETURN SRESULT
   END

  IF ARG1 = 'SDW' THEN DO
    CALL SDWC
    RETURN SRESULT
  END

EXIT


SDWC:
/*********************************************************************/
/* STARTREK GALACTIC DATE                                            */
/*********************************************************************/

/* THE STARTREK STARDATE IS BUILT BASED ON THE FOLLOWING.

   C + (1000*(Y-B)) + ((1000/N)*(M+D-1))
   WHERE B IS THE STANDARD YEAR. (USING 2005 AS THE ALTERNATE
     WAS 2323.
   WHERE C IS 58000.00 STARDATE YEAR FOR 2005. (2323 WAS 00000)
   WHERE M IS THE CURRENT MONTH NUMBER BASE ON MONTH JULIAN
   WHERE D IS THE CURRENT  DAY
   WHERE Y IS THE CURRENT YEAR

   CITATION:
   THIS IS BASED ON NOTES FROM THE FOLLOWING WEBSITE.
   HTTPS://WWW.WIKIHOW.COM/CALCULATE-STARDATES

*/

 SN = 365            /* DAYS IN YEAR. 366 FOR LEAP */
 SB = 2005           /* USING BASE AS 2005 (58000.00) */
 SC = 58000.00

 IF CY > 2322 THEN DO
   SB = 2323
   SC = 0
 END

 MN = '000 031 059 090 120 151 181 212 243 273 304 334'

  IF CY // 4 = 0 THEN DO  /* LEAP  */
   LEAP = 1
   SN = 366
   MN = '000 031 060 091 121 152 182 213 244 274 305 335'
  END

  MMP = ((CM-1)*4)+1 /* START POSITION IN MONTH STRING */

  MM = SUBSTR(MN,MMP,3)


 SDW = SC + (1000*(CY-SB)) + ((1000/SN)*(MM+CD-1))

 SRESULT = ROUND(SDW,2)

RETURN SRESULT

SDW2G:

 SN = 365            /* DAYS IN YEAR. 366 FOR LEAP */
 SB = 2005           /* USING BASE AS 2005 (58000.00) */
 SC = 58000.00
 IF ARG4 = 'BASE2' THEN DO
    SB = 2323
    SC = 0
 END

 MN = '000 031 059 090 120 151 181 212 243 273 304 334'
 /* ARG2 HAS THE STARDATE TO BE CONVERTED */
 STH = (INT(ARG2/1000)*1000)   /* IGNORE THE 100 10 1 .1 ETC */
 STL = ROUND(ARG2 - STH,2)    /* 10 10 1 .1 ETC VALUE  */
 SDYR = INT(((STH - SC)/1000) + SB)
 IF SDYR // 4 = 0 THEN DO           /* ZERO MEANS LEAP YEAR */
   LEAP = 1
   SN = 366
   MN = '000 031 060 091 121 152 182 213 244 274 305 335'
  END

  SMD =  INT((CEIL(STL * SN) / 1000) + 1)
  SPOS = 45
  DO AA = 1 TO 12
  BB = 13 - AA
    IF SMD < SUBSTR(MN,SPOS,4) THEN DO  /* NOT THIS MONTH */
     SPOS = SPOS - 4
     ITERATE
    END
    IF SMD = SUBSTR(MN,SPOS,4) THEN DO /* EQUAL TO MONTH VALUE */
     SMD = SMD + 1
    END
    IF SMD > SUBSTR(MN,SPOS,4) THEN DO /* SHOULD BE GREATER    */
     MNM = SUBSTR(MN,SPOS,4)
     MNV = BB   /* MONTH VALUE */
     LEAVE
    END
  END  /* DO AA= */

  SDMM = MNV         /* MONTH */
  SDDD = SMD - MNM  /* THE DAY */
  SDMX = SDMM + 100
  SDDX = SDDD + 100
  SDMT = SUBSTR(SDMX,2,2)
  SDDT = SUBSTR(SDDX,2,2)


  /* XU = MM/DD/YYYY   XE = DD/MM/YYYY   I = YYYY-MM-DD */

  IF ARG1 = 'XU' THEN SRESULT = SDMT'/'SDDT'/'SDYR
  IF ARG1 = 'XE' THEN SRESULT = SDDT'/'SDMT'/'SDYR
  IF ARG1 = 'I'  THEN SRESULT = SDYR'-'SDMT'-'SDDT

RETURN SRESULT

/*********************************************************************/
/* STARTREK GALACTIC DATE - END OF CALCULATIONS                      */
/*********************************************************************/



/*********************************************************************/
/* STARTREK DATE BASED ON JDN FROM 01/01/0001 DATE                   */
/*********************************************************************/
SDNEW:

 CURRENT_DATE = DATE('JDN')
 LASTFOURDIGITS = SUBSTR(CURRENT_DATE, LENGTH(CURRENT_DATE) - 3, 4)

 CURRENT_TIME = TIME('S')  /* GET CURRENT SYSTEM TIME IN SECONDS */

 SECONDS_IN_DAY = 24 * 60 * 60  /* TOTAL SECONDS IN A DAY */

 TENTH_OF_THE_DAY = FLOOR((CURRENT_TIME / SECONDS_IN_DAY) * 10)

 CURRENTYEAR = SUBSTR(DATE(), LENGTH(DATE()) - 3, 4)

 RESULT = LASTFOURDIGITS||'.'||TENTH_OF_THE_DAY||'/'|| CURRENTYEAR

 SRESULT = 'StarDate/Year:'  RESULT

RETURN SRESULT

/*********************************************************************/
/* STARTREK DATE BASED ON JDN FROM 01/01/0001 DATE - END CALCULATIONS*/
/*********************************************************************/


  /*SETUP DEFAULTS */
DEFCNFG:

   CD = SUBSTR(DATE('XU'),4,2)
   CM = SUBSTR(DATE('XU'),1,2)
   CY  = SUBSTR(DATE('XU'),7,4)
   TI = TIME('M')
   TH = SUBSTR(TIME(),1,2)
   TN = SUBSTR(TIME(),4,2)
   TS = SUBSTR(TIME(),7,2)


   CJCYC = 7980                    /* JULIAN CYCLE  */

RETURN



