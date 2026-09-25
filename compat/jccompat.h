/*
 * jccompat.h - JCC runtime compatibility layer for the cc370/libc370 build
 *
 * BREXX/370 was written against the JCC compiler and its C runtime. The
 * mbt v2 build compiles it with cc370 (GCC 3.4.6, i370) and links it with
 * libc370 instead. This header is force-included into every translation
 * unit of the cc370 build (see [build] cflags in project.toml) and maps the
 * JCC-specific runtime API onto libc370, or declares a replacement that is
 * implemented in compat/jccompat.c.
 *
 * Everything here is inactive for the JCC build (JCC defined) and for the
 * host build (__CROSS__ defined), which keep using their own headers.
 *
 * Items marked "TODO(cc370)" are known gaps: they compile and link, but do
 * not (yet) provide the JCC behaviour. See docs/cc370-migration.md.
 */
#ifndef JCCOMPAT_H
#define JCCOMPAT_H

#if !defined(JCC) && !defined(__CROSS__)

#define BREXX_CC370 1

/*
 * cc370 maps external names to 8 uppercase characters. rxmvs.h / lmvs.h
 * carry the renames that keep BREXX's long names unique; they must be
 * active in EVERY translation unit, otherwise a definition and its
 * references end up with different MVS names.
 */
#include "lmvs.h"
#include "rxmvs.h"

#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>
#include <errno.h>
#include <time.h>
#include <setjmp.h>

/* libc370's <stdint.h> only knows (u)intptr_t for a list of host CPUs,
 * i370 is not among them. TODO(cc370): mvslovers/libc370#187 */
#define STDINT_H_UINTPTR_T_DEFINED
#include <stdint.h>
typedef unsigned int uintptr_t;
typedef int          intptr_t;

/* JCC headers define this for "intentionally unused" parameters */
#ifndef __unused
#define __unused
#endif

/* ------------------------------------------------------------------ */
/* File naming style (JCC: extern char *_style)                        */
/* ------------------------------------------------------------------ */
/*
 * JCC interprets a plain file name according to _style ("//DDN:" by
 * default, "//DSN:" for a fully qualified dataset name, "//MEM:" for a
 * memory file). A name may also carry an explicit style prefix.
 * libc370's fopen() expects "DD:name" for a DD name and treats a plain
 * name as a dataset name (quoted = fully qualified). jcc_fopen() does the
 * translation and strips the JCC-only mode extensions (",recfm=...").
 */
extern char *_style;

FILE *jcc_fopen(const char *filename, const char *mode)   asm("JCCFOPEN");
#define fopen(f, m)  jcc_fopen((f), (m))

/*
 * JCC low level file handles. BREXX only uses a handle to query dataset
 * information of an open stream, so the handle simply is the FILE pointer
 * (31-bit addresses fit into an int).
 */
int jcc_fileno(FILE *fp)                                    asm("JCCFILNO");
int jcc_isatty(int handle)                                  asm("JCCISTTY");
#define fileno(fp)   jcc_fileno(fp)
#define isatty(h)    jcc_isatty(h)

int __get_ddndsnmemb(int handle, char *ddn, char *dsn, char *member,
                     char *serial, unsigned char *flags)    asm("JCCGDDNM");

/* open() flags used by BREXX (values as in JCC) */
#define _O_RDONLY  0x0000
#define _O_WRONLY  0x0001
#define _O_RDWR    0x0002
#define _O_TEXT    0x0004
#define _O_BINARY  0x0008
#define _O_APPEND  0x0010
#define _O_TRUNC   0x0020
#define _O_CREAT   0x0040
#define _O_EXCL    0x0080
#define O_RDONLY   _O_RDONLY
#define O_WRONLY   _O_WRONLY
#define O_RDWR     _O_RDWR
#define O_TEXT     _O_TEXT
#define O_BINARY   _O_BINARY
#define O_APPEND   _O_APPEND
#define O_TRUNC    _O_TRUNC
#define O_CREAT    _O_CREAT
#define O_EXCL     _O_EXCL

#define STDIN_FILENO  0
#define STDOUT_FILENO 1
#define STDERR_FILENO 2

/* ------------------------------------------------------------------ */
/* JCC runtime globals                                                 */
/* ------------------------------------------------------------------ */
/* TODO(cc370): the JCC runtime maintains these; libc370 has no
 * equivalent, the compat layer only provides the storage. */
