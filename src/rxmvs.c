#include <stdlib.h>
#include <strings.h>
#include <stdio.h>
#include <errno.h>
#include <time.h>
#include <hashmap.h>
#include <rxtso.h>
#include <mvs/mtt.h>
#include <mvs/apf.h>
#include <mvs/wto.h>
#include <mvs/crt.h>
#include "irx.h"
#include "rexx.h"
#include "rxdefs.h"
#include "rxmvsext.h"
#include "util.h"
#include "stack.h"
#include "math.h"

#include "rxtcp.h"
#include "rxnje.h"
#include "rxll.h"
#include "rxarray.h"
#include "rxmatrix.h"
#include "rxiarray.h"
#include "rxdsn.h"
#include "rxrac.h"
#include "rxregex.h"

#include "dynit.h"
#include "rac.h"
#include "dsio.h"
#include "sarray.h"
#ifdef __DEBUG__
#include "bmem.h"
#endif

/* FLAG2 */
const unsigned char _TSOFG  = 0x01; // hex for 0000 0001
const unsigned char _TSOBG  = 0x02; // hex for 0000 0010
const unsigned char _EXEC   = 0x04; // hex for 0000 0100
const unsigned char _ISPF   = 0x08; // hex for 0000 1000
/* FLAG3 */
const unsigned char _STDIN  = 0x01; // hex for 0000 0001
const unsigned char _STDOUT = 0x02; // hex for 0000 0010
const unsigned char _STDERR = 0x04; // hex for 0000 0100

RX_ENVIRONMENT_BLK_PTR env_block   = NULL;
RX_ENVIRONMENT_CTX_PTR environment = NULL;
RX_OUTTRAP_CTX_PTR     outtrapCtx  = NULL;
RX_ARRAYGEN_CTX_PTR    arraygenCtx = NULL;

extern char SignalCondition[64];     // Signal condition used in CONDITION()
extern int  TrappedCnd;      // its SC_ bit, for CONDITION('S')
extern int  TrapByCall;      // trapped by CALL ON, for CONDITION('I')
extern char SignalLine[64];
extern Lstr LTMP[16];

// TODO: must be moved into the environment context
HashMap *globalVariables;
static char savedEntry[81];    // keeps the first (most current) Trace Table entry




#ifdef __CROSS__
# include "jccdummy.h"
#endif

//
//  INTERNAL FUNCTION PROTOTYPES
//
int reopen(int fp);

void Lcryptall(PLstr to, PLstr from, PLstr pw, int rounds,int mode);
int _EncryptString(const PLstr to, const PLstr from, const PLstr password);
void _rotate(PLstr to, const Lstr *from, int start, int slen);
void Lhash(const PLstr to, const Lstr *from, long slots) ;

#define DEFAULT_NUM_SUBCMD_ENTRIES 10

#define DEFAULT_LENGTH_SUBCMD_ENTRIE 32

/* ------------------------------------------------------------------------------------------------------------------ */



// TODO: new home needed for this stuff - used in R_dattimbase
/* ------------------------------------------------------------------------------------------------------------------ */
static char *months[] = {
        TEXT("January"), TEXT("February"), TEXT("March"),
        TEXT("April"), TEXT("May"), TEXT("June"),
        TEXT("July"), TEXT("August"), TEXT("September"),
        TEXT("October"), TEXT("November"), TEXT("December") };

/* 1..12 for a month name's first three letters, 0 for none */
static int monthOf(const char *name) {
    for (int m = 0; m < 12; ++m) {
        if (strncasecmp(months[m], name, 3) == 0) return m + 1;
    }
    return 0;
}

int parseParm(PLstr parm,int parmi[10],int pmax,int from) {
    int wrds;
    Lstr word;
    LINITSTR(word);
    Lfx(&word,16);
    Lscpy(&word,",:.;/-");
    Lfilter(parm,parm,&word,'B');
    wrds=Lwords(parm);
    parmi[0]=0;

    /* parmi has 10 entries: pmax 10 wrote parmi[10], beside it */
    for (int i = from; i <= pmax && i < 10; ++i) {
        if (wrds < i) {
            parmi[i]=0;
            continue;
        }
        Lword(&word, parm, i);
        LASCIIZ(word);
        if (_Lisnum(&word) == LINTEGER_TY) {
            parmi[i] = lLastScannedNumber;
            continue;
        }
        parmi[i] = monthOf((const char *) LSTR(word));
        if (parmi[i] == 0) {
            printf("invalid date part: %s within %s\n", LSTR(word), LSTR(*parm));
            Lerror(ERR_INCORRECT_CALL, 0);
        }
    }
    LFREESTR(word);

    return 0;
}

/* DATTIMBASE 'B': the timestamp t as ctime() formats it, without its
 * newline ("Wed Dec  9 07:40:45 2020"). ctime() is not reentrant and
 * libc370 has no ctime_r(); localtime_r() and the format of its
 * asctime() give the same text. */
static void baseTimeStamp(PLstr to, long t)
{
    static const char wday[7][4] = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" };
    static const char mon[12][4] = { "Jan", "Feb", "Mar", "Apr", "May", "Jun",
                                     "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" };
    time_t    tt = (time_t) t;
    struct tm tmv;

    Lfx(to, 32);
    if (localtime_r(&tt, &tmv) == NULL) {
        LZEROSTR(*to);
        return;
    }
    snprintf((char *) LSTR(*to), LMAXLEN(*to), "%.3s %.3s%3d %.2d:%.2d:%.2d %d",
             wday[tmv.tm_wday], mon[tmv.tm_mon], tmv.tm_mday,
             tmv.tm_hour, tmv.tm_min, tmv.tm_sec, 1900 + tmv.tm_year);
}

/* DATTIMBASE 'T': a date in format imod as seconds since 1970 */
static int toTimestamp(PLstr indate, char imod)
{
    int a;
    int m;
    int y;
    int yy;
    int mm;
    int dd;
    int dnum;
    int parmi[10];

    if (imod=='B') parseParm(indate, parmi, 9,2);     // Parse base date string into single parms from word 2
    else parseParm(indate, parmi, 9,1);        // Parse date string into single parms
    switch (imod) {
        case 'O':   // yyyy mm dd hour min sec
            yy = parmi[1];
            mm = parmi[2];
            dd = parmi[3];
            break;
        case 'E':   // dd mm yyyy hour min sec
            yy = parmi[3];
            mm = parmi[2];
            dd = parmi[1];
            break;
        case 'U':   // mm dd yyyy hour min sec
            yy = parmi[3];
            mm = parmi[1];
            dd = parmi[2];
            break;
        case 'B':   // Base Time Stamp: Wed Dec 09 07:40:45 2020
            yy = parmi[7];
            if (yy<100) yy=yy+2000;
            mm = parmi[2];
            dd = parmi[3];
            break;
        default:
            Lfailure("invalid input format:",&imod,"","","");
            return 0;
    }
    a = (14 - mm) / 12;
    m = mm + 12 * a - 3;
    y = yy + 4800 - a;
    dnum = dd + (153 * m + 2) / 5 + 365 * y;
    dnum = dnum + y / 4 - y / 100 + y / 400 - 32045;
    return ((dnum - 2440588) * 86400 + parmi[4] * 3600 + parmi[5] * 60 + parmi[6]);
}

void datetimebase(PLstr to, char omod,PLstr indate,char imod) {
    if (imod=='T' && omod=='B')  {
        /* Lrdint(), not L2INT(): that converted the caller's argument */
        baseTimeStamp(to, Lrdint(indate));
    } else if (omod=='T')  {
        int seconds;

        if (indate==NULL || LLEN(*indate)==0) seconds = (int) time(0);
        else seconds = toTimestamp(indate, imod);
        Lfx(to, 16);            /* the time(0) case wrote without room */
        snprintf((char *) LSTR(*to), LMAXLEN(*to), "%d", seconds);
    } else Lfailure("invalid output format:",&omod,"","","");

    LTYPE(*to) = LSTRING_TY;
    LLEN(*to) = strlen(LSTR(*to));
}
/* ------------------------------------------------------------------------------------------------------------------ */

// TODO: new home needed for this stuff - used in R_outtrap
/* ------------------------------------------------------------------------------------------------------------------ */
void droplf(char *s)
{
    s[strcspn(s, "\n")] = '\0';      /* cut at the first linefeed, if any */
}

int get2variables(const Lstr *vname1, const Lstr *ddn, int maxrecs, __unused int concat, int skipamt)
{
    unsigned char pbuff[4098];
    char vname2[256];       /* 19 bytes held the caller's stem name */
    char vname3[19];

    int recs = 0;

    FILE *f;

    f = rxOpenDd((const char *) LSTR(*ddn), "r");   /* OUTTRAP's DD (#299) */
    if (f == NULL) {
        return 8;
    }
    recs = 0;
    while (fgets(pbuff, 4096, f)) {
        if (maxrecs > 0 && recs>=maxrecs) break;
        if (skipamt == 0) {
            recs++;
            droplf(&pbuff[0]); // remove linefeed
            snprintf(vname2, sizeof(vname2), "%s%d", (const char*) LSTR(*vname1), recs);  // edited stem name
            setVariable(vname2, pbuff);             // set rexx variable
        } else {
            skipamt--;
        }
    }  // end of while
    snprintf(vname2, sizeof(vname2), "%s0", (const char*) LSTR(*vname1));
    snprintf(vname3, sizeof(vname3), "%d", recs);
    setVariable(vname2, vname3);

    fclose(f);

    return 0;
}
/* ------------------------------------------------------------------------------------------------------------------ */



// TODO: new home needed for this stuff - unsorted yet
/* ------------------------------------------------------------------------------------------------------------------ */
int _EncryptString(const PLstr to, const PLstr from, const PLstr password) {
    int slen;
    int plen;
    int ki;
    int kj;
    L2STR(from);
    L2STR(password);
    slen=LLEN(*from);
    plen=LLEN(*password);
    kj = 0;
    for (ki = 0; ki < slen; ki++) {
        LSTR(*to)[ki] = LSTR(*from)[ki] ^ LSTR(*password)[kj];
        if (++kj >= plen) kj = 0;   /* the password repeats */
    }
    LLEN(*to) = (size_t) slen;
    LTYPE(*to) = LSTRING_TY;
    return slen;
}

// -------------------------------------------------------------------------------------
// Encrypt/Decrypt common Procedure
// -------------------------------------------------------------------------------------
void Lcryptall(PLstr to, PLstr from, PLstr pw, int rounds,int mode) {
    int plen;
    int slen;
    int ki;
    int kj;
    int hashv;
    Lstr pwt;
    L2STR(from);                 // make sure FROM is string
    L2STR(pw);                   // same for password
    slen = LLEN(*from);       // don't use STRLEN, as string may contain '0'x
    if (slen < 1) {              // is string empty? then return null string
        LZEROSTR(*to);
        return;
    }
    // set up temporary result
    Lfx(to, slen);
    Lstrcpy(to, from);
    // init Password definition
    plen = LLEN(*pw);
    if (plen == 0) return;   // no password given, string remains unchanged

    LINITSTR(pwt);
    Lfx(&pwt, plen);

    Lhash(&pwt, pw, 127);
    hashv = LINT(pwt);

    if (mode == 0) {  // encode
        // run through encryption in several rounds
        for (ki = 1; ki <= rounds; ki++) {    // Step 1: XOR String with Password
            for (kj = 0; kj < slen; kj++) {
                LSTR(*to)[kj] = LSTR(*to)[kj] + hashv;
            }
            hashv=(hashv+3)%127;
            _rotate(&pwt, pw, ki, 0);
            slen = _EncryptString(to, to, &pwt);
        }
    } else {    // decode
        hashv=(hashv+3*rounds-3)%127;
        for (ki = rounds; ki >= 1; ki--) {    // Step 1: XOR String with Password
            _rotate(&pwt, pw, ki,0);
            slen = _EncryptString(to, to, &pwt);
            for (kj = 0; kj < slen; kj++) {
                LSTR(*to)[kj]=LSTR(*to)[kj]-hashv;
            }
            hashv=(hashv-3)%127;
        }
    }
    // final settings and cleanup
    LLEN(*to) = (size_t) slen;
    LTYPE(*to) = LSTRING_TY;
    LFREESTR(pwt)
}

