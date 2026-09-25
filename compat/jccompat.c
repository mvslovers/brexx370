/*
 * jccompat.c - JCC runtime compatibility layer for the cc370/libc370 build
 *
 * Implements the JCC library functions BREXX/370 depends on in terms of
 * libc370. See jccompat.h for the overview and docs/cc370-migration.md for
 * the list of known gaps (marked TODO(cc370) below).
 */
#include "jccompat.h"

#if !defined(JCC) && !defined(__CROSS__)

#include <ctype.h>
#include <clibio.h>
#include <clibos.h>
#include <clibwto.h>
#include <clibecb.h>
#include <clibtso.h>
#include <time64.h>
#include <racf.h>
#include <clibthrd.h>
#include <clibppa.h>

/* ------------------------------------------------------------------ */
/* JCC runtime globals                                                 */
/* ------------------------------------------------------------------ */
char  *_style            = "//DDN:";    /* JCC default style           */
int    __libc_tso_status = 0;
long   __libc_arch       = 0;
long   __libc_heap_used  = 0;
long   __libc_heap_max   = 0;
long   __libc_stack_used = 0;
long   __libc_stack_max  = 0;

/*
 * Only word 6 (R1 at entry) is used by BREXX: under TSO it is the CPPL,
 * which libc370 keeps in the PPA. Returns NULL if there is no PPA.
 * TODO(cc370): the other words of the entry save area are not provided.
 */
void **
jcc_entry_r13(void)
{
    static void *savearea[18];
    CLIBPPA *ppa = __ppaget();

    if (ppa == NULL)
        return NULL;
    savearea[6] = ppa->ppacppl;
    return savearea;
}

/* ------------------------------------------------------------------ */
/* fopen() with JCC name styles                                        */
/* ------------------------------------------------------------------ */
#define STYLE_DDN  0
#define STYLE_DSN  1
#define STYLE_MEM  2
#define STYLE_HFS  3
#define STYLE_NULL 4

static int
style_of(const char *style)
{
    if (style == NULL)                          return STYLE_DDN;
    if (strncmp(style, "//DSN:", 6) == 0)       return STYLE_DSN;
    if (strncmp(style, "//MEM:", 6) == 0)       return STYLE_MEM;
    if (strncmp(style, "//HFS:", 6) == 0)       return STYLE_HFS;
    return STYLE_DDN;
}

/*
 * Reduce a JCC mode string ("rb,klen=0,lrecl=256,recfm=u,force") to what
 * libc370 understands: the base mode plus the libc370 options "record",
 * "bsam" and "rlse". JCC's DCB defaults (recfm/lrecl/blksize/force, vtoc,
 * volser/unit/pri/sec/dirblks) have no libc370 equivalent and are dropped.
 * TODO(cc370): PDSdet()/VTOC access rely on ",recfm=u,force" / ",vtoc".
 */
static void
map_mode(const char *mode, char *out, size_t outlen)
{
    size_t i = 0;
    const char *p;

    for (p = mode; *p && *p != ',' && i < outlen - 1; p++)
        out[i++] = (char) tolower((unsigned char) *p);
    out[i] = '\0';

    /*
     * libc370 has no update modes ('+' makes fopen() fail). "a+" is safe
     * to reduce to "a" (append only, reading back is not possible). "r+"
     * and "w+" are left to fail on purpose: BREXX falls back from "r+" to
     * "w+" when CHAROUT/LINEOUT open a file, and turning that into "w"
     * would silently truncate an existing dataset.
     * TODO(cc370): libc370 update modes (libc370#189).
     */
    if (out[0] == 'a') {
        char *plus = strchr(out, '+');
        if (plus != NULL)
            memmove(plus, plus + 1, strlen(plus));
        i = strlen(out);
    }

    while (*p == ',') {
        const char *opt = ++p;
        size_t len = 0;

        while (p[len] && p[len] != ',') len++;
        if ((len == 6 && strncmp(opt, "record", 6) == 0) ||
            (len == 4 && strncmp(opt, "bsam", 4) == 0) ||
            (len == 4 && strncmp(opt, "rlse", 4) == 0)) {
            if (i + len + 1 < outlen) {
                out[i++] = ',';
                memcpy(out + i, opt, len);
                i += len;
                out[i] = '\0';
            }
        }
        p += len;
    }
}

