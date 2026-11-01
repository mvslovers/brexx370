#define __BMEM_C__
#include "lerror.h"
#include "lstring.h"
#include "rexx.h"
#include "signal.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

extern void RxNoPriv(void);


#if defined(__DEBUG__)
#   include <errno.h>
#   include <ctype.h>
#   include "util.h"
#endif

#if !defined(__MVS__) && !defined(__MACH__)
#	include <malloc.h>
#endif

#if defined(__CROSS__)
#   include "jccdummy.h"
#endif

#define MAGIC	0xDEADBEAF

/* JCC's _msize(): the size of a heap block. libc370's malloc() takes its
 * storage from getmain(), which puts an 8 byte prefix in front of it:
 *   +0  subpool << 24 | GETMAINed length
 *   +4  PSW key << 24 | size requested by the caller
 * so the caller's size is the low 24 bits of the word before the block.
 * (JCC had a 16 byte header; reading 12 bytes before a libc370 block
 * crossed into an unallocated page and abended S0C4 at termination.) */
static int
heapSize(void *ptr)
{
    if (ptr == NULL)
        return 0;
    return (int) (((unsigned *) ptr)[-1] & 0x00FFFFFF);
}

bool
isAuxiliaryMemory(void *ptr)
{
    bool isAuxMem;
    dword *tmp;

    if (heapSize(ptr) == 0) {
        tmp = (dword *)((byte *)ptr - 12);

        if (tmp[0] == MAGIC) {
            if ((void *)tmp[1] == ptr && tmp[2] > 12) {
#ifdef __DEBUG__
                printf("DBG> %d BYTES OF AUXILIARY MEMORY FOUND AT %p\n", (int) (tmp[2]), (void *) tmp[1]);
                DumpHex((void *)tmp, tmp[2] + 12);
#endif
                isAuxMem = TRUE;
            } else {
                printf("MEMORY ERROR - FOUND CORRUPTED AUXILIARY MEMORY\n");
                isAuxMem = FALSE;
                raise(SIGSEGV);
            }
        } else {
            isAuxMem = FALSE;
        }
    } else {
        isAuxMem = FALSE;
    }

    return isAuxMem;
}

#ifndef __DEBUG__
/* Small blocks come from a pool of 8 KB chunks, the rest from libc370's
 * malloc(). libc370 takes every allocation from its own GETMAIN, adds an
 * 8 byte header and rounds up to 64 bytes, so a stem entry of four small
 * blocks (variable, name, value, tree leaf) used 256 bytes of the region.
 * In the pool the same entry takes 120 (#504).
 *
 * A pool block has the header   +0 POOL_MAGIC   +4 size class
 * in front of it, 8 bytes like libc370's own, which free_or_die()
 * recognises by the magic (a libc370 block starts with its subpool).
 * The pool belongs to the task that called BmemInit(); another task
 * (the NJE subtask) and PRIVILEGE('ON') (its key 0 puts GETMAIN into
 * subpool 252, where later stores of key 8 would abend) use malloc(). */
#define RESERVE_SIZE 16384

static void *reserve;               /* given back before the error is reported */
static int   outOfMemory;           /* the error path has been entered */

#ifdef __MVS__
#include "subtask.h"
#include "rxnje.h"
#define POOL_MAGIC   0x504F4F4CU
#define POOL_STEP    8
#define POOL_CLASSES 16
#define POOL_MAXSIZE (POOL_STEP * POOL_CLASSES)
#define POOL_CHUNK   (8192 - 8)     /* libc370's header makes it 8192 */

extern int _authorisedGranted;      /* PRIVILEGE('ON') is in effect */

typedef struct PoolFree {
    struct PoolFree *next;
} PoolFree;

static unsigned  poolOwner;                 /* TCB, 0: no pool */
static PoolFree *poolFree[POOL_CLASSES + 1];
static unsigned *poolCur;
static unsigned *poolEnd;
static void     *poolChunks;                /* first word of a chunk links */

static unsigned
currentTcb(void)
{
    return *(unsigned *) 0x21C;             /* PSATOLD */
}

static void
poolPush(unsigned *hdr, unsigned cls)
{
    hdr[0] = POOL_MAGIC;
    hdr[1] = cls;
    ((PoolFree *) (hdr + 2))->next = poolFree[cls];
    poolFree[cls] = (PoolFree *) (hdr + 2);
}

