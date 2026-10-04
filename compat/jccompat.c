/*
 * jccompat.c - JCC runtime compatibility layer for the cc370/libc370 build
 *
 * Implements the JCC library functions BREXX/370 depends on in terms of
 * libc370. See jccompat.h for the overview and docs/cc370-migration.md for
 * the list of known gaps (marked TODO(cc370) below).
 */
#include "jccompat.h"

#if !defined(JCC) && !defined(__CROSS__)

#include <stdio.h>
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
