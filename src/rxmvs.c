#include <stdlib.h>
#include <stdio.h>
#include <hashmap.h>
#include <rxtso.h>
#include "irx.h"
#include "rexx.h"
#include "rxdefs.h"
#include "rxmvsext.h"
#include "util.h"
#include "stack.h"
#include "math.h"

#include "rxtcp.h"
#include "rxnje.h"
#include "rxrac.h"
#include "dynit.h"
#include "smf.h"
#include "rac.h"
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

#ifdef JCC
extern FILE * stdin;
extern FILE * stdout;
extern FILE * stderr;

#include "time.h"
#endif

// TODO: must be moved into the environment context
HashMap *globalVariables;
int _authorisedNative=-1;
int _authorisedGranted=0;
static char savedEntry[81];    // keeps the first (most current) Trace Table entry

#define iError(rc,label) {iErr=rc;goto label;}

#ifdef __CROSS__
# include "jccdummy.h"
#else
extern char* _style;
extern void ** entry_R13;
extern int  __libc_tso_status;
extern long __libc_heap_used;
extern long __libc_heap_max;
extern long __libc_stack_used;
extern long __libc_stack_max;
#endif

//
//  INTERNAL FUNCTION PROTOTYPES
//
void parseArgs(char **array, char *str);
void parseDCB(FILE *pFile);
int reopen(int fp);

void Lcryptall(PLstr to, PLstr from, PLstr pw, int rounds,int mode);
int _EncryptString(const PLstr to, const PLstr from, const PLstr password);
void _rotate(PLstr to,PLstr from, int start,int slen);
void Lhash(const PLstr to, const PLstr from, long slots) ;

// TODO: new home needed for this stuff - used in R_dir()
/* ------------------------------------------------------------------------------------------------------------------ */
#define maxdirent 3000
#define endmark "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF"
#define UDL_MASK   ((int) 0x1F)
#define NPTR_MASK  ((int) 0x60)
#define ALIAS_MASK ((int) 0x80)

#define DEFAULT_NUM_SUBCMD_ENTRIES 10

#define DEFAULT_LENGTH_SUBCMD_ENTRIE 32

void julian2gregorian(int year, int day, char **date)
{
    static const int month_len[] = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };

    int leap = (year % 4 == 0) && (year % 100 != 0 || year % 400 == 0);
    int day_of_month = day;
    int month;

    for (month = 0; month < 12; month ++) {

        int mlen = month_len[month];

        if (leap && month == 1)
            mlen ++;

        if (mlen >= day_of_month)
            break;

        day_of_month -= mlen;

    }

    sprintf(*date, "%.2d-%.2d-%.2d", year, month+1, day_of_month);
}

int getYear(byte flag, byte yy) {
    int year = 0;

    char tmp[2];
    bzero(tmp, 2);

    sprintf(tmp, "%x", yy);
    sscanf (tmp, "%d", &year);

    /*
    if (flag == 0x01) {
        year = year + 2000;
    } else {
        year = year + 1900;
    }
    */

    return year;
}

int getDay(byte byte1, byte byte2) {
    int day = 0;

    char tmp[3];
    bzero(tmp, 3);

    sprintf(tmp, "%.1x%.1x%.1x", (byte1 >> 4) & 0x0F, byte1 & 0x0F, (byte2 >> 4) & 0x0F );
    sscanf(tmp, "%d", &day);

    return day;
}
/* ------------------------------------------------------------------------------------------------------------------ */



// TODO: new home needed for this stuff - used in R_dattimbase
/* ------------------------------------------------------------------------------------------------------------------ */
static char *months[] = {
        TEXT("January"), TEXT("February"), TEXT("March"),
        TEXT("April"), TEXT("May"), TEXT("June"),
        TEXT("July"), TEXT("August"), TEXT("September"),
        TEXT("October"), TEXT("November"), TEXT("December") };

int parseParm(PLstr parm,int parmi[10],int pmax,int from) {
    int i,j,wrds;
    Lstr word;
    LINITSTR(word);
    Lfx(&word,16);
    Lscpy(&word,",:.;/-");
    Lfilter(parm,parm,&word,'B');
    wrds=Lwords(parm);
    parmi[0]=0;

    for (i = from; i <= pmax; ++i) {
        if (wrds>=i) {
            Lword(&word, parm, i);
            LASCIIZ(word);
            if (_Lisnum(&word) == LINTEGER_TY) parmi[i] = lLastScannedNumber;
            else {
                for (j = 0; j < 12; ++j) {
                    if (strncasecmp(months[j], LSTR(word), 3) != 0) continue;
                    parmi[i] = j + 1;
                    break;
                }
                if (j == 12) {
                    printf("invalid date part: %s within %s\n", LSTR(word), LSTR(*parm));
                    Lerror(ERR_INCORRECT_CALL, 0);
                }
            }
        } else parmi[i]=0;
    }
    LFREESTR(word);

    return 0;
}

void datetimebase(PLstr to, char omod,PLstr indate,char imod) {
    int dnum=0;

    if (imod=='T' && omod=='B')  {
        L2INT(indate);
        sprintf(LSTR(*to), "%.24s", ctime(&LINT(*indate)));
    } else if (omod=='T')  {
        int a,m,y,yy,mm,dd, parmi[10];
        if (indate==NULL || LLEN(*indate)==0)
            sprintf((char *) LSTR(*to),"%d\0", (int) time(0));
        else {
            if (imod=='B') parseParm(indate, parmi, 10,2);    // Parse base date string into single parms from word 2
            else parseParm(indate, parmi, 10,1);       // Parse date string into single parms
            if (imod == 'O') { // Date Time format given in the format yyyy mm dd hour min sec
                yy = parmi[1];   // parmi 1=year 2=month 3=day 4=hour 5=min 6=sec
                mm = parmi[2];
                dd = parmi[3];
                goto calcDate;
            } else if (imod == 'E') { // Date Time format given in the format mm dd yyyy hour min sec
                yy = parmi[3];  // parmi 1=day 2=month 3=year 4=hour 5=min 6=sec
                mm = parmi[2];
                dd = parmi[1];
                goto calcDate;
            } else if (imod == 'U') { // INPUT format USA:  Date Time format given in the format mm dd yyyy mm dd hour min sec
                yy = parmi[3]; // parmi 1=month 2=day 3=year 4=hour 5=min 6=sec
                mm = parmi[1];
                dd = parmi[2];
                goto calcDate;// 1  2   3  4   5  6 7
            } else if (imod == 'B') { // INPUT format Base Time Stamp: Wed Dec 09 07:40:45 2020
                yy = parmi[7]; // parmi 1=n/a 2=month 3=day 4=hour 5=min 6=sec
                if (yy<100) yy=yy+2000;
                mm = parmi[2];
                dd = parmi[3];
                goto calcDate;
            } else Lfailure("invalid input format:",&imod,"","","");
            calcDate:
            a = (14 - mm) / 12;
            m = mm + 12 * a - 3;
            y = yy + 4800 - a;
            dnum = dd + (153 * m + 2) / 5 + 365 * y;
            dnum = dnum + y / 4 - y / 100 + y / 400 - 32045;
            dnum = ((dnum - 2440588) * 86400 + parmi[4] * 3600 + parmi[5] * 60 + parmi[6]);
            sprintf((char *) LSTR(*to), "%d", dnum);
        }
    } else Lfailure("invalid output format:",&omod,"","","");

    LTYPE(*to) = LSTRING_TY;
    LLEN(*to) = strlen(LSTR(*to));
}
/* ------------------------------------------------------------------------------------------------------------------ */

// TODO: new home needed for this stuff - used in R_outtrap
/* ------------------------------------------------------------------------------------------------------------------ */
void droplf(char *s)
{
    char *pos;
    if ((pos = strchr(s, '\n')) != NULL) {
        *pos = '\0';
    }
}

int get2variables(PLstr vname1,PLstr ddn, int maxrecs, int concat, int skipamt)
{
    unsigned char pbuff[4098];
    unsigned char vname2[19];
    unsigned char vname3[19];
    unsigned char obuff[4098];

    int recs = 0;

    FILE *f;

    f = fopen((const char *)LSTR(*ddn), "r");
    if (f == NULL) {
        return 8;
    }
    recs = 0;
    while (fgets(pbuff, 4096, f)) {
        if (maxrecs > 0 & recs>=maxrecs) break;
        if (skipamt == 0) {
            recs++;
            droplf(&pbuff[0]); // remove linefeed
            sprintf(vname2, "%s%d", (const char*) LSTR(*vname1), recs);  // edited stem name
            setVariable(vname2, pbuff);             // set rexx variable
        } else {
            skipamt--;
        }
    }  // end of while
    sprintf(vname2, "%s0", (const char*) LSTR(*vname1));
    sprintf(vname3, "%d", recs);
    setVariable(vname2, vname3);

    fclose(f);

    return 0;
}
/* ------------------------------------------------------------------------------------------------------------------ */



// TODO: new home needed for this stuff - unsorted yet
/* ------------------------------------------------------------------------------------------------------------------ */
int _EncryptString(const PLstr to, const PLstr from, const PLstr password) {
    int slen,plen, ki, kj;
    L2STR(from);
    L2STR(password);
    slen=LLEN(*from);
    plen=LLEN(*password);
    for (ki = 0, kj=0; ki < slen; ki++,kj++) {
        if (kj >= plen) kj = 0;
        LSTR(*to)[ki] = LSTR(*from)[ki] ^ LSTR(*password)[kj];
    }
    LLEN(*to) = (size_t) slen;
    LTYPE(*to) = LSTRING_TY;
    return slen;
}

// -------------------------------------------------------------------------------------
// Encrypt/Decrypt common Procedure
// -------------------------------------------------------------------------------------
void Lcryptall(PLstr to, PLstr from, PLstr pw, int rounds,int mode) {
    int plen, slen, ki,kj, hashv;
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
void _rotate(PLstr to, PLstr from, int start, int frlen) {
    int slen,rlen, istart=start,flen=frlen;

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
void Lhash(const PLstr to, const PLstr from, long slots) {
    int ki,value=0, pcn,pwr,islots=INT32_MAX;
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
        }

        for (ki = 0; ki < lhlen; ki++) {
            value = (value + (LSTR(*from)[ki]) * pwr)%islots;
            pwr = ((pwr * pcn) % islots);
        }
    }
    value=labs(value%slots);
    Licpy(to,labs(value));
}

// TODO: TEST
typedef struct mtt_header {
    char tableId[4];
    void *current;
    void *start;
    void *end;
    int subPoolLen;
    char wrapTime[12];
    void *wrapPoint;
    void *reserver1;
    int dataLength;
    void *reserved2[21];
} MTT_HEADER, *P_MTT_HEADER;

typedef struct mtt_entry_header {
    short flags;
    short tag;
    void *immData;
    short len;
    unsigned char callerData;
} MTT_ENTRY_HEADER, *P_MTT_ENTRY_HEADER;

int updateIOPL (IOPL *iopl)
{
    int rc = 0;

    void **cppl;
    byte *ect;
    byte *ecb;
    byte *upt;

    // this stuf is TSO only
    if (!isTSO()) {
        return -1;
    }

    cppl = entry_R13[6];
    upt  = cppl[1];
    ect  = cppl[3];

    ((void **)iopl)[0] = upt;
    ((void **)iopl)[1] = ect;

    return 0;
}

void getStemV(PLstr plsPtr, char *sName,int stemindx) {
    char vname[128];
    memset(vname, 0, sizeof(vname));
    sprintf(vname, "%s%d", sName, stemindx);
    getVariable(vname, plsPtr);
}
int getIntegerV(char *sName,int stemindx) {
    char vname[128];
    memset(vname, 0, sizeof(vname));
    sprintf(vname, "%s%d", sName, stemindx);
    return getIntegerVariable(vname);
}