/* the rest of a chunk goes onto the free lists, then a new chunk */
static int
poolNewChunk(void)
{
    unsigned *chunk;
    unsigned  cls;

    while (poolEnd - poolCur >= 4) {        /* header and one 8 byte step */
        cls = (unsigned) (poolEnd - poolCur) / 2 - 1;
        if (cls > POOL_CLASSES)
            cls = POOL_CLASSES;
        poolPush(poolCur, cls);
        poolCur += 2 + cls * (POOL_STEP / 4);
    }
    chunk = malloc(POOL_CHUNK);
    if (chunk == NULL)
        return 0;
    chunk[0] = (unsigned) poolChunks;
    poolChunks = chunk;
    poolCur = chunk + 2;
    poolEnd = (unsigned *) ((char *) chunk + POOL_CHUNK);
    return 1;
}

static void *
poolAlloc(size_t size)
{
    unsigned  cls = (unsigned) ((size + POOL_STEP - 1) / POOL_STEP);
    unsigned *hdr;
    PoolFree *blk;

    if (cls == 0)
        cls = 1;
    blk = poolFree[cls];
    if (blk != NULL) {
        poolFree[cls] = blk->next;
        return blk;
    }
    if ((unsigned) (poolEnd - poolCur) < 2 + cls * (POOL_STEP / 4) &&
        !poolNewChunk())
        return NULL;
    hdr = poolCur;
    poolCur += 2 + cls * (POOL_STEP / 4);
    hdr[0] = POOL_MAGIC;
    hdr[1] = cls;
    return hdr + 2;
}

static int
isPoolBlock(void *ptr)
{
    return ((unsigned *) ptr)[-2] == POOL_MAGIC;
}
#endif /* __MVS__ */

void
BmemInit(void)
{
    outOfMemory = 0;
    reserve = malloc(RESERVE_SIZE);
#ifdef __MVS__
    poolOwner = currentTcb();
    memset(poolFree, 0, sizeof(poolFree));
    poolCur = poolEnd = NULL;
    poolChunks = NULL;
#endif
}

void
BmemTerm(void)
{
#ifdef __MVS__
    void *chunk;

    while (poolChunks != NULL && poolOwner == currentTcb()) {
        chunk = poolChunks;
        poolChunks = (void *) ((unsigned *) chunk)[0];
        free(chunk);
    }
    poolOwner = 0;
    memset(poolFree, 0, sizeof(poolFree));
    poolCur = poolEnd = NULL;
#endif
    free(reserve);
    reserve = NULL;
}

/* Out of memory ends the exec like any error that cannot go on: reported
 * once, RC 60 (61), the exec's storage freed by RxRun(). The error text is
 * built from the reserve; if that fails as well, nothing more is said. It
 * used to allocate again from here and recurse until the abend (#504). */
static void
memoryExhausted(int code)
{
    int again = outOfMemory;

#ifdef __MVS__
    /* The NJE subtask ends alone: RxNoPriv() would drop the main task's
     * PRIVILEGE('ON') under its feet, the reserve is the main task's
     * storage, and RxMemoryError() would longjmp into the main task's frame.
     * __NJERECEIVE reports the error. The message is lost if stderr is not
     * open in the subtask yet. */
    if (poolOwner != 0 && currentTcb() != poolOwner) {
        fprintf(stderr, "Error %d: %s\n", code, code == ERR_REALLOC_FAILED ?
                "Memory reallocation failed." : "Memory allocation failed.");
        njeSubtaskFailed(code);
        subtaskEnd(code);
    }
#endif
    outOfMemory = 1;
    RxNoPriv();     /* the free() below must not run under PRIVILEGE('ON') (#191) */
    free(reserve);
    reserve = NULL;
    RxMemoryError(code, again);
}

/* -------------- malloc_or_die ---------------- */
void *
malloc_or_die(size_t size, __unused char *desc)
{
    void *ptr;

#ifdef __MVS__
    if (size <= POOL_MAXSIZE && poolOwner != 0 && !_authorisedGranted &&
        currentTcb() == poolOwner)
        ptr = poolAlloc(size);
    else
#endif
        ptr = malloc(size);
    if (!ptr)
        memoryExhausted(ERR_MALLOC_FAILED);

    return ptr ;
}

