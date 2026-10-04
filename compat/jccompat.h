/*
 * jccompat.h - what is left of the JCC compatibility layer (#298)
 *
 * BREXX/370 was written against the JCC compiler and its C runtime. The
 * mbt v2 build compiles it with cc370 (GCC 3.4.6, i370) and links it with
 * libc370 instead. This header is force-included into every translation
 * unit of the cc370 build (see [build] cflags in project.toml). The JCC
 * runtime API it used to map onto libc370 is gone; what remains is the
 * BREXX_CC370 marker, the 8-character external name renames, the standard
 * headers every file expects, (u)intptr_t and __unused.
 *
 * Everything here is inactive for the JCC build (JCC defined) and for the
 * host build (__CROSS__ defined), which keep using their own headers.
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

/* an intentionally unused parameter, e.g. "func" of a REXX function */
#ifndef __unused
#define __unused __attribute__((unused))
#endif

#endif /* !JCC && !__CROSS__ */
#endif /* JCCOMPAT_H */