int getStemV0(char *sName)  {
    char vname[128];
    memset(vname, 0, sizeof(vname));
    sprintf(vname, "%s0", sName);
    return getIntegerVariable(vname);
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
void R_enq(int func)
{
    int inflags;
    RX_ENQ_PARAMS enq_parameter;
    RX_SVC_PARAMS svc_parameter;

    if (ARGN !=2) Lerror(ERR_INCORRECT_CALL, 0);

    LASCIIZ(*ARG1)
    Lupper(ARG1);
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
void R_deq(int func)
{
    bool test  = FALSE;
    bool block = FALSE;
    int inflags;

    RX_ENQ_PARAMS enq_parameter;
    RX_SVC_PARAMS svc_parameter;

    if (ARGN < 1 || ARGN > 2)  Lerror(ERR_INCORRECT_CALL, 0);

    LASCIIZ(*ARG1)
    Lupper(ARG1);
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

void R_console(int func)
{
    RX_SVC_PARAMS svc_parameter;
    unsigned char cmd[128];

    if (ARGN !=1) Lerror(ERR_INCORRECT_CALL, 0);

    LASCIIZ(*ARG1)
    Lupper(ARG1);
    get_s(1)

    privilege(1);
    bzero(cmd, sizeof(cmd));
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

void R_privilege(int func) {
    int rc = 8;

    RX_SVC_PARAMS svc_parameter;

    if (ARGN != 1)
        Lerror(ERR_INCORRECT_CALL, 0);   // then NOP;

    /*
    if (!rac_check(FACILITY, PRIVILAGE, READ)) {
        RxSetSpecialVar(RCVAR, -3);
        return;
    }
    */

    LASCIIZ(*ARG1)
    Lupper(ARG1);
    get_s(1)

    if (strcmp((const char *) ARG1->pstr, "ON") == 0) {
        rc = privilege(1);
    } else if (strcmp((const char *) ARG1->pstr, "OFF") == 0) {
        rc = privilege(0);
    }

    Licpy(ARGR, rc);
}

void R_error(int func) {
    if (ARGN != 1)
        Lerror(ERR_INCORRECT_CALL,0);
    LASCIIZ(*ARG1)
    Lupper(ARG1);
    get_s(1)
    Lfailure(LSTR(*ARG1),"","","","");
}

void R_getg(int func)
{
    PLstr tmp;

    if (ARGN != 1)
        Lerror(ERR_INCORRECT_CALL,0);

    LASCIIZ(*ARG1)
    Lupper(ARG1);
    get_s(1)

    tmp = hashMapGet(globalVariables, (char *) LSTR(*ARG1));

    if (tmp && !LISNULL(*tmp)) {
        Lstrcpy(ARGR, tmp);
    } else {
        LZEROSTR(*ARGR)
    }
}

void R_setg(int func)
{
    PLstr pValue;

    if (ARGN != 2)
        Lerror(ERR_INCORRECT_CALL,0);

    LASCIIZ(*ARG1)
    Lupper(ARG1);
    get_s(1)

    LPMALLOC(pValue)
    Lstrcpy(pValue, ARG2);

    hashMapSet(globalVariables, (char *) LSTR(*ARG1), pValue);

    Lstrcpy(ARGR, ARG2);
}

void R_level(int func) {
    if (ARGN != 0)
        Lerror(ERR_INCORRECT_CALL, 0);
    Licpy(ARGR,_rx_proc);
}

/* ------------------------------------------------------------------------------------
 * Pick exactly one CHAR out of a string
 * ------------------------------------------------------------------------------------
 */
void R_char(int func) {
    char pad;
    int cnum;
    Lfx(ARGR,8);
    get_s(1);
    get_i(2,cnum);
    get_pad(3,pad);
    if (cnum<=LLEN(*ARG1)) pad=LSTR(*ARG1)[cnum-1];
    Lscpy(ARGR,&pad);
    LLEN(*ARGR)=1;
}

/* ------------------------------------------------------------------------------------
 * DateTime Main function
 * ------------------------------------------------------------------------------------
 */
void R_dattimbase(int func) {
    int dnum = 0;
    char imod, omod;

    if (ARG1==NULL) omod=' ';
    else {
        Lupper(ARG1);
        omod=LSTR(*ARG1)[0];
    }

    if (ARG3==NULL) imod=' ';
    else {
        Lupper(ARG3);
        imod=LSTR(*ARG3)[0];
    }

    if (imod == 'T' && _Lisnum(ARG2) != LINTEGER_TY)  Lfailure("invalid Date/in-format combination",LSTR(*ARG2),"/",&imod,"");
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

void R_outtrap(int func)
{
    int rc =0;

    RX_TSO_PARAMS  tso_parameter;
    void ** cppl;

    __dyn_t dyn_parms;

    if (ARGN < 1 || ARGN > 4) {
        Lerror(ERR_INCORRECT_CALL, 0);
    }

    if (__libc_tso_status != 1 ||  entry_R13 [6] == 0) {
        Lerror(ERR_INCORRECT_CALL, 0);
    }

    if (exist(1)) {
        get_s(1);
        LASCIIZ(*ARG1);
    }

    if (exist(2)) {
        if(LTYPE(*ARG2) == LINTEGER_TY) {
            outtrapCtx->maxLines = LINT(*ARG2);
        }
    }

    if (exist(3)) {
        get_s(3);
        LASCIIZ(*ARG1);
        if (strcasecmp("NOCONCAT", (const char *) LSTR(*ARG3)) == 0) {
            outtrapCtx->concat = FALSE;
        }
    }

    if (exist(4)) {
        if (LTYPE(*ARG4) == LINTEGER_TY) {
            outtrapCtx->skipAmt = LINT(*ARG4);
            if (outtrapCtx->skipAmt > 999999999) {
                outtrapCtx->skipAmt = 999999999;
            }
        }
    }

    cppl = entry_R13[6];

    memset(&tso_parameter, 00, sizeof(RX_TSO_PARAMS));
    tso_parameter.cppladdr = (unsigned int *) cppl;

    if (strcasecmp("OFF", (const char *) LSTR(*ARG1)) != 0) {
        // remember variable name
        memset(&outtrapCtx->varName,0,sizeof(&outtrapCtx->varName));
        Lstrcpy(&outtrapCtx->varName, ARG1);

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

void R_dumpIt(int func)
{
    void *ptr  = 0;
    int   size = 0;
    long  adr  = 0;

    if (ARGN > 2 || ARGN < 1) {
        Lerror(ERR_INCORRECT_CALL,0);
    }

    if (ARGN == 1) {

    } else {
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

void R_wto(int func)
{
    int msgId = 0;

    if (ARGN != 1)
        Lerror(ERR_INCORRECT_CALL,0);

    LASCIIZ(*ARG1);
    get_s(1);

    msgId = _write2op((char *)LSTR(*ARG1));

    LICPY(*ARGR, msgId);
}

void R_listIt(int func)
{
    BinTree tree;
    int	j;
    if (ARGN > 1 ) {
        Lstr lsFuncName,lsMaxArg;

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
        Lupper(ARG1);
        printf("List Variables with Prefix '%s'\n",ARG1->pstr);
        printf("%.*s\n", 29+ARG1->len,
               "-------------------------------------------------------");
        BinPrint(tree.parent, ARG1);
    }
}

void R_vlist(int func)
{
    BinTree tree;
    int	j,found=0;
    int mode=1;
    if (ARGN > 2 ) {
        Lstr lsFuncName,lsMaxArg;

        LINITSTR(lsFuncName)
        LINITSTR(lsMaxArg)

        Lfx(&lsFuncName,5);
        Lfx(&lsMaxArg, 4);

        Lscpy(&lsFuncName, "VList");
        Licpy(&lsMaxArg,2);

        Lerror(ERR_INCORRECT_CALL,4,&lsFuncName, &lsMaxArg);
    }

    if (ARG1 != NULL && ARG1->pstr == NULL) {
        printf("VLIST: invalid parameters, maybe enclose in quotes\n");
        Lerror(ERR_INCORRECT_CALL,4,1);
    }
    if (exist(2)) {
        L2STR(ARG2);
        Lupper(ARG2);
        if (LSTR(*ARG2)[0] == 'V') mode = 1;
        else if (LSTR(*ARG2)[0] == 'N') mode = 2;
    }

    tree = _proc[_rx_proc].scope[0];

    if (ARG1 == NULL || LSTR(*ARG1)[0] == 0) {
        found=BinVarDump(ARGR,tree.parent, NULL,mode);
    } else {
        LASCIIZ(*ARG1) ;
        Lupper(ARG1);
        if (LSTR(*ARG1)[LLEN(*ARG1)-1]=='.') {
            strcat(LSTR(*ARG1),"*");
            LLEN(*ARG1)=LLEN(*ARG1)+1;
        }
        found=BinVarDump(ARGR, tree.parent, ARG1,mode);
    }
    setIntegerVariable("VLIST.0", found);
}

void R_stemhi(int func)
{
    BinTree tree;
    int	found=0;

    if (ARGN !=1)  Lerror(ERR_INCORRECT_CALL,4,1);

    if (ARG1 == NULL || LSTR(*ARG1)[0] == 0) {
        // NOP
    } else {
        LASCIIZ(*ARG1) ;
        Lupper(ARG1);
        if (LSTR(*ARG1)[LLEN(*ARG1)-1]!='.') {
            strcat(LSTR(*ARG1),".");
            LLEN(*ARG1)=LLEN(*ARG1)+1;
        }
        tree = _proc[_rx_proc].scope[0];
        found=BinStemCount(ARGR,tree.parent, ARG1);
    }
    Licpy(ARGR ,found);
}

void R_bldl(int func) {
    int found=0;
    if (ARGN != 1 || LLEN(*ARG1)==0) Lerror(ERR_INCORRECT_CALL,0);
    LASCIIZ(*ARG1) ;
    Lupper(ARG1);

    if (findLoadModule((char *)LSTR(*ARG1))) found=1;
    Licpy(ARGR,found);
}

void R_upper(int func) {
    if (ARGN != 1) Lerror(ERR_INCORRECT_CALL,0);

    if (LTYPE(*ARG1) != LSTRING_TY) {
        L2str(ARG1);
    };
    LASCIIZ(*ARG1) ;
    Lupper(ARG1);
    Lstrcpy(ARGR,ARG1);
}

void R_lower(int func) {
    if (ARGN != 1) Lerror(ERR_INCORRECT_CALL,0);

    if (LTYPE(*ARG1) != LSTRING_TY) {
        L2str(ARG1);
    };
    LASCIIZ(*ARG1) ;
    Llower(ARG1);
    Lstrcpy(ARGR,ARG1);
}

void R_lastword(int func) {
    long	i=0, lwi=0, lwe=0;
    if (ARGN != 1) Lerror(ERR_INCORRECT_CALL,0);
    if (LLEN(*ARG1)==0) {
        LZEROSTR(*ARGR);
        return;
    }
    L2STR(ARG1);
    LASCIIZ(*ARG1) ;

    for (;;) {
        LSKIPBLANKS(*ARG1,i);
        if (i>=LLEN(*ARG1)) break;
        lwi=i;
        LSKIPWORD(*ARG1,i);
        lwe=i;
    }
    if (lwi>0)  _Lsubstr(ARGR,ARG1,lwi+1,lwe-lwi);
    else LZEROSTR(*ARGR);
}

void R_join(int func) {
    int mlen = 0, slen=0, i = 0,j=0;
    Lstr joins, tabin;
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
    slen=LLEN(*ARG2)-1;
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
        for (j = 0; j < LLEN(tabin); j++) {
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

void R_split(int func) {
    long i=0,j=0, n = 0, ctr=0;
    Lstr Word, tabin;
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
    Lupper(ARG2);
    LINITSTR(Word);
    Lfx(&Word,LLEN(*ARG1)+1);

    bzero(varName, 255);
// Loop over provided string
    for (;;) {
        //    SKIP to next Word, Drop all word delimiter
        for (i = i; i < LLEN(*ARG1); i++) {
            for (j = 0; j < LLEN(tabin); j++) {
                if (LSTR(*ARG1)[i] == LSTR(tabin)[j]) goto splitChar;  // split char found             }
            }
            break;
            splitChar:
            continue;
        }
        dropChar: ;
        if (i>=LLEN(*ARG1)) break;
//    SKIP to next Delimiter, scan word
        for (n = i; n < LLEN(*ARG1); n++) {
            for (j = 0; j < LLEN(tabin); j++) {
                if (LSTR(*ARG1)[n] == LSTR(tabin)[j]) goto splitCharf;  // split char found             }
            }
            continue;
            splitCharf:
            break;
        }
        //    Move Word into STEM
        ctr++;                    // Next word found, increase counter
        _Lsubstr(&Word,ARG1,i+1,n-i);
        LSTR(Word)[n-i]=NULL;     // set 0 for end of string
        LLEN(Word)=n-i;
        if (sdot==0) sprintf(varName, "%s.%i",LSTR(*ARG2) ,ctr);
        else sprintf(varName, "%s%i",LSTR(*ARG2) ,ctr);
        setVariable(varName, LSTR(Word));  // set stem variable
        i=n;                      // newly set string offset for next loop
    }
//  set stem.0 content for found words
    if (sdot==0) sprintf(varName, "%s.0",LSTR(*ARG2));
    else sprintf(varName, "%s0",LSTR(*ARG2));
    sprintf(LSTR(Word), "%ld", ctr);
    setVariable(varName, LSTR(Word));
    LFREESTR(Word);
    LFREESTR(tabin);
    Licpy(ARGR, ctr);   // return number if found words
}

void R_wait(int func)
{
    int val;

    time_t seconds;

    if (ARGN != 1)
        Lerror(ERR_INCORRECT_CALL,0);

    LASCIIZ(*ARG1);
    get_i (1,val);

    Sleep(val);
}

void R_abend(int func)
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

void R_userid(int func)
{
    char *userid = "n.a.";

    if (ARGN > 0) {
        Lerror(ERR_INCORRECT_CALL,0);
    }
#ifdef JCC
    userid = getlogin();
#endif
    Lscpy(ARGR, userid);
}

void R_listdsi(int func)
{
    char *args[2];

    char sFileName[45];
    char sFunctionCode[3];

    FILE *pFile;
    int flen=0;
    char sflen[9];
    int iErr;

    QuotationType quotationType;

    char* _style_old = _style;

    memset(sFileName,0,45);
    memset(sFunctionCode,0,3);

    iErr = 0;

    if (ARGN != 1)
        Lerror(ERR_INCORRECT_CALL,0);

    LASCIIZ(*ARG1);
    get_s(1);
    Lupper(ARG1);

    args[0]= NULL;
    args[1]= NULL;

    parseArgs(args, (char *)LSTR(*ARG1));

    if (args[1] != NULL && strcmp(args[1], "FILE") != 0)
        Lerror(ERR_INCORRECT_CALL,0);

    if (args[1] == NULL) {
        _style = "//DSN:";
        quotationType = CheckQuotation(args[0]);
        switch (quotationType) {
            case UNQUOTED:
                if (environment->SYSPREF[0] != '\0') {
                    strcat(sFileName, environment->SYSPREF);
                    strcat(sFileName, ".");
                    strcat(sFileName, (const char *) LSTR(*ARG1));
                }
                break;
            case PARTIALLY_QUOTED:
                strcat(sFunctionCode, "16");
                iErr = 2;
                break;
            case FULL_QUOTED:
                strncpy(sFileName, (const char *) (LSTR(*ARG1)) + 1, ARG1->len - 2);
                break;
            default:
                Lerror(ERR_DATA_NOT_SPEC, 0);


        }
    } else {
        strcpy(sFileName,args[0]);
        _style = "//DDN:";
    }

    if (iErr == 0) {
        char pbuff[4096];
        int records=0;
        pFile = FOPEN(sFileName,"R");
           if (pFile != NULL) {
              while (fgets(pbuff, 4096, pFile)) records++;  // just read 3 bytes to be safe including CRLF
              sprintf((char *)sflen, "%d", records);
              setVariable("SYSRECORDS", (char *)sflen);
              fseek(pFile, 0,SEEK_SET);
              strcat(sFunctionCode,"0");
              parseDCB(pFile);
              if (fseek(pFile, 0,SEEK_END)==0) flen=ftell(pFile);
              sprintf((char *)sflen, "%d", flen);
              setVariable("SYSSIZE", (char *)sflen);
              FCLOSE(pFile);
        } else {
            strcat(sFunctionCode,"16");
        }
    }

    Lscpy(ARGR,sFunctionCode);

    _style = _style_old;
}

void R_sysdsn(int func)
{
    char sDSName[45];
    char sMessage[256];

    unsigned char *ptr;

    FILE *pFile;
    int iErr;

    QuotationType quotationType;

    char* _style_old = _style;

    const char* MSG_OK                  = "OK";
    const char* MSG_NOT_A_PO            = "MEMBER SPECIFIED, BUT DATASET IS NOT PARTITIONED";
    const char* MSG_MEMBER_NOT_FOUND    = "MEMBER NOT FOUND";
    const char* MSG_DATASET_NOT_FOUND   = "DATASET NOT FOUND";
    const char* MSG_ERROR_READING       = "ERROR PROCESSING REQUESTED DATASET";
    const char* MSG_DATSET_PROTECTED    = "PROTECTED DATASET";
    const char* MSG_VOLUME_NOT_FOUND    = "VOLUME NOT ON SYSTEM";
    const char* MSG_DATASET_UNAVAILABLE = "UNAVAILABLE DATASET";
    const char* MSG_INVALID_DSNAME      = "INVALID DATASET NAME, ";
    const char* MSG_MISSING_DSNAME      = "MISSING DATASET NAME";

    memset(sDSName,0,45);
    memset(sMessage,0,256);

    iErr = 0;

    if (ARGN != 1)
        Lerror(ERR_INCORRECT_CALL,0);

    LASCIIZ(*ARG1);
    get_s(1);
    Lupper(ARG1);

    if (LSTR(*ARG1)[0] == '\0') {
        strcat(sMessage,MSG_MISSING_DSNAME);
        iErr = 1;
    }

    if (iErr == 0) {
        quotationType = CheckQuotation((char *)LSTR(*ARG1));
        switch(quotationType) {
            case UNQUOTED:
                if (environment->SYSPREF[0] != '\0') {
                    strcat(sDSName, environment->SYSPREF);
                    strcat(sDSName, ".");
                    strcat(sDSName, (const char*)LSTR(*ARG1));
                }
                break;
            case PARTIALLY_QUOTED:
                strcat(sMessage,MSG_INVALID_DSNAME);
                strcat(sMessage,(const char*)LSTR(*ARG1));
                iErr = 2;
                break;
            case FULL_QUOTED:
                strncpy(sDSName, (const char *)(LSTR(*ARG1))+1, ARG1->len-2);
                break;
            default:
                Lerror(ERR_DATA_NOT_SPEC,0);
        }
    }

    if (iErr == 0) {
        _style = "//DSN:";
        pFile = FOPEN(sDSName,"R");
        if (pFile != NULL) {
            strcat(sMessage, MSG_OK);
            FCLOSE(pFile);
        } else {
            strcat(sMessage,MSG_DATASET_NOT_FOUND);
        }
    }

    Lscpy(ARGR,sMessage);

    _style = _style_old;
}

void hostenv(int func) {
    int rc = 0,i=0;
    char *offset;
    char retbuf[320];
    byte *ect;
    byte *upt;
    void **cppl;

    memset(retbuf, '\0', sizeof(retbuf));

    if (isTSO()) cppl = entry_R13[6];
    else {
        Lscpy(ARGR,"failed, TSO required");
        return;
    }

    upt  = cppl[1];
    ect  = cppl[3];

    privilege(1);
    rc = systemCP(upt, ect, "CP QUERY CPLEVEL",16, retbuf,sizeof(retbuf));
    privilege(0);

    if (func==1) goto CPLEVEL;
    CPTYPE:
    if (strstr(retbuf, "HHC01600E")   != 0) Lscpy(ARGR, "Hercules");
    else if (strstr(retbuf, "VM/370") != 0) Lscpy(ARGR, "VM/370");
    else if (strstr(retbuf, "VM/ESA") != 0) Lscpy(ARGR, "VM/ESA");
    else if (strstr(retbuf, "VM/SP")  != 0) Lscpy(ARGR, "VM/SP");
    else if (strstr(retbuf, "VM")     != 0) Lscpy(ARGR, "VM");
    else Lscpy(ARGR, "UNKNOWN");
    return;

    CPLEVEL:
    if (strstr(retbuf, "HHC01600E") != 0) goto HercVersion;
    VMVersion:
    offset=strstr(retbuf, "VM/");
    if (offset==0) Lscpy(ARGR,retbuf);
    else {
        for (i = 0; offset[i] != '\0'; i++) {
            if (offset[i] == '\r' || offset[i] == '\n') {
                offset[i] = '\0';
                break;
            }
        }
        Lscpy(ARGR, offset);
    }
    return;

    HercVersion:
    privilege(1);
    rc = systemCP(upt, ect, "VERSION",7, retbuf,sizeof(retbuf));
    privilege(0);
    offset=strstr(retbuf, "Hercules");
    if (offset==0) Lscpy(ARGR,retbuf);
    else {
        for (i = 0; offset[i] != '\0'; i++) {
            if (offset[i] == 0x25) {
                offset[i] = '\0';
                break;
            }
        }
        Lscpy(ARGR, offset);
    }
    return;
}

void R_sysvar(int func)
{
    extern unsigned long long ullInstrCount;
    char *msg = "not yet implemented";

    if (ARGN != 1) {
        Lerror(ERR_INCORRECT_CALL,0);
    }

    LASCIIZ(*ARG1);
    get_s(1);
    Lupper(ARG1);

    if (strcmp((const char*)ARG1->pstr, "SYSUID") == 0) {
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
        Licpy(ARGR, _testauth());
    } else if (strcmp((const char*)ARG1->pstr, "RXINSTRC") == 0) {
        Licpy(ARGR, ullInstrCount);
    } else if (strcmp((const char*)ARG1->pstr, "SYSHEAP") == 0) {
        Licpy(ARGR, __libc_heap_used);
    } else if (strcmp((const char*)ARG1->pstr, "SYSSTACK") == 0) {
        Licpy(ARGR, __libc_stack_used);
    } else if (strcmp((const char*)ARG1->pstr, "SYSCPLVL") == 0) {
        if (rac_check(FACILITY, SVC244, READ)) {
            hostenv(1);  // return argument set in hostenv()
        }  else {
            char *error_msg = "not authorized";
            Lscpy(ARGR, error_msg);
        }
    } else if (strcmp((const char*)ARG1->pstr, "SYSCP") == 0) {
        if (rac_check(FACILITY, SVC244, READ)) {
            hostenv(0);  // return argument set in hostenv()
        }  else {
            char *error_msg = "not authorized";
            Lscpy(ARGR, error_msg);
        }
    } else if (strcmp((const char*)ARG1->pstr, "SYSNODE") == 0) {
        if (rac_check(FACILITY, SVC244, READ)) {
            char netId[8 + 1];                // 8 + \0
            char *sNetId = &netId[0];
            privilege(1);
            RxNjeGetNetId(&sNetId);
            privilege(0);

            Lscpy(ARGR, sNetId);
        } else {
            char *error_msg = "not authorized";
            Lscpy(ARGR, error_msg);
        }
    } else if (strcmp((const char*)ARG1->pstr, "SYSRACF") == 0 ||
               strcmp((const char*)ARG1->pstr, "SYSRAKF") == 0) {
        if (rac_status()) {
            Lscpy(ARGR, "AVAILABLE");
        } else {
            Lscpy(ARGR, "NOT AVAILABLE");
        }
    } else if (strcmp((const char*)ARG1->pstr, "SYSTERMID") == 0) {

        RX_GTTERM_PARAMS paramsPtr;

        typedef struct tScreenSize {
            byte bRows;
            byte bCols;
        } PRIMARY_SCREEN_SIZE, ALTERNATE_SCREEN_SIZE;

        PRIMARY_SCREEN_SIZE primaryScreenSize;
        ALTERNATE_SCREEN_SIZE alternateScreenSize;

        char termid[8 + 1];

        paramsPtr.primadr   = (unsigned int *) &primaryScreenSize;
        paramsPtr.altadr    = (unsigned int *) &alternateScreenSize;
        *paramsPtr.altadr  |= 0x80000000;
        paramsPtr.attradr   = 0;
        paramsPtr.termidadr = (unsigned int *) &termid;

        bzero(termid, 9);

        gtterm(&paramsPtr);

        fprintf(stdout, "FOO> SYSTERMID=%s\n", termid);
        fprintf(stdout, "FOO> SYSWTERM=%d\n", alternateScreenSize.bCols);
        fprintf(stdout, "FOO> SYSLTERM=%d\n", alternateScreenSize.bRows);
        /*
        fssPrimaryCols      = primaryScreenSize.bCols;
        fssPrimaryRows      = primaryScreenSize.bRows;
        fssAlternateCols    = alternateScreenSize.bCols;
        fssAlternateRows    = alternateScreenSize.bRows;
        */

    } else {
        Lscpy(ARGR,msg);
    }
}

void R_mvsvar(int func)
{
    char *msg = "not yet implemented";
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
    cvt  = psa[4];         //  16
    smca = cvt[49];        // 196
    smcasid =  smca + 4;   //  16
    csd  = cvt[165];       // 660

    if (ARGN != 1) {
        Lerror(ERR_INCORRECT_CALL,0);
    }

    LASCIIZ(*ARG1);
    get_s(1);
    Lupper(ARG1);

    if (strcmp((const char *) ARG1->pstr, "SYSNAME") == 0) {
        Lscpy2(ARGR, (char *) (smcasid), 4);
    } else if (strcmp((const char *) ARG1->pstr, "SYSSMFID") == 0) {
        Lscpy2(ARGR, (char *) (smcasid), 4);
    } else if (strcmp((const char *) ARG1->pstr, "CPUS") == 0) {
        sprintf(&chrtmp[0], "%x", (int) csd[2]);
        tempoff = &chrtmp[0] + 4;
        sprintf(chrtmp, "%4s\n", tempoff);
        Lscpy2(ARGR, chrtmp, 4);
    } else if (strcmp((const char *) ARG1->pstr, "CPU") == 0) {
        sprintf(chrtmp, "%x", cvt[-2]);
        Lscpy(ARGR, chrtmp);
    } else if (strcmp((const char *) ARG1->pstr, "SYSOPSYS") == 0) {
        cvt2 = (short *) cvt;
        sprintf(chrtmp, "MVS %.*s.%.*s", 2, cvt2 - 2, 2, cvt2 - 1);
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
/* ----- dropped way too slow!
void R_stemcopy(int func)
{
    BinTree *tree;
    PBinLeaf from, to, ptr ;
    Lstr tempKey, tempValue;

    LINITSTR(tempKey)
    LINITSTR(tempValue)

    Variable *varFrom, *varTo, *varTemp;

    if (ARGN!=2){
        Lerror(ERR_INCORRECT_CALL, 0);
    }

    // FROM
    Lupper(ARG1);
    LASCIIZ(*ARG1);

    // TO
    Lupper(ARG2);
    LASCIIZ(*ARG2);

    tree = _proc[_rx_proc].scope;

    // look up Source stem
    from = BinFind(tree, ARG1);
    if (!from) {
        printf("Invalid Stem %s\n", LSTR(*ARG1));
        Lerror(ERR_INCORRECT_CALL,0);
    }

    //  look up Target stem, must be available, later set it up
    to = BinFind(tree, ARG2);
    if (!to) {
        Lscpy(&tempKey,LSTR(*ARG2));
        Lcat(&tempKey,"$$STEMCOPY");
        setVariable(&tempKey,"");
        to = BinFind(tree, ARG2);
        if (!to) {
            printf("Target Stem missing %s\n", LSTR(*ARG2));
            Lerror(ERR_INCORRECT_CALL, 0);
        }
    }

    varFrom = (Variable *) from->value;
    varTo   = (Variable *) to->value;

    ptr = BinMin(varFrom->stem->parent);
    while (ptr != NULL) {
        Lstrcpy(&tempKey, &ptr->key);
        Lstrcpy(&tempValue, LEAFVAL(ptr));

        varTemp = (Variable *)MALLOC(sizeof(Variable),"Var");
        varTemp->value = tempValue;
        varTemp->exposed=((Variable *) ptr->value)->exposed;

//       BinAdd((BinTree *)varTo->stem, &tempKey, varTemp);

        ptr = BinSuccessor(ptr);
    }

    LFREESTR(tempKey)
    LFREESTR(tempValue)
}
*/


/* ---------------------------------------------------------------
 *  DIR( file )
 *    Exploiting Partitioned Data Set Directory Fields
 *      Part   I: http://www.naspa.net/magazine/1991/t9109019.txt
 *      Part  II: http://www.naspa.net/magazine/1991/t9110014.txt
 *      Part III: http://www.naspa.net/magazine/1991/t9111015.txt
 *    Using the System Status Index
 *                http://www.naspa.net/magazine/1991/t9104004.txt
 * ---------------------------------------------------------------
 */
void R_dir( const int func )
{
    int iErr;

    long   ii;

    FILE * fh;

    char   record[256];
    char   memberName[8 + 1];
    char   aliasName[8 + 1];
    char   ttr[6 + 1];
    char   version[5 + 1];
    char   creationDate[8 + 1];
    char   changeDate[8 + 1];
    char   changeTime[8 + 1];
    char   init[5 + 1];
    char   curr[5 + 1];
    char   mod[5 + 1];
    char   uid[8 + 1];

    unsigned char  *currentPosition;

    short  bytes;
    short  count;
    int    info_byte;
    short  numPointers;
    short  userDataLength;
    bool   isAlias;
    int    loadModuleSize;

    long   quit;
    short  l;
    char   sDSN[45];
    char   line[255];
    char   *sLine;
    int    pdsecount = 0;

    P_USER_DATA pUserData;

    if (ARGN != 1) {
        Lerror(ERR_INCORRECT_CALL,0);
    }

    must_exist(1);
    get_s(1)

    LASCIIZ(*ARG1)

#ifndef __CROSS__
    Lupper(ARG1);
#endif

    bzero(sDSN, 45);

    _style = "//DSN:";

    // get the correct dsn for the input file
    iErr = getDatasetName(environment, (const char*)LSTR(*ARG1), sDSN);

    // open the pds directory
    fh = fopen (sDSN, "rb,klen=0,lrecl=256,blksize=256,recfm=u,force");

    if (fh != NULL) {
        // skip length field
        fread(&l, 1, 2, fh);

        quit = 0;

        while (fread(record, 1, 256, fh) == 256) {

            currentPosition = (unsigned char *) &(record[2]);
            bytes = ((short *) &(record[0]))[0];

            count = 2;
            while (count < bytes) {

                if (memcmp(currentPosition, endmark, 8) == 0) {
                    quit = 1;
                    break;
                }

                bzero(line, 255);
                sLine = line;

                bzero(memberName, 9);
                sprintf(memberName, "%.8s", currentPosition);
                {
                    // remove trailing blanks
                    long   jj = 7;
                    while (memberName[jj] == ' ') jj--;
                    memberName[++jj] = 0;
                }
                sLine += sprintf(sLine, "%-8s", memberName);
                currentPosition += 8;   // skip current member name

                bzero(ttr, 7);
                sprintf(ttr, "%.2X%.2X%.2X", currentPosition[0], currentPosition[1], currentPosition[2]);
                sLine += sprintf(sLine, "   %-6s", ttr);
                currentPosition += 3;   // skip ttr

                info_byte = (int) (*currentPosition);
                currentPosition += 1;   // skip info / stats byte

                numPointers    = (info_byte & NPTR_MASK);
                userDataLength = (info_byte & UDL_MASK) * 2;

                // no load lib
                if ( numPointers == 0 && userDataLength > 0) {
                    int year = 0;
                    int day  = 0;
                    char *datePtr;

                    pUserData = (P_USER_DATA) currentPosition;

                    bzero(version, 6);
                    sprintf(version, "%.2d.%.2d", pUserData->vlvl, pUserData->mlvl);
                    sLine += sprintf(sLine, " %-5s", version);

                    bzero(creationDate, 9);
                    datePtr = (char *) &creationDate;
                    year = getYear(pUserData->credt[0], pUserData->credt[1]);
                    day  = getDay (pUserData->credt[2], pUserData->credt[3]);
                    julian2gregorian(year, day, &datePtr);
                    sLine += sprintf(sLine, " %-8s", creationDate);

                    bzero(changeDate, 9);
                    datePtr = (char *) &changeDate;
                    year = getYear(pUserData->chgdt[0], pUserData->chgdt[1]);
                    day  = getDay (pUserData->chgdt[2], pUserData->chgdt[3]);
                    julian2gregorian(year, day, &datePtr);
                    sLine += sprintf(sLine, " %-8s", changeDate);

                    bzero(changeTime, 9);
                    sprintf(changeTime, "%.2x:%.2x:%.2x", (int)pUserData->chgtm[0], (int)pUserData->chgtm[1], (int)pUserData->chgss);
                    sLine += sprintf(sLine, " %-8s", changeTime);

                    bzero(init, 6);
                    sprintf(init, "%5d", pUserData->init);
                    sLine += sprintf(sLine, " %-5s", init);

                    bzero(curr, 6);
                    sprintf(curr, "%5d", pUserData->curr);
                    sLine += sprintf(sLine, " %-5s", curr);

                    bzero(mod, 6);
                    sprintf(mod, "%5d", pUserData->mod);
                    sLine += sprintf(sLine, " %-5s", mod);

                    bzero(uid, 9);
                    sprintf(uid, "%-.8s", pUserData->uid);
                    sLine += sprintf(sLine, " %-8s",  uid);
                } else {
                    isAlias        = (info_byte & ALIAS_MASK);

                    loadModuleSize = ((byte) *(currentPosition + 0xA)) << 16 |
                                     ((byte) *(currentPosition + 0xB)) << 8  |
                                     ((byte) *(currentPosition + 0xC));

                    sLine += sprintf(sLine, " %.6x", loadModuleSize);

                    if (isAlias) {
                        bzero(aliasName, 9);
                        sprintf(aliasName, "%.8s", currentPosition + 0x18);
                        {
                            // remove trailing blanks
                            long   jj = 7;
                            while (aliasName[jj] == ' ') jj--;
                            aliasName[++jj] = 0;
                        }
                        sLine += sprintf(sLine, " %.8s", aliasName);
                    }
                }

                if (pdsecount == maxdirent) {
                    quit = 1;
                    break;
                } else {
                    char stemName[13]; // DIRENTRY (8) + . (1) + MAXDIRENTRY=3000 (4)
                    char varName[32];

                    bzero(stemName, 13);
                    bzero(varName, 32);

                    sprintf(stemName, "DIRENTRY.%d", ++pdsecount);

                    sprintf(varName, "%s.NAME", stemName);
                    setVariable(varName, memberName);

                    sprintf(varName, "%s.TTR", stemName);
                    setVariable(varName, ttr);

                    if ((((info_byte & 0x60) >> 5) == 0) && userDataLength > 0) {
                        sprintf(varName, "%s.CDATE", stemName);
                        setVariable(varName, creationDate);

                        sprintf(varName, "%s.UDATE", stemName);
                        setVariable(varName, changeDate);

                        sprintf(varName, "%s.UTIME", stemName);
                        setVariable(varName, changeTime);

                        sprintf(varName, "%s.INIT", stemName);
                        setVariable(varName, init);

                        sprintf(varName, "%s.SIZE", stemName);
                        setVariable(varName, curr);

                        sprintf(varName, "%s.MOD", stemName);
                        setVariable(varName, mod);

                        sprintf(varName, "%s.UID", stemName);
                        setVariable(varName, uid);
                    }

                    sprintf(varName, "%s.LINE", stemName);
                    setVariable(varName, line);
                }

                currentPosition += userDataLength;

                count += (8 + 4 + userDataLength);
            }

            if (quit) break;

            fread(&l, 1, 2, fh); /* Skip U length */
        }

        fclose(fh);
        _style = "//DDN:";
        setIntegerVariable("DIRENTRY.0", pdsecount);
        Licpy(ARGR,0);
    }  else Licpy(ARGR,8);
}

/* -------------------------------------------------------------------------------------
 * return integer value, REAL numbers will converted to integer, STRING parms lead to error
 * -------------------------------------------------------------------------------------
 */
void R_int( const int func ) {

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
void R_type( const int func ) {

    int ta;

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
        }
    }
}

/* -------------------------------------------------------------------------------------
 * Encrypt String
 * -------------------------------------------------------------------------------------
 */
void R_crypt(int func) {
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
void R_decrypt(int func) {
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
void R_rotate(int func) {
    int start, slen;
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
void R_rhash(int func) {
    int     slots=0;

    must_exist(1);
    get_oi0(2,slots);       /* is there a max slot given? */

    Lhash(ARGR,ARG1,slots);
}

/* -------------------------------------------------------------------------------------
 * Remove DSN
 * -------------------------------------------------------------------------------------
 */
void R_removedsn(int func)
{
    char sFileName[55];
    int remrc=-2, iErr=0,dbg=0;
    char* _style_old = _style;

    memset(sFileName,0,55);
    if (ARGN !=1) Lerror(ERR_INCORRECT_CALL,0);
    LASCIIZ(*ARG1)
#ifndef __CROSS__
    Lupper(ARG1);
#endif
    get_s(1)
    _style = "//DSN:";
    iErr = getDatasetName(environment, (const char *) LSTR(*ARG1), sFileName);
    // no errors occurred so far, perform the remove
    if (iErr == 0) remrc = remove(sFileName);
    else remrc=iErr;

    if (dbg==1) {
        printf("Remove %s\n",sFileName);
        printf("   RC  %i\n",remrc);
    }

    Licpy(ARGR,remrc);
    _style = _style_old;
}

/* -------------------------------------------------------------------------------------
 * Rename DSN-old,DSN-new
 * -------------------------------------------------------------------------------------
 */
void R_renamedsn(int func)
{
    char sFileNameOld[55];
    Lstr oldDSN, oldMember;
    char sFileNameNew[55];
    Lstr newDSN, newMember;
    char sFunctionCode[3];
    int renrc=-9, iErr=0, p=0, dbg=0;
    char* _style_old = _style;

    if (ARGN !=2) Lerror(ERR_INCORRECT_CALL,0);

    memset(sFileNameOld,0,55);
    memset(sFileNameNew,0,55);

    LASCIIZ(*ARG1)
    LASCIIZ(*ARG2)
    get_s(1)
    get_s(2)

#ifndef __CROSS__
    Lupper(ARG1);
    Lupper(ARG2);
#endif
// * ---------------------------------------------------------------------------------------
// * Split DSN and Member
// * ---------------------------------------------------------------------------------------
    splitDSN(&oldDSN, &oldMember, ARG1);
    splitDSN(&newDSN, &newMember, ARG2);
// * ---------------------------------------------------------------------------------------
// * Auto complete DSNs
// * ---------------------------------------------------------------------------------------
    _style = "//DSN:";
    iErr = getDatasetName(environment, (const char *) LSTR(oldDSN), sFileNameOld);
    if (iErr == 0) {
        iErr = getDatasetName(environment, (const char *) LSTR(newDSN), sFileNameNew);
        if (iErr != 0) renrc=-2;
    } else renrc=-2;
    if (iErr != 0) goto leave;
//* Add Member Names if there are any
    if (LLEN(oldMember)>0) {
        strcat(sFileNameOld, "(");
        strcat(sFileNameOld, (const char *) LSTR(oldMember));
        strcat(sFileNameOld, ")");
    }
    if (LLEN(newMember)>0) {
        strcat(sFileNameNew, "(");
        strcat(sFileNameNew, (const char *) LSTR(newMember));
        strcat(sFileNameNew, ")");
    }
// * ---------------------------------------------------------------------------------------
// * Test certain RENAME some scenarios
// * ---------------------------------------------------------------------------------------
    if (LLEN(oldMember)==0 && LLEN(newMember)!=0 || LLEN(oldMember)!=0 && LLEN(newMember)==0) goto incomplete;
    if (Lstrcmp(&oldDSN,&newDSN)==0 ){
        if (LLEN(oldMember)==0 && LLEN(newMember)==0) goto STequal;
        if (LLEN(oldMember)>0 && LLEN(newMember)>0) {
            if (strcmp((const char *) LSTR(oldMember),(const char *) LSTR(newMember))==0) goto STequal;
            goto doRename;  // perform Member Rename
        }
    }
    if (Lstrcmp(&oldDSN,&newDSN)!=0 ) {
        if (LLEN(oldMember) > 0 && LLEN(newMember) > 0) goto invalren;
        else if (LLEN(oldMember) == 0 && LLEN(newMember) == 0) goto doRename;
    }
    goto doRename;  // no match with special secenarious, just try the rename/*
// * ---------------------------------------------------------------------------------------
// * Incomplete Member definition in either from or to DSN
// * ---------------------------------------------------------------------------------------
    incomplete:
    if (dbg==1) printf("incomplete Member definition in Rename\n");
    renrc=-3;
    goto leave;
// * ---------------------------------------------------------------------------------------
// * From / To DSNs are equal, no Rename necessary
// * ---------------------------------------------------------------------------------------
    STequal:
    if (dbg==1) printf("Source and Target DSN are equal\n");
    renrc=-4;
    goto leave;
//  * ---------------------------------------------------------------------------------------
//  * DSN Rename and Member Rename at the same time are not allowed
//  * ---------------------------------------------------------------------------------------
    invalren:
    if (dbg==1) printf("Invalid Rename of DSN and Member at the same time\n");
    renrc = -5;
    goto leave;
// * ---------------------------------------------------------------------------------------
// * Perform the Rename
// * ---------------------------------------------------------------------------------------
    doRename:
#ifndef __CROSS__
    renrc = rename(sFileNameOld,sFileNameNew);
#else
    renrc=0;
#endif
// * ---------------------------------------------------------------------------------------
// * Clean up and exit
// * ---------------------------------------------------------------------------------------
    leave:
    if (dbg==1) {
        printf("Rename from %s\n",sFileNameOld);
        printf("         To %s\n",sFileNameNew);
        printf("         RC %i\n",renrc);
    }
    LFREESTR(oldDSN);
    LFREESTR(oldMember);
    LFREESTR(newDSN);
    LFREESTR(newMember);
    Licpy(ARGR,renrc);
    _style = _style_old;
}

/* -------------------------------------------------------------------------------------
 * DYNFREE  ddname
 * -------------------------------------------------------------------------------------
 */
void R_free(int func)
{
    int iErr=0,dbg=0;
    __dyn_t dyn_parms;

    if (ARGN !=1) Lerror(ERR_INCORRECT_CALL,0);

    LASCIIZ(*ARG1)
    get_s(1)

#ifndef __CROSS__
    Lupper(ARG1);
#endif

    dyninit(&dyn_parms);
    dyn_parms.__ddname = (char *) LSTR(*ARG1);

    iErr = dynfree(&dyn_parms);
    if (dbg==1) {
        printf("FREE DD %s\n",LSTR(*ARG1));
        printf("     RC %i\n",iErr);
    }

    Licpy(ARGR, iErr);
}

/* -------------------------------------------------------------------------------------
 * DYNALLOC ddname DSN SHR
 * -------------------------------------------------------------------------------------
 */
void R_allocate(int func) {
    int iErr = 0, dbg = 0;
    char *_style_old = _style;
    char sFileName[55];
    Lstr DSN, Member;
    __dyn_t dyn_parms;
    if (ARGN < 2 || ARGN > 3) Lerror(ERR_INCORRECT_CALL, 0);

    LASCIIZ(*ARG1)
    LASCIIZ(*ARG2)
    get_s(1)
    get_s(2)
    if (ARGN == 3) {
        LASCIIZ(*ARG3)
        Lupper(ARG3);
    }
#ifndef __CROSS__
    Lupper(ARG1);
    Lupper(ARG2);
#endif
    _style = "//DSN:";    // Complete DSN if necessary
    dyninit(&dyn_parms);
    dyn_parms.__ddname = (char *) LSTR(*ARG1);
    // free DDNAME, just in case it's allocated
    iErr = dynfree(&dyn_parms);

    if (strcmp((const char *) ARG2->pstr, "DUMMY") == 0) {
        dyn_parms.__misc_flags = __DUMMY_DSN;
        iErr = dynalloc(&dyn_parms);
    } else if (strcmp((const char *) ARG2->pstr, "INTRDR") == 0) {
        dyn_parms.__sysout = 'A';
        dyn_parms.__sysoutname = (char *) LSTR(*ARG2);
        dyn_parms.__lrecl = 80;
        dyn_parms.__blksize = 80;
        dyn_parms.__recfm = _F_;
        dyn_parms.__misc_flags = __PERM;
        iErr = dynalloc(&dyn_parms);
    } else if(strncmp((const char *) ARG2->pstr, "&&", strlen("&&")) == 0) {

        char * varName = (char *) LSTR(*ARG2) + 2;

        dyn_parms.__recfm = _FB_;
        dyn_parms.__lrecl = 80;
        dyn_parms.__blksize = 80;
        dyn_parms.__alcunit = __TRK;
        dyn_parms.__primary = 5;
        dyn_parms.__secondary = 6;
        dyn_parms.__unit = "VIO";
        dyn_parms.__status = __DISP_NEW & __DISP_DELETE;

        iErr = dynalloc(&dyn_parms);

        setVariable(varName, dyn_parms.__retdsn);

    } else {
        splitDSN(&DSN, &Member, ARG2);
        iErr = getDatasetName(environment, (const char *) LSTR(DSN), sFileName);
        if (iErr == 0) {
            dyn_parms.__dsname = (char *) sFileName;
            if (LLEN(Member)>0) dyn_parms.__member = (char *) LSTR(Member);
            if (ARGN==3 && strcasecmp(LSTR(*ARG3),"MOD") == 0) dyn_parms.__status = __DISP_MOD;
            else dyn_parms.__status = __DISP_SHR;
            iErr = dynalloc(&dyn_parms);
            if (dbg==1) {
                printf("ALLOC DD %s\n",LSTR(*ARG1));
                printf("     DSN %s\n",sFileName);
                if (LLEN(Member)>0)  printf("  Member %s\n",LSTR(Member));
                printf("      RC %i\n",iErr);
            }
        }
        LFREESTR(DSN);
        LFREESTR(Member);
    }
    Licpy(ARGR,iErr);

    _style = _style_old;
}

/* -------------------------------------------------------------------------------------
 * CREATE new Dataset
 * -------------------------------------------------------------------------------------
 */
void R_create(int func) {
    int iErr = 0,dbg=0;
    char sFileName[55];
    char sFileDCB[128];
    char *_style_old = _style;
    FILE *fk ; // file handle

    if (ARGN !=2) Lerror(ERR_INCORRECT_CALL, 0);

    LASCIIZ(*ARG1)
    LASCIIZ(*ARG2)
    get_s(1)
    get_s(2)

#ifndef __CROSS__
    Lupper(ARG1);
    Lupper(ARG2);
#endif
    memset(sFileDCB,0,80);
    strcat(sFileDCB, "WB, ");
    strcat(sFileDCB, (const char *) LSTR(*ARG2));
    _style = "//DSN:";    // Complete DSN if necessary
    iErr = getDatasetName(environment, (const char *) LSTR(*ARG1), sFileName);
    if (iErr == 0) {
        fk=FOPEN((char*) sFileName,"RB");
        if (fk!=NULL) { // File already defined, error
            FCLOSE(fk);
            if (dbg==1) printf("DSN already catalogued %s\n", sFileName);
            iErr = -2;
        }
    }
    if (iErr == 0) {
        fk=FOPEN((char*) sFileName,sFileDCB);
        if (fk!=NULL) { // File sucessfully created
            FCLOSE(fk);
            if (dbg==1) printf("DSN created successfully %s\n", sFileName);
            iErr = 0;
        } else {
            if (dbg==1) printf("DSN cannot be created %s\n", sFileName);
            iErr = -1;
        }
    }
    if (dbg==1) {
        printf("CREATE     %s\n",sFileName);
        printf("  DCB etc. %s\n",sFileDCB);
        printf("       RC  %i\n",iErr);
    }

    Licpy(ARGR,iErr);
    _style = _style_old;
}

/* -------------------------------------------------------------------------------------
 * EXISTS does Dataset exist
 * -------------------------------------------------------------------------------------
 */
void R_exists(int func) {
    int iErr = 0;
    char sFileName[55];
    char *_style_old = _style;
    FILE *fk; // file handle

    if (ARGN != 1) Lerror(ERR_INCORRECT_CALL, 0);

    LASCIIZ(*ARG1)
    get_s(1)
#ifndef __CROSS__
    Lupper(ARG1);
#endif
    _style = "//DSN:";    // Complete DSN if necessary
    iErr = getDatasetName(environment, (const char *) LSTR(*ARG1), sFileName);
    if (iErr == 0) {
        fk = FOPEN((char *) sFileName, "RB");
        if (fk != NULL) { // File already defined, error
            FCLOSE(fk);
            iErr = 1;
        } else iErr=0;
    }
    Licpy(ARGR,iErr);
    _style = _style_old;
}

/* -------------------------------------------------------------------------------------
 * Load and execute external REXX qualified with dsname
 * -------------------------------------------------------------------------------------
 */
void R_exec(int func) {

}

/* -------------------------------------------------------------------------------------
 * String Array
 * -------------------------------------------------------------------------------------
 */
#define sarraymax 32
#define sswap(ix1,ix2) {swap=sindex[ix1]; \
          sindex[ix1]=sindex[ix2]; \
          sindex[ix2]=swap;}
#define sstring(ix) sindex[ix] + sizeof(int)
char *sarray[32];
int  sindxhi[32];
char **sindex;
int  sarrayhi[32];

void R_screate(int func) {
    int sname,imax;
    if (func>0 ) imax=func;
    else get_i(1,imax);
    if (imax<50) imax=50;
     for (sname = 0; sname <= sarraymax; ++sname) {
        if (sarray[sname] == 0) break;
    }
    if (sname > sarraymax) Lfailure ("String Array Stack stack full, no allocation occurred", "", "", "", "");
    if (sname==0) memset(sarray, 0, sarraymax*sizeof(char *));
    sindex = MALLOC(imax*sizeof(char*), "SINDEX");
    sarray[sname]= (char *) sindex;
    sindxhi[sname]=imax;
    sarrayhi[sname]=0;
    memset(sindex, 0, imax*sizeof(char *));
    Licpy(ARGR, sname);
}

void snew(int index,char *string,int llen) {
    int mlen;
    if (llen<=0) mlen = (strlen(string) + 1 + 16) * sizeof(char) + sizeof(int);
    else mlen=llen;
    sindex[index] = MALLOC(mlen, "SSTRING");
    *sindex[index] = mlen;
    strcpy(sindex[index] + sizeof(int), string);
}

void sset(int index,PLstr string) {
    int mlen,mlen2;
    LASCIIZ(*string);
    mlen = (LLEN(*string) + 1 + 16) * sizeof(char) + sizeof(int);
    if (sindex[index] == 0) snew(index,LSTR(*string),mlen);
    else {
        mlen2 = (LLEN(*string) + 1) * sizeof(char) + sizeof(int);
        if (mlen2 > *sindex[index]) {
            FREE(sindex[index]);
            sindex[index] = MALLOC(mlen, "SSTRING");
            *sindex[index] = mlen;
        }
        strcpy(sindex[index] + sizeof(int), LSTR(*string));
    }
 }

void R_sset(int func) {
    int sname,index,mlen,mlen2,jj;
    get_i0(1,sname);
    sindex= (char **) sarray[sname];
    get_i(2,index);
    index--;
    for (jj = 2; jj < ARGN; ++jj) { // Allow adding of more than one value
       // dynamic get_s(jj)
        if ((rxArg.a[jj])==((void*)0))Lerror(40, 0);
        if (((*((rxArg.a[jj]))).type)!=LSTRING_TY)L2str(((rxArg.a[jj])));
        sset(index,rxArg.a[jj]);
        index++;
    }
    if (index>sarrayhi[sname]) sarrayhi[sname]=index;
    Licpy(ARGR,0);
}
void R_sget(int func) {
    int sname,index;
    get_i0(1,sname);
    get_i(2,index);
    index--;
    sindex= (char **) sarray[sname];
    if (sindex[index]==0)  Lscpy(ARGR,"");
    else Lscpy(ARGR,sstring(index));
}
void R_sswap(int func) {
    int sname, ix1, ix2;
    char * swap;
    get_i0(1, sname);
    get_i(2, ix1);
    get_i(3, ix2);
    ix1--;
    ix2--;
    sindex = (char **) sarray[sname];
    sswap(ix1,ix2);

    Licpy(ARGR,0);
}
void R_sclc(int func) {
    int sname, ix1, ix2;
    get_i0(1, sname);
    get_i(2, ix1);
    get_i(3, ix2);
    ix1--;
    ix2--;
    sindex = (char **) sarray[sname];
    Licpy(ARGR,strcmp(sstring(ix1),sstring(ix2)));
}

void R_sfree(int func) {
    int sname,index,ii,jj;
    if (ARGN == 0) {
        for (jj = 0; jj <= sarraymax; ++jj) {
            if (sarray[jj] == 0) continue;
            sindex= (char **) sarray[jj];
            for (ii = 0; ii < sindxhi[jj]; ++ii) {
                if (sindex[ii] == 0) continue;
                FREE(sindex[ii]);
            }
            FREE(sindex);
            sarray[jj]=0;
        }
    } else {
        get_i0(1, sname);
        if (sarray[sname] != 0) {
            sindex = (char **) sarray[sname];
            for (ii = 0; ii < sindxhi[sname]; ++ii) {
                if (sindex[ii] == 0) continue;
                FREE(sindex[ii]);
            }
            FREE(sindex);
        }
    }
    Lscpy(ARGR,0);
}

void bsort(int from,int to) {
   int ii,j,sm;
   char * sw;

    for (ii = from; ii <= to; ++ii) {
        sm = ii;
        for (j = ii + 1; j <= to; ++j) {
            if (strcmp(sindex[j] + sizeof(int), sindex[sm] + sizeof(int)) < 0) sm = j;
        }
        sw = sindex[ii];
        sindex[ii] = sindex[sm];
        sindex[sm] = sw;
    }
}

void sqsort(int from, int to,int level) {
    int i, j, pivot;
    char *swap;

  //  if (from >= to) return;  should not happen
    pivot = (to+from)/2;
    i = from;
    j = to;
    while (i < j) {
        while (strcmp(sindex[i] + sizeof(int), sindex[pivot] + sizeof(int)) <= 0 && i < to)
            i++;
        while (strcmp(sindex[j] + sizeof(int), sindex[pivot] + sizeof(int)) > 0)
            j--;

        if (i < j) sswap(i,j);
    }

    sswap(pivot,j);

    if (from<j-1) {
        if (j-1-from>15) sqsort(from, j - 1, level + 1);
        else bsort(from, j - 1);
    }
    if (j+1<to) {
        if (to-j+1>15) sqsort(j + 1, to, level + 1);
        else bsort(j + 1, to);
    }
}

void shsort(int from,int to) {
    int i, j, k,complete;
    char *sw;
    i = from;
    j = to;
    k = (from + to) / 2;
    while (k>0) {
       for (;;) {
           complete=1;
           for (i = 0; i <= to-k; ++i) {
               j=i+k;
               if (strcmp(sstring(i),sstring(j))>0) {
                  sw = sindex[i];
                  sindex[i] = sindex[j];
                  sindex[j] = sw;
                  complete=0;
               }
           }
           if(complete) break;
       }
       k=k/2;
    }
}

void sreverse(int sname) {
    int shi,i, m;
    char *sw;

    sindex= (char **) sarray[sname];
    shi=sarrayhi[sname] - 1;
    m=shi/2;
    for (i = 0; i <= m; ++i) {
        sw = sindex[i];
        sindex[i] = sindex[shi];
        sindex[shi] = sw;
        shi--;
    }
}

void R_sqsort(int func) {
    int sname, i;
    char *sw, mode;

    get_i0(1, sname);
    get_modev(2,mode,'A');

    sindex= (char **) sarray[sname];
    sqsort(0, sarrayhi[sname]-1,0);

    Licpy(ARGR,sarrayhi[sname]); // return number of sorted items
    if (mode=='D') sreverse(sname);             // ascending, do nothing
 }

void R_shsort(int func) {
    int sname, i;
    char *sw, mode;

    get_i0(1, sname);
    get_modev(2,mode,'A');

    sindex= (char **) sarray[sname];
    shsort(0, sarrayhi[sname]-1);

    Licpy(ARGR,sarrayhi[sname]); // return number of sorted items
    if (mode=='D') sreverse(sname);             // ascending, do nothing
}
void R_sreverse(int func) {
    int sname;

    get_i0(1, sname);
    sindex= (char **) sarray[sname];

    Licpy(ARGR,sarrayhi[sname]-1); // return number of sorted items
    sreverse(sname);                        // reverse array order
}
void R_sarray(int func) {
    int sname;

    get_i0(1, sname);
    sindex= (char **) sarray[sname];

    Licpy(ARGR,sarrayhi[sname]); // return number of sorted items
    setIntegerVariable("sarrayhi", sarrayhi[sname]);
    setIntegerVariable("sarraymax",sindxhi[sname]);
    setIntegerVariable("sarrayADDR", (int) sindex);
}

void R_sread(int func) {
    int sname,recs=0,ssize=500,ii;
    FILE *fk; // file handle
    char record[16385];
    char *pos;
    R_screate(ssize);
    sname=LINT(*ARGR);
    sindex= (char **) sarray[sname];

    get_s(1);
    LASCIIZ(*ARG1);
    Lupper(ARG1);
    fk=fopen(LSTR(*ARG1), "R");
    for (;;) {
        fgets(record, sizeof(record)-1, fk);
        if(feof(fk)) break;
        if ((pos = strchr(record, '\n')) != NULL) *pos = '\0';
        if (recs>sindxhi[sname]) {
            if (ssize<8192) ssize=ssize*2;
            else ssize=ssize+2000;
            sarray[sname] = REALLOC((void *) sarray[sname], ssize * sizeof(char *));
            sindex= (char **) sarray[sname];
          //  printf("ReAlloc %d %d %x\n",recs,ssize,sarray[sname]);
            sindxhi[sname]=ssize;
        } // else printf("fits in %d %s\n",recs,record);
        snew(recs, record, 0);
        recs++;    // record count starts with position 0

    }
    fclose(fk);
    sindxhi[sname]=recs+50;
    sarrayhi[sname]=recs;
   // sarray[sname] = REALLOC((void *) sarrayhi[sname], sindxhi[sname] * sizeof(char *));
    setIntegerVariable("sarrayhi", sarrayhi[sname]);
    setIntegerVariable("sarraymax",sindxhi[sname]);

    Licpy(ARGR,sname);
}

void R_swrite(int func) {
    int sname,ii;
    FILE *fk; // file handle

    get_i0(1, sname);
    sindex= (char **) sarray[sname];

    get_s(2);
    LASCIIZ(*ARG2);
    Lupper(ARG2);
    fk=fopen(LSTR(*ARG2), "W");
    for (ii=0;ii<sarrayhi[sname];ii++) {
        fputs(sstring(ii),fk);
        fputs ("\n", fk);
    }
    fclose(fk);
    Licpy(ARGR, (long) sarrayhi[sname]);
}

void R_ssearch(int func) {
    int sname,ii,from=1;
    char mode;
    get_i0(1, sname);
    sindex= (char **) sarray[sname];

    get_s(2);
    LASCIIZ(*ARG2);         // search string
    get_oiv(3,from,1);   // optional from parameter
    from--;
    get_modev(4,mode,'C');        // case/nocase parameter

    if (mode=='N') {  // noCase  not case sensitive
        Lupper(ARG2);
        for (ii = from; ii < sarrayhi[sname]; ii++) {
            Lscpy(ARGR,sindex[ii]);
            Lupper(ARGR);
            if ((int) strstr(LSTR(*ARGR), LSTR(*ARG2)) > 0) goto found;
        }
    }
    else {     // CASE  case sensitive
        for (ii = 0; ii < sarrayhi[sname]; ii++) {
            if ((int) strstr(sindex[ii], LSTR(*ARG2)) > 0) goto found;
        }
    }
    Licpy(ARGR, 0) ;
    return;
    found:
    Licpy(ARGR, ii+1);
}

void R_sselect(int func) {
    int sname, s1, k, ii, jj = 0,llen, from[99], to[99], zone = 0, slen = 0;
    Lstr temp;
    LINITSTR(temp);
    get_i0(1, sname);
    get_s(2);
    LASCIIZ(*ARG2);           // search string
    R_screate(sarrayhi[sname]);
    s1 = LINT(*ARGR);
    for (k = 2,ii=1; k <= ARGN; k++,ii++) {
        get_sv(k);
        from[ii] = getIntegerV("sselect.from.", ii);
        to[ii] = getIntegerV("sselect.length.", ii);
        if (to[ii] == 0) to[ii] = -1;
        printf("zone %d %d %d \n", ii,from[ii], to[ii]);
    }
    sindex = (char **) sarray[sname];
    for (ii = 0; ii < sarrayhi[sname]; ii++) {
        for (k = 1; k < ARGN; k++) {
 //           printf("String %s %s %d %d \n",sstring(ii),((*(rxArg.a[k])).pstr),ii,k);
            if (from[k]==0) {
                if ((int) strstr(sstring(ii), ((*(rxArg.a[k])).pstr)) > 0) goto copy;
            } else {
                   Lscpy(&temp, sstring(ii));
                   Lsubstr(ARGR, &temp, from[k], to[k], ' ');
                   llen = LLEN(*ARGR);
                   LSTR(*ARGR)[llen] = '\0';     // set null terminator, not set by Lsubstr
                   if ((int) strstr(LSTR(*ARGR), ((*(rxArg.a[k])).pstr)) > 0) goto copy;
                   }
               }
            continue;
            copy:
            Lscpy(ARGR, sstring(ii));
            sindex = (char **) sarray[s1];
            snew(jj, LSTR(*ARGR), -1);
            jj++;
            sindex = (char **) sarray[sname];
    }

    LFREESTR(temp);
    sarrayhi[s1] = jj;
    Licpy(ARGR, s1);
}

void R_smerge(int func) {
    int s1,s2,s3,i,ii=0,ji=0,smax;
    char *sw1, *sw2;
    get_i0(1, s1);
    get_i0(2, s2);
    smax=sarrayhi[s1]+sarrayhi[s2];
    sindex= (char **) sarray[s1];
    sqsort(0, sarrayhi[s1]-1,0);
    sindex= (char **) sarray[s2];
    sqsort(0, sarrayhi[s2]-1,0);
    R_screate(smax);
    s3=LINT(*ARGR);               // save new sarray token

    sindex= (char **) sarray[s1];
    sw1=sstring(ii);
    sindex= (char **) sarray[s2];
    sw2=sstring(ji);

    for (i = 0; i < smax; ++i) {
        if (ii>=sarrayhi[s1]) goto sets2;
        if (ji>=sarrayhi[s2]) goto sets1;
        if (strcmp(sw1,sw2)<0) {
          sets1:
           sindex= (char **) sarray[s3];
           snew(i,sw1,0);
           ii++;         // set to next entry
           sindex= (char **) sarray[s1];
           sw1=sstring(ii);
        } else {
          sets2:
           sindex= (char **) sarray[s3];
           snew(i,sw2,0);
           ji++;         // set to next entry
           sindex= (char **) sarray[s2];
           sw2=sstring(ji);
        }
    }
    sarrayhi[s3]=smax;
    Licpy(ARGR,s3); // return number of sorted items
}

void R_sprint(int func) {
    int sname,ii,from,to;

    get_i0(1, sname);
    sindex= (char **) sarray[sname];

    get_oiv(2,from,1);
    get_oiv(3,to,sarrayhi[sname]);

    for (ii=from-1;ii<to;ii++) {
        printf("%0.5d   %s\n",ii+1,sstring(ii));
    }
     Licpy(ARGR, 0);
}



/* -------------------------------------------------------------------------------------
 * Linked List
 * -------------------------------------------------------------------------------------
 */
#define llmax 32
#define llMagic	  0xCAFEBABE

struct node {
    int  *next;
    int  *previous;
    int  magic;
    char data[8];
};
struct root {
    int  *next;
    int  *previous;
    char name[16];
    char flags;
    char reserved[3];
    int  count;
    int  added;
    int  deleted;
    int  *last;
};
struct root *llist[llmax];
struct node *llistcur[llmax];
int llchecked=-1;    // last checked Linked List
#define linknode(predecessor,node,successor) {predecessor->next= (int *) node; \
                               node->next=successor;\
                               node->previous= (int *) predecessor;}
#define updatenode(node,predecessor,successor) {node->next=successor;\
                               node->previous= (int *) predecessor;}
// #define getllname(list) {get_i0(1, list);if (list!=llchecked) llcheck(list);}
#define getllname(list) get_i0(1, list);
#define CHECK_BIT(var,pos) ((var) & (1<<(pos)))
#define llADDRreturn(addr) {if (llist[llname]->flags == 0) Licpy(ARGR,(long) addr); \
                            else {sprintf(sNumber, "%x", addr); \
                            Lscpy(ARGR, sNumber);}              \
                            return;}

struct node* llSetADDR(PLstr address, int llname) {
    struct node *addr;
    if (llist[llname]->flags == 0)  addr = (struct node *) LINT(*address);
    else {
        Lx2d(ARGR, address, 0);    /* using ARGR as temp field for conversion */
        addr = (struct node *) Lrdint(ARGR);
    }
    if (addr == NULL) Lerror(ERR_INCORRECT_CALL,0);
    if (addr->magic!=llMagic) Lfailure ("Invalid Linked List entry address", LSTR(*ARG3), "", "", "");
    return addr;
}
int llcheck(int llname) {
    char sllname[16];
    if (llname > llmax) {
        sprintf(sllname, "%d", llname);
        Lfailure("invalid Linked List specified: ", sllname, "", "", "");
    }
    if (llist[llname] == 0) {
        sprintf(sllname, "%d", llname);
        Lfailure("Linked List not yet initialised: ", sllname, "", "", "");
    }
    llchecked=llname;     // successfully checked
    return 0;
}

void R_llcreate(int func) {
    int llname;
    struct root * head = NULL;

    for (llname = 0; llname <= llmax; ++llname) {
        if (llist[llname] == 0) break;
    }
    if (llname > llmax) Lfailure ( "Linked List Stack stack full, no allocation occurred","","","","");
    llist[llname] = MALLOC(sizeof(struct root),"LLROOT");
    memset(llist[llname],0,sizeof(struct root));
    if (ARGN==0) strcpy(llist[llname]->name, "UNNAMED");
    else {
        get_s(1)
        LASCIIZ(*ARG1);
        strcpy(llist[llname]->name,(const char *) LSTR(*ARG1));
    }
    llistcur[llname]= (struct node *) llist[llname];
    llist[llname]->next=0 ;
    llist[llname]->previous=0 ;
    llist[llname]->last=0 ;
    llist[llname]->count=0 ;
    llist[llname]->added=0 ;
    llist[llname]->deleted=0 ;
    llist[llname]->flags= 0;

    Licpy(ARGR,llname);
}
void R_lladd(int func) {
    struct node *new = NULL, *current;
    int llname;
    char sNumber[32];
    getllname(llname);
    LASCIIZ(*ARG2)
    current = (struct node *) llist[llname]->last;
    if (current == NULL) current = (struct node *) llist[llname];
    new = MALLOC(sizeof(struct node) + LLEN(*ARG2), "LLENTRY");
    new->next = NULL;
    new->magic = llMagic;
    strcpy(new->data, (const char *) LSTR(*ARG2));
    linknode(current, new, NULL);

    llistcur[llname] = new;
    llist[llname]->last = (int *) new;
    llist[llname]->count++;
    llist[llname]->added++;
    llADDRreturn(new);
}
void R_llinsert(int func) {
    struct node *new = NULL, *current, *fwd,*prev;
    int llname ;
    char sNumber[32];

    getllname(llname);

    if (ARGN==3) llistcur[llname]= llSetADDR(ARG3,llname);  // address provided as input
    current=llistcur[llname];
    if (current->next==NULL && llist[llname]->next==NULL) {
        R_lladd(func) ;
        return;
    }
    LASCIIZ(*ARG2)
    new = MALLOC(sizeof(struct node)+LLEN(*ARG2)+16,"LLENTRY");
    new->magic=llMagic;
    strcpy(new->data, (const char *) LSTR(*ARG2));
    if ((int *) current==llist[llname]->next) prev = (struct node *) llist[llname];  // old record was first record
    else prev = (struct node *) current->previous;
    linknode(prev, new, (int *) current);
    llistcur[llname] = (struct node *) new;
    llist[llname]->count++;
    llist[llname]->added++;
    llADDRreturn(new);
}
void R_llget(int func) {
    struct node *nxt, *addr, *iaddr;
    int llname, xaddr;

    getllname(llname)

    iaddr = llistcur[llname];
    if (ARGN > 1) {
        Lupper(ARG2);
        if (strncmp((const char *) ARG2->pstr, "FIRST",2)     == 0) llistcur[llname] = (struct node *) llist[llname]->next;
        else if (strncmp((const char *) ARG2->pstr, "LAST",2) == 0) llistcur[llname] = (struct node *) llist[llname]->last;
        else if (strncmp((const char *) ARG2->pstr, "NEXT",2) == 0) llistcur[llname] = (struct node *) iaddr->next;
        else if (strncmp((const char *) ARG2->pstr, "PREVIOUS",2) == 0) {
            if (iaddr==(struct node *) -1) llistcur[llname] = (struct node *) llist[llname]->last;
            else llistcur[llname] = (struct node *) iaddr->previous;
        }else llistcur[llname] = llSetADDR(ARG2,llname);
    } else {    // just one argument
      if (iaddr==(struct node *) llist[llname]) llistcur[llname]= (struct node *) iaddr->next;     // sits currently on position 0, display first record then
      else if (iaddr==(struct node *) -1) {   // position behind last record, don't change current element ,just print the last record
          iaddr= (struct node *) llist[llname]->last;
          Lscpy(ARGR,iaddr->data);
          return;
      }
    }
    if (llistcur[llname] == NULL || llist[llname]->next==NULL) Lscpy(ARGR, "$$EMPTY$$");
    else Lscpy(ARGR, llistcur[llname]->data);
}
void R_llentry(int func) {
    struct node *nxt,*addr, *iaddr;
    int llname, xaddr;

    getllname(llname);

    iaddr=llistcur[llname];
    printf("---------------------------------------------\n");
    printf("Linked List Entry %d (%s)\n",llname, llist[llname]->name);
    printf("---------------------------------------------\n");
    printf("Address  %x \n",llistcur[llname]);
    printf("Data     %s \n",llistcur[llname]->data);
    printf("Next     %x \n",llistcur[llname]->next);
    if (llistcur[llname]->previous==(int *)llist[llname])  printf("Previous %x \n",0);
    else printf("Previous %x \n",llistcur[llname]->previous);
}
void R_lllist(int func) {
    struct node *current;
    int llname,count=0;

    getllname(llname);

    current= (struct node *) llist[llname]->next;
    printf("     Entries of Linked List: %d (%s)\n",llname,llist[llname]->name);
    printf("Entry Entry Address     Next    Previous      Data\n");
    printf("-------------------------------------------------------\n");
    while (current!= NULL) {
        count++;
        printf("%5d ",count);
        printf("%10x ",current);
        printf(" %10x ",current->next);
        if (current->previous==(int *)llist[llname])  printf(" %10x",0);
        else printf(" %10x",current->previous);
        printf("   %s \n",current->data);
        current = (struct node *) current->next;
    }
    printf("Linked List contains %d Entries\n",count);
    printf("       List counter  %d Entries\n",llist[llname]->count);
    Licpy(ARGR,count);
    return ;
}
void R_lldetails(int func) {
    struct node *current;
    int llname,mode,count=0;
    char sNumber[32];

    getllname(llname);

    if (ARGN==2) {
        LASCIIZ(*ARG2);
        Lupper(ARG2);
        if (LSTR(*ARG2)[0]=='C') Licpy(ARGR, (int) llist[llname]->count);
        else if (LSTR(*ARG2)[0]=='A') Licpy(ARGR, (int) llist[llname]->added);
        else if (LSTR(*ARG2)[0]=='D') Licpy(ARGR, (int) llist[llname]->deleted);
        else if (LSTR(*ARG2)[0]=='L') {
            current = (struct node *) llist[llname]->next;
            while (current != NULL) {
                count++;
                current = (struct node *) current->next;
            }
            Licpy(ARGR, count);
        }
        else if (LSTR(*ARG2)[0]=='F') {
            current = (struct node *) llist[llname]->next;
            while (current != NULL) {
                count++;
                current = (struct node *) current->next;
            }
            printf("Attributes of Linked List %d (%s)\n", llname,llist[llname]->name);
            printf("-------------------------------------------------------\n");
            printf("Entry Count     %d\n", llist[llname]->count);
            printf("     Listed     %d\n", count);
            printf("      Added     %d\n", llist[llname]->added);
            printf("    Deleted     %d\n", llist[llname]->deleted);
            sprintf(sNumber,"%x",llistcur[llname]);
            printf("Current Pointer %s\n", sNumber);
        }
    }
    else Licpy(ARGR, (int) llist[llname]->count);
}

void R_llset(int func) {
    struct node *nxt, *current, *addr;
    int llname, item = -1, count,dec=0;
    char mode, sNumber[32];

    getllname(llname)

    if (ARGN == 1) mode = 'N';
    else {
        Lupper(ARG2);
        if (strncmp(LSTR(*ARG2), "POSITION", 2) == 0) mode = 'O';
        else if (strncmp(LSTR(*ARG2), "AMODE", 2)==0) {
            Lupper(ARG3);
            if (strncmp(LSTR(*ARG3), "HEX", 2)== 0) llist[llname]->flags=1;
            else llist[llname]->flags=0;
            Licpy(ARGR,llist[llname]->flags);
            return;
        }
        else mode = LSTR(*ARG2)[0];
    }
    if (mode=='F') {                                                    // set to FIRST entry
        current= (struct node *) llist[llname];
        if (current==NULL) goto setfailed;
        if ((int *) current->next == NULL) llistcur[llname]=NULL;
        else llistcur[llname] = (struct node *) current->next;
    } else if (mode=='N') {                                             // set to NEXT entry
        current=llistcur[llname];
        if (current==NULL) goto setfailed;
        if ((int *) current->next == NULL) llistcur[llname]=NULL;
        else llistcur[llname] = (struct node *) current->next;
    }  else if (mode=='P') {                                            // set to PREVIOUS entry
        current=llistcur[llname];
        if (current==NULL) goto setfailed;
        if (current->previous==(int *)llist[llname]) llistcur[llname]=NULL;
        else llistcur[llname]= (struct node *) current->previous;
    } else if (mode=='C') {                                             // return CURRENT entry
    } else if (mode=='L') {                                             // set to LAST entry
        llistcur[llname]= (struct node *) llist[llname]->last;
    } else if (mode=='O') {                                             // POSITION to n.th entry
        if (ARGN!=3) Lfailure ("Record Number missing", "", "", "", "");
        count= Lrdint(ARG3);
        current= (struct node *) llist[llname];
        if (current==NULL) goto setfailed;
        if ((int *) current->next == NULL) goto setfailed;
        if (count<0) current= (struct node *) -1;     // position 0, sets prior to first record, -1 after last record
        else if (count>0) {   // locate record position
            current = (struct node *) current->next;
            count--;
            while (current != NULL && count > 0) {
                current = (struct node *) current->next;
                count--;
            }
        }
        if (current == NULL) llistcur[llname] = (struct node *) llist[llname]->last;
        else llistcur[llname] = current;
    } else if (mode=='A') {                                             // set to given entry ADDRESS
        if (ARGN!=3) Lfailure ("Linked List address missing", "", "", "", "");
        llistcur[llname]= llSetADDR(ARG3,llname);
    }
    llADDRreturn(llistcur[llname]);

    setfailed:
    Licpy(ARGR,-8);
    return ;
}
void R_llfree(int func) {
    struct node *current,*todel;
    int llname,item=-1,mode=2;

    getllname(llname);

    current= (struct node *) llist[llname];
    if (current==NULL) goto empty;
    current= (struct node *) current->next;
    while (current!= NULL) {
        todel=current;
        current = (struct node *) current->next;
        FREE(todel);
    }
    FREE(llist[llname]);
    Licpy(ARGR,0);
    return;
    empty:
    Licpy(ARGR,-8);
    return ;
}
void unlinkll(struct node *current,int llname) {
    struct node *new = NULL, *fwd, *prev;
    if (llist[llname]->count <= 1) {  // if 1: this is the last entry, just about to be deleted
        llist[llname]->next = NULL;
        llist[llname]->previous = NULL;
        llist[llname]->last = NULL;
        llistcur[llname]= (struct node *) llist[llname];
        if (llist[llname]->count < 1) return ;
        goto setstats;
    }
    // 1. save pointer of element to delete
    fwd = (struct node *) current->next;
    prev = (struct node *) current->previous;
    // 2. link previous element to succeeding element (referred to by element to delete)
    //    if there is no previous element, link referred element to LL root
    if (llistcur[llname]->previous == (int *) llist[llname]) llist[llname]->next = (int *) fwd;
    else prev->next = (int *) fwd;
    // 3. link succeeding element to previous element (referred to by element to delete)
    if (fwd != NULL) fwd->previous = (int *) prev;
    // 4. set new active element
    if ((struct root *) prev == llist[llname]) prev = NULL;
    if (prev == NULL) llistcur[llname] = (struct node *) llist[llname]->next;
    else if (fwd == NULL) {
        llistcur[llname] = (struct node *) prev;
        llist[llname]->last = (int *) prev;
    } else llistcur[llname] = (struct node *) fwd;

    setstats:
    llist[llname]->count--;
    llist[llname]->deleted++;
}

void R_lldel(int func) {
    struct node *new = NULL, *current, *fwd,*prev;
    int llname;
    char sNumber[32];

    getllname(llname)

    if (ARGN==2) llistcur[llname]= llSetADDR(ARG2,llname);  // address provided as input
    current=llistcur[llname];
    if (current==NULL | llist[llname]->count < 1) {
        Licpy(ARGR,-8);
        return ;
    }
    unlinkll(current,llname);                // unlink element, new current element is set
    FREE(current);                       // now free memory of element to delete
    llADDRreturn(llistcur[llname]);
 }
void R_lldelink(int func) {
    struct node *new = NULL, *current, *fwd,*prev;
    int llname ;
    char sNumber[32];

    getllname(llname);

    if (ARGN==2) llistcur[llname]= llSetADDR(ARG2,llname);  // address provided as input
    current=llistcur[llname];
    if (current==NULL) {
        Licpy(ARGR,-8);
        return ;
    }
    unlinkll(current,llname);
    current->next= (int *) -1;
    current->previous= (int *) -1;
    llADDRreturn(current);
}

void R_lllink(int func) {
    struct node *tolink, *current, *fwd,*prev;
    int llname ;
    char sNumber[32];

    getllname(llname);

    tolink=llSetADDR(ARG2,llname);
    if (ARGN==3) {
        current=llSetADDR(ARG3,llname);
        sprintf(sNumber,"%x",current);
        if ((int) current->next == -1 | (int) current->previous == -1 ) Lfailure ("Linked List target address inactive, or do not belong to List: ", sNumber, "", "", "");
        llistcur[llname] = current;  // target address provided as input
    }
    if (llist[llname]->next==NULL) {  // empty llist
        linknode(llist[llname],tolink,NULL);
    } else {
        current = llistcur[llname];
        if (current == NULL) current = (struct node *) llist[llname];  // if no current element set it to first element

        if (current == (struct node *) llist[llname]) {  // old record was first record
            linknode(llist[llname], tolink, (int *) current);
            updatenode(current,llist[llname],NULL);
        } else {
            prev = (struct node *) current->previous;
            linknode(prev, tolink, (int *) current);
        }
    }
    llistcur[llname]= (struct node *) tolink;
    llist[llname]->count++;
    llADDRreturn(llistcur[llname]);
  }

/* -------------------------------------------------------------------------------------
 * Matrix
 * -------------------------------------------------------------------------------------
 */
#define matrixmax 128
#define ivectormax 64
#define sfvectormax 16
#define svectormax 16

#define matOffset(ix,rowi,coli) {ix=((rowi-1)*matcols[matrixname]+(coli-1));}
#define matOffset2(mname,ix,rowi,coli) {ix=((rowi-1)*matcols[mname]+(coli-1));}
#define mcheck(m0) { if (curmatrixname!=m0) Matrixcheck(m0);}

double *matrix[matrixmax];
int    *ivector[ivectormax],ivrows[ivectormax],ivnum=0;
int    matrows[matrixmax], matcols[matrixmax],matrixname=0,curmatrixname=-1,mdebug;
char   *bitarray[ivectormax];
int    arrayrows[ivectormax];
char   *sfvector[sfvectormax];
int    sfvrows[sfvectormax],svslen[sfvectormax];

int Matrixcheck(matrixname) {
    char sNumber[16];
    char sNumber2[8];

    if (curmatrixname==matrixname) return 0;
    if (matrixname>matrixmax) {
        sprintf(sNumber,"%d",matrixname);
        sprintf(sNumber2,"%d",matrixmax);
        Lfailure ( "Matrix ",sNumber,"exceeds maximum of ",sNumber2,"");
    }
    if (matrix[matrixname] == 0) {
        sprintf(sNumber,"%d",matrixname);
        Lfailure ( "Matrix ",sNumber,"is not defined","","");
    }
    curmatrixname=matrixname;
    return 0;
}

void setMatrixStem(char *sName, int mname,int stemi, double fValue)
{
    char sStem[32];
    char sValue[32];

    if (stemi<0) sprintf(sStem,"%s.%d",sName,mname);
    else  sprintf(sStem,"%s.%d.%d",sName,mname,stemi);
    sprintf(sValue,"%f",fValue);
    setVariable(sStem,sValue);
}

int mcreate(int rows, int cols) {
    int matrixname,size;
    for (matrixname = 0; matrixname <= matrixmax; ++matrixname) {
        if (matrix[matrixname] == 0) break;
    }
    if (matrixname > matrixmax) Lfailure ( "Matrix stack full, no allocation occurred","","","","");
    matrows[matrixname]=rows;
    matcols[matrixname]=cols;
    size=rows*cols*sizeof(double);
    matrix[matrixname] =MALLOC(size,"Matrix");
    if (matrix[matrixname]==0) Lfailure ( "Storage stack full, no allocation occurred","","","","");
    curmatrixname=matrixname;
    if (mdebug==1) printf("Matrix create %d %d %d size %d AT %d\n",matrixname,rows,cols,size,matrix[matrixname]);
    return matrixname;
}
void R_mcreate(int func) {
    int matrixname,rows,cols;
    get_i(1,rows);    // Number of rows, rows run from 1 to rows, if rows=1 it's a 1-dimensional vector of columns
    get_i(2,cols);
    matrixname= mcreate(rows, cols) ;
    if (ARGN==3) {
        get_s(3);
        LASCIIZ(*ARG3)
        if (mdebug==1) printf("Matrix created %d %s Dimension %d,%d\n",matrixname,LSTR(*ARG3),rows,cols);
    } else if (mdebug==1) printf("Matrix created %d Dimension %d,%d\n",matrixname,rows,cols);
    Licpy(ARGR,matrixname);
}
void R_bitarray(int func) {
    int arrayname, rows, index, size, bytex, bitx, i, iv;
    get_s(1)
    LASCIIZ(*ARG1);
    Lupper(ARG1);
    if (strcmp((const char *) ARG1->pstr, "CREATE") == 0) {
        get_i(2, rows);
        for (arrayname = 0; arrayname <= ivectormax; ++arrayname) {
            if (bitarray[arrayname] == 0) break;
        }
        if (arrayname > ivectormax) Lfailure("Bit Array stack full, no allocation occurred", "", "", "", "");
        arrayrows[arrayname] = rows;
        bitarray[arrayname] = MALLOC((rows + 1) / 8, "BitArray");
        memset(bitarray[arrayname], 0, (rows + 1) / 8);
        if (bitarray[arrayname] == 0) Lfailure("Storage stack full, no allocation occurred", "", "", "", "");
        Licpy(ARGR, arrayname);
        return;
    } else if (strcmp((const char *) ARG1->pstr, "SET") == 0) {
        get_i0(2, arrayname);
        iv = 1;
        get_i(3, index);
        if (ARGN == 4) {
            get_i0(4, iv);
            if (iv != 0 & iv != 1) iv = 1;
        }
        index--;
        bytex = index / 8;
        bitx = index % 8;
        if (iv == 1) bitarray[arrayname][bytex] = bitarray[arrayname][bytex] | (1 << bitx);
        else bitarray[arrayname][bytex] = bitarray[arrayname][bytex] & ~(1 << bitx);
    } else if (strcmp((const char *) ARG1->pstr, "DUMP") == 0) {
        get_i0(2, arrayname);
        get_i(3, index);
        index--;
        bytex = index / 8;
        bitx = index % 8;
        printf("Dump of Array element %d, Bit contained in Byte %d position %d\n", index, bytex, bitx);
        for (i = 7; 0 <= i; i--) {
            printf("%c", (bitarray[arrayname][bytex] & (1 << i)) ? '1' : '0');
        }
        printf("\n");
        Licpy(ARGR, 0);
    } else if (strcmp((const char *) ARG1->pstr, "GET") == 0) {
        get_i0(2, arrayname);
        get_i(3, index);
        index--;
        bitx=index%8;
        Licpy(ARGR, (bitarray[arrayname][index / 8] & (1 << bitx)) >> bitx);
    }
}
void R_mfree(int func) {
    int ii;
    curmatrixname = -1;
    if (ARGN == 0) {
        for (ii = 0; ii <= matrixmax; ++ii) {
            if (matrix[ii] == 0) continue;
            FREE(matrix[ii]);
            matrix[ii] = 0;
        }
        for (ii = 0; ii <= ivectormax; ++ii) {
            if (ivector[ii] == 0) continue;
            FREE(ivector[ii]);
            ivector[ii] = 0;
        }
        return;
    }
    get_s(2);
    get_i0(1, ii);
    LASCIIZ(*ARG2)
    Lupper(ARG2);
    if (ii > matrixmax | ii < 0) return;
    if (LSTR(*ARG2)[0] == 'I') {
        FREE(ivector[ii]);   // Free ivector
        ivector[ii] = 0;
    } else if (LSTR(*ARG2)[0] == 'M') {
        if (mdebug == 1) printf("Matrix freed %d\n", ii);
        FREE(matrix[ii]);    // Free Matrix
        matrix[ii] = 0;
    }
}
void R_memory(int func) {
    int i,imax=-1,noprint=0,getmain,lastgm,*gotten=NULL,nogot=14*1024*1024,*gotlast,*memory[128],alc=0;

    if (ARGN>0) {
        get_s(1);
        LASCIIZ(*ARG1)
        Lupper(ARG1);
        if (LSTR(*ARG1)[0]=='N') noprint=1;
    }
    if (noprint==0) {
        printf("MVS Free Storage Map\n");
        printf("---------------------------\n");
    }
// find first/next block
    while (1 > 0) {
        for (getmain = nogot; getmain > 16384; getmain = getmain / 2) {
            gotten = malloc(getmain);
            if (gotten != NULL) break;
            nogot = getmain;
        }
        if (gotten == NULL) break;
        gotlast = gotten;
        lastgm  = getmain;
        while (1 > 0) {
            if (gotten != NULL) free(gotten);
            gotten = NULL;
            if (nogot - getmain < 16384) break;
            getmain = getmain + (nogot - getmain) / 2;
            gotten = malloc(getmain);
            if (gotten == NULL) {  //  printf("not extended %d %d\n",getmain,gotten);
                nogot = getmain;
                getmain = (int) lastgm;
            } else {  // printf("extended %d \n",getmain);
                gotlast= gotten;
                lastgm = getmain;
            }
        }
        gotten = malloc(getmain);  // re-allocate memory to find next slot
        if (gotten==NULL) break;
        if (noprint==0) printf("AT ADDR %8d   %5d KB\n", (int) gotten, getmain / 1024);
        imax++;
        if (imax>128) {
            printf ("Memory List exceeded\n");
            break;
        }
        memory[imax] = gotten;
        nogot = getmain;
        alc = alc + getmain;
        gotlast = NULL;
    }
    for (i = 0; i <= imax; ++i) {
        free(memory[i]);
    }
    Licpy(ARGR,alc);
    if (noprint==0) {
        printf("Total              %5d KB\n", alc/1024);
        printf("---------------------------\n");
    }
}
void R_sfcreate(int func) {
    int vname, rows, slen;
    get_i(1,rows);
    get_i(2,slen);
    for (vname = 0; vname <= sfvectormax; ++vname) {
        if (sfvector[vname] == 0) break;
    }
    if (vname > sfvectormax) {
        vname = -8;
        goto sc8;
    }
    sfvrows[vname] = rows;
    svslen[vname] = slen+1;   // +1 for succeedign hex 0
    sfvector[vname] = (char *) MALLOC(rows * sizeof(char) * svslen[vname], "F-STRING Vector");
    sc8:
    Licpy(ARGR,vname);
}
void R_sfset(int func) {
    int vname,row,slen,offset;
    get_i0(1,vname);
    get_i(2,row);
    slen=LLEN(*ARG3);
    if (slen>svslen[vname]-1) slen=svslen[vname]-1;
    offset=(row-1)*svslen[vname];
    memcpy(&sfvector[vname][offset], LSTR(*ARG3), slen);
    sfvector[vname][offset + slen] = '\0';
    Licpy(ARGR,0);
}
void R_sfget(int func) {
    int vname,row;
    get_i0(1,vname);
    get_i(2,row);
    Lscpy(ARGR,&sfvector[vname][(row - 1) * svslen[vname]]);
}
void R_sffree(int func) {
    int vname,row;
    get_i0(1,vname);
    FREE(sfvector[vname]);
    Licpy(ARGR,0);
}
int sundaram(int iv,int lim,int one) {
    int j, i, k, mid, current, xlim, byten, bitn,bytex,bitx;
    char *noprime;
    xlim = (lim * 8);
    if (lim>1000000) xlim=xlim+lim;
    noprime= MALLOC((xlim + 1)/8, "Sundaram BitArray");
    memset(noprime,0,(xlim + 1)/8);

    mid = xlim / 2;
    for (j = 1; j <= mid; ++j) {
        for (i = 1; i <= j; ++i) {
            current = i + j + (2 * i * j);
            if (current > xlim) break;
            current--;
            bytex = current / 8;
            bitx = current % 8;
            noprime[bytex] = noprime[bytex] | (1 << bitx);
        }
    }
    if (one < 0) {
        i = 0;
        ivector[iv][i++] = 2;
        for (j = 1; j <= xlim; ++j) {
            bitx=(j-1)%8;
            current=(noprime[(j-1)/8] & (1 << bitx)) >> bitx;
            if (current == 1) continue;
            ivector[iv][i++] = j * 2 + 1;
            if (i >= lim) break;
        }
    } else {
        if (lim==1) i=2;     // sub prime 2, no need to go through table
        else {
            i = 1;
            for (j = 1; j <= xlim; ++j) {
                bitx=(j-1)%8;
                current=(noprime[(j-1)/8] & (1 << bitx)) >> bitx;
                if (current == 1) continue;
                if (++i < lim) continue;
                k = j * 2 + 1;
                break;
            }
            i = k;
        }
    }
    FREE(noprime);
    return i;
}
void R_icreate(int func) {
    int vname,ii,jj,jm,jr,rows;
    char option=' ';
    if (ARGN >1) option = l2u[(byte)LSTR(*ARG2)[0]];
    rows = Lrdint(ARG1);
    for (ii = 0; ii <=ivectormax; ++ii) {
        if (ivector[ii]==0) break;
    }
    if (ii>ivectormax) {
        vname=-8;
        goto ic8 ;
    }
    vname=ii;
    ivrows[vname]=rows;
    ivector[vname] = (int *) MALLOC(rows*sizeof(int),"INT Vector");
    if (option=='E') {
        for (ii = 0; ii < rows; ++ii) {
            ivector[vname][ii] = ii+1;
        }
    } else if (option=='N'){
        for (ii = 0; ii <rows; ++ii) {
            ivector[vname][ii] = 0;
        }
    } else if (option=='D'){
        jj=rows;
        for (ii = 0; ii <rows; ++ii, jj--) {
            ivector[vname][ii] = jj;
        }
    } else if (option=='F'){      // fibonacci
        ivector[vname][0] = 1;
        ivector[vname][1] = 1;
        for (ii = 2; ii <rows; ++ii) {
            if (ii<46) ivector[vname][ii] = ivector[vname][ii-2]+ivector[vname][ii-1];
            else ivector[vname][ii] =0;
        }
    } else if (option=='S') {
        for (ii = 0; ii <rows; ++ii) {
            ivector[vname][ii] = 0;
        }
        sundaram(vname,rows,-1);
    } else if (option=='P'){
        ivector[vname][0] = 2;
        ii=0;
        for (jj = 3; ; jj=jj+2) {
            for (jm = 0;jm<ii; ++jm) {
                jr=(int) ivector[vname][jm];
                if (jj%jr==0) goto isnoprim;
            }
            ii++;
            if (ii<ivrows[vname]) ivector[vname][ii] = jj;
            else break;
            isnoprim: continue;
        }
    }
    ic8:
    Licpy(ARGR,vname);
}
void R_iset(int func) {
    int vname,row;
    get_i0(1,vname);
    get_i(2,row);
    ivector[vname][row-1]= Lrdint(ARG3);
    Licpy(ARGR,0);
}
void R_iget(int func) {
    int vname,row;
    get_i0(1,vname);
    get_i(2,row);
    Licpy(ARGR,ivector[vname][row-1]);
}
void R_mset(int func) {
    int matrixname,row,col,indx;
    get_i0(1,matrixname);
    mcheck(matrixname);
    get_i(2,row);
    get_i(3,col);

    matOffset(indx,row,col);
    matrix[matrixname][indx] = Lrdreal(ARG4);
    Licpy(ARGR,0);
}
void R_mget(int func) {
    int matrixname,row,col,indx;
    get_i0(1,matrixname);
    mcheck(matrixname);
    get_i(2,row);
    get_i(3,col);
    matOffset(indx,row,col);
    Lrcpy(ARGR,  (matrix[matrixname])[indx]);
}
double mmean(int matrixname, int col, int mrow) {
    double mean=0;
    int i,indx;
    if (mrow<=1) return 0;
    for (i = 1; i<=mrow; i++) {
        matOffset(indx,i,col);
        mean=mean+(matrix[matrixname])[indx];
    }
    return mean/mrow;
}
double mhighv(int matrixname, int col, int mrow) {
    double high;
    int i,indx;
    if (mrow<=1) return 0;
    matOffset(indx,1,col);
    high=(matrix[matrixname])[indx];
    for (i = 2; i<=mrow; i++) {
        matOffset(indx,i,col);
        if ((matrix[matrixname])[indx]>high) {
            high=(matrix[matrixname])[indx];
        }
    }
    return high;
}
double mlowv(int matrixname, int col, int mrow) {
    double low;
    int i,indx;
    if (mrow<=1) return 0;
    matOffset(indx,1,col);
    low=(matrix[matrixname])[indx];
    for (i = 2; i<=mrow; i++) {
        matOffset(indx,i,col);
        if ((matrix[matrixname])[indx]<low) low=(matrix[matrixname])[indx];
    }
    return low;
}
double mvariance(int matrixname, int col, int mrow,int meanflag,double meanin) {
    double variance=0,mean=0,temp;
    int i,j,indx;
    if (mrow<=1) return 0;
    if (meanflag==1) mean=meanin;
    else mean=mmean(matrixname, col, mrow);
    for (i = 1; i<=mrow; i++) {
        matOffset(indx,i,col);
        temp= (matrix[matrixname][indx])-mean;
        variance=variance+temp*temp;
    }
    return sqrt(variance/(mrow-1));
}
int mcopy(int m0){
    int i,j,rows, cols,indx,m1,m9;
    rows=matrows[m0];
    cols=matcols[m0];

    m1= mcreate(rows, cols);
    for (i = 1; i <=rows; i++) {
        for (j = 1; j <= cols; j++) {
            matOffset2(m1,indx,i,j);
            matrix[m1][indx] = matrix[m0][indx];
        }
    }
    return m1;
}
// Insert Column
void R_minscol(int func){
    int i,j,rows, cols,indx,indx2,m1,m2;
    double setf;
    if (ARGN!=2) Lerror(ERR_INCORRECT_CALL,0);
    get_i0(1,m2);

    setf = Lrdreal(ARG2);

    mcheck(m2);

    rows=matrows[m2];
    cols=matcols[m2];

    m1= mcreate(rows, cols+1);
    for (i = 1; i <=rows; i++) {
        matOffset2(m1,indx,i,1);
        matrix[m1][indx] = setf;
    }
    for (i = 1; i <=rows; i++) {
        for (j = 1; j <= cols; j++) {
            matOffset2(m1,indx,i,j+1);
            matOffset2(m2,indx2,i,j);
            matrix[m1][indx] = matrix[m2][indx2];
        }
    }
    Licpy(ARGR,m1);
}
void R_mscalar(int func){
    int i,j,rows, cols,indx,m1,m2;
    get_i0(1,m2);
    mcheck(m2);
    rows=matrows[m2];
    cols=matcols[m2];
    L2REAL(ARG2);

    m1=mcreate(rows, cols);
    for (i = 0; i<(rows)*(cols); i++) {
        matrix[m1][i] = matrix[m2][i]*LREAL(*ARG2);
    }
    Licpy(ARGR,m1);
}
void R_mnormalise(int func) {
    int matrixname,m2,i,j,indx,row,col,mode,mrows,mcols,divisor=1;
    double mean, variance;
    char option='A';
    get_i0(1,m2);
    if (ARGN >1) option = l2u[(byte)LSTR(*ARG2)[0]];
    else option='S';
    mcheck(m2);
    mrows=matrows[m2];
    mcols=matcols[m2];
    matrixname= mcopy(m2);
    // step 1 calculate mean and variance of array
    for (j = 1; j<=mcols; j++) {
        mean= mmean(m2, j, mrows);
        variance= mvariance(m2, j, mrows,1,mean);
        if (mdebug==1) printf("mean/variance %d %f %f\n",j,mean,variance);
        if (variance==0 & option=='S') goto noVariance;
        if (option=='L') {
            // divisor=pow((int) 10,(int)log(fabs(mhighv(m2,j,mrows))));
            mean=mhighv(m2,j,mrows);
            mean=fabs(mean);
            mean=log10(mean);
            divisor=(int) mean;
            divisor=pow(10,divisor);
        }
        else divisor=1;

        for (i = 1; i<=mrows; i++) {
            matOffset(indx,i,j);
            if (option=='M') (matrix[matrixname][indx])=matrix[matrixname][indx]-mean;
            else if (option=='R') (matrix[matrixname][indx])=matrix[matrixname][indx]/mrows;
            else if (option=='L') {if (divisor>1) (matrix[matrixname][indx])=matrix[matrixname][indx]/(double) divisor;}
            else (matrix[matrixname][indx])=(matrix[matrixname][indx]-mean)/variance;  // option Standard
        }
        noVariance:
        setMatrixStem("_rowvariance",matrixname,j,mvariance(matrixname, j, mrows,0,0));
        setMatrixStem("_rowmean",matrixname,j,mmean(matrixname, j, mrows));
        setMatrixStem("_rowfactor",matrixname,j,(double) divisor);
    }
    Licpy(ARGR,matrixname);
}
void R_mmultiply(int func) {
    int m1,m2,m3,row1,col1,row2,col2,row3,col3,ix1,ix2;
    int i,j,k;
    double sum;
    get_i0(1,m2);
    get_i0(2,m3);
    mcheck(m2);
    mcheck(m3);
    row2=matrows[m2];
    col2=matcols[m2];
    row3=matrows[m3];
    col3=matcols[m3];

    if (col2 != row3) {
        printf("Matrix Multiplication is not possible.\n");
        printf("Matrix 1 dimension :,%d x %d\n",row2,col2);
        printf("Matrix 2 dimension :,%d x %d\n",row3,col3);
        Licpy(ARGR,8);
        return;
    }
    m1= mcreate(row2, col3);
    for (i = 1; i <=row2; i++) {
        for (j = 1; j <= col3; j++) {
            sum=0;
            for (k = 1; k <=row3; k++) {
                matOffset2(m2,ix1,i,k);
                matOffset2(m3,ix2,k,j);
                sum = sum + matrix[m2][ix1]*matrix[m3][ix2];
            }
            matOffset2(m1,ix1,i,j);
            matrix[m1][ix1] = sum;
        }
    }
    Licpy(ARGR, m1);
}
void R_msubtract(int func) {
    int m1,m2,m3,row1,col1,row2,col2,row3,col3,ix1;
    int i,j;
    get_i0(1,m2);
    get_i0(2,m3);
    mcheck(m2);
    mcheck(m3);
    row2=matrows[m2];
    col2=matcols[m2];
    row3=matrows[m3];
    col3=matcols[m3];

    if (row2 != row3 | col2 != col3) {
        printf("Matrix Subtraction is not possible.\n");
        printf("Matrix 1 dimension :,%d x %d\n",row2,col2);
        printf("Matrix 2 dimension :,%d x %d\n",row3,col3);
        Licpy(ARGR,8);
        return;
    }
    m1= mcreate(row2, col2);
    for (i = 1; i <=row2; i++) {
        for (j = 1; j <= col2; j++) {
            matOffset2(m1,ix1,i,j);  // can be used for all 3 matrixes
            matrix[m1][ix1]=matrix[m2][ix1]-matrix[m3][ix1];
        }
    }
    Licpy(ARGR, m1);
}
void R_madd(int func) {
    int m1,m2,m3,row1,col1,row2,col2,row3,col3,ix1;
    int i,j;
    get_i0(1,m2);
    get_i0(2,m3);
    mcheck(m2);
    mcheck(m3);
    row2=matrows[m2];
    col2=matcols[m2];
    row3=matrows[m3];
    col3=matcols[m3];

    if (row2 != row3 | col2 != col3) {
        printf("Matrix Addition is not possible.\n");
        printf("Matrix 1 dimension :,%d x %d\n",row2,col2);
        printf("Matrix 2 dimension :,%d x %d\n",row3,col3);
        Licpy(ARGR,8);
        return;
    }
    m1= mcreate(row2, col2);
    for (i = 1; i <=row2; i++) {
        for (j = 1; j <= col2; j++) {
            matOffset2(m1,ix1,i,j);  // can be used for all 3 matrixes
            matrix[m1][ix1]=matrix[m2][ix1]+matrix[m3][ix1];
        }
    }
    Licpy(ARGR, m1);
}
void R_mprod(int func) {
    int m1,m2,m3,row1,col1,row2,col2,row3,col3,ix1;
    int i,j;
    get_i0(1,m2);
    get_i0(2,m3);
    mcheck(m2);
    mcheck(m3);
    row2=matrows[m2];
    col2=matcols[m2];
    row3=matrows[m3];
    col3=matcols[m3];

    if (row2 != row3 | col2 != col3) {
        printf("Matrix/Matrix Product is not possible.\n");
        printf("Matrix 1 dimension :,%d x %d\n",row2,col2);
        printf("Matrix 2 dimension :,%d x %d\n",row3,col3);
        Licpy(ARGR,8);
        return;
    }
    m1= mcreate(row2, col2);
    for (i = 1; i <=row2; i++) {
        for (j = 1; j <= col2; j++) {
            matOffset2(m1,ix1,i,j);  // can be used for all 3 matrixes
            matrix[m1][ix1]=matrix[m2][ix1]*matrix[m3][ix1];
        }
    }
    Licpy(ARGR, m1);
}
void R_msqr(int func) {
    int m1,m2,m3,row1,col1,row2,col2,row3,col3,ix1;
    int i,j;
    double msum=0.0, msqr=0.0;
    get_i0(1,m2);
    mcheck(m2);
    row2=matrows[m2];
    col2=matcols[m2];

    m1= mcreate(row2, col2);
    for (i = 1; i <=row2; i++) {
        msum=0;
        msqr=0;
        for (j = 1; j <= col2; j++) {
            matOffset2(m1,ix1,i,j);  // can be used for all 3 matrixes
            msum=msum+matrix[m2][ix1];
            matrix[m1][ix1]=matrix[m2][ix1]*matrix[m2][ix1];
            msqr=msqr+matrix[m1][ix1];
        }
        setMatrixStem("_rowsum",m1,i,msum);
        setMatrixStem("_rowsqr",m1,i,msqr);
    }
    Licpy(ARGR, m1);
}
void R_mtranspose(int func) {
    int m1,m2,row2,col2,ix1,ix2;

    int i,j,k;
    get_i0(1,m2);
    mcheck(m2);
    row2=matrows[m2];
    col2=matcols[m2];

    m1= mcreate(col2,row2);
    for (i = 1; i <=row2; i++) {
        for (j = 1; j <= col2; j++) {
            matOffset2(m1,ix1,j,i);
            matOffset2(m2,ix2,i,j);
            matrix[m1][ix1] = matrix[m2][ix2];
        }
    }
    Licpy(ARGR,m1);
}
void R_minvert(int func) {
    int m1,m2,m3,row1,col1,row2,col2,ix1,ix2,ix3;
    int i,j,k,ij,reorder[1000];
    double sum,max,hi,hr,hv[1000];
    get_i0(1, m2)
    mcheck(m2);
    row2=matrows[m2];
    col2=matcols[m2];
    if (col2 != row2) {
        printf("Matrix inversion not possible!\n");
        Licpy(ARGR,8);
        return;
    }
    m1=mcopy(m2);
    for (i = 1; i <=row2; i++) {
        reorder[i]=i;
    }
    for (j = 1; j <=row2; j++) {
        matOffset2(m1,ix1,j,i);
        max=fabs(matrix[m1][ix1]);
        ij=j;
        for (i = 1; i <=row2; i++) {
            matOffset2(m1,ix1,i,j);
            if (fabs(matrix[m1][ix1] > max)) {
                max=fabs(matrix[m1][ix1]);
                ij=i;
            }
        }
        if (max==0) Lfailure("Matrix is singular","","","","");;
        if (ij > j) {
            for (k = 1; k <=row2; k++) {
                matOffset2(m1,ix1,j,k);
                matOffset2(m1,ix2,ij,k);
                hi=matrix[m1][ix1];
                matrix[m1][ix1]=matrix[m1][ix2] ;
                matrix[m1][ix2]=hi;
            }
            hi=reorder[j];
            reorder[j]=reorder[ij];
            reorder[ij]=hi;
        }
        matOffset2(m1,ix1,j,j);
        hr=1/matrix[m1][ix1];
        for (i = 1; i <=row2; i++) {
            matOffset2(m1,ix2,i,j);
            matrix[m1][ix2]= matrix[m1][ix2] * hr;
        }
        matrix[m1][ix1]=hr;
        for (k = 1; k <=row2; k++) {
            if (k==j) continue;
            matOffset2(m1,ix2,j,k);
            for (i=1; i <=row2; i++) {
                if (i==j) continue;
                matOffset2(m1,ix1,i,k);
                matOffset2(m1,ix3,i,j);
                matrix[m1][ix1]= matrix[m1][ix1] - matrix[m1][ix3] * matrix[m1][ix2];
            }
            matrix[m1][ix2]= -hr * matrix[m1][ix2];
        }
    }
    for (i = 1; i <=row2; i++) {
        for (k = 1; k <=row2; k++) {
            matOffset2(m1,ix1,i,k);
            hv[reorder[k]]=matrix[m1][ix1];
        }
        for (k = 1; k <=row2; k++) {
            matOffset2(m1,ix1,i,k);
            matrix[m1][ix1]=hv[k];
        }
    }
    Licpy(ARGR, m1);
}

void R_mcopy(int func) {
    int m1,m2;
    get_i0(1,m2);
    mcheck(m2);
    m1=mcopy(m2);
    Licpy(ARGR, m1);
}
void R_mdelcol(int func) {
    int m1,m2,j,i,k,skip,col,ix1,ix2,del,rows,cols,dcols[32]={0};
    get_i0(1,m2);
    get_i(2,skip);    // at least one skip column required
    mcheck(m2);
    rows=matrows[m2];
    cols=matcols[m2];
    if (ARGN>33) Lerror(ERR_INCORRECT_CALL,0);
    k=0;
    for (i=1; i<ARGN; i++) {
        j=Lrdint(rxArg.a[i]);
        if (j>cols | j<1) continue;
        dcols[k] = j;
        k=k+1;
    }
    m1=mcreate(rows,cols-k);    // new column range, k is number of deleted rows
    col=0;
    for (j = 1; j <= cols; j++) {
        skip=0;
        for (k = 0; k < ARGN; k++) {
            if(j!=dcols[k]) continue;
            skip=1;
            break;
        }
        if (skip==1) if (mdebug==1) printf("DELeted %d \n",j);
        if (skip==1) continue;
        col=col+1;
        for (i = 1; i <=rows; i++) {
            matOffset2(m1,ix1,i,col);
            matOffset2(m2,ix2,i,j);
            matrix[m1][ix1] = matrix[m2][ix2];
        }
    }
    Licpy(ARGR, m1);
}
void R_mdelrow(int func) {
    int m1,m2,j,i,k,skip,row,ix1,ix2,del,rows,cols,drows[32]={0};
    get_i0(1,m2);
    get_i(2,skip);    // at least one skip column required
    mcheck(m2);
    rows=matrows[m2];
    cols=matcols[m2];
    if (ARGN>33) Lerror(ERR_INCORRECT_CALL,0);
    k=0;
    for (i=1; i<ARGN; i++) {
        j=Lrdint(rxArg.a[i]);
        if (j>rows | j<1) continue;
        drows[k] = j;
        k=k+1;
    }
    m1=mcreate(rows-k,cols);    // new column range, k is number of deleted rows
    row=0;
    for (i = 1; i <=rows; i++) {
        skip=0;
        for (k = 0; k < ARGN; k++) {
            if(i!=drows[k]) continue;
            skip=1;
            break;
        }
        if (skip==1) continue;
        row=row+1;
        for (j = 1; j <= cols; j++) {
            matOffset2(m1,ix1,row,j);
            matOffset2(m2,ix2,i,j);
            matrix[m1][ix1] = matrix[m2][ix2];
        }
    }
    Licpy(ARGR, m1);
}
void R_mproperty(int func) {
    int m1,j,i,indx,mrows,mcols;
    double mean,variance,msum=0;
    get_i0(1,m1);
    mcheck(m1);
    mrows=matrows[m1];
    mcols=matcols[m1];

    if (ARGN>1) {
        for (j = 1; j <= mcols; j++) {
            mean = mmean(m1, j, mrows);
            variance = mvariance(m1, j, mrows, 1, mean);
            setMatrixStem("_rowmean", m1, j, mean);
            setMatrixStem("_rowvariance", m1, j, variance);
            setMatrixStem("_rowlow",m1,j,mlowv(m1, j, mrows));
            setMatrixStem("_rowhigh",m1,j,mhighv(m1, j, mrows));
            msum=0;
            for (i = 1; i <= mrows; i++) {
                matOffset2(m1, indx, i, j);
                msum = msum + (matrix[m1][indx]);
            }
            setMatrixStem("_rowsum", m1, j, msum);
            setMatrixStem("_rowsqr", m1, j, msum * msum);
        }
        // sum up cols per row
        for (i = 1; i <= mrows; i++) {
            msum=0;
            for (j = 1; j <= mcols; j++) {
                matOffset2(m1, indx, i, j);
                msum = msum + (matrix[m1][indx]);
            }
            setMatrixStem("_colsum", m1, i, msum);
            setMatrixStem("_colsqr", m1, i, msum * msum);
        }
    }
    setMatrixStem("_rows",m1,-1,mrows);
    setMatrixStem("_cols",m1,-1,mcols);
}
void R_mused(int func) {
    int ii,ct=0,size=0;
    printf("Matrices Rows   Cols   Size\n");
    printf("---------------------------\n");
    for (ii = 0; ii <=matrixmax; ++ii) {
        if (matrix[ii]==0) continue;
        ct++;
        size=size+matrows[ii]*matcols[ii]*sizeof(double);
        printf("%3d    %6d %6d %6d\n",ii,matrows[ii],matcols[ii],matrows[ii]*matcols[ii]*sizeof(double));
    }
    printf("Active %d, Total Size %dK\n",ct,size/1024);
}
void R_prime(int func) {
    int i;
    get_i0(1,i);
    i=sundaram(-1,i,1);
    Licpy(ARGR,i);
}
void R_rxlist(int func) {
    RxFile  *rxf;
    int ii=0;
    printf("Loaded Rexx Modules \n");
    printf("    REXX      Member   DDNAME   DSN \n");
    printf("-----------------------------------------------------\n");
    for (rxf = rxFileList; rxf != NULL; rxf = rxf->next) {
        if (strcmp(rxf->filename,"-BREXX/370-")) {
            ii++;
            printf("%3d %-9s %-8s %-8s %s\n",ii,rxf->filename,rxf->member,rxf->ddn,rxf->dsn);
        }
    }
    Licpy(ARGR,ii);
}

/* -------------------------------------------------------------------------------------
 * Read the master trace table
 * -------------------------------------------------------------------------------------
 */
void R_mtt(int func)
{
    int rc = 0;

    void **psa;           // PSA     =>   0 / 0x00
    void **cvt;           // FLCCVT  =>  16 / 0x10
    void **mser;          // CVTMSER => 148 / 0x94
    void **bamttbl;       // BAMTTBL => 140 / 0x8C
    void **current_entry; // CURRENT =>   4 / 0x4

    jmp_buf jb;
    long staeret;

    int row = 0;
    int entries = 0;
    int idx = 0;

    int refresh = 0;
    void *lines[2048];
    char varName[9];

    P_MTT_HEADER mttHeader;
    P_MTT_ENTRY_HEADER mttEntryHeader;
    P_MTT_ENTRY_HEADER mttEntryHeaderStart;
    P_MTT_ENTRY_HEADER mttEntryHeaderWrap;
    P_MTT_ENTRY_HEADER mttEntryHeaderNext;
    P_MTT_ENTRY_HEADER mttEntryHeaderNext2;
    P_MTT_ENTRY_HEADER mttEntryHeaderNext3;
    P_MTT_ENTRY_HEADER mttEntryHeaderNextCurr;

    // Check if there is an explicit REFRESH requested
    if (ARGN == 1) {
        LASCIIZ(*ARG1)
        if (strcasecmp((const char *) LSTR(*ARG1), "REFRESH") == 0) {
            refresh = 1;
        }
    }

    staeret = _setjmp_stae(jb, NULL);
    if (staeret == 0) {

        // enable privileged mode
        privilege(1);

        // point to control blocks
        psa = 0;
        cvt = psa[4];              //  16
        mser = cvt[37];             // 148

        // point to master trace table header
        mttHeader = mser[35];

        // get most current mtt entry
        mttEntryHeader = (P_MTT_ENTRY_HEADER) mttHeader->current;

        // if most current entry is equal with the previous one and no REFERSH is requested, don't scan TT
        if (refresh == 1 || strcmp((const char *) &mttEntryHeader->callerData, savedEntry) != 0) {

            // save first entry
            memcpy(&savedEntry, (char *) &mttEntryHeader->callerData, 80);

            // iterate from most current mtt entry to the  end of the mtt
            while (((uintptr_t) mttEntryHeader) + mttEntryHeader->len + 10 <= (uintptr_t) mttHeader->end) {
                // buffer entry
                lines[entries] = &mttEntryHeader->callerData;
                entries++;

                // point to next entry
                mttEntryHeader = (P_MTT_ENTRY_HEADER) (((uintptr_t) mttEntryHeader) + mttEntryHeader->len + 10);
            }

            // get mtt entry at wrap point
            mttEntryHeader = (P_MTT_ENTRY_HEADER) mttHeader->wrapPoint;

            // iterate from wrap point to most current mtt entry
            while (((uintptr_t) mttEntryHeader) + mttEntryHeader->len + 10 < (uintptr_t) mttHeader->current) {
                // buffer entry
                lines[entries] = &mttEntryHeader->callerData;
                entries++;

                // point to next entry
                mttEntryHeader = (P_MTT_ENTRY_HEADER) (((uintptr_t) mttEntryHeader) + mttEntryHeader->len + 10);
            }

            // set stem count variable
            setIntegerVariable("_LINE.0", entries);

            // convert entry count to a index for entry array
            idx = entries - 1;

            // copy entry pointers to resulting stem variable

            for (row = 1; row <= entries; row++) {
                // build variable name and set variable
                sprintf(varName, "_LINE.%d", row);
                setVariable(varName, (char *) lines[idx]);
                idx--;
            }
        } else {
            entries = -1;
        }

        // disable privileged mode
        privilege(0);

        rc = _setjmp_canc();

        if (rc > 0) {
            fprintf(STDERR, "ERROR: MTT STAE routine ended with RC(%d)\n", rc);
        }

    } else if (staeret == 1) {
        entries=-1;             // return no new entries found
        _write2op("BREXX/370 MTT FUNCTION IN ERROR");
    }

    Licpy(ARGR, entries);
}

void R_mttx(int func)
{
    int rc = 0;

    void **psa;           // PSA     =>   0 / 0x00
    void **cvt;           // FLCCVT  =>  16 / 0x10
    void **mser;          // CVTMSER => 148 / 0x94
    void **bamttbl;       // BAMTTBL => 140 / 0x8C
    void **current_entry; // CURRENT =>   4 / 0x4

    jmp_buf jb;
    long staeret;

    int entries = 0;
    int sname;
    char refresh ;

    P_MTT_HEADER mttHeader;
    P_MTT_ENTRY_HEADER mttEntryHeader;
    P_MTT_ENTRY_HEADER mttEntryHeaderStart;
    P_MTT_ENTRY_HEADER mttEntryHeaderWrap;
    P_MTT_ENTRY_HEADER mttEntryHeaderNext;
    P_MTT_ENTRY_HEADER mttEntryHeaderNext2;
    P_MTT_ENTRY_HEADER mttEntryHeaderNext3;
    P_MTT_ENTRY_HEADER mttEntryHeaderNextCurr;

    // Check if there is an explicit REFRESH requested
    get_modev(1,refresh,'N');
    get_oiv(2,sname,-1);

    staeret = _setjmp_stae(jb, NULL);
    if (staeret == 0) {

        // enable privileged mode
        privilege(1);

        // point to control blocks
        psa = 0;
        cvt = psa[4];              //  16
        mser = cvt[37];            // 148
        if(sname<0) {
           R_screate(2048);          // create string array
           sname = LINT(*ARGR);         // save new sarray token
        }
        sindex = (char **) sarray[sname];
        setIntegerVariable("mtt_sarray", sname);

        // point to master trace table header
        mttHeader = mser[35];
        // get most current mtt entry
        mttEntryHeader = (P_MTT_ENTRY_HEADER) mttHeader->current;
        // if most current entry is equal with the previous one and no REFERSH is requested, don't scan TT
        if (refresh == 'R' || strcmp((const char *) &mttEntryHeader->callerData, savedEntry) != 0) {
            // save first entry
            memcpy(&savedEntry, (char *) &mttEntryHeader->callerData, 80);
            // iterate from most current mtt entry to the  end of the mtt
            while (((uintptr_t) mttEntryHeader) + mttEntryHeader->len + 10 <= (uintptr_t) mttHeader->end) {
                // buffer entry
                snew(entries, (char *) &mttEntryHeader->callerData, -1);
                entries++;
                // point to next entry
                mttEntryHeader = (P_MTT_ENTRY_HEADER) (((uintptr_t) mttEntryHeader) + mttEntryHeader->len + 10);
            }
            // get mtt entry at wrap point
            mttEntryHeader = (P_MTT_ENTRY_HEADER) mttHeader->wrapPoint;
            // iterate from wrap point to most current mtt entry
            while (((uintptr_t) mttEntryHeader) + mttEntryHeader->len + 10 < (uintptr_t) mttHeader->current) {
                // buffer entry
                snew(entries, (char *) &mttEntryHeader->callerData, -1);
                entries++;
                // point to next entry
                mttEntryHeader = (P_MTT_ENTRY_HEADER) (((uintptr_t) mttEntryHeader) + mttEntryHeader->len + 10);
            }
            // set sarray hi count
            sarrayhi[sname] = entries;
        } else {
            entries = -1;
        }

        // disable privileged mode
        privilege(0);

        rc = _setjmp_canc();

        if (rc > 0) {
            fprintf(STDERR, "ERROR: MTT STAE routine ended with RC(%d)\n", rc);
        }

    } else if (staeret == 1) {
        entries=-1;             // return no new entries found
        _write2op("BREXX/370 MTT FUNCTION IN ERROR");
    }

    Licpy(ARGR, entries);
}



/* -----------------------------------------------------------------------------------
 * SUBMIT(DSN) SUBMIT(")STEM stemname.")
 *   rc :  -1  INTRDR can't be allocated
 *   rc :  -2  INTRDR can't be opened
 *   rc :  -3  JCL DSN can't be allocated or opened
 *   rc :  -4  STEM.0 is not set or not numeric
 * -----------------------------------------------------------------------------------
 */
void R_submit(int func) {
    int iErr = 0, ii, recs, mode=-1;
    char *_style_old = _style;
    char sFileName[55];
    char pbuff[80];

    __dyn_t dyn_parms;
    PLstr plsValue;
    FILE *ftin = NULL, *ftout = NULL;

    LASCIIZ(*ARG1)
    get_s(1)
    Lupper(ARG1);
    if (LSTR(*ARG1)[LLEN(*ARG1) - 1] == '.') mode = 1;
    else if (LSTR(*ARG1)[0] == '*')             mode = 3;
    else mode = 0;
/*--------------------------------------------------------
 * 1. Allocate internal Reader and open it
 * -----------------------------------------------------------------------------------
 */
    dyninit(&dyn_parms);   // init DYNALLOC

    //   dyn_parms.__ddname = (char *) "SUBINT";
    //   free DDNAME, just in case it's allocated
    iErr = dynfree(&dyn_parms);
    // Allocate INTRDR
    dyn_parms.__sysout = 'A';
    dyn_parms.__sysoutname = (char *) "INTRDR";
    dyn_parms.__lrecl = 80;
    dyn_parms.__blksize = 80;
    dyn_parms.__recfm = _F_;
    dyn_parms.__misc_flags = __CLOSE;
    iErr = dynalloc(&dyn_parms);
    if (iErr != 0) iError(-1,cleanup)
    else {
        //     printf("PEJ> %s\n", dyn_parms.__retddn);
        _style = "//DDN:";
        ftout = fopen(dyn_parms.__retddn,"w");
        if (ftout == NULL) iError(-2,cleanup)
    }
/* -----------------------------------------------------------------------------------
 * 2. OPEN JCL DSN
 * -----------------------------------------------------------------------------------
 */
    if (mode == 1)      goto writeStem;    // mode 1: is stem
    else if (mode == 3) goto writeQueue;   // mode 3: is queue
    else if (mode == 0) {                  // mode 0: is DSN
        _style = "//DSN:";    // Complete DSN
        getDatasetName(environment, (const char *) LSTR(*ARG1), sFileName);
        ftin = fopen(sFileName, "r");
        if (ftin != NULL) goto writeDSN;
        iError(-3,cleanup)
    }
    /* -----------------------------------------------------------------------------------
     * 4 CLEANUP end end
     * -----------------------------------------------------------------------------------
     */
    cleanup:
    if (ftin  !=0 ) fclose(ftin);
    if (ftout !=0 ) fclose(ftout);
    _style = _style_old;
    //  dynfree(&dyn_parms);

    Licpy(ARGR,iErr);

    return;
    /* -----------------------------------------------------------------------------------
     * 3.1 WRITE STEM to INTRDR
     * -----------------------------------------------------------------------------------
     */
    writeStem:
    LPMALLOC(plsValue)

    recs = getStemV0(LSTR(*ARG1));
    if (recs==0) iErr=-4;
    else {
        for (ii = 1; ii <= recs; ii++) {
            getStemV(plsValue, LSTR(*ARG1), ii);
            sprintf(pbuff, "%s\n", LSTR(*plsValue));
            fputs(pbuff, ftout);
        }
    }
    LPFREE(plsValue);
    goto cleanup;
/* -----------------------------------------------------------------------------------
 * 3.2 WRITE JCL to INTRDR
 * -----------------------------------------------------------------------------------
 */
    writeDSN:
    while (fgets(pbuff, 80, ftin)) {
        fputs(pbuff, ftout);
    }
    goto cleanup;
/* -----------------------------------------------------------------------------------
 * 3.3 WRITE JCL from Queue
 * -----------------------------------------------------------------------------------
 */
    writeQueue:
    recs =  StackQueued();
    //  printf("QUEUE recs %d \n",recs);
    for (ii = 1; ii <= recs; ii++) {
        plsValue=PullFromStack();
        fputs(LSTR(*plsValue), ftout);
        fputs("\n", ftout);
        LPFREE(plsValue);
    }
    goto cleanup;
/* end of SUBMIT Procedure */
}

void R_e2a(int func){
    get_s(1);
    LE2A(ARGR, ARG1);
}

void R_a2e(int func){
    get_s(1);
    LA2E(ARGR, ARG1);
}

/* -----------------------------------------------------------------------------------
 * Convert Number as unsigned integer to String
 * -----------------------------------------------------------------------------------
 */
void R_c2u( int func )
{
    int	i,n=0;
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

    n = MIN(n,LLEN(*ARG1));
    unum = 0;
    for (i=n-1; i>=0; i--)
        unum = (unum << 8) | ((byte) (LSTR(*ARGR)[i]) & 0xFF);

    sprintf(LSTR(*ARGR), "%lu", unum);
    LTYPE(*ARGR)=LSTRING_TY;
    LLEN(*ARGR) = STRLEN(LSTR(*ARGR));
}

void R_putsmf(int func)
{
    int smf_recordnum, rc = 0;
    RX_SVC_PARAMS svcParams;
    SMF_RECORD smf_record ;

    /*
    if (!rac_check(FACILITY, SMF, READ)) {
        RxSetSpecialVar(RCVAR, -3);
        return;
    }
    */

    // process input fields
    if (ARGN != 2) Lerror(ERR_INCORRECT_CALL, 0);   // then NOP;
// get and check SMF record type
    get_i(1,smf_recordnum);
    if (smf_recordnum<=0 || smf_recordnum>=255) {
        printf ("SMF invalid record type %d\n",smf_recordnum);
        Lerror(ERR_INCORRECT_CALL, 0);
    }
// get SMF text correct lenght
    LASCIIZ(*ARG2)
    get_s(2)
    if (LLEN(*ARG2)>sizeof(smf_record.data)) LLEN(*ARG2)=sizeof(smf_record.data);

// set SMF record header
    memset(&smf_record,0,sizeof(SMF_RECORD));
    // JCC aligns to fullword, therefore SMF_RECORD is 2 bytes longer
    smf_record.reclen    = sizeof(SMF_RECORD) - sizeof(smf_record.data) + LLEN(*ARG2) - 2;
    smf_record.segdesc   = 0;
    smf_record.sysiflags = 2;
    smf_record.rectype   = smf_recordnum;

    setSmfTime((P_SMF_RECORD_BASE_HEADER) &smf_record);       // calculate and SMF record time
    setSmfDate((P_SMF_RECORD_BASE_HEADER) &smf_record);       // calculate and SMF record date
    setSmfSid((P_SMF_RECORD_BASE_HEADER) &smf_record);        // set remaining header fields

// set SMF record message
    memcpy(&smf_record.data,LSTR(*ARG2),LLEN(*ARG2));
//  DumpHex((const unsigned char *) &smf_record,smf_record.reclen);

// execute SMF SVC
    rc = writeUserSmfRecord(&smf_record);
// set return code (R15 of SVC
    Licpy(ARGR, rc);
}

void R_dummy(int func)
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

    bzero(STPB,  32);
    bzero(LSD,   16);
    bzero(&iopl, 16);

    rc = updateIOPL(&iopl);

    LSD[3] = LSTR(*ARG1);
    STPB[1] = LSD;

    rc = loadLoadModule("IKJSTCK ", (void **)&ikjstck);
    printf("DBG> IKJSTCK called with RC=%d\n", rc);

    printf("DBG> calling IKJSTCK\n");

    iopl.IOPLIOPB = &STPB;

    rc = ikjstck(iopl);

    printf("DBG> done with RC=%d\n", rc);
}

/*
void R_dummy(int func)
{
    char data[255];
    int ii =0;

    bzero(data, 255);
    printf("FOO> \n");

    loop:
    ii = tget_nowait(&data[0], 254);
    if (ii > 0) {
        printf("FOO> i=%d - data='%s' \n", ii, data);
    } else {
        Sleep(500);
    }

    goto loop;

}
*/

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

}
#endif

//
// EXPORTED FUNCTIONS
//
int RxMvsInitialize()
{
    RX_INIT_PARAMS_PTR      init_parameter;
    RX_TSO_PARAMS_PTR       tso_parameter;
    RX_WORK_BLK_EXT_PTR     wrk_block;
    RX_PARM_BLK_PTR         parm_block;
    RX_SUBCMD_TABLE_PTR     subcmd_table;
    RX_SUBCMD_ENTRY_PTR     subcmd_entry;
    RX_SUBCMD_ENTRY_PTR     subcmd_entries;
    RX_IRXEXTE_PTR          irxexte;

    RX_SVC_PARAMS           svcParams;

    void ** pEnvBlock;

    char IRXEXCOM[8] = "IRXEXCOM";

    int      rc     = 0;

#ifdef __DEBUG__
    if (entry_R13 != 0) {
        printf("DBG> SA at %p\n", (void *) (uintptr_t) entry_R13);
    }
#endif

    init_parameter   = MALLOC(sizeof(RX_INIT_PARAMS), "RxMvsInitialize_init_parms");
    memset(init_parameter, 0, sizeof(RX_INIT_PARAMS));

    environment      = MALLOC(sizeof(RX_ENVIRONMENT_CTX), "RxMvsInitialize_environment");
    memset(environment, 0, sizeof(RX_ENVIRONMENT_CTX));

    init_parameter->rxctxadr = (unsigned *)environment;

    rc = call_rxinit(init_parameter);

    if ((environment->flags3 & _STDIN) == _STDIN) {
        reopen(_STDIN);
    }
    if ((environment->flags3 & _STDOUT) == _STDOUT) {
        reopen(_STDOUT);
    }
    if ((environment->flags3 & _STDERR) == _STDERR) {
        reopen(_STDERR);
    }

    // save initial cppl
    if (isTSO()) {
        environment->cppl = entry_R13[6];
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

    /* real rexx stuff */
    subcmd_entries = MALLOC(DEFAULT_NUM_SUBCMD_ENTRIES * sizeof(RX_SUBCMD_ENTRY), "RxMvsInitialize_subcmd_entries");
    bzero(subcmd_entries,      DEFAULT_NUM_SUBCMD_ENTRIES * sizeof(RX_SUBCMD_ENTRY));

    subcmd_table = MALLOC(sizeof(RX_SUBCMD_TABLE), "RxMvsInitialize_subcmd_table");
    bzero(subcmd_table, sizeof(RX_SUBCMD_TABLE));

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
    bzero(parm_block, sizeof(RX_PARM_BLK));

    memcpy(parm_block->parmblock_id,       "IRXPARMS", 8);
    memcpy(parm_block->parmblock_version,  "0200",     4);
    memcpy(parm_block->parmblock_language, "ENU",      3);  //AmericanEnglisch
    parm_block->parmblock_subcomtb = subcmd_table;

    irxexte =  MALLOC(sizeof(RX_IRXEXTE), "RxMvsInitialize_irxexte");
    bzero(irxexte, sizeof(RX_IRXEXTE));

    wrk_block = MALLOC(sizeof(RX_WORK_BLK_EXT), "RxMvsInitialize_wrk_block");
    bzero(wrk_block, sizeof(RX_WORK_BLK_EXT));

    env_block = MALLOC(sizeof(RX_ENVIRONMENT_BLK), "RxMvsInitialize_env_block");
    bzero(env_block, sizeof(RX_ENVIRONMENT_BLK));

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

    if (environment)
        FREE(environment);

}

void RxMvsRegFunctions()
{
    RxRacRegFunctions();
    RxTcpRegFunctions();
    RxNjeRegFunctions();

    /* MVS specific functions */
    RxRegFunction("ENCRYPT",    R_crypt,        0);
    RxRegFunction("DATTIMBASE", R_dattimbase,   0);
    RxRegFunction("DECRYPT",    R_decrypt,      0);
    RxRegFunction("FREE",       R_free,         0);
    RxRegFunction("ALLOCATE",   R_allocate,     0);
    RxRegFunction("CREATE",     R_create,       0);
    RxRegFunction("EXISTS",     R_exists,       0);
    RxRegFunction("RENAME",     R_renamedsn,    0);
    RxRegFunction("REMOVE",     R_removedsn,    0);
    RxRegFunction("DUMPIT",     R_dumpIt,       0);
    RxRegFunction("LISTIT",     R_listIt,       0);
    RxRegFunction("WAIT",       R_wait,         0);
    RxRegFunction("WTO",        R_wto ,         0);
    RxRegFunction("ABEND",      R_abend ,       0);
    RxRegFunction("USERID",     R_userid,       0);
    RxRegFunction("LISTDSI",    R_listdsi,      0);
    RxRegFunction("ROTATE",     R_rotate,       0);
    RxRegFunction("RHASH",      R_rhash,        0);
    RxRegFunction("SYSDSN",     R_sysdsn,       0);
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
    RxRegFunction("BLDL",       R_bldl,         0);
    RxRegFunction("EXEC",       R_exec,         0);
    RxRegFunction("LLCREATE",   R_llcreate,     0);
    RxRegFunction("LLADD",      R_lladd,        0);
    RxRegFunction("LLDEL",      R_lldel,        0);
    RxRegFunction("LLDELINK",   R_lldelink,     0);
    RxRegFunction("LLLINK",     R_lllink,       0);
    RxRegFunction("LLGET",      R_llget,        0);
    RxRegFunction("LLSET",      R_llset,        0);
    RxRegFunction("LLINSERT",   R_llinsert,     0);
    RxRegFunction("LLENTRY",    R_llentry,      0);
    RxRegFunction("LLLIST",     R_lllist,       0);
    RxRegFunction("LLDETAILS",  R_lldetails,    0);
    RxRegFunction("LLFREE",     R_llfree,       0);
    RxRegFunction("SCREATE",    R_screate,      0);
    RxRegFunction("SSET",       R_sset,         0);
    RxRegFunction("SGET",       R_sget,         0);
    RxRegFunction("SSWAP",      R_sswap,        0);
    RxRegFunction("SCLC",       R_sclc,         0);
    RxRegFunction("SFREE",      R_sfree,        0);
    RxRegFunction("SQSORT",     R_sqsort,       0);
    RxRegFunction("SHSORT",     R_shsort,       0);
    RxRegFunction("SREVERSE",   R_sreverse,     0);
    RxRegFunction("SMERGE",     R_smerge,       0);
    RxRegFunction("__SREAD",    R_sread,        0);
    RxRegFunction("__SWRITE",   R_swrite,       0);
    RxRegFunction("SSEARCH",    R_ssearch,      0);
    RxRegFunction("SSELECT",    R_sselect,       0);
    RxRegFunction("SARRAY",     R_sarray,       0);
    RxRegFunction("SPRINT",     R_sprint,       0);
// Matrix Integer functions
    RxRegFunction("ICREATE",    R_icreate,      0);
    RxRegFunction("IGET",       R_iget,         0);
    RxRegFunction("ISET",       R_iset,         0);
    RxRegFunction("SFCREATE",   R_sfcreate,     0);
    RxRegFunction("SFGET",      R_sfget,        0);
    RxRegFunction("SFSET",      R_sfset,        0);
    RxRegFunction("SFFREE",     R_sffree,       0);
    RxRegFunction("MCREATE",    R_mcreate,      0);
    RxRegFunction("MDELCOL",    R_mdelcol,      0);
    RxRegFunction("MDELROW",    R_mdelrow,      0);
    RxRegFunction("MGET",       R_mget,         0);
    RxRegFunction("MSET",       R_mset,         0);
    RxRegFunction("MNORMALISE", R_mnormalise,   0);
    RxRegFunction("MMULTIPLY",  R_mmultiply,    0);
    RxRegFunction("MTRANSPOSE", R_mtranspose,   0);
    RxRegFunction("MCOPY",      R_mcopy,        0);
    RxRegFunction("MINVERT",    R_minvert,      0);
    RxRegFunction("MPROPERTY",  R_mproperty,    0);
    RxRegFunction("MSCALAR",    R_mscalar,      0);
    RxRegFunction("MADD",       R_madd,         0);
    RxRegFunction("MSUBTRACT",  R_msubtract,    0);
    RxRegFunction("MPROD",      R_mprod,        0);
    RxRegFunction("MSQR",       R_msqr,         0);
    RxRegFunction("MINSCOL",    R_minscol,      0);
    RxRegFunction("MFREE",      R_mfree,        0);
    RxRegFunction("MUSED",      R_mused,        0);
    RxRegFunction("MEMORY",     R_memory,       0);
    RxRegFunction("BITARRAY",   R_bitarray,     0);
    RxRegFunction("PRIME",      R_prime,        0);
    RxRegFunction("RXLIST",     R_rxlist,       0);
    //    RxRegFunction("STEMCOPY",   R_stemcopy,     0);
    RxRegFunction("DIR",        R_dir,          0);
    RxRegFunction("GETG",       R_getg,         0);
    RxRegFunction("SETG",       R_setg,         0);
    RxRegFunction("LEVEL",      R_level,        0);
    RxRegFunction("ENQ",        R_enq,          0);
    RxRegFunction("DEQ",        R_deq,          0);
    RxRegFunction("ERROR",      R_error,        0);
    RxRegFunction("CHAR",       R_char,         0);
    RxRegFunction("TYPE",       R_type,         0);
    RxRegFunction("OUTTRAP",    R_outtrap,      0);
    RxRegFunction("SUBMIT",     R_submit,       0);
    RxRegFunction("E2A",        R_e2a,          0);
    RxRegFunction("A2E",        R_a2e,          0);
    RxRegFunction("C2U",        R_c2u ,         0);

    if (rac_check(FACILITY, SVC244, READ)) {
        RxRegFunction("PUTSMF", R_putsmf, 0);
        RxRegFunction("PRIVILEGE", R_privilege, 0);
        RxRegFunction("CONSOLE", R_console, 0);
        RxRegFunction("MTT",        R_mtt ,         0);
        RxRegFunction("MTTX",        R_mttx ,         0);
    }

#ifdef __DEBUG__
    RxRegFunction("TEST",       R_test,         0);
    RxRegFunction("MAGIC",      R_magic,        0);
    RxRegFunction("DUMMY",      R_dummy,        0);
#endif
}

int isTSO() {
    int ret = 0;

    if ((environment->flags2 & _TSOFG) == _TSOFG ||
        (environment->flags2 & _TSOBG) == _TSOBG) {
        ret = 1;
    }

    return ret;
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
        ascb = psa[137];
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

void getVariable(char *sName, PLstr plsValue)
{
    Lstr lsScope,lsName;

    LINITSTR(lsScope)
    LINITSTR(lsName)

    Lfx(&lsScope,sizeof(dword));
    Lfx(&lsName, strlen(sName));

    Licpy(&lsScope,_rx_proc);
    Lscpy(&lsName, sName);

    RxPoolGet(&lsScope, &lsName, plsValue);

    LASCIIZ(*plsValue)

    LFREESTR(lsScope)
    LFREESTR(lsName)
}

char *getStemVariable(char *sName)
{
    char  sValue[4097];
    Lstr lsScope,lsName,lsValue;

    LINITSTR(lsScope)
    LINITSTR(lsName)
    LINITSTR(lsValue)

    Lfx(&lsScope,sizeof(dword));
    Lfx(&lsName, strlen(sName));

    Licpy(&lsScope,_rx_proc);
    Lscpy(&lsName, sName);

    RxPoolGet(&lsScope, &lsName, &lsValue);

    LASCIIZ(lsValue)

    if(LTYPE(lsValue)==1) {
        sprintf(sValue,"%d",LINT(lsValue));
    }
    if(LTYPE(lsValue)==2) {
        sprintf(sValue,"%f",LREAL(lsValue));
    }
    if(LTYPE(lsValue)==0) {
        memset(sValue,0,sizeof(sValue));
        strncpy(sValue,LSTR(lsValue),LLEN(lsValue));
    }

    LFREESTR(lsScope)
    LFREESTR(lsName)
    LFREESTR(lsValue)

    return (char *)sValue[0];
}

int getIntegerVariable(char *sName) {
    char sValue[19];
    PLstr plsValue;
    LPMALLOC(plsValue)
    getVariable(sName, plsValue);

    if(LTYPE(*plsValue)==1) {
        sprintf(sValue,"%d",(int)LINT(*plsValue));
    } else if (LTYPE(*plsValue)==0) {
        memset(sValue,0,sizeof(sValue));
        strncpy(sValue,(const char*)LSTR(*plsValue),LLEN(*plsValue));
    } else {
        sprintf(sValue,"%d",0);
    }

    LPFREE(plsValue);

    return (atoi(sValue));
}

int privilege(int state)
{
    int rc = 8;

    RX_SVC_PARAMS svc_parameter;

    if (!rac_check(FACILITY, SVC244, READ)) {
        return rc;
    }

    // get current authorization state
    if (_authorisedNative == -1)
        _authorisedNative = _testauth();

    if (state == 1) {
        /* SET AUTHORIZED 1 */
        if (_authorisedNative == 0) {
            svc_parameter.R0 = (uintptr_t) 0;
            svc_parameter.R1 = (uintptr_t) 1;
            svc_parameter.SVC = 244;
            call_rxsvc(&svc_parameter);

            rc = 0;
        }

        /* MODSET KEY=ZERO
        svc_parameter.R0 = (uintptr_t) 0;
        svc_parameter.R1 = (uintptr_t) 0x30; // DC    B'00000000 00000000 00000000 00110000'
        svc_parameter.SVC = 107;
        call_rxsvc(&svc_parameter);
        */
        rc = _modeset(0);
        _authorisedGranted=1;
    } else if (state == 0  && _authorisedGranted == 1) {
        /* MODSET KEY=NZERO
        svc_parameter.R0 = (uintptr_t) 0;
        svc_parameter.R1 = (uintptr_t) 0x20; // DC    B'00000000 00000000 00000000 00100000'
        svc_parameter.SVC = 107;
        call_rxsvc(&svc_parameter);
        */
        _modeset(1);

        /* Reset AUTHORIZED 0 */
        if (_authorisedNative == 0) {
            svc_parameter.R0 = (uintptr_t) 0;
            svc_parameter.R1 = (uintptr_t) 0;
            svc_parameter.SVC = 244;
            call_rxsvc(&svc_parameter);
        }
        _authorisedGranted = 0;
    }

    return rc;
}

void setVariable(char *sName, char *sValue)
{
    Lstr lsScope,lsName,lsValue;

    LINITSTR(lsScope)
    LINITSTR(lsName)
    LINITSTR(lsValue)

    Lfx(&lsScope,sizeof(dword));
    Lfx(&lsName, strlen(sName));
    Lfx(&lsValue, strlen(sValue));

    Licpy(&lsScope,_rx_proc);
    Lscpy(&lsName, sName);
    Lscpy(&lsValue, sValue);

    LASCIIZ(lsName);
    LASCIIZ(lsValue);

    RxPoolSet(&lsScope, &lsName, &lsValue);

    LFREESTR(lsScope)
    LFREESTR(lsName)
    LFREESTR(lsValue)
}

void setVariable2(char *sName, char *sValue, int lValue)
{
    Lstr lsScope,lsName,lsValue;

    LINITSTR(lsScope)
    LINITSTR(lsName)
    LINITSTR(lsValue)

    Lfx(&lsScope,sizeof(dword));
    Lfx(&lsName, strlen(sName));
    Lfx(&lsValue, lValue);

    Licpy(&lsScope,_rx_proc);
    Lscpy(&lsName, sName);
    Lscpy2(&lsValue, sValue, lValue);

    RxPoolSet(&lsScope, &lsName, &lsValue);

    LFREESTR(lsScope)
    LFREESTR(lsName)
    LFREESTR(lsValue)
}

void setIntegerVariable(char *sName, int iValue)
{
    char sValue[19];

    sprintf(sValue,"%d",iValue);
    setVariable(sName,sValue);
}

int findLoadModule(char moduleName[8])
{
    int found = 0;

    RX_BLDL_PARAMS bldlParams;
    RX_SVC_PARAMS svcParams;

    memset(&bldlParams, 0, sizeof(RX_BLDL_PARAMS));
    memset(&bldlParams.BLDLN, ' ', 8);

    strncpy(bldlParams.BLDLN,
            moduleName,
            MIN(sizeof(bldlParams.BLDLN), strlen(moduleName)));

    bldlParams.BLDLF = 1;
    bldlParams.BLDLL = 50;

    svcParams.SVC = 18;
    svcParams.R0  = (uintptr_t) &bldlParams;
    svcParams.R1  = 0;

    call_rxsvc(&svcParams);

    if (svcParams.R15 == 0) {
        found = 1;
    }

    return found;
}

int loadLoadModule(char moduleName[8], void **pAddress)
{
    int iRet = 0;

    RX_SVC_PARAMS  svcParams;
    svcParams.SVC = 8;
    svcParams.R0  = (uintptr_t) moduleName;
    svcParams.R1  = 0;

    call_rxsvc(&svcParams);

    if (svcParams.R15 == 0) {
        *pAddress = (void *) (uintptr_t)svcParams.R0;
    }

    return svcParams.R15;
}

int linkLoadModule(const char8 moduleName, void *pParmList, void *GPR0)
{
    RX_SVC_PARAMS      svcParams;

    void *modInfo[2];
    modInfo[0] = (void *) moduleName;
    modInfo[1] = 0;

    svcParams.SVC = 6;
    svcParams.R0  = (unsigned int) (uintptr_t) GPR0;
    svcParams.R1  = (unsigned int) (uintptr_t) pParmList;
    svcParams.R15 = (unsigned int) (uintptr_t) &modInfo;

    call_rxsvc(&svcParams);

    return svcParams.R15;
}

int getRunId()
{
    int runId = 0;

    if (environment->runId == 0) {
        srand((unsigned) time((time_t *)0)%(3600*24));
        runId = rand() % 9999;
    } else {
        runId = environment->runId;
    }

    return runId;
}

//
// INTERNAL FUNCTIONS
//

void parseArgs(char **array, char *str)
{
    int i = 0;
    char *p = strtok (str, " ");
    while (p != NULL)
    {
        array[i++] = p;
        p = strtok (NULL, " ");
    }
}

void parseDCB(FILE *pFile)
{
    unsigned char *flags;
    unsigned char  sDsn[45];
    unsigned char  sDdn[9];
    unsigned char  sMember[9];
    unsigned char  sSerial[7];
    unsigned char  sLrecl[6];
    unsigned char  sBlkSize[6];

    flags = MALLOC(11, "dcbflags");
    __get_ddndsnmemb(fileno(pFile), (char *)sDdn, (char *)sDsn, (char *)sMember, (char *)sSerial, flags);

    /* DSN */
    if (sDsn[0] != '\0')
        setVariable("SYSDSNAME", (char *)sDsn);

    /* DDN */
    if (sDdn[0] != '\0')
        setVariable("SYSDDNAME", (char *)sDdn);

    /* MEMBER */
    if (sMember[0] != '\0')
        setVariable("SYSMEMBER", (char *)sMember);

    /* VOLSER */
    if (sSerial[0] != '\0')
        setVariable("SYSVOLUME", (char *)sSerial);

    /* DSORG */
    if(flags[4] == 0x40)
        setVariable("SYSDSORG", "PS");
    else if (flags[4] == 0x02)
        setVariable("SYSDSORG", "PO");
    else
        setVariable("SYSDSORG", "???");

    /* RECFM */
    if(flags[6] == 0x40)
        setVariable("SYSRECFM", "V");
    else if(flags[6] == 0x50)
        setVariable("SYSRECFM", "VB");
    else if(flags[6] == 0x54)
        setVariable("SYSRECFM", "VBA");
    else if(flags[6] == 0x80)
        setVariable("SYSRECFM", "F");
    else if(flags[6] == 0x90)
        setVariable("SYSRECFM", "FB");
    else if(flags[6] == 0xC0)
        setVariable("SYSRECFM", "U");
    else
        setVariable("SYSRECFM", "??????");

    /* BLKSIZE */
    sprintf((char *)sBlkSize, "%d", flags[8] | flags[7] << 8);
    setVariable("SYSBLKSIZE", (char *)sBlkSize);

    /* LRECL */
    sprintf((char *)sLrecl, "%d", flags[10] | flags[9] << 8);
    setVariable("SYSLRECL", (char *)sLrecl);

    FREE(flags);
}

int reopen(int fp) {

    int new_fp, rc = 0;
    char* _style_old = _style;

#ifdef JCC
    _style = "//DDN:";
    switch(fp) {
        case 0x01:
            if (stdin != NULL) {
              fclose(stdin);
            }

            new_fp = _open("STDIN", O_TEXT | O_RDONLY);
            rc = _dup2(new_fp, 0);
            _close(new_fp);

            stdin = fdopen(0,"rt");

            break;
        case 0X02:
            if (stdout != NULL) {
              fclose(stdout);
            }

            new_fp = _open("STDOUT", O_TEXT | O_WRONLY);
            rc = _dup2(new_fp, 1);
            _close(new_fp);

            stdout = fdopen(1,"at");

            break;
        case 0x04:
            if (stderr != NULL) {
              fclose(stderr);
            }

            new_fp = _open("STDERR", O_TEXT | O_WRONLY);
            rc = _dup2(new_fp, 2);
            _close(new_fp);

            stderr = fdopen(2, "at");

            break;
        default:
            rc = ERR_INITIALIZATION;
            break;
    }
#endif
    _style = _style_old;

    return 0;
}