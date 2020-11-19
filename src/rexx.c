#define __REXX_C__

#include <string.h>
#include <setjmp.h>

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
#ifdef JCC
#include <io.h>
#endif

/* ----------- Function prototypes ------------ */
void	__CDECL Rerror(const int,const int,...);
void    __CDECL RxInitFiles(void);
void    __CDECL RxDoneFiles(void);
void	__CDECL RxRegFunctionDone(void);

void    __CDECL RxFileLoadDDN(RxFile *rxf, const char *ddn);
void    __CDECL RxFileLoadDSN(RxFile *rxf);
void    __CDECL RxFileDCB(RxFile *rxf);

#ifdef __CROSS__
#include "jccdummy.h"
#endif

/* ----------- External variables ------------- */
extern Lstr	errmsg;
#ifdef JCC
extern char* _style;
#endif


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
    Lstr	str;

    _prgname = prorgram_name;

    LINITSTR(str);

    /* do the basic initialisation */
    Linit(Rerror);		/* initialise with Lstderr as error function */

    LINITSTR(symbolstr);
    Lfx(&symbolstr,250);	/* create symbol string */

    LINITSTR(errmsg);
    Lfx(&errmsg,250);	/* create error message string */

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
    Lscpy(&str,"TSO");	    tsoStr      = _Add2Lits( &str, FALSE );
    Lscpy(&str,"LINK");	linkStr     = _Add2Lits( &str, FALSE );
    Lscpy(&str,"LINKPGM");	linkpgmStr  = _Add2Lits( &str, FALSE );
    Lscpy(&str,"LINKMVS");	linkmvsStr  = _Add2Lits( &str, FALSE );
    Lscpy(&str,"SYSTEM");	systemStr   = _Add2Lits( &str, FALSE );
    Lscpy(&str,"ISPEXEC");	ispexecStr  = _Add2Lits( &str, FALSE );

    LFREESTR(str);
} /* RxInitialize */

/* ----------------- RxFinalize ----------------- */
void __CDECL
RxFinalize( void )
{
    LFREESTR(symbolstr);	/* delete symbol string	*/
    LFREESTR(errmsg);	/* delete error msg str	*/
    RxDoneInterpret();
    FREE(_proc);		/* free prg list	*/
    while (rxStackList.items>0) DeleteStack();
    LPFREE(_code);	_code = NULL;

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
        /* try to load from "ur" script location */
        RxFileLoadDSN(rxf);
    }

    if (rxf->fp != NULL) {
        Lread(rxf->fp,&(rxf->file), LREADFILE);
        RxFileDCB(rxf);
        FCLOSE(rxf->fp);

        return TRUE;
    } else {
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
    int isdsn;

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

        /* rxf->filename = "-BREXXX370-"; */
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
            RxSignalCondition(SC_SYNTAX);
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

    /* check to see if it is already loaded */
    for (rxf = rxFileList; rxf != NULL; rxf = rxf->next)
        if (!strcmp(rxf->filename,(char *)LSTR(*libname)))
            return -1;

    /* create  a RxFile structure */
    rxf = RxFileAlloc((char *)LSTR(*libname));
    strcpy(rxf->dsn, rxFileList->dsn);

    rxf->libHandle = NULL;
    if (rxf->libHandle!=NULL) {
        /* load the main function and execute it...*/
        RxFileType(rxf);
        goto LIB_LOADED;
    }

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
    int	i;

    /* --- set exit jmp position --- */
    if ((i=setjmp(_exit_trap))!=0)
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
        Lstrcpy(pr->env,&(systemStr->key));
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

#ifdef __CROSS__
int __getdcb  (int h, unsigned char  * dsorg,
               unsigned char  * recfm,
               unsigned char  * keylen,
               unsigned short * lrecl,
               unsigned short * blksize) {

    int rc = 0;

    *dsorg      = 0x40;
    *recfm      = 0x90;
    *keylen     = 0xff;
    *lrecl      = 80;
    *blksize    = 32000;

    return rc;
}

int __get_ddndsnmemb (int handle, char * ddn,
                      char * dsn,
                      char * member,
                      char * serial,
                      unsigned char * flags) {
    int rc = 0;

    strcpy(ddn, "");
    strcpy(dsn, "");
    strcpy(member, "");

    return rc;
}
#endif
