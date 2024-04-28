#define __REXX_C__

#include <string.h>
#include <setjmp.h>
#include <time.h>

#include "lerror.h"
#include "lstring.h"

#include "rexx.h"
#include "stack.h"
#include "trace.h"
#include "bintree.h"
#include "compile.h"
#include "interpre.h"
#include "nextsymb.h"
#include "preload.h"
#include "rxmvsext.h"
#include "smf.h"

#ifdef JCC
#include <io.h>
#endif

#ifdef __CROSS__
#include "jccdummy.h"
#endif

/* ----------- Function prototypes ------------ */
void	__CDECL Rerror(const int,const int,...);
void    __CDECL RxInitFiles(void);
void    __CDECL RxDoneFiles(void);
void	__CDECL RxRegFunctionDone(void);

void    __CDECL RxFileLoadDDN(RxFile *rxf, const char *ddn);
void    __CDECL RxFileLoadDSN(RxFile *rxf);
void    __CDECL RxFileDCB(RxFile *rxf);

/* ----------- External variables ------------- */
extern Lstr	errmsg;
extern Lstr	LTMP[16];
#ifdef JCC
extern char* _style;
#endif

int getRandomId();

/* ---------------- RxInitProc ---------------- */
static void
RxInitProc( void )
{
    _rx_proc = -1;
    _proc_size = PROC_INC;
    _proc = (RxProc*) MALLOC( _proc_size * sizeof(RxProc), "RxProc" );
    MEMSET(_proc,0,_proc_size*sizeof(RxProc));
} /* RxInitProc */

/* ----------------- RxInitialize ----------------- */
void __CDECL
RxInitialize( char *prorgram_name )
{
    int ii;
    Lstr	str;

    _prgname = prorgram_name;

    LINITSTR(str);

    /* do the basic initialisation */
    Linit(Rerror);		/* initialise with Lstderr as error function */

    LINITSTR(symbolstr);
    Lfx(&symbolstr,250);	/* create symbol string */

    LINITSTR(errmsg);
    Lfx(&errmsg,250);	/* create error message string */

    for (ii=0; ii<16; ii++) {
        char sValue[6];
        LINITSTR(LTMP[ii]);
        Lscpy(&LTMP[ii]," ");
    }

    /* --- first locate configuration file --- */
    /* rexx.rc for DOS in the executable program directory */
    /* .rexxrc for unix in the HOME directory */

    _procidcnt = 1;		/* Program id counter	*/

    DQINIT(rxStackList);	/* initialise stacks	*/
    CreateStack();		/* create first stack	*/
    rxFileList = NULL;	/* intialise rexx files	*/
    LPMALLOC(_code);
    CompileClause = NULL;

    RxInitProc();		/* initialize prg list	*/
    RxInitInterpret();	/* initialise interpreter*/
    RxInitFiles();		/* initialise files	*/
    RxInitVariables();	/* initialise hash table for variables	*/

    BINTREEINIT(_labels);	/* initialise labels	*/
    BINTREEINIT(rxLitterals);	/* initialise litterals	*/

    Lscpy(&str,"HALT");    haltStr     = _Add2Lits( &str, FALSE );
    Lscpy(&str,"1");	    oneStr      = _Add2Lits( &str, FALSE );
    Lscpy(&str,"");		nullStr     = _Add2Lits( &str, FALSE );
    Lscpy(&str,"0");	    zeroStr     = _Add2Lits( &str, FALSE );
    Lscpy(&str,"ERROR");	errorStr    = _Add2Lits( &str, FALSE );
    Lscpy(&str,"RESULT");	resultStr   = _Add2Lits( &str, FALSE );
    Lscpy(&str,"NOVALUE");	noValueStr  = _Add2Lits( &str, FALSE );
    Lscpy(&str,"NOTREADY");notReadyStr = _Add2Lits( &str, FALSE );
    Lscpy(&str,"SIGL");	siglStr     = _Add2Lits( &str, FALSE );
    Lscpy(&str,"RC");	    RCStr       = _Add2Lits( &str, FALSE );
    Lscpy(&str,"SYNTAX");	syntaxStr   = _Add2Lits( &str, FALSE );
    Lscpy(&str,"SYSTEM");	systemStr   = _Add2Lits( &str, FALSE );
    Lscpy(&str,"MVS");	    mvsStr      = _Add2Lits( &str, FALSE );
    Lscpy(&str,"TSO");	    tsoStr      = _Add2Lits( &str, FALSE );
    Lscpy(&str,"LINK");	linkStr     = _Add2Lits( &str, FALSE );
    Lscpy(&str,"LINKPGM");	linkpgmStr  = _Add2Lits( &str, FALSE );
    Lscpy(&str,"LINKMVS");	linkmvsStr  = _Add2Lits( &str, FALSE );
    Lscpy(&str,"ISPEXEC");	ispexecStr  = _Add2Lits( &str, FALSE );

    LFREESTR(str);

} /* RxInitialize */