#define __libc_tso_status  jccTsoSt   /* keep the names unique in 8 chars */
#define __libc_arch        jccArch
#define __libc_heap_used   jccHpUsd
#define __libc_heap_max    jccHpMax
#define __libc_stack_used  jccStUsd
#define __libc_stack_max   jccStMax
/* JCC: caller's save area at program entry; BREXX reads entry_R13[6]
 * (R1 at entry = the CPPL under TSO). Emulated from libc370's PPA. */
void **jcc_entry_r13(void)                                  asm("JCCENR13");
#define entry_R13 (jcc_entry_r13())
extern int    __libc_tso_status;
extern long   __libc_arch;
extern long   __libc_heap_used;
extern long   __libc_heap_max;
extern long   __libc_stack_used;
extern long   __libc_stack_max;

/* ------------------------------------------------------------------ */
/* Authorization, recovery, operator messages                          */
/* ------------------------------------------------------------------ */
int  _testauth(void)                                        asm("JCCTAUTH");
int  _modeset(int p)                                        asm("JCCMODES");
int  _write2op(char *msg)                                   asm("JCCW2OP");

/*
 * BREXX's own assembler routines. The JCC build renamed their entry points
 * with objscan (legacy/rxmvsext.nam); cc370 references them by the real
 * MVS names instead.
 */
#define call_rxikj441   RXIKJ441
#define call_rxabend    RXABEND
#define call_rxinit     RXINIT
#define call_rxterm     RXTERM
#define call_rxvsam     RXVSAM
#define call_rxtso      RXTSO
#define call_rxsvc      RXSVC
#define cputime         RXCPUTIM
#define systemCP        RXCPCMD
#define _setjmp_estae   RXSETJMP        /* asm/rxestae.asm */
#define _setjmp_ecanc   RXECANC         /* asm/rxestae.asm */

/*
 * JCC runtime STAE based setjmp: returns 0 when the recovery environment
 * was established and non-zero after an abend was intercepted.
 * TODO(cc370): map onto libc370's __estae()/try(); currently the
 * recovery environment is NOT established (abends are not caught).
 */
int  _setjmp_stae(jmp_buf jbs, char *sdwa104)               asm("JCCSTAE");
int  _setjmp_canc(void)                                     asm("JCCSCANC");

/* ------------------------------------------------------------------ */
/* gettimeofday() - JCC provides the BSD interface                     */
/* ------------------------------------------------------------------ */
#include <socket.h>             /* libc370 defines struct timeval here */
struct timezone {
    int tz_minuteswest;
    int tz_dsttime;
};
int gettimeofday(struct timeval *tv, struct timezone *tz)   asm("JCCGTOD");

/* ------------------------------------------------------------------ */
/* Misc. JCC library functions                                         */
/* ------------------------------------------------------------------ */
char *strupr(char *string)                                  asm("JCCSTRUP");
int   _msize(void *ptr)                                     asm("JCCMSIZE");
void  Sleep(long millis)                                    asm("JCCSLEEP");
int   systemTSO(char *cmd)                                  asm("JCCSYTSO");
char *getlogin(void)                                        asm("JCCGLOGN");

/* ------------------------------------------------------------------ */
/* Sockets: libc370's <socket.h> is winsock-like, add the JCC spellings */
/* ------------------------------------------------------------------ */
#include <socket.h>

#define SOCKET          int
#define SOCKADDR_IN     struct sockaddr_in
#define LPSOCKADDR      struct sockaddr *
#define INVALID_SOCKET  (-1)
#define SOCKET_ERROR    (-1)
#ifndef PF_INET
#define PF_INET         AF_INET
#endif
#define WSAGetLastError() errno
#ifndef EWOULDBLOCK
#define EWOULDBLOCK     35
#endif
#ifndef EINPROGRESS
#define EINPROGRESS     36
#endif
#define WSAEWOULDBLOCK  EWOULDBLOCK
#define WSAEINPROGRESS  EINPROGRESS
typedef int socklen_t;

unsigned long inet_addr(const char *cp)                     asm("JCCINADR");

/* ------------------------------------------------------------------ */
/* Threads (JCC <process.h>), implemented with libc370 cthreads.       */
/* Requires the crt1 startup (startup = "crt1" in project.toml).       */
/* ------------------------------------------------------------------ */
long beginthread(int (*start)(void *), unsigned stack, void *arg)
                                                            asm("JCCBTHRD");
int  syncthread(long threadid)                              asm("JCCSTHRD");
void endthread(int rc)                                      asm("JCCETHRD");

#endif /* !JCC && !__CROSS__ */
#endif /* JCCOMPAT_H */
