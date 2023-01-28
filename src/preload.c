#include <string.h>
#include <hashmap.h>
#include "lerror.h"
#include "lstring.h"

#include "preload.h"

extern HashMap *globalVariables;

void
RxPreLoad(RxFile *rxf,char *code) {
    int clen;
    clen=(int)strlen(code);
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
    Lupper(&rxf->name);
    if (strcmp((const char *) LSTR(rxf->name), "PEEKA") == 0) {
        RxPreLoad(rxf, "PEEKA: return c2d(storage(d2x(arg(1)),4))");
    } else if (strcmp((const char *) LSTR(rxf->name), "PEEKN") == 0) {
        RxPreLoad(rxf, "PEEKN: return c2d(storage(d2x(arg(1)),arg(2)))");
    } else if (strcmp((const char *) LSTR(rxf->name), "STEMCOPY") == 0) {
        RxPreLoad(rxf, "STEMCOPY: parse arg $#IN,$#OUT;"
                       "if length($#IN)=0  then call STOP 'No source STEM defined';"
                       "if length($#OUT)=0 then call STOP 'No target STEM defined';"
                       "_#SHI=value($#IN'0'); if datatype(_#SHI)<>'NUM' then call STOP 'STEM '$#IN'0 does not contain a valid number';"
                       "_#RX='__RX'$#IN||$#OUT; if getg(_#RX)=='' then do; "
                       "lmac='do __i=0 for _#SHI+1;'$#OUT'__i='$#IN'__i;end;return';"
                       "call setg(_#RX,lmac); end; interpret 'call '_#RX; return _#SHI;");
    } else if (strcmp((const char *) LSTR(rxf->name), "PEEKU") == 0) {
        RxPreLoad(rxf, "PEEKU: return c2u(storage(d2x(arg(1)),4))");
    } else if (strcmp((const char *) LSTR(rxf->name), "STOP") == 0) {
        RxPreLoad(rxf, "STOP:;call error arg(1)");
     } else if (strcmp((const char *) LSTR(rxf->name), "DATETIME") == 0) {
        RxPreLoad(rxf, "DATETIME: procedure;parse upper arg _o,_d,_i;_i=char(_i,1);_o=char(_o,1);"
                       "if _o='T' & _i='T' then if type(_d)='INTEGER' then return _d;"
                       "if _o<>'T' | (_i=_o &_d<>'') then do;_d=dattimbase('t',_d,_i);_i='T';end;"
                       "if _i<>'T' | _o='B' then return DatTimBase(_o,_d,_i);"
                       "parse value dattimbase('B',_d,_i) with _wd _mnt _dd _tme _yy;"
                       "_pi=right(1+pos(_mnt,'JanFebMarAprMayJunJulAugSepOctNovDec')%3,2,'0');"
                       "_dd=right(_dd,2,'0');if _o='E' then return _dd'.'_pi'.'_YY'-'_tme;"
                       "if _o='U' then return _pi'/'_DD'/'_YY'-'_tme;return _YY'/'_pi'/'_DD'-'_tme;");
    } else if (strcmp((const char *) LSTR(rxf->name), "BASE64DEC") == 0) {
        RxPreLoad(rxf, "BASE64DEC: procedure;trace off;"
                       "b64='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';"
                       "_f=strip(translate(arg(1),'+/','-_' ));_s='';"
                       "do while abbrev('==',_f)=0;parse var _f _o 2 _f;_o=d2x( pos(_o,b64)-1);"
                       "_s=_s||right(x2b(_o),6,0);end;return x2c(b2x(left(_s,length(_s)-2*length(_f))))");
    } else if (strcmp((const char *) LSTR(rxf->name), "BASE64ENC") == 0) {
        RxPreLoad(rxf, "BASE64ENC: Procedure;trace off;"
                       "!b64='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';"
                       "_f=x2b(c2x(arg(1)));_s='';_t=int((length(_f)/4)//3);"
                       "_f=_f||copies('00',_t);do while _f<>'';parse var _f n 7 _f;"
                       "n=x2d(b2x(n));_s=_s||substr(!b64,n+1,1);end;return _s||copies('=',_t );");
    } else if (strcmp((const char *) LSTR(rxf->name), "CLRSCRN") == 0) {
        RxPreLoad(rxf, "CLRSCRN: ADDRESS TSO 'CLS';return 0");
    } else if (strcmp((const char *) LSTR(rxf->name), "MOD") == 0) {
        RxPreLoad(rxf, "MOD: return int(arg(1)//arg(2))");
    } else if (strcmp((const char *) LSTR(rxf->name), "B2C") == 0) {
        RxPreLoad(rxf, "B2C: return x2c(b2x(arg(1)))");
    } else if (strcmp((const char *) LSTR(rxf->name), "C2B") == 0) {
        RxPreLoad(rxf, "C2B: return x2b(c2x(arg(1)))");
    } else if (strcmp((const char *) LSTR(rxf->name), "ROOT") == 0) {
        RxPreLoad(rxf, "ROOT:;r=POW(arg(1),1/arg(2)); return r");
    } else if (strcmp((const char *) LSTR(rxf->name), "DUMPVAR") == 0) {
        RxPreLoad(rxf, "DUMPVAR: Procedure;trace off;parse upper arg vn;"
                       "xn=value(vn,,-1);va=addr('xn');vl=length(xn);"
                       "say 'Core Dump of 'vn', length 'vl', length displayed 'vl+8;"
                       "say copies('-',77);vl=vl+8;call dumpit d2x(va),vl;return 0");
    } else if (strcmp((const char *) LSTR(rxf->name), "EPOCH2DATE") == 0) {
        RxPreLoad(rxf, "EPOCH2DATE: procedure;trace off;"
                       "udd=arg(1)%int(86400);udt=arg(1)//int(86400);"
                       "hh=right(udt%int(3600),2,'0');ut=udt//int(3600);"
                       "mm=right(ut%int(60),2,'0');ut=ut//int(60);ss=right(int(ut),2,'0');"
                       "return rxdate('e',udd,'unix')' 'hh':'mm':'ss");
    } else if (strcmp((const char *) LSTR(rxf->name), "GETTOKEN") == 0) {
        RxPreLoad(rxf, "GETTOKEN: Procedure;trace off;"
                       "if abbrev('CENTURY',upper(arg(1)),1)=1 then do;"
                       "call wait 1;DX=date('sorted');DX=substr(DX,2,2)+365*substr(DX,4);"
                       "return DX||filter(time('L'),'.:');end;"
                       "return filter(time('L'),'.:');");
    } else if (strcmp((const char *) LSTR(rxf->name), "JOBINFO") == 0) {
        RxPreLoad(rxf, "JOBINFO: procedure expose job.;trace off;drop job.;"
                       "job.name=strip(peeks(__tiot(),8));ssib=peeka(__jscb()+316);"
                       "jobn=peeks(ssib+12,8);job.number=translate(jobn,'0',' ');"
                       "proc=strip(peeks(__tiot()+8,8));"
                       "stepn=strip(peeks(__tiot()+16,8));if stepn='' then job.step=proc;"
                       "else job.step=proc'.'stepn;job.program=peeks(__jscb()+360,8);"
                       "return job.name;__tcb: return peeka(540);"
                       "__tiot: return peeka(__tcb()+12);__jscb: return peeka(__tcb()+180)");
    } else if (strcmp((const char *) LSTR(rxf->name), "PEEKS") == 0) {
        RxPreLoad(rxf, "PEEKS: return storage(d2x(arg(1)),arg(2));");
    } else if (strcmp((const char *) LSTR(rxf->name), "VERSION") == 0) {
        RxPreLoad(rxf, "VERSION: Procedure;parse upper arg mode;"
                       "parse version lang vers ptf '('datef')';"
                       "if abbrev('FULL',mode,1)=0 then return vers;parse var datef mm dd yy;"
                       "return 'Version 'vers' Build Date 'dd'. 'mm' 'yy");
    } else if (strcmp((const char *) LSTR(rxf->name), "SPLITBS") == 0) {
        RxPreLoad(rxf, "SPLITBS: trace off;"
                       "if arg(3)='' then return split(arg(1),arg(2));parse arg __S,__T,__X;"
                       "if __T='' then __T='mystem.';"
                       "else if substr(__T,length(__T),1)<>'.' then __T=__T'.';interpret 'drop '__T;"
                       "##l=length(__X);##I=1;##O=1;##P=pos(__X,__S);if ##P>0 then "
                       "do until ##P=0;interpret __T'##I=substr(__S,##O,##P-##O)';##I=##I+1;"
                       "##O=##P+##l;##P=pos(__X,__S,##O);end;interpret __T'##I=substr(__S,##O)';"
                       "interpret __T'0=##I';return ##I");
    } else if (strcmp((const char *) LSTR(rxf->name), "LOADP") == 0) {
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
    } else if (strcmp((const char *) LSTR(rxf->name), "SETP") == 0) {
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
    } else if (strcmp((const char *) LSTR(rxf->name), "GETP") == 0) {
        RxPreLoad(rxf, "GETP: trace off;parse arg _p;if length(_p)>8 then _p=substr(_p,1,8);"
                       ";else if _p='' then _p='default';return getg(_p'_'arg(2));");
    } else if (strcmp((const char *) LSTR(rxf->name), "AFTER") == 0) {
        RxPreLoad(rxf, "after: trace off;!_#=pos(arg(1),arg(2));"
                       "if !_#=0 then return '';!_#=!_#+length(arg(1));return substr(arg(2),!_#);");
    } else if (strcmp((const char *) LSTR(rxf->name), "BEFORE") == 0) {
        RxPreLoad(rxf, "before: trace off;!_#=pos(arg(1),arg(2));"
                       "if !_#<2 then return '';return substr(arg(2),1,!_#-1);");
    } else if (strcmp((const char *) LSTR(rxf->name), "WORDDEL") == 0) {
        RxPreLoad(rxf, "worddel:;trace off;parse arg _#s,_#w;_#o=wordindex(_#s,_#w);if _#o=0 then return _#s;"
                       "return substr(_#s,1,_#o-1)subword(_#s,_#w+1);");
    } else if (strcmp((const char *) LSTR(rxf->name), "WORDINS") == 0) {
        RxPreLoad(rxf, "wordins:;trace off;parse arg __n,__o,__p;if __p<1 then return __n' '__o;"
                       "__i=wordindex(__o,__p)+wordlength(__o,__p);if __i<1 then return __o' '__n;"
                       "return substr(__o,1,__i)__n' 'substr(__o,__i+1);");
    } else if (strcmp((const char *) LSTR(rxf->name), "WORDREP") == 0) {
        RxPreLoad(rxf, "wordrep:;trace off;parse arg __r,__s,__w;__p=wordindex(__s,__w);if __p<1 then return __s;"
                       "return substr(__s,1,__p-1)__r' 'substr(__s,__p+wordlength(__s,__w)+1);");
    } else if (strcmp((const char *) LSTR(rxf->name), "LOCK") == 0) {
        RxPreLoad(rxf, "LOCK: procedure expose LckTry;parse upper arg qn,mode,wf;lcktry=0;"
                       "if qn='' then call error 'lock resource name is mandatory';"
                       "if abbrev('EXCLUSIVE',mode,1)=1 then mode=67;else if abbrev('SHARED',mode,1)=1 then mode=195;"
                       "else if abbrev('TEST',mode,1)=1 then return enq(qn,71);else mode=195;etim=time('ms');"
                       "if datatype(wf)='NUM' then etim=etim+wf/1000;do while enq(qn,mode)<>0;"
                       "if time('ms')>=etim then return 4;call wait 100;lcktry=lcktry+1;end;return 0;");
    } else if (strcmp((const char *) LSTR(rxf->name), "UNLOCK") == 0) {
        RxPreLoad(rxf, "UNLOCK: return DEQ(ARG(1),65);");
    } else if (strcmp((const char *) LSTR(rxf->name), "__NJEFETCH") == 0) {
        RxPreLoad(rxf, "__njefetch: procedure expose _data _$njef;parse arg tim1,tim2;tim2=tim2/1000;"
                       "if _$njef<>0 then do;et=__njereceive(tim1);if et=3 then return et;_$njef=0;return et;end;"
                       "tim3=time('ms');_$njef=1;do forever;et=__njereceive(10);if et=1 then leave;if et=3 then do;"
                       "if time('ms')-tim3>tim2 then return 5;call wait 100;end;else return et;end;_$njef=0;return 1;");
    } else if (strcmp((const char *) LSTR(rxf->name), "XPULL") == 0) {
        RxPreLoad(rxf, "xpull: parse pull __#stck;return __#stck;");
    } else if (strcmp((const char *) LSTR(rxf->name), "MVSVAR") == 0) {
        RxPreLoad(rxf, "MVSVAR: trace off;parse upper arg var;if var='NJEDSN' then return __NJEDSN();"
                       "if var='JOBNUMBER' then do; call jobinfo; return job.number;end;"
                       "if var='JOBNAME' then do; call jobinfo; return job.name;end;"
                       "if var='STEPNAME' then do; call jobinfo; return job.step;end;"
                       "if var='PROGRAM' then do; call jobinfo; return job.program;end;"
                       "if var='REXXDSN' then do; call rxlist('STEM'); return word(rxlist.1,4);end;"
                       "if var='REXX' then do; call rxlist('STEM'); return word(rxlist.1,2);end;"
                       "if var='IPLDATE' then return ipldate('XEUROPEAN');"
                       "if var='MVSUP' then return __MVSUP();if var='NJE' then return __NJE();else return __MVSVAR(var);");
    } else if (strcmp((const char *) LSTR(rxf->name), "LLCOPY") == 0) {
        RxPreLoad(rxf, "llCopy: procedure ; trace off; parse arg llsource; ll2=llcreate() ; if ll2<0 then return -8;"
        "call llset(llsource,'FIRST'); do until llset(llsource)=0; call lladd(ll2,llget(llsource)) ; end ; return ll2;");
    } else if (strcmp((const char *) LSTR(rxf->name), "SYSVAR") == 0) {
        RxPreLoad(rxf, "SYSVAR: ;parse upper arg var;"
                       "if var='SCRWIDTH' then return _fssmetrics('WIDTH');"
                       "if var='SCRHEIGHT' then return _fssmetrics('HEIGHT');"
                       "return __SYSVAR(var);return;");
    } else if (strcmp((const char *) LSTR(rxf->name), "_FSSMETRICS") == 0) {
        RxPreLoad(rxf, "_FSSMETRICS: procedure; trace off; parse upper arg var;"
        "parse upper arg mode; if mode<>'WIDTH' & mode<>'HEIGHT' then return -2;"
        "env=address(); address FSS; 'TEST'; if rc>0 then do; 'INIT'; if rc>0 then return -1; end;"
        "'GET 'MODE' _fssresult'; ADDRESS env; return _fssresult");
    }else if (strcmp((const char *) LSTR(rxf->name), "__NJEDSN") == 0) {
        RxPreLoad(rxf,"__NJEDSN: procedure;r2=peeka(16)+640;do for 128;r2=peeka(r2);"
                      "if r2=0 then return '';if peeks(r2+16,5)='NJE38' then leave;end;"
                      "r3=peeka(r2+8);do for 64;r4=r3+20;if PEEKS(r4,7)='NJEINIT' then return strip(PEEKS(R4+12,44));"
                      "if r3=peeka(r2+12) then return '';r3=peeka(r3);end;return '';");
    }else if (strcmp((const char *) LSTR(rxf->name), "__NJE") == 0) {
        RxPreLoad(rxf,"__NJE: procedure;if __njedsn()='' then return 0;else return 1;");
    }else if (strcmp((const char *) LSTR(rxf->name), "__MVSUP") == 0) {
        RxPreLoad(rxf,"__MVSup: procedure;return peekU(peeka(peeka(16)+604)+124)%1000*1.024%1;");
    }else if (strcmp(LSTR(rxf->name), "DEFINED") == 0) {
        RxPreLoad(rxf,"defined:;parse arg _#p0;_defnd=symbol(_#p0);if _defnd=='VAR' then do;"
                      "if datatype(_#p0)=='NUM' then return 2;return 1;end;if _defnd=='LIT' then return 0;return -1;");
    } else if (strcmp(LSTR(rxf->name), "LIFO") == 0) {
        RxPreLoad(rxf,"LIFO: parse upper arg ""_#llp0;"
                      "if _#llp0=='PULL' then return llGET(arg(2),'LIFO');"
                      "if _#llp0=='PUSH' then return llADD(arg(2),arg(3));"
                      "if _#llp0=='CREATE' then return llCreate(arg(2)); call error 'invalid LIFO request: '_#llp0;");
    } else if (strcmp(LSTR(rxf->name), "FIFO") == 0) {
        RxPreLoad(rxf,"FIFO: parse upper arg ""_#llp0;"
                      "if _#llp0=='PUSH' then return llADD(arg(2),arg(3)); "
                      "if _#llp0=='PULL' then return llGET(arg(2),'FIFO');"
                      "if _#llp0=='CREATE' then return llCreate(arg(2)); call error 'invalid FIFO request: '_#llp0;");
    } else if (strcmp(LSTR(rxf->name), "SREAD") == 0) {
        RxPreLoad(rxf,"SREAD: procedure; trace off; parse upper arg dsn;"
                      "dsub=c2d(substr(dsn,1,1)); if dsub=125 | dsub=127 then do;"
                      "ddname='X'right(time('LS'),7);"
                      "call allocate(ddname,dsn); alc=1; end; else ddname=dsn;"
                      "sname=__sread(ddname);"
                      "if alc=1 then call free ddname; return sname;");
    } else if (strcmp(LSTR(rxf->name), "SWRITE") == 0) {
        RxPreLoad(rxf,"SWRITE: procedure; trace off; parse upper arg sname,dsn;"
                      "dsub=c2d(substr(dsn,1,1)); if dsub=125 | dsub=127 then do;"
                      "ddname='X'right(time('LS'),7);"
                      "call allocate(ddname,dsn); alc=1; end; else ddname=dsn;"
                      "recs=__swrite(sname,ddname);"
                      "if alc=1 then call free ddname; return recs;");
        } else if (strcmp(LSTR(rxf->name), "LLSORT") == 0) {
        RxPreLoad(rxf,"llsort: procedure; trace off; parse arg ll1,mode,offset; if offset='' then offset=1; s1=ll2s(ll1);"
                       "call sqsort(s1,mode,offset); call llclear(ll1); call s2ll(s1,,,ll1); call sfree(s1); return ll1;");
    } else if (strcmp(LSTR(rxf->name), "LLREAD") == 0) {
        RxPreLoad(rxf,"llread: procedure; trace off; parse arg dsn; s1=sread(dsn); ll1=s2ll(s1); call sfree(s1); return ll1;");
    } else if (strcmp(LSTR(rxf->name), "LLWRITE") == 0) {
        RxPreLoad(rxf,"llwrite: procedure; trace off; parse arg ll1,dsn; s1=ll2s(ll1); recs=swrite(s1,dsn); call sfree(s1); return recs;");
    } else if (strcmp(LSTR(rxf->name), "STEM2S") == 0) {
        RxPreLoad(rxf,"stem2s:; trace off; parse arg __#stem; __#exec='__#'time('LS');"
                      "call setg(__#exec,'__#s=screate('__#stem'0); do __#i=1 to '__#stem'0; if strip('__#stem'__#i)=\"\" then iterate; call sset(__#s,,'__#stem'__#i);"
                      "end; return;'); interpret 'call '__#exec; return __#s;");
    } else if (strcmp(LSTR(rxf->name), "S2STEM") == 0) {
        RxPreLoad(rxf,"s2stem:; trace off; parse arg __#snum,__#stem;__#exec='__#'time('LS');"
                      "call setg(__#exec,'do __#i=1 to sarray(__#snum); '__#stem'__#i=sget(__#snum,__#i); end; '__#stem'0=__#i-1; return');"
                      "interpret 'call '__#exec; return sarray(__#snum);");
    } else if (strcmp(LSTR(rxf->name), "STEM2LL") == 0) {
        RxPreLoad(rxf,"stem2ll:; trace off; parse arg __#stem; __#exec='__#'time('LS');"
                      "call setg(__#exec,'__#s=llcreate(); do __#i=1 to '__#stem'0; call lladd(__#s,'__#stem'__#i); end; return __#s');"
                      "interpret '__#ll='__#exec'()'; return __#ll;");
    } else if (strcmp(LSTR(rxf->name), "LL2STEM") == 0) {
        RxPreLoad(rxf,"ll2stem:; trace off; parse arg __#llnum,__#stem;__#exec='__#'time('LS');"
                      "call llset(__#llnum,'FIRST'); "
                      "call setg(__#exec,__#stem'1=llget('__#llnum'); do __#i=2 until llcurrent==0; '__#stem'__#i=llget('__#llnum',\"NEXT\"); end; '__#stem'0=__#i-1; return');"
                      "interpret 'call '__#exec; return __#'stem'0;");
    } else if (strcmp(LSTR(rxf->name), "SEC2TIME") == 0) {
        RxPreLoad(rxf,"sec2time: procedure; parse upper arg intime,days,dds; if arg(3)='' then dds='day(s)';"
                      "if abbrev('DAYS',days,1)=1 then do; timdd=intime%86400; timrr=INTIME//86400; timhh=timrr%3600;"
                      "timrr=INTIME//3600; timmm=timrr%60; timss=timrr//60; return timdd' 'dds' '_timeF(timhh)':'_timeF(timmm)':'_timeF(timss%1); end;"
                      "timhh=intime%3600; timrr=intime//3600; timmm=timrr%60; timss=timrr//60; return _timeF(timhh)':'_timeF(timmm)':'_timeF(timss%1);"
                      "_timeF: ;return right(arg(1),2,'0')");
    } else if (strcmp(LSTR(rxf->name), "IPLDATE") == 0) {
        RxPreLoad(rxf,"ipldate: procedure; ipl=mvsvar('mvsup'); ipl1=date('TIME')-ipl; ipls=time('s')-ipl//86400;"
                      "do while ipls<0; ipls=ipls+86400; end;"
                      "return date(arg(1),ipl1,'TIME')' 'sec2time(ipls)");
    } else if (strcmp((const char *) LSTR(rxf->name), "IFREE") == 0) {
        RxPreLoad(rxf, "IFREE: return MFREE(arg(1),'INDEX')");
    } else if (strcmp((const char *) LSTR(rxf->name), "FFREE") == 0) {
        RxPreLoad(rxf, "FFREE: return MFREE(arg(1),'MATRIX')");
    } else if (strcmp((const char *) LSTR(rxf->name), "FCREATE") == 0) {
        RxPreLoad(rxf, "FCREATE: return MCREATE(arg(1),1')");
    } else if (strcmp((const char *) LSTR(rxf->name), "__EXVTOC") == 0) {
        RxPreLoad(rxf,"__EXVTOC: Procedure; trace off; if arg(1)='' then return -8; if SYSVAR('SYSTSO')<>1 then return -16;"
                      "if allocate('VTOCOUT','##vtoc')<>0 then return -16; ADDRESS TSO \"RXVTOC '\"arg(1)\"' \"arg(2)\"\";"
                      "__sx=sread('VTOCOUT'); call free('VTOCOUT'); if pos('VOLUME IS NOT MOUNTED',sget(__sx,1))>0 then return -12; return __sx;");
    } else if (strcmp((const char *) LSTR(rxf->name), "LISTVOL") == 0) {
        RxPreLoad(rxf,"LISTVOL: trace off; if arg(1)='' then return 8; __sx=__exvtoc(arg(1),'NOHEADING NOPRINT');"
                      "if __sx <0 then return __cleanup(__sx); parse value sget(__sx,1) with . . . voldsns . . voltrkalc . . voltrkused .;"
                      "if word(sget(__sx,2),1)<>'>>BREXX' then return __cleanup(4);"
                      "parse value sget(__sx,2) with . volvolume voldevice voltype volcyls voldscbs voltrkcyl voltrklen voldscbtrk voldirtrk volalttrk .;"
                      "if type(volcyls)='INTEGER' & type(voltrkcyl)='INTEGER' then voltrks=volcyls*voltrkcyl; else voltrks='';"
                      "if voldevice=='' then return __cleanup(12); return __cleanup(0); __cleanup:;  call sfree(__sx); drop __sx ;return arg(1)");
    } else if (strcmp((const char *) LSTR(rxf->name), "LISTVOLS") == 0) {
        RxPreLoad(rxf,"LISTVOLS: Procedure  expose volumes.; trace off; parse upper arg option; call privilege('on'); call outtrap('dev.');"
                      "ADDRESS COMMAND 'CP DEVLIST'; call outtrap('off'); call privilege('off'); bi=0; do volj=1 to dev.0;"
                      "parse upper value word(dev.volj,4) with dasd'/'vol'.'dev; if dasd<>'DASD' then iterate; bi=bi+1;"
                      "unit=word(dev.volj,3); buffer.bi=vol'  'unit'  'dev; end; bi=bi+1; buffer.0=bi; buffer.bi=bi-1' Volumes found';"
                      "if abbrev('FMTLIST',option,3)>0 then call fmtlist ,,'Volume  Unit Device'; else if abbrev('LIST',option,3)>0 then do;"
                      "say 'Volume  Unit Device'; do i=1 to buffer.0; say buffer.i; end; end; else do; buffer.0=buffer.0-1;"
                      "do i=0 to buffer.0; volumes.i=buffer.i; end; end; return;");
    } else if (strcmp((const char *) LSTR(rxf->name), "VTOC") == 0) {
        RxPreLoad(rxf,"VTOC: trace off; parse upper arg __vol,__fmt; if __fmt='' then parse upper arg __vol','__fmt;"
                      "__sx=__exvtoc(arg(1),'NOHEADING PRINT(NEW (DSNAME VOLUME ALLOC USED DSORG RECFM PCT LRECL BLKSZ LSTUS CDATE))');"
                      "if __sx <0 then return -16; __lmax=sarray(__sx);"
                      "vtoc.hdr='DSNAME                                       VOLUME  ALLOC   USED DSORG RECFM PCT LRECL BLKSZ LSTUS CDATE';"
                      "if pos('>>BREXX',sget(__sx,__lmax))>0 then do; call sset(__sx,__lmax,'');__lmax=__lmax-1; end;"
                      "if abbrev('LIST',__fmt,3)>0 then do; say vtoc.hdr; do __si=1 to sarray(__sx); say sget(__sx,__si); end; end;"
                      "else if abbrev('FMTLIST',__fmt,3)>0 then do; buffer.0='ARRAY '__sx; call fmtlist ,,vtoc.hdr; end; "
                      "else call s2stem(__sx,'vtoc.'); call sfree(__sx); return");
    } else if (strcmp((const char *) LSTR(rxf->name), "TSTCAT") == 0) {
        RxPreLoad(rxf,"TSTCAT: trace off; parse upper arg __dsn,__vol; if listdsiq(__dsn)<>0 then return 16; if sysvolume==__vol then return 0; return 8;");
    } else if (strcmp((const char *) LSTR(rxf->name), "LISTDSIX") == 0) {
        RxPreLoad(rxf,"LISTDSIX: trace off; if listdsi(arg(1))<>0 then return 8; __sx=__exvtoc(sysvolume,'BEGINNING('sysdsname') ENDING('sysdsname') NOHEADING');"
                      "if __sx <0 then return -16; __lmax=sarray(__sx); __ssi=ssearch(__sx,sysdsname' '); if __ssi=0 then signal __nodsn;"
                      "systracks=__subs(2,6); sysntracks=__subs(9,6); sysextents=__subs(20,3);sysdsorgx=__subs(24,4);"
                      "sysrecfmx=__subs(30,4);syslreclx=__subs(43,5);sysblksizex=__subs(36,5);syscreate =__subs(48,5); sysrefdate=__subs(54,5); "
                      "sysseqalc =__subs(113,4); sysunits  =__subs(120,1); if substr(sysrecfm,1,1)='?' then sysrecfm=sysrecfmx;"
                      "if SYSunits='C' then SYSunits='CYLINDERS'; else if SYSunits='T' then SYSunits='TRACKS'; else if SYSunits='B' then SYSunits='BLOCKS';"
                      "__nodsn: call sfree(__sx); return 0;"
                      "__subs: return strip(substr(sget(__sx,__ssi),arg(1),arg(2)))");
    } else if (strstr((const char *) LSTR(rxf->name), "__") !=NULL) {
        if (RxPreLoadTemp(rxf,&rxf->name) > 0) return FALSE;
    } else return FALSE;
    return TRUE;
}