/* ----------------- RxFinalize ----------------- */
void __CDECL
RxFinalize( void )
{
    int ii;
    LFREESTR(symbolstr);	/* delete symbol string	*/
    LFREESTR(errmsg);	/* delete error msg str	*/
    RxDoneInterpret();
    FREE(_proc);		/* free prg list	*/
    while (rxStackList.items>0) DeleteStack();
    LPFREE(_code);	_code = NULL;
    for (ii=0; ii<16; ii++) {
        LFREESTR(LTMP[ii]);
    }

    RxDoneFiles();		/* close all files	*/

        /* will free also nullStr, zeroStr and oneStr	*/
    BinDisposeLeaf(&rxLitterals,rxLitterals.parent,FREE);
    BinDisposeLeaf(&_labels,_labels.parent,FREE);
    RxDoneVariables();
    RxRegFunctionDone();	/* initialise register functions	*/
} /* RxFinalize */

RxFile* __CDECL
RxFileAlloc(char *fname)
{
    RxFile	*rxf;

    rxf = (RxFile*)MALLOC(sizeof(RxFile),"RxFile");
    if (rxf==NULL)
        return rxf;
    MEMSET(rxf,0,sizeof(RxFile));
    Lscpy(&(rxf->name), fname);
    LASCIIZ(rxf->name);

    return rxf;
} /* RxFileAlloc */

/* ----------------- RxFileType ------------------- */
void __CDECL
RxFileType(RxFile *rxf)
{
    unsigned char *c;

    /* find file type */
    c = LSTR(rxf->name)+LLEN(rxf->name);
    for (;c>LSTR(rxf->name) && *c!='.';c--) ;;
    if (*c=='.')
        rxf->filetype = c;
    for (;c>LSTR(rxf->name) && *c!=FILESEP;c--) ;;
    if (c>LSTR(rxf->name))
        c++;
    rxf->filename = c;
} /* RxFileType */

/* ----------------- RxFileFree ------------------- */
void __CDECL
RxFileFree(RxFile *rxf)
{
    RxFile *f;

    while (rxf) {
        f = rxf;
        rxf = rxf->next;
        LFREESTR(f->name);
        LFREESTR(f->file);
        FREE(f);
    }
} /* RxFileFree */

/* ----------------- RxFileLoad ------------------- */

