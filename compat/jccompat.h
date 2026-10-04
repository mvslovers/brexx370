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
#include <mvs/socket.h>

/* libc370's <stdint.h> only knows (u)intptr_t for a list of host CPUs,
 * i370 is not among them. TODO(cc370): mvslovers/libc370#187 */
#define STDINT_H_UINTPTR_T_DEFINED
#include <stdint.h>
typedef unsigned int uintptr_t;
typedef int          intptr_t;

/* an intentionally unused parameter, e.g. "func" of a REXX function */
#ifndef __unused
#define __unused __attribute__((unused))
#endif

/* ------------------------------------------------------------------ */
/* Files: BREXX opens data sets through src/dsio.c on libc370 (#299).   */
/* JCC's _style, jcc_fopen(), fileno() and its handles are gone.       */
/* ------------------------------------------------------------------ */

/* ------------------------------------------------------------------ */
/* Sockets: <mvs/socket.h> brings libc370's POSIX socket headers and its */
/* winsock-like calls (closesocket, ioctlsocket); add the JCC spellings */
/* ------------------------------------------------------------------ */

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