// -------------------------------------------------------------------------------------
// Rotate String
// -------------------------------------------------------------------------------------
// Return string at a certain position til it's end and continued substring before starting position
void _rotate(PLstr to, const Lstr *from, int start, int frlen) {
    int slen;
    int rlen;
    int istart=start;
    int flen=frlen;

    slen=LLEN(*from);
    if (slen<1) {                  // is string empty? then return null string
        LZEROSTR(*to);
        return;
    }
    istart=istart%slen;             // if start > string length (re-calculate offset)
    istart--;                       // make start to a offset
    istart=istart%slen;             // if start > string length (re-calculate offset)
    rlen = slen- istart;            // lenght of remaining string
    if (flen==0) flen=slen;
    if (LISNULL(*to)) LINITSTR(*to);
    Lfx(to,slen);
// 1. copy remaining string part
    MEMMOVE( LSTR(*to), LSTR(*from)+istart, (size_t)rlen);
// 2. attach remaining length with string starting from position 1
    if (flen>rlen) MEMMOVE( LSTR(*to)+rlen, LSTR(*from), (size_t)slen-rlen);
    LLEN(*to) = (size_t) flen;
    LTYPE(*to) = LSTRING_TY;
}

// -------------------------------------------------------------------------------------
// RHASH function
// -------------------------------------------------------------------------------------
void Lhash(const PLstr to, const Lstr *from, long slots) {
    int value=0;
    int pcn;
    int pwr;
    int islots=INT32_MAX;
    size_t	lhlen=0;

    if (slots==0) slots=islots; /* maximum slots */

    pcn   = 71;                    /* potentially different Chars   */
    pwr = 1;                       /* Power of ... */

    if (!LISNULL(*from)) {
        switch (LTYPE(*from)) {
            case LINTEGER_TY:
                lhlen = sizeof(long);
                break;
            case LREAL_TY:
                lhlen = sizeof(double);
                break;
            case LSTRING_TY:
                lhlen = LLEN(*from);
                break;
            default:
                break;
        }

        for (int ki = 0; (size_t) ki < lhlen; ki++) {
            value = (value + (LSTR(*from)[ki]) * pwr)%islots;
            pwr = ((pwr * pcn) % islots);
        }
    }
    value=labs(value%slots);
    Licpy(to,labs(value));
}

int updateIOPL (IOPL *iopl)
{

    void **cppl;
    byte *ect;
    byte *upt;

    // this stuf is TSO only, and needs a CPPL (not there under TSO CALL)
    if (!isTSO() || tsoCppl() == NULL) {
        return -1;
    }

    cppl = tsoCppl();
    upt  = cppl[1];
    ect  = cppl[3];

    ((void **)iopl)[0] = upt;
    ((void **)iopl)[1] = ect;

    return 0;
}


/* ------------------------------------------------------------------------------------------------------------------ */

/* ---------------------------------------------------------------------------------------------------------------------
 * Thanks to Mike Carter, who helped with the correct ENQ Flags
 * ENQEXUNC EQU   X'40'  64   01000000     EXCLUSIVE UNCONDITIONAL.
 * ENQEXUSE EQU   X'43'  67   01100111     EXCLUSIVE RET=USE.
 * ENQEXTST EQU   X'47'  71   01110001     EXCLUSIVE RET=TEST.
 * ENQEXCHG EQU   X'42'  66   01000010     SHARED TO EXCLUSIVE.
 * ENQSHUNC EQU   X'C0'  192  11000000     SHARED UNCONDITIONAL.
 * ENQSHUSE EQU   X'C3'  195  11000011     SHARED RET=USE.
 * DEQUNC   EQU   X'41'  65   01000001     NORMAL DEQ(CONDITIONAL)
 * ENQDEQ   EQU   X'40'  64   01000000     NORMAL ENQ/DEQ INDICATION.
 * We use mainly:
 *   EXCLUSIVE mode=67
 *   SHARED    mode=195
 *   TEST      mode=71
 * for DEQ     mode=64
 *
 * ---------------------------------------------------------------------------------------------------------------------
 */
void R_enq(__unused int func)
{
    int inflags;
    RX_ENQ_PARAMS enq_parameter;
    RX_SVC_PARAMS svc_parameter;

    if (ARGN !=2) Lerror(ERR_INCORRECT_CALL, 0);

    LASCIIZ(*ARG1)
    Lupper(ARG_OWN(1));
    get_s(1)
    get_i(2,inflags);

    enq_parameter.flags = 192; // List end Byte always 192 0xC= // 1100 0000
    enq_parameter.params = inflags;
    enq_parameter.rname = (char *) LSTR(*ARG1);
    enq_parameter.rname_length = LLEN(*ARG1);
    enq_parameter.ret = 0;
    enq_parameter.qname = "BREXX370";
    enq_parameter.rname = (char *) LSTR(*ARG1);

    svc_parameter.R1 = (uintptr_t) &enq_parameter;
    svc_parameter.SVC = 56;

    call_rxsvc(&svc_parameter);

    Licpy(ARGR, enq_parameter.ret);
}

/* ---------------------------------------------------------------------------------------------------------------------
 *   DEQ
 * ---------------------------------------------------------------------------------------------------------------------
 */
void R_deq(__unused int func)
{
    int inflags;

    RX_ENQ_PARAMS enq_parameter;
    RX_SVC_PARAMS svc_parameter;

    if (ARGN < 1 || ARGN > 2)  Lerror(ERR_INCORRECT_CALL, 0);

    LASCIIZ(*ARG1)
    Lupper(ARG_OWN(1));
    get_s(1)
    get_i(2,inflags);

    enq_parameter.flags = 192; // 0xC= // 1100 0000
    enq_parameter.rname_length = LLEN(*ARG1);
    enq_parameter.params = inflags; // 0x49 // 0100 1001 / HAVE
    enq_parameter.ret = 0;
    enq_parameter.qname = "BREXX370";
    enq_parameter.rname = (char *) LSTR(*ARG1);

    svc_parameter.R1 = (uintptr_t) &enq_parameter;
    svc_parameter.SVC = 48;

    call_rxsvc(&svc_parameter);

    Licpy(ARGR, enq_parameter.ret);

}

void R_console(__unused int func)
{
    RX_SVC_PARAMS svc_parameter;
    unsigned char cmd[128];

    if (ARGN !=1) Lerror(ERR_INCORRECT_CALL, 0);

    LASCIIZ(*ARG1)
    Lupper(ARG_OWN(1));
    get_s(1)

    privilege(1);
    memset(cmd, 0, sizeof(cmd));
    cmd[1] = 104;

    memset(&cmd[4], 0x40, 124);
    memcpy(&cmd[4], LSTR(*ARG1), LLEN(*ARG1));

    /* SEND COMMAND */
    svc_parameter.R0 = (uintptr_t) 0;
    svc_parameter.R1 = (uintptr_t) &cmd[0];
    svc_parameter.SVC = 34;
    call_rxsvc(&svc_parameter);

    privilege(0);
}

void R_privilege(__unused int func) {
    int rc = 8;


    if (ARGN != 1)
        Lerror(ERR_INCORRECT_CALL, 0);   // then NOP;

    LASCIIZ(*ARG1)
    Lupper(ARG_OWN(1));
    get_s(1)

    if (strcmp((const char *) ARG1->pstr, "ON") == 0) {
        rc = privilege(1);
    } else if (strcmp((const char *) ARG1->pstr, "OFF") == 0) {
        rc = privilege(0);
    }

    Licpy(ARGR, rc);
}

void R_error(__unused int func) {
    if (ARGN != 1)
        Lerror(ERR_INCORRECT_CALL,0);
    LASCIIZ(*ARG1)
    Lupper(ARG_OWN(1));
    get_s(1)
    Lfailure(LSTR(*ARG1),"","","","");
}

void R_getg(__unused int func)
{
    PLstr tmp;

    if (ARGN != 1)
        Lerror(ERR_INCORRECT_CALL,0);

    LASCIIZ(*ARG1)
    Lupper(ARG_OWN(1));
    get_s(1)

    tmp = hashMapGet(globalVariables, (char *) LSTR(*ARG1));

    if (tmp && !LISNULL(*tmp)) {
        Lstrcpy(ARGR, tmp);
    } else {
        LZEROSTR(*ARGR)
    }
}

void R_setg(__unused int func)
{
    PLstr pValue;
    PLstr pOld;

    if (ARGN != 2)
        Lerror(ERR_INCORRECT_CALL,0);

    LASCIIZ(*ARG1)
    Lupper(ARG_OWN(1));
    get_s(1)

    LPMALLOC(pValue)
    Lstrcpy(pValue, ARG2);

    /* the map only swaps the pointer: free the value it replaces (#93) */
    pOld = hashMapGet(globalVariables, (char *) LSTR(*ARG1));
    hashMapSet(globalVariables, (char *) LSTR(*ARG1), pValue);
    if (pOld != NULL) LPFREE(pOld)

    Lstrcpy(ARGR, ARG2);
}

void R_level(__unused int func) {
    int level;
    int nlevel;

    if (ARGN>0) {
        level = (int) Lrdint(ARG1);

        if (level <= 0) {
            nlevel = _rx_proc + level;
            if (nlevel < 0) nlevel = 0;
        } else {
            if (level > _rx_proc) nlevel = _rx_proc;
            else nlevel = level;
        }
        printf("level %d \n",nlevel);

        return ;
    }

    Licpy(ARGR,_rx_proc);
}

/* -------------------------------------------------------------- */
/*  ARG([n[,option]])                                             */
/* -------------------------------------------------------------- */
void R_argv(__unused int func)
{
    int pnum;
    int level;
    int nlevel;
    const RxProc	*pr;

    if (ARGN>1) level = (int)Lrdint(ARG2);
    else level=-1;

    if (level<=0) {
        nlevel = _rx_proc + level;
        if (nlevel < 0) nlevel = 0;
    } else {
        if (level > _rx_proc) nlevel=_rx_proc;
        else nlevel=level;
    }
    pr = &(_proc[nlevel]);

    get_oiv(1, pnum, 0)
    if (pnum==0) {
       Licpy(ARGR, pr->arg.n);
       return;
    }
    if (pnum < 0 || pnum>pr->arg.n) LZEROSTR(*ARGR)   /* ARG(-1) read beside a[] */
    else Lstrcpy(ARGR, pr->arg.a[pnum - 1]);
 } /* R_arg */

/* ------------------------------------------------------------------------------------
 * Pick exactly one CHAR out of a string
 * ------------------------------------------------------------------------------------
 */
void R_char(__unused int func) {
    char pad;
    int cnum;
    Lfx(ARGR,8);
    get_s(1);
    get_i(2,cnum);
    get_pad(3,pad);
    if ((size_t) cnum <= LLEN(*ARG1)) pad=LSTR(*ARG1)[cnum-1];
    Lscpy(ARGR,&pad);
    LLEN(*ARGR)=1;
}

/* ------------------------------------------------------------------------------------
 * DateTime Main function
 * ------------------------------------------------------------------------------------
 */
void R_dattimbase(__unused int func) {
    int dnum = 0;
    char imod;
    char omod;

    if (ARG1==NULL) omod=' ';
    else {
        Lupper(ARG_OWN(1));
        omod=LSTR(*ARG1)[0];
    }

    if (ARG3==NULL) imod=' ';
    else {
        Lupper(ARG_OWN(3));
        imod=LSTR(*ARG3)[0];
    }

    /* an integer argument is no string to scan: _Lisnum() read its bytes */
    if (imod == 'T' && ARG2 != NULL && LTYPE(*ARG2) != LINTEGER_TY &&
        (LTYPE(*ARG2) != LSTRING_TY || _Lisnum(ARG2) != LINTEGER_TY)) {
        L2STR(ARG2);
        Lfailure("invalid Date/in-format combination",LSTR(*ARG2),"/",&imod,"");
    }
    if (imod==omod) {
        if (ARG2==NULL ) dnum=1;
        if (dnum==0 && LLEN(*ARG2)==0) dnum=1;
        if (dnum==1) Lfailure("Empty Date field","","","","");
        if (imod == 'T')  {
            Lstrcpy(ARGR,ARG2);
            return;
        }
        datetimebase(ARGR, 'T', ARG2, imod);
        imod = 'T';
    } else if (ARG2==NULL || LLEN(*ARG2)==0) {
        datetimebase(ARGR, 'T', NULL, 'B');
        if (omod == 'T') return;
        imod = 'T';
    } else Lstrcpy(ARGR,ARG2);

    datetimebase(ARGR,omod, ARGR, imod);
}

