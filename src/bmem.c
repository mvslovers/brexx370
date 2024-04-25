#define __BMEM_C__
#include "lerror.h"
#include "lstring.h"
#include "util.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <ctype.h>

#if !defined(__CMS__) && !defined(__MVS__) && !defined(__MACH__)
#	include <malloc.h>
#endif

#include "signal.h"

#define MAGIC	0xDEADBEAF
bool
isAuxiliaryMemory(void *ptr)
{
    bool isAuxMem;
    dword *tmp;
    int a = 0;

#ifdef JCC
    a = _msize(ptr);
#endif

    if (a == 0) {
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
/* -------------- malloc_or_die ---------------- */
void *
malloc_or_die(size_t size, char *desc)
{
    void *ptr = malloc(size);
    if (!ptr) {
        Lstr lerrno;

        LINITSTR(lerrno)
        Lfx(&lerrno,31);

        Lscpy(&lerrno,strerror(errno));

        Lerror(ERR_MALLOC_FAILED,0);
        fprintf(stderr, "errno: %s\n",strerror(errno));

        LFREESTR(lerrno);
        raise(SIGSEGV);
    }

    return ptr ;
}

/* -------------- realloc_or_die ---------------- */
void *
realloc_or_die(void *ptr, size_t size)
{
    size++;

    ptr = realloc(ptr,size);

    if (!ptr) {

        fprintf(STDERR,"realloc_or_die: Not enough memory to allocate %zu bytes \n", size);

        Lerror(ERR_REALLOC_FAILED, 0);

        raise(SIGSEGV);
    }

    return ptr;
}

void
free_or_die(void *ptr)
{
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
#if defined(__BORLANDC__)&&(defined(__HUGE__)||defined(__LARGE__))
    mem = (Memory *)farmalloc(sizeof(Memory)+size);
#else
    if(size == 0) {
        fprintf ( stderr, "ERROR: zero sized memory requested for %s \n", desc) ;
        raise(SIGSEGV);
    }

    mem = (Memory *)malloc(sizeof(Memory)+size);
#endif
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

#if defined(__BORLANDC__)&&(defined(__HUGE__)||defined(__LARGE__))
    mem = (Memory *)farrealloc(mem,size+sizeof(Memory));
#else
    mem = (Memory *)realloc(mem,size+sizeof(Memory));
#endif

    if (mem==NULL) {
        fprintf(STDERR,"mem_realloc: Not enough memory to allocate object %s size=%zu\n",
                mem->desc,size);
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

#if defined(__BORLANDC__)&&(defined(__HUGE__)||defined(__LARGE__))
    farfree(mem);
#else
    free(mem);
#endif

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

    fprintf(STDERR,"%3d %5zu %p %s\t\"",
        count, mem->size, mem->data, mem->desc);
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
    Memory	*mem,*tmp;

    tmp = mem_head;
    while (tmp) {
        tmp = tmp->prev;
        if (tmp) {
            mem = tmp;
        }
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