/* -------------- realloc_or_die ---------------- */
void *
realloc_or_die(void *ptr, size_t size)
{
    void *new;

    size++;

#ifdef __MVS__
    if (ptr != NULL && isPoolBlock(ptr)) {
        size_t old = ((unsigned *) ptr)[-1] * POOL_STEP;

        if (size <= old)
            return ptr;
        new = malloc_or_die(size, "realloc");
        memcpy(new, ptr, old);
        free_or_die(ptr);
        return new;
    }
#endif
    new = realloc(ptr, size);
    if (!new)
        memoryExhausted(ERR_REALLOC_FAILED);

    return new;
}

void
free_or_die(void *ptr)
{
    if (ptr == NULL)
        return;
#ifdef __MVS__
    if (isPoolBlock(ptr)) {
        unsigned cls = ((unsigned *) ptr)[-1];

        /* a block of the pool must not be linked by another task */
        if (currentTcb() == poolOwner && cls >= 1 && cls <= POOL_CLASSES) {
            ((PoolFree *) ptr)->next = poolFree[cls];
            poolFree[cls] = (PoolFree *) ptr;
        }
        return;
    }
#endif
    if (isAuxiliaryMemory(ptr)) {
#ifdef __DEBUG__
        printf("TBD> FREE AUXILIARY MEMORY\n");
#endif
    } else {
        free(ptr);
    }
}
#else
#define MAGIC1	0xDECAFFEE
#define MAGIC2	0xDECAFFFF

/*
 * This file provides some debugging functions for memory allocation
 */
typedef struct tmemory_st {
    dword	magic;
    char	*desc;
    size_t	size;
    struct	tmemory_st *next;
    struct	tmemory_st *prev;
//#if defined(ALIGN) && !defined(__ALPHA)
//	/* Some machines have problems if the address is not at 8-bytes aligned */
//	int	dummy;
//#endif
    byte	data[sizeof(dword)];
} Memory;

static Memory	*mem_head = NULL;
static long	total_mem = 0L;

void mem_list(void);

/* -------------- mem_malloc ---------------- */
void *
mem_malloc(size_t size, char *desc)
{
    Memory	*mem;

    /* add space for the header */
    if(size == 0) {
        fprintf ( stderr, "ERROR: zero sized memory requested for %s \n", desc) ;
        raise(SIGSEGV);
    }

    mem = (Memory *)malloc(sizeof(Memory)+size);
    if (mem) {
        /* Create the memory header */
        mem->magic = MAGIC1;
        mem->desc = desc;
        mem->size = size;
        mem->next = NULL;
        mem->prev = mem_head;
        if (mem_head)
            mem_head->next = mem;

        mem_head = mem;
        total_mem += size;

        /* Mark also the END of data */
        *(dword *)((byte*)mem->data+mem->size) = MAGIC2;

        return (void *)(mem->data);
    } else {
        fprintf ( stderr, "ERROR: memory allocation for %s failed: %s\n", desc, strerror ( errno )) ;
        raise(SIGSEGV);
    }
} /* mem_malloc */

/* -------------- mem_realloc ---------------- */
void *
mem_realloc(void *ptr, size_t size)
{
    Memory	*mem, *other;
    int	head;

    /* find our header */
    mem = (Memory *)((char *)ptr - (sizeof(Memory)-sizeof(dword)));

    /* check if the memory is valid */
    if (mem->magic != MAGIC1) {
        fprintf(STDERR,"mem_realloc: PREFIX Magic number doesn't match of object %p!\n",ptr);
        mem_list();
        raise(SIGSEGV);
    }

    if (*(dword *)(mem->data+mem->size) != MAGIC2) {
        fprintf(STDERR,"mem_realloc: SUFFIX Magic number doesn't match of object %p!\n",ptr);
        mem_list();
        raise(SIGSEGV);
    }

    if(size == 0) {
        fprintf ( stderr, "ERROR: zero sized memory requested for reallocation of %s\n", mem->desc) ;
        raise(SIGSEGV);
    }

    total_mem -= mem->size;
    head = (mem==mem_head);

    mem = (Memory *)realloc(mem,size+sizeof(Memory));

    if (mem==NULL) {
        fprintf(STDERR,"mem_realloc: Not enough memory to allocate object %s size=%lu\n",
                mem->desc,(unsigned long)size);
        raise(SIGSEGV);
    }

    if (head) mem_head = mem;
    mem->size = size;
    total_mem += size;

    other = mem->prev;
    if (other)	other->next = mem;
    other = mem->next;
    if (other)	other->prev = mem;

    /* Mark also the new END of data */
    *(dword *)(mem->data+mem->size) = MAGIC2;

    return (void *)(mem->data);
} /* mem_realloc */