void R_outtrap(__unused int func)
{
    int rc =0;

    RX_TSO_PARAMS  tso_parameter;
    void ** cppl;

    __dyn_t dyn_parms;

    if (ARGN < 1 || ARGN > 4) {
        Lerror(ERR_INCORRECT_CALL, 0);
    }

    if (isTSO()!= 1 ||  tsoCppl() == 0) {
        Lerror(ERR_INCORRECT_CALL, 0);
    }

    if (exist(1)) {
        get_s(1);
        LASCIIZ(*ARG1);
    }

    if (exist(2) && LTYPE(*ARG2) == LINTEGER_TY) {
        outtrapCtx->maxLines = LINT(*ARG2);
    }

    if (exist(3)) {
        get_s(3);
        LASCIIZ(*ARG1);
        if (strcasecmp("NOCONCAT", (const char *) LSTR(*ARG3)) == 0) {
            outtrapCtx->concat = FALSE;
        }
    }

    if (exist(4) && LTYPE(*ARG4) == LINTEGER_TY) {
        outtrapCtx->skipAmt = LINT(*ARG4);
        if (outtrapCtx->skipAmt > 999999999) {
            outtrapCtx->skipAmt = 999999999;
        }
    }

    cppl = tsoCppl();

    memset(&tso_parameter, 00, sizeof(RX_TSO_PARAMS));
    tso_parameter.cppladdr = (unsigned int *) cppl;

    if (strcasecmp("OFF", (const char *) LSTR(*ARG1)) != 0) {
        // remember variable name
            Lstrcpy(&outtrapCtx->varName, ARG1);   // reuses the buffer of the last call

        dyninit(&dyn_parms);
        dyn_parms.__ddname    = (char *) LSTR(outtrapCtx->ddName);
        dyn_parms.__status    = __DISP_NEW;
        dyn_parms.__unit      = "VIO";
        dyn_parms.__dsorg     = __DSORG_PS;
        dyn_parms.__recfm     = _FB_;
        dyn_parms.__lrecl     = 133;
        dyn_parms.__blksize   = 13300;
        dyn_parms.__alcunit   = __TRK;
        dyn_parms.__primary   = 5;
        dyn_parms.__secondary = 5;

        rc = dynalloc(&dyn_parms);

        strcpy(tso_parameter.ddout, (const char *) LSTR(outtrapCtx->ddName));

        rc = call_rxtso(&tso_parameter);

    } else {
        rc = call_rxtso(&tso_parameter);

        rc = get2variables(&outtrapCtx->varName, &outtrapCtx->ddName,
                           outtrapCtx->maxLines, outtrapCtx->concat,
                           outtrapCtx->skipAmt);

        dyninit(&dyn_parms);
        dyn_parms.__ddname = (char *) LSTR(outtrapCtx->ddName);
        rc = dynfree(&dyn_parms);
    }

    Licpy(ARGR, rc);
}

void R_dumpIt(__unused int func)
{
    void *ptr  = 0;
    int   size = 0;
    long  adr  = 0;

    if (ARGN > 2 || ARGN < 1) {
        Lerror(ERR_INCORRECT_CALL,0);
    }

    if (ARGN != 1) {         /* one argument: nothing to dump */
        Lx2d(ARGR,ARG1,0);    /* using ARGR as temp field for conversion */
        adr = Lrdint(ARGR);
        if (adr < 0) {
            Lerror(ERR_INCORRECT_CALL, 0);
        }

        ptr = (void *)adr;
        size = Lrdint(ARG2);
    }



    DumpHex((unsigned char *)ptr, size);
}

void R_wto(__unused int func)
{
    if (ARGN != 1)
        Lerror(ERR_INCORRECT_CALL,0);

    LASCIIZ(*ARG1);
    get_s(1);

    wto((char *)LSTR(*ARG1));

    LICPY(*ARGR, 0);
}

void R_listIt(__unused int func)
{
    BinTree tree;
    if (ARGN > 1 ) {
        Lstr lsFuncName;
        Lstr lsMaxArg;

        LINITSTR(lsFuncName)
        LINITSTR(lsMaxArg)

        Lfx(&lsFuncName,6);
        Lfx(&lsMaxArg, 4);

        Lscpy(&lsFuncName, "ListIT");
        Licpy(&lsMaxArg,1);

        Lerror(ERR_INCORRECT_CALL,4,&lsFuncName, &lsMaxArg);
    }

    if (ARG1 != NULL && ARG1->pstr == NULL) {
        printf("LISTIT: invalid parameters, maybe enclose in quotes\n");
        Lerror(ERR_INCORRECT_CALL,4,1);
    }

    tree = _proc[_rx_proc].scope[0];

    if (ARG1 == NULL || LSTR(*ARG1)[0] == 0) {
        printf("List all Variables\n");
        printf("------------------\n");
        BinPrint(tree.parent, NULL);
    } else {
        LASCIIZ(*ARG1) ;
        Lupper(ARG_OWN(1));
        printf("List Variables with Prefix '%s'\n",ARG1->pstr);
        printf("%.*s\n", (int) (29+ARG1->len),
               "-------------------------------------------------------");
        BinPrint(tree.parent, ARG1);
    }
}

void R_vlist(__unused int func)
{
    BinTree tree;
    int	found=0;
    int mode=1;
    get_s(1);
    LASCIIZ(*ARG1);

    if (ARGN > 3 ) {
        Lstr lsFuncName;
        Lstr lsMaxArg;

        LINITSTR(lsFuncName)
        LINITSTR(lsMaxArg)

        Lfx(&lsFuncName,5);
        Lfx(&lsMaxArg, 4);

        Lscpy(&lsFuncName, "VList");
        Licpy(&lsMaxArg,2);

        Lerror(ERR_INCORRECT_CALL,4,&lsFuncName, &lsMaxArg);
    }

    if (ARG1 != NULL && ARG1->pstr == NULL)  Lfailure("VLIST: invalid parameters, maybe enclose in quotes","","","","");
    if (exist(2)) {
        get_s(2);
        LASCIIZ(*ARG2);
        Lupper(ARG_OWN(2));
        if (LSTR(*ARG2)[0] == 'V') mode = 1;
        else if (LSTR(*ARG2)[0] == 'N') mode = 2;
        else if (LSTR(*ARG2)[0] == 'A' && exist(3)) {
            get_s(3);
            LASCIIZ(*ARG3);
            Lupper(ARG_OWN(3));
            if (LSTR(*ARG1)[LLEN(*ARG1)-1]!='.')  Lfailure("AS Clause only available for STEM variables:",LSTR(*ARG1),"","","");
            if (LSTR(*ARG3)[LLEN(*ARG3)-1]!='.')  Lfailure("AS Clause must be STEM variable:",LSTR(*ARG3),"","","");
            mode = 3;      // AS Clause
        }
    }

    tree = _proc[_rx_proc].scope[0];

    if (ARG1 == NULL || LSTR(*ARG1)[0] == 0) {
        found=BinVarDump(ARGR,tree.parent, NULL,mode,ARG3);
    } else {
        Lstr argone;
        LINITSTR(argone);
        Lfx(&argone, LLEN(*ARG1));
        Lstrcpy(&argone, ARG1);
        Lupper(&argone);
        if (LSTR(argone)[LLEN(argone) - 1] == '.') {
            strcat(LSTR(argone), "*");
            LLEN(argone)= LLEN(argone) + 1;
        }
        found=BinVarDump(ARGR, tree.parent, &argone, mode, ARG3);
        LFREESTR(argone);
    }
    setIntegerVariable("VLIST.0", found);
}

void R_stemhi(__unused int func)
{
    BinTree tree;
    int	found=0;

    if (ARGN !=1)  Lerror(ERR_INCORRECT_CALL,4,1);

    if (ARG1 == NULL || LSTR(*ARG1)[0] == 0) {
        // NOP
    } else {
        LASCIIZ(*ARG1) ;
        Lupper(ARG_OWN(1));
        if (LSTR(*ARG1)[LLEN(*ARG1)-1]!='.') {
            Lcat(ARG1, ".");    /* strcat() could write one byte too far */
        }
        tree = _proc[_rx_proc].scope[0];
        found=BinStemCount(ARGR,tree.parent, ARG1);
    }
    Licpy(ARGR ,found);
}

void arginas(PLstr isname, __unused const char* asname) {
    Lstrcpy(ARG_OWN(1), isname);  // replace it by requested as-name, in a copy (#305)

    R_vlist(0);                // search for all variables returned is set-list with all entries
}

void R_argin(__unused int func) {
    int stemi;  // -1: no such argument / not a variable
    int rc=-1;
    const RxProc *pr;
    PBinLeaf	litleaf;

    get_i(1,stemi)
    pr = &(_proc[_rx_proc]);   // current proc level
    if(stemi < 1 || stemi>pr->arg.n) Licpy(ARGR,rc);
    else {
         Lstrcpy(ARGR, pr->arg.a[stemi - 1]);  // copy requested variable name
         Lupper(ARGR);
 //        tree = _proc[_rx_proc - 1].scope[0];          // set to caller level
         litleaf = BinFind(&rxLitterals, ARGR);
         if (litleaf) {
             RxVarExpose(_proc[_rx_proc].scope, litleaf);
             if exist(3) {
                get_sv(3)
                arginas(ARGR, LSTR(*ARG3));
             }
            } else Licpy(ARGR,rc);
     }
    Licpy(ARG_OWN(1),stemi);
 }

void R_upper(__unused int func) {
    if (ARGN != 1) Lerror(ERR_INCORRECT_CALL,0);

    if (LTYPE(*ARG1) != LSTRING_TY) {
        L2str(ARG1);
    }
    LASCIIZ(*ARG1) ;
    Lstrcpy(ARGR,ARG1);
    Lupper(ARGR);
}

void R_lower(__unused int func) {
    if (ARGN != 1) Lerror(ERR_INCORRECT_CALL,0);

    if (LTYPE(*ARG1) != LSTRING_TY) {
        L2str(ARG1);
    }
    LASCIIZ(*ARG1) ;
    Lstrcpy(ARGR,ARG1);
    Llower(ARGR);
}

void R_lastword(__unused int func) {
    long offset=0;
    long lwi=0;
    long lwe=0;
    long wrds;

    LZEROSTR(*ARGR);   // default no word

    if (LLEN(*ARG1)==0) return;

    get_sv(1);
    get_oiv(2,wrds,1)

    offset= LLEN(*ARG1) - 1;


    while (wrds>0) {
        while (offset >= 0 && ISSPACE(LSTR(*ARG1)[offset])) offset--;
        if (offset < 0) break;
        lwe = offset + 2; // offset points to last char of word +1 to place it to next blank, +1 to make offset to position

        while (offset >= 0 && !ISSPACE(LSTR(*ARG1)[offset])) offset--;
        lwi= offset + 2;   // offset points to first blank prior to word +1 to place it to first char of word, +1 to make offset to position
        wrds--;
    }
     if (wrds==0) _Lsubstr(ARGR,ARG1,lwi,lwe-lwi);
}

void R_join(__unused int func) {
    int mlen = 0;
    int i = 0;
    Lstr joins;
    Lstr tabin;
    if (ARGN >3 || ARGN<2 || ARG1==NULL || ARG2==NULL) Lerror(ERR_INCORRECT_CALL, 0);
    if (LLEN(*ARG1) <1) {
        Lstrcpy(ARGR, ARG2);
        return;
    }
    if (LLEN(*ARG2) <1) {
        Lstrcpy(ARGR, ARG1);
        return;
    }
    if (LLEN(*ARG1) > LLEN(*ARG2)) mlen = LLEN(*ARG1);
    else mlen = LLEN(*ARG2);
    if (mlen <= 0) {
        LZEROSTR(*ARGR);
        return;
    }
    LINITSTR(tabin);
    Lfx(&tabin,32);
    if (ARG3==NULL||LLEN(*ARG3)==0) {
        LLEN(tabin)=1;
        LSTR(tabin)[0]=' ';
    } else {
        L2STR(ARG3);
        Lstrcpy(&tabin,ARG3);
    }

    LINITSTR(joins);
    Lfx(&joins, mlen);
    LLEN(joins)=mlen;

    L2STR(ARG1);
    LASCIIZ(*ARG1);
    L2STR(ARG2);
    LASCIIZ(*ARG2);

    for (i = 0; i < mlen; i++) {
        for (int j = 0; (size_t) j < LLEN(tabin); j++) {
            if (LSTR(*ARG2)[i] == LSTR(tabin)[j]) goto joinChar;  // split char found             }
        }
        LSTR(joins)[i] = LSTR(*ARG2)[i];
        continue;
        joinChar:   LSTR(joins)[i] = LSTR(*ARG1)[i];
    }
    Lstrcpy(ARGR, &joins);
    LFREESTR(joins);
    LFREESTR(tabin);
}

/* SPLIT: is c one of the delimiter characters */
static int isDelim(unsigned char c, const Lstr *delims)
{
    return memchr(LSTR(*delims), c, LLEN(*delims)) != NULL;
}