FILE *
jcc_fopen(const char *filename, const char *mode)
{
    char name[FILENAME_MAX];
    char lmode[64];
    int  style;

    if (filename == NULL || mode == NULL)
        return NULL;

    /* an explicit style prefix wins over _style */
    if (strncmp(filename, "//NULLFILE", 10) == 0) {
        style = STYLE_NULL;
    } else if (strncmp(filename, "//", 2) == 0 && filename[5] == ':') {
        style = style_of(filename);
        filename += 6;
    } else {
        style = style_of(_style);
    }

    map_mode(mode, lmode, sizeof(lmode));

    switch (style) {
        case STYLE_DDN:
            snprintf(name, sizeof(name), "DD:%s", filename);
            break;
        case STYLE_DSN:
            /* JCC DSN style names are fully qualified */
            if (filename[0] == '\'' || filename[0] == '&')
                snprintf(name, sizeof(name), "%s", filename);
            else
                snprintf(name, sizeof(name), "'%s'", filename);
            break;
        default:
            /* TODO(cc370): memory files (//MEM:), HFS and //NULLFILE */
            errno = EINVAL;
            return NULL;
    }

    return (fopen)(name, lmode);
}

/* ------------------------------------------------------------------ */
/* Reads on output-only streams                                        */
/* ------------------------------------------------------------------ */
static int
readable(FILE *fp)
{
    if (fp != NULL && (fp->flags & _FILE_FLAG_WRITE) &&
        !(fp->flags & _FILE_FLAG_READ)) {
        errno = EBADF;
        return 0;
    }
    return 1;
}

int
jcc_fgetc(FILE *fp)
{
    return readable(fp) ? (fgetc)(fp) : EOF;
}

char *
jcc_fgets(char *s, int n, FILE *fp)
{
    return readable(fp) ? (fgets)(s, n, fp) : NULL;
}

size_t
jcc_fread(void *p, size_t size, size_t n, FILE *fp)
{
    return readable(fp) ? (fread)(p, size, n, fp) : 0;
}

/* ------------------------------------------------------------------ */
/* Handles                                                             */
/* ------------------------------------------------------------------ */
int
jcc_fileno(FILE *fp)
{
    return (int) fp;
}

int
jcc_isatty(int handle)
{
    FILE *fp = (FILE *) handle;

    return fp != NULL && (fp->flags & _FILE_FLAG_TERM) != 0;
}

/*
 * Return DD, DSN, member and volser of an open stream plus an 11 byte
 * JFCB extract (see JCC fopen documentation for the layout).
 * TODO(cc370): libc370 keeps no volser / DSORG in the FILE; the volser is
 * returned empty and DSORG is derived from the presence of a member.
 */
int
__get_ddndsnmemb(int handle, char *ddn, char *dsn, char *member,
                 char *serial, unsigned char *flags)
{
    FILE *fp = (FILE *) handle;

    if (fp == NULL)
        return -1;

    if (ddn)    strcpy(ddn, fp->ddname);
    if (dsn)    strcpy(dsn, fp->dataset);
    if (member) strcpy(member, fp->member);
    if (serial) serial[0] = '\0';

    if (flags) {
        memset(flags, 0, 11);
        flags[4]  = fp->member[0] ? 0x02 : 0x40;       /* DSORG PO / PS  */
        flags[6]  = fp->recfm;
        flags[7]  = (unsigned char) (fp->blksize >> 8);
        flags[8]  = (unsigned char) (fp->blksize & 0xFF);
        flags[9]  = (unsigned char) (fp->lrecl >> 8);
        flags[10] = (unsigned char) (fp->lrecl & 0xFF);
    }

    return 0;
}

/* ------------------------------------------------------------------ */
/* Authorization, recovery, operator messages                          */
/* ------------------------------------------------------------------ */
int
_testauth(void)
{
    return __isauth() ? 1 : 0;
}

/*
 * JCC: _modeset(0) = MODESET KEY=ZERO, _modeset(1) = back to the TCB key.
 * TODO(cc370): verify on MVS; __super()/__prob() also switch the state.
 */
static unsigned char saved_key = PSWKEY8;

int
_modeset(int p)
{
    if (p == 0)
        return __super(PSWKEY0, &saved_key);
    return __prob(saved_key, NULL);
}

int
_write2op(char *msg)
{
    wto(msg);
    return 0;
}

/*
 * _setjmp_estae()/_setjmp_ecanc() are BREXX's own RXSETJMP/RXECANC.
 * TODO(cc370): establish a real STAE recovery environment (libc370
 * __estae()/try()). Until then no abend is intercepted: these always
 * report "environment established" and the cancel calls are no-ops.
 */
int _setjmp_stae(jmp_buf jbs, char *sdwa104)  { (void) jbs; (void) sdwa104; return 0; }
int _setjmp_canc(void)                        { return 0; }