/* -------------- mem_free ---------------- */
void __CDECL
mem_free(void *ptr)
{
    Memory	*mem, *mem_prev, *mem_next;
    int	head;

    if (isAuxiliaryMemory(ptr)) {
#ifdef __DEBUG__
        printf("TBD> FREE AUXILIARY MEMORY\n");
#endif
        return;
    }

    /* find our header */
    mem = (Memory *)((char *)ptr - (sizeof(Memory)-sizeof(dword)));

    if (mem->magic != MAGIC1) {
        fprintf(STDERR,"mem_free: PREFIX Magic number doesn't match of object %p!\n",ptr);
        mem_list();
        raise(SIGSEGV);
        return;
    }
    if (*(dword *)(mem->data+mem->size) != MAGIC2) {
        fprintf(STDERR,"mem_free: SUFFIX Magic number doesn't match!\n");
        mem_list();
        raise(SIGSEGV);
        return;
    }

    /* Remove the MAGIC number, just to catch invalid entries */
    mem->magic = 0L;

    mem_prev = mem->prev;
    mem_next = mem->next;
    total_mem -= mem->size;
    head = (mem==mem_head);

    free(mem);

    if (mem_next) mem_next->prev = mem_prev;
    if (mem_prev) mem_prev->next = mem_next;
    if (head) mem_head = mem_prev;

} /* mem_free */

/* -------------- mem_print --------------- */
static void
mem_print(int count, Memory *mem)
{
    int	i;

    fputs((mem->magic==MAGIC1)?"  ":"??",STDERR);

    fprintf(STDERR,"%3d %5lu %p %s\t\"",
        count, (unsigned long)mem->size, mem->data, mem->desc);
    for (i=0; i<10; i++)
        fprintf(STDERR,"%c",
            isprint(mem->data[i])? mem->data[i]: '.');
    fprintf(STDERR,"\" ");
    for (i=0; i<10; i++)
        fprintf(STDERR,"%02X ",mem->data[i]);
    fprintf(STDERR,"\n");
} /* mem_print */

/* -------------- mem_list ---------------- */
void __CDECL
mem_list(void)
{
    Memory	*mem;
    int	y, count;

    mem = mem_head;
    count = 0;
    fprintf(STDERR,"\nMemory list:\n");
    y = 0;
    while (mem) {
        mem_print(count++,mem);
        mem = mem->prev;
        if (++y==15) {
            if (getchar()=='q') exit(0);
            y = 0;
        }
    }
    fprintf(STDERR,"\n");
} /* mem_list */

/* --------------- mem_chk ------------------- */
int __CDECL
mem_chk( void )
{
    Memory	*mem;
    int	i=0;
    for (mem=mem_head; mem; mem = mem->prev,i++) {
        if (mem->magic != MAGIC1) {
            fprintf(STDERR,"mem_chk: PREFIX Magic number doesn't match! ID=%d\n",i);
            mem_print(i,mem);
            mem_list();
        }
        if (*(dword *)(mem->data+mem->size) != MAGIC2) {
            fprintf(STDERR,"mem_chk: SUFFIX Magic number doesn't match! ID=%d\n",i);
            mem_print(i,mem);
            mem_list();
        }
    }
    return 0;
} /* mem_chk */

/* -------------- mem_allocated ----------------- */
long __CDECL
mem_allocated( void )
{
    return total_mem;
} /* mem_allocated */

/* -------------- mem_first ---------------- */
void * __CDECL
mem_first(void)
{
    Memory	*mem;

    // oldest block: the end of the prev chain; mem_head when it is alone
    mem = mem_head;
    while (mem && mem->prev) {
        mem = mem->prev;
    }
    return mem;
} /* mem_first */

/* -------------- mem_last ---------------- */
void * __CDECL
mem_last(void)
{
    Memory	*mem = mem_head;

    if (mem) {
        return mem;
    } else {
        return 0;
    }
} /* mem_last */

/* -------------- mem_count ---------------- */
int __CDECL
mem_count(void)
{
    Memory	*mem;
    int	count;

    mem = mem_head;
    count = 0;

    while (mem) {
        count++;
        mem = mem->prev;
    }
    return count;
} /* mem_count */

#endif