void testfunc(RxFile *rxf,int offset) {
    Lstr tmp1,tmp2;
    int ind,beg=0,end,skip=0;
    LINITSTR(tmp1);
    LINITSTR(tmp2);

    Lfx(&tmp1,LLEN(rxf->file)+256);
    Lfx(&tmp2,LLEN(rxf->file)+256);
//  find beginn of function (BEG), also find end of last statement: IND
    for (ind=offset-1;ind>=0;ind--) {
        if (LSTR(rxf->file)[ind]==';' || LSTR(rxf->file)[ind]=='\n') break;
        if (beg>0) continue;
        if (LSTR(rxf->file)[ind]==' ' || LSTR(rxf->file)[ind]=='=') beg=ind;
    }
    if (beg==0) beg=ind;
// search end of function call (begin of next statement)
    for (end=offset+1;end<LLEN(rxf->file);end++) {
        if (LSTR(rxf->file)[end]==';' || LSTR(rxf->file)[end]=='\n') break;
    }
// isolate function call, start with the plain function name, setting of a variable will be dropped
    _Lsubstr(&tmp1,&rxf->file,beg+1+1,end-beg-1);
    Lupper(&tmp1);
 // check if it is an registered function, else return
    if ((int) strstr(LSTR(tmp1),"ARGIN#(") > 0) ;
    else if ((int) strstr((const char *) LSTR(tmp1), "XXXX#?(") > 0) ;
    else return;
//  drop #sign of the function
    for (offset=LLEN(tmp1)-1;offset>=0;offset--) {
        if (skip == 0) { 
           if (LSTR(tmp1)[offset] == '#') skip = offset;
        }  else LSTR(tmp1)[offset+1]=LSTR(tmp1)[offset];
    }
    LSTR(tmp1)[0]=' ';
// build new function call, must start with a call statement, else the RETURN variable is not set
    Lscpy(&tmp2,"\n CALL");
    Lcat(&tmp2,LSTR(tmp1));
// expand function call with an INTERPRET RESULT, to activate the provided set statements (VLIST)
    Lcat(&tmp2,"\n interpret RESULT \n");
// build new rxf>file conmtent, by extracting part prior to function call, then add new build function call, and the remaining part
    _Lsubstr(&tmp1,&rxf->file,1,ind);
    Lcat(&tmp1, LSTR(tmp2));
    _Lsubstr(&tmp2,&rxf->file,end+1,0);
    Lcat(&tmp1, LSTR(tmp2));
// finally move it back to rx->file variable
    Lstrcpy(&rxf->file,&tmp1);
// cleanup
    LFREESTR(tmp1);
    LFREESTR(tmp2);
}
int __CDECL
RxFileLoad(RxFile *rxf, bool loadLibrary)
{
    /*
     * search path for "ur" rexx  script:
     *
     * => DD, SYSUEXEC, SYSUPROC, SYSEXEC, SYSPROC, DSN
     */
    if (loadLibrary == FALSE) {				/* try to load the "ur" script */
        /* try to load via ddn */
        RxFileLoadDDN(rxf, NULL);

        /* try to load from SYSUEXEC */
        RxFileLoadDDN(rxf, "SYSUEXEC");

        /* try to load from SYSUPROC */
        RxFileLoadDDN(rxf, "SYSUPROC");

        /* try to load from SYSEXEC */
        RxFileLoadDDN(rxf, "SYSEXEC");

        /* try to load from SYSPROC */
        RxFileLoadDDN(rxf, "SYSPROC");

        /* try load via dsn */
        RxFileLoadDSN(rxf);
    } else {
        if (RxPreLoaded(rxf)) return TRUE;     /* internal functions written in BREXX? */

        /* try to load from RXLIB */
        RxFileLoadDDN(rxf, "RXLIB");

        /* try to load from "ur" script location (DD) */
        RxFileLoadDDN(rxf, rxf->ddn);

        /* try to load from "ur" script location (DSN) */
        RxFileLoadDSN(rxf);
    }

    if (rxf->fp != NULL) {
        int offset=0;
        Lread(rxf->fp,&(rxf->file), LREADFILE);
        RxFileDCB(rxf);
        FCLOSE(rxf->fp);
        offset= (int) strstr(LSTR(rxf->file),"#(");
        if (offset>0) {
           Lstr needle;
           LINITSTR(needle);
           Lfx(&needle,16);	/* create symbol string */
           Lscpy(&needle,"#(");
            offset=Lpos(&needle,&rxf->file,0);
            while (offset != 0) {
                testfunc(rxf, offset);
                offset=Lpos(&needle,&rxf->file,offset+3);
            }
            LFREESTR(needle);
        }
        return TRUE;
    } else {
        if (RxLoadRX(rxf)) return TRUE;   // try to load a stem/array rexx stored in a global
        return FALSE;
    }
} /* RxFileLoad */

/* ------------ RxFileDCB ------------ */
void RxFileDCB(RxFile *rxf)
{
    char ddn[9];
    char dsn[45];
    char member[9];
    char serial[7];
    unsigned char flags[11];

    __get_ddndsnmemb(fileno(rxf->fp), ddn, dsn, member, serial, flags);

    strcpy(rxf->ddn, ddn);
    strcpy(rxf->dsn, dsn);
    strcpy(rxf->member, member);

#ifdef __DEBUG1__
    fprintf(STDOUT,"DBG> name  : %s\n",   LSTR(rxf->name));
    fprintf(STDOUT,"DBG> ddn   : %s\n",   rxf->ddn);
    fprintf(STDOUT,"DBG> dsn   : %s\n",   rxf->dsn);
    fprintf(STDOUT,"DBG> member: %s\n\n", rxf->member);
#endif
} /* RxFileDCB */