void R_split(__unused int func) {
    long i=0;
    long j=0;
    long n = 0;
    long ctr=0;
    Lstr Word;
    Lstr tabin;
    char varName[255];
    int sdot=0;

    if (ARGN >3 || ARG1==NULL|| ARG2==NULL) Lerror(ERR_INCORRECT_CALL, 0);
    LINITSTR(tabin);
    Lfx(&tabin,32);
    if (ARG3==NULL||LLEN(*ARG3)==0) {
        LLEN(tabin)=1;
        LSTR(tabin)[0]=' ';
    } else {
        L2STR(ARG3);
        Lstrcpy(&tabin,ARG3);
    }
    L2STR(ARG1);
    LASCIIZ(*ARG1);
    L2STR(ARG2);
    LASCIIZ(*ARG2);
    j=LLEN(*ARG2)-1;     // offset of last char
    if (LSTR(*ARG2)[j]=='.') sdot=1;
    Lupper(ARG_OWN(2));
    LINITSTR(Word);
    Lfx(&Word,LLEN(*ARG1)+1);

    memset(varName, 0, 255);
// Loop over provided string
    for (;;) {
        //    SKIP to next Word, Drop all word delimiter
        while ((size_t) i < LLEN(*ARG1) && isDelim(LSTR(*ARG1)[i], &tabin)) i++;
        if ((size_t) i >= LLEN(*ARG1)) break;
//    SKIP to next Delimiter, scan word
        n = i;
        while ((size_t) n < LLEN(*ARG1) && !isDelim(LSTR(*ARG1)[n], &tabin)) n++;
        //    Move Word into STEM
        ctr++;                    // Next word found, increase counter
        _Lsubstr(&Word,ARG1,i+1,n-i);
        LSTR(Word)[n-i]='\0';     // set 0 for end of string
        LLEN(Word)=n-i;
        if (sdot==0) snprintf(varName, sizeof(varName), "%s.%li",LSTR(*ARG2) ,ctr);
        else snprintf(varName, sizeof(varName), "%s%li",LSTR(*ARG2) ,ctr);
        setVariable(varName, LSTR(Word));  // set stem variable
        i=n;                      // newly set string offset for next loop
    }
//  set stem.0 content for found words
    {
        char count[16];     /* LSTR(Word) held the last word, not a number */

        if (sdot==0) snprintf(varName, sizeof(varName), "%s.0",LSTR(*ARG2));
        else snprintf(varName, sizeof(varName), "%s0",LSTR(*ARG2));
        snprintf(count, sizeof(count), "%ld", ctr);
        setVariable(varName, count);
    }
    LFREESTR(Word);
    LFREESTR(tabin);
    Licpy(ARGR, ctr);   // return number if found words
}

void R_wait(__unused int func)
{
    int val;


    if (ARGN != 1)
        Lerror(ERR_INCORRECT_CALL,0);

    LASCIIZ(*ARG1);
    get_i (1,val);

    sleepMs(val);
}

void R_abend(__unused int func)
{
    RX_ABEND_PARAMS_PTR params;

    int ucc = 0;

    if (ARGN != 1)
        Lerror(ERR_INCORRECT_CALL,0);

    LASCIIZ(*ARG1);
    get_i (1,ucc);

    if (ucc < 1 || ucc > 3999)
        Lerror(ERR_INCORRECT_CALL,0);

    _setjmp_ecanc();

    params = MALLOC(sizeof(RX_ABEND_PARAMS), "R_abend_parms");

    params->ucc          = ucc;

    call_rxabend(params);

    FREE(params);
}

void R_userid(__unused int func)
{
    const char *userid;

    if (ARGN > 0) {
        Lerror(ERR_INCORRECT_CALL,0);
    }
    userid = rac_user();
    Lscpy(ARGR, userid);
}

/* SYSVAR('SYSCP') and ('SYSCPLVL'): a CP command through DIAG 8, with
 * the privilege it needs */
static void cpCommand(byte *upt, byte *ect, char *cmd, char *retbuf, int size)
{
    privilege(1);
    (void) systemCP(upt, ect, cmd, (int) strlen(cmd), retbuf, size);
    privilege(0);
}

/* the host system a CP QUERY CPLEVEL answer names */
static const char *cpHost(const char *retbuf)
{
    if (strstr(retbuf, "HHC01600E") != 0) return "Hercules";
    if (strstr(retbuf, "VM/370") != 0)    return "VM/370";
    if (strstr(retbuf, "VM/ESA") != 0)    return "VM/ESA";
    if (strstr(retbuf, "VM/SP")  != 0)    return "VM/SP";
    if (strstr(retbuf, "VM")     != 0)    return "VM";
    return "UNKNOWN";
}

void hostenv(int func) {
    /* Hercules ends its VERSION lines with an EBCDIC line feed */
    static const char hercEnd[] = { 0x25, '\0' };
    char *offset;
    char retbuf[320];
    byte *ect;
    byte *upt;
    void **cppl;

    memset(retbuf, '\0', sizeof(retbuf));

    if (isTSO() && tsoCppl() != NULL) cppl = tsoCppl();
    else {
        Lscpy(ARGR,"failed, TSO required");
        return;
    }

    upt  = cppl[1];
    ect  = cppl[3];

    cpCommand(upt, ect, "CP QUERY CPLEVEL", retbuf, sizeof(retbuf));

    if (func != 1) {                    /* SYSCP: the host's name */
        Lscpy(ARGR, cpHost(retbuf));
        return;
    }
    /* SYSCPLVL: its level, from VM's answer or from Hercules' VERSION */
    if (strstr(retbuf, "HHC01600E") == 0) {
        offset=strstr(retbuf, "VM/");
        if (offset==0) Lscpy(ARGR,retbuf);
        else {
            offset[strcspn(offset, "\r\n")] = '\0';
            Lscpy(ARGR, offset);
        }
        return;
    }
    cpCommand(upt, ect, "VERSION", retbuf, sizeof(retbuf));
    offset=strstr(retbuf, "Hercules");
    if (offset==0) Lscpy(ARGR,retbuf);
    else {
        offset[strcspn(offset, hercEnd)] = '\0';
        Lscpy(ARGR, offset);
    }
}

/* ---------------------------------------------------------------------
 * GTTERM: terminal id and screen size of the TSO terminal.
 * termid is blank-stripped and empty, rows/cols are 0, when there is no
 * terminal (batch, TSO in the background) or GTTERM fails. The size is
 * the alternate screen size, falling back to the primary one.
 * Returns the GTTERM return code, -1 outside TSO.
 * --------------------------------------------------------------------- */
static int getTerminal(char termid[8 + 1], int *rows, int *cols)
{
    RX_GTTERM_PARAMS params;

    struct termSize {
        byte bRows;
        byte bCols;
    };
    struct termSize primarySize;
    struct termSize alternateSize;

    int rc;

    memset(termid, 0, 8 + 1);
    *rows = 0;
    *cols = 0;

    if (!isTSO()) {
        return -1;
    }

    memset(&primarySize,   0, sizeof(primarySize));
    memset(&alternateSize, 0, sizeof(alternateSize));

    // four-word list as GTTERM TERMID= builds it: the end-of-list bit
    // goes on the terminal id word
    params.primadr   = (unsigned *) &primarySize;
    params.altadr    = (unsigned *) &alternateSize;
    params.attradr   = 0;
    params.termidadr = (unsigned *) (((uintptr_t) termid) | 0x80000000);

    rc = gtterm(&params);
    if (rc != 0) {
        memset(termid, 0, 8 + 1);
        return rc;
    }

    termid[8] = '\0';
    for (int ii = 7; ii >= 0 && (termid[ii] == ' ' || termid[ii] == '\0'); ii--) {
        termid[ii] = '\0';
    }

    if (alternateSize.bRows != 0 && alternateSize.bCols != 0) {
        *rows = alternateSize.bRows;
        *cols = alternateSize.bCols;
    } else {
        *rows = primarySize.bRows;
        *cols = primarySize.bCols;
    }

    return 0;
}

/* SYSVAR's values that need SVC 244: SYSCPLVL, SYSCP (DIAG 8) and
 * SYSNODE (NJE38). 0 when name is none of them, else 1 and ARGR set */
static int sysvarHost(const char *name)
{
    int which;

    if (strcmp(name, "SYSCPLVL") == 0)     which = 1;
    else if (strcmp(name, "SYSCP") == 0)   which = 0;
    else if (strcmp(name, "SYSNODE") == 0) which = 2;
    else return 0;

    if (!rac_check(FACILITY, SVC244, READ)) {
        Lscpy(ARGR, "not authorized");
    } else if (which < 2) {
        hostenv(which);  // return argument set in hostenv()
    } else {
        char netId[10 + 1];               // "-INACTIVE-" + \0
        char *sNetId = &netId[0];

        privilege(1);
        RxNjeGetNetId(&sNetId);
        privilege(0);
        Lscpy(ARGR, sNetId);
    }
    return 1;
}

void R_sysvar(__unused int func)
{
    extern unsigned long long ullInstrCount;
    const char *msg = "not yet implemented";

    if (ARGN != 1) {
        Lerror(ERR_INCORRECT_CALL,0);
    }

    LASCIIZ(*ARG1);
    get_s(1);
    Lupper(ARG_OWN(1));

    if (sysvarHost((const char *) ARG1->pstr)) {
        /* set there */
    } else if (strcmp((const char*)ARG1->pstr, "SYSUID") == 0) {
        Lscpy(ARGR,environment->SYSUID);
    } else if (strcmp((const char*)ARG1->pstr, "SYSPREF") == 0) {
        Lscpy(ARGR, environment->SYSPREF);
    } else if (strcmp((const char*)ARG1->pstr, "SYSENV") == 0) {
        if (!isTSO()) Lscpy(ARGR, "BATCH");
        else Lscpy(ARGR,environment->SYSENV);
    } else if (strcmp((const char*)ARG1->pstr, "SYSTSO") == 0) {
        Licpy(ARGR,isTSO());
    } else if (strcmp((const char*)ARG1->pstr, "SYSISPF") == 0) {
        Lscpy(ARGR, environment->SYSISPF);
    } else if (strcmp((const char*)ARG1->pstr, "SYSAUTH") == 0) {
        Licpy(ARGR, __isauth() ? 1 : 0);
    } else if (strcmp((const char*)ARG1->pstr, "RXINSTRC") == 0) {
        Licpy(ARGR, ullInstrCount);
    } else if (strcmp((const char*)ARG1->pstr, "SYSHEAP") == 0 ||
               strcmp((const char*)ARG1->pstr, "SYSSTACK") == 0) {
        /* JCC's runtime counted heap and stack; libc370 does not (#298) */
        Licpy(ARGR, 0);
    } else if (strcmp((const char*)ARG1->pstr, "SYSRACF") == 0 ||
               strcmp((const char*)ARG1->pstr, "SYSRAKF") == 0) {
        if (rac_status()) {
            Lscpy(ARGR, "AVAILABLE");
        } else {
            Lscpy(ARGR, "NOT AVAILABLE");
        }
    } else if (strcmp((const char*)ARG1->pstr, "SYSTERMID") == 0) {
        char termid[8 + 1];
        int rows;
        int cols;

        getTerminal(termid, &rows, &cols);
        Lscpy(ARGR, termid);
    } else {
        Lscpy(ARGR,msg);
    }
}

void R_terminal(__unused int func) {
    char termid[8 + 1];
    int rows;
    int cols;
    char result[16];

    if (ARGN > 0) {
        Lerror(ERR_INCORRECT_CALL, 0);
    }

    getTerminal(termid, &rows, &cols);

    snprintf(result, sizeof(result), "%d %d", rows, cols);
    Lscpy(ARGR, result);
}

