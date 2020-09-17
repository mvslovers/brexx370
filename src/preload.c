#include <string.h>

#include "lerror.h"
#include "lstring.h"

#include "preload.h"

/* ----------------- RxPreLoaded ------------------- */
int __CDECL
RxPreLoaded(RxFile *rxf) {
    if (strcasecmp(LSTR(rxf->name), "GETPOINTER") == 0) {
        Lfx(&rxf->file, 64);
        LZEROSTR(rxf->file);
        strcpy(LSTR(rxf->file), "GETPOINTER: return c2d(storage(d2x(arg(1)),4))\0");
    } else if (strcasecmp(LSTR(rxf->name), "CLRSCRN") == 0) {
        Lfx(&rxf->file, 64);
        LZEROSTR(rxf->file);
        strcpy(LSTR(rxf->file), "CLRSCRN: ADDRESS TSO 'CLS';return 0\0");
    }  else if (strcasecmp(LSTR(rxf->name), "STIME") == 0) {
        Lfx(&rxf->file, 128);
        LZEROSTR(rxf->file);
        strcpy(LSTR(rxf->file),"STIME: PROCEDURE; PARSE VALUE TIME('L') WITH __HH':'__MM':'__SS'.'__HS;");
        strcat(LSTR(rxf->file),"return __HH*360000+__MM*6000+__SS*100+__HS\0");
    } else if (strcasecmp(LSTR(rxf->name), "B2C") == 0) {
        Lfx(&rxf->file, 64);
        LZEROSTR(rxf->file);
        strcpy(LSTR(rxf->file), "B2C: return x2c(b2x(arg(1)))\0");
    } else if (strcasecmp(LSTR(rxf->name), "C2B") == 0) {
        Lfx(&rxf->file, 64);
        LZEROSTR(rxf->file);
        strcpy(LSTR(rxf->file), "C2B: return x2b(c2x(arg(1)))\0");
    } else if (strcasecmp(LSTR(rxf->name), "ROOT") == 0) {
        Lfx(&rxf->file, 64);
        LZEROSTR(rxf->file);
        strcpy(LSTR(rxf->file), "ROOT: return pow(arg(1),1/arg(2))\0");
    } else return FALSE;
    LLEN(rxf->file) = strlen(LSTR(rxf->file));
    LTYPE(rxf->file) = LSTRING_TY;
    LASCIIZ(rxf->file);
    return TRUE;
}