/* ------------ RxFileLoadDSN ------------ */
void __CDECL RxFileLoadDSN(RxFile *rxf)
{
    char* _style_old = _style;
    int isdsn = 0;

    Lupper(&(rxf->name));
    Lupper(&(rxFileList->name));

    if (rxf->fp == NULL) {
        const char *lastName = (const char *) LSTR(rxFileList->name);
        const char *currentNamme = (const char *) LSTR(rxf->name);

        if((*rxFileList->dsn == '\0' && *rxf->dsn == '\0')  /* no dsn set means try loading the initial script */
           ||
           (strcmp(lastName, currentNamme) != 0)) {         /* do not load same member from the same po */
        #ifndef __CROSS__
           char finalName[60] = "";    // Clear Memory to avoid unwanted characters in file name pej/mig 3.May 20
        #else
           char finalName[255] = "";   // Clear Memory and increase length on PC side to 255 length pej/mig 3.May 20
        #endif
            if ((int) strstr(LSTR(rxf->name),".")>0) isdsn=1;
            else if (strlen(LSTR(rxf->name))>8) isdsn=1;

            if (strlen(rxf->dsn) > 0 && isdsn==0) {
              snprintf(finalName, 54, "%s%c%s%c", rxf->dsn, '(', LSTR(rxf->name), ')');
           } else {
           #ifndef __CROSS__
              snprintf(finalName, 54, "%s", LSTR(rxf->name));
           #else
              snprintf(finalName, 250, "%s", LSTR(rxf->name));
           #endif
            }

            _style = "//DSN:";
            rxf->fp = FOPEN(finalName, "r");

            writeLoadRecord(&finalName[0], TRUE, rxf->fp != NULL);
        }
    }

    _style = _style_old;
} /* RxFileLoadDSN */

/* ------------ RxFileLoadDDN ------------ */
void __CDECL RxFileLoadDDN(RxFile *rxf, const char *ddn)
{
    if (rxf->fp == NULL) {
        char finalName[20];
        char* _style_old = _style;

        if (ddn != NULL) {
            snprintf(finalName, 18, "%s%c%s%c", ddn, '(', LSTR(rxf->name), ')');
        } else {
            snprintf(finalName, 18, "%s", LSTR(rxf->name));
        }

        _style = "//DDN:";
        rxf->fp = FOPEN(finalName, "r");

        if (rxf->fp != NULL &&ddn != NULL) {
           strcpy(rxf->ddn, ddn);
        }

        writeLoadRecord(&finalName[0], FALSE, rxf->fp != NULL);

        _style = _style_old;
    }
} /* RxFileLoadDDN */

/* --- _LoadRexxLibrary --- */
static jmp_buf	old_trap;
static int
_LoadRexxLibrary(RxFile *rxf)
{
    size_t	ip;
    int rc = 0;

    if (RxFileLoad(rxf, TRUE)) {
        /* add return instruction for safety */
        strcat((char *)LSTR(rxf->file),"\nreturn 0");
        rxf->file.len = rxf->file.len + 9;

        ip = (size_t)((byte huge *)Rxcip - (byte huge *)Rxcodestart);
        MEMCPY(old_trap,_error_trap,sizeof(_error_trap));
        RxFileType(rxf);

        if (*rxf->member != '\0') {
            rxf->filename = rxf->member;
        } else {
            rxf->filename = "-BREXX/370-";
        }

        RxInitCompile(rxf,NULL);
        RxCompile();
        /* restore state */
        MEMCPY(_error_trap,old_trap,sizeof(_error_trap));
        Rxcodestart = (CIPTYPE*)LSTR(*_code);
        Rxcip = (CIPTYPE*)((byte huge *)Rxcodestart + ip);
        if (rxReturnCode) {
            RxSignalCondition(SC_SYNTAX,"");
        }
        rc = 0;
    } else {
        rc=  1;
    }

    return rc;
} /* _LoadRexxLibrary */

/* ----------------- RxLoadLibrary ------------------- */
int __CDECL
RxLoadLibrary( PLstr libname, bool shared )
{
    RxFile  *rxf, *last;

    /* Convert to ASCIIZ */
    L2STR(libname); LASCIIZ(*libname);

    if (_proc[_rx_proc].trace & (member_trace)) {
        fprintf(STDERR,"     +++ try loading %s +++\n", LSTR(*libname));
    }

    /* check to see if it is already loaded */
    for (rxf = rxFileList; rxf != NULL; rxf = rxf->next)
        if (!strcmp(rxf->filename,(char *)LSTR(*libname)))
            return -1;

    /* create  a RxFile structure */
    rxf = RxFileAlloc((char *)LSTR(*libname));
    strcpy(rxf->dsn, rxFileList->dsn);
    strcpy(rxf->ddn, rxFileList->ddn);

    /* try to load the file as rexx library */
    if (_LoadRexxLibrary(rxf)) {
        RxFileFree(rxf);
        return 1;
    }

LIB_LOADED:

    /* find the last in the queue */
    for (last = rxFileList; last->next != NULL; )
        last = last->next;
    last->next = rxf;
    return 0;
} /* RxLoadLibrary */

/* ----------------- RxRun ------------------ */
int __CDECL
RxRun( PLstr filename, PLstr programstr,
    PLstr arguments, PLstr tracestr)
{
    RxProc	*pr;

    /* --- set exit jmp position --- */
    if ((setjmp(_exit_trap))!=0)
        goto run_exit;
    /* --- set temporary error trap --- */
    if (setjmp(_error_trap)!=0)
        return rxReturnCode;

    /* ====== first load the file ====== */
    if (LSTR(*filename)) {
        rxFileList = RxFileAlloc((char *)LSTR(*filename));

        /* --- Load file --- */
        if (!RxFileLoad(rxFileList, FALSE)) {
            fprintf(STDERR,"Error %d running \"%s\": File not found\n",
                    ERR_FILE_NOT_FOUND, LSTR(rxFileList->name));

            RxFileFree(rxFileList);
            return 1;
        }
    } else {
        rxFileList = RxFileAlloc("<STDIN>");
        Lfx(&(rxFileList->file), LLEN(*programstr));
        Lstrcpy(&(rxFileList->file), programstr);
    }
    RxFileType(rxFileList);
    LASCIIZ(rxFileList->file);

#ifdef __DEBUG__
    if (__debug__) {
        printf("File is:\n%s\n",LSTR(rxFileList->file));
        getchar();
    }
#endif

    /* ====== setup procedure ====== */
    _rx_proc++;		/* increase program items	*/
    pr = _proc+_rx_proc;	/* pr = Proc pointer		*/

    /* set program id counter */
    pr->id = _procidcnt++;

    /* --- initialise Proc structure --- */
                /* arguments...		*/
    pr->arg.n = 0;
    // FOO
    /*
    for (i=0; i<MAXARGS; i++) {
        if (LLEN(arguments[i])) {
            pr->arg.n = i+1;
            pr->arg.a[i] = &(arguments[i]);
        } else
            pr->arg.a[i] = NULL;
    }*/

    if (LLEN(*arguments) > 0) {
        pr->arg.n = 1;
        pr->arg.a[0] = arguments;
    }

    pr->arg.r = NULL;

    pr->calltype = CT_PROGRAM;	/* call type...		*/
    pr->ip = 0;			/* procedure ip		*/
    pr->stack = -1;		/* prg stck, will be set in interpret	*/
    pr->stacktop = -1;		/* no arguments		*/

    pr->scope = RxScopeMalloc();
    LPMALLOC(pr->env);
    if (isTSO())
        Lstrcpy(pr->env,&(tsoStr->key));
    else
        Lstrcpy(pr->env,&(mvsStr->key));
    pr->digits = LMAXNUMERICDIGITS;
    pr->fuzz = 0;
    pr->form = SCIENTIFIC;
    pr->condition = 0;
    pr->lbl_error    = &(errorStr->key);
    pr->lbl_halt     = &(haltStr->key);
    pr->lbl_novalue  = &(noValueStr->key);
    pr->lbl_notready = &(notReadyStr->key);
    pr->lbl_syntax   = &(syntaxStr->key);
    pr->codelen = 0;
    pr->trace = normal_trace;
    pr->interactive_trace = FALSE;
    if (tracestr && LLEN(*tracestr)) TraceSet(tracestr);

    /* rxFileList->filename = "-BREXXX370-"; */
    if (*rxFileList->member != '\0') {
        rxFileList->filename = "#";
        strcat(rxFileList->filename,rxFileList->member);
    } else {
        rxFileList->filename = "-BREXX/370-";
    }

    /* ======= Compile file ====== */
    RxInitCompile(rxFileList,NULL);
    RxCompile();

#ifdef __DEBUG__
    if (__debug__) {
        printf("Literals are:\n");
        //BinPrint(rxLitterals.parent, NULL);
        getchar();

        printf("Labels(&functions) are:\n");
        //BinPrint(_labels.parent, NULL);
        printf("Code Size: %zd\n\n",LLEN(*_code));
        getchar();
    }
#endif

    /* ======= Execute code ======== */
    if (!rxReturnCode)
        RxInterpret();

run_exit:
    /* pr pointer might have changed if Proc was resized */
    pr = _proc+_rx_proc;
#ifdef __DEBUG__
    if (__debug__)
        printf("Return Code = %d\n",rxReturnCode);
#endif

    /* ======== free up memory ======== */
    RxFileFree(rxFileList);
    LPFREE(pr->env);
    if (CompileClause) {
        FREE(CompileClause);
        CompileClause = NULL;
    }
    RxScopeFree(pr->scope);
    FREE(pr->scope);
    _rx_proc--;

    return rxReturnCode;
} /* RxRun */