void R_mvsvar(__unused int func)
{
    const char *msg = "not yet implemented";
    char chrtmp[16];
    char *tempoff;

    void ** psa;           // PSA     =>   0 / 0x00
    void ** cvt;           // FLCCVT  =>  16 / 0x10
    void ** smca;          // CVTSMCA => 196 / 0xC4
    void ** csd;           // CVT+660
    void ** smcasid;       // SMCASID =>  16 / 0x10
    short * cvt2;

    memset(chrtmp, '\0', sizeof(chrtmp));
    psa  = 0;
    cvt  = psa[4];         //  16 -- NOSONAR: the PSA is at address 0 on MVS
    smca = cvt[49];        // 196
    smcasid =  smca + 4;   //  16
    csd  = cvt[165];       // 660

    if (ARGN != 1) {
        Lerror(ERR_INCORRECT_CALL,0);
    }

    LASCIIZ(*ARG1);
    get_s(1);
    Lupper(ARG_OWN(1));

    if (strcmp((const char *) ARG1->pstr, "SYSNAME") == 0) {
        Lscpy2(ARGR, (char *) (smcasid), 4);
    } else if (strcmp((const char *) ARG1->pstr, "SYSSMFID") == 0) {
        Lscpy2(ARGR, (char *) (smcasid), 4);
    } else if (strcmp((const char *) ARG1->pstr, "CPUS") == 0) {
        char cpus[16];      /* it printed chrtmp+4 into chrtmp itself */

        snprintf(cpus, sizeof(cpus), "%x", (int) csd[2]);
        tempoff = &cpus[0] + 4;
        snprintf(chrtmp, sizeof(chrtmp), "%4s\n", tempoff);
        Lscpy2(ARGR, chrtmp, 4);
    } else if (strcmp((const char *) ARG1->pstr, "CPU") == 0) {
        snprintf(chrtmp, sizeof(chrtmp), "%x", (unsigned) cvt[-2]);
        Lscpy(ARGR, chrtmp);
    } else if (strcmp((const char *) ARG1->pstr, "SYSOPSYS") == 0) {
        cvt2 = (short *) cvt;
        snprintf(chrtmp, sizeof(chrtmp), "MVS %.*s.%.*s", 2, (char *) (cvt2 - 2), 2, (char *) (cvt2 - 1));
        Lscpy(ARGR, chrtmp);
    } else if (strcmp((const char *) ARG1->pstr, "SYSNJVER") == 0) {
        char version[21 + 1];             // 21 + \0
        char *sVersion = &version[0];
        RxNjeGetVersion(&sVersion);
        Lscpy(ARGR, sVersion);
        Lupper(ARGR);
    } else {
        Lscpy(ARGR, msg);
    }
}


/* -------------------------------------------------------------------------------------
 * return integer value, REAL numbers will converted to integer, STRING parms lead to error
 * -------------------------------------------------------------------------------------
 */
void R_int( __unused const int func ) {

    if (ARGN != 1) Lerror(ERR_INCORRECT_CALL, 0);
    if (LTYPE(*ARG1) == LINTEGER_TY) Licpy(ARGR, LINT(*ARG1));
    else if (LTYPE(*ARG1) == LREAL_TY) Licpy(ARGR, LREAL(*ARG1));
    else {
        L2STR(ARG1);
        if (_Lisnum(ARG1)==LSTRING_TY) Lfailure("Invalid Number: ",LSTR(*ARG1),"","","");
        LINT(*ARGR) = (long) lLastScannedNumber;
        LTYPE(*ARGR) = LINTEGER_TY;
        LLEN(*ARGR) = sizeof(long);
    }
}

/* -------------------------------------------------------------------------------------
 * Fast variant of DATATYPE
 * -------------------------------------------------------------------------------------
 */
void R_type( __unused const int func ) {


    if (ARGN != 1) Lerror(ERR_INCORRECT_CALL, 0);
    if (LTYPE(*ARG1) == LINTEGER_TY) Lscpy(ARGR, "INTEGER");
    else if (LTYPE(*ARG1) == LREAL_TY) Lscpy(ARGR, "REAL");
    else {
        L2STR(ARG1);
        switch (_Lisnum(ARG1)) {
            case LINTEGER_TY:
                Lscpy(ARGR, "INTEGER");
                break;
            case LREAL_TY:
                Lscpy(ARGR, "REAL");
                break;
            case LSTRING_TY:
                Lscpy(ARGR, "STRING");
                break;
            default:
                break;
        }
    }
}

/* -------------------------------------------------------------------------------------
 * Encrypt String
 * -------------------------------------------------------------------------------------
 */
void R_crypt(__unused int func) {
    int rounds=7;
    // string to encrypt and password must exist
    must_exist(1);
    must_exist(2);
    get_oi0(3,rounds);       /* drop rounds parameter, it might decrease security */
    if (rounds==0) rounds=7;  /* maximum slots */
    Lcryptall(ARGR, ARG1, ARG2,rounds,0);  // mode =0  encode
}

/* -------------------------------------------------------------------------------------
 * Decrypt String
 * -------------------------------------------------------------------------------------
 */
void R_decrypt(__unused int func) {
    int rounds=1;
    // string to encrypt and password must exist
    must_exist(1);
    must_exist(2);
    Lcryptall(ARGR, ARG1, ARG2,rounds,1); // mode =1  decode
}

/* -------------------------------------------------------------------------------------
 * Rotate String (registered stub)
 * -------------------------------------------------------------------------------------
 */
void R_rotate(__unused int func) {
    int start;
    int slen;
    must_exist(1);
    must_exist(2);
    get_oi(2,start);
    get_oi0(3,slen);
    _rotate(ARGR,ARG1,start,slen);
}

/* -------------------------------------------------------------------------------------
 * RHASH (registered stub)
 * -------------------------------------------------------------------------------------
 */
void R_rhash(__unused int func) {
    int     slots=0;

    must_exist(1);
    get_oi0(2,slots);       /* is there a max slot given? */

    Lhash(ARGR,ARG1,slots);
}

/* ----------------- Lindex ---------------------- */
/* haystack   - Lstr where to search               *
 *  needle    - Lstr to search                     *
 *    start       - starting position [1,haystack len] *
 *              if start < 1 then start = 1                *
 * returns  0 (NOTFOUND) is needle is not found    *
 * else returns position [1,haystack len]          *
 * ----------------------------------------------- */
long fndpos(const Lstr *needle, PLstr haystack, int start) {
    long fpos;
    start--;		/* for C string offset = 0, Rexx=1 */
    if (start < 0) start = 0;

    if (LLEN(*needle) <= 0)           return LNOTFOUND;
    if (LLEN(*haystack) <= 0)           return LNOTFOUND;
    if (LLEN(*needle) > LLEN(*haystack))  return LNOTFOUND;

    fpos= (long) strstr(LSTR(*haystack)+start, LSTR(*needle));
    if (fpos == 0)   return LNOTFOUND;
    return fpos-(long) (*haystack).pstr + 1;
}



void R_fpos( __unused int func)  {
    long	start;

    get_sv(1);
    get_sv(2);
    get_oiv(3,start,1);
     Licpy(ARGR,fndpos(ARG1,ARG2,start));
}

/* ----------------- Lchagestr ------------------- */
void R_fchangestr(__unused int func) {
    size_t pos;
    size_t foundpos;

    get_sv(1);
    get_sv(2);
    get_sv(3);

    if (LLEN(*ARG1)==0) {
        Lstrcpy(ARGR,ARG2);
        return;
    }

    LZEROSTR(*ARGR);
    pos = 1;

    for (;;) {
        foundpos = fndpos(ARG1,ARG2,pos);
        if (foundpos==0) break;
        if (foundpos!=pos) {
            _Lsubstr(&LTMP[14],ARG2,pos,foundpos-pos);
            Lstrcat(ARGR,&LTMP[14]);
        }
        Lstrcat(ARGR,ARG3);
        pos = foundpos + LLEN(*ARG1);
    }
    _Lsubstr(&LTMP[14],ARG2,pos,0);
    Lstrcat(ARGR,&LTMP[14]);
} /* Lchagestr */


void R_quote(__unused int func) {
  char quote= '\'';
  get_sv(1);

  if (LSTR(*ARG1)[0] == quote && LSTR(*ARG1)[LLEN(*ARG1) - 1] == '\'') goto isquoted;
  if (LSTR(*ARG1)[0] == '\"' && LSTR(*ARG1)[LLEN(*ARG1)-1] == '\"') goto isquoted;
  if (strchr((const char *) LSTR(*ARG1), quote) !=0) quote= '\"';   // string contains single quote, use double quote to enclose string
  // else quote='\'';                           // else use single quotes to enclose string is default
  Lfx(ARGR,LLEN(*ARG1)+2);
  LZEROSTR(*ARGR);
  LLEN(*ARGR)=1;
  LSTR(*ARGR)[0] = quote;
  Lstrcat(ARGR, ARG1);
  LSTR(*ARGR)[LLEN(*ARG1)+1] = quote;
  LLEN(*ARGR)=LLEN(*ARG1)+2;
  LSTR(*ARGR)[LLEN(*ARGR)] ='\0';

  return;
  isquoted:
    printf("is quited");
    Lstrcpy(ARGR,ARG1);
  return;
}

void R_arraygen(__unused int func)
{
    int rc =0;

    RX_TSO_PARAMS  tso_parameter;
    void ** cppl;

    __dyn_t dyn_parms;

    if (ARGN != 1) Lerror(ERR_INCORRECT_CALL, 0);

     if (isTSO()!= 1 ||  tsoCppl() == 0) Lerror(ERR_INCORRECT_CALL, 0);

    get_s(1);
    LASCIIZ(*ARG1);

    cppl = tsoCppl();

    memset(&tso_parameter, 00, sizeof(RX_TSO_PARAMS));
    tso_parameter.cppladdr = (unsigned int *) cppl;

    if (strcasecmp("OFF", (const char *) LSTR(*ARG1)) != 0) {    // ARRAYGEN ON
        dyninit(&dyn_parms);
        dyn_parms.__ddname    = (char *) LSTR(arraygenCtx->ddName);
        dyn_parms.__status    = __DISP_NEW;
        dyn_parms.__unit      = "VIO";
        dyn_parms.__dsorg     = __DSORG_PS;
        dyn_parms.__recfm     = _FB_;
        dyn_parms.__lrecl     = 255;
        dyn_parms.__blksize   = 5100;
        dyn_parms.__alcunit   = __TRK;
        dyn_parms.__primary   = 5;
        dyn_parms.__secondary = 5;

        rc = dynalloc(&dyn_parms);

        strcpy(tso_parameter.ddout, (const char *) LSTR(arraygenCtx->ddName));

        rc = call_rxtso(&tso_parameter);
        Licpy(ARGR, rc);
    } else {  // OFF requested
        rc = call_rxtso(&tso_parameter);
        Lstrcpy(ARG_OWN(1),&arraygenCtx->ddName);    /* a copy, not the caller's (#305) */
        R_sread(0);
     // ARGR contains sarray number
        Lscpy(ARG_OWN(1),"OFF");       // Reset ARG1 (a copy since #305)
        dyninit(&dyn_parms);
        dyn_parms.__ddname = (char *) LSTR(arraygenCtx->ddName);
        rc = dynfree(&dyn_parms);
    }
}

/* -------------------------------------------------------------------------------------
 * MEMORY: the free storage map (the matrices and arrays that stood here
 * are in rxmatrix.c and rxiarray.c, #302)
 * -------------------------------------------------------------------------------------
 */
#define MEMORY_BLOCKS 128

/* the largest block malloc() gives below *nogot, at least 16K: halve
 * until one fits, then widen towards *nogot while one still does. On
 * return *nogot is the first size that did not fit, *size the block's;
 * NULL when there is none */
static int *largestBlock(int *nogot, int *size)
{
    int *gotten = NULL;
    int getmain;
    int lastgm;

    for (getmain = *nogot; getmain > 16384; getmain = getmain / 2) {
        gotten = malloc(getmain);
        if (gotten != NULL) break;
        *nogot = getmain;
    }
    if (gotten == NULL) return NULL;
    free(gotten);
    lastgm = getmain;
    while (*nogot - getmain >= 16384) {
        getmain = getmain + (*nogot - getmain) / 2;
        gotten = malloc(getmain);
        if (gotten == NULL) {
            *nogot = getmain;
            getmain = lastgm;
        } else {
            free(gotten);
            lastgm = getmain;
        }
    }
    *size = getmain;
    return malloc(getmain);        /* hold it to find the next block */
}

