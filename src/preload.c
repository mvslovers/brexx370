#include <string.h>
#include <hashmap.h>
#include "lerror.h"
#include "lstring.h"

#include "preload.h"

extern HashMap *globalVariables;

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
int
RxPreLoadTemp(RxFile *rxf, PLstr rxname) {
    int clen;
    PLstr tmp;
    tmp = hashMapGet(globalVariables, (char *) LSTR(*rxname));

    if (tmp && !LISNULL(*tmp)) {
        clen=LLEN(*tmp);
        Lfx(&rxf->file, clen+32);
        LZEROSTR(rxf->file);
        Lstrcpy(&rxf->file,rxname);
        strcat(LSTR(rxf->file),": ");
        LLEN(rxf->file)=LLEN(rxf->file)+2;
        Lstrcat(&rxf->file,tmp);
        LASCIIZ(rxf->file);
   //   hashMapDelete(globalVariables, (char *) LSTR(*rxname));
    } else return 8;
    return 0;
 }


/* ----------------- RxPreLoaded ------------------- */
int __CDECL
RxPreLoaded(RxFile *rxf) {
    if (strcasecmp(LSTR(rxf->name), "PEEKA") == 0) {
        RxPreLoad(rxf, "PEEKA: return c2d(storage(d2x(arg(1)),4))");
    } else if (strcasecmp(LSTR(rxf->name), "STOP") == 0) {
        RxPreLoad(rxf, "STOP:;say '*** 'arg(1);rc=arg(2); if rc=='' then rc=8;"
                       "say '*** REXX execution stopped ';exit rc;");
    } else if (strcasecmp(LSTR(rxf->name), "DATETIME") == 0) {
        RxPreLoad(rxf, "DATETIME: procedure;parse upper arg _o,_d,_i;_i=char(_i,1);_o=char(_o,1);"
                       "if _o='T' & _i='T' then if type(_d)='INTEGER' then return _d;"
                       "if _o<>'T' | (_i=_o &_d<>'') then do;_d=dattimbase('t',_d,_i);_i='T';end;"
                       "if _i<>'T' | _o='B' then return DatTimBase(_o,_d,_i);"
                       "parse value dattimbase('B',_d,_i) with _wd _mnt _dd _tme _yy;"
                       "_pi=right(1+pos(_mnt,'JanFebMarAprMayJunJulAugSepOctNovDec')%3,2,'0');"
                       "_dd=right(_dd,2,'0');if _o='E' then return _dd'.'_pi'.'_YY'-'_tme;"
                       "if _o='U' then return _pi'/'_DD'/'_YY'-'_tme;return _YY'/'_pi'/'_DD'-'_tme;");
    } else if (strcasecmp(LSTR(rxf->name), "BASE64DEC") == 0) {
        RxPreLoad(rxf, "BASE64DEC: procedure;trace off;"
                       "b64='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';"
                       "_f=strip(translate(arg(1),'+/','-_' ));_s='';"
                       "do while abbrev('==',_f)=0;parse var _f _o 2 _f;_o=d2x( pos(_o,b64)-1);"
                       "_s=_s||right(x2b(_o),6,0);end;return x2c(b2x(left(_s,length(_s)-2*length(_f))))");
    } else if (strcasecmp(LSTR(rxf->name), "BASE64ENC") == 0) {
        RxPreLoad(rxf, "BASE64ENC: Procedure;trace off;"
                       "!b64='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';"
                       "_f=x2b(c2x(arg(1)));_s='';_t=int((length(_f)/4)//3);"
                       "_f=_f||copies('00',_t);do while _f<>'';parse var _f n 7 _f;"
                       "n=x2d(b2x(n));_s=_s||substr(!b64,n+1,1);end;return _s||copies('=',_t );");
    } else if (strcasecmp(LSTR(rxf->name), "CLRSCRN") == 0) {
        RxPreLoad(rxf, "CLRSCRN: ADDRESS TSO 'CLS';return 0");
    } else if (strcasecmp(LSTR(rxf->name), "MOD") == 0) {
        RxPreLoad(rxf, "MOD: return int(arg(1)//arg(2))");
    } else if (strcasecmp(LSTR(rxf->name), "B2C") == 0) {
        RxPreLoad(rxf, "B2C: return x2c(b2x(arg(1)))");
    } else if (strcasecmp(LSTR(rxf->name), "C2B") == 0) {
        RxPreLoad(rxf, "C2B: return x2b(c2x(arg(1)))");
    } else if (strcasecmp(LSTR(rxf->name), "ROOT") == 0) {
        RxPreLoad(rxf, "ROOT:;r=POW(arg(1),1/arg(2)); return r");
    } else if (strcasecmp(LSTR(rxf->name), "DUMPVAR") == 0) {
        RxPreLoad(rxf, "DUMPVAR: Procedure;trace off;parse upper arg vn;"
                       "xn=value(vn,,-1);va=addr('xn');vl=length(xn);"
                       "say 'Core Dump of 'vn', length 'vl', length displayed 'vl+8;"
                       "say copies('-',77);vl=vl+8;call dumpit d2x(va),vl;return 0");
    } else if (strcasecmp(LSTR(rxf->name), "EPOCH2DATE") == 0) {
        RxPreLoad(rxf, "EPOCH2DATE: procedure;trace off;"
                       "udd=arg(1)%int(86400);udt=arg(1)//int(86400);"
                       "hh=right(udt%int(3600),2,'0');ut=udt//int(3600);"
                       "mm=right(ut%int(60),2,'0');ut=ut//int(60);ss=right(int(ut),2,'0');"
                       "return rxdate('e',udd,'unix')' 'hh':'mm':'ss");
    } else if (strcasecmp(LSTR(rxf->name), "GETTOKEN") == 0) {
        RxPreLoad(rxf, "GETTOKEN: Procedure;trace off;"
                       "if abbrev('CENTURY',upper(arg(1)),1)=1 then do;"
                       "call wait 1;DX=date('sorted');DX=substr(DX,2,2)+365*substr(DX,4);"
                       "return DX||filter(time('L'),'.:');end;"
                       "return peeka(peeka(peeka(16)+604)+124)");
    } else if (strcasecmp(LSTR(rxf->name), "JOBINFO") == 0) {
        RxPreLoad(rxf, "JOBINFO: procedure expose job.;trace off;drop job.;"
                       "job.name=strip(peeks(__tiot(),8));ssib=peeka(__jscb()+316);"
                       "jobn=peeks(ssib+12,8);job.number=translate(jobn,'0',' ');"
                       "proc=strip(peeks(__tiot()+8,8));"
                       "stepn=strip(peeks(__tiot()+16,8));if stepn='' then job.step=proc;"
                       "else job.step=proc'.'stepn;job.program=peeks(__jscb()+360,8);"
                       "return job.name;__tcb: return peeka(540);"
                       "__tiot: return peeka(__tcb()+12);__jscb: return peeka(__tcb()+180)");
    } else if (strcasecmp(LSTR(rxf->name), "PEEKS") == 0) {
        RxPreLoad(rxf, "PEEKS: return storage(d2x(arg(1)),arg(2));");
    } else if (strcasecmp(LSTR(rxf->name), "VERSION") == 0) {
        RxPreLoad(rxf, "VERSION: Procedure;parse upper arg mode;"
                       "parse version lang vers ptf '('datef')';"
                       "if abbrev('FULL',mode,1)=0 then return vers;parse var datef mm dd yy;"
                       "return 'Version 'vers' Build Date 'dd'. 'mm' 'yy");
    } else if (strcasecmp(LSTR(rxf->name), "SPLITBS") == 0) {
        RxPreLoad(rxf, "SPLITBS: trace off;"
                       "if arg(3)='' then return split(arg(1),arg(2));parse arg __S,__T,__X;"
                       "if __T='' then __T='mystem.';"
                       "else if substr(__T,length(__T),1)<>'.' then __T=__T'.';interpret 'drop '__T;"
                       "##l=length(__X);##I=1;##O=1;##P=pos(__X,__S);if ##P>0 then "
                       "do until ##P=0;interpret __T'##I=substr(__S,##O,##P-##O)';##I=##I+1;"
                       "##O=##P+##l;##P=pos(__X,__S,##O);end;interpret __T'##I=substr(__S,##O)';"
                       "interpret __T'0=##I';return ##I");
    } else if (strcasecmp(LSTR(rxf->name), "LOADP") == 0) {
        RxPreLoad(rxf, "LOADP: Procedure;parse upper arg _p;      ;"
                       "if length(_p)>8 then _p=substr(_p,1,8);else if _p='' then _p='default';"
                       "_AD=userid()\".REXX.PROF(\"_P\")\";_AE=\"'\"userid()\".REXX.PROF(\"_P\")'\";"
                       "if exists(_AE)<>1 then return 4;_fk=getG('PROF_file_'_p);if _fk>0 then do;"
                       "call close _fk;call setG('PROF_file_','');end;"
                       "if Import(_ad)<>0 then return 8;signal on syntax name _#ierr;"
                       "interpret 'call PROF_'_p;say vlist(_p);_A=changestr('=\"',vlist(_p),'\",\"');"
                       "call split(_A,'_x','15'x);drop _a;do i=1 to _x.0;"
                       "interpret '#=SETG(\"'_x.i\")\";end;drop _x.;_a=vlist(_p);_fk=open(_AE,'rb');"
                       "fs=SEEK(_fk,0,\"EOF\");call close _fk;if fs<length(_A)*1.5 then return 0;"
                       "_fk=open(_AE,'wb');if _fk<=0 then return 4;call write _fk,'PROF_'_p':  '_A;"
                       "call close _fk;return 0;_#ierr:;"
                       "say 'Error '_ae' corrupted, label PROF_'_p': missing, or';"
                       "say '       file contains invalid statements';return 8");
    } else if (strcasecmp(LSTR(rxf->name), "SETP") == 0) {
        RxPreLoad(rxf, "SETP: Procedure;trace off;parse upper arg _p,_v;if _p='' then _p='default';"
                       "if length(_p)>8 then _p=substr(_p,1,8);_fk=getG('PROF_file_'_p);"
                       "if _fk='' then _fk=_#cpds();if _fk<=0 then return _fk;"
                       "call write(_fk,_p'_'_v'=\"'arg(3)'\"','nl');call setg(_p'_'_v,arg(3));"
                       "return 0;_#cpds:;_AD=userid()'.REXX.PROF';_ap=\"'\"_ad'('_p\")'\";"
                       "if exists(\"'\"_AD\"'\")<1 then _fk=_#apds();"
                       "else if exists(_ap)=1 then _fk=_#rpds();else _fk=_#npds();"
                       "if _fk<=0 then return -1;call setg('PROF_file_'_p,_fk);return _fk;"
                       "_#npds:;_fk=open(_ap,'wt');if _fk<=0 then return -1;#=_#wlb();"
                       "return _fk;_#rpds:;_fk=open(_ap,'RB');if _fk<=0 then return -2;"
                       "eof=seek(_fk,0,'EOF');call seek(_fk,0,'TOF');_b=read(_fk,eof);"
                       "call close _fk;_fk=open(_ap,'wb');if _fk<=0 then return -2;"
                       "if pos('PROF_'_p':',substr(_b,1,40))=0 then call _#wlb;"
                       "call write(_fk,_b);drop _b;return _fk;_#apds:;"
                       "rc=CREATE(\"'\"_AD\"'\",'recfm=vb,lrecl=255,blksize=5100,unit=sysda,;"
                       ",pri=30,sec=30,dirblks=50');if rc<0 then return -3;_fk=open(_ap,'wt');"
                       "if _fk<=0 then return -1;call _#wlb;return _fk;"
                       "_#wlb: return write(_fk,'PROF_'_p':','nl')");
    } else if (strcasecmp(LSTR(rxf->name), "GETP") == 0) {
        RxPreLoad(rxf, "GETP: trace off;parse arg _p;if length(_p)>8 then _p=substr(_p,1,8);"
                       ";else if _p='' then _p='default';return getg(_p'_'arg(2));");
    } else if (strcasecmp(LSTR(rxf->name), "AFTER") == 0) {
        RxPreLoad(rxf, "after: trace off;!_#=pos(arg(1),arg(2));"
                       "if !_#=0 then return '';!_#=!_#+length(arg(1));return substr(arg(2),!_#);");
    } else if (strcasecmp(LSTR(rxf->name), "BEFORE") == 0) {
        RxPreLoad(rxf, "before: trace off;!_#=pos(arg(1),arg(2));"
                       "if !_#<2 then return '';return substr(arg(2),1,!_#-1);");
    } else if (strcasecmp(LSTR(rxf->name), "WORDDEL") == 0) {
        RxPreLoad(rxf, "worddel:;trace off;parse arg _#s,_#w;_#o=wordindex(_#s,_#w);if _#o=0 then return _#s;"
                       "return substr(_#s,1,_#o-1)subword(_#s,_#w+1);");
    } else if (strcasecmp(LSTR(rxf->name), "WORDINS") == 0) {
        RxPreLoad(rxf, "wordins:;trace off;parse arg __n,__o,__p;if __p<1 then return __n' '__o;"
                       "__i=wordindex(__o,__p)+wordlength(__o,__p);if __i<1 then return __o' '__n;"
                       "return substr(__o,1,__i)__n' 'substr(__o,__i+1);");
    } else if (strcasecmp(LSTR(rxf->name), "WORDREP") == 0) {
        RxPreLoad(rxf, "wordrep:;trace off;parse arg __r,__s,__w;__p=wordindex(__s,__w);if __p<1 then return __s;"
                       "return substr(__s,1,__p-1)__r' 'substr(__s,__p+wordlength(__s,__w)+1);");
    } else if (strcasecmp(LSTR(rxf->name), "LOCK") == 0) {
        RxPreLoad(rxf, "LOCK: procedure expose LckTry;parse upper arg qn,mode,wf;lcktry=0;"
                       "if qn='' then call stop 'lock resource name is mandatory';"
                       "if abbrev('EXCLUSIVE',mode,1)=1 then mode=67;else if abbrev('SHARED',mode,1)=1 then mode=195;"
                       "else if abbrev('TEST',mode,1)=1 then return enq(qn,71);else mode=195;etim=time('ms');"
                       "if datatype(wf)='NUM' then etim=etim+wf/1000;do while enq(qn,mode)<>0;"
                       "if time('ms')>=etim then return 4;call wait 100;lcktry=lcktry+1;end;return 0;");
    } else if (strcasecmp(LSTR(rxf->name), "UNLOCK") == 0) {
        RxPreLoad(rxf, "UNLOCK: return DEQ(ARG(1),65);");
    } else if (strcasecmp(LSTR(rxf->name), "__NJEFETCH") == 0) {
        RxPreLoad(rxf, "__njefetch: procedure expose _data _$njef;parse arg tim1,tim2;tim2=tim2/1000;"
                       "if _$njef<>0 then do;et=__njereceive(tim1);if et=3 then return et;_$njef=0;return et;end;"
                       "tim3=time('ms');_$njef=1;do forever;et=__njereceive(10);if et=1 then leave;if et=3 then do;"
                       "if time('ms')-tim3>tim2 then return 5;call wait 100;end;else return et;end;_$njef=0;return 1;");
    } else if (strstr(LSTR(rxf->name), "__") !=NULL) {
                       if (RxPreLoadTemp(rxf,&rxf->name) > 0) return FALSE;
    } else if (strcasecmp(LSTR(rxf->name), "XPULL") == 0) {
        RxPreLoad(rxf, "xpull: parse pull __#stck;return __#stck;");
        } else return FALSE;
    return TRUE;
}