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
