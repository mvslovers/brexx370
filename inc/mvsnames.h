/*
 * mvsnames.h - force-included into every translation unit of the cc370
 * build ([build] cflags in project.toml)
 *
 * cc370 maps external names to 8 uppercase characters. lmvs.h and rxmvs.h
 * carry the renames that keep BREXX's long names unique; they must be
 * active in EVERY translation unit, otherwise a definition and its
 * references end up with different MVS names. Hence a force-include and
 * not an #include in each file.
 */
#ifndef BREXX_MVSNAMES_H
#define BREXX_MVSNAMES_H

#ifdef __MVS__
#include "lmvs.h"
#include "rxmvs.h"
#endif

/* an intentionally unused parameter, e.g. "func" of a REXX function */
#ifndef __unused
#define __unused __attribute__((unused))
#endif

#endif /* BREXX_MVSNAMES_H */
