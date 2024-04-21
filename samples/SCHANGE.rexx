        SAY COPIES('-',50)
        SAY "READ EXTERNAL INTO SARRAY, SELECT SUBSET"
        SAY COPIES('-',50)
        DSNIN=MVSVAR("REXXDSN")
        S1=SREAD("'"DSNIN"(LLDATA)'")      /* READ DATA */
        CALL SLIST S1
        SAY SCHANGE(S1,'IN','**','EE','+++','EY','')
        SAY COPIES('-',50)
        SAY 'CHANGED ARRAY '
        SAY COPIES('-',50)
        CALL SLIST S1
        CALL SFREE S1
        EXIT 0
