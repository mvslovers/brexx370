#include <string.h>

#include "lerror.h"
#include "lstring.h"

#include "preload.h"
int
RxPreLoad(RxFile *rxf,char *code) {
    int clen;
    clen=strlen(code);
    Lfx(&rxf->file, clen+32);
    LZEROSTR(rxf->file);
    strcpy(LSTR(rxf->file), code);
    LLEN(rxf->file) = clen;
    LTYPE(rxf->file) = LSTRING_TY;
    LASCIIZ(rxf->file);
}
/* ----------------- RxPreLoaded ------------------- */
int __CDECL
RxPreLoaded(RxFile *rxf) {
    if (strcasecmp(LSTR(rxf->name), "GETPOINTER") == 0) {
        RxPreLoad(rxf,"GETPOINTER: return c2d(storage(d2x(arg(1)),4))");
    } else if (strcasecmp(LSTR(rxf->name), "CLRSCRN") == 0) {
        RxPreLoad(rxf,"CLRSCRN: ADDRESS TSO 'CLS';return 0");
    }  else if (strcasecmp(LSTR(rxf->name), "STIME") == 0) {
        RxPreLoad(rxf,"STIME: PROCEDURE; PARSE VALUE TIME('L') WITH __HH':'__MM':'__SS'.'__HS;"
                "return __HH*360000+__MM*6000+__SS*100+__HS");
       }  else if (strcasecmp(LSTR(rxf->name), "TIMESTAMP") == 0) {
        RxPreLoad(rxf,"timestamp: return timstamp(arg(1),arg(2),arg(3))");
    } else if (strcasecmp(LSTR(rxf->name), "B2C") == 0) {
        RxPreLoad(rxf, "B2C: return x2c(b2x(arg(1)))");
    } else if (strcasecmp(LSTR(rxf->name), "C2B") == 0) {
        RxPreLoad(rxf,"C2B: return x2b(c2x(arg(1)))");
    } else if (strcasecmp(LSTR(rxf->name), "ROOT") == 0) {
        RxPreLoad(rxf, "ROOT: return pow(arg(1),1/arg(2))");
    } else if (strcasecmp(LSTR(rxf->name), "DUMPVAR") == 0) {
        RxPreLoad(rxf,"DUMPVAR: Procedure;parse upper arg vname;"
        "xname=value(vname,,0);vaddr=addr('xname');"
        "vlen=length(xname);say 'Core Dump of 'vname', length 'vlen', length displayed 'vlen+16;"
        "say copies('-',77);vlen=vlen+16;"
        "call dumpit d2x(vaddr),vlen;return 0;");
    } else return FALSE;
    return TRUE;
}