void R_memory(__unused int func) {
    int noprint=0;
    int nogot=14*1024*1024;
    int size=0;
    int blocks=0;
    int *memory[MEMORY_BLOCKS];
    int alc=0;

    if (ARGN>0) {
        get_s(1);
        LASCIIZ(*ARG1)
        Lupper(ARG_OWN(1));
        if (LSTR(*ARG1)[0]=='N') noprint=1;
    }
    if (noprint==0) {
        printf("MVS Free Storage Map\n");
        printf("---------------------------\n");
    }
    /* hold every free block, largest first, to map them; the list took
     * memory[128] and lost the block it could not store */
    for (;;) {
        int *gotten = largestBlock(&nogot, &size);

        if (gotten == NULL) break;
        if (blocks == MEMORY_BLOCKS) {
            free(gotten);
            printf ("Memory List exceeded\n");
            break;
        }
        if (noprint==0) printf("AT ADDR %8d   %5d KB\n", (int) gotten, size / 1024);
        memory[blocks++] = gotten;
        nogot = size;
        alc = alc + size;
    }
    for (int i = 0; i < blocks; ++i) {
        free(memory[i]);
    }
    Licpy(ARGR,alc);
    if (noprint==0) {
        printf("Total              %5d KB\n", alc/1024);
        printf("---------------------------\n");
    }
}
void R_rxlist(__unused int func) {
    RxFile  *rxf;
    char varName[16];
    char sValue[256];   /* 80 did not hold four names */
    char option='U';
    int ii=0;
    if (ARGN>0) {
        LASCIIZ(*ARG1)
        option = LSTR(*ARG1)[0];
    }
    switch (option) {
        case 'S':    // set to STEM
          for (rxf = rxFileList; rxf != NULL; rxf = rxf->next) {
              if (strcmp(rxf->filename, "-BREXX/370-")) {
                 ii++;
                 snprintf(varName, sizeof(varName), "rxlist.%d", ii);
                 snprintf(sValue, sizeof(sValue), "%s %s %s %s", rxf->filename, rxf->member, rxf->ddn, rxf->dsn);
                 setVariable(varName, sValue);
              }
              setIntegerVariable("rxlist.0", ii);
          }
        break;
        case 'L':    // List only REXX names and set to STEM
            for (rxf = rxFileList; rxf != NULL; rxf = rxf->next) {
                if (strcmp(rxf->filename, "-BREXX/370-")) {
                    ii++;
                    snprintf(varName, sizeof(varName), "rxlist.%d", ii);
                    snprintf(sValue, sizeof(sValue), "%s", rxf->filename);
                    setVariable(varName, sValue);
                }
                setIntegerVariable("rxlist.0", ii);
            }
            break;
        case 'R':    // remove entry: 0 when found, -1 when not
          get_s(2)
          LASCIIZ(*ARG2);
          ii=-1;       /* set after the loop, it hid a found entry */
          for (rxf = rxFileList; rxf != NULL; rxf = rxf->next) {
              if (strcmp(rxf->filename, LSTR(*ARG2))==0) {
                 rxf->filename[0]='0';
                 ii=0;
                 break;
              }
          }
        break;
        default :   // List it
          printf("Loaded Rexx Modules \n");
          printf("    REXX      Member   DDNAME   DSN \n");
          printf("-----------------------------------------------------\n");
          for (rxf = rxFileList; rxf != NULL; rxf = rxf->next) {
              if (strcmp(rxf->filename, "-BREXX/370-")) {
                 ii++;
                 printf("%3d %-9s %-8s %-8s %s\n", ii, rxf->filename, rxf->member, rxf->ddn, rxf->dsn);
              }
          }
        break;
    }
    Licpy(ARGR,ii);
}

void lcs (const char *a, int n, const char *b, int m, char **s) {
    int i;
    int j;
    int k;
    int t;
    int *z;
    int **c;

    if (n < 1 || m < 1) {               /* R_lcs refuses empty strings */
        Lscpy(ARGR, "");
        return;
    }
    /* (n+1)*(m+1) overflowed int for long strings: a small table */
    if ((size_t) (m + 1) > ((size_t) -1) / sizeof (int) / (size_t) (n + 1)) {
        Lfailure("LCS: strings too long", "", "", "", "");
        return;
    }
    z = calloc((size_t) (n + 1) * (size_t) (m + 1), sizeof (int));
    c = calloc((size_t) (n + 1), sizeof (int *));
    if (z == NULL || c == NULL) {       /* not checked before */
        free(c);
        free(z);
        Lfailure("LCS: not enough storage", "", "", "", "");
        return;
    }
    for (i = 0; i <= n; i++) {
        c[i] = &z[i * (m + 1)];
    }
    for (i = 1; i <= n; i++) {
        for (j = 1; j <= m; j++) {
            if (a[i - 1] == b[j - 1])   c[i][j] = c[i - 1][j - 1] + 1;
            else   c[i][j] = MAX(c[i - 1][j], c[i][j - 1]);
        }
    }
    t = c[n][m];
    *s = malloc(t + 1);                 /* Lscpy() reads it up to a NUL */
    if (*s == NULL) {
        free(c);
        free(z);
        Lfailure("LCS: not enough storage", "", "", "", "");
        return;
    }
    (*s)[t] = '\0';
    for (i = n, j = m, k = t - 1; k >= 0 && i > 0 && j > 0;) {
        if (a[i - 1] == b[j - 1])
            (*s)[k] = a[i - 1], i--, j--, k--;
        else if (c[i][j - 1] > c[i - 1][j])
            j--;
        else
            i--;
    }
    Lscpy(ARGR, *s);
    free(c);
    free(z);
    free(*s);
}

void R_lcs(__unused int func) {
   char *s;
   s = NULL;
   get_s(1);
   get_s(2);
   if (LLEN(*ARG1)==0 || LLEN(*ARG2)==0) Lerror(ERR_INCORRECT_CALL,0);

   lcs(LSTR(*ARG1),LLEN(*ARG1),LSTR(*ARG2),LLEN(*ARG2),&s);
}


/* --------------------------------------------------------------------------
 * Read the master trace table
 *
 * libc370 cmtt_new() copies the whole table in key 0, authorising the task
 * via SVC 244 when it is not APF authorised (NULL if that is refused), and
 * cmtt_get_array() walks the COPY with bounds checks, oldest entry first.
 * The copy is released with cmtt_free() after every call.
 * -------------------------------------------------------------------------------------
 */
#define MTT_TEXTLEN 256

// copy the caller data of an entry, bounded by its length, as a C string
static char *mttText(MTENTRY *entry, char *text)
{
    int len = entry->mtentlen;

    if (len > MTT_TEXTLEN - 1) len = MTT_TEXTLEN - 1;
    memcpy(text, entry->mtentdat, len);
    text[len] = '\0';

    return text;
}

// remember the newest entry, 80 bytes as before
static void mttSave(const char *text)
{
    strncpy(savedEntry, text, sizeof(savedEntry) - 1);
    savedEntry[sizeof(savedEntry) - 1] = '\0';
}

void R_mtt(__unused int func)
{
    CMTT *cmtt;
    MTENTRY **array;

    int row = 0;
    int entries = -1;

    char refresh;
    char varName[16];
    char text[MTT_TEXTLEN];

    // Check if there is an explicit REFRESH requested
    get_modev(1,refresh,'N');

    cmtt  = cmtt_new();
    array = cmtt_get_array(cmtt);

    if (array == NULL) {
        wto("BREXX/370 MTT FUNCTION IN ERROR");
    } else {
        entries = array_count(&array);
        if (entries == 0) {
            setIntegerVariable("_LINE.0", 0);
        // if most current entry is equal with the previous one and no REFRESH is requested, don't scan TT
        } else if (refresh == 'R' || strncmp(mttText(array[entries - 1], text), savedEntry, 40) != 0) {
            mttSave(mttText(array[entries - 1], text));

            // set stem count variable
            setIntegerVariable("_LINE.0", entries);

            // oldest entry first
            for (row = 1; row <= entries; row++) {
                snprintf(varName, sizeof(varName), "_LINE.%d", row);
                setVariable(varName, mttText(array[row - 1], text));
            }
        } else {
            entries = -1;
        }
    }

    cmtt_free(&cmtt);

    Licpy(ARGR, entries);
}

#define ttfree(sname) {for (int ii = 0; ii < sarrayhi[sname]; ++ii) { \
                           if (sindex[ii] == 0) continue; \
                           FREE(sindex[ii]); \
                           sindex[ii] = 0;} \
                       sarrayhi[sname]=0; }
/* ----------------------------------------------------------------------------------------
 * MTTX(option,sarray,max-items,search-string)
 *     option   R  REFRESH    built new array
 *              M  MOD        just return new entries, previous entries (if any) are deleted
 *              N  NO-REFRESH add new entries at the end of the existing array
 *     sarray   array-number, must be pre-allocated (use >= 4000)
 *  max-items   maximum number of trace-table entries to be fetched
 *     string   just take those entries containing the string
 * Entries are added newest first; the array size limits them as max-items does.
 * ----------------------------------------------------------------------------------------
 */
/* MTTX's search filter: no search string, or the text contains it */
static int mttMatch(const char *text, const Lstr *search)
{
    return search == NULL || strstr(text, (const char *) LSTR(*search)) != NULL;
}

/* MTTX 'R': the whole table, newest first, into the string array sindex
 * points to; returns the number of entries */
static int mttRefresh(MTENTRY **array, int ix, int imax, const Lstr *search)
{
    char text[MTT_TEXTLEN];
    int  entries = 0;

    if (ix >= 0) mttSave(mttText(array[ix], text));  // save first entry
    for (; ix >= 0 && entries < imax; ix--) {
        mttText(array[ix], text);
        if (!mttMatch(text, search)) continue;
        snew(entries, text, -1);
        entries++;
    }
    return entries;
}

/* MTTX 'N'/'M': the entries newer than lastEntry, appended after the
 * array's first `entries`; returns how many were added */
static int mttAddNew(MTENTRY **array, int ix, int imax, int entries,
                     const Lstr *search, const char *lastEntry)
{
    char text[MTT_TEXTLEN];
    int  added = 0;

    for (; ix >= 0 && entries < imax; ix--) {
        mttText(array[ix], text);
        if (strncmp(text, lastEntry, 40)==0) break;  // compare first 40 bytes, that's enough
        if (!mttMatch(text, search)) continue;
        snew(entries, text, -1);
        entries++;
        added++;
    }
    return added;
}

void R_mttx(__unused int func)
{
    CMTT *cmtt;
    MTENTRY **array;
    const Lstr *search;

    int entries = 0;
    int added;
    int sname;
    int imax;
    int ix;
    char refresh;         // REFRESH: build new content of array, NON-REFRESH just add new lines at the end, MOD: just return new entries
    char lastEntry[81];
    char text[MTT_TEXTLEN];

    // Check if there is an explicit REFRESH requested
    get_modev(1,refresh,'N');
    get_sname(2,sname)          /* it indexed sindxhi[] unchecked */

    get_oi(3,imax);
    if (imax==0) imax=99999999;
    if (imax>sindxhi[sname]) imax=sindxhi[sname];

    get_sv(4);
    if ((rxArg.a[4-1])==((void*)0) || LLEN(*ARG4) == 0) search = NULL;
    else search = ARG4;

    cmtt  = cmtt_new();
    array = cmtt_get_array(cmtt);

    if (array == NULL) {
        wto("BREXX/370 MTT FUNCTION IN ERROR");
        cmtt_free(&cmtt);
        Licpy(ARGR, -1);    // return no new entries found
        return;
    }

    // newest entry
    ix = (int) array_count(&array) - 1;

    sindex = (char **) sarray[sname];    // set sarray address
    if (sarrayhi[sname]==0 && refresh=='N') refresh='R';
    if (refresh == 'M') {  // prepare array to receive just new entries
        ttfree(sname)      // free existing sarray entries (not the sarray)
    }
    if (refresh == 'R')  {
        ttfree(sname)     // free existing sarray entries (not the sarray)
        entries = mttRefresh(array, ix, imax, search);
        sarrayhi[sname] = entries;
    } else if (ix >= 0 && strncmp(mttText(array[ix], text), savedEntry, 40) != 0) {
        /* just the entries since the last call, up to the one saved then */
        memcpy(lastEntry, savedEntry, sizeof(lastEntry));
        mttSave(text);    // save first entry
        added = mttAddNew(array, ix, imax, sarrayhi[sname], search, lastEntry);
        sarrayhi[sname] = sarrayhi[sname] + added;   // set sarray hi count
        entries = sarrayhi[sname];
    } else {
        entries = -1;
    }

    cmtt_free(&cmtt);

    Licpy(ARGR, entries);
}


void R_e2a(__unused int func){
    get_s(1);
    LE2A(ARGR, ARG1);
    LTYPE(*ARGR) = LSTRING_TY;
}

void R_a2e(__unused int func){
    get_s(1);
    LA2E(ARGR, ARG1);
    LTYPE(*ARGR) = LSTRING_TY;

}
/* -----------------------------------------------------------------------------------
 * Change STOP of started task in CSCB->CIB
 * -----------------------------------------------------------------------------------
 */
void R_stcstop( __unused int func ) {
    long *s;
    long stop=0;

    s = (*((long **) 548));      // 548->ASCB
    s = ((long **) s)[14];       //  56->CSCB

    if (s==NULL) goto nocb;

    s = ((long **) s)[11];      //  44->CIB
    while (s) {                 //  loop through all CIB of stc to find STOP command
      if (((unsigned char *) s)[4] ==0x40) {
          stop = 1;
          break;
      }
      s = ((long **) s)[0];//   0->NEXT-CIB
    }
  nocb:
    Licpy(ARGR,stop);
}

