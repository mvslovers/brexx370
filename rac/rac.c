#include <stdio.h>
#include <string.h>
#include "rac.h"

int rac_status()
{
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
        if (strncmp((char *)safvid, "SAFV", 4) == 0) {
            isRacSecured = 1;
        }
    }

    return isRacSecured;
}
