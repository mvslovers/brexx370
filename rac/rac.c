#include <stdio.h>
#include <string.h>
#include "rac.h"

int rac_secured()
{
    /*
     *
     * verify RAC availability
     *
         LA    R7,1             return code if RAC unavailable
         L     R1,CVTPTR        get CVT address
         ICM   R1,B'1111',CVTSAF(R1) SAFV defined ?
         BZ    LOGNOK           no RAC, allow login
         USING SAFV,R1          addressability of SAFV
         CLC   SAFVIDEN(4),SAFVID SAFV initialized ?
         BNE   LOGNOK           no RAC, allow login
         DROP  R1               SAFV no longer needed
     */

    int isRacSecured = 0;

    void ** psa;            // PSA     =>    0 / 0x00
    void ** cvt;            // FLCCVT  =>   16 / 0x10
    void ** safv;           // CVTSAF  =>  248 / 0xF8

    void ** safvid;         // SAFVIDEN =>   0 / 0x00

    psa  = 0;
    cvt  = psa[4];          // 16
    safv = cvt[62];         // 248

    if (safv != NULL) {
        safvid = safv;
        printf("DBG> SAFV found. SAFVIDEN=%4s\n", (char *) safvid);
        if (strncmp((char *)safvid, "SAFV", 4) == 0) {
            printf("DBG> BINGO \n");
            isRacSecured = 1;
        }
    }

    return isRacSecured;
}