/* ------------------------------------------------------------------ */
/* Time                                                                */
/* ------------------------------------------------------------------ */
int
gettimeofday(struct timeval *tv, struct timezone *tz)
{
    uclock64_t now = uclock64();

    if (tv) {
        tv->tv_sec  = (long) (now / 1000000);
        tv->tv_usec = (long) (now % 1000000);
    }
    if (tz) {
        tz->tz_minuteswest = 0;
        tz->tz_dsttime     = 0;
    }
    return 0;
}

void
Sleep(long millis)
{
    unsigned ecb = 0;

    if (millis > 0)
        ecb_timed_wait(&ecb, (unsigned) ((millis + 9) / 10), 0);
}

/* ------------------------------------------------------------------ */
/* Misc.                                                               */
/* ------------------------------------------------------------------ */
char *
strupr(char *string)
{
    char *p;

    for (p = string; p && *p; p++)
        *p = (char) toupper((unsigned char) *p);
    return string;
}

int
jcc_strncasecmp(const char *a, const char *b, size_t n)
{
    for (; n > 0; a++, b++, n--) {
        int ca = tolower((unsigned char) *a);
        int cb = tolower((unsigned char) *b);

        if (ca != cb || ca == '\0')
            return ca - cb;
    }
    return 0;
}

int
jcc_strcasecmp(const char *a, const char *b)
{
    return jcc_strncasecmp(a, b, (size_t) -1);
}

/*
 * JCC: size of a heap block. libc370's malloc() takes its storage from
 * getmain(), which puts an 8 byte prefix in front of the block:
 *   +0  subpool << 24 | GETMAINed length
 *   +4  PSW key << 24 | size requested by the caller
 * so the caller's size is the low 24 bits of the word before the block.
 * (JCC had a 16 byte header, and bmem.c's auxiliary memory check read 12
 * bytes before the block -- with libc370 that crossed into an unallocated
 * page and abended S0C4 at termination.)
 * TODO(cc370): replace with a libc370 malloc_usable_size()/_msize().
 */
int
_msize(void *ptr)
{
    if (ptr == NULL)
        return 0;
    return (int) (((unsigned *) ptr)[-1] & 0x00FFFFFF);
}

/*
 * Execute a TSO command. JCC takes the full command line; libc370's
 * tsocmd() wants the command name and its operands separately.
 * TODO(cc370): no CLIST / implicit EXEC support, TSO environment only.
 */
int
systemTSO(char *cmd)
{
    char pgm[9];
    int  i = 0;
    CLIBPPA *ppa = __ppaget();

    /* JCC: -1 if the program was not called with a CPPL */
    if (ppa == NULL || ppa->ppacppl == NULL)
        return -1;

    while (*cmd == ' ') cmd++;
    while (*cmd && *cmd != ' ' && i < 8)
        pgm[i++] = (char) toupper((unsigned char) *cmd++);
    pgm[i] = '\0';
    while (*cmd && *cmd != ' ') cmd++;          /* overlong name */
    while (*cmd == ' ') cmd++;

    return tsocmd(pgm, cmd);
}

/* userid of the current address space (from the ACEE) */
char *
getlogin(void)
{
    static char userid[9];
    ACEE *acee = racf_get_acee();
    int   len;

    userid[0] = '\0';
    if (acee != NULL) {
        len = (unsigned char) acee->aceeuser[0];
        if (len > 8) len = 8;
        memcpy(userid, &acee->aceeuser[1], len);
        userid[len] = '\0';
    }
    return userid;
}

/* ------------------------------------------------------------------ */
/* Sockets                                                             */
/* ------------------------------------------------------------------ */
unsigned long
inet_addr(const char *cp)
{
    in_addr_t addr;

    if (cp == NULL || !inet_aton(cp, &addr))
        return INADDR_NONE;
    return addr.s_addr;
}

/* ------------------------------------------------------------------ */
/* Threads                                                             */
/* ------------------------------------------------------------------ */
/* returns a thread handle, 0 if the thread could not be created */
long
beginthread(int (*start)(void *), unsigned stack, void *arg)
{
    CTHDTASK *task;

    if (stack > 0)
        task = cthread_create_ex((void *) start, arg, NULL, stack);
    else
        task = cthread_create((void *) start, arg, NULL);

    return (long) task;
}

/* waits for the thread to end and returns its return code */
int
syncthread(long threadid)
{
    CTHDTASK *task = (CTHDTASK *) threadid;
    int rc;

    if (task == NULL)
        return -1;

    cthread_wait(&task->termecb);
    cthread_detach(task);
    rc = task->rc;
    cthread_delete(&task);

    return rc;
}

void
endthread(int rc)
{
    cthread_exit(rc);
}

#endif /* !JCC && !__CROSS__ */