/* -----------------------------------------------------------------------------------
 * BREXX Options
 * -----------------------------------------------------------------------------------
 */
void R_options( __unused int func ) {
    extern char brxoptions[16];
    get_s(1);
    get_s(2);
    LASCIIZ(*ARG1);
    LASCIIZ(*ARG2);
    Lupper(ARG_OWN(1));
    Lupper(ARG_OWN(2));
/* OPTIONS  STEMCLEAR assigned to brxoptions[0]
 *          STECLEAR ON : if a default value is set (stem.=xx) all existing entries are renamed to this value
 *          STECLEAR OFF: existing entries keep their content
 * OPTIONS  DATE     assigned to brxoptions[1]
 *          assigns a default output option to all date functions.
 *          allowed values are XEUROPEAN,EUROPEAN, XUSA, USA, XGERMAN, GERMAN
 *          DATE default-output-date
 */
   if (strncmp((const char *) ARG1->pstr, "STEMCLEAR",4)==0 ) {
       if      (strcmp((const char *) ARG2->pstr, "OFF") == 0) brxoptions[0]='1';
       else if (strcmp((const char *) ARG2->pstr, "ON") == 0)  brxoptions[0]='0';
  } else if (strcmp((const char *) ARG1->pstr, "DATE")==0 ) {
       if      (strncmp((const char *) ARG2->pstr, "XEUROPEAN",3) == 0) brxoptions[1]='A';
       else if (strncmp((const char *) ARG2->pstr, "XGERMAN",3) == 0)   brxoptions[1]='B';
       else if (strncmp((const char *) ARG2->pstr, "XUSA",3) == 0)      brxoptions[1]='C';
       else if (strncmp((const char *) ARG2->pstr, "EUROPEAN",3) == 0)  brxoptions[1]='E';
       else if (strncmp((const char *) ARG2->pstr, "GERMAN",3) == 0)    brxoptions[1]='G';
       else if (strcmp((const char *) ARG2->pstr, "USA") == 0)          brxoptions[1]='U';
  } else Lerror(ERR_INCORRECT_CALL, 0);
    Licpy(ARGR,0);
}

/* -----------------------------------------------------------------------------------
 * Signal Condition
 * -----------------------------------------------------------------------------------
 */
void R_condition( __unused int func ) {
    const char *desc;
    char cmode;
    if (ARGN > 1) Lerror(ERR_INCORRECT_CALL,0);
    get_modev(1,cmode,'I');

    /* no condition trapped yet: every option is the null string (#233) */
    if (SignalCondition[0] == '\0') {
        LZEROSTR(*ARGR);
        return;
    }
    Lscpy(&LTMP[0],SignalCondition);   ///
    if (cmode=='C') {
       Lword(ARGR,&LTMP[0],1);
    }
    else if (cmode=='D') {
       if (TrappedCnd == SC_SYNTAX &&
           strstr(SignalCondition,"Line ") != 0) Lscpy(ARGR, SignalLine);
       else {
          /* everything after the condition name, e.g. the command (#234) */
          desc = strchr(SignalCondition,' ');
          Lscpy(ARGR, desc ? desc+1 : "");
       }
    }
    else if (cmode=='I') Lscpy(ARGR, TrapByCall ? "CALL" : "SIGNAL");
    else if (cmode=='S') {
       if (!(_proc[_rx_proc].condition & TrappedCnd)) Lscpy(ARGR, "OFF");
       else if (_proc[_rx_proc].delayed & TrappedCnd) Lscpy(ARGR, "DELAY");
       else Lscpy(ARGR, "ON");
    }
    else if (cmode=='X') Lscpy(ARGR, SignalLine);
    else Lscpy(ARGR, TrapByCall ? "CALL" : "SIGNAL");

}

/* -----------------------------------------------------------------------------------
 * Mask Blank within strings to improve WORD functions
 * -----------------------------------------------------------------------------------
 */
void R_maskblk( __unused int func ) {
    int strdel=0;
    char chr;
    if (ARGN != 3) Lerror(ERR_INCORRECT_CALL,0);
    get_s(1);    // string to change
    get_s(2);    // string delimeter typically " or '
    get_s(3);    // Blank replacement character
    LASCIIZ(*ARG1);

    Lstrcpy(ARGR,ARG1);
    for (int i=0; (size_t) i < LLEN(*ARGR);i++) {
        chr=LSTR(*ARGR)[i];
        if (strdel==1) {
            if (chr == LSTR(*ARG2)[0]) strdel = 0;
            else if(chr==' ') LSTR(*ARGR)[i]=LSTR(*ARG3)[0];
        }
        else if(chr==LSTR(*ARG2)[0]) strdel=1;
    }
}

/* -----------------------------------------------------------------------------------
 * Convert Number as unsigned integer to String
 * -----------------------------------------------------------------------------------
 */
void R_c2u( __unused int func )
{
    int n=0;
    unsigned int unum;
    n=sizeof(long);

    if (ARGN > 1) Lerror(ERR_INCORRECT_CALL,0);

    get_s(1);

    L2STR(ARG1);

    if (!LLEN(*ARG1)) {
        Licpy(ARGR,0);
        return;
    }

    Lstrcpy(ARGR,ARG1);
    Lreverse(ARGR);

    n = MIN(n,(int) LLEN(*ARG1));
    unum = 0;
    for (int i=n-1; i>=0; i--)
        unum = (unum << 8) | ((byte) (LSTR(*ARGR)[i]) & 0xFF);

    snprintf((char *) LSTR(*ARGR), LMAXLEN(*ARGR), "%u", unum);
    LTYPE(*ARGR)=LSTRING_TY;
    LLEN(*ARGR) = STRLEN(LSTR(*ARGR));
}

void R_dummy(__unused int func)
{
    int rc = 0;

    /*
    - link data into LSD-LSDDATA
    - LOAD von IKJSTCK
     */

    /* external function */
    typedef int ikjstck_func_t (IOPL iopl);
    typedef     ikjstck_func_t * ikjstck_func_p;
    static      ikjstck_func_p ikjstck;

    void *STPB[8]; // 8F = 32b
    void *LSD[4];  // 4F = 16b
    IOPL  iopl;    // 4F = 16b

    memset(STPB, 0, 32);
    memset(LSD, 0, 16);
    memset(&iopl, 0, 16);

    (void) updateIOPL(&iopl);

    LSD[3] = LSTR(*ARG1);
    STPB[1] = LSD;

    rc = loadLoadModule("IKJSTCK ", (void **)&ikjstck);
    printf("DBG> IKJSTCK called with RC=%d\n", rc);

    printf("DBG> calling IKJSTCK\n");

    iopl.IOPLIOPB = &STPB;

    rc = ikjstck(iopl);

    printf("DBG> done with RC=%d\n", rc);
}


#ifdef __DEBUG__
void R_magic(int func)
{
    void *pointer;
    long decAddr;
    int  count;
    char magicstr[64];

    char option='F';

    if (ARGN>1)
        Lerror(ERR_INCORRECT_CALL,0);
    if (exist(1)) {
        L2STR(ARG1);
        option = l2u[(byte)LSTR(*ARG1)[0]];
    }

    option = l2u[(byte)option];

    switch (option) {
        case 'F':
            pointer = mem_first();
            decAddr = (long) pointer;
            sprintf(magicstr,"%ld", decAddr);
            break;
        case 'L':
            pointer = mem_last();
            decAddr = (long) pointer;
            sprintf(magicstr,"%ld", decAddr);
            break;
        case 'C':
            count = mem_count();
            sprintf(magicstr,"%d", count);
            break;
        default:
            sprintf(magicstr,"%s", "ERROR");
    }

    Lscpy(ARGR,magicstr);
}

void R_test(int func)
{
    Lscpy(ARGR,"End Test");
}
#endif

//
// EXPORTED FUNCTIONS
//
int RxMvsInitialize()
{
    RX_INIT_PARAMS_PTR      init_parameter;
    RX_WORK_BLK_EXT_PTR     wrk_block;
    RX_PARM_BLK_PTR         parm_block;
    RX_SUBCMD_TABLE_PTR     subcmd_table;
    RX_SUBCMD_ENTRY_PTR     subcmd_entry;
    RX_SUBCMD_ENTRY_PTR     subcmd_entries;
    RX_IRXEXTE_PTR          irxexte;



    char IRXEXCOM[8] = "IRXEXCOM";

    int      rc     = 0;

#ifdef __DEBUG__
    printf("DBG> CPPL at %p\n", (void *) tsoCppl());
#endif

    init_parameter   = MALLOC(sizeof(RX_INIT_PARAMS), "RxMvsInitialize_init_parms");
    memset(init_parameter, 0, sizeof(RX_INIT_PARAMS));

    environment      = MALLOC(sizeof(RX_ENVIRONMENT_CTX), "RxMvsInitialize_environment");
    memset(environment, 0, sizeof(RX_ENVIRONMENT_CTX));

    init_parameter->rxctxadr = (unsigned *)environment;

    rc = call_rxinit(init_parameter);

#ifdef __MVS__
    /* JCC read stdin from DD STDIN whenever it is allocated (logon
     * procedure, JCL, or RXINIT above); libc370 reads DD SYSIN. */
    reopen(_STDIN);
#else
    if ((environment->flags3 & _STDIN) == _STDIN) {
        reopen(_STDIN);
    }
#endif
    if ((environment->flags3 & _STDOUT) == _STDOUT) {
        reopen(_STDOUT);
    }
    if ((environment->flags3 & _STDERR) == _STDERR) {
        reopen(_STDERR);
    }

    // save initial cppl
    if (isTSO()) {
        environment->cppl = tsoCppl();
    }

    environment->runId = getRunId();

    FREE(init_parameter);

    /* outtrap stuff */
    outtrapCtx = MALLOC(sizeof(RX_OUTTRAP_CTX), "RxMvsInitialize_outtrap_ctx");
    LINITSTR(outtrapCtx->varName);
    LINITSTR(outtrapCtx->ddName);
    Lscpy(&outtrapCtx->ddName, "BRXOUT  ");

    outtrapCtx->maxLines = 999999999;
    outtrapCtx->concat   = TRUE;
    outtrapCtx->skipAmt  = 0;

    arraygenCtx = MALLOC(sizeof(RX_ARRAYGEN_CTX), "RxMvsInitialize_arraygen_ctx");
    LINITSTR(arraygenCtx->varName);
    LINITSTR(arraygenCtx->ddName);
    Lscpy(&arraygenCtx->ddName, "ARRYDDN ");

    /* real rexx stuff */
    subcmd_entries = MALLOC(DEFAULT_NUM_SUBCMD_ENTRIES * sizeof(RX_SUBCMD_ENTRY), "RxMvsInitialize_subcmd_entries");
    memset(subcmd_entries, 0, DEFAULT_NUM_SUBCMD_ENTRIES * sizeof(RX_SUBCMD_ENTRY));

    subcmd_table = MALLOC(sizeof(RX_SUBCMD_TABLE), "RxMvsInitialize_subcmd_table");
    memset(subcmd_table, 0, sizeof(RX_SUBCMD_TABLE));

    // create MVS host environment
    subcmd_entry   = &subcmd_entries[subcmd_table->subcomtb_used];
    memcpy(subcmd_entry->subcomtb_name,    "MVS     ", 8);
    memcpy(subcmd_entry->subcomtb_routine, "IRXSTAM ", 8);
    memcpy(subcmd_entry->subcomtb_token,   "                ", 16);
    subcmd_table->subcomtb_used++;

    // create TSOX host environment
    subcmd_entry   = &subcmd_entries[subcmd_table->subcomtb_used];
    memcpy(subcmd_entry->subcomtb_name,    "TSO     ", 8);
    memcpy(subcmd_entry->subcomtb_routine, "IRXSTAM ", 8);
    memcpy(subcmd_entry->subcomtb_token,   "                ", 16);
    subcmd_table->subcomtb_used++;

    // create ISPF host environment
    subcmd_entry   = &subcmd_entries[subcmd_table->subcomtb_used];
    memcpy(subcmd_entry->subcomtb_name,    "ISPEXEC ", 8);
    memcpy(subcmd_entry->subcomtb_routine, "IRXSTAM ", 8);
    memcpy(subcmd_entry->subcomtb_token,   "                ", 16);
    subcmd_table->subcomtb_used++;

    // create FSS host environment
    subcmd_entry   = &subcmd_entries[subcmd_table->subcomtb_used];
    memcpy(subcmd_entry->subcomtb_name,    "FSS     ", 8);
    memcpy(subcmd_entry->subcomtb_routine, "IRXSTAM ", 8);
    memcpy(subcmd_entry->subcomtb_token,   "                ", 16);
    subcmd_table->subcomtb_used++;

    // create DYNREXX host environment
    subcmd_entry   = &subcmd_entries[subcmd_table->subcomtb_used];
    memcpy(subcmd_entry->subcomtb_name,    "DYNREXX ", 8);
    memcpy(subcmd_entry->subcomtb_routine, "IRXSTAM ", 8);
    memcpy(subcmd_entry->subcomtb_token,   "                ", 16);
    subcmd_table->subcomtb_used++;

    // create COMMAND host environment
    if (rac_check(FACILITY, DIAG8, READ)) {
        subcmd_entry   = &subcmd_entries[subcmd_table->subcomtb_used];
        memcpy(subcmd_entry->subcomtb_name,    "COMMAND ", 8);
        memcpy(subcmd_entry->subcomtb_routine, "IRXSTAM ", 8);
        memcpy(subcmd_entry->subcomtb_token,   "                ", 16);
        subcmd_table->subcomtb_used++;
    }

    // create CONSOLE host environment
    if (rac_check(FACILITY, SVC244, READ)) {
        subcmd_entry   = &subcmd_entries[subcmd_table->subcomtb_used];
        memcpy(subcmd_entry->subcomtb_name,    "CONSOLE ", 8);
        memcpy(subcmd_entry->subcomtb_routine, "IRXSTAM ", 8);
        memcpy(subcmd_entry->subcomtb_token,   "                ", 16);
        subcmd_table->subcomtb_used++;
    }

    memcpy(subcmd_table->subcomtb_initial, "MVS     ", 8);
    subcmd_table->subcomtb_first  = &subcmd_entries[0];
    subcmd_table->subcomtb_total  = DEFAULT_NUM_SUBCMD_ENTRIES;
    subcmd_table->subcomtb_length = DEFAULT_LENGTH_SUBCMD_ENTRIE;

    parm_block = MALLOC(sizeof(RX_PARM_BLK), "RxMvsInitialize_parm_block");
    memset(parm_block, 0, sizeof(RX_PARM_BLK));

    memcpy(parm_block->parmblock_id,       "IRXPARMS", 8);
    memcpy(parm_block->parmblock_version,  "0200",     4);
    memcpy(parm_block->parmblock_language, "ENU",      3);  //AmericanEnglisch
    parm_block->parmblock_subcomtb = subcmd_table;

    irxexte =  MALLOC(sizeof(RX_IRXEXTE), "RxMvsInitialize_irxexte");
    memset(irxexte, 0, sizeof(RX_IRXEXTE));

    wrk_block = MALLOC(sizeof(RX_WORK_BLK_EXT), "RxMvsInitialize_wrk_block");
    memset(wrk_block, 0, sizeof(RX_WORK_BLK_EXT));

    env_block = MALLOC(sizeof(RX_ENVIRONMENT_BLK), "RxMvsInitialize_env_block");
    memset(env_block, 0, sizeof(RX_ENVIRONMENT_BLK));

    memcpy(env_block->envblock_id,      "ENVBLOCK", 8);
    memcpy(env_block->envblock_version, "0100",     4);

    env_block->envblock_parmblock    = parm_block;
    env_block->envblock_irxexte      = irxexte;
    env_block->envblock_workblok_ext = wrk_block;
    env_block->envblock_userfield    = environment;
    env_block->envblock_length       = 320;

    if (findLoadModule(IRXEXCOM)) {
        loadLoadModule(IRXEXCOM, &irxexte->irxexcom);
    }

    if (isTSO()) {
        setEnvBlock(env_block);
    }

    environment->lastLeaf = 0;

    return rc;
}

