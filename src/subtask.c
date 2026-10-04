#include <mvs/thread.h>

/* no BREXX header beyond subtask.h here: <mvs/thread.h> brings its own
 * SDWA, which rxmvsext.h defines too */
#include "subtask.h"

long
subtaskStart(int (*start)(void *), void *arg)
{
    return (long) cthread_create((void *) start, arg, NULL);
}

int
subtaskWait(long handle)
{
    CTHDTASK *task = (CTHDTASK *) handle;
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
subtaskEnd(int rc)
{
    cthread_exit(rc);
}
