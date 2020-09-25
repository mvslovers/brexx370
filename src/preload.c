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
    if (strcasecmp(LSTR(rxf->name), "PEEKA") == 0) {
        RxPreLoad(rxf, "PEEKA: return c2d(storage(d2x(arg(1)),4))");
    } else if (strcasecmp(LSTR(rxf->name), "CLRSCRN") == 0) {
        RxPreLoad(rxf, "CLRSCRN: ADDRESS TSO 'CLS';return 0");
    } else if (strcasecmp(LSTR(rxf->name), "STIME") == 0) {
        RxPreLoad(rxf, "STIME: PROCEDURE; PARSE VALUE TIME('L') WITH __HH':'__MM':'__SS'.'__HS;"
                       "return __HH*360000+__MM*6000+__SS*100+__HS");
    }else if (strcasecmp(LSTR(rxf->name), "EPOCHTIME") == 0) {
        RxPreLoad(rxf,"EPOCHTIME: procedure;trace off;"
                       "parse arg dd,mm,yy;if dd='' then do;"
                       "parse value date('e') with dd'/'mm'/'yy;yy='20'yy;"
                       "secs=time('s');end;else do;"
                       "if _vr(dd,1,31)>0 then signal tserror;"
                       "if _vr(mm,1,12)>0 then signal tserror;"
                       "if _vr(yy,1970,2040)>0 then signal tserror;"
                       "secs=0;end;a=(14-mm)%12;m=mm+12*a-3;y=yy+4800-a;"
                       "j=dd+(153*m+2)%5+365*y;j=j+y%4-y%100+y%400-32045;"
                       "return int((j-1721426-719162)*86400+secs);_vr:;"
                       "if datatype(arg(1))<>'NUM' then return 8;"
                       "if arg(1)<arg(2) | arg(1)>arg(3) then return 8;return 0;"
                       "tserror: SAY 'DATE IN ERROR: 'DD'.'MM'.'YY;exit 8");
    } else if (strcasecmp(LSTR(rxf->name), "MOD") == 0) {
        RxPreLoad(rxf, "MOD: return arg(1)%arg(2)");
    } else if (strcasecmp(LSTR(rxf->name), "REM") == 0) {
        RxPreLoad(rxf, "REM: return arg(1)//arg(2)%1");
    } else if (strcasecmp(LSTR(rxf->name), "B2C") == 0) {
        RxPreLoad(rxf, "B2C: return x2c(b2x(arg(1)))");
    } else if (strcasecmp(LSTR(rxf->name), "C2B") == 0) {
        RxPreLoad(rxf, "C2B: return x2b(c2x(arg(1)))");
    } else if (strcasecmp(LSTR(rxf->name), "ROOT") == 0) {
        RxPreLoad(rxf, "ROOT:;r=POW(arg(1),1/arg(2)); return r");
    } else if (strcasecmp(LSTR(rxf->name), "DUMPVAR") == 0) {
        RxPreLoad(rxf, "DUMPVAR: Procedure;trace off;parse upper arg vname;"
                       "xname=value(vname,,0);vaddr=addr('xname');"
                       "vlen=length(xname);say 'Core Dump of 'vname', length 'vlen', length displayed 'vlen+16;"
                       "say copies('-',77);vlen=vlen+16;"
                       "call dumpit d2x(vaddr),vlen;return 0");
    }else if (strcasecmp(LSTR(rxf->name), "EPOCH2DATE") == 0) {
            RxPreLoad(rxf,"EPOCH2DATE: procedure;trace off;"
                       "udd=arg(1)%86400;udt=arg(1)//86400%1;"
                       "hh=right(udt%3600,2,'0');ut=udt//3600%1;"
                       "mm=right(ut%60,2,'0');ut=ut//60%1;ss=right(ut%1,2,'0');"
                       "return rxdate('e',udd,'unix')' 'hh':'mm':'ss");
    }else if (strcasecmp(LSTR(rxf->name), "GETTOKEN") == 0) {
            RxPreLoad(rxf,"GETTOKEN: Procedure;trace off;"
                       "if abbrev('CENTURY',upper(arg(1)),1)=1 then do;"
                       "call wait 1;DX=date('sorted');DX=substr(DX,2,2)+365*substr(DX,4);"
                       "return DX||filter(time('L'),'.:');end;"
                       "return peeka(peeka(peeka(16)+604)+124)");
    }else if (strcasecmp(LSTR(rxf->name), "JOBINFO") == 0) {
            RxPreLoad(rxf,"JOBINFO: procedure expose job.;trace off;drop job.;"
                       "job.name=strip(peeks(__tiot(),8));ssib=peeka(__jscb()+316);"
                       "jobn=peeks(ssib+12,8);job.number=translate(jobn,'0',' ');"
                       "proc=strip(peeks(__tiot()+8,8));"
                       "stepn=strip(peeks(__tiot()+16,8));if stepn='' then job.step=proc;"
                       "else job.step=proc'.'stepn;job.program=peeks(__jscb()+360,8);"
                       "return job.name;__tcb: return peeka(540);"
                       "__tiot: return peeka(__tcb()+12);__jscb: return peeka(__tcb()+180)");
    }else if (strcasecmp(LSTR(rxf->name), "PEEKS") == 0) {
            RxPreLoad(rxf,"PEEKS: return storage(d2x(arg(1)),arg(2));");
    }else if (strcasecmp(LSTR(rxf->name), "VERSION") == 0) {
            RxPreLoad(rxf,"VERSION: Procedure;parse upper arg mode;"
                       "parse version lang vers ptf '('datef')';"
                       "if abbrev('FULL',mode,1)=0 then return vers;parse var datef mm dd yy;"
                       "return 'Version 'vers' Build Date 'dd'. 'mm' 'yy");
    } else return FALSE;
    return TRUE;
}