void RxMvsTerminate()
{
    RX_TERM_PARAMS_PTR      term_parameter;
    RX_IRXEXTE_PTR          irxexte;
    RX_WORK_BLK_EXT_PTR     wrk_block;
    RX_PARM_BLK_PTR         parm_block;
    RX_SUBCMD_TABLE_PTR     subcmd_table;
    RX_SUBCMD_ENTRY_PTR     subcmd_entries;

    irxexte        = env_block->envblock_irxexte;
    wrk_block      = env_block->envblock_workblok_ext;
    parm_block     = env_block->envblock_parmblock;
    subcmd_table   = parm_block->parmblock_subcomtb;
    subcmd_entries = subcmd_table->subcomtb_first;


    FCLOSE(STDIN);
    FCLOSE(STDOUT);
    FCLOSE(STDERR);

    term_parameter   = MALLOC(sizeof(RX_TERM_PARAMS), "RxMvsTerminate_term_parameter");
    memset(term_parameter, 0, sizeof(RX_TERM_PARAMS));

    term_parameter->rxctxadr = (unsigned *)environment;
    (void) call_rxterm(term_parameter);

    setEnvBlock(0);

    if (subcmd_entries)
        FREE(subcmd_entries);

    if (subcmd_table)
        FREE(subcmd_table);

    if (parm_block)
        FREE(parm_block);

    if (wrk_block)
        FREE(wrk_block);

    if (irxexte)
        FREE(irxexte);

    if (env_block)
        FREE(env_block);

    if (outtrapCtx) {
        LFREESTR(outtrapCtx->ddName);
        FREE(outtrapCtx);
    }

    if (arraygenCtx) {
        LFREESTR(arraygenCtx->ddName);
        FREE(arraygenCtx);
    }

    rac_done();

    R_sfree(-1);
    R_mfree(-1);

    if (environment)
        FREE(environment);

}

void RxMvsRegFunctions()
{
    RxRacRegFunctions();
    RxTcpRegFunctions();
    RxNjeRegFunctions();
    RxLlRegFunctions();
    RxMatrixRegFunctions();
    RxIArrayRegFunctions();
    RxSArrayRegFunctions();
    RxDsnRegFunctions();
    RxRegexRegFunctions();

    /* MVS specific functions */
    RxRegFunction("ENCRYPT",    R_crypt,        0);
    RxRegFunction("DATTIMBASE", R_dattimbase,   0);
    RxRegFunction("DECRYPT",    R_decrypt,      0);
    RxRegFunction("DUMPIT",     R_dumpIt,       0);
    RxRegFunction("LISTIT",     R_listIt,       0);
    RxRegFunction("WAIT",       R_wait,         0);
    RxRegFunction("WTO",        R_wto ,         0);
    RxRegFunction("ABEND",      R_abend ,       0);
    RxRegFunction("USERID",     R_userid,       0);
    RxRegFunction("ROTATE",     R_rotate,       0);
    RxRegFunction("RHASH",      R_rhash,        0);
    RxRegFunction("__SYSVAR",   R_sysvar,       0);
    RxRegFunction("__MVSVAR",   R_mvsvar,       0);
    RxRegFunction("UPPER",      R_upper,        0);
    RxRegFunction("INT",        R_int,          0);
    RxRegFunction("JOIN",       R_join,         0);
    RxRegFunction("SPLIT",      R_split,        0);
    RxRegFunction("LOWER",      R_lower,        0);
    RxRegFunction("LASTWORD",   R_lastword,     0);
    RxRegFunction("VLIST",      R_vlist,        0);
    RxRegFunction("STEMHI",     R_stemhi,       0);
    RxRegFunction("FPOS",       R_fpos,         0);
    RxRegFunction("FCHANGESTR", R_fchangestr,   0);
//    RxRegFunction("_SPRINTF",    R_printf,      1);
    RxRegFunction("QUOTE",    R_quote,      1);
// Linked List functions
// String Array functions
    RxRegFunction("LCS",        R_lcs,          0);
// Matrix Integer functions
    RxRegFunction("MEMORY",     R_memory,       0);
    RxRegFunction("RXLIST",     R_rxlist,       0);
    RxRegFunction("ARGIN",      R_argin,        0);
    RxRegFunction("GETG",       R_getg,         0);
    RxRegFunction("SETG",       R_setg,         0);
    RxRegFunction("LEVEL",      R_level,        0);
    RxRegFunction("ARGV",       R_argv,         0);
    RxRegFunction("ENQ",        R_enq,          0);
    RxRegFunction("DEQ",        R_deq,          0);
    RxRegFunction("ERROR",      R_error,        0);
    RxRegFunction("CHAR",       R_char,         0);
    RxRegFunction("TYPE",       R_type,         0);
    RxRegFunction("OUTTRAP",    R_outtrap,      0);
    RxRegFunction("ARRAYGEN",   R_arraygen,     0);
    RxRegFunction("E2A",        R_e2a,          0);
    RxRegFunction("A2E",        R_a2e,          0);
    RxRegFunction("C2U",        R_c2u ,         0);
    RxRegFunction("STCSTOP",    R_stcstop ,     0);
    RxRegFunction("TERMINAL",   R_terminal,     0);
    RxRegFunction("OPTIONS",    R_options,      0);
    RxRegFunction("CONDITION",  R_condition,    0);
    RxRegFunction("MASKBLK",    R_maskblk,      0);

    if (rac_check(FACILITY, SVC244, READ)) {
        RxRegFunction("PRIVILEGE", R_privilege, 0);
        RxRegFunction("CONSOLE", R_console,0);
        RxRegFunction("MTT",     R_mtt ,   0);
        RxRegFunction("MTTX",    R_mttx ,  0);
    }

#ifdef __DEBUG__
    RxRegFunction("TEST",     R_test,         0);
    RxRegFunction("MAGIC",      R_magic,        0);
    RxRegFunction("DUMMY",      R_dummy,        0);
#endif
    R_screate(-512);
}

int isTSO() {
    int ret = 0;

    if ((environment->flags2 & _TSOFG) == _TSOFG ||
        (environment->flags2 & _TSOBG) == _TSOBG) {
        ret = 1;
    }

    return ret;
}

int isTSOFG() {
    return (environment->flags2 & _TSOFG) == _TSOFG;
}

void **tsoCppl(void)
{
#ifdef __MVS__
    /* libc370's startup keeps it in the PPA (libc370#210); JCC had it at
     * entry_R13[6] */
    CLIBPPA *ppa = __ppaget();

    return ppa != NULL ? (void **) ppa->ppacppl : NULL;
#else
    return NULL;
#endif
}

int isISPF() {
    int ret = 0;

    if ((environment->flags2 & _ISPF) == _ISPF) {
        ret = 1;
    }

    return ret;
}

int isEXEC() {
    int ret = 0;

    if ((environment->flags2 & _EXEC) == _EXEC) {
        ret = 1;
    }

    return ret;
}

void *_getEctEnvBk()
{
    void ** psa;           // PAS      =>   0 / 0x00
    void ** ascb;          // PSAAOLD  => 548 / 0x224
    void ** asxb;          // ASCBASXB => 108 / 0x6C
    void ** lwa;           // ASXBLWA  =>  20 / 0x14
    void ** ect;           // LWAPECT  =>  32 / 0x20
    void ** ectenvbk;      // ECTENVBK =>  48 / 0x30

    if (isTSO()) {
        psa  = 0;
        ascb = psa[137];    // NOSONAR: the PSA is at address 0 on MVS
        asxb = ascb[27];
        lwa  = asxb[5];
        ect  = lwa[8];

        // TODO use cast to BYTE and + 48
        ectenvbk = ect + 12;   // 12 * 4 = 48

    } else {
        ectenvbk = NULL;
    }

    return ectenvbk;
}

void *getEnvBlock()
{
    void **ectenvbk;
    void  *envblock;

    ectenvbk = _getEctEnvBk();

    if (ectenvbk != NULL) {
        envblock = *ectenvbk;
    } else {
        envblock = NULL;
    }

    return envblock;
}

void setEnvBlock(void *envblk)
{
    void ** ectenvbk;

    ectenvbk  = _getEctEnvBk();

    if (ectenvbk != NULL) {
        *ectenvbk = envblk;
    }
}


int getRunId()
{
    int runId = 0;

    if (environment->runId == 0) {
        srand((unsigned) time((time_t *)0)%(3600*24));
        runId = rand() % 9999;      // NOSONAR: a job-local id, not a secret
    } else {
        runId = environment->runId;
    }

    return runId;
}

//
// INTERNAL FUNCTIONS
//

int reopen(int fp) {


#ifdef __MVS__
    /* libc370 opens stdin as DD:SYSIN, else NULLFILE; the TSO foreground
     * has neither. Bind it to DD STDIN if that is allocated (to the
     * terminal in TSO). stdout and stderr already reach the terminal. */
    if (fp == _STDIN) {
        FILE *in = rxOpenDd("STDIN", "r");

        if (in != NULL) {
            if (stdin != NULL) {
                fclose(stdin);
            }
            stdin = in;
        }
    }
#endif

    return 0;
}
