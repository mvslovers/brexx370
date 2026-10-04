#ifndef BREXX_SUBTASK_H
#define BREXX_SUBTASK_H

/*
 * BREXX's subtasks (the NJE38 listener, rxnje.c) on libc370 cthreads; they
 * need the crt1 startup (startup = "crt1" in project.toml). JCC called
 * these beginthread(), syncthread() and endthread(). Kept apart from the
 * BREXX headers: <mvs/thread.h> brings its own SDWA.
 *
 * subtaskStart() returns a handle, 0 if the subtask could not be created.
 * subtaskWait() waits for it to end and returns its return code, -1 for a
 * 0 handle. subtaskEnd() ends the calling subtask with rc.
 */
long subtaskStart(int (*start)(void *), void *arg)  asm("SUBTSTRT");
int  subtaskWait(long handle)                       asm("SUBTWAIT");
void subtaskEnd(int rc)                             asm("SUBTEND");

#endif /* BREXX_SUBTASK_H */
