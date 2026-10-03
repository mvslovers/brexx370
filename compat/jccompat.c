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
#include <stdio.h>
#include <mvs/apf.h>
#include <mvs/wto.h>
#include <mvs/ecb.h>
#include <ext/time64.h>
#include <mvs/racf.h>
#include <mvs/thread.h>
#include <mvs/crt.h>

/* ------------------------------------------------------------------ */
/* JCC runtime globals                                                 */
/* ------------------------------------------------------------------ */
int    __libc_tso_status = 0;
long   __libc_arch       = 0;
long   __libc_heap_used  = 0;
long   __libc_heap_max   = 0;
long   __libc_stack_used = 0;
long   __libc_stack_max  = 0;

void **
jcc_cppl(void)
{
    CLIBPPA *ppa = __ppaget();

    return ppa != NULL ? (void **) ppa->ppacppl : NULL;
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
 * JCC: _modeset(0) = MODESET KEY=ZERO, _modeset(1) = back to the TCB key,
 * both in problem state. Supervisor state with key 0, as this used to
 * leave it, makes MVS map GETMAIN/FREEMAIN of subpool 0 to subpool 252,
 * and libc370's free() then abended S30A/S378 (#191). __prob() sets a
 * key only from supervisor state, hence two steps each way. Nothing that
 * calls privilege() needs supervisor state itself: RXCPCMD switches on
 * its own, SVC 34 needs the authorisation only.
 */
static unsigned char saved_key = PSWKEY8;

int
_modeset(int p)
{
    int rc;

    if (p == 0)
        rc = __super(PSWKEY0, &saved_key);
    else
        rc = __super(saved_key, NULL);
    if (rc == 0)
        rc = __prob(PSWKEYNONE, NULL);
    return rc;
}

int
_write2op(char *msg)
{
    wto(msg);
    return 0;
}

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